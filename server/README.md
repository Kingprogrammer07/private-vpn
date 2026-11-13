# Private VPN Server Infrastructure

Self-hosted VLESS Reality + XTLS-Vision VPN backend using 3X-UI on Ubuntu / Debian.

## Server Parameters Example
- **Domain:** `vpn.yourdomain.com` (for SSL Admin Panel)
- **Server IP:** `<YOUR_SERVER_IP>`
- **Port:** `8443` (VLESS Reality inbound)
- **Web UI:** `https://vpn.yourdomain.com` (Reverse proxied via Nginx to 127.0.0.1:2053)
- **SNI Target:** `gateway.icloud.com` (or `www.microsoft.com`, `www.yahoo.com`)

## Directory Structure on Server
```bash
/opt/private_vpn/
├── docker-compose.yml
├── db/
└── cert/
```

## Quick Commands on Server
```bash
# Check status
docker ps | grep private_vpn

# Restart 3X-UI service
docker restart private_vpn

# View logs
docker logs private_vpn --tail 50
```
