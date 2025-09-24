# Tech LEAD Setup Guide

## Prerequisites Checklist

- [ ] Linux/macOS environment
- [ ] Docker and Docker Compose installed
- [ ] n8n instance (self-hosted)
- [ ] Claude CLI with active Max subscription
- [ ] GitHub account with repository access
- [ ] Telegram account
- [ ] Basic command line knowledge

## Step-by-Step Setup

### 1. System Preparation

```bash
# Clone the repository
git clone https://github.com/Lucasmind/techLEAD.git
cd techLEAD

# Make scripts executable
chmod +x scripts/*.sh
```

### 2. Claude CLI Setup

```bash
# Install Claude CLI (if not already installed)
# Visit https://claude.ai/cli for installation instructions

# Verify installation
claude --version

# Authenticate
claude auth login
```

### 3. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit with your credentials
nano .env
```

Required configurations:
- `GITHUB_TOKEN`: Create at GitHub Settings → Developer Settings → Personal Access Tokens
- `TELEGRAM_BOT_TOKEN`: Get from @BotFather on Telegram
- `TELEGRAM_CHAT_ID`: Use @userinfobot to get your ID

### 4. Deploy Infrastructure

```bash
# Run setup script
./scripts/setup.sh

# Verify services are running
docker-compose ps
```

### 5. Initialize NocoDB

1. Access NocoDB at http://localhost:8080
2. Create admin account on first access
3. Create new base called "techLEAD"
4. Run SQL from `schema/init.sql`
5. Generate API token: Settings → API Tokens → Generate

### 6. Configure n8n

1. Access your n8n instance
2. Create new credentials:
   - GitHub: Use PAT token from .env
   - NocoDB: Use API token from step 5
   - Telegram: Use bot token from .env

3. Import workflows:
   - Go to Workflows → Import
   - Import each file from `workflows/` directory
   - Update webhook URLs in each workflow

### 7. Setup Telegram Bot

```bash
# 1. Create bot with @BotFather
/newbot
# Follow prompts to get token

# 2. Set webhook (replace URL)
curl -X POST "https://api.telegram.org/bot<YOUR_TOKEN>/setWebhook" \
  -d "url=https://your-n8n-instance.com/webhook/telegram"

# 3. Verify webhook
curl "https://api.telegram.org/bot<YOUR_TOKEN>/getWebhookInfo"
```

### 8. Configure GitHub Repository

Add these secrets to your repository:
- Settings → Secrets → Actions
- Add `CLAUDE_CODE_OAUTH_TOKEN`

Ensure workflows exist:
- `.github/workflows/claude.yml`
- `.github/workflows/claude-test.yml`
- `.github/workflows/claude-review.yml`

### 9. Initial Project Setup

```sql
-- Run in NocoDB SQL console
INSERT INTO projects_table (
  repository_url,
  project_identifier,
  status,
  telegram_chat_id,
  context_summary
) VALUES (
  'https://github.com/yourusername/yourrepo',
  'YOUR_PROJECT_LABEL',
  'planning',
  'YOUR_TELEGRAM_CHAT_ID',
  'Project description and goals'
);
```

### 10. Test the System

```bash
# Test Claude CLI
./scripts/test-claude-cli.sh

# Test Telegram bot
# Send message: @techLEAD status

# Test n8n workflows
# Manually trigger Main Orchestrator in n8n UI
```

## Verification Checklist

- [ ] Docker services running
- [ ] NocoDB accessible and schema created
- [ ] n8n workflows imported
- [ ] Telegram bot responding
- [ ] Claude CLI working
- [ ] GitHub webhooks configured
- [ ] First project created in NocoDB

## Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues and solutions.