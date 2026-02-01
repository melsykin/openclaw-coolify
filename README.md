# OpenClaw Minimal

Lightweight OpenClaw deployment with security hardening.

## Features

- Core OpenClaw chat interface
- Token-based authentication
- Docker socket proxy (security)
- Multi-provider AI support (Anthropic, OpenAI, Gemini)

## Requirements

- Coolify or Docker Compose
- At least one AI provider API key

## Quick Start

### 1. Set API Key

In Coolify, add your API key to environment variables:

```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

Or use `OPENAI_API_KEY` or `GEMINI_API_KEY`.

### 2. Deploy

Coolify will automatically use `docker-compose.yaml`.

Build time: ~5-10 minutes.

### 3. Access UI

Check deployment logs for:

```
🦞 OpenClaw is ready!

🔑 Access Token: abc123...
☁️  Public: https://your-domain.com?token=abc123...
```

Click the URL to access the web interface.

## Troubleshooting

Run diagnostics inside the container:

```bash
bash /app/scripts/diagnose.sh
```

Common issues:

- **Build fails**: Check Docker has internet access
- **Can't access UI**: Verify port 18789 is exposed
- **Token not working**: Check logs for current token
- **AI not responding**: Verify API key in Coolify env vars

## Data Persistence

Docker volumes preserve your data across redeployments:

- `openclaw-config` - Settings and token
- `openclaw-workspace` - Chat history

## Security

- Docker socket access via proxy (limited API permissions)
- Token-based UI authentication (randomly generated)
- HTTPS via Caddy (Coolify managed)
