variable "aws_region" {
  description = "The AWS Region where the EC2 instance is located"
  type        = string
  default     = "us-east-1"
}

variable "instance_id" {
  description = "The ID of the EC2 instance to stop, image, resize, and start (e.g., i-0123456789abcdef0)"
  type        = string
  default     = ""
}

variable "new_instance_type" {
  description = "The desired new EC2 instance type (e.g., t3.medium, t3.large, m5.large, etc.)"
  type        = string
  default     = "t3.medium"
}

variable "ami_name_prefix" {
  description = "Prefix for the backup AMI name created prior to resizing"
  type        = string
  default     = "backup-before-resize"
}

variable "ami_description" {
  description = "Description for the backup AMI"
  type        = string
  default     = "Automated pre-resize backup image created by Terraform"
}

variable "wait_for_status_checks" {
  description = "Whether to wait for 2/2 system and instance status checks to pass before completing"
  type        = bool
  default     = true
}

variable "create_demo_instance" {
  description = "Set to true if you want Terraform to launch a demo EC2 instance to test the resizing workflow"
  type        = bool
  default     = false
}

variable "environment_tags" {
  description = "Tags to assign to resources created by this module"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Workflow    = "EC2-Resize-With-Backup"
    Environment = "Operations"
  }
}
