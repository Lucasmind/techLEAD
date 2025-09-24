# Tech LEAD Troubleshooting Guide

## Common Issues and Solutions

### Claude CLI Issues

#### "Claude: command not found"
```bash
# Check if Claude is in PATH
which claude

# If not found, add to PATH or use full path in .env
CLAUDE_CLI_PATH=/full/path/to/claude
```

#### "Authentication required"
```bash
# Re-authenticate
claude auth login

# Check status
claude auth status
```

### Telegram Bot Issues

#### Bot not responding
1. Check webhook status:
```bash
curl "https://api.telegram.org/bot<TOKEN>/getWebhookInfo"
```

2. Verify n8n webhook is active:
- Check Telegram Bot Handler workflow is active
- Verify webhook URL matches

#### "Unauthorized" errors
- Regenerate bot token with @BotFather
- Update token in .env and n8n credentials

### GitHub Issues

#### Workflows not triggering
1. Check GitHub Action logs
2. Verify @claude mention format
3. Ensure oauth token is valid
4. Check repository permissions

#### Rate limiting
- Implement caching in n8n
- Increase check intervals
- Use webhook instead of polling

### NocoDB Issues

#### Connection refused
```bash
# Check if service is running
docker-compose ps

# Check logs
docker-compose logs nocodb

# Restart service
docker-compose restart nocodb
```

#### API token not working
1. Regenerate token in NocoDB UI
2. Update in n8n credentials
3. Test with curl:
```bash
curl -H "xc-token: YOUR_TOKEN" http://localhost:8080/api/v1/db/data/noco
```

### n8n Workflow Issues

#### Execute Command node fails
- Verify Claude CLI path
- Check command syntax
- Test command manually in terminal

#### Workflow stops unexpectedly
1. Check execution logs in n8n
2. Look for error nodes
3. Verify all credentials are valid
4. Check timeout settings

### Docker Issues

#### Services won't start
```bash
# Check ports availability
netstat -tulpn | grep -E '8080|5432'

# Clean restart
docker-compose down
docker-compose up -d

# Check logs
docker-compose logs -f
```

#### Database connection issues
```bash
# Test PostgreSQL connection
docker exec -it techLEAD-postgres psql -U postgres -d nocodb

# Reset database
docker-compose down -v
docker-compose up -d
```

## Debug Commands

### Check System Status
```bash
# All services
docker-compose ps

# Service logs
docker-compose logs [service-name]

# n8n executions
# Check in n8n UI: Executions tab

# Database content
docker exec techLEAD-postgres psql -U postgres -d nocodb -c "SELECT * FROM projects_table;"
```

### Test Components
```bash
# Claude CLI
echo '{"test":"data"}' | claude --prompt "Return the input as JSON"

# Telegram bot
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -d "chat_id=<CHAT_ID>" \
  -d "text=Test message"

# GitHub API
curl -H "Authorization: token <GITHUB_TOKEN>" \
  https://api.github.com/user
```

## Getting Help

1. Check logs for specific error messages
2. Search existing GitHub issues
3. Create detailed bug report with:
   - Error messages
   - Relevant logs
   - Steps to reproduce
   - System configuration