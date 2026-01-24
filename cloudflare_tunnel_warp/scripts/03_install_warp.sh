#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0" >&2
  exit 1
fi

apt-get update -y
apt-get install -y curl gpg lsb-release ca-certificates

install -d -m 0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/cloudflare-client.list

apt-get update -y
apt-get install -y cloudflare-warp

# Start service
systemctl enable warp-svc || true
systemctl start warp-svc || true

# Register & connect (proxy mode gives local SOCKS5 on 127.0.0.1:40000)
warp-cli register || true
warp-cli set-mode proxy
warp-cli connect

echo "WARP status:"
warp-cli status || true

echo "Public IP from VPS (should be Cloudflare/WARP if connected):"
curl -s ifconfig.me || true
echo

echo "OK: WARP installed & connected (proxy mode). Next: run scripts/04_apply_xray_warp_egress.sh"
