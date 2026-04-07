#!/bin/bash

set -euo pipefail

LOG_FILE="$HOME/linux-production-server/docs/k3s-setup.log"

log() {
  local message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

mkdir -p "$HOME/linux-production-server/docs"
touch "$LOG_FILE"

log "Starting k3s setup..."

if command -v k3s >/dev/null 2>&1; then 
  log "k3s is already installed. Skipping installation."
else
  log "Installing k3s..."
  curl -sSfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh - 2>&1 | tee -a "$LOG_FILE"
fi

log "Checking k3s service status.."
sudo systemctl enable k3s 2>&1 | tee -a "$LOG_FILE"
sudo systemctl start k3s 2>&1 | tee -a "$LOG_FILE"

log "Waiting for node to become ready..."
sleep 10

log "Verifying cluster..."
sudo k3s kubectl get nodes -o wide 2>&1 | tee -a "$LOG_FILE"

log "Setting up kubeconfig for current user..."
mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$USER:$USER" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"
log "kubeconfig copied to $HOME/.kube/config"

log "k3s setup complete."
