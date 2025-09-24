# n8n Workflow Setup Guide

This guide will help you import and configure the Tech LEAD workflows in your n8n instance.

## Prerequisites

- n8n instance running (via Docker Compose or self-hosted)
- Access to n8n UI (typically http://localhost:5678)
- Required credentials configured (see Credentials section)

## Step 1: Configure Credentials

Before importing workflows, set up these credentials in n8n:

### 1.1 GitHub Personal Access Token
1. Go to Settings → Credentials → Add Credential
2. Choose "GitHub API"
3. Name: `GitHub PAT`
4. Authentication: Personal Access Token
5. Token: Your GitHub PAT with `repo`, `workflow` permissions

### 1.2 Telegram Bot
1. Go to Settings → Credentials → Add Credential
2. Choose "Telegram API"
3. Name: `Tech LEAD Telegram Bot`
4. Access Token: Your bot token from @BotFather

### 1.3 NocoDB API
1. Go to Settings → Credentials → Add Credential
2. Choose "HTTP Request (Header Auth)"
3. Name: `NocoDB API`
4. Header Name: `xc-auth`
5. Header Value: Your NocoDB API token

## Step 2: Configure Environment Variables

Add these environment variables to your n8n instance:

```bash
# In your .env file or docker-compose.yml
N8N_CUSTOM_ENV_NOCODB_API_URL=http://nocodb:8080
N8N_CUSTOM_ENV_GITHUB_ORG=your-org
N8N_CUSTOM_ENV_TELEGRAM_BOT_USERNAME=@YourBotUsername
```

## Step 3: Import Workflows

### Option A: Import via UI
1. Open n8n UI
2. Click "Workflows" → "Import from File"
3. Import these files in order:
   - `workflows/n8n-telegram-bot.json` (must be first for webhook)
   - `workflows/n8n-main-orchestrator.json`

### Option B: Import via CLI
```bash
# If you have n8n CLI installed
n8n import:workflow --input=./workflows/n8n-telegram-bot.json
n8n import:workflow --input=./workflows/n8n-main-orchestrator.json
```

## Step 4: Configure Webhooks

### 4.1 Get Telegram Webhook URL
1. Open the "Tech LEAD - Telegram Bot Handler" workflow
2. Click on the "Telegram Webhook" node
3. Copy the webhook URL (e.g., `https://your-n8n.com/webhook/telegram-webhook`)

### 4.2 Set Telegram Webhook
```bash
# Set the webhook for your bot
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-n8n-domain.com/webhook/telegram-webhook"
  }'
```

## Step 5: Initialize Database

1. Access NocoDB at http://localhost:8080
2. Create a new base called `techLEAD`
3. Run the SQL from `schema/init.sql`
4. Insert your first project:

```sql
INSERT INTO projects_table (
  repository_url,
  project_identifier,
  status,
  telegram_chat_id,
  context_summary
) VALUES (
  'https://github.com/yourusername/yourrepo',
  'MY_PROJECT',
  'active',
  'YOUR_TELEGRAM_CHAT_ID',
  'Project description and goals'
);
```

## Step 6: Test the Setup

### 6.1 Test Telegram Bot
1. Message your bot: `/help`
2. You should receive the command list

### 6.2 Test Workflow Execution
1. Manually trigger the Main Orchestrator workflow
2. Check execution logs in n8n
3. Verify Telegram receives the issue selection message

## Step 7: Activate Workflows

Once testing is complete:
1. Activate "Tech LEAD - Telegram Bot Handler" (always on)
2. Activate "Tech LEAD - Main Orchestrator" (runs every 30 minutes)

## Troubleshooting

### Webhook Not Responding
- Check n8n is accessible from the internet
- Verify webhook URL is correct
- Check n8n logs for incoming requests

### Claude CLI Not Working
- Verify Claude CLI is installed in n8n container
- Check authentication: `docker exec n8n-container claude auth status`
- Ensure Execute Command node is enabled in n8n

### NocoDB Connection Issues
- Verify NocoDB is running
- Check network connectivity between containers
- Validate API token permissions

### Telegram Bot Issues
- Verify bot token is correct
- Check bot has admin rights in the group (if using groups)
- Review webhook status: `https://api.telegram.org/bot<TOKEN>/getWebhookInfo`

## Additional Workflows

The following workflows are still being converted to n8n format:
- Issue Monitor (checks @claude completion)
- PR Monitor (watches for reviews)
- Claude Execution Helper (utility workflow)

These will be added in subsequent updates.

## Support

For issues or questions:
1. Check n8n execution logs
2. Review decision_log table in NocoDB
3. Check Telegram bot webhook info
4. Open an issue on GitHub with details