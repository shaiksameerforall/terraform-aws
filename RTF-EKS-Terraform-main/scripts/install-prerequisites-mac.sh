#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[INFO] $1"
}

if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  log "Homebrew already installed."
fi

log "Installing Terraform, kubectl, Helm, eksctl..."
brew tap hashicorp/tap || true
brew tap aws/tap || true
brew install hashicorp/tap/terraform || true
brew install kubectl || true
brew install helm || true
brew install aws/tap/eksctl || true

if ! command -v aws >/dev/null 2>&1; then
  log "AWS CLI not found. Installing AWS CLI v2 package..."
  curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
  sudo installer -pkg "/tmp/AWSCLIV2.pkg" -target /
else
  log "AWS CLI already installed."
fi

if ! command -v rtfctl >/dev/null 2>&1; then
  log "Installing rtfctl for macOS..."
  curl -L https://anypoint.mulesoft.com/runtimefabric/api/download/rtfctl-darwin/latest -o /tmp/rtfctl
  chmod +x /tmp/rtfctl

  if [ -d "/opt/homebrew/bin" ]; then
    sudo mv /tmp/rtfctl /opt/homebrew/bin/rtfctl
  else
    sudo mv /tmp/rtfctl /usr/local/bin/rtfctl
  fi
else
  log "rtfctl already installed."
fi

log "Versions:"
aws --version || true
terraform version || true
kubectl version --client || true
helm version || true
eksctl version || true
rtfctl -h >/dev/null 2>&1 && echo "rtfctl installed" || true

log "Prerequisite installation completed."
