# Tech LEAD Setup Checklist

## Current Status
- ✅ Docker containers running (n8n, nocodb, postgres)
- ✅ n8n accessible at http://localhost:5678
- ✅ NocoDB accessible at http://localhost:8810
- ✅ Credentials added in n8n UI
- ⏳ Database tables need creation
- ⏳ Telegram webhook needs configuration
- ⏳ Workflows need credential linking

## Required Information

Please provide:
1. **Your n8n API key** (from n8n Settings → API → Create API Key)
2. **Your Telegram Bot Token** (from @BotFather)
3. **Your Telegram Chat ID** (your personal or group chat ID)
4. **Your GitHub repository** (where Tech LEAD will manage issues)
5. **Your GitHub Personal Access Token** (with repo and workflow permissions)

## Step-by-Step Setup

### 1. Update .env file
Edit `/media/rob/Workspace/Development/techLEAD/.env`:
```bash
N8N_API_KEY=your-new-n8n-api-key
TELEGRAM_BOT_TOKEN=your-bot-token-from-botfather
TELEGRAM_CHAT_ID=your-chat-id
GITHUB_TOKEN=your-github-pat
GITHUB_ORG=your-github-username-or-org
```

### 2. Set up NocoDB Database
```bash
# Run the setup script for instructions
./scripts/setup-nocodb.sh
```

Key steps:
1. Open http://localhost:8810
2. Create a base called "techLEAD"
3. Create three tables: projects_table, decisions_log, work_log
4. Get API token from NocoDB settings
5. Update NOCODB_API_TOKEN in .env

### 3. Configure Telegram Webhook

After updating .env with your bot token, I can run:
```bash
# Get webhook URL from n8n
WEBHOOK_URL="http://YOUR_PUBLIC_IP:5678/webhook/telegram-webhook"

# Set webhook for your bot
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"${WEBHOOK_URL}\"}"
```

### 4. Link Credentials in n8n Workflows

In n8n UI:
1. Open "Tech LEAD - Main Orchestrator" workflow
2. Click each HTTP Request node
3. In credentials dropdown, select your configured credentials:
   - GitHub nodes → Select your GitHub credential
   - NocoDB nodes → Select your NocoDB credential
   - Telegram nodes → Select your Telegram credential
4. Save the workflow

### 5. Activate Workflows
1. In n8n UI, open each workflow
2. Toggle the "Active" switch in the top bar
3. Start with Telegram Bot Handler (always active)
4. Then activate Main Orchestrator (runs every 30 min)

## Quick Test Commands

Once setup is complete:

```bash
# Test Telegram bot
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe"

# Test n8n API
curl -X GET "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: ${N8N_API_KEY}"

# Test NocoDB API
curl -X GET "http://localhost:8810/api/v1/db/data/nc/techLEAD/projects_table" \
  -H "xc-auth: ${NOCODB_API_TOKEN}"
```

## What Each Component Does

- **Main Orchestrator**: Runs every 30 minutes, fetches issues, asks Claude to select one
- **Telegram Bot Handler**: Receives commands from you via Telegram
- **NocoDB**: Stores project state, decisions, and work logs
- **GitHub Integration**: Manages issues, PRs, and triggers workflows

## Need Help?

If you provide the required tokens and information, I can:
1. Set up the Telegram webhook automatically
2. Update the workflows via API
3. Create a test project in NocoDB
4. Run initial tests to verify everything works