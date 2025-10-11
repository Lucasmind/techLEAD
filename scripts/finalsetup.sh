#!/bin/bash
# finalsetup.sh - Sets up monitoring and state files for techLEAD
# Can be called by install.sh OR /techlead-setup command

set -e

echo "🚀 Setting up techLEAD monitoring and state management..."
echo ""

# Detect script location (works from anywhere)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Create .techlead directory structure
echo "📁 Creating .techlead directory structure..."
mkdir -p .techlead/{hooks,templates/guidance,archive}

# 2. Copy monitoring scripts
echo "📊 Installing monitoring scripts..."
cp "$REPO_ROOT/scripts/monitor.sh" .techlead/
cp "$REPO_ROOT/scripts/monitor-runner.sh" .techlead/
chmod +x .techlead/monitor.sh .techlead/monitor-runner.sh

# 3. Copy hooks if not already present
echo "🪝 Installing hooks..."
cp -n "$REPO_ROOT/hooks"/* .techlead/hooks/ 2>/dev/null || cp "$REPO_ROOT/hooks"/* .techlead/hooks/
chmod +x .techlead/hooks/*.sh

# 4. Copy templates
echo "📝 Installing guidance templates..."
cp -r "$REPO_ROOT/templates/guidance"/* .techlead/templates/guidance/

# 5. Create empty log/state files
echo "📋 Creating state and log files..."
touch .techlead/{decisions_log.jsonl,github_ops.log,workflow_state.log,work_log.jsonl}

# 6. Create config file if it doesn't exist
if [ ! -f .techlead/config.json ]; then
    echo "⚙️  Creating default config..."
    cat > .techlead/config.json <<'EOF'
{
  "version": "1.2.0",
  "runner": {
    "type": "docker",
    "container_name": "techLEAD-runner",
    "jobs": {
      "implement": "claude",
      "review": "claude-review",
      "test": "claude-test"
    }
  },
  "monitoring": {
    "timeout_seconds": 300,
    "check_interval_seconds": 30,
    "show_detailed_logs": false
  },
  "workflow": {
    "auto_continue_on_success": true,
    "require_pm_approval": ["merge", "sequence_start"],
    "max_review_iterations": 3
  },
  "memory": {
    "decisions_log": ".techlead/decisions_log.jsonl",
    "work_log": ".techlead/work_log.jsonl",
    "workflow_state": ".techlead/workflow_state.json"
  }
}
EOF
fi

# 7. Create claude-snippet.md for reference
cat > .techlead/claude-snippet.md <<'EOF'
# techLEAD Context Snippet

This file is for reference only. CLAUDE.md at the repository root is the active project instructions file.

To use techLEAD:
- Run `/techlead` to start orchestration
- Run `/techlead-issue` to create issues with AI-assisted templates
- Run `/rollback` to undo work using checkpoint tags

See README.md for full documentation.
EOF

echo ""
echo -e "${GREEN}✅ techLEAD setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Set up GitHub Actions workflows:"
echo "   https://docs.claude.com/en/docs/claude-code/github-actions"
echo ""
echo "2. Copy workflow template (if needed):"
echo "   cp .github/workflows/claude.yml.template .github/workflows/claude.yml"
echo ""
echo "3. Configure self-hosted runner with label 'techlead'"
echo ""
echo "4. Run ${GREEN}/techlead${NC} to start orchestrating!"
echo ""
