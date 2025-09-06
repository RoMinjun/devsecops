#!/bin/bash
# Simple helper script to install k3s as a server or agent.
# Usage:
#   ./kubernetes.sh server
#   ./kubernetes.sh agent <server_ip> <token>
set -euo pipefail
ROLE=${1:-}
SERVER_IP=${2:-}
TOKEN=${3:-}
case "$ROLE" in
  server)
    curl -sfL https://get.k3s.io | sh -
    ;;
  agent)
    if [ -z "$SERVER_IP" ] || [ -z "$TOKEN" ]; then
      echo "Usage: $0 agent <server_ip> <token>" >&2
      exit 1
    fi
    curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN=$TOKEN sh -
    ;;
  *)
    echo "Usage: $0 [server|agent] [server_ip] [token]" >&2
    exit 1
    ;;
esac
