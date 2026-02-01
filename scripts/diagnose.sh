#!/usr/bin/env bash
# OpenClaw Diagnostic Script for Coolify Deployments
# Run this inside your Coolify container terminal to diagnose issues

set -e

echo "=================================================="
echo "🔍 OpenClaw Diagnostic Report"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
}

check_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
}

check_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
}

echo "1. Checking OpenClaw Installation..."
echo "-----------------------------------"
if command -v openclaw >/dev/null 2>&1; then
    VERSION=$(openclaw --version 2>&1 || echo "unknown")
    check_pass "OpenClaw binary found: $VERSION"
else
    check_fail "OpenClaw binary not found in PATH"
    echo "   Expected location: /usr/local/bin/openclaw or /usr/bin/openclaw"
fi
echo ""

echo "2. Checking Configuration..."
echo "-----------------------------------"
CONFIG_FILE="/root/.openclaw/openclaw.json"
if [ -f "$CONFIG_FILE" ]; then
    check_pass "Configuration file exists: $CONFIG_FILE"

    # Check if token exists
    if grep -q '"token"' "$CONFIG_FILE"; then
        TOKEN=$(grep -o '"token": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
        check_pass "Auth token configured: ${TOKEN:0:20}..."
    else
        check_fail "No auth token found in config"
    fi
else
    check_fail "Configuration file not found: $CONFIG_FILE"
    echo "   Bootstrap may not have run successfully"
fi
echo ""

echo "3. Checking API Keys..."
echo "-----------------------------------"
API_KEYS_FOUND=0
[ -n "$OPENAI_API_KEY" ] && { check_pass "OPENAI_API_KEY is set"; API_KEYS_FOUND=1; }
[ -n "$ANTHROPIC_API_KEY" ] && { check_pass "ANTHROPIC_API_KEY is set"; API_KEYS_FOUND=1; }
[ -n "$GEMINI_API_KEY" ] && { check_pass "GEMINI_API_KEY is set"; API_KEYS_FOUND=1; }
[ -n "$MINIMAX_API_KEY" ] && { check_pass "MINIMAX_API_KEY is set"; API_KEYS_FOUND=1; }
[ -n "$KIMI_API_KEY" ] && { check_pass "KIMI_API_KEY is set"; API_KEYS_FOUND=1; }
[ -n "$OPENCODE_API_KEY" ] && { check_pass "OPENCODE_API_KEY is set"; API_KEYS_FOUND=1; }

if [ $API_KEYS_FOUND -eq 0 ]; then
    check_fail "NO API KEYS CONFIGURED! OpenClaw requires at least one."
    echo "   Set one in Coolify Environment Variables and redeploy."
else
    check_pass "At least one API key is configured"
fi
echo ""

echo "4. Checking Docker Access..."
echo "-----------------------------------"
if [ -n "$DOCKER_HOST" ]; then
    check_pass "DOCKER_HOST is set: $DOCKER_HOST"

    if docker ps >/dev/null 2>&1; then
        CONTAINER_COUNT=$(docker ps | wc -l)
        check_pass "Docker daemon accessible (found $((CONTAINER_COUNT-1)) running containers)"
    else
        check_fail "Cannot connect to Docker daemon"
        echo "   DOCKER_HOST: $DOCKER_HOST"
        echo "   Check if docker-proxy service is running"
    fi
else
    check_warn "DOCKER_HOST not set (expected: tcp://docker-proxy:2375)"
fi
echo ""

echo "5. Checking Network & Ports..."
echo "-----------------------------------"
GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
echo "   Gateway Port: $GATEWAY_PORT"

if command -v lsof >/dev/null 2>&1; then
    if lsof -i ":$GATEWAY_PORT" >/dev/null 2>&1; then
        check_pass "Port $GATEWAY_PORT is in use (OpenClaw likely running)"
    else
        check_warn "Port $GATEWAY_PORT is not in use (OpenClaw may not be running)"
    fi
fi

if [ -n "$SERVICE_FQDN_OPENCLAW" ]; then
    check_pass "Public domain configured: $SERVICE_FQDN_OPENCLAW"
else
    check_warn "No public domain configured (SERVICE_FQDN_OPENCLAW is empty)"
    echo "   You'll need to access via IP address or configure domain in Coolify"
fi
echo ""

echo "6. Checking Workspace & State..."
echo "-----------------------------------"
WORKSPACE="${OPENCLAW_WORKSPACE:-/root/openclaw-workspace}"
STATE="${OPENCLAW_STATE_DIR:-/root/.openclaw}"

[ -d "$WORKSPACE" ] && check_pass "Workspace exists: $WORKSPACE" || check_fail "Workspace missing: $WORKSPACE"
[ -d "$STATE" ] && check_pass "State directory exists: $STATE" || check_fail "State directory missing: $STATE"

if [ -f "$WORKSPACE/SOUL.md" ]; then
    check_pass "SOUL.md found in workspace"
else
    check_warn "SOUL.md not found (will be created on first run)"
fi
echo ""

echo "7. Checking System Resources..."
echo "-----------------------------------"
if command -v free >/dev/null 2>&1; then
    TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
    AVAILABLE_RAM=$(free -m | awk '/^Mem:/{print $7}')
    echo "   Total RAM: ${TOTAL_RAM}MB"
    echo "   Available RAM: ${AVAILABLE_RAM}MB"

    if [ "$TOTAL_RAM" -lt 2000 ]; then
        check_warn "Less than 2GB RAM available. OpenClaw may struggle."
    else
        check_pass "Sufficient RAM available"
    fi
fi

if command -v df >/dev/null 2>&1; then
    DISK_AVAIL=$(df -h / | awk 'NR==2 {print $4}')
    echo "   Available Disk Space: $DISK_AVAIL"
fi

ULIMIT=$(ulimit -n)
echo "   Open Files Limit (ulimit): $ULIMIT"
if [ "$ULIMIT" -lt 10000 ]; then
    check_warn "ulimit is low ($ULIMIT). Recommended: 65535"
else
    check_pass "ulimit is sufficient ($ULIMIT)"
fi
echo ""

echo "8. Checking Processes..."
echo "-----------------------------------"
if pgrep -f "openclaw" >/dev/null; then
    PID=$(pgrep -f "openclaw")
    check_pass "OpenClaw process is running (PID: $PID)"
else
    check_fail "No OpenClaw process found"
    echo "   Try running: openclaw gateway run"
fi
echo ""

echo "9. Checking Recent Logs..."
echo "-----------------------------------"
LOG_DIR="$STATE/logs"
if [ -d "$LOG_DIR" ]; then
    LATEST_LOG=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ]; then
        check_pass "Log file found: $LATEST_LOG"
        echo ""
        echo "   Last 10 lines of log:"
        echo "   ---------------------"
        tail -10 "$LATEST_LOG" | sed 's/^/   /'
    else
        check_warn "No log files found in $LOG_DIR"
    fi
else
    check_warn "Log directory not found: $LOG_DIR"
fi
echo ""

echo "=================================================="
echo "📊 Diagnostic Summary"
echo "=================================================="
echo ""

# Generate recommendations
if [ $API_KEYS_FOUND -eq 0 ]; then
    echo "🔴 CRITICAL: Add at least one API key in Coolify Environment Variables"
fi

if ! command -v openclaw >/dev/null 2>&1; then
    echo "🔴 CRITICAL: OpenClaw binary not installed. Check build logs."
fi

if ! docker ps >/dev/null 2>&1; then
    echo "🔴 CRITICAL: Cannot access Docker. Check docker-proxy service."
fi

if ! pgrep -f "openclaw" >/dev/null; then
    echo "🟡 WARNING: OpenClaw is not running. Check logs for crash reasons."
fi

echo ""
echo "=================================================="
