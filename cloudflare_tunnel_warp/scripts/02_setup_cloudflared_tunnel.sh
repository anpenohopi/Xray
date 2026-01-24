#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0" >&2
  exit 1
fi

read -rp "Tunnel name (example: vps-tunnel): " TUNNEL_NAME
read -rp "Hostname to expose (example: xray.example.com): " HOSTNAME
read -rp "Local Xray port (example: 10000): " XRAY_PORT

if [[ -z "${TUNNEL_NAME}" || -z "${HOSTNAME}" || -z "${XRAY_PORT}" ]]; then
  echo "Missing input." >&2
  exit 1
fi

# Ensure dirs
install -d -m 0755 /etc/cloudflared

echo "[1/4] cloudflared tunnel login (opens URL)..."
# This prints a URL; user must open in browser and authorize.
cloudflared tunnel login

echo "[2/4] Create tunnel (if already exists, this may fail; that's OK)..."
set +e
cloudflared tunnel create "${TUNNEL_NAME}"
set -e

# Find newest credential file (UUID.json)
CRED_SRC=$(ls -1t /root/.cloudflared/*.json 2>/dev/null | head -n 1 || true)
if [[ -z "${CRED_SRC}" ]]; then
  # also try current user's home (if sudo from non-root)
  if [[ -n "${SUDO_USER:-}" && -d "/home/${SUDO_USER}/.cloudflared" ]]; then
    CRED_SRC=$(ls -1t "/home/${SUDO_USER}/.cloudflared"/*.json 2>/dev/null | head -n 1 || true)
  fi
fi

if [[ -z "${CRED_SRC}" ]]; then
  echo "ERROR: Cannot find tunnel credential *.json in ~/.cloudflared.\nRun: cloudflared tunnel create ${TUNNEL_NAME} (as the same user)" >&2
  exit 1
fi

CRED_DST=/etc/cloudflared/$(basename "${CRED_SRC}")
cp -f "${CRED_SRC}" "${CRED_DST}"
chmod 600 "${CRED_DST}"

echo "[3/4] Write /etc/cloudflared/config.yml"
cat > /etc/cloudflared/config.yml <<CFG
tunnel: ${TUNNEL_NAME}
credentials-file: ${CRED_DST}

ingress:
  - hostname: ${HOSTNAME}
    service: http://localhost:${XRAY_PORT}
  - service: http_status:404
CFG

echo "[4/4] Route DNS to tunnel"
cloudflared tunnel route dns "${TUNNEL_NAME}" "${HOSTNAME}"

# Install/enable service
cloudflared service install || true
systemctl enable cloudflared || true
systemctl restart cloudflared || true

systemctl status cloudflared --no-pager -l || true

echo "OK: cloudflared tunnel configured. Hostname: ${HOSTNAME}"
