terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "external" "dynamodb_count" {

  program = [
    "powershell.exe",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    "${path.module}\\hitcount.ps1"
  ]
}

output "dynamodb_hitcounter_count" {
  value = data.external.dynamodb_count.result.count
}

output "excel_report" {
  value = data.external.dynamodb_count.result.file
}