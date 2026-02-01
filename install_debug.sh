#!/bin/bash

echo "=== Deep Dive: Why OpenClaw Can't Be Reached ==="
echo ""

echo "1. Check what OpenClaw is actually binding to inside container:"
CONTAINER_ID=$(docker ps | grep openclaw | grep -v proxy | head -1 | awk '{print $1}')
if [ -n "$CONTAINER_ID" ]; then
  echo "Container ID: $CONTAINER_ID"
  echo ""
  echo "Processes listening inside container:"
  docker exec "$CONTAINER_ID" sh -c "netstat -tlnp 2>/dev/null || ss -tlnp" | grep -E ':18789|LISTEN'
  echo ""
  echo "Environment variables:"
  docker exec "$CONTAINER_ID" sh -c "env | grep -E 'PORT|BIND|BASE_URL|PUBLIC_URL'"
else
  echo "  ❌ No OpenClaw container found"
fi
echo ""

echo "2. Check Caddy configuration for OpenClaw:"
CADDY_CONTAINER=$(docker ps | grep caddy | awk '{print $1}')
if [ -n "$CADDY_CONTAINER" ]; then
  echo "Caddy container: $CADDY_CONTAINER"
  echo ""
  echo "Current Caddy config (looking for test.mysticservices.win):"
  docker exec "$CADDY_CONTAINER" sh -c "cat /config/caddy/autosave.json 2>/dev/null | jq . | grep -A10 -B2 mysticservices" || echo "  Checking alternative location..."
  docker exec "$CADDY_CONTAINER" sh -c "cat /data/caddy/autosave.json 2>/dev/null | jq . | grep -A10 -B2 mysticservices" || echo "  No config found"
  echo ""
  echo "Caddy logs (last 20 lines):"
  docker logs "$CADDY_CONTAINER" 2>&1 | tail -20
else
  echo "  ❌ No Caddy container found"
fi
echo ""

echo "3. Check if container is actually exposing port 18789:"
docker port "$CONTAINER_ID" 2>/dev/null || echo "  No port mappings found"
echo ""

echo "4. Try to reach OpenClaw from different contexts:"
echo "  From host to localhost:18789:"
curl -s -o /dev/null -w "    Status: %{http_code}\n" http://localhost:18789/__openclaw__/canvas/ 2>/dev/null || echo "    ❌ Failed"
echo ""
if [ -n "$CONTAINER_ID" ]; then
  echo "  From host to container IP directly:"
  CONTAINER_IP=$(docker inspect "$CONTAINER_ID" | grep -m1 '"IPAddress"' | cut -d'"' -f4)
  echo "    Container IP: $CONTAINER_IP"
  curl -s -o /dev/null -w "    Status: %{http_code}\n" "http://$CONTAINER_IP:18789/__openclaw__/canvas/" 2>/dev/null || echo "    ❌ Failed"
  echo ""
  echo "  From inside container to itself:"
  docker exec "$CONTAINER_ID" sh -c "curl -s -o /dev/null -w 'Status: %{http_code}\n' http://localhost:18789/__openclaw__/canvas/" 2>/dev/null || echo "    ❌ Failed"
fi
echo ""

echo "5. Check networks container is connected to:"
if [ -n "$CONTAINER_ID" ]; then
  docker inspect "$CONTAINER_ID" | grep -A30 '"Networks"'
fi
echo ""

echo "6. Check Coolify-specific labels:"
if [ -n "$CONTAINER_ID" ]; then
  echo "Container labels:"
  docker inspect "$CONTAINER_ID" | grep -A50 '"Labels"' | head -60
fi
echo ""

echo "=== DIAGNOSIS ==="
echo ""
if [ -n "$CONTAINER_ID" ] && docker exec "$CONTAINER_ID" sh -c "curl -s http://localhost:18789/__openclaw__/canvas/" >/dev/null 2>&1; then
  echo "✅ OpenClaw IS running and responding inside container"
  echo "❌ But external access is blocked - this is a networking/proxy issue"
else
  echo "❌ OpenClaw is NOT responding even inside its own container"
  echo "   This means OpenClaw itself isn't starting properly or binding correctly"
fi
