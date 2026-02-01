#!/bin/bash

echo "=== Test: Can Caddy reach OpenClaw on port 18789? ==="
echo ""

# Get container IP
CONTAINER_IP=$(docker inspect 35b50a6395d0 | grep '"IPAddress"' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '^$' | head -1)

echo "OpenClaw container IP: $CONTAINER_IP"
echo ""

echo "Testing from Caddy container to OpenClaw port 18789..."
docker exec coolify-proxy curl -s -o /dev/null -w "Status: %{http_code}\n" "http://$CONTAINER_IP:18789/__openclaw__/canvas/"

echo ""
echo "Testing from Caddy container to OpenClaw port 80 (what it's currently trying)..."
docker exec coolify-proxy curl -s -o /dev/null -w "Status: %{http_code}\n" "http://$CONTAINER_IP:80/" 2>&1 | head -2

