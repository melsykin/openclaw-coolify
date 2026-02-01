#!/usr/bin/env bash
set -e

OPENCLAW_STATE="/root/.openclaw"
CONFIG_FILE="$OPENCLAW_STATE/openclaw.json"
WORKSPACE_DIR="/root/openclaw-workspace"

# Create directories
mkdir -p "$OPENCLAW_STATE" "$WORKSPACE_DIR"
chmod 700 "$OPENCLAW_STATE"

mkdir -p "$OPENCLAW_STATE/credentials"
mkdir -p "$OPENCLAW_STATE/agents/main/sessions"
chmod 700 "$OPENCLAW_STATE/credentials"

# Seed workspace
if [ ! -f "$WORKSPACE_DIR/SOUL.md" ]; then
    if [ -f "./SOUL.md" ]; then
        echo "✨ Copying SOUL.md to workspace"
        cp "./SOUL.md" "$WORKSPACE_DIR/SOUL.md"
    fi
fi

if [ ! -f "$WORKSPACE_DIR/BOOTSTRAP.md" ]; then
    if [ -f "./BOOTSTRAP.md" ]; then
        echo "🚀 Copying BOOTSTRAP.md to workspace"
        cp "./BOOTSTRAP.md" "$WORKSPACE_DIR/BOOTSTRAP.md"
    fi
fi

# Generate config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "🏥 Generating openclaw.json..."
    TOKEN=$(openssl rand -hex 24)
    cat >"$CONFIG_FILE" <<EOF
{
  "commands": {
    "native": true,
    "nativeSkills": true,
    "text": true,
    "bash": true,
    "config": true,
    "debug": true,
    "restart": true,
    "useAccessGroups": true
  },
  "gateway": {
    "port": ${OPENCLAW_GATEWAY_PORT:-18789},
    "mode": "local",
    "bind": "lan",
    "controlUi": {
      "enabled": true,
      "allowInsecureAuth": false
    },
    "trustedProxies": ["*"],
    "auth": {
      "mode": "token",
      "token": "$TOKEN"
    }
  },
  "agents": {
    "defaults": {
      "workspace": "$WORKSPACE_DIR",
      "maxConcurrent": 2
    },
    "list": [
      {
        "id": "main",
        "default": true,
        "name": "default",
        "workspace": "/root/openclaw-workspace"
      }
    ]
  }
}
EOF
fi

# Export state
export OPENCLAW_STATE_DIR="$OPENCLAW_STATE"

# Extract token
if [ -f "$CONFIG_FILE" ]; then
    TOKEN=$(grep -o '"token": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
fi

# Set ulimit
ulimit -n 65535

# Display access info
echo ""
echo "=================================================================="
echo "🦞 OpenClaw is ready!"
echo "=================================================================="
echo ""
echo "🔑 Access Token: $TOKEN"
echo ""
echo "🌍 Local: http://localhost:${OPENCLAW_GATEWAY_PORT:-18789}?token=$TOKEN"
if [ -n "$SERVICE_FQDN_OPENCLAW" ]; then
    echo "☁️  Public: https://${SERVICE_FQDN_OPENCLAW}?token=$TOKEN"
fi
echo ""
echo "=================================================================="

# Start OpenClaw
exec openclaw gateway run
