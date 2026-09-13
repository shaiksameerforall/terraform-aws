#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)"
TF_DIR="$REPO_ROOT/terraform"

cat <<'MSG'
Before destroying:
1. Delete Mule apps deployed to Runtime Fabric.
2. Delete API gateways deployed to Runtime Fabric.
3. Delete the Runtime Fabric record from Anypoint Runtime Manager.
4. Then continue with Terraform destroy.
MSG

read -r -p "Continue with terraform destroy? Type yes: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Destroy cancelled."
  exit 1
fi

cd "$TF_DIR"
terraform destroy
