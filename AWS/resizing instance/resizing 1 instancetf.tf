terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_id" {
  type        = string
  description = "Target EC2 Instance ID"
}

variable "new_instance_type" {
  type        = string
  default     = "t3.large"
  description = "Desired new instance type"
}

# Step 1: Stop the EC2 Instance
resource "aws_ec2_instance_state" "stop" {
  instance_id = var.instance_id
  state       = "stopped"
}

# Step 2: Create an AMI (depends on instance being stopped)
resource "aws_ami_from_instance" "backup_image" {
  name               = "backup-image-${var.instance_id}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  source_instance_id = var.instance_id
  snapshot_without_reboot = true

  depends_on = [aws_ec2_instance_state.stop]
}

# Step 3: Change Instance Type & Step 4: Start the Instance
resource "null_resource" "modify_and_start" {
  triggers = {
    ami_id        = aws_ami_from_instance.backup_image.id
    instance_type = var.new_instance_type
  }

  # Modify the instance type while stopped
  provisioner "local-exec" {
    command = "aws ec2 modify-instance-attribute --region ${var.aws_region} --instance-id ${var.instance_id} --instance-type '{\"Value\": \"${var.new_instance_type}\"}'"
  }

  # Start the instance
  provisioner "local-exec" {
    command = "aws ec2 start-instances --region ${var.aws_region} --instance-ids ${var.instance_id}"
  }

  # Step 5: Wait for status checks to pass and output success message
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for 2/2 system and instance status checks to pass..."
      aws ec2 wait instance-status-ok --region ${var.aws_region} --instance-ids ${var.instance_id}
      echo "SUCCESS: Instance ${var.instance_id} resized to ${var.new_instance_type} and passed all health checks."
    EOT
  }

  depends_on = [aws_ami_from_instance.backup_image]
}

output "operation_status" {
  value = "Instance ${var.instance_id} successfully resized to ${var.new_instance_type} and verified healthy."
  depends_on = [null_resource.modify_and_start]
}