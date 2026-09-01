#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)"
TF_DIR="$REPO_ROOT/terraform"

cd "$TF_DIR"

if [ ! -f terraform.tfvars ]; then
  echo "terraform.tfvars not found. Creating from terraform.tfvars.example..."
  cp terraform.tfvars.example terraform.tfvars
  echo "Edit terraform/terraform.tfvars before re-running this script."
  exit 1
fi

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
