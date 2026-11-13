# Private VPN Server Infrastructure

Self-hosted VLESS Reality + XTLS-Vision VPN backend using 3X-UI on Ubuntu.

## Server Details
- **Domain:** `vpn.softhub.uz`
- **Server IP:** `178.238.228.77`
- **Port:** `8443` (VLESS Reality)
- **Web UI:** `https://vpn.softhub.uz` (Proxying 127.0.0.1:2053)
- **SNI Target:** `gateway.icloud.com`

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
