# Your OpenClaw Deployment - Likely Issues

## Critical Finding: Missing API Keys

I checked your `.env` file and found **no AI provider API keys configured**. This is the most likely reason your deployment isn't working.

### ❌ What's Missing
Your `.env` file only contains Supabase keys (which are not used by OpenClaw). You need at least ONE of these:

```bash
OPENAI_API_KEY=sk-proj-...
ANTHROPIC_API_KEY=sk-ant-...
GEMINI_API_KEY=AIza...
MINIMAX_API_KEY=...
```

## How to Fix This

### In Coolify:

1. **Go to your OpenClaw service**
2. Click **Environment Variables**
3. **Add one of these:**

   | Provider | Variable Name | Get Key From |
   |----------|--------------|--------------|
   | OpenAI | `OPENAI_API_KEY` | https://platform.openai.com/api-keys |
   | Claude | `ANTHROPIC_API_KEY` | https://console.anthropic.com/account/keys |
   | Gemini | `GEMINI_API_KEY` | https://aistudio.google.com/app/apikey |
   | MiniMax | `MINIMAX_API_KEY` | https://platform.minimaxi.com |

4. **Click Save**
5. **Redeploy** the service (Coolify will rebuild with the new environment variable)

### Example (Adding OpenAI):
```
Variable Name: OPENAI_API_KEY
Value: sk-proj-abc123xyz...
```

## Other Common Issues

### 1. Domain Configuration (If API keys are already set)

**Symptom:** Container runs but you can't access it

**Check in Coolify:**
- Go to your service → **Domains**
- Make sure you have a domain configured (e.g., `openclaw.yourdomain.com`)
- Verify your DNS A record points to your Coolify server IP

**Quick DNS Test:**
```bash
# On your local machine:
nslookup openclaw.yourdomain.com

# Should return your Coolify server IP
```

**Common DNS Mistakes:**
- Using Cloudflare with proxy enabled (orange cloud) - **Set to "DNS Only"** (gray cloud)
- Wrong IP address in A record
- Forgot to add A record entirely

### 2. Insufficient Resources (Hostinger VPS)

**Symptom:** Build fails or container crashes

**Check your Hostinger plan:**
- Need minimum: **2GB RAM**, **2 CPU cores**
- Recommended: **4GB RAM**, **4 CPU cores**

**How to check (in Coolify terminal):**
```bash
free -h  # Check RAM
df -h    # Check disk space
```

### 3. Build Failures

**Symptom:** Deployment fails during build phase

**Common causes:**
- npm registry timeout (temporary)
- Insufficient disk space
- Out of memory during build

**Solution:**
1. Check build logs for specific error
2. Try deploying again (npm can be unreliable)
3. If OOM (Out of Memory), upgrade your VPS plan

### 4. Docker Socket Access

**Symptom:** Container starts but can't create sandboxes

**This is usually handled automatically** by the `docker-proxy` service, but check:

In Coolify logs, verify you see:
```
docker-proxy | ... [info] Accepting connections
```

## Step-by-Step Diagnosis

Run these commands in your **Coolify Service Terminal**:

### 1. Check if OpenClaw is installed:
```bash
which openclaw
openclaw --version
```

Expected output:
```
/usr/local/bin/openclaw
openclaw version X.Y.Z
```

### 2. Run the diagnostic script:
```bash
chmod +x /app/scripts/diagnose.sh
/app/scripts/diagnose.sh
```

This will check:
- ✅ OpenClaw installation
- ✅ API keys (most likely your issue!)
- ✅ Docker access
- ✅ Configuration
- ✅ System resources

### 3. Check the logs:
```bash
# Look for the "ready" message:
tail -50 /var/log/* | grep -i "openclaw is ready"

# Or check recent errors:
tail -100 /var/log/* | grep -i error
```

### 4. Try manual start (for debugging):
```bash
openclaw gateway run
```

Watch for errors. Common error if API keys are missing:
```
Error: No model provider configured
```

## Most Likely Root Causes (In Order)

### 1. 🔴 No API Keys (90% probability)
**Evidence:** Your `.env` file has no AI provider keys
**Fix:** Add at least one API key in Coolify environment variables

### 2. 🟡 Domain Not Configured (5% probability)
**Evidence:** Would need to check your Coolify domain settings
**Fix:** Configure domain in Coolify or access via IP

### 3. 🟡 Build Failed (3% probability)
**Evidence:** Would show in build logs
**Fix:** Check build logs for npm/Docker errors

### 4. 🟢 Docker Socket Issues (1% probability)
**Evidence:** docker-proxy not running
**Fix:** Redeploy entire service

### 5. 🟢 Insufficient Resources (1% probability)
**Evidence:** OOM killer in system logs
**Fix:** Upgrade VPS plan

## Recommended Action Plan

### Step 1: Add API Keys (DO THIS FIRST)
1. Choose a provider (OpenAI is easiest to get started)
2. Get an API key
3. Add to Coolify environment variables
4. Redeploy

### Step 2: Watch the Deployment
1. Monitor **Build Logs**
2. Look for: "✅ openclaw binary found"
3. Then monitor **Service Logs**
4. Look for: "🦞 OpenClaw is ready!"

### Step 3: First Access
1. Copy the URL with token from logs
2. Open in browser (you'll see "Unauthorized")
3. Run `openclaw-approve` in Coolify terminal
4. Refresh browser

### Step 4: If Still Not Working
1. Run `/app/scripts/diagnose.sh` in terminal
2. Check the output for specific failures
3. Read the detailed TROUBLESHOOTING.md guide
4. Gather logs and specific error messages

## Quick Reference Files

I've created several helpful files for you:

- **QUICK_START.md** - Step-by-step deployment guide
- **TROUBLESHOOTING.md** - Detailed troubleshooting for common issues
- **scripts/diagnose.sh** - Automated diagnostic script
- **DIAGNOSIS.md** (this file) - Summary of likely issues

## Need More Help?

If after adding API keys and following the steps above it still doesn't work, please provide:

1. **Output of diagnostic script:**
   ```bash
   /app/scripts/diagnose.sh > /tmp/diagnosis.txt
   cat /tmp/diagnosis.txt
   ```

2. **Last 100 lines of logs:**
   ```bash
   # In Coolify: Service → Logs → Copy last 100 lines
   ```

3. **Build logs** (if build failed)

4. **Your setup:**
   - Hostinger VPS specs (RAM/CPU)
   - Domain configuration
   - Which API key you added

---

## TL;DR - Fastest Path to Working OpenClaw

1. **Get an API key** (OpenAI: https://platform.openai.com/api-keys)
2. **Add to Coolify:** Environment Variables → `OPENAI_API_KEY` → `sk-proj-YOUR-KEY`
3. **Redeploy** (click Deploy button)
4. **Wait 10 minutes** for build to complete
5. **Check logs** for "🦞 OpenClaw is ready!" and copy the URL
6. **Access URL** → Run `openclaw-approve` in terminal → Refresh browser
7. **Done!** You should see the OpenClaw dashboard

**Time from start to working:** 15-20 minutes (assuming you have API key ready)
