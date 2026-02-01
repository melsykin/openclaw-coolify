# OpenClaw Minimal - Coolify Deployment

**Bare-bones OpenClaw with security hardening.**

## What's Included

✅ **Core OpenClaw** - Chat interface + AI agent
✅ **Security** - Docker socket proxy + token auth
✅ **UI Access** - Token-protected web interface
✅ **Multi-provider** - OpenAI, Anthropic, Google Gemini support

## What's Removed

❌ Browser automation (Playwright, Chromium)
❌ Media tools (FFmpeg, ImageMagick)
❌ AI CLIs (Claude, Kimi, Gemini CLIs)
❌ Deployment tools (Vercel, GitHub CLI)
❌ Extra languages (Go, Python packages)
❌ Optional services (SearXNG, Qdrant, etc.)

## Quick Start

### 1. Configure Environment

Edit `.env` and add at least one API key:

```bash
ANTHROPIC_API_KEY=sk-ant-...
# or
OPENAI_API_KEY=sk-...
# or
GEMINI_API_KEY=...
```

### 2. Deploy on Coolify

In Coolify project settings:
- **Docker Compose Location**: `docker-compose.minimal.yaml`
- **Port**: 18789
- Load env vars from `.env.minimal`

### 3. Access the UI

After deployment succeeds, check the logs for:

```
🔑 Access Token: abc123...
🌍 Service URL: https://your-domain.com?token=abc123...
```

Click the URL to access the web interface.

## Build Time

**~5-10 minutes** (vs 30-40min for full build)

## Image Size

**~800MB** (vs 2.5GB for full build)

## Security Features

- Docker socket proxy (no direct socket mount)
- Token-based authentication (randomly generated)
- HTTPS via Caddy (Coolify managed)
- Limited Docker API permissions

## Troubleshooting

**Build fails**: Check Docker daemon has internet access
**Can't access UI**: Verify port 18789 is exposed in Coolify
**Token not working**: Check logs for the current token

## Need More Features?

Use `docker-compose.yaml` + `Dockerfile` for the full version with:
- Browser automation
- Media processing
- Python tools
- AI CLIs
- More providers
