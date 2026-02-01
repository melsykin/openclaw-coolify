#!/bin/bash

echo "=== Coolify Network Diagnostic ==="
echo ""

echo "1. Checking for Coolify proxy (Caddy):"
docker ps | grep -i caddy || echo "  ❌ No Caddy container found"
echo ""

echo "2. Checking for Coolify networks:"
docker network ls | grep -i coolify
echo ""

echo "3. Checking what network your current OpenClaw is on:"
docker ps | grep openclaw | awk '{print $NF}' | while read container; do
  echo "  Container: $container"
  docker inspect "$container" 2>/dev/null | grep -A5 '"Networks"' | head -10
done
echo ""

echo "4. Checking what's listening on ports 80/443:"
ss -tlnp | grep -E ':80|:443'
echo ""

echo "5. Checking if there are any manual reverse proxy configs:"
echo "  Caddy config:"
ls -la /etc/caddy/Caddyfile 2>/dev/null || echo "    None found"
echo "  Nginx config:"
ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "    None found"
echo ""

echo "6. Testing if OpenClaw port is accessible locally:"
curl -s -o /dev/null -w "  HTTP Status: %{http_code}\n" http://localhost:18789/__openclaw__/canvas/ || echo "  ❌ Cannot reach OpenClaw on localhost:18789"
echo ""

echo "=== Recommended Actions ==="
echo ""
echo "Based on the output above:"
echo "- If you see 'coolify-proxy' or similar network, note its exact name"
echo "- If Caddy container exists, check its logs: docker logs <caddy-container-name>"
echo "- If no Coolify network found, we need to configure differently"
