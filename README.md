# techLEAD

### **L**eadership **E**ngine for **A**I **D**evelopment

**Autonomous project orchestration powered by Claude Code**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](https://github.com/Lucasmind/techLEAD)

---

## A Quick Note

Hey! I built this for myself to speed up my own coding workflow. It's been working great for me, so I figured I'd share it. I'll update it sporadically as I need new features or find issues, but I'm not looking to heavily support or maintain this as a big project.

That said—if you spot problems, open an issue. Got a good idea? Open an issue. Fork it, modify it, make it your own. It's completely open and not particularly complex, but it seems to work pretty well.

Good vibes to you! ✌️

---

## Overview

techLEAD is an AI-powered technical leader that autonomously manages software development workflows. Built natively on Claude Code, it makes strategic decisions, coordinates GitHub Actions runners, and ensures high-quality code delivery.

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

## How It Works: A Typical Workflow

Here's what a day with techLEAD looks like, whether you're starting a new project or working on an existing codebase.

### 1. Planning Your Work

**Create issues with AI assistance:**
```bash
You: /techlead-issue

Claude: What would you like to create an issue for?

You: Add user authentication with JWT tokens

Claude: [Detects: Feature, Security-relevant]
Let me help you create a comprehensive feature issue...

[Conversational extraction of requirements]

✓ Issue #42 created: Add JWT authentication
  Labels: enhancement, security
  Related: Issue #38 (API endpoints)
```

**Benefits:**
- Consistent issue formatting across your team
- No forgotten requirements or edge cases
- Automatic linking of related work
- Testing requirements excluded (techLEAD handles this)

### 2. Starting Work

**Initialize techLEAD:**
```bash
You: /techlead

techLEAD: Checking for in-progress work... None found.

Found 5 open issues:
  #42 [enhancement, security] Add JWT authentication
  #43 [bug] Login form validation error
  #44 [enhancement] Add rate limiting
  ...

Would you like to:
  a) Work on a single issue
  b) Work on a sequence (multiple related issues)

You: Work on issue 42

techLEAD: Creating checkpoint: before-issue-42
Analyzing issue #42...

[Classifies as: Security Feature]
[Loads: security-fix.md guidance template]
[Populates with: requirements, affected files, patterns]

Ready to post guidance to @claude runner. Proceed? (yes/no)

You: yes
```

### 3. Autonomous Execution

**techLEAD orchestrates the workflow:**

```
techLEAD: ✓ Posted @claude comment with structured guidance
          ⏳ Monitoring implementation (blocking)...

[GitHub Actions runner starts in background]
@claude: Creating branch: issue-42-add-jwt-authentication
@claude: Installing dependencies...
@claude: Implementing JWT middleware...
@claude: Adding authentication routes...
@claude: ✓ Implementation complete

techLEAD: ✓ Implementation succeeded (12 minutes)
          Synchronizing local branch...
          ✓ Branch synced: issue-42-add-jwt-authentication

          Spawning test-builder subagent...

test-builder: Analyzing implementation changes...
test-builder: Found: AuthMiddleware, JWTService, AuthController
test-builder: Creating unit tests... ✓
test-builder: Creating integration tests... ✓
test-builder: Running tests... ✓ (coverage: 87%)
test-builder: Committing tests... ✓

techLEAD: ✓ Tests complete
          Creating pull request...

✓ PR #123 created: Add JWT authentication
  Auto-triggered @claude-review...
```

### 4. Code Review Loop

**Automated review and iteration:**

```
techLEAD: ⏳ Monitoring code review (blocking)...

@claude-review: Analyzing PR #123...
@claude-review: Found 3 issues:
  - CRITICAL: JWT secret hardcoded in middleware
  - IMPORTANT: Missing token expiration check
  - OPTIONAL: Consider using refresh tokens

techLEAD: ✓ Review complete
          Spawning code-analyzer subagent...

code-analyzer: Categorized feedback:
  🔴 CRITICAL (1): Security vulnerability
  🟡 IMPORTANT (1): Missing functionality
  ⚪ OPTIONAL (1): Enhancement suggestion

  Priority: Fix critical and important items
  Estimated time: 15 minutes

techLEAD: Posting fix request to @claude runner...
          ⏳ Monitoring implementation (blocking)...

@claude: Fixing issues...
@claude: - Moved JWT secret to environment variable
@claude: - Added token expiration validation
@claude: ✓ Fixes pushed

techLEAD: ✓ Fixes complete
          ⏳ Waiting for re-review (blocking)...

@claude-review: Re-analyzing PR #123...
@claude-review: ✓ All critical issues resolved
@claude-review: ✓ Approved for merge

techLEAD: ✓ Review clean (no changes requested)
```

### 5. Pre-Merge Validation

**Comprehensive quality checks:**

```
techLEAD: Spawning final-validator subagent...

final-validator: Running pre-merge validation...
final-validator: ✓ Unit tests passing (87% coverage)
final-validator: ✓ Integration tests passing
final-validator: ✓ Linting passed
final-validator: ✓ Build successful
final-validator: ✓ E2E tests passing (Playwright)
final-validator: ✓ GitHub checks passing

techLEAD: ✓ All validations passed

Ready to merge PR #123. Approve? (yes/no)

You: yes
```

### 6. Completion & Memory

**Merge and checkpoint:**

```
techLEAD: Merging PR #123... ✓
          Closing issue #42... ✓
          Creating checkpoint: after-issue-42
          Updating project memory...

✓ Issue #42 completed successfully
  - Implementation: 12 minutes
  - Testing: 8 minutes
  - Review & fixes: 15 minutes
  - Total: 35 minutes

Updated CLAUDE.md with learned patterns:
  - JWT authentication implementation
  - Environment variable pattern
  - Token expiration best practices

Continue with next issue? (yes/no)
```

### Key Interactions Explained

**techLEAD (Orchestrator)**
- Lives in your Claude Code session
- Makes strategic decisions
- Coordinates all actors
- Maintains project memory
- Monitors via Docker logs (self-hosted) or GitHub UI (cloud-hosted)

**@claude (Implementation Runner)**
- GitHub Actions runner (cloud or self-hosted)
- Receives structured guidance from techLEAD
- Writes implementation code
- Creates branches and commits
- Responds to fix requests

**@claude-review (Code Review Runner)**
- Auto-triggered on PR creation
- Analyzes code quality and security
- Categorizes issues by severity
- Re-reviews after fixes

**Subagents (Local)**
- `test-builder`: Creates comprehensive tests following project patterns
- `code-analyzer`: Interprets review feedback, prioritizes actions
- `final-validator`: Pre-merge quality gate (tests, linting, builds, E2E)

**Monitoring**

For **self-hosted runners**, techLEAD uses real-time Docker log monitoring:
```bash
# Automatically called by techLEAD
.techlead/monitor.sh implement  # Watches @claude
.techlead/monitor.sh review     # Watches @claude-review
```

For **GitHub-hosted runners**, monitor via:
- GitHub Actions UI (Repository → Actions tab)
- Command line: `gh run watch`

### Working in Sprints

**Multi-issue sequences:**

```bash
You: /techlead

techLEAD: Found 5 related issues tagged 'auth-sprint':
  #42 JWT authentication
  #44 Rate limiting
  #45 Session management

Work as sequence? (yes/no)

You: yes

techLEAD: Creating sequence checkpoint: before-seq-auth-sprint-20251009

          Sequence plan:
            1. Issue #42 - JWT authentication (estimated: 40 min)
            2. Issue #44 - Rate limiting (estimated: 30 min)
            3. Issue #45 - Session management (estimated: 25 min)

          I'll proceed autonomously through all issues.
          You'll see progress via checklist updates.
          I'll only stop for failures or critical decisions.

          Proceed? (yes/no)

You: yes

techLEAD: [Autonomously executes all 3 issues]

✓ Sequence complete (95 minutes total)
  Creating checkpoint: after-seq-auth-sprint-20251009

All changes merged to main. Authentication sprint complete! 🎉
```

### Rollback Protection

**Safe experimentation:**

If something goes wrong, rollback to any checkpoint:

```bash
You: /rollback

Claude: Available rollback points:
  - after-issue-42: Keep JWT auth, remove later work
  - before-seq-auth-sprint: Remove entire auth sprint
  - before-issue-42: Remove all auth work

You: Rollback to before-issue-42

Claude: This will:
  ✓ Keep: All work before issue #42
  ✗ Remove: JWT auth, rate limiting, session management

  Force push required. Confirm? (yes/no)

You: yes

Claude: ✓ Rolled back to before-issue-42
        Reopened issues: #42, #44, #45

Ready to start fresh!
```

---

## Quick Start

### Three Installation Modes

**techLEAD supports three installation modes:**

| Mode | Best For | Setup Time | Cost |
|------|----------|------------|------|
| **GitHub-hosted** | Beginners, quick start | 5 minutes | Free tier available |
| **Self-hosted** | Advanced users, full control | 20 minutes | Free (uses your hardware) |
| **Orchestration-only** | Existing GitHub Actions setup | 2 minutes | Free (uses your setup) |

---

### Option 1: GitHub-Hosted Runners (Recommended)

**No Docker required!** Uses GitHub's infrastructure.

⚠️ **Note:** With GitHub-hosted runners, the Docker log monitoring (`.techlead/monitor.sh`) won't work. You'll need to monitor workflow progress via GitHub Actions UI or `gh run watch`.

#### Prerequisites
- Claude Code installed
- GitHub repository
- GitHub CLI (`gh`) authenticated

#### Setup GitHub Actions with Claude

**Follow the official guide:**
📚 [Claude Code GitHub Actions Setup](https://docs.claude.com/en/docs/claude-code/github-actions)

This will guide you through:
1. Creating the `CLAUDE_CODE_OAUTH_TOKEN` secret
2. Setting up GitHub Actions workflows
3. Configuring permissions

#### Install techLEAD

**Automated (Recommended):**
```bash
# Install techLEAD in your project
cd your-project-directory

# Download installer
curl -sSL https://raw.githubusercontent.com/Lucasmind/techLEAD/main/install.sh -o install.sh
chmod +x install.sh

# Run installer (interactive)
./install.sh
# Choose option 1 (GitHub-hosted)

# Optional: Remove downloaded installer from project root
rm install.sh
```

**Note:** The installer is copied to `.techlead/install.sh` for reference. You can safely delete the downloaded copy from your project root.

**Manual:**
```bash
# Clone techLEAD
git clone https://github.com/Lucasmind/techLEAD.git
cd techLEAD

# Copy to your project
cp -r .techlead your-project/.techlead
cp -r .github/workflows your-project/.github/workflows
cp -r .claude your-project/.claude

cd your-project

# Append techLEAD guidelines to CLAUDE.md (if exists) or create new
if [ -f "CLAUDE.md" ]; then
  echo -e "\n---\n" >> CLAUDE.md
  cat /path/to/techLEAD/CLAUDE.md >> CLAUDE.md
else
  cp /path/to/techLEAD/CLAUDE.md CLAUDE.md
fi

# Edit workflows to use GitHub-hosted runners
vim .github/workflows/claude.yml
# Change: runs-on: [self-hosted, ...] → runs-on: ubuntu-latest

vim .github/workflows/claude-code-review.yml
# Change: runs-on: [self-hosted, ...] → runs-on: ubuntu-latest

# Make scripts executable
chmod +x .techlead/*.sh .techlead/hooks/*.sh
```

#### Usage

```bash
# Restart Claude Code (fully close and reopen)
# This is required for the /techlead command to load

# Start techLEAD
/techlead
```

**Monitoring workflows:**

Since Docker log monitoring doesn't work with GitHub-hosted runners, use:

```bash
# Watch workflow in real-time
gh run watch

# Or view in GitHub Actions UI
# Go to: Repository → Actions tab
```

---

### Option 2: Self-Hosted Runner (Advanced)

**Full control, faster execution.** Runs locally with real-time Docker log monitoring.

✅ **Advantage:** The `.techlead/monitor.sh` scripts work perfectly with self-hosted runners, giving you real-time job status via Docker logs.

#### Prerequisites
- Claude Code installed
- GitHub CLI (`gh`) authenticated
- Docker installed (for runner container)

#### Setup GitHub Actions with Claude

**Follow the official guide:**
📚 [Claude Code GitHub Actions Setup](https://docs.claude.com/en/docs/claude-code/github-actions)

This covers:
1. Creating the `CLAUDE_CODE_OAUTH_TOKEN` secret
2. Setting up GitHub Actions workflows
3. Configuring permissions

#### Setup Self-Hosted Runner

**Follow GitHub's official guide:**
📚 [Add Self-Hosted Runners](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)

This will guide you through:
1. Creating a runner token
2. Configuring the runner on your machine
3. Starting the runner

**Quick Docker Setup (Alternative):**

If you prefer a Docker-based runner, we provide a complete Docker setup:

```bash
cd your-project/.github/runner

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

See `.github/runner/README.md` for detailed Docker setup instructions.

#### Install techLEAD

**Automated (Recommended):**
```bash
cd your-project-directory

# Download installer
curl -sSL https://raw.githubusercontent.com/Lucasmind/techLEAD/main/install.sh -o install.sh
chmod +x install.sh

# Run installer (interactive)
./install.sh
# Choose option 2 (Self-hosted)
# Follow the prompts

# Optional: Remove downloaded installer from project root
rm install.sh
```

**Note:** The installer is copied to `.techlead/install.sh` for reference.

**Manual:**
```bash
# Clone techLEAD
git clone https://github.com/Lucasmind/techLEAD.git
cd techLEAD

# Copy to your project
cp -r .techlead your-project/.techlead
cp -r .github your-project/.github
cp -r .claude your-project/.claude

cd your-project

# Append techLEAD guidelines to CLAUDE.md (if exists) or create new
if [ -f "CLAUDE.md" ]; then
  echo -e "\n---\n" >> CLAUDE.md
  cat /path/to/techLEAD/CLAUDE.md >> CLAUDE.md
else
  cp /path/to/techLEAD/CLAUDE.md CLAUDE.md
fi

# Make scripts executable
chmod +x .techlead/*.sh .techlead/hooks/*.sh

# Configure runner container name (if using Docker monitoring)
vim .techlead/config.json
# Set: "container_name": "your-runner-name"
```

#### Usage

```bash
# Restart Claude Code (fully close and reopen)
# This is required for the /techlead command to load

# Start techLEAD
/techlead
```

**Note:** With automated installation, the script configures the container name for you.

**Monitoring workflows:**

With self-hosted runners, you get real-time monitoring:

```bash
# techLEAD automatically runs this when monitoring @claude runner:
.techlead/monitor.sh implement

# You'll see real-time Docker logs:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Monitoring GitHub Actions Runner
# Container: techlead-runner
# Job: claude
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# ✓ Job started (2025-10-02 18:05:00Z)
# Running... (this may take several minutes)
# ✓ SUCCESS (2025-10-02 18:12:30Z)
# Duration: 7m 30s
```

---

### Option 3: Orchestration-Only (Existing Setup)

**Already have Claude Code GitHub Actions?** Just add the orchestration layer.

This mode is perfect if you:
- ✅ Already have `@claude` and `@claude-review` workflows configured
- ✅ Already have runners set up (GitHub-hosted or self-hosted)
- ✅ Just want to add the techLEAD orchestration commands

#### What Gets Installed

- `/techlead` slash command
- State tracking hooks
- Subagents (test-builder, code-analyzer, final-validator)
- Memory system (CLAUDE.md + state files)

#### What Gets Skipped

- GitHub workflows (keeps your existing ones)
- Runner configuration (uses your existing runners)

#### Installation

**Automated:**
```bash
cd your-project-directory

# Download installer
curl -sSL https://raw.githubusercontent.com/Lucasmind/techLEAD/main/install.sh -o install.sh
chmod +x install.sh

# Run installer (interactive)
./install.sh
# Choose option 3 (Orchestration only)

# Optional: Remove downloaded installer from project root
rm install.sh
```

**Note:** The installer is copied to `.techlead/install.sh` for reference.

**Manual:**
```bash
# Clone techLEAD
git clone https://github.com/Lucasmind/techLEAD.git
cd techLEAD

# Copy only orchestration components
cp -r .techlead your-project/.techlead
cp -r .claude your-project/.claude

cd your-project

# Append techLEAD guidelines to CLAUDE.md (if exists) or create new
if [ -f "CLAUDE.md" ]; then
  echo -e "\n---\n" >> CLAUDE.md
  cat /path/to/techLEAD/CLAUDE.md >> CLAUDE.md
else
  cp /path/to/techLEAD/CLAUDE.md CLAUDE.md
fi

# Make scripts executable
chmod +x .techlead/*.sh .techlead/hooks/*.sh

# Configure runner container name (if using self-hosted Docker runner)
vim .techlead/config.json
# Set: "container_name": "your-runner-name"
```

#### Usage

```bash
# Restart Claude Code (fully close and reopen)
# This is required for the /techlead command to load

# Start techLEAD orchestration
/techlead
```

**Important:** Make sure your existing workflows have the `@claude` and `@claude-review` triggers configured properly.

**Note:** With automated installation, the script prompts for your runner container name if you're using Docker monitoring.

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

## Creating Issues

When creating GitHub issues for techLEAD to work on, follow these guidelines:

### What to Include

**DO include:**
- ✅ Clear description of the feature or bug
- ✅ Acceptance criteria (what defines "done")
- ✅ Use cases or problem statements
- ✅ Specific technical constraints (if any)
- ✅ API preferences or architectural guidance (if critical)

**DON'T include:**
- ❌ Testing requirements or test cases
- ❌ Detailed implementation steps (unless critical)
- ❌ Code snippets or solutions (let @claude decide)

### Why No Testing Requirements?

techLEAD's **test-builder subagent** automatically:
- Analyzes implementation changes
- Follows existing test patterns in your codebase
- Creates comprehensive tests (unit + integration)
- Aims for >80% coverage
- Iterates until tests pass

### AI-Assisted Issue Creation

Use the `/techlead-issue` command for AI-guided issue creation with automatic classification and formatting:

```bash
/techlead-issue
```

**Features:**
- **Conversational extraction** - Claude asks questions to gather structured information
- **Auto-classification** - Detects issue type (feature/bug/enhancement/security/refactoring/performance)
- **Template selection** - Uses appropriate GitHub issue template based on type
- **Related issue detection** - Searches for similar or related issues
- **Auto-prioritization** - Suggests labels and priority based on type
- **Sequence suggestion** - Detects when creating multiple related issues

**Example Session:**
```
You: /techlead-issue

Claude: What would you like to create an issue for?

You: We need rate limiting on the API

Claude: I've analyzed your request:
Type: Feature
Primary focus: API rate limiting

Let me help you create a feature issue.

1. What's the feature title?

You: Add rate limiting to API endpoints

Claude: Great!
2. Describe the feature in 1-2 sentences

You: Implement rate limiting to prevent API abuse and ensure fair usage

[... conversational extraction continues ...]

Claude: ✓ Issue #54 created successfully!

Title: Add rate limiting to API endpoints
Labels: enhancement, api
URL: https://github.com/user/repo/issues/54

Next steps:
  a) Start work now (/techlead)
  b) Create more issues
  c) Done
```

**Benefits:**
- ✅ Consistent issue formatting across your project
- ✅ Never forget critical information
- ✅ Automatic exclusion of testing requirements
- ✅ Smart linking of related issues
- ✅ Reduced cognitive load (just describe what you want)

**Example: Good Issue**
```markdown
## Description
Add rate limiting to API endpoints to prevent abuse

## Acceptance Criteria
- [ ] Limit: 100 requests per minute per IP
- [ ] Return 429 status when limit exceeded
- [ ] Include rate limit headers in response

## Implementation Notes
- Use existing Redis instance for rate tracking
```

**Example: Avoid This**
```markdown
## Description
Add rate limiting

## Testing Requirements  ← Don't include this!
- Test rate limit enforcement
- Test header responses
- Test Redis connection
...
```

### GitHub Issue Templates

This repository includes issue templates that automatically exclude testing sections:
- **Feature Request** (`.github/ISSUE_TEMPLATE/feature.md`)
- **Bug Report** (`.github/ISSUE_TEMPLATE/bug.md`)

These templates guide you to provide the right information for techLEAD.

### Guidance Templates

techLEAD uses structured guidance templates to communicate with the @claude runner. When analyzing an issue, techLEAD:

1. **Classifies the issue type** (feature/bug/enhancement/refactoring/security)
2. **Loads the appropriate template** from `.techlead/templates/guidance/`
3. **Populates placeholders** with issue-specific details
4. **Posts the guidance** as an @claude comment

**Available Templates:**
- `feature-implementation.md` - New feature development
- `bug-fix.md` - Bug fixes with root cause analysis
- `enhancement.md` - Improvements to existing features
- `refactoring.md` - Code restructuring without behavior changes
- `security-fix.md` - Security vulnerability remediation

**Benefits:**
- ✅ Consistent, structured communication
- ✅ Comprehensive context for @claude runner
- ✅ Clear acceptance criteria and checklists
- ✅ Automatic exclusion of testing requirements
- ✅ Standardized branch naming and workflow

**Template Structure:**
```markdown
@claude

# {Issue Type}: {TITLE}

## Context
{BACKGROUND}

## Requirements
{ACCEPTANCE_CRITERIA}

## Technical Approach
{IMPLEMENTATION_STRATEGY}

## Definition of Done
- [ ] Implementation matches all acceptance criteria
- [ ] Code follows existing project patterns
- [ ] Ready for test-builder to create comprehensive tests

## Instructions
Please implement this {type} following the technical approach outlined above.
Create a branch `{BRANCH_NAME}` and make the necessary changes.
```

These templates ensure @claude receives clear, actionable guidance for every issue.

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
- Hook configuration (PostToolUse, SubagentStop)
- Automatically loaded by Claude Code on startup

**Do not edit unless you know what you're doing.**

### .claude/commands/techlead.md

Contains:
- `/techlead` slash command definition
- Loaded by Claude Code on startup
- **Requires full restart** (close and reopen) to load changes

**Note:** Claude Code v2.0.8+ uses `.md` files in `.claude/commands/` for slash commands instead of `config.json`.

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

## Rollback & Recovery

techLEAD creates checkpoint tags to enable granular rollback to any point in your workflow.

### Checkpoint System

**Before any work starts:**
- Single issue: `before-issue-42`
- Sequence: `before-seq-auth-20251005-1800`

**After each successful merge:**
- Issue checkpoint: `after-issue-42`
- Sequence completion: `after-seq-auth-20251005-2100`

### Rollback Options

#### 1. Rollback Entire Sequence

```bash
# Removes all work from sequence
git reset --hard before-seq-auth-20251005-1800
git push --force origin main
gh issue reopen 42 43 44 45 46
```

#### 2. Partial Rollback (Keep Some Work)

```bash
# Example: Keep first 3 issues, remove last 2
git reset --hard after-issue-44
git push --force origin main
gh issue reopen 45 46
```

**Available rollback points:**
- `after-issue-42` - Keep issue 42 only
- `after-issue-43` - Keep issues 42-43
- `after-issue-44` - Keep issues 42-44
- `after-issue-45` - Keep issues 42-45

#### 3. Single Issue Rollback

```bash
# Remove work from issue 42
git reset --hard before-issue-42
git push --force origin main
gh issue reopen 42
```

### Using the /rollback Command

techLEAD provides an interactive rollback command:

```bash
# In Claude Code
/rollback
```

**Workflow:**
1. techLEAD analyzes workflow_state.json
2. Shows rollback options with impact
3. You select which checkpoint to restore
4. techLEAD shows detailed plan
5. You confirm with "yes"
6. techLEAD executes rollback and reopens issues

**Example:**
```
Sequence: OAuth Implementation
Completed: 5/5 issues

Rollback Options:
  1) Entire sequence - removes all 5 issues
  2) After issue #42 - keeps login, removes 4 others
  3) After issue #43 - keeps login + signup, removes 3 others
  4) After issue #44 - keeps first 3, removes 2 others
  5) After issue #45 - keeps first 4, removes logout only

Select option (1-5 or cancel): 4

⚠️ This will:
- Reset main to: after-issue-44
- Remove commits: 2
- Reopen issues: #45, #46
- Require force push

Continue? (yes/no): yes

✓ Rollback complete
✓ Issues reopened: #45, #46
```

### Safety Features

**Recovery from Accidental Rollback:**
```bash
# Git reflog keeps history for ~90 days
git reflog
git reset --hard HEAD@{1}  # Undo the rollback
git push --force origin main
```

**Requirements:**
- Force push permissions on main branch
- Team coordination (ensure no active work)
- PM approval for rollback execution

### Alternative: Revert Instead of Reset

If force push is not allowed or safe:

```bash
# Create revert commits (preserves history)
git revert <commit-range>
git push origin main  # No force push needed
```

**Trade-offs:**
- ✅ Safer (no history rewriting)
- ✅ No force push required
- ❌ More complex (potential conflicts)
- ❌ Less clean (revert commits in history)

### Best Practices

1. **Verify impact** before rollback (git log, git diff)
2. **Communicate** with team before force push
3. **Document reason** in decisions_log.jsonl
4. **Reopen issues** immediately after rollback
5. **Provide better guidance** when retrying

### When NOT to Rollback

- Others have built work on top of current main
- Production depends on current state
- Only minor fixes needed (use regular PR instead)
- Unsure about full impact

Instead, consider:
- Targeted fix PRs for specific issues
- Feature flags to disable problematic features
- Manual revert of specific commits

---

## Upgrading

If you already have techLEAD installed and want to upgrade to the latest version:

```bash
# Run the install script again
.techlead/install.sh

# Or download the latest version
curl -sSL https://raw.githubusercontent.com/Lucasmind/techLEAD/main/install.sh -o /tmp/techlead-upgrade.sh
chmod +x /tmp/techlead-upgrade.sh
/tmp/techlead-upgrade.sh
```

**The installer will automatically detect your existing installation and offer:**

1. **Upgrade (recommended)** - Updates all components while preserving your configuration
2. **Reinstall** - Fresh installation with backups
3. **Cancel** - Exit without changes

### What Gets Updated

- ✅ Monitor scripts (smart job detection)
- ✅ /techlead command (autonomous execution)
- ✅ Hooks (state tracking)
- ✅ Subagents (test-builder, code-analyzer, final-validator)
- ✅ Permissions (auto-configured)

### What Gets Preserved

- ✅ Your container name and runtime config
- ✅ Memory files (decisions_log.jsonl, work_log.jsonl)
- ✅ CLAUDE.md customizations
- ✅ Workflow files (if Mode 3)

### After Upgrading

1. **Restart Claude Code** (fully close and reopen)
2. Run `/techlead` to use the updated orchestrator

The upgrade creates a timestamped backup in `.techlead/backup-upgrade-[timestamp]/` so you can roll back if needed.

---

## Uninstall

To remove techLEAD from your project:

```bash
# Run the uninstall script (automatically installed during setup)
.techlead/uninstall.sh
```

**If the uninstall script is missing:**
```bash
# Download it to the correct location
curl -sSL https://raw.githubusercontent.com/Lucasmind/techLEAD/main/uninstall.sh -o .techlead/uninstall.sh
chmod +x .techlead/uninstall.sh
.techlead/uninstall.sh
```

**What the uninstall script does:**

1. **Shows what will be removed:**
   - Directories: `.techlead/`, `.claude/agents/`, `.github/runner/`
   - Workflows: `claude.yml`, `claude-code-review.yml`
   - Files: Based on installation log

2. **Restores backups:**
   - `.backup.CLAUDE.md` → `CLAUDE.md`
   - `.claude/config.json.backup` → `.claude/config.json`

3. **Cleans up:**
   - Removes all techLEAD files and directories
   - Optionally removes techLEAD entries from `.gitignore`

4. **Lists remaining backups** you can manually delete

**Safe uninstall:**
- Always creates `.gitignore.backup` before modifying
- Asks for confirmation before removing files
- Preserves your original project files

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

**Version:** 1.1.0
**Status:** Production Ready
**Last Updated:** 2025-10-05
