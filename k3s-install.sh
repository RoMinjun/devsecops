#!/bin/bash
# Usage:
#   ./k3s-install.sh server
#   ./k3s-install.sh agent <server_ip> <token>

set -euo pipefail

prep() {
  # 1) Disable swap
  swapoff -a
  sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

  # 2) Kernel modules + sysctl for networking
  cat <<EOF >/etc/modules-load.d/k3s.conf
overlay
br_netfilter
EOF

  modprobe overlay
  modprobe br_netfilter

  cat <<EOF >/etc/sysctl.d/99-k3s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

  sysctl --system >/dev/null
}

ROLE=${1:-}
SERVER_IP=${2:-}
TOKEN=${3:-}

case "$ROLE" in
  server)
    prep
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
    ;;
  agent)
    if [ -z "$SERVER_IP" ] || [ -z "$TOKEN" ]; then
      echo "Usage: $0 agent <server_ip> <token>" >&2
      exit 1
    fi
    prep
    curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN=$TOKEN sh -
    ;;
  *)
    echo "Usage: $0 [server|agent] [server_ip] [token]" >&2
    exit 1
    ;;
esac