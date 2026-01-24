# Option 4: Cloudflared Tunnel (Ingress) + Cloudflare WARP (Egress) untuk Xray

## Apa yang setup ini buat
- **Ingress (masuk)**: Client → Cloudflare Edge → **cloudflared tunnel** → Xray (localhost)
- **Egress (keluar)**: Xray → **Cloudflare WARP** → Internet

**Result**: Bila client connect dan anda check IP (contoh `speedtest.net` atau `ifconfig.me`), IP akan tunjuk **Cloudflare/WARP**.

## File dalam folder ini
- `scripts/01_install_cloudflared.sh` – install cloudflared
- `scripts/02_setup_cloudflared_tunnel.sh` – create config tunnel + route DNS
- `scripts/03_install_warp.sh` – install & connect WARP (mode proxy)
- `scripts/04_apply_xray_warp_egress.sh` – jadikan outbound Xray pergi ke WARP proxy
- `templates/xray_vless_ws_warp_outbound.json` – contoh config Xray minimal (kalau anda nak guna config sendiri)
- `templates/cloudflared_config.yml` – contoh config cloudflared

## Prasyarat
- VPS Ubuntu (20.04/22.04 recommended)
- Domain anda sudah berada dalam Cloudflare (Zone OK)
- Anda ada akses root/sudo

## Cara guna (paling senang)
1) Masuk VPS dan masuk folder ini

```bash
cd Xray-main-patched/cloudflare_tunnel_warp
```

2) Install cloudflared
```bash
sudo bash scripts/01_install_cloudflared.sh
```

3) Setup tunnel (akan minta input: tunnel name, hostname, port local Xray)
```bash
sudo bash scripts/02_setup_cloudflared_tunnel.sh
```

4) Install & connect WARP
```bash
sudo bash scripts/03_install_warp.sh
```

5) Apply WARP egress untuk Xray (akan backup config lama)
```bash
sudo bash scripts/04_apply_xray_warp_egress.sh
```

6) Restart services
```bash
sudo systemctl restart xray || true
sudo systemctl restart cloudflared || true
```

## Verify
- Pada VPS:
```bash
curl -s ifconfig.me; echo
warp-cli status
```
- Pada client (lepas connect Xray): buka `ifconfig.me` / speedtest → IP Cloudflare/WARP.
