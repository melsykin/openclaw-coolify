#!/bin/bash

echo "=== Quick Fix: Connect OpenClaw to Coolify Network ==="
echo ""

# Get the OpenClaw container ID
CONTAINER_ID=$(docker ps | grep openclaw | grep -v proxy | head -1 | awk '{print $1}')

if [ -z "$CONTAINER_ID" ]; then
  echo "❌ No OpenClaw container found"
  exit 1
fi

echo "OpenClaw container: $CONTAINER_ID"
echo ""

# Get the coolify network ID
COOLIFY_NETWORK=$(docker network ls | grep coolify | awk '{print $1}')

if [ -z "$COOLIFY_NETWORK" ]; then
  echo "❌ No coolify network found"
  exit 1
fi

echo "Coolify network: $COOLIFY_NETWORK"
echo ""

# Check if already connected
ALREADY_CONNECTED=$(docker inspect "$CONTAINER_ID" | grep -c "$COOLIFY_NETWORK")

if [ "$ALREADY_CONNECTED" -gt 0 ]; then
  echo "✅ Container is already connected to coolify network"
else
  echo "Connecting container to coolify network..."
  docker network connect "$COOLIFY_NETWORK" "$CONTAINER_ID"
  
  if [ $? -eq 0 ]; then
    echo "✅ Successfully connected!"
  else
    echo "❌ Failed to connect"
    exit 1
  fi
fi

echo ""
echo "Waiting 5 seconds for Caddy to detect the change..."
sleep 5
echo ""

echo "Testing access..."
curl -I https://test.mysticservices.win 2>&1 | head -5

echo ""
echo "=== Check Caddy logs for errors ==="
docker logs coolify-proxy 2>&1 | tail -10
