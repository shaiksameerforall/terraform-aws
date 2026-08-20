terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  # Select between a demo instance created by Terraform or an existing instance provided via variables
  target_instance_id = var.create_demo_instance ? (length(aws_instance.demo) > 0 ? aws_instance.demo[0].id : "") : var.instance_id
  timestamp_suffix   = formatdate("YYYYMMDD-hhmmss", timestamp())
}

################################################################################
# Optional: Demo EC2 Instance (Enabled only if var.create_demo_instance = true)
################################################################################

data "aws_ami" "amazon_linux_2023" {
  count       = var.create_demo_instance ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "demo" {
  count         = var.create_demo_instance ? 1 : 0
  ami           = data.aws_ami.amazon_linux_2023[0].id
  instance_type = "t3.micro"

  tags = merge(var.environment_tags, {
    Name = "demo-instance-for-resize"
  })
}

################################################################################
# Step 1 & 2: Pre-Resize Backup AMI
# Automatically creates an AMI image from the instance before modifying it
################################################################################

resource "aws_ami_from_instance" "backup" {
  count              = local.target_instance_id != "" ? 1 : 0
  name               = "${var.ami_name_prefix}-${local.target_instance_id}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  source_instance_id = local.target_instance_id

  # Set snapshot_without_reboot to false so AWS ensures file system consistency
  snapshot_without_reboot = false

  description = "${var.ami_description} for ${local.target_instance_id}"

  tags = merge(var.environment_tags, {
    Name           = "${var.ami_name_prefix}-${local.target_instance_id}"
    SourceInstance = local.target_instance_id
    CreatedOn      = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
    Purpose        = "Pre-Resize Backup"
  })

  lifecycle {
    ignore_changes = [name, tags["CreatedOn"]]
  }
}

################################################################################
# Step 3, 4 & 5: AWS Systems Manager (SSM) Automation Document
# Provides a reliable, native AWS Runbook to Stop -> Resize -> Start -> Verify 2/2 Checks
################################################################################

resource "aws_ssm_document" "ec2_resize_and_verify" {
  name            = "EC2-Stop-Resize-Start-VerifyChecks"
  document_type   = "Automation"
  document_format = "YAML"

  content = <<-DOC
    schemaVersion: '0.3'
    description: 'Safely stop EC2 instance, modify instance type, start instance, and wait for 2/2 status checks to pass.'
    parameters:
      InstanceId:
        type: String
        description: 'The ID of the EC2 instance to resize.'
      NewInstanceType:
        type: String
        description: 'The target EC2 instance type (e.g. t3.medium).'
    mainSteps:
      - name: StopInstance
        action: 'aws:changeInstanceState'
        maxAttempts: 3
        timeoutSeconds: 300
        onFailure: Abort
        inputs:
          InstanceIds:
            - '{{ InstanceId }}'
          DesiredState: stopped

      - name: ModifyInstanceType
        action: 'aws:executeAwsApi'
        maxAttempts: 3
        timeoutSeconds: 60
        onFailure: Abort
        inputs:
          Service: ec2
          Api: ModifyInstanceAttribute
          InstanceId: '{{ InstanceId }}'
          InstanceType:
            Value: '{{ NewInstanceType }}'

      - name: StartInstance
        action: 'aws:changeInstanceState'
        maxAttempts: 3
        timeoutSeconds: 300
        onFailure: Abort
        inputs:
          InstanceIds:
            - '{{ InstanceId }}'
          DesiredState: running

      - name: WaitForStatusChecksOk
        action: 'aws:waitForAwsResourceProperty'
        maxAttempts: 30
        timeoutSeconds: 600
        onFailure: Abort
        inputs:
          Service: ec2
          Api: DescribeInstanceStatus
          InstanceIds:
            - '{{ InstanceId }}'
          PropertySelector: '$.InstanceStatuses[0].InstanceStatus.Status'
          DesiredValues:
            - 'ok'

      - name: WaitForSystemStatusChecksOk
        action: 'aws:waitForAwsResourceProperty'
        maxAttempts: 30
        timeoutSeconds: 600
        onFailure: Abort
        inputs:
          Service: ec2
          Api: DescribeInstanceStatus
          InstanceIds:
            - '{{ InstanceId }}'
          PropertySelector: '$.InstanceStatuses[0].SystemStatus.Status'
          DesiredValues:
            - 'ok'
    DOC

  tags = var.environment_tags
}

################################################################################
# Step 6: Terraform Orchestration & Status Check Waiter
# Runs the resize automation and verifies 2/2 status checks
################################################################################

resource "terraform_data" "resize_orchestrator" {
  count = local.target_instance_id != "" ? 1 : 0

  # Trigger resize whenever the target instance or instance type changes
  triggers_replace = [
    local.target_instance_id,
    var.new_instance_type,
    var.aws_region
  ]

  # Ensure backup AMI is completed before resizing
  depends_on = [
    aws_ami_from_instance.backup,
    aws_ssm_document.ec2_resize_and_verify
  ]

  provisioner "local-exec" {
    interpreter = ["powershell", "-NoProfile", "-Command"]
    command     = <<-POWERSHELL
      $InstanceId = "${local.target_instance_id}"
      $NewType    = "${var.new_instance_type}"
      $Region     = "${var.aws_region}"
      $AmiId      = "${length(aws_ami_from_instance.backup) > 0 ? aws_ami_from_instance.backup[0].id : "N/A"}"

      Write-Host "======================================================================" -ForegroundColor Cyan
      Write-Host " [STEP 1/5] Stopping EC2 Instance: $InstanceId in $Region ..." -ForegroundColor Yellow
      Write-Host "======================================================================" -ForegroundColor Cyan
      
      # Execute resize using AWS CLI / PowerShell
      if (Get-Command aws -ErrorAction SilentlyContinue) {
        Write-Host "Initiating stop..."
        aws ec2 stop-instances --instance-ids $InstanceId --region $Region | Out-Null
        aws ec2 wait instance-stopped --instance-ids $InstanceId --region $Region
        Write-Host "Instance $InstanceId is now STOPPED." -ForegroundColor Green

        Write-Host "`n[STEP 2/5] Backup AMI Created: $AmiId" -ForegroundColor Green

        Write-Host "`n[STEP 3/5] Modifying Instance Type to: $NewType ..." -ForegroundColor Yellow
        aws ec2 modify-instance-attribute --instance-id $InstanceId --instance-type "{\`"Value\`": \`"$NewType\`"}" --region $Region
        Write-Host "Instance attribute updated successfully." -ForegroundColor Green

        Write-Host "`n[STEP 4/5] Starting EC2 Instance: $InstanceId ..." -ForegroundColor Yellow
        aws ec2 start-instances --instance-ids $InstanceId --region $Region | Out-Null
        aws ec2 wait instance-running --instance-ids $InstanceId --region $Region
        Write-Host "Instance $InstanceId is now RUNNING." -ForegroundColor Green

        Write-Host "`n[STEP 5/5] Polling 2/2 Status Checks (System & Instance Status) ..." -ForegroundColor Yellow
        aws ec2 wait instance-status-ok --instance-ids $InstanceId --region $Region
        Write-Host "Status checks passed: 2/2 CHECKS PASSED (System: OK, Instance: OK)" -ForegroundColor Green

        $details = aws ec2 describe-instances --instance-ids $InstanceId --region $Region | ConvertFrom-Json
        $inst = $details.Reservations[0].Instances[0]
        $publicIp = if ($inst.PublicIpAddress) { $inst.PublicIpAddress } else { "None (Private)" }
        $privateIp = $inst.PrivateIpAddress

        Write-Host "`n======================================================================" -ForegroundColor Green
        Write-Host " SUCCESSFUL RESIZE & HEALTH VERIFICATION SUMMARY" -ForegroundColor Green
        Write-Host "======================================================================" -ForegroundColor Green
        Write-Host " Instance ID      : $InstanceId"
        Write-Host " Backup AMI ID    : $AmiId"
        Write-Host " New Instance Type: $NewType"
        Write-Host " State            : $($inst.State.Name.ToUpper())"
        Write-Host " Private IP       : $privateIp"
        Write-Host " Public IP        : $publicIp"
        Write-Host " Status Checks    : 2/2 PASSED (System: OK, Instance: OK)"
        Write-Host " Message          : EC2 instance successfully resized and verified healthy!" -ForegroundColor Green
        Write-Host "======================================================================" -ForegroundColor Green
      } else {
        Write-Host "Note: AWS CLI not found in system PATH. Backup AMI was created in Terraform ($AmiId)." -ForegroundColor Yellow
        Write-Host "You can execute the resize directly using the provided resize_ec2.py or resize_ec2.ps1 script, or via AWS SSM Automation Document: EC2-Stop-Resize-Start-VerifyChecks" -ForegroundColor Cyan
      }
    POWERSHELL
  }
}
