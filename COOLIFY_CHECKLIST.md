# Coolify Deployment Checklist

Use this checklist to verify your OpenClaw deployment on Coolify is configured correctly.

## Pre-Deployment

### ☑️ Hostinger VPS Setup
- [ ] Hostinger VPS is running
- [ ] SSH access works
- [ ] At least 2GB RAM available
- [ ] At least 20GB disk space available
- [ ] Docker is installed
- [ ] Coolify is installed and accessible

### ☑️ DNS Configuration (if using custom domain)
- [ ] Domain purchased/registered
- [ ] A record created pointing to VPS IP
- [ ] DNS propagation complete (test with `nslookup your-domain.com`)
- [ ] If using Cloudflare: Proxy is DISABLED (gray cloud, not orange)

### ☑️ API Keys Ready
- [ ] At least ONE API key obtained:
  - [ ] OpenAI API key (https://platform.openai.com/api-keys)
  - [ ] OR Anthropic API key (https://console.anthropic.com/account/keys)
  - [ ] OR Gemini API key (https://aistudio.google.com/app/apikey)
  - [ ] OR MiniMax API key

## During Deployment in Coolify

### ☑️ Repository Configuration
- [ ] Added new resource in Coolify
- [ ] Selected "Public Repository"
- [ ] Repository URL: `https://github.com/YOUR-USERNAME/openclaw-coolify`
- [ ] Branch: `main`
- [ ] Coolify detected `coolify.json` (should show "Docker Compose" type)

### ☑️ Environment Variables (CRITICAL)
- [ ] Opened "Environment Variables" tab BEFORE deploying
- [ ] Added at least ONE API key:
  ```
  Variable: OPENAI_API_KEY
  Value: sk-proj-...
  ```
- [ ] (Optional) Added Telegram bot token if using Telegram
- [ ] (Optional) Added Cloudflare tunnel token if needed
- [ ] Clicked **Save**

### ☑️ Domain Configuration
- [ ] Went to "Domains" tab
- [ ] Added custom domain (e.g., `openclaw.yourdomain.com`)
  - OR using Coolify's auto-generated URL
- [ ] SSL certificate generation enabled (usually auto)
- [ ] Port 18789 is exposed (should be automatic)

### ☑️ Deployment
- [ ] Clicked "Deploy" button
- [ ] Build started successfully
- [ ] Waited for build to complete (5-15 minutes)

## Post-Deployment Verification

### ☑️ Build Success
- [ ] Build logs show: "✅ openclaw binary found"
- [ ] Build completed without errors
- [ ] All 4 services should be defined:
  - [ ] openclaw
  - [ ] docker-proxy
  - [ ] searxng
  - [ ] registry

### ☑️ Runtime Success
Go to "Logs" tab and verify:
- [ ] See: "🦞 OpenClaw is ready!"
- [ ] See: "🔑 Access Token: ..."
- [ ] See: "☁️ Service URL (Public): https://..."
- [ ] No continuous errors/crashes
- [ ] Container stays running (not restarting)

### ☑️ Access & Authorization
- [ ] Copied the URL with token from logs
- [ ] Opened URL in browser
- [ ] Saw "Unauthorized" or pairing screen (this is normal!)
- [ ] Went to Coolify → Execute Command tab
- [ ] Ran: `openclaw-approve`
- [ ] Refreshed browser
- [ ] Now see OpenClaw dashboard!

### ☑️ Health Checks
In Coolify terminal, run diagnostic:
```bash
/app/scripts/diagnose.sh
```

- [ ] OpenClaw binary: ✅ PASS
- [ ] Configuration file: ✅ PASS
- [ ] At least one API key: ✅ PASS
- [ ] Docker access: ✅ PASS
- [ ] OpenClaw process running: ✅ PASS

### ☑️ Functional Tests
Once in dashboard:
- [ ] Dashboard loads properly
- [ ] Can see system status
- [ ] Gateway shows as "Online"
- [ ] Can navigate to different tabs

### ☑️ Optional: Channel Setup
If setting up Telegram:
- [ ] Created bot with @BotFather
- [ ] Added `TELEGRAM_BOT_TOKEN` to environment variables
- [ ] Redeployed service
- [ ] Messaged the bot
- [ ] Bot responded with pairing request
- [ ] Approved pairing in dashboard
- [ ] Can chat with bot

If setting up WhatsApp:
- [ ] Opened Dashboard → Channels → WhatsApp
- [ ] QR code appeared
- [ ] Scanned with WhatsApp (Linked Devices)
- [ ] Connection successful
- [ ] Can send messages to yourself

## Troubleshooting Checklist

If deployment failed, check:

### ❌ Build Failures
- [ ] Checked build logs for specific error
- [ ] Error is npm-related → Retry deployment
- [ ] Error is OOM (out of memory) → Upgrade VPS RAM
- [ ] Error is disk space → Clean up VPS or upgrade

### ❌ Container Crashes/Restarts
- [ ] Checked runtime logs for error messages
- [ ] Verified API key is actually set
- [ ] Checked VPS has enough RAM (`free -h`)
- [ ] Checked Docker socket is accessible
- [ ] Verified docker-proxy service is running

### ❌ Can't Access Domain
- [ ] DNS A record is correct
- [ ] DNS has propagated (wait 5-10 minutes, then test)
- [ ] SSL certificate generated (check Domains tab)
- [ ] Cloudflare proxy is disabled
- [ ] Tried accessing with token: `https://domain.com?token=...`
- [ ] Tried HTTP instead of HTTPS temporarily
- [ ] Checked Coolify reverse proxy logs

### ❌ API Keys Not Working
- [ ] Copied API key correctly (no extra spaces)
- [ ] API key is valid (test with curl or provider's playground)
- [ ] Variable name is exactly: `OPENAI_API_KEY` (not `OPENAI_KEY`)
- [ ] Redeployed after adding/changing API key
- [ ] API key has sufficient credits/quota

### ❌ "Unauthorized" Won't Go Away
- [ ] Ran `openclaw-approve` in the SERVICE terminal (not local)
- [ ] Waited 5 seconds after running command
- [ ] Hard refreshed browser (Ctrl+F5 or Cmd+Shift+R)
- [ ] Cleared browser cache and cookies
- [ ] Tried different browser
- [ ] Checked token in URL matches token in logs

## Emergency Recovery

If everything seems broken:

### Option 1: Fresh Deploy
- [ ] Delete service in Coolify
- [ ] Wait 30 seconds
- [ ] Verify containers are gone: `docker ps | grep openclaw`
- [ ] Deploy again from scratch
- [ ] Make sure to add API keys BEFORE clicking Deploy

### Option 2: Local Testing
- [ ] Clone repository locally
- [ ] Create `.env` file with API keys
- [ ] Run: `docker-compose up -d`
- [ ] Check if it works locally
- [ ] If yes: Issue is with Coolify config
- [ ] If no: Issue is with OpenClaw setup or API keys

### Option 3: Manual Debugging
SSH into Hostinger VPS:
```bash
# Check Docker containers
docker ps -a | grep openclaw

# Check logs
docker logs openclaw-openclaw-1

# Check resources
free -h
df -h

# Check Docker socket
ls -la /var/run/docker.sock
```

## Success Criteria

You know it's working when:
- ✅ Container is running (green status in Coolify)
- ✅ Logs show "🦞 OpenClaw is ready!"
- ✅ Can access dashboard via domain
- ✅ After `openclaw-approve`, dashboard is fully accessible
- ✅ Can navigate all tabs (Gateway, Channels, Pairing, etc.)
- ✅ System status shows "Online"
- ✅ No errors in logs

## Getting Help

If after going through this entire checklist you're still stuck:

1. **Run the diagnostic script:**
   ```bash
   /app/scripts/diagnose.sh > /tmp/report.txt
   cat /tmp/report.txt
   ```

2. **Gather information:**
   - [ ] Screenshot of Coolify service status
   - [ ] Last 100 lines of build logs
   - [ ] Last 100 lines of runtime logs
   - [ ] Output of diagnostic script
   - [ ] Your VPS specs (RAM, CPU, disk)
   - [ ] Which API key provider you're using

3. **Read detailed guides:**
   - [ ] Read DIAGNOSIS.md (most likely issues)
   - [ ] Read TROUBLESHOOTING.md (detailed solutions)
   - [ ] Read QUICK_START.md (step-by-step guide)

4. **Test locally first:**
   - Sometimes it helps to test with Docker Compose locally
   - This isolates whether it's a Coolify issue or OpenClaw issue

---

**Remember:** The #1 most common issue is **missing API keys**. Double-check this first! ⚡
