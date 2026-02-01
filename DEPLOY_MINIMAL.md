# Minimal OpenClaw Deployment Guide

## 🎯 Goal
Fast, secure OpenClaw deployment with token-based UI access.

## 📦 What You Get
- **Build time**: 5-10 minutes (vs 30-40min)
- **Image size**: ~800MB (vs 2.5GB)
- **Security**: Docker proxy + token auth
- **UI**: Full web interface with token protection

## 🚀 Deployment Steps

### Option A: Using Coolify UI

1. **In your Coolify project**, go to **Configuration**

2. **Set Docker Compose file**:
   ```
   docker-compose.minimal.yaml
   ```

3. **Add environment variables** (in Coolify UI):
   ```
   ANTHROPIC_API_KEY=sk-ant-your-key-here
   ```
   *(or OPENAI_API_KEY, GEMINI_API_KEY)*

4. **Deploy** and wait ~5-10 minutes

5. **Check logs** for your access URL with token:
   ```
   🔑 Access Token: abc123...
   ☁️  Public: https://your-domain.com?token=abc123...
   ```

### Option B: Using Git Branch

1. **Update coolify.json**:
   ```bash
   cp coolify.minimal.json coolify.json
   git add coolify.json
   git commit -m "Use minimal deployment"
   git push
   ```

2. **Update .env** in Coolify with your API key

3. **Redeploy** in Coolify

## 🔑 Accessing the UI

Once deployed, find this in the logs:

```
================================================================
🦞 OpenClaw is ready!
================================================================

🔑 Access Token: your-random-token-here

🌍 Local: http://localhost:18789?token=your-random-token-here
☁️  Public: https://your-domain.com?token=your-random-token-here

================================================================
```

Click the public URL and you're in!

## ✅ Verify It's Working

1. Access the URL with token
2. You should see the OpenClaw web interface
3. Try sending a message like "hello"
4. The AI should respond

## 🔧 Troubleshooting

### Build fails
- Check Docker has internet access
- Verify API key is set in Coolify

### Can't access UI
- Check port 18789 is exposed
- Verify domain is pointing to your server
- Wait 1-2 minutes for Caddy to propagate

### Token doesn't work
- Check logs for current token
- Token changes on each redeploy (check fresh logs)

### AI not responding
- Verify API key is correct in Coolify env vars
- Check logs for API errors

## 📊 Comparison

| Feature | Minimal | Full |
|---------|---------|------|
| Build Time | 5-10 min | 30-40 min |
| Image Size | 800MB | 2.5GB |
| Security | ✅ | ✅ |
| UI Access | ✅ | ✅ |
| Core Chat | ✅ | ✅ |
| Browser Tools | ❌ | ✅ |
| Media Tools | ❌ | ✅ |
| AI CLIs | ❌ | ✅ |
| Python Tools | ❌ | ✅ |

## 🔄 Upgrade to Full Version

If you need browser automation, media processing, etc:

1. Switch back to `docker-compose.yaml`
2. Update coolify.json or Coolify UI setting
3. Redeploy (wait 30-40min)

## 💾 Data Persistence

Your data is persisted in Docker volumes:
- `openclaw-config` - Settings and token
- `openclaw-workspace` - Chat history and agent workspace

These survive redeployments!
