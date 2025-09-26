# Tech LEAD n8n Workflows

This directory contains the n8n workflow definitions for the Tech LEAD orchestration system.

## Core Production Workflows

### Main Orchestrator
- **File**: `main-orchestrator.json`
- **Schedule**: Every 30 minutes
- **Purpose**: Main decision loop for issue selection and agent dispatch
- **Status**: Ready for production

### Issue Monitor
- **File**: `issue-monitor.json`
- **Schedule**: Every 5 minutes
- **Purpose**: Tracks @claude workflow execution and triggers testing
- **Status**: Ready for production

### PR Monitor
- **File**: `pr-monitor.json`
- **Schedule**: Every 10 minutes
- **Purpose**: Monitors PR reviews and manages merge process
- **Status**: Ready for production

### Telegram Bot Handler
- **File**: `telegram-bot-handler.json`
- **Trigger**: Webhook
- **Purpose**: Handles all Telegram bot interactions with PM
- **Status**: Ready for production

### Claude Execution Helper
- **File**: `claude-execution-helper.json`
- **Trigger**: Called by other workflows
- **Purpose**: Standardized Claude execution (update to use container API)
- **Status**: Needs update for container

## Test Workflows

### Claude Container Test
- **File**: `claude-container-test.json`
- **Trigger**: Webhook at `/webhook/claude-container`
- **Purpose**: Basic container connectivity testing
- **Status**: Working

### Claude Container Comprehensive
- **File**: `claude-container-comprehensive.json`
- **Trigger**: Webhook with action routing
- **Purpose**: Full integration testing with Tech LEAD decisions
- **Status**: Working

### Telegram Webhook Test
- **File**: `telegram-webhook-test.json`
- **Trigger**: Webhook
- **Purpose**: Test Telegram bot webhook reception and responses
- **Status**: Working

## Import Instructions

1. Open your n8n instance at http://localhost:5678
2. Go to Workflows → Import from File
3. Import each JSON file
4. Configure credentials:
   - GitHub (PAT token)
   - NocoDB (API token)
   - Telegram (Bot token)
5. Update Claude calls to use `http://claudeproxy:8888/execute`
6. Update webhook URLs to match your instance

## Claude Container Integration

All workflows should now call Claude via the containerized proxy:
- **URL**: `http://claudeproxy:8888/execute`
- **Method**: POST
- **Body**: `{"prompt": "...", "json": true, "max_turns": 1}`

See [CLAUDE_CONTAINER.md](../docs/CLAUDE_CONTAINER.md) for details.

## Development Notes

When modifying workflows:
1. Export the workflow as JSON
2. Test with container endpoints
3. Document any changes
4. Commit with descriptive message