# Changelog

All notable changes to techLEAD will be documented in this file.

## [1.1.0] - 2025-10-05

### Added

#### Upgrade System
- **Automatic upgrade detection** - Install script now detects existing installations
- **Smart upgrade mode** - Preserves user configuration while updating all components
- **Timestamped backups** - Every upgrade creates a backup for rollback
- **Config merging** - Uses jq to intelligently merge configurations

#### Autonomous Execution
- **Reduced PM interruptions** - techLEAD proceeds autonomously after initial approval
- **Sequence mode improvements** - Get approval once, execute entire sequence
- **Clear approval rules** - Documents when to ask PM vs. when to proceed
- **Branch synchronization** - Automatic local/remote branch sync after @claude creates branches

#### Smart Job Detection
- **Already-running job detection** - Monitors can join jobs already in progress
- **Completed job detection** - Instantly detects jobs that finished before monitoring started
- **Race condition handling** - Checks last 5 minutes of logs before waiting
- **Better timeout handling** - 5-minute timeout with clear error messages

#### Failure Handling
- **Graceful stop on failures** - STOP workflow immediately when monitor.sh returns exit code 1
- **Structured error reporting** - Reports what failed, provides logs, offers options
- **No autonomous recovery** - Waits for PM decision instead of guessing
- **Uncertainty handling** - Clear guidance on when to stop and ask

#### Permissions
- **Auto-configured permissions** - Install script creates `.claude/settings.local.json` automatically
- **Smart merging** - Merges permissions into existing settings files
- **No manual setup** - Users get working system out of the box

### Changed

#### Slash Command Format
- **Migrated to .md format** - `/techlead` now defined in `.claude/commands/techlead.md`
- **Removed from config.json** - No longer uses `slashCommands` array (Claude Code v2.0.8+)
- **Requires restart** - Must fully close and reopen Claude Code to load

#### Installation Flow
- **Upgrade-first approach** - Detects existing installations and offers upgrade
- **Three-option menu** - Upgrade, Reinstall, or Cancel
- **Better feedback** - Shows what's updated vs. what's preserved
- **Simplified instructions** - Clear restart requirements for slash command loading

#### Monitor Scripts
- **Immediate execution** - Start monitoring right after posting @claude comment
- **No check-ins** - Don't ask PM for confirmation before monitoring
- **Exit code checking** - Properly handle success (0) vs. failure (1)
- **Detailed logging** - Shows job detection, runtime, and completion status

### Fixed

- **Race condition** - Monitor script missing jobs that start immediately
- **Permission issues** - No longer requires manual permission configuration
- **Branch desync** - Ensures local branch matches remote after @claude creates it
- **Unnecessary check-ins** - Eliminated redundant PM confirmations
- **Config preservation** - Upgrades now preserve container names and custom settings

### Documentation

- **Upgrade section** in README.md - Full upgrade instructions and feature list
- **Autonomy rules** in CLAUDE.md - When to ask PM vs. proceed autonomously
- **Critical execution pattern** - Post comment → monitor immediately → check exit code
- **Branch synchronization** - How to sync local with remote branches
- **Failure handling** - What to do when jobs fail
- **Configuration files** - New section documenting .md vs. config.json approach

---

## [1.0.0] - 2025-10-03

### Initial Release

- **techLEAD orchestrator** - Autonomous project management via Claude Code
- **GitHub Actions integration** - @claude and @claude-review runners
- **Subagent system** - test-builder, code-analyzer, final-validator
- **Docker monitoring** - Blocking script for self-hosted runners
- **Memory system** - CLAUDE.md, workflow_state.json, decision logs
- **Three installation modes** - GitHub-hosted, Self-hosted, Orchestration-only
- **Resume capability** - Pick up interrupted workflows
- **State management** - Comprehensive workflow tracking

---

**Legend:**
- **Added** - New features
- **Changed** - Changes to existing functionality
- **Fixed** - Bug fixes
- **Documentation** - Documentation updates
