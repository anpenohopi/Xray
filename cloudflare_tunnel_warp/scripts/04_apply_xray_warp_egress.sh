#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0" >&2
  exit 1
fi

CONFIG=""
for p in /etc/xray/config.json /usr/local/etc/xray/config.json; do
  if [[ -f "$p" ]]; then CONFIG="$p"; break; fi
done

if [[ -z "$CONFIG" ]]; then
  echo "ERROR: Cannot find Xray config.json in /etc/xray or /usr/local/etc/xray" >&2
  exit 1
fi

echo "Using Xray config: $CONFIG"

if ! command -v jq >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y jq
fi

TS=$(date +%Y%m%d_%H%M%S)
cp -f "$CONFIG" "${CONFIG}.bak_${TS}"
echo "Backup created: ${CONFIG}.bak_${TS}"

TMP=$(mktemp)

jq '
  # Ensure arrays exist
  .outbounds = (.outbounds // []) |
  .routing = (.routing // {}) |
  .routing.rules = (.routing.rules // []) |

  # Remove existing warp outbound if any
  .outbounds = ([.outbounds[] | select(.tag != "warp")] ) |

  # Prepend WARP SOCKS outbound
  .outbounds = ([{
      "tag": "warp",
      "protocol": "socks",
      "settings": {"servers": [{"address": "127.0.0.1", "port": 40000}]}
    }] + .outbounds) |

  # Prepend routing rule to send ALL tcp/udp to warp
  .routing.rules = ([{
      "type": "field",
      "network": "tcp,udp",
      "outboundTag": "warp"
    }] + .routing.rules)
' "$CONFIG" > "$TMP"

# Sanity check: file not empty
if [[ ! -s "$TMP" ]]; then
  echo "ERROR: Generated config is empty. Restore from backup." >&2
  rm -f "$TMP"
  exit 1
fi

mv -f "$TMP" "$CONFIG"
chmod 644 "$CONFIG" || true

echo "OK: Xray config updated to use WARP egress (via 127.0.0.1:40000)"
echo "Restart Xray: sudo systemctl restart xray"
