# Changelog

All notable changes to the Tech LEAD project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2025-01-23

### Added
- Initial project structure and documentation
- Database schema for NocoDB (projects_table, decisions_log, work_log)
- Docker Compose setup for n8n and NocoDB infrastructure
- Project guidelines in CLAUDE.md for AI implementation
- Contributing guidelines
- License (MIT)
- n8n workflow configurations:
  - Main Orchestrator (30-minute cycle for issue selection)
  - Issue Monitor (5-minute checks for @claude completion)
  - PR Monitor (10-minute checks for review status)
  - Telegram Bot Handler (webhook-based command processing)
  - Claude Execution Helper (utility for Claude CLI integration)
- GitHub Actions workflows:
  - @claude implementation workflow
  - @claude-test validation workflow (5 retry attempts)
  - @claude-review automated PR review workflow

### Added (n8n Implementation)
- n8n-compatible workflow JSON files:
  - n8n-main-orchestrator.json (validated and ready)
  - n8n-telegram-bot.json (webhook-based handler)
- Comprehensive n8n setup guide (docs/N8N_SETUP.md)
- Credential configuration instructions
- Webhook setup documentation
- Database initialization guide

### To Do
- Complete remaining workflow conversions (Issue Monitor, PR Monitor, Claude Helper)
- Test full integration with live n8n instance
- Production deployment guide
- Example project walkthrough video
- Advanced troubleshooting documentation