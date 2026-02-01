# OpenClaw on Coolify - Quick Start Guide

## Prerequisites Checklist
Before deploying, make sure you have:

- [ ] Coolify installed and running on your Hostinger VPS
- [ ] At least one AI provider API key (OpenAI, Anthropic, Gemini, or MiniMax)
- [ ] A domain or subdomain pointing to your Coolify server
- [ ] At least 2GB RAM available on your VPS

## Step-by-Step Deployment

### 1. Prepare Your API Keys
You need **at least one** of these:

| Provider | Where to Get | Example Format |
|----------|-------------|----------------|
| OpenAI | https://platform.openai.com/api-keys | `sk-proj-...` |
| Anthropic (Claude) | https://console.anthropic.com/account/keys | `sk-ant-...` |
| Google Gemini | https://aistudio.google.com/app/apikey | `AIza...` |
| MiniMax | https://platform.minimaxi.com | Various formats |

### 2. Deploy on Coolify

#### Option A: Deploy from this repository
1. In Coolify Dashboard, click **+ Add** → **New Resource**
2. Select **Public Repository**
3. Repository URL: `https://github.com/YOUR-USERNAME/openclaw-coolify`
   (Replace with your forked repository URL)
4. Branch: `main`
5. Click **Continue**
6. Coolify will auto-detect `coolify.json`

#### Option B: Deploy from original repository
1. Use: `https://github.com/essamamdani/openclaw-coolify`
2. Follow same steps as Option A

### 3. Configure Environment Variables

**Before deploying**, go to the **Environment Variables** section:

#### Required Variables (Add at least ONE API key):
```bash
# Pick one or more:
OPENAI_API_KEY=sk-proj-your-key-here
# OR
ANTHROPIC_API_KEY=sk-ant-your-key-here
# OR
GEMINI_API_KEY=your-key-here
# OR
MINIMAX_API_KEY=your-key-here
```

#### Optional but Recommended:
```bash
# For Telegram bot integration:
TELEGRAM_BOT_TOKEN=your-bot-token

# For Cloudflare Tunnel (public access without domain):
CF_TUNNEL_TOKEN=your-tunnel-token
```

⚠️ **Important:** If you don't add at least one API key, OpenClaw will fail to start properly.

### 4. Configure Domain

In Coolify:
1. Go to your service → **Domains**
2. Add your domain/subdomain, e.g., `openclaw.yourdomain.com`
3. Make sure your DNS A record points to your Coolify server IP
4. Wait for SSL certificate to generate (1-2 minutes)

**DNS Configuration Example:**
```
Type: A
Name: openclaw (or @ for root domain)
Value: YOUR_VPS_IP_ADDRESS
TTL: 300
Proxy: Disabled (gray cloud if using Cloudflare)
```

### 5. Deploy

1. Click **Deploy** (or **Save** if you edited environment variables)
2. Monitor the **Build Logs**
3. Build takes 5-15 minutes (downloads Node.js, Docker, Go, and many packages)
4. Wait for: **"Build Successful"**

### 6. Check Deployment

Once deployed, go to **Service Logs** and look for:

```
==================================================================
🦞 OpenClaw is ready!
==================================================================

🔑 Access Token: abc123xyz...

🌍 Service URL (Local): http://localhost:18789?token=abc123xyz...
☁️  Service URL (Public): https://openclaw.yourdomain.com?token=abc123xyz...
```

**If you DON'T see this:**
- Check the logs for errors
- Run the diagnostic script (see section below)

### 7. First Access

1. **Copy the Public URL** with token from the logs
2. **Open it in your browser**
3. You'll see an **"Unauthorized"** screen (this is normal!)
4. Go back to Coolify → Your Service → **Execute Command**
5. Run: `openclaw-approve`
6. **Refresh your browser** - you should now see the OpenClaw dashboard!

⚠️ **Security Note:** Only run `openclaw-approve` right after you access the URL yourself. It approves ALL pending pairing requests.

### 8. Initial Configuration

Once you're in the dashboard:

#### A. Run the Onboarding Wizard
In Coolify → Execute Command:
```bash
openclaw onboard
```

Follow the interactive setup to configure:
- Agent personality
- Default model
- Skills and capabilities

#### B. Connect Chat Channels (Optional)

**Telegram (Easiest):**
1. Message [@BotFather](https://t.me/botfather) on Telegram
2. Create a bot: `/newbot`
3. Copy the token
4. Add to Coolify Environment Variables: `TELEGRAM_BOT_TOKEN=your-token`
5. Redeploy
6. Message your bot → It'll ask for pairing → Approve in dashboard

**WhatsApp:**
1. Go to OpenClaw Dashboard → **Channels** → **WhatsApp**
2. Scan QR code with WhatsApp (Linked Devices)
3. Done!

## Troubleshooting

### Container won't start
```bash
# In Coolify Terminal:
./scripts/diagnose.sh
```

This will check:
- OpenClaw installation
- API keys
- Docker access
- Network configuration
- System resources

### Build fails
**Common causes:**
1. **Insufficient RAM** - Need at least 2GB
2. **npm registry timeout** - Retry deployment
3. **Docker socket access** - Check Coolify permissions

**Solution:**
- Check Hostinger VPS resources
- Try deploying again (npm can be flaky)

### Domain not working
**Checklist:**
- [ ] DNS A record points to correct IP
- [ ] SSL certificate generated (check Domains tab)
- [ ] Cloudflare proxy disabled (if using Cloudflare DNS)
- [ ] Wait 5 minutes for DNS propagation

**Test DNS:**
```bash
dig openclaw.yourdomain.com
# or
nslookup openclaw.yourdomain.com
```

### "Unauthorized" doesn't go away after openclaw-approve
**Solution:**
1. Make sure you ran `openclaw-approve` in the **Service Terminal** (not your local machine)
2. Wait 5 seconds
3. Hard refresh browser (Ctrl+F5 or Cmd+Shift+R)
4. Clear browser cache if still not working

### Can't connect to Docker
**Solution:**
1. Check if `docker-proxy` service is running:
   ```bash
   docker ps | grep docker-proxy
   ```
2. If not running, redeploy the entire stack
3. Make sure `/var/run/docker.sock` exists on host

## Performance Tuning

### Hostinger VPS Requirements

| Tier | RAM | CPU | Disk | Recommendation |
|------|-----|-----|------|----------------|
| Minimum | 2GB | 2 cores | 20GB | Basic use, 1-2 users |
| Recommended | 4GB | 4 cores | 40GB | Production, multiple users |
| Optimal | 8GB | 8 cores | 80GB | Heavy use, many sandboxes |

### If Running Slow
1. **Enable swap** (if low RAM):
   ```bash
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

2. **Disable unused services** in docker-compose.yaml:
   - Comment out `registry` if not deploying to your own registry
   - Comment out `searxng` if not using web search

3. **Reduce concurrent sandboxes**:
   - Edit `openclaw.json` (after first run)
   - Set `maxConcurrent: 2` instead of 4

## Advanced: Local Testing (Without Coolify)

If you want to test locally first:

```bash
# Clone the repo
git clone https://github.com/essamamdani/openclaw-coolify
cd openclaw-coolify

# Configure environment
cp .env.example .env
nano .env  # Add your API keys

# Generate required secrets
export SERVICE_BASE64_REGISTRY=$(openssl rand -base64 16)
export SERVICE_BASE64_SEARXNG=$(openssl rand -base64 16)

# Start services
docker-compose up -d

# Watch logs
docker-compose logs -f openclaw

# Access when ready
# Look for token in logs, then open:
# http://localhost:18789?token=YOUR_TOKEN
```

## Getting Help

If you're still stuck after trying:
1. Running `./scripts/diagnose.sh`
2. Reading `TROUBLESHOOTING.md`
3. Checking Coolify logs

Please gather this info:
- Full build logs (from Coolify)
- Runtime logs (last 100 lines)
- Output of `./scripts/diagnose.sh`
- Your VPS specs (RAM, CPU)
- Which domain provider you're using

Then open an issue on GitHub or ask in the community.

## Next Steps

Once OpenClaw is running:

1. **Explore the Dashboard**
   - Check system health
   - View active sessions
   - Monitor resource usage

2. **Try Commands**
   - In connected chat: "What's the weather?"
   - Ask it to write code
   - Test web search

3. **Add Skills**
   - OpenClaw has a plugin system
   - Check `skills/` directory
   - Read [Skills Documentation](docs/tools/skills.md)

4. **Secure Your Instance**
   - Change the auth token (optional)
   - Set up proper firewall rules
   - Enable HTTPS only

---

**Welcome to OpenClaw! 🦞**

Your self-hosted AI assistant is ready to work where you work—in the chat apps you already use, on infrastructure you control.
