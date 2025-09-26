# CLAUDE.md - AI Implementation Guidelines

## Overview

This document provides guidelines for AI agents working on the Tech LEAD project. Tech LEAD is an orchestration system that makes strategic decisions about GitHub development workflows.

## Project Context

Tech LEAD acts as an intelligent technical leader that:
- Makes strategic decisions about what to work on
- Coordinates AI agents (@claude, @claude-test, @claude-review)
- Communicates with a Project Manager via Telegram
- Maintains project state in NocoDB

## Architecture Understanding

### Core Components
1. **n8n Orchestrator**: Workflow automation engine
2. **Claude CLI**: Strategic decision-making (not API, uses local CLI)
3. **NocoDB**: State management with PostgreSQL backend
4. **Telegram Bot**: PM communication interface
5. **GitHub**: Execution platform for development work

### Key Workflows
- Main Orchestrator (30-minute cycles)
- Issue Monitor (5-minute checks)
- PR Monitor (10-minute checks)
- Telegram Bot Handler (webhook-triggered)
- Claude Execution Helper (utility workflow)

## Implementation Guidelines

### When Working on Tech LEAD

1. **Maintain Separation of Concerns**
   - Tech LEAD makes decisions, it doesn't code
   - @claude implements
   - @claude-test validates
   - @claude-review quality checks

2. **Workflow Management**
   - ALWAYS refactor existing workflows - DO NOT create new versions
   - Edit files in place, don't create -fixed, -v2, -updated versions
   - Use the original filenames and update them directly
   - Example: Edit `telegram-bot-handler.json`, don't create `telegram-bot-handler-fixed.json`

3. **Claude CLI Integration**
   - Always use `claude` command, NOT `claude code`
   - Format: `echo "$JSON" | claude --prompt "..."`
   - Output should be JSON for parsing

3. **GitHub Workflow Triggers**
   - @claude: Manual trigger via comment
   - @claude-test: Manual trigger, then autonomous (5 attempts)
   - @claude-review: AUTO-triggers on PR (never manual)

4. **Database Schema**
   - projects_table: Project configuration
   - decisions_log: All Claude decisions
   - work_log: GitHub workflow executions

5. **Error Handling**
   - Always escalate to PM when stuck
   - Log all decisions to NocoDB
   - Graceful degradation on failures

### Code Style for n8n Workflows

```javascript
// Use clear node names
"Main Orchestrator - Fetch Issues"
"Claude Decision - Select Issue"
"Telegram - PM Approval"

// Always validate Claude responses
if (!claude_response.selected_issue) {
  throw new Error("Claude did not select an issue");
}

// Use structured data
const context = {
  role: "Tech LEAD",
  task: "analyze_issues",
  data: issues
};
```

### Prompt Engineering

When creating prompts for Tech LEAD's Claude brain:

```javascript
{
  "system": "You are Tech LEAD, an intelligent orchestrator",
  "context": {
    "repository": "...",
    "current_state": "...",
    "project_goals": "..."
  },
  "task": "specific_decision_type",
  "output_format": "JSON with specific structure"
}
```

### Testing Strategy

1. **Component Testing**: Test each workflow individually
2. **Integration Testing**: Full cycle on test issues
3. **PM Simulation**: Test Telegram interactions
4. **Claude CLI Verification**: Ensure prompts return valid JSON

### PR Requirements

For PRs to Tech LEAD:

1. **Workflow Changes**
   - Export workflow JSON
   - Document node modifications
   - Test in isolation first

2. **Claude Prompts**
   - Include example input/output
   - Document decision criteria
   - Test edge cases

3. **Documentation**
   - Update README if adding features
   - Document new Telegram commands
   - Add troubleshooting for new issues

### Security Considerations

- Never hardcode credentials
- Use n8n credential store
- Validate all GitHub webhook payloads
- Sanitize Claude responses before executing
- Rate limit Telegram commands

### Performance Optimization

- Cache GitHub API responses when possible
- Batch NocoDB operations
- Use webhook triggers over polling where available
- Implement exponential backoff for retries

## Technical Notes

### Docker Commands
- Use `docker compose` (no hyphen) - the hyphenated `docker-compose` is outdated
- Example: `docker compose up -d`, `docker compose down`

## Development Workflow

### Adding New Features

1. Create issue with clear requirements
2. Implement in feature branch
3. Test with mock data first
4. Integration test with real GitHub repo
5. Document in README
6. Submit PR with comprehensive description

### Debugging

1. Check n8n execution logs
2. Verify Claude CLI output format
3. Inspect NocoDB decision logs
4. Review Telegram bot messages
5. Examine GitHub Action logs

## Common Patterns

### Decision Making Pattern
```javascript
// 1. Gather context
const context = await gatherProjectContext();

// 2. Ask Claude
const decision = await askClaude(context, task);

// 3. Get PM approval
const approved = await getPMApproval(decision);

// 4. Execute
if (approved) {
  await executeDecision(decision);
}

// 5. Log
await logDecision(decision, approved);
```

### Error Escalation Pattern
```javascript
try {
  // Attempt operation
} catch (error) {
  // Log to NocoDB
  await logError(error);

  // Notify PM
  await telegram.send(`Error: ${error.message}`);

  // Wait for instructions
  const instructions = await waitForPM();
}
```

## Resources

- [n8n Documentation](https://docs.n8n.io)
- [Claude CLI Guide](https://claude.ai/docs)
- [NocoDB API](https://docs.nocodb.com/developer-resources/rest-apis)
- [Telegram Bot API](https://core.telegram.org/bots/api)
- [GitHub REST API](https://docs.github.com/rest)

## Support

For questions or issues:
1. Check existing GitHub issues
2. Review decision logs in NocoDB
3. Ask in project Telegram channel
4. Create detailed bug report with logs

---

Remember: Tech LEAD is about intelligent orchestration, not implementation. Keep the focus on strategic decisions and coordination.