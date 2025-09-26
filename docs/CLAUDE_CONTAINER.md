# Claude Container Documentation

## Overview

The Claude Proxy Container provides an HTTP API interface to Claude CLI, enabling n8n workflows to interact with Claude without requiring API keys. It uses OAuth authentication from the host machine's active Claude installation.

## Architecture

```
┌────────────────────────────────────────────────┐
│              Docker Host (Hydra)                │
│                                                 │
│  ┌─────────────────┐     ┌──────────────────┐ │
│  │   n8n Container │────▶│  Claude Proxy    │ │
│  │                 │     │   Container      │ │
│  │ Port: 5678      │     │  Port: 8888      │ │
│  └─────────────────┘     └──────────────────┘ │
│         │                        │             │
│         └───── Shared Network ───┘             │
│              (n8n_default)                     │
└────────────────────────────────────────────────┘
```

## Container Setup

### Location
```
/home/rob/docker/claudecodeproxy/
```

### Files
- `Dockerfile` - Container definition
- `docker-compose.yml` - Service configuration
- `proxy-server.py` - HTTP API server
- `setup.sh` - Setup script
- `claude` - Claude CLI binary
- `claude-credentials/` - OAuth credentials

## API Endpoints

### Health Check
```bash
GET http://localhost:8888/health

Response:
{
  "status": "healthy",
  "timestamp": "2025-09-26T18:24:47.376472",
  "claude_available": true
}
```

### Execute Claude Command
```bash
POST http://localhost:8888/execute
Content-Type: application/json

{
  "prompt": "Your question here",
  "json": false,
  "max_turns": 1,
  "timeout": 30
}

Response:
{
  "success": true,
  "stdout": "Claude's response",
  "stderr": "",
  "returncode": 0,
  "command": ["claude", "-p", "..."]
}
```

### Test Cases

Built-in test cases for quick validation:

```bash
# Simple test
curl -X POST http://localhost:8888/execute \
  -H "Content-Type: application/json" \
  -d '{"test_case": "simple"}'

# Tech LEAD decision test
curl -X POST http://localhost:8888/execute \
  -H "Content-Type: application/json" \
  -d '{"test_case": "tech_lead"}'
```

## n8n Integration

### Workflow Configuration

Use the HTTP Request node with these settings:

```javascript
{
  "method": "POST",
  "url": "http://claudeproxy:8888/execute",
  "sendBody": true,
  "specifyBody": "json",
  "jsonBody": {
    "prompt": "{{ $json.prompt }}",
    "json": true,
    "max_turns": 1
  }
}
```

### Container Networking

The Claude proxy container joins the n8n network automatically:

```yaml
networks:
  - n8n_default  # Shared with n8n
  - nocodb-net  # Optional NocoDB access
```

From n8n workflows, use: `http://claudeproxy:8888`
From host machine, use: `http://localhost:8888`

## Authentication

The container uses OAuth credentials from the host's active Claude installation:

1. Host credentials location: `~/.claude/.credentials.json`
2. Copied during setup to: `claude-credentials/`
3. Mounted in container at: `/home/claude/.claude/`

### Refreshing Credentials

When host credentials are updated:

```bash
cd /home/rob/docker/claudecodeproxy
./setup.sh  # Copies fresh credentials
docker compose restart claudeproxy
```

## Maintenance

### Container Management

```bash
# Start container
docker compose up -d

# Stop container
docker compose down

# View logs
docker compose logs -f claudeproxy

# Restart container
docker compose restart claudeproxy

# Rebuild after changes
docker compose build
docker compose up -d
```

### Troubleshooting

#### Check container status
```bash
docker ps | grep claudeproxy
```

#### Test from n8n container
```bash
docker exec n8n wget -qO- http://claudeproxy:8888/health
```

#### Verify Claude CLI in container
```bash
docker exec claudeproxy /home/claude/.local/bin/claude --version
```

#### Common Issues

1. **Permission Denied Errors**
   - The container creates required directories with proper permissions
   - Check: `docker exec claudeproxy ls -la /home/claude/.claude/`

2. **Authentication Failures**
   - Credentials expire or need refresh
   - Solution: Run `./setup.sh` and restart container

3. **Network Connectivity**
   - Ensure containers share the same network
   - Check: `docker network inspect n8n_default`

4. **Port Conflicts**
   - Port 8888 must be available
   - Check: `lsof -i :8888`

## Security Notes

- OAuth credentials are copied from host, not stored in image
- Container runs as non-root user (claude)
- Credentials have restricted permissions (600)
- No external API keys required
- Container only accessible on local network

## Performance

- First request may take 5-10 seconds (Claude initialization)
- Subsequent requests typically respond in 2-5 seconds
- Default timeout: 30 seconds (configurable per request)
- Container uses minimal resources (~100MB RAM)

## Updates

To update Claude CLI binary:

```bash
# Copy new binary from host
cp ~/.local/bin/claude /home/rob/docker/claudecodeproxy/claude

# Rebuild container
cd /home/rob/docker/claudecodeproxy
docker compose build
docker compose up -d
```