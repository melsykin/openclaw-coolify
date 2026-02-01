# OpenClaw 502 Bad Gateway - Root Cause & Fix

## The Problem

Your logs show OpenClaw is running perfectly:
```
🦞 OpenClaw is ready!
🔑 Access Token: 73c0d388bdc621834ccbdd8687b184370422a1412d7010d6
[gateway] listening on ws://0.0.0.0:18789
```

But you get **502 Bad Gateway** when accessing `https://test.mysticservices.win?token=...`

## Root Cause

The original `docker-compose.yaml` was missing:
1. **Port exposure** - The `ports:` section wasn't defined, so Coolify's proxy couldn't reach the container
2. **Network configuration** - The container wasn't on Coolify's proxy network
3. **Service labels** - No Traefik labels to tell Coolify how to route traffic

## What I Fixed

### 1. Added Port Exposure
```yaml
ports:
  - "18789:18789"
```

### 2. Added Traefik Labels for Coolify
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.openclaw.rule=Host(`${SERVICE_FQDN_OPENCLAW}`)"
  - "traefik.http.services.openclaw.loadbalancer.server.port=18789"
  # Plus WebSocket support headers
```

### 3. Added Coolify Network
```yaml
networks:
  - coolify
  - default
```

### 4. Added Health Check
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:18789/__openclaw__/canvas/"]
  interval: 30s
  start_period: 60s
```

### 5. Removed Conflicting Settings
Removed `SERVICE_URL_OPENCLAW_18789: null` which was disabling Coolify's auto URL generation.

## How to Deploy the Fixed Version

### Option 1: Push Changes to Your Fork

1. Commit these changes to your forked repository
2. In Coolify, delete the old OpenClaw service
3. Redeploy from your updated repository
4. Wait for build to complete
5. Access via your domain

### Option 2: Redeploy with Updated Settings

If you don't want to update the repo:

1. In Coolify, go to your OpenClaw service
2. Go to **Advanced** → **Docker Compose**
3. You may be able to edit the docker-compose directly there
4. Add the port and network configuration
5. Redeploy

### Option 3: Manual Coolify Configuration

If the labels don't work (Coolify versions vary):

1. In Coolify → Your Service → **Domains**
2. Make sure the domain is configured: `test.mysticservices.win`
3. Go to **Advanced** settings
4. Look for "Container Port" or "Internal Port" - set it to `18789`
5. Look for "Service" or "Container" - select `openclaw`
6. Save and redeploy

## Alternative: Cloudflare Tunnel (Bypass Coolify Proxy)

If domain routing continues to fail, use Cloudflare Tunnel instead:

1. Create a Cloudflare Tunnel: https://dash.cloudflare.com → Zero Trust → Access → Tunnels
2. Get your tunnel token
3. In Coolify, add environment variable: `CF_TUNNEL_TOKEN=your-token`
4. Redeploy
5. The bootstrap script will automatically set up the tunnel
6. Access via the Cloudflare-provided URL

This bypasses Coolify's reverse proxy entirely and gives you a secure public URL.

## Verifying the Fix

After redeploying with the fixed config:

### Check 1: Container is on Coolify Network
```bash
# In Coolify terminal:
docker network inspect coolify | grep -A5 openclaw
```

### Check 2: Port is Exposed
```bash
docker ps | grep openclaw
# Should show "0.0.0.0:18789->18789/tcp"
```

### Check 3: Health Check Passing
```bash
curl -f http://localhost:18789/__openclaw__/canvas/
# Should return HTML (the canvas UI)
```

### Check 4: Logs Show Readiness
```bash
# Look for:
[gateway] listening on ws://0.0.0.0:18789
```

## If It's Still 502

If you still get 502 after deploying the fixed version:

### 1. Check Coolify's Reverse Proxy

Coolify uses either Traefik or Caddy. Check which one:
```bash
docker ps | grep -E "traefik|caddy"
```

Check proxy logs for errors:
```bash
docker logs <traefik-container-name> 2>&1 | tail -50
# or
docker logs <caddy-container-name> 2>&1 | tail -50
```

### 2. Check Network Name

The fix assumes Coolify's network is called `coolify`. It might be different:
```bash
docker network ls | grep -i coolify
```

If it's named differently (e.g., `coolify-infra`), update docker-compose.yaml:
```yaml
networks:
  coolify-infra:  # Use actual network name
    external: true
```

### 3. Try Without External Network

If the `coolify` network doesn't exist, the deployment will fail. Try removing the network section:

Edit docker-compose.yaml and remove:
```yaml
networks:
  coolify:
    external: true
```

And from the openclaw service, remove:
```yaml
    networks:
      - coolify
      - default
```

Then redeploy and configure routing in Coolify's UI instead.

### 4. Check Your Hostinger Setup

You mentioned trying multiple methods. There might be residual configuration:

```bash
# Check for conflicting Caddy configs
cat /etc/caddy/Caddyfile 2>/dev/null

# Check for conflicting Nginx configs
ls /etc/nginx/sites-enabled/ 2>/dev/null

# Check what's listening on port 443/80
ss -tlnp | grep -E ':80|:443'
```

If there's a manual Caddy/Nginx config from your previous attempts, it might be conflicting with Coolify's proxy.

## Summary of Changes

| File | Change | Purpose |
|------|--------|---------|
| docker-compose.yaml | Added `ports: - "18789:18789"` | Expose port to Coolify |
| docker-compose.yaml | Added Traefik labels | Route traffic correctly |
| docker-compose.yaml | Added `networks: coolify` | Join Coolify's proxy network |
| docker-compose.yaml | Added healthcheck | Let Coolify know when ready |
| docker-compose.yaml | Removed `SERVICE_URL_*: null` | Enable Coolify auto-routing |
| coolify.json | Updated version, added proxyService | Tell Coolify which service to proxy |

## Next Steps

1. **Push the changes** to your GitHub fork
2. **Delete** the existing Coolify service (clean slate)
3. **Redeploy** from your updated repository
4. **Check logs** for "OpenClaw is ready"
5. **Access** `https://test.mysticservices.win?token=YOUR_TOKEN`
6. **If it works**: Run `openclaw-approve` in terminal, then refresh

If still failing, try the Cloudflare Tunnel option as a reliable alternative.
