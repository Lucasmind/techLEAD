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
echo "Choose runner mode:"
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
read -p "Enter choice (1 or 2): " RUNNER_MODE

# Copy techLEAD scripts
echo ""
echo -e "${GREEN}Copying techLEAD scripts...${NC}"

mkdir -p .techlead/hooks
cp -r "$TECHLEAD_DIR/.techlead"/*.sh .techlead/
cp -r "$TECHLEAD_DIR/.techlead/hooks"/*.sh .techlead/hooks/
cp "$TECHLEAD_DIR/.techlead/config.json" .techlead/

chmod +x .techlead/*.sh .techlead/hooks/*.sh

echo "✓ Scripts copied"

# Copy workflows
echo -e "${GREEN}Copying GitHub workflows...${NC}"

mkdir -p .github/workflows
cp "$TECHLEAD_DIR/.github/workflows/claude.yml" .github/workflows/
cp "$TECHLEAD_DIR/.github/workflows/claude-code-review.yml" .github/workflows/

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
        echo "Please manually merge .claude/config.json with $TECHLEAD_DIR/.claude/config.json"
        echo "Backup saved to: .claude/config.json.backup"
    fi
else
    cp "$TECHLEAD_DIR/.claude/config.json" .claude/
    echo "✓ Claude Code config installed"
fi

# Initialize or update CLAUDE.md
echo ""
if [ -f "CLAUDE.md" ]; then
    echo -e "${YELLOW}CLAUDE.md already exists${NC}"
    read -p "Append techLEAD guidelines? (y/n): " APPEND_CLAUDE

    if [ "$APPEND_CLAUDE" = "y" ]; then
        echo "" >> CLAUDE.md
        echo "---" >> CLAUDE.md
        echo "" >> CLAUDE.md
        cat "$TECHLEAD_DIR/CLAUDE.md" >> CLAUDE.md
        echo "✓ techLEAD guidelines appended to CLAUDE.md"
    fi
else
    cp "$TECHLEAD_DIR/CLAUDE.md" CLAUDE.md
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
        echo ".github/runner/.env" >> .gitignore
        echo ".github/runner/claude-credentials/" >> .gitignore
        echo "✓ .gitignore updated"
    else
        echo "✓ .gitignore already configured"
    fi
else
    cp "$TECHLEAD_DIR/.gitignore" .gitignore
    echo "✓ .gitignore created"
fi

# Update .techlead/config.json with runner name
echo ""
if [ "$RUNNER_MODE" = "2" ]; then
    read -p "Enter your runner container name (default: techlead-runner): " CONTAINER_NAME
    CONTAINER_NAME=${CONTAINER_NAME:-techlead-runner}

    # Update config
    jq --arg name "$CONTAINER_NAME" '.runner.container_name = $name' .techlead/config.json > .techlead/config.json.tmp
    mv .techlead/config.json.tmp .techlead/config.json

    echo "✓ Updated .techlead/config.json with container name: $CONTAINER_NAME"
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
else
    echo "Self-hosted runner mode configured."
    echo ""
    echo "Next steps:"
    echo "  1. Set up the runner (see instructions above)"
    echo "  2. Add CLAUDE_CODE_OAUTH_TOKEN secret to your repository"
    echo "  3. Commit and push the changes to GitHub"
    echo "  4. Open Claude Code in this directory"
    echo "  5. Run: /techlead"
fi

echo ""
echo "For detailed documentation, see:"
echo "  - Main README: https://github.com/Lucasmind/techLEAD"
echo "  - Runner setup: .github/runner/README.md (if using self-hosted)"
echo ""
echo -e "${GREEN}Happy orchestrating! 🤖${NC}"
