# OpenClaw Coolify Troubleshooting Guide

## Quick Diagnostic Checklist

### 1. Check Container Status
In Coolify, go to your OpenClaw service and check:
- ✅ Is the container **Running** (green)?
- ✅ Are all 4 services starting? (openclaw, docker-proxy, registry, searxng)
- ❌ If any service shows "Exited" or "Error", check logs immediately

### 2. Check Environment Variables (CRITICAL)
**You MUST have at least ONE API key configured:**

In Coolify → Your Service → Environment Variables, verify you have:
```bash
# At least ONE of these is REQUIRED:
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GEMINI_API_KEY=...
MINIMAX_API_KEY=...
```

**Common mistake:** Leaving all API keys empty will cause OpenClaw to fail silently.

### 3. Check Auto-Generated Secrets
Coolify auto-generates these variables. Verify they exist:
```bash
SERVICE_BASE64_REGISTRY=...
SERVICE_BASE64_SEARXNG=...
SERVICE_FQDN_OPENCLAW=your-subdomain.yourdomain.com
```

If `SERVICE_FQDN_OPENCLAW` is empty, your domain configuration is broken.

### 4. Check Logs for Bootstrap Success
In Coolify → Service → Logs, look for:
```
🦞 OpenClaw is ready!
🔑 Access Token: [some-long-token]
☁️  Service URL (Public): https://your-domain.com?token=...
```

**If you DON'T see this banner:**
- The bootstrap script failed
- Check earlier logs for errors (npm install failure, Docker socket issues, etc.)

### 5. Domain Configuration Issues
**Symptom:** Container runs but you can't access it via the domain.

**Check:**
1. Go to Coolify → Your Service → **Domains**
2. Verify your domain is properly configured
3. Make sure SSL certificate is generated (may take 1-2 minutes)
4. Try accessing `http://` first if `https://` fails

**Common Coolify Domain Issues:**
- Wrong DNS A record (must point to your Coolify server IP)
- Cloudflare proxy enabled (orange cloud) - Should be "DNS Only" (gray cloud)
- SSL cert still generating - Wait 2 minutes and refresh

### 6. Docker Socket Access (Critical for Sandboxing)
OpenClaw needs Docker access to create sandboxes. Check:

In Coolify → Your Service → Advanced → **Volumes**:
```
✅ /var/run/docker.sock is mounted (on host)
```

**This is handled by the docker-proxy service automatically** - but verify it's running:
```bash
docker ps | grep docker-proxy
```

### 7. Port Conflicts
OpenClaw uses port **18789** by default.

**Check in Coolify:**
- Go to Service → **Network**
- Verify port 18789 is exposed
- Make sure no other service is using this port

## Common Error Scenarios

### Error: "Cannot connect to Docker daemon"
**Solution:**
1. The `docker-proxy` service must be running
2. Check Coolify logs for `docker-proxy` errors
3. Verify `/var/run/docker.sock` exists on your host

### Error: "npm install -g openclaw" fails during build
**Symptoms:** Build fails at the npm install step in Dockerfile

**Solutions:**
1. Check if your Hostinger VPS has enough resources:
   - Minimum 2GB RAM recommended
   - 4GB RAM ideal
2. Try deploying during off-peak hours (npm registry issues)
3. Enable swap if RAM is limited

### Error: Container restarts repeatedly
**Check:**
1. Service → Logs → Look for crash reason
2. Common causes:
   - Missing API keys
   - Port already in use
   - Out of memory (OOM killed)
   - Docker socket not accessible

### Error: "404 Not Found" when accessing domain
**Check:**
1. Is the container actually running? (Check status)
2. Is the port correct in Coolify settings?
3. Try accessing with the token: `https://your-domain.com?token=YOUR_TOKEN`
4. Check Coolify reverse proxy logs

### Domain works but shows "Unauthorized"
**This is NORMAL on first access!**

**Solution:**
1. Access the URL (you'll see "Unauthorized" screen)
2. Open Coolify → Service → **Terminal**
3. Run: `openclaw-approve`
4. Refresh the browser

⚠️ **Security Warning:** `openclaw-approve` auto-approves ALL pairing requests. Only run it right after you access the URL yourself.

## Debug Commands (Run in Coolify Terminal)

### Check if OpenClaw binary is installed:
```bash
which openclaw
openclaw --version
```

### Check OpenClaw configuration:
```bash
cat /root/.openclaw/openclaw.json
```

### Check Docker access:
```bash
docker ps
# Should list running containers
```

### Check logs:
```bash
tail -f /root/.openclaw/logs/*.log
```

### Manual start (for debugging):
```bash
openclaw gateway run
```

## Hostinger-Specific Issues

### 1. Resource Limits
Hostinger VPS plans vary. OpenClaw + SearXNG + Registry requires:
- **Minimum:** 2GB RAM, 2 CPU cores, 20GB disk
- **Recommended:** 4GB RAM, 4 CPU cores, 40GB disk

**Check your plan:**
```bash
free -h  # Check RAM
df -h    # Check disk space
```

### 2. Firewall/Security Groups
Make sure your Hostinger firewall allows:
- Port 80 (HTTP)
- Port 443 (HTTPS)
- Port 18789 (OpenClaw - if exposing directly)

### 3. DNS Propagation
If you just added a domain:
- DNS can take 5-60 minutes to propagate
- Test with `dig your-domain.com` or `nslookup your-domain.com`

## Step-by-Step Fresh Deployment

If nothing works, try this clean deployment:

### Step 1: Clean slate in Coolify
1. Delete the existing OpenClaw service
2. Wait 30 seconds
3. Check that all containers are gone: `docker ps -a | grep openclaw`

### Step 2: Set up environment variables FIRST
Before deploying, prepare:
```bash
# Required - Pick at least one:
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# Optional but recommended:
TELEGRAM_BOT_TOKEN=...  # For Telegram integration
```

### Step 3: Deploy
1. Coolify → New → Public Repository
2. URL: `https://github.com/essamamdani/openclaw-coolify`
3. **Wait for Coolify to detect the `coolify.json`**
4. Configure environment variables in the UI
5. Set a subdomain (e.g., `openclaw.yourdomain.com`)
6. Click **Deploy**

### Step 4: Monitor the build
1. Watch the build logs for errors
2. Build takes 5-15 minutes (downloads many packages)
3. Look for: "✅ openclaw binary found"

### Step 5: First access
1. Wait for: "🦞 OpenClaw is ready!" in logs
2. Copy the URL with token
3. Access it → You'll see "Unauthorized"
4. Terminal → `openclaw-approve`
5. Refresh

## Still Not Working?

If you've tried everything above, please provide:

1. **Coolify Logs** (last 100 lines):
   - Service → Logs → Copy
2. **Container Status:**
   - Is it running or crashed?
3. **Environment Variables** (redact secrets):
   - Which API keys do you have configured?
4. **Error Messages:**
   - Any specific errors in logs?
5. **Your Setup:**
   - Hostinger VPS specs (RAM, CPU)?
   - Domain configuration (subdomain, DNS provider)?

---

## Quick Wins

### If you just want to test locally first:
Instead of Coolify, you can run locally with Docker Compose:

```bash
git clone https://github.com/essamamdani/openclaw-coolify
cd openclaw-coolify
cp .env.example .env
# Edit .env and add at least one API key
docker-compose up -d
```

Then access: `http://localhost:18789?token=[check logs for token]`

This helps determine if the issue is with Coolify or the OpenClaw setup itself.
