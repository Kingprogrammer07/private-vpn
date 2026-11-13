#!/bin/bash
set -e

echo "=== Pulling latest changes from Git ==="
cd /opt/private-vpn-repo
git pull origin main

echo "=== Syncing Docker Compose ==="
cp /opt/private-vpn-repo/server/docker-compose.yml /opt/private_vpn/docker-compose.yml

echo "=== Restarting Private VPN Container ==="
cd /opt/private_vpn
docker compose up -d

echo "=== Reloading Nginx ==="
nginx -t && systemctl reload nginx

echo "✅ Server successfully updated and running!"
