#!/bin/bash

# techLEAD Installation Script
# Helps you set up techLEAD in your project

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  techLEAD Installation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detect if we're in the techLEAD repo or a target project
if [ -f ".techlead/config.json" ] && [ -f "CLAUDE.md" ] && grep -q "techLEAD" CLAUDE.md 2>/dev/null; then
    echo -e "${YELLOW}Detected: Running from techLEAD repository${NC}"
    echo "This script will help you copy techLEAD to another project."
    echo ""
    read -p "Enter target project directory: " TARGET_DIR

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}Error: Directory $TARGET_DIR does not exist${NC}"
        exit 1
    fi

    TECHLEAD_DIR="$(pwd)"
    cd "$TARGET_DIR"
else
    echo -e "${GREEN}Installing techLEAD in current directory:${NC} $(pwd)"
    echo ""

    # Ask where techLEAD repo is
    read -p "Enter path to techLEAD repository (or press Enter to clone): " TECHLEAD_DIR

    if [ -z "$TECHLEAD_DIR" ]; then
        echo "Cloning techLEAD repository..."
        git clone https://github.com/Lucasmind/techLEAD.git /tmp/techLEAD-install
        TECHLEAD_DIR="/tmp/techLEAD-install"
    fi
fi

# Verify techLEAD directory
if [ ! -f "$TECHLEAD_DIR/.techlead/config.json" ]; then
    echo -e "${RED}Error: $TECHLEAD_DIR is not a valid techLEAD repository${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Installation Mode${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Choose installation mode:"
echo ""
echo "  1) GitHub-hosted runners (recommended for beginners)"
echo "     - No setup required"
echo "     - Uses GitHub's infrastructure"
echo "     - Free tier available"
echo ""
echo "  2) Self-hosted runner (advanced)"
echo "     - Full control"
echo "     - Faster execution"
echo "     - Requires Docker"
echo ""
echo "  3) Orchestration only (already have GitHub Actions setup)"
echo "     - Only installs /techlead command, hooks, and subagents"
echo "     - Skips workflows and runner configuration"
echo "     - For users with existing Claude Code GitHub integration"
echo ""
read -p "Enter choice (1, 2, or 3): " RUNNER_MODE

# Create installation log
mkdir -p .techlead
cat > .techlead/install.log <<EOF
# techLEAD Installation Log
# Created: $(date)
# Mode: $RUNNER_MODE
#
# This file tracks what was installed for easy uninstall
EOF

# Copy techLEAD scripts
echo ""
echo -e "${GREEN}Copying techLEAD scripts...${NC}"

mkdir -p .techlead/hooks
cp -r "$TECHLEAD_DIR/.techlead"/*.sh .techlead/
cp -r "$TECHLEAD_DIR/.techlead/hooks"/*.sh .techlead/hooks/
cp "$TECHLEAD_DIR/.techlead/config.json" .techlead/

chmod +x .techlead/*.sh .techlead/hooks/*.sh

echo "installed:.techlead/" >> .techlead/install.log
echo "✓ Scripts copied"

# Copy workflows (skip for orchestration-only mode)
if [ "$RUNNER_MODE" != "3" ]; then
    echo -e "${GREEN}Copying GitHub workflows...${NC}"

    mkdir -p .github/workflows
    cp "$TECHLEAD_DIR/.github/workflows/claude.yml" .github/workflows/
    cp "$TECHLEAD_DIR/.github/workflows/claude-code-review.yml" .github/workflows/
    echo "installed:.github/workflows/claude.yml" >> .techlead/install.log
    echo "installed:.github/workflows/claude-code-review.yml" >> .techlead/install.log
fi

# Update workflows based on runner mode
if [ "$RUNNER_MODE" = "1" ]; then
    echo "  Configuring for GitHub-hosted runners..."

    # Update claude.yml
    sed -i.bak 's/runs-on: \[self-hosted, linux, x64, techlead\]/# runs-on: [self-hosted, linux, x64, techlead]/' .github/workflows/claude.yml
    sed -i.bak 's/# runs-on: ubuntu-latest/runs-on: ubuntu-latest/' .github/workflows/claude.yml

    # Update claude-code-review.yml
    sed -i.bak 's/runs-on: \[self-hosted, linux, x64, techlead\]/# runs-on: [self-hosted, linux, x64, techlead]/' .github/workflows/claude-code-review.yml
    sed -i.bak 's/# runs-on: ubuntu-latest/runs-on: ubuntu-latest/' .github/workflows/claude-code-review.yml

    rm .github/workflows/*.bak

    echo "✓ Workflows configured for GitHub-hosted runners"
else
    echo "  Configuring for self-hosted runner..."
    echo "✓ Workflows configured for self-hosted runner"

    # Copy runner configuration
    echo -e "${GREEN}Copying runner configuration...${NC}"
    mkdir -p .github/runner
    cp -r "$TECHLEAD_DIR/.github/runner"/* .github/runner/
    chmod +x .github/runner/start.sh
    echo "installed:.github/runner/" >> .techlead/install.log

    echo "✓ Runner configuration copied"
    echo ""
    echo -e "${YELLOW}Next steps for self-hosted runner:${NC}"
    echo "  1. cd .github/runner"
    echo "  2. cp .env.example .env"
    echo "  3. Edit .env with your GitHub token and repository"
    echo "  4. mkdir claude-credentials"
    echo "  5. cp ~/.claude/.credentials.json claude-credentials/"
    echo "  6. docker-compose up -d --build"
    echo ""
    echo "See .github/runner/README.md for detailed instructions"
fi

# Copy Claude Code configuration
echo ""
echo -e "${GREEN}Setting up Claude Code configuration...${NC}"

mkdir -p .claude

if [ -f ".claude/config.json" ]; then
    echo -e "${YELLOW}Warning: .claude/config.json already exists${NC}"
    read -p "Merge techLEAD config? (y/n): " MERGE_CONFIG

    if [ "$MERGE_CONFIG" = "y" ]; then
        echo "Creating backup..."
        cp .claude/config.json .claude/config.json.backup
        echo "backup:.claude/config.json.backup" >> .techlead/install.log
        echo "Please manually merge .claude/config.json with $TECHLEAD_DIR/.claude/config.json"
        echo "Backup saved to: .claude/config.json.backup"
    fi
else
    cp "$TECHLEAD_DIR/.claude/config.json" .claude/
    echo "installed:.claude/config.json" >> .techlead/install.log
    echo "✓ Claude Code config installed"
fi

# Copy subagents
echo ""
echo -e "${GREEN}Setting up techLEAD subagents...${NC}"

mkdir -p .claude/agents

if [ -d "$TECHLEAD_DIR/.claude/agents" ]; then
    cp -r "$TECHLEAD_DIR/.claude/agents"/* .claude/agents/ 2>/dev/null || true
    echo "installed:.claude/agents/" >> .techlead/install.log
    echo "✓ Subagents installed (test-builder, code-analyzer, final-validator)"
else
    echo -e "${YELLOW}Warning: No subagents found in techLEAD repository${NC}"
fi

# Initialize or update CLAUDE.md
echo ""
if [ -f "CLAUDE.md" ]; then
    echo -e "${YELLOW}CLAUDE.md already exists${NC}"
    read -p "Append techLEAD guidelines? (y/n): " APPEND_CLAUDE

    if [ "$APPEND_CLAUDE" = "y" ]; then
        echo "Creating backup..."
        cp CLAUDE.md .backup.CLAUDE.md
        echo "backup:.backup.CLAUDE.md" >> .techlead/install.log
        echo "" >> CLAUDE.md
        echo "---" >> CLAUDE.md
        echo "" >> CLAUDE.md
        cat "$TECHLEAD_DIR/CLAUDE.md" >> CLAUDE.md
        echo "modified:CLAUDE.md" >> .techlead/install.log
        echo "✓ techLEAD guidelines appended to CLAUDE.md"
        echo "✓ Backup saved to: .backup.CLAUDE.md"
    fi
else
    cp "$TECHLEAD_DIR/CLAUDE.md" CLAUDE.md
    echo "installed:CLAUDE.md" >> .techlead/install.log
    echo "✓ CLAUDE.md created"
fi

# Update .gitignore
echo ""
echo -e "${GREEN}Updating .gitignore...${NC}"

if [ -f ".gitignore" ]; then
    if ! grep -q ".techlead/runner_status.json" .gitignore; then
        echo "" >> .gitignore
        echo "# techLEAD runtime state" >> .gitignore
        echo ".techlead/runner_status.json" >> .gitignore
        echo ".techlead/workflow_state.log" >> .gitignore
        echo ".techlead/install.log" >> .gitignore
        echo ".github/runner/.env" >> .gitignore
        echo ".github/runner/claude-credentials/" >> .gitignore
        echo "" >> .gitignore
        echo "# techLEAD installation backups" >> .gitignore
        echo ".backup.*" >> .gitignore
        echo "modified:.gitignore" >> .techlead/install.log
        echo "✓ .gitignore updated"
    else
        echo "✓ .gitignore already configured"
    fi
else
    cp "$TECHLEAD_DIR/.gitignore" .gitignore
    echo "installed:.gitignore" >> .techlead/install.log
    echo "✓ .gitignore created"
fi

# Update .techlead/config.json with runner name
echo ""
if [ "$RUNNER_MODE" = "2" ] || [ "$RUNNER_MODE" = "3" ]; then
    echo "Do you use a self-hosted runner with Docker?"
    if [ "$RUNNER_MODE" = "3" ]; then
        read -p "Configure Docker monitoring? (y/n): " USE_DOCKER
    else
        USE_DOCKER="y"
    fi

    if [ "$USE_DOCKER" = "y" ]; then
        read -p "Enter your runner container name (default: techlead-runner): " CONTAINER_NAME
        CONTAINER_NAME=${CONTAINER_NAME:-techlead-runner}

        # Update config
        jq --arg name "$CONTAINER_NAME" '.runner.container_name = $name' .techlead/config.json > .techlead/config.json.tmp
        mv .techlead/config.json.tmp .techlead/config.json

        echo "✓ Updated .techlead/config.json with container name: $CONTAINER_NAME"
    else
        echo "✓ Skipping Docker monitoring configuration"
    fi
fi

# Create memory files
echo ""
echo -e "${GREEN}Creating memory files...${NC}"

touch .techlead/decisions_log.jsonl
touch .techlead/work_log.jsonl
touch .techlead/github_ops.log
touch .techlead/workflow_state.log

echo "✓ Memory files created"

# Final summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$RUNNER_MODE" = "1" ]; then
    echo "GitHub-hosted runner mode configured."
    echo ""
    echo "Next steps:"
    echo "  1. Commit and push the changes to GitHub"
    echo "  2. Add CLAUDE_CODE_OAUTH_TOKEN secret to your repository:"
    echo "     Go to: Settings → Secrets and variables → Actions"
    echo "     Create secret: CLAUDE_CODE_OAUTH_TOKEN"
    echo "  3. Open Claude Code in this directory"
    echo "  4. Run: /techlead"
elif [ "$RUNNER_MODE" = "2" ]; then
    echo "Self-hosted runner mode configured."
    echo ""
    echo "Next steps:"
    echo "  1. Set up the runner (see instructions above)"
    echo "  2. Add CLAUDE_CODE_OAUTH_TOKEN secret to your repository"
    echo "  3. Commit and push the changes to GitHub"
    echo "  4. Open Claude Code in this directory"
    echo "  5. Run: /techlead"
else
    echo "Orchestration-only mode configured."
    echo ""
    echo "Installed components:"
    echo "  ✓ /techlead slash command"
    echo "  ✓ Post-tool use hooks (state tracking)"
    echo "  ✓ Subagents (test-builder, code-analyzer, final-validator)"
    echo "  ✓ Memory system (CLAUDE.md + state files)"
    echo ""
    echo "Skipped:"
    echo "  • GitHub workflows (using your existing setup)"
    echo "  • Runner configuration (using your existing runners)"
    echo ""
    echo "Next steps:"
    echo "  1. Ensure your existing @claude workflow is configured"
    echo "  2. Ensure your existing @claude-review workflow is configured"
    echo "  3. Commit and push the changes to GitHub"
    echo "  4. Open Claude Code in this directory"
    echo "  5. Run: /init to load configuration"
    echo "  6. Run: /techlead to start orchestration"
fi

echo ""
echo "For detailed documentation, see:"
echo "  - Main README: https://github.com/Lucasmind/techLEAD"
echo "  - Runner setup: .github/runner/README.md (if using self-hosted)"
echo ""
echo -e "${GREEN}Happy orchestrating! 🤖${NC}"
