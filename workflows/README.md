# n8n Workflows

This directory will contain the n8n workflow JSON files for Tech LEAD.

## Workflow Files

- **main-orchestrator.json** - Main 30-minute cycle workflow that selects issues and triggers implementation
- **issue-monitor.json** - Monitors GitHub issue status and manages testing
- **pr-monitor.json** - Monitors PR reviews and manages merge process
- **telegram-bot-handler.json** - Handles Telegram bot commands and natural language queries
- **claude-execution-helper.json** - Utility workflow for Claude CLI integration

## Import Instructions

1. Open your n8n instance
2. Go to Workflows → Import
3. Import each JSON file
4. Configure credentials:
   - GitHub (PAT token)
   - NocoDB (API token)
   - Telegram (Bot token)
5. Update webhook URLs to match your instance

## Development

When creating or modifying workflows:
1. Export the workflow as JSON
2. Place in this directory
3. Document any new nodes or connections
4. Test thoroughly before committing

Note: Actual workflow JSON files will be added after n8n implementation.