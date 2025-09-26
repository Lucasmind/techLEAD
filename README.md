# Tech LEAD - Leadership Engine for AI Development

An intelligent orchestration system that autonomously manages GitHub development workflows by coordinating AI agents (@claude, @claude-test, @claude-review) through strategic decision-making.

## 🚀 Overview

Tech LEAD acts as an intelligent technical leader for your development projects. It doesn't write code - instead, it makes strategic decisions about what to work on, how to approach problems, and coordinates a team of AI agents to execute the actual implementation.

### Key Features

- **Autonomous Issue Management**: Analyzes and prioritizes GitHub issues intelligently
- **Strategic Decision Making**: Uses Claude AI to make tech lead-level decisions
- **PM Communication**: Natural language interaction via Telegram bot
- **Workflow Orchestration**: Coordinates @claude, @claude-test, and @claude-review
- **Project Agnostic**: Works with any GitHub repository and project structure
- **Cost Efficient**: Uses Claude CLI with your Max subscription (no API costs)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Tech LEAD System                      │
├───────────────┬────────────────┬────────────────────────┤
│     n8n       │  Claude Proxy  │     GitHub Actions     │
│  Orchestrator │  Container API │  @claude/@claude-test  │
├───────────────┼────────────────┼────────────────────────┤
│   NocoDB      │   Telegram Bot │    GitHub Repository   │
│ State Storage │   PM Interface │    Source of Truth     │
└───────────────┴────────────────┴────────────────────────┘
```

### Container Architecture
- **Claude Proxy Container**: HTTP API wrapper for Claude CLI
- **Shared Docker Network**: Container-to-container communication
- **OAuth Authentication**: Uses host's Claude credentials
- **Port 8888**: HTTP API endpoint

## 📋 Prerequisites

- n8n instance (self-hosted)
- Claude CLI with active Max subscription
- GitHub repository with Actions enabled
- Docker & Docker Compose
- Telegram account
- Linux/Mac environment

## 🛠️ Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/Lucasmind/techLEAD.git
cd techLEAD
```

### 2. Deploy infrastructure
```bash
# Start core services
docker-compose up -d

# Setup Claude proxy container
cd /home/rob/docker/claudecodeproxy
./setup.sh
docker compose build
docker compose up -d
```

### 3. Configure environment
```bash
cp .env.example .env
# Edit .env with your credentials
```

### 4. Import n8n workflows
- Open n8n at http://localhost:5678
- Import workflows from `workflows/` directory
- Configure credentials in n8n

### 5. Initialize NocoDB
- Access NocoDB at http://localhost:8080
- Run schema setup from `schema/init.sql`
- Add your first project

### 6. Start the bot
- Message @BotFather on Telegram
- Create bot and get token
- Configure webhook to n8n

## 💬 Telegram Commands

### Natural Language
- "@techLEAD what are we working on?"
- "@techLEAD why did we choose this issue?"
- "@techLEAD pause work"
- "@techLEAD give me a status update"

### Quick Commands
- `/status` - Current work status
- `/pause` - Pause automation
- `/resume` - Resume automation
- `/projects` - List active projects

## 🔄 Workflow Overview

1. **Main Orchestrator** (30-min cycle)
   - Fetches GitHub issues
   - Claude analyzes and selects next task
   - PM approves via Telegram
   - Triggers @claude implementation

2. **Issue Monitor**
   - Watches @claude completion
   - Triggers @claude-test
   - Escalates test failures to PM
   - Creates PR when ready

3. **PR Monitor**
   - Waits for auto-triggered @claude-review
   - Claude filters review feedback
   - PM approves changes
   - Merges and cleans up

## 🔧 Configuration

### GitHub Setup
```yaml
# Add to your repository:
.github/workflows/claude.yml
.github/workflows/claude-test.yml
.github/workflows/claude-review.yml
```

### Project Configuration
```json
{
  "repository_url": "https://github.com/user/repo",
  "project_identifier": "FEATURE_NAME",
  "context_summary": "Building feature X with requirements Y"
}
```

## 📊 Monitoring

- **GitHub Issues**: Primary source of truth
- **NocoDB Dashboard**: Decision history and logs
- **Telegram**: Real-time status updates
- **n8n Executions**: Workflow monitoring

## 🐛 Troubleshooting

### Common Issues

**Claude Proxy Container Issues**
- Check container status: `docker ps | grep claudeproxy`
- View logs: `docker logs claudeproxy --tail 50`
- Test health: `curl http://localhost:8888/health`
- Verify credentials: `docker exec claudeproxy ls -la /home/claude/.claude/`

**Claude CLI not responding**
- Container uses OAuth from host's `~/.claude/.credentials.json`
- Refresh credentials: `cd /home/rob/docker/claudecodeproxy && ./setup.sh`
- Rebuild container: `docker compose down && docker compose build && docker compose up -d`

**Telegram bot not receiving messages**
- Verify webhook URL in BotFather
- Check n8n webhook is active

**GitHub workflows not triggering**
- Ensure PAT has workflow permissions
- Verify @claude mentions are formatted correctly

## 📚 Documentation

- [CLAUDE.md](./CLAUDE.md) - AI implementation guidelines
- [Setup Guide](./docs/SETUP.md) - Detailed setup instructions
- [Troubleshooting](./docs/TROUBLESHOOTING.md) - Common issues and solutions
- [Contributing](./CONTRIBUTING.md) - How to contribute

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](./LICENSE) for details

## 🙏 Acknowledgments

- Anthropic for Claude AI
- n8n for workflow automation
- NocoDB for database interface
- The open-source community

---

Built with ❤️ by the Tech LEAD team