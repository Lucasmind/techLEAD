#!/bin/bash

# techLEAD Uninstall Script
# Removes techLEAD from your project

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  techLEAD Uninstall${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if techLEAD is installed
if [ ! -f ".techlead/config.json" ]; then
    echo -e "${RED}Error: techLEAD does not appear to be installed in this directory${NC}"
    exit 1
fi

# Check for installation log
if [ ! -f ".techlead/install.log" ]; then
    echo -e "${YELLOW}Warning: No installation log found${NC}"
    echo "This might be an older installation. Uninstall will proceed with best effort."
    echo ""
fi

# Show what will be removed
echo -e "${YELLOW}This will remove the following:${NC}"
echo ""
echo "Directories:"
[ -d ".techlead" ] && echo "  • .techlead/"
[ -d ".claude/agents" ] && echo "  • .claude/agents/"
[ -d ".github/runner" ] && echo "  • .github/runner/"

echo ""
echo "Files:"
[ -f ".claude/config.json" ] && echo "  • .claude/config.json (will restore backup if exists)"
[ -f ".github/workflows/claude.yml" ] && echo "  • .github/workflows/claude.yml"
[ -f ".github/workflows/claude-code-review.yml" ] && echo "  • .github/workflows/claude-code-review.yml"
[ -f "CLAUDE.md" ] && echo "  • CLAUDE.md (will restore backup if exists)"

echo ""
echo -e "${YELLOW}Backups found:${NC}"
if [ -f ".backup.CLAUDE.md" ]; then
    echo "  • .backup.CLAUDE.md (will be restored)"
else
    echo "  • No CLAUDE.md backup found"
fi

if [ -f ".claude/config.json.backup" ]; then
    echo "  • .claude/config.json.backup (will be restored)"
else
    echo "  • No .claude/config.json backup found"
fi

echo ""
read -p "Do you want to proceed with uninstall? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo -e "${GREEN}Starting uninstall...${NC}"
echo ""

# Restore CLAUDE.md backup
if [ -f ".backup.CLAUDE.md" ]; then
    echo "Restoring CLAUDE.md from backup..."
    mv .backup.CLAUDE.md CLAUDE.md
    echo "✓ CLAUDE.md restored"
elif [ -f "CLAUDE.md" ] && grep -q "techLEAD" CLAUDE.md; then
    echo -e "${YELLOW}Warning: CLAUDE.md contains techLEAD content but no backup found${NC}"
    read -p "Remove CLAUDE.md? (y/n): " REMOVE_CLAUDE
    if [ "$REMOVE_CLAUDE" = "y" ]; then
        rm CLAUDE.md
        echo "✓ CLAUDE.md removed"
    else
        echo "✓ CLAUDE.md kept (you may want to manually remove techLEAD content)"
    fi
fi

# Restore .claude/config.json backup
if [ -f ".claude/config.json.backup" ]; then
    echo "Restoring .claude/config.json from backup..."
    mv .claude/config.json.backup .claude/config.json
    echo "✓ .claude/config.json restored"
elif [ -f ".claude/config.json" ]; then
    echo -e "${YELLOW}Warning: .claude/config.json exists but no backup found${NC}"
    read -p "Remove .claude/config.json? (y/n): " REMOVE_CLAUDE_CONFIG
    if [ "$REMOVE_CLAUDE_CONFIG" = "y" ]; then
        rm .claude/config.json
        echo "✓ .claude/config.json removed"
    else
        echo "✓ .claude/config.json kept"
    fi
fi

# Remove techLEAD directories
echo "Removing techLEAD directories..."
[ -d ".techlead" ] && rm -rf .techlead && echo "✓ Removed .techlead/"
[ -d ".claude/agents" ] && rm -rf .claude/agents && echo "✓ Removed .claude/agents/"
[ -d ".github/runner" ] && rm -rf .github/runner && echo "✓ Removed .github/runner/"

# Remove workflows
echo "Removing workflows..."
[ -f ".github/workflows/claude.yml" ] && rm .github/workflows/claude.yml && echo "✓ Removed claude.yml"
[ -f ".github/workflows/claude-code-review.yml" ] && rm .github/workflows/claude-code-review.yml && echo "✓ Removed claude-code-review.yml"

# Ask about .gitignore cleanup
echo ""
if [ -f ".gitignore" ] && grep -q "techLEAD" .gitignore; then
    read -p "Remove techLEAD entries from .gitignore? (y/n): " CLEAN_GITIGNORE
    if [ "$CLEAN_GITIGNORE" = "y" ]; then
        # Create backup
        cp .gitignore .gitignore.backup
        # Remove techLEAD section
        sed -i.tmp '/# techLEAD/,/^$/d' .gitignore
        rm .gitignore.tmp
        echo "✓ Cleaned .gitignore (backup: .gitignore.backup)"
    else
        echo "✓ .gitignore left unchanged"
    fi
fi

# Final summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Uninstall Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "techLEAD has been removed from your project."
echo ""
echo "Remaining backups (you can delete these):"
[ -f ".gitignore.backup" ] && echo "  • .gitignore.backup"
[ -f ".backup.CLAUDE.md" ] && echo "  • .backup.CLAUDE.md"
[ -f ".claude/config.json.backup" ] && echo "  • .claude/config.json.backup"
echo ""
