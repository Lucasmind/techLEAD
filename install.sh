#!/bin/bash

# techLEAD Installation Script
# Installs techLEAD using traditional (non-plugin) method

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  techLEAD Installation (Traditional)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} For plugin installation, use: ${GREEN}/plugin install techlead${NC}"
echo ""

# Check if running via pipe (curl | bash)
if [ ! -t 0 ]; then
    echo -e "${RED}ERROR: This script cannot be run via pipe (curl | bash)${NC}"
    echo ""
    echo "Please run manually instead:"
    echo "  git clone https://github.com/RobAntunes/techLEAD.git"
    echo "  cd techLEAD"
    echo "  ./install.sh"
    echo ""
    exit 1
fi

# Detect script location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if we're in techLEAD repo
if [ ! -f "$SCRIPT_DIR/.claude-plugin/plugin.json" ]; then
    echo -e "${RED}ERROR: Must run from techLEAD repository directory${NC}"
    exit 1
fi

# Detect if we're in source repo or target project
IS_SOURCE_REPO=false
if [ -f "uninstall.sh" ] && [ -f ".claude-plugin/plugin.json" ]; then
    IS_SOURCE_REPO=true
fi

# If in source repo, ask for target directory
if [ "$IS_SOURCE_REPO" = true ]; then
    echo -e "${YELLOW}Running from techLEAD repository${NC}"
    echo "This will install techLEAD to another project directory."
    echo ""
    read -p "Enter target project directory: " TARGET_DIR

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}Error: Directory $TARGET_DIR does not exist${NC}"
        exit 1
    fi

    TECHLEAD_SOURCE="$SCRIPT_DIR"
    cd "$TARGET_DIR"
fi

# Check for existing installation
if [ -f ".techlead/install.log" ]; then
    echo ""
    echo -e "${YELLOW}Existing installation detected${NC}"
    echo ""
    read -p "Reinstall? This will backup existing files. (y/n): " REINSTALL

    if [ "$REINSTALL" != "y" ]; then
        echo "Installation cancelled."
        exit 0
    fi

    # Backup existing installation
    BACKUP_DIR=".techlead/backup-$(date +%Y%m%d-%H%M%S)"
    echo "Creating backup: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -r .claude "$BACKUP_DIR/" 2>/dev/null || true
    cp -r .techlead "$BACKUP_DIR/" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}Installing techLEAD...${NC}"
echo ""

# 1. Copy Claude Code configuration structure
echo "📦 Installing Claude Code components..."
mkdir -p .claude/{commands,agents}

if [ -z "$TECHLEAD_SOURCE" ]; then
    TECHLEAD_SOURCE="$SCRIPT_DIR"
fi

# Copy commands, agents, and hooks
cp "$TECHLEAD_SOURCE/commands"/* .claude/commands/
cp "$TECHLEAD_SOURCE/agents"/* .claude/agents/

echo "✓ Commands installed (/techlead, /techlead-issue, /techlead-setup, /rollback)"
echo "✓ Agents installed (test-builder, code-analyzer, final-validator)"

# 2. Set up hooks configuration
echo ""
echo "🪝 Configuring hooks..."

if [ -f ".claude/config.json" ]; then
    echo -e "${YELLOW}Warning: .claude/config.json exists. Manual merge may be needed.${NC}"
    cp .claude/config.json .claude/config.json.backup
else
    # Create hooks configuration
    cat > .claude/config.json <<'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "TodoWrite",
        "hooks": [
          {
            "type": "command",
            "command": ".techlead/hooks/save-workflow-state.sh"
          }
        ]
      },
      {
        "matcher": "Bash.*gh (issue|pr)",
        "hooks": [
          {
            "type": "command",
            "command": ".techlead/hooks/github-state-sync.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "test-builder|code-analyzer|final-validator",
        "hooks": [
          {
            "type": "command",
            "command": ".techlead/hooks/log-subagent-completion.sh"
          }
        ]
      }
    ]
  }
}
EOF
    echo "✓ Hooks configured"
fi

# 3. Configure permissions
echo ""
echo "🔐 Configuring permissions..."

if [ -f ".claude/settings.local.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        TEMP_FILE=$(mktemp)
        jq '.permissions.allow += [".techlead/monitor.sh*", "Bash(.techlead/monitor.sh*)"] | .permissions.allow |= unique' .claude/settings.local.json > "$TEMP_FILE"
        mv "$TEMP_FILE" .claude/settings.local.json
        echo "✓ Permissions updated"
    else
        echo -e "${YELLOW}Warning: jq not found. Please manually add permissions.${NC}"
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

# 4. Run finalsetup.sh to complete installation
echo ""
echo "🚀 Running final setup..."
echo ""

bash "$TECHLEAD_SOURCE/scripts/finalsetup.sh"

# 5. Copy workflow template
echo ""
echo "📋 Installing GitHub Actions workflow template..."
mkdir -p .github/workflows
cp "$TECHLEAD_SOURCE/.github/workflows/claude.yml.template" .github/workflows/

echo "✓ Workflow template copied to .github/workflows/claude.yml.template"

# 6. Copy issue templates
echo ""
echo "📝 Installing GitHub issue templates..."
if [ -d "$TECHLEAD_SOURCE/.github/ISSUE_TEMPLATE" ]; then
    mkdir -p .github/ISSUE_TEMPLATE
    cp "$TECHLEAD_SOURCE/.github/ISSUE_TEMPLATE"/* .github/ISSUE_TEMPLATE/ 2>/dev/null || true
    echo "✓ Issue templates installed"
fi

# 7. Update .gitignore
echo ""
echo "📄 Updating .gitignore..."

if [ -f ".gitignore" ]; then
    if ! grep -q ".techlead/workflow_state.log" .gitignore; then
        cat >> .gitignore <<'EOF'

# techLEAD runtime state
.techlead/workflow_state.log
.techlead/install.log
.github/runner/.env
.github/runner/claude-credentials/

# techLEAD backups
.techlead/backup-*
.backup.*
EOF
        echo "✓ .gitignore updated"
    else
        echo "✓ .gitignore already configured"
    fi
fi

# Create install log
mkdir -p .techlead
cat > .techlead/install.log <<EOF
# techLEAD Installation Log
# Created: $(date)
# Method: Traditional install (not plugin)
# Version: 1.2.0
EOF

# Final summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Installed components:"
echo "  ✓ Slash commands (/techlead, /techlead-issue, /techlead-setup, /rollback)"
echo "  ✓ Subagents (test-builder, code-analyzer, final-validator)"
echo "  ✓ Hooks (state tracking)"
echo "  ✓ Monitoring scripts (.techlead/monitor*.sh)"
echo "  ✓ State management (.techlead/ directory)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Set up GitHub Actions:"
echo "   ${GREEN}https://docs.claude.com/en/docs/claude-code/github-actions${NC}"
echo ""
echo "   Quick setup in Claude Code:"
echo "   ${GREEN}/install-github-app${NC}"
echo ""
echo "2. Copy workflow template:"
echo "   ${GREEN}cp .github/workflows/claude.yml.template .github/workflows/claude.yml${NC}"
echo ""
echo "3. Configure self-hosted runner (if using):"
echo "   Edit claude.yml and set runner label to 'techlead'"
echo ""
echo "4. ${YELLOW}IMPORTANT:${NC} Restart Claude Code completely (close and reopen)"
echo "   Slash commands only load on full restart"
echo ""
echo "5. Start orchestrating:"
echo "   ${GREEN}/techlead${NC}"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo "  • GitHub: https://github.com/RobAntunes/techLEAD"
echo "  • CLAUDE.md in repository for project instructions"
echo ""
echo -e "${GREEN}Happy orchestrating! 🤖${NC}"
echo ""
