# techLEAD Integration

This project uses **techLEAD** (Leadership Engine for AI Development) for autonomous project orchestration.

## Available Command

- `/techlead` - Start the techLEAD orchestrator for autonomous issue management and workflow coordination

## What techLEAD Does

techLEAD acts as an AI technical leader that:
- Analyzes and prioritizes GitHub issues
- Coordinates @claude and @claude-review runners
- Manages comprehensive testing via test-builder subagent
- Ensures quality through code-analyzer and final-validator subagents
- Maintains project state and decision history

## Configuration

techLEAD configuration is stored in `.techlead/config.json` and includes:
- Runner container name for Docker monitoring
- Workflow automation settings
- Memory system configuration

For full techLEAD documentation, see: https://github.com/Lucasmind/techLEAD
