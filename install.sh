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

# Check if running via pipe (curl | bash)
if [ ! -t 0 ]; then
    echo -e "${RED}ERROR: This script cannot be run via pipe (curl | bash)${NC}"
    echo ""
    echo "Interactive prompts don't work properly when piped."
    echo ""
    echo "Please run manually instead:"
    echo "  curl -sSL https://raw.githubusercontent.com/Lucasmind/techLEAD/main/install.sh -o install.sh"
    echo "  chmod +x install.sh"
    echo "  ./install.sh"
    echo ""
    exit 1
fi

# Detect if we're in the techLEAD source repo
# Check for presence of source-only files (uninstall.sh in root + .techlead directory structure)
IS_SOURCE_REPO=false
if [ -f "uninstall.sh" ] && [ -f "install.sh" ] && [ -d ".techlead" ] && [ -d ".claude/agents" ] && [ ! -f ".techlead/install.log" ]; then
    # Additional check: look for git remote pointing to techLEAD
    if [ -d ".git" ]; then
        GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
        if echo "$GIT_REMOTE" | grep -q "techLEAD"; then
            IS_SOURCE_REPO=true
        fi
    fi
fi

if [ "$IS_SOURCE_REPO" = true ]; then
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
fi

# Check for existing installation BEFORE asking for source
if [ -f ".techlead/install.log" ] && [ "$IS_SOURCE_REPO" = false ]; then
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  Existing Installation Detected${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Found existing techLEAD installation."
    echo ""
    echo "Options:"
    echo "  1) Upgrade (recommended - preserves your config)"
    echo "  2) Reinstall (fresh install, creates backups)"
    echo "  3) Cancel"
    echo ""
    read -p "Enter choice (1, 2, or 3): " INSTALL_MODE_CHOICE

    if [ "$INSTALL_MODE_CHOICE" = "3" ]; then
        echo "Installation cancelled."
        exit 0
    elif [ "$INSTALL_MODE_CHOICE" = "1" ]; then
        # Upgrade mode
        echo ""
        echo -e "${GREEN}Starting upgrade...${NC}"

        # Create upgrade backup
        UPGRADE_BACKUP=".techlead/backup-upgrade-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$UPGRADE_BACKUP"

        echo "Creating backup: $UPGRADE_BACKUP"

        # Backup current scripts and config
        cp -r .techlead/*.sh "$UPGRADE_BACKUP/" 2>/dev/null || true
        cp -r .techlead/hooks "$UPGRADE_BACKUP/" 2>/dev/null || true
        cp .techlead/config.json "$UPGRADE_BACKUP/config.json.old" 2>/dev/null || true
        cp .claude/config.json "$UPGRADE_BACKUP/claude-config.json.old" 2>/dev/null || true
        cp .claude/commands/techlead.md "$UPGRADE_BACKUP/techlead.md.old" 2>/dev/null || true

        echo "✓ Backup created"
        echo ""

        # Update scripts
        echo -e "${GREEN}Updating techLEAD scripts...${NC}"
        cp "$TECHLEAD_DIR/.techlead"/*.sh .techlead/
        cp -r "$TECHLEAD_DIR/.techlead/hooks"/*.sh .techlead/hooks/
        chmod +x .techlead/*.sh .techlead/hooks/*.sh
        echo "✓ Scripts updated"

        # Merge config.json (preserve user settings)
        echo -e "${GREEN}Updating configuration...${NC}"
        if command -v jq >/dev/null 2>&1; then
            # Preserve container_name and other user customizations
            CONTAINER_NAME=$(jq -r '.runner.container_name // "techlead-runner"' .techlead/config.json)
            cp "$TECHLEAD_DIR/.techlead/config.json" .techlead/config.json
            jq --arg name "$CONTAINER_NAME" '.runner.container_name = $name' .techlead/config.json > .techlead/config.json.tmp
            mv .techlead/config.json.tmp .techlead/config.json
            echo "✓ Configuration updated (preserved your container name: $CONTAINER_NAME)"
        else
            echo -e "${YELLOW}Warning: jq not found, copying default config${NC}"
            cp "$TECHLEAD_DIR/.techlead/config.json" .techlead/config.json
            echo "  Please manually update .techlead/config.json with your container name"
        fi

        # Update Claude config (hooks)
        echo -e "${GREEN}Updating Claude Code hooks...${NC}"
        cp "$TECHLEAD_DIR/.claude/config.json" .claude/config.json
        echo "✓ Hooks updated"

        # Update slash command
        echo -e "${GREEN}Updating /techlead command...${NC}"
        mkdir -p .claude/commands
        cp "$TECHLEAD_DIR/.claude/commands/techlead.md" .claude/commands/
        echo "✓ /techlead command updated"

        # Update subagents
        echo -e "${GREEN}Updating subagents...${NC}"
        mkdir -p .claude/agents
        cp -r "$TECHLEAD_DIR/.claude/agents"/* .claude/agents/ 2>/dev/null || true
        echo "✓ Subagents updated"

        # Update permissions
        echo -e "${GREEN}Updating permissions...${NC}"
        if [ -f ".claude/settings.local.json" ]; then
            if command -v jq >/dev/null 2>&1; then
                TEMP_FILE=$(mktemp)
                jq '.permissions.allow += [".techlead/monitor.sh*", "Bash(.techlead/monitor.sh*)"] | .permissions.allow |= unique' .claude/settings.local.json > "$TEMP_FILE"
                mv "$TEMP_FILE" .claude/settings.local.json
                echo "✓ Permissions updated"
            else
                echo -e "${YELLOW}Warning: jq not found, cannot auto-update permissions${NC}"
                echo "  Please manually add to .claude/settings.local.json:"
                echo '    "allow": [".techlead/monitor.sh*", "Bash(.techlead/monitor.sh*)"]'
            fi
        else
            cat > .claude/settings.local.json <<'EOF'
{
  "permissions": {
    "allow": [
      ".techlead/monitor.sh*",
      "Bash(.techlead/monitor.sh*)"
    ],
    "deny": [],
    "ask": []
  }
}
EOF
            echo "✓ Permissions configured"
        fi

        # Update install/uninstall scripts
        cp "$TECHLEAD_DIR/install.sh" .techlead/
        cp "$TECHLEAD_DIR/uninstall.sh" .techlead/

        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✓ Upgrade Complete!${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "Updated components:"
        echo "  ✓ Monitor scripts (smart job detection)"
        echo "  ✓ /techlead command (autonomous execution)"
        echo "  ✓ Hooks (state tracking)"
        echo "  ✓ Subagents (test-builder, code-analyzer, final-validator)"
        echo "  ✓ Permissions (auto-configured)"
        echo ""
        echo "Preserved:"
        echo "  ✓ Your container name and config"
        echo "  ✓ Memory files (decisions_log.jsonl, work_log.jsonl)"
        echo "  ✓ CLAUDE.md customizations"
        echo ""
        echo "Backup location: $UPGRADE_BACKUP"
        echo ""
        echo -e "${YELLOW}Important:${NC}"
        echo "  1. Restart Claude Code (fully close and reopen)"
        echo "  2. Run: /techlead to use the updated orchestrator"
        echo ""
        echo -e "${GREEN}Happy orchestrating! 🤖${NC}"
        exit 0
    fi

    # If choice was 2 (reinstall), continue with normal installation
    echo ""
    echo -e "${YELLOW}Proceeding with fresh installation (backups will be created)...${NC}"
else
    # No existing installation - ask for techLEAD source location
    echo -e "${GREEN}Installing techLEAD in current directory:${NC} $(pwd)"
    echo ""

    # Ask where techLEAD repo is
    read -p "Enter path to techLEAD repository (or press Enter to clone): " TECHLEAD_DIR

    if [ -z "$TECHLEAD_DIR" ]; then
        echo "Cloning techLEAD repository..."
        # Clean up any stale clone directory
        rm -rf /tmp/techLEAD-install
        git clone https://github.com/Lucasmind/techLEAD.git /tmp/techLEAD-install
        TECHLEAD_DIR="/tmp/techLEAD-install"
    fi

    # Verify techLEAD directory
    if [ ! -f "$TECHLEAD_DIR/.techlead/config.json" ]; then
        echo -e "${RED}Error: $TECHLEAD_DIR is not a valid techLEAD repository${NC}"
        exit 1
    fi
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

# Validate runner mode selection
if [ "$RUNNER_MODE" != "1" ] && [ "$RUNNER_MODE" != "2" ] && [ "$RUNNER_MODE" != "3" ]; then
    echo -e "${RED}Error: Invalid selection. Please choose 1, 2, or 3.${NC}"
    exit 1
fi

# Check for existing GitHub Actions setup
echo ""
if [ -f ".github/workflows/claude.yml" ] || [ -f ".github/workflows/claude-code-review.yml" ] || [ -d ".github/runner" ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  WARNING: Existing GitHub Actions Setup Detected${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Found existing files:"
    [ -f ".github/workflows/claude.yml" ] && echo "  • .github/workflows/claude.yml"
    [ -f ".github/workflows/claude-code-review.yml" ] && echo "  • .github/workflows/claude-code-review.yml"
    [ -d ".github/runner" ] && echo "  • .github/runner/ (directory)"
    echo ""

    if [ "$RUNNER_MODE" = "3" ]; then
        echo -e "${GREEN}Mode 3 selected: Workflows will NOT be modified${NC}"
    else
        echo -e "${RED}Mode $RUNNER_MODE will OVERWRITE these files!${NC}"
        echo ""
        echo "Options:"
        echo "  1) Continue and create backups (recommended)"
        echo "  2) Switch to Mode 3 (orchestration-only, no workflow changes)"
        echo "  3) Cancel installation"
        echo ""
        read -p "Enter choice (1, 2, or 3): " OVERWRITE_CHOICE

        if [ "$OVERWRITE_CHOICE" = "3" ]; then
            echo "Installation cancelled."
            exit 0
        elif [ "$OVERWRITE_CHOICE" = "2" ]; then
            RUNNER_MODE="3"
            echo -e "${GREEN}Switched to Mode 3 (orchestration-only)${NC}"
        elif [ "$OVERWRITE_CHOICE" != "1" ]; then
            echo -e "${RED}Invalid choice. Installation cancelled.${NC}"
            exit 1
        fi
    fi
fi

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

# Copy install and uninstall scripts to .techlead for safe keeping
cp "$TECHLEAD_DIR/install.sh" .techlead/
cp "$TECHLEAD_DIR/uninstall.sh" .techlead/

chmod +x .techlead/*.sh .techlead/hooks/*.sh

echo "installed:.techlead/" >> .techlead/install.log
echo "✓ Scripts copied"

# Backup existing workflows and runner config
if [ "$RUNNER_MODE" != "3" ]; then
    BACKUP_DIR=".techlead/backup-$(date +%Y%m%d-%H%M%S)"
    NEEDS_BACKUP=false

    # Check what needs backing up
    if [ -f ".github/workflows/claude.yml" ] || [ -f ".github/workflows/claude-code-review.yml" ]; then
        NEEDS_BACKUP=true
    fi
    if [ -d ".github/runner" ]; then
        NEEDS_BACKUP=true
    fi

    if [ "$NEEDS_BACKUP" = true ]; then
        echo -e "${YELLOW}Creating backup of existing GitHub Actions setup...${NC}"
        mkdir -p "$BACKUP_DIR"

        # Backup workflows
        if [ -f ".github/workflows/claude.yml" ]; then
            mkdir -p "$BACKUP_DIR/workflows"
            cp ".github/workflows/claude.yml" "$BACKUP_DIR/workflows/"
            echo "backup:$BACKUP_DIR/workflows/claude.yml" >> .techlead/install.log
        fi
        if [ -f ".github/workflows/claude-code-review.yml" ]; then
            mkdir -p "$BACKUP_DIR/workflows"
            cp ".github/workflows/claude-code-review.yml" "$BACKUP_DIR/workflows/"
            echo "backup:$BACKUP_DIR/workflows/claude-code-review.yml" >> .techlead/install.log
        fi

        # Backup runner config
        if [ -d ".github/runner" ]; then
            cp -r ".github/runner" "$BACKUP_DIR/"
            echo "backup:$BACKUP_DIR/runner/" >> .techlead/install.log
        fi

        echo "✓ Backup created: $BACKUP_DIR"
    fi
fi

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
elif [ "$RUNNER_MODE" = "2" ]; then
    echo "  Configuring for self-hosted runner..."

    # Copy runner configuration
    echo -e "${GREEN}Copying runner configuration...${NC}"
    mkdir -p .github/runner
    cp -r "$TECHLEAD_DIR/.github/runner"/* .github/runner/
    chmod +x .github/runner/start.sh
    echo "installed:.github/runner/" >> .techlead/install.log

    echo "✓ Workflows configured for self-hosted runner"
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

# Configure permissions for monitor.sh
echo ""
echo -e "${GREEN}Configuring Claude Code permissions...${NC}"

if [ -f ".claude/settings.local.json" ]; then
    # File exists, need to merge permissions
    if command -v jq >/dev/null 2>&1; then
        # Use jq to merge permissions
        TEMP_FILE=$(mktemp)
        jq '.permissions.allow += [".techlead/monitor.sh*", "Bash(.techlead/monitor.sh*)"] | .permissions.allow |= unique' .claude/settings.local.json > "$TEMP_FILE"
        mv "$TEMP_FILE" .claude/settings.local.json
        echo "✓ Permissions merged into existing settings.local.json"
    else
        echo -e "${YELLOW}Warning: jq not found, cannot auto-merge permissions${NC}"
        echo "Please manually add to .claude/settings.local.json:"
        echo '  "permissions": {'
        echo '    "allow": [".techlead/monitor.sh*", "Bash(.techlead/monitor.sh*)"]'
        echo '  }'
    fi
else
    # Create new settings.local.json
    cat > .claude/settings.local.json <<'EOF'
{
  "permissions": {
    "allow": [
      ".techlead/monitor.sh*",
      "Bash(.techlead/monitor.sh*)"
    ],
    "deny": [],
    "ask": []
  }
}
EOF
    echo "installed:.claude/settings.local.json" >> .techlead/install.log
    echo "✓ Permissions configured for monitor.sh"
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

# Copy slash commands
echo ""
echo -e "${GREEN}Setting up techLEAD slash commands...${NC}"

mkdir -p .claude/commands

if [ -f "$TECHLEAD_DIR/.claude/commands/techlead.md" ]; then
    cp "$TECHLEAD_DIR/.claude/commands/techlead.md" .claude/commands/
    echo "installed:.claude/commands/techlead.md" >> .techlead/install.log
    echo "✓ /techlead command installed"
else
    echo -e "${YELLOW}Warning: No techlead.md command found in techLEAD repository${NC}"
fi

# Initialize or update CLAUDE.md
echo ""
if [ -f "CLAUDE.md" ]; then
    echo -e "${YELLOW}CLAUDE.md already exists${NC}"
    read -p "Add minimal techLEAD reference? (y/n): " APPEND_CLAUDE

    if [ "$APPEND_CLAUDE" = "y" ]; then
        echo "Creating backup..."
        cp CLAUDE.md .backup.CLAUDE.md
        echo "backup:.backup.CLAUDE.md" >> .techlead/install.log
        echo "" >> CLAUDE.md
        echo "---" >> CLAUDE.md
        echo "" >> CLAUDE.md
        cat "$TECHLEAD_DIR/.techlead/claude-snippet.md" >> CLAUDE.md
        echo "modified:CLAUDE.md" >> .techlead/install.log
        echo "✓ techLEAD reference added to CLAUDE.md (minimal)"
        echo "✓ Backup saved to: .backup.CLAUDE.md"
    fi
else
    echo -e "${YELLOW}No CLAUDE.md found${NC}"
    read -p "Create minimal CLAUDE.md with techLEAD reference? (y/n): " CREATE_CLAUDE

    if [ "$CREATE_CLAUDE" = "y" ]; then
        cp "$TECHLEAD_DIR/.techlead/claude-snippet.md" CLAUDE.md
        echo "installed:CLAUDE.md" >> .techlead/install.log
        echo "✓ Minimal CLAUDE.md created with techLEAD reference"
    else
        echo "✓ Skipped CLAUDE.md creation"
    fi
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
    echo "  3. Open Claude Code in this directory (or restart if already open)"
    echo "  4. Run: /techlead"
elif [ "$RUNNER_MODE" = "2" ]; then
    echo "Self-hosted runner mode configured."
    echo ""
    echo "Next steps:"
    echo "  1. Set up the runner (see instructions above)"
    echo "  2. Add CLAUDE_CODE_OAUTH_TOKEN secret to your repository"
    echo "  3. Commit and push the changes to GitHub"
    echo "  4. Open Claude Code in this directory (or restart if already open)"
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
    echo "  4. Restart Claude Code (fully close and reopen)"
    echo "  5. Run: /techlead to start orchestration"
fi

echo ""
echo "For detailed documentation, see:"
echo "  - Main README: https://github.com/Lucasmind/techLEAD"
echo "  - Runner setup: .github/runner/README.md (if using self-hosted)"
echo ""
echo -e "${YELLOW}Installed scripts:${NC}"
echo "  • .techlead/install.sh (for reference)"
echo "  • .techlead/uninstall.sh (to remove techLEAD)"
echo ""
echo -e "${YELLOW}To uninstall later:${NC}"
echo "  .techlead/uninstall.sh"
echo ""
echo -e "${GREEN}Happy orchestrating! 🤖${NC}"
