# techLEAD v2

**Autonomous project orchestration powered by Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/Lucasmind/techLEAD)

---

## Overview

techLEAD v2 is an AI-powered technical leader that autonomously manages software development workflows. Built natively on Claude Code, it makes strategic decisions, coordinates GitHub Actions runners, and ensures high-quality code delivery.

### What techLEAD Does

- ✅ **Analyzes and prioritizes issues** based on project context
- ✅ **Coordinates implementation** via @claude GitHub Actions runner
- ✅ **Builds comprehensive tests** using test-builder subagent
- ✅ **Manages code review** with @claude-review integration
- ✅ **Validates quality** before merge with final-validator
- ✅ **Maintains project memory** and learns from patterns

### What techLEAD Doesn't Do

- ❌ **Write implementation code** (delegates to @claude runner)
- ❌ **Make decisions without PM approval** (checkpoints at key decisions)
- ❌ **Modify production without validation** (comprehensive pre-merge checks)

---

## Quick Start

### Two Installation Modes

**techLEAD supports two ways to run GitHub Actions:**

| Mode | Best For | Setup Time | Cost |
|------|----------|------------|------|
| **GitHub-hosted** | Beginners, quick start | 5 minutes | Free tier available |
| **Self-hosted** | Advanced users, full control | 20 minutes | Free (uses your hardware) |

---

### Option 1: GitHub-Hosted Runners (Recommended)

**No Docker required!** Uses GitHub's infrastructure.

#### Prerequisites
- Claude Code installed
- GitHub repository
- GitHub CLI (`gh`) authenticated

#### Installation

**Automated (Recommended):**
```bash
# Install techLEAD in your project
cd your-project-directory
curl -sSL https://raw.githubusercontent.com/Lucasmind/techLEAD/main/install.sh | bash
# Choose option 1 (GitHub-hosted)
```

**Manual:**
```bash
# Clone techLEAD
git clone https://github.com/Lucasmind/techLEAD.git
cd techLEAD

# Copy to your project
cp -r .techlead your-project/.techlead
cp -r .github/workflows your-project/.github/workflows
cp -r .claude your-project/.claude
cp CLAUDE.md your-project/CLAUDE.md

cd your-project

# Edit workflows to use GitHub-hosted runners
vim .github/workflows/claude.yml
# Change: runs-on: [self-hosted, ...] → runs-on: ubuntu-latest

vim .github/workflows/claude-code-review.yml
# Change: runs-on: [self-hosted, ...] → runs-on: ubuntu-latest

# Make scripts executable
chmod +x .techlead/*.sh .techlead/hooks/*.sh
```

#### Configure GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Create secret:
   - Name: `CLAUDE_CODE_OAUTH_TOKEN`
   - Value: Your Claude OAuth token (from `~/.claude/.credentials.json`)

#### Usage

```bash
# Open Claude Code in your project
cd your-project

# Initialize
/init

# Start techLEAD
/techlead
```

---

### Option 2: Self-Hosted Runner (Advanced)

**Full control, faster execution.** Runs locally via Docker.

#### Prerequisites
- Claude Code installed
- Docker and Docker Compose
- GitHub CLI (`gh`) authenticated
- GitHub Personal Access Token (repo + workflow scopes)

#### Installation

**Automated (Recommended):**
```bash
cd your-project-directory
curl -sSL https://raw.githubusercontent.com/Lucasmind/techLEAD/main/install.sh | bash
# Choose option 2 (Self-hosted)
# Follow the prompts
```

**Manual:**
```bash
# Clone techLEAD
git clone https://github.com/Lucasmind/techLEAD.git
cd techLEAD

# Copy to your project
cp -r .techlead your-project/.techlead
cp -r .github your-project/.github
cp -r .claude your-project/.claude
cp CLAUDE.md your-project/CLAUDE.md

cd your-project

# Make scripts executable
chmod +x .techlead/*.sh .techlead/hooks/*.sh .github/runner/start.sh
```

#### Setup Runner

```bash
cd .github/runner

# Configure environment
cp .env.example .env
vim .env
```

Update `.env`:
```bash
GITHUB_TOKEN=ghp_your_token_here
GITHUB_REPOSITORY=yourusername/yourrepo
CONTAINER_NAME=techlead-runner
RUNNER_LABELS=self-hosted,linux,x64,techlead
```

**Setup Claude credentials:**
```bash
mkdir -p claude-credentials
cp ~/.claude/.credentials.json claude-credentials/
```

**Start runner:**
```bash
docker-compose up -d --build

# Verify
docker logs techlead-runner
```

#### Configure GitHub Secrets

Same as Option 1 above (add `CLAUDE_CODE_OAUTH_TOKEN`).

#### Usage

```bash
# Open Claude Code in your project
cd your-project

# Update .techlead/config.json with your runner name
vim .techlead/config.json
# Set: "container_name": "techlead-runner"

# Initialize
/init

# Start techLEAD
/techlead
```

---

### What Happens When You Run `/techlead`

1. **Issue Selection**
   - Lists all open issues
   - Analyzes and categorizes
   - Gets your prioritization

2. **Implementation**
   - Posts @claude comment with guidance
   - Monitors runner via Docker logs (blocking)
   - Waits for completion

3. **Testing**
   - Spawns test-builder subagent
   - Creates comprehensive tests
   - Runs and validates

4. **Code Review**
   - Creates PR (auto-triggers @claude-review)
   - Spawns code-analyzer
   - Coordinates fixes

5. **Final Validation**
   - Spawns final-validator
   - Runs full test suite, linting, build
   - Runs E2E tests (Playwright)

6. **Merge**
   - Gets your approval
   - Generates detailed summary
   - Merges and cleans up

---

## Architecture

```
/techlead command
  ↓
Main techLEAD Session (Claude Code)
├── Decision Engine (native Claude reasoning)
├── Runner Monitoring (Docker logs, blocking)
├── Subagent Spawning (Task tool)
│   ├── test-builder (creates & validates tests)
│   ├── code-analyzer (interprets review feedback)
│   └── final-validator (pre-merge checks)
└── Memory Management (CLAUDE.md + state files)
```

### Key Components

| Component | Purpose | Implementation |
|-----------|---------|----------------|
| **techLEAD** | Strategic orchestration | Claude Code session |
| **@claude** | Code implementation | GitHub Actions runner |
| **@claude-review** | Code review | GitHub Actions runner (auto-triggered) |
| **test-builder** | Test creation | Subagent (Task tool) |
| **code-analyzer** | Review interpretation | Subagent (Task tool) |
| **final-validator** | Pre-merge validation | Subagent (Task tool) |
| **Monitor scripts** | Runner status | Docker log tailing (blocking) |
| **Memory system** | State & context | CLAUDE.md + JSON files |

---

## Workflow

### Single Issue Workflow

1. **Issue Selection**
   - List all open issues
   - Analyze by priority and type
   - Get PM prioritization

2. **Issue Analysis**
   - Read issue details
   - Check for conflicts with recent changes
   - Prepare comprehensive guidance for @claude runner

3. **Implementation**
   - Post @claude comment with guidance
   - Monitor via Docker logs (blocking)
   - Wait for completion

4. **Testing**
   - Pull implementation code
   - Analyze changes
   - Spawn test-builder subagent
   - Commit and push tests

5. **Pull Request**
   - Create PR with detailed summary
   - Auto-triggers @claude-review

6. **Code Review**
   - Monitor review completion
   - Spawn code-analyzer to interpret feedback
   - Present analysis to PM
   - Coordinate fixes if needed

7. **Final Validation**
   - Spawn final-validator
   - Run full test suite
   - Run Playwright E2E tests
   - Verify all GitHub checks pass

8. **Merge & Cleanup**
   - Generate detailed merge summary
   - Merge PR
   - Clean up branches
   - Close issue
   - Update memory

### Multi-Issue Sequence Workflow

Same as single issue, but automatically continues to next issue:
- Issue #1 → complete workflow → Issue #2 → complete workflow → Issue #3
- Progress tracked: "2/5 complete"
- PM can pause between issues
- Summary report at end of sequence

---

## Monitoring

techLEAD uses **Docker log monitoring** for real-time runner feedback:

### Monitor Scripts

```bash
# Monitor implementation runner
.techlead/monitor.sh implement

# Monitor code review
.techlead/monitor.sh review

# Monitor tests
.techlead/monitor.sh test
```

### How It Works

```
techLEAD posts @claude comment
  ↓
techLEAD runs: .techlead/monitor.sh implement
  ↓
Claude Code BLOCKS (waits for script to exit)
  ↓
Script tails Docker logs: docker logs -f <container>
  ↓
Detects: "Running job: claude"
Detects: "Job claude completed with result: Succeeded"
  ↓
Script exits with code 0 (success) or 1 (failure)
  ↓
Control returns to techLEAD
  ↓
techLEAD continues workflow automatically
```

**Benefits:**
- ✅ Real-time visibility
- ✅ No polling overhead
- ✅ Guaranteed continuation
- ✅ Works offline (local runner)

---

## Memory & State

### File Structure

```
.techlead/
├── config.json                  # techLEAD settings
├── monitor-runner.sh            # Docker log monitor (blocking)
├── monitor.sh                   # Wrapper (reads config)
├── workflow_state.json          # Current workflow state (runtime)
├── decisions_log.jsonl          # Historical decisions
├── work_log.jsonl               # Execution history
├── github_ops.log               # GitHub operations log
└── workflow_state.log           # State change log
```

### Resume Capability

If workflow is interrupted:

1. **State saved** to workflow_state.json after each step
2. **On restart**, /techlead checks for existing state
3. **If recent** (<24h): Offers to resume from last step
4. **If stale** (>24h): Archives and starts fresh

**Example:**

```
You: /techlead

techLEAD: Found in-progress workflow:
- Issue #42 (OAuth implementation)
- Progress: 15/30 steps (50%)
- Last updated: 1 hour ago
- Current step: Monitoring @claude runner

Options:
A) Resume from where we left off
B) Start fresh (discard progress)

What would you like to do?
```

### Memory Files

| File | Purpose | Format |
|------|---------|--------|
| **CLAUDE.md** | Project context, patterns, standards | Markdown (auto-loaded) |
| **workflow_state.json** | Current state (issue, step, checklist) | JSON (runtime) |
| **decisions_log.jsonl** | Decision history with rationale | JSONL (append-only) |
| **work_log.jsonl** | Execution events, subagent completions | JSONL (append-only) |

---

## Configuration

### .techlead/config.json

```json
{
  "version": "2.0.0",
  "runner": {
    "type": "docker",
    "container_name": "your-runner-name",  // <- UPDATE THIS
    "jobs": {
      "implement": "claude",
      "review": "claude-review",
      "test": "claude-test"
    }
  },
  "monitoring": {
    "timeout_seconds": 300,
    "show_detailed_logs": false
  },
  "workflow": {
    "auto_continue_on_success": true,
    "require_pm_approval": ["merge", "sequence_start"],
    "max_review_iterations": 3
  }
}
```

### .claude/config.json

Contains:
- `/techlead` slash command definition
- Hook configuration (PostToolUse, SubagentStop)
- Automatically loaded by Claude Code

**Do not edit unless you know what you're doing.**

---

## Subagents

### test-builder

**Purpose:** Create comprehensive tests for implementations

**Process:**
1. Analyzes implementation changes (`git diff`)
2. Reviews existing test patterns
3. Creates tests following project patterns
4. Runs tests and iterates on failures (max 5 attempts)
5. Reports coverage and results

**Output:**
```json
{
  "test_files": ["src/__tests__/oauth.test.ts"],
  "tests_created": 15,
  "tests_passing": 15,
  "coverage_percent": 87,
  "success": true
}
```

### code-analyzer

**Purpose:** Interpret code review feedback intelligently

**Process:**
1. Reads all review comments
2. Categorizes each item:
   - **CRITICAL**: Must fix (security, bugs)
   - **IMPORTANT**: Should fix (best practices)
   - **OPTIONAL**: Nice to have
   - **IGNORE**: Not applicable
3. Provides implementation guidance
4. Estimates complexity

**Output:**
```json
{
  "critical": [
    {
      "comment": "Missing CSRF validation",
      "reason": "Security vulnerability",
      "approach": "Add csurf middleware",
      "complexity": "low"
    }
  ],
  "important": [...],
  "optional": [...]
}
```

### final-validator

**Purpose:** Comprehensive pre-merge validation

**Process:**
1. Runs full test suite
2. Executes linting
3. Runs build
4. Runs Playwright E2E tests (if available)
5. Verifies GitHub Actions checks

**Output:**
```json
{
  "tests": {"passed": 127, "failed": 0},
  "linting": {"errors": 0, "warnings": 0},
  "build": {"success": true},
  "e2e": {"passed": 8, "failed": 0},
  "overall_success": true
}
```

---

## Deployment to Your Project

### Option 1: Copy Scripts

```bash
# In your project directory
mkdir -p .techlead/hooks
cp /path/to/techLEAD/.techlead/*.sh .techlead/
cp /path/to/techLEAD/.techlead/hooks/*.sh .techlead/hooks/
cp /path/to/techLEAD/.techlead/config.json .techlead/

# Edit config with your runner name
vim .techlead/config.json

# Make executable
chmod +x .techlead/*.sh .techlead/hooks/*.sh

# Update CLAUDE.md with project context
vim CLAUDE.md
```

### Option 2: Use as Template

1. Fork this repository
2. Customize CLAUDE.md with your project specifics
3. Update `.techlead/config.json` with your runner
4. Add project-specific patterns to CLAUDE.md

---

## Troubleshooting

### Monitor script doesn't find container

```bash
# List containers
docker ps -a

# Update config with correct name
vim .techlead/config.json
# Set: "container_name": "your-runner-name"
```

### Workflow state becomes stale

```bash
# Archive old state
mv .techlead/workflow_state.json .techlead/archive/workflow_state_$(date +%Y%m%d).json

# Start fresh
/techlead
```

### Resume doesn't work

```bash
# Check state file
cat .techlead/workflow_state.json

# Verify timestamp is recent
# If too old, will auto-archive

# Manual resume:
# Edit workflow_state.json
# Set last_updated to current time
```

### Runner monitoring times out

**Cause:** Job name mismatch in config

**Solution:**
```bash
# Check actual job name in Docker logs
docker logs <container> | grep "Running job:"

# Update config.json with correct job name
vim .techlead/config.json
```

### Subagent fails

```bash
# Check logs
cat .techlead/work_log.jsonl

# Try spawning manually using Task tool
# Reduce scope or break into smaller tasks
# Adjust subagent prompt if needed
```

---

## Comparison: v1 vs v2

| Feature | v1 (n8n) | v2 (Claude Code) |
|---------|----------|------------------|
| **Platform** | n8n + Claude CLI | Claude Code native |
| **Decision Making** | JSON parsing | Native reasoning |
| **Monitoring** | GitHub API polling | Docker logs (real-time) |
| **State** | NocoDB database | Files (CLAUDE.md + JSON) |
| **PM Communication** | Telegram bot | Direct in Claude Code |
| **Resume** | None | Full state restoration |
| **Sequences** | Manual | Automated multi-issue |
| **Context** | Lost between calls | Maintained in session |
| **Setup** | Complex (5+ services) | Simple (Claude Code + runner) |

---

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Test thoroughly
4. Submit a pull request with detailed description

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

---

## License

MIT License - see [LICENSE](./LICENSE) for details

---

## Acknowledgments

- [Anthropic](https://www.anthropic.com/) for Claude AI
- [Claude Code](https://claude.com/claude-code) for the platform
- The open-source community

---

## Links

- **Documentation**: [CLAUDE.md](./CLAUDE.md) - AI implementation guidelines
- **Previous Version**: [techLEAD-v1](https://github.com/Lucasmind/techLEAD-v1) (archived)
- **Issues**: [GitHub Issues](https://github.com/Lucasmind/techLEAD/issues)

---

**Built with ❤️ using Claude Code**

**Version:** 2.0.0
**Status:** Production Ready
**Last Updated:** 2025-10-02
