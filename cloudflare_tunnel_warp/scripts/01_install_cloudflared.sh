#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0" >&2
  exit 1
fi

apt-get update -y
apt-get install -y curl gpg lsb-release ca-certificates

install -d -m 0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg

echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/ $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/cloudflare.list

apt-get update -y
apt-get install -y cloudflared

cloudflared --version

echo "OK: cloudflared installed. Next: run scripts/02_setup_cloudflared_tunnel.sh"
