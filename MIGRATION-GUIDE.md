# techLEAD Migration Guide: Traditional → Plugin Installation

## Safe Migration for trendlenspro Project

This guide helps you migrate from traditional techLEAD installation to the plugin-based installation while preserving all your valuable history, settings, and learned patterns.

---

## ⚠️ IMPORTANT: Read This First

**What You'll Preserve:**
- ✅ All decision history (decisions_log.jsonl)
- ✅ All execution history (work_log.jsonl)
- ✅ All GitHub operations (github_ops.log)
- ✅ All state changes (workflow_state.log)
- ✅ Archived workflow states
- ✅ Project context and learned patterns (CLAUDE.md)
- ✅ Your container name and custom settings

**What Gets Replaced (Safe):**
- ♻️ Monitoring scripts (fresh from plugin)
- ♻️ Slash commands (fresh from plugin)
- ♻️ Subagents (fresh from plugin)
- ♻️ Hooks (fresh from plugin)

**Time Required:** 15-20 minutes

**Rollback Available:** Yes, full backup created

---

## Phase 1: Create Complete Backup

### Step 1: Create Backup Directory

```bash
cd ~
mkdir -p techlead-trendlenspro-backup-$(date +%Y%m%d-%H%M%S)
cd techlead-trendlenspro-backup-$(date +%Y%m%d-%H%M%S)
pwd  # Note this path - you'll need it later
```

**Expected output:**
```
/home/rob/techlead-trendlenspro-backup-20251012-140530
```

**✏️ Write down this path:** `_______________________________________`

---

### Step 2: Backup Critical History Files

These files contain irreplaceable history and MUST be preserved:

```bash
# Set your project path
PROJECT="/media/rob/Workspace/Development/trendlenspro"

# Backup all history/memory files
cp "$PROJECT/.techlead/decisions_log.jsonl" ./decisions_log.jsonl 2>/dev/null || echo "⚠️  No decisions_log.jsonl"
cp "$PROJECT/.techlead/work_log.jsonl" ./work_log.jsonl 2>/dev/null || echo "⚠️  No work_log.jsonl"
cp "$PROJECT/.techlead/github_ops.log" ./github_ops.log 2>/dev/null || echo "⚠️  No github_ops.log"
cp "$PROJECT/.techlead/workflow_state.log" ./workflow_state.log 2>/dev/null || echo "⚠️  No workflow_state.log"
cp "$PROJECT/.techlead/workflow_state.json" ./workflow_state.json 2>/dev/null || echo "⚠️  No workflow_state.json"

# Backup archived states
cp -r "$PROJECT/.techlead/archive" ./archive 2>/dev/null || echo "⚠️  No archive directory"

# Backup project context (learned patterns)
cp "$PROJECT/CLAUDE.md" ./CLAUDE.md 2>/dev/null || echo "⚠️  No CLAUDE.md"

# List what was backed up
echo ""
echo "✅ History files backed up:"
ls -lh *.jsonl *.log *.json *.md 2>/dev/null
echo ""
ls -lh archive/ 2>/dev/null
```

**Verify:** You should see files listed. If any critical files are missing, investigate before proceeding.

---

### Step 3: Backup Configuration Files

These contain your customizations:

```bash
# Backup runtime config (container name, timeouts, etc.)
cp "$PROJECT/.techlead/config.json" ./techlead-config.json 2>/dev/null || echo "⚠️  No config.json"

# Backup permissions
cp "$PROJECT/.claude/settings.local.json" ./claude-settings.json 2>/dev/null || echo "⚠️  No settings.local.json"

# Backup hooks config (if customized)
cp "$PROJECT/.claude/config.json" ./claude-config.json 2>/dev/null || echo "⚠️  No .claude/config.json"

# Backup any custom templates (if modified)
cp -r "$PROJECT/.techlead/templates" ./templates-backup 2>/dev/null || echo "⚠️  No custom templates"

echo ""
echo "✅ Configuration files backed up:"
ls -lh *.json 2>/dev/null
```

---

### Step 4: Extract Critical Settings

Extract your container name and any custom settings:

```bash
# Extract container name (CRITICAL - you'll need this)
CONTAINER_NAME=$(grep -o '"container_name": "[^"]*"' ./techlead-config.json | cut -d'"' -f4)
echo ""
echo "📝 Your Docker container name: $CONTAINER_NAME"
echo ""
echo "✏️  Write this down: _______________________________________"
echo ""

# Show full config for reference
echo "📋 Full config.json contents:"
cat ./techlead-config.json
echo ""
```

**✏️ Write down your container name - you'll need it after migration!**

---

### Step 5: Verify Backup Completeness

Run this checklist:

```bash
echo "🔍 Backup Verification Checklist:"
echo ""

# Critical files (must have)
[ -f decisions_log.jsonl ] && echo "✅ decisions_log.jsonl" || echo "❌ MISSING: decisions_log.jsonl"
[ -f work_log.jsonl ] && echo "✅ work_log.jsonl" || echo "❌ MISSING: work_log.jsonl"
[ -f github_ops.log ] && echo "✅ github_ops.log" || echo "❌ MISSING: github_ops.log"
[ -f workflow_state.log ] && echo "✅ workflow_state.log" || echo "❌ MISSING: workflow_state.log"
[ -f CLAUDE.md ] && echo "✅ CLAUDE.md" || echo "❌ MISSING: CLAUDE.md"

# Important files (should have)
[ -f techlead-config.json ] && echo "✅ techlead-config.json" || echo "⚠️  techlead-config.json (will use default)"
[ -f claude-settings.json ] && echo "✅ claude-settings.json" || echo "⚠️  claude-settings.json (will use default)"

# Optional
[ -d archive ] && echo "✅ archive/ directory" || echo "ℹ️  No archive directory"

echo ""
read -p "Does everything look correct? (y/n): " VERIFY

if [ "$VERIFY" != "y" ]; then
    echo "❌ Backup verification failed. Please investigate before proceeding."
    exit 1
fi

echo "✅ Backup verified!"
```

**STOP HERE if anything is missing or looks wrong!**

---

## Phase 2: Uninstall Old techLEAD

### Step 6: Navigate to Project and Uninstall

```bash
cd /media/rob/Workspace/Development/trendlenspro

# Run uninstall script
./.techlead/uninstall.sh
```

**When prompted:**

```
Do you want to proceed with uninstall? (y/n): y

Remove CLAUDE.md? (y/n): n  ← Keep it! We backed it up but leave original

Remove .claude/config.json? (y/n): y  ← Remove it, plugin will create new one

Remove techLEAD entries from .gitignore? (y/n): y  ← Clean it up
```

**Verify uninstall:**

```bash
# These should be gone
[ ! -d .techlead ] && echo "✅ .techlead removed" || echo "❌ .techlead still exists"
[ ! -d .claude/agents ] && echo "✅ .claude/agents removed" || echo "❌ .claude/agents still exists"
[ ! -d .claude/commands ] && echo "✅ .claude/commands removed" || echo "❌ .claude/commands still exists"

echo ""
echo "✅ Old techLEAD uninstalled"
```

---

## Phase 3: Install via Plugin

### Step 7: Add techLEAD Plugin Marketplace

**In Claude Code:**

```
/plugin marketplace add /media/rob/Workspace/Development/techLEAD
```

**Expected output:**
```
✓ Added marketplace "techlead-marketplace" from /media/rob/Workspace/Development/techLEAD
```

---

### Step 8: Install techLEAD Plugin

**In Claude Code:**

```
/plugin install techlead@techlead-marketplace
```

**Expected output:**
```
✓ Installing plugin "techlead" from techlead-marketplace
✓ Installed commands: /techlead, /techlead-issue, /techlead-setup, /rollback
✓ Installed agents: test-builder, code-analyzer, final-validator
✓ Registered hooks: PostToolUse, SubagentStop
```

---

### Step 9: Run techLEAD Setup

**In Claude Code (while in trendlenspro directory):**

```
/techlead-setup
```

This will:
- Create `.techlead/` directory structure
- Install monitoring scripts
- Copy hooks to `.techlead/hooks/`
- Create guidance templates
- Create empty state files
- Create default config.json

**Expected output:**
```
✅ techLEAD setup complete!
```

**Verify setup:**

```bash
# Check directory structure
ls -la .techlead/

# Should see:
# - monitor.sh
# - monitor-runner.sh
# - config.json
# - hooks/
# - templates/
# - Empty .jsonl and .log files
```

---

## Phase 4: Restore Your Data

### Step 10: Restore History Files

**IMPORTANT:** We append to preserve any new structure created by setup:

```bash
# Set your backup directory path (from Step 1)
BACKUP_DIR=~/techlead-trendlenspro-backup-YYYYMMDD-HHMMSS  # Use your actual path!

cd /media/rob/Workspace/Development/trendlenspro

# Restore/append history files
cat "$BACKUP_DIR/decisions_log.jsonl" >> .techlead/decisions_log.jsonl 2>/dev/null
cat "$BACKUP_DIR/work_log.jsonl" >> .techlead/work_log.jsonl 2>/dev/null
cat "$BACKUP_DIR/github_ops.log" >> .techlead/github_ops.log 2>/dev/null
cat "$BACKUP_DIR/workflow_state.log" >> .techlead/workflow_state.log 2>/dev/null

# Restore current state (overwrite - it's current state)
cp "$BACKUP_DIR/workflow_state.json" .techlead/workflow_state.json 2>/dev/null

# Restore archive
cp -r "$BACKUP_DIR/archive" .techlead/ 2>/dev/null || echo "No archive to restore"

echo "✅ History files restored"
```

**Verify:**

```bash
# Check file sizes - should have content now
ls -lh .techlead/*.jsonl .techlead/*.log
```

---

### Step 11: Restore CLAUDE.md (Project Context)

Your CLAUDE.md contains learned patterns and project-specific context. This is critical!

```bash
# Restore your project's CLAUDE.md
cp "$BACKUP_DIR/CLAUDE.md" ./CLAUDE.md

echo "✅ CLAUDE.md restored"
```

---

### Step 12: Restore Configuration Settings

**Critical Step: Update Container Name**

```bash
# Check current default config
cat .techlead/config.json

# Extract your old container name
CONTAINER_NAME=$(grep -o '"container_name": "[^"]*"' "$BACKUP_DIR/techlead-config.json" | cut -d'"' -f4)
echo "Your container name: $CONTAINER_NAME"

# Update config.json with your container name
sed -i "s/\"container_name\": \"techLEAD-runner\"/\"container_name\": \"$CONTAINER_NAME\"/" .techlead/config.json

# Verify the change
grep container_name .techlead/config.json

echo "✅ Container name updated"
```

**Optional: Restore other custom settings**

If you had custom timeout values, workflow settings, etc.:

```bash
# Compare old vs new config
diff "$BACKUP_DIR/techlead-config.json" .techlead/config.json

# If you see important differences, edit manually:
nano .techlead/config.json
```

---

### Step 13: Restore Permissions (if needed)

Check if you had custom permissions:

```bash
# Compare permissions
diff "$BACKUP_DIR/claude-settings.json" .claude/settings.local.json 2>/dev/null

# If differences exist, you may need to merge manually
# The plugin should have set up basic permissions already
```

---

## Phase 5: Verify & Test

### Step 14: Verify All Files

```bash
cd /media/rob/Workspace/Development/trendlenspro

echo "🔍 Final Verification Checklist:"
echo ""

# History preserved
[ -s .techlead/decisions_log.jsonl ] && echo "✅ decisions_log.jsonl (has content)" || echo "❌ decisions_log.jsonl (empty or missing)"
[ -s .techlead/work_log.jsonl ] && echo "✅ work_log.jsonl (has content)" || echo "❌ work_log.jsonl (empty or missing)"
[ -s .techlead/github_ops.log ] && echo "✅ github_ops.log (has content)" || echo "❌ github_ops.log (empty or missing)"
[ -s CLAUDE.md ] && echo "✅ CLAUDE.md (has content)" || echo "❌ CLAUDE.md (empty or missing)"

echo ""

# New structure installed
[ -f .techlead/monitor.sh ] && echo "✅ monitor.sh installed" || echo "❌ monitor.sh missing"
[ -f .techlead/monitor-runner.sh ] && echo "✅ monitor-runner.sh installed" || echo "❌ monitor-runner.sh missing"
[ -d .techlead/hooks ] && echo "✅ hooks/ directory exists" || echo "❌ hooks/ directory missing"
[ -d .techlead/templates/guidance ] && echo "✅ templates/ directory exists" || echo "❌ templates/ directory missing"

echo ""

# Configuration correct
echo "📝 Configuration Check:"
grep container_name .techlead/config.json
echo ""

# Plugin components
[ -d ~/.claude/plugins/techlead ] && echo "✅ Plugin installed" || echo "❌ Plugin not found"

echo ""
echo "Verification complete!"
```

---

### Step 15: Restart Claude Code

**CRITICAL:** Slash commands only load on full restart.

1. **Save all work**
2. **Completely close Claude Code** (not just close window - quit application)
3. **Reopen Claude Code**
4. **Navigate to trendlenspro:**
   ```bash
   cd /media/rob/Workspace/Development/trendlenspro
   ```

---

### Step 16: Test techLEAD

**In Claude Code:**

```
/techlead
```

**What to expect:**

```
Checking for in-progress work...
✓ Found workflow_state.json (if you had one)

Loading project context from CLAUDE.md...
✓ Loaded learned patterns

Found X open issues:
  #42 [enhancement] ...
  #48 [bug] ...
  ...

Would you like to:
  a) Work on a single issue
  b) Work on a sequence
```

**Verify History:**

Ask techLEAD:
```
Can you check the decisions_log.jsonl and tell me about recent decisions?
```

It should be able to read your historical decisions.

---

## Phase 6: Cleanup (Optional)

### Step 17: Verify Everything Works

Test a few things:
1. ✅ `/techlead` command loads
2. ✅ Project history is accessible
3. ✅ Container name is correct in config
4. ✅ Can list issues
5. ✅ CLAUDE.md context is loaded

**If everything works:**

```bash
# You can now safely delete backups (or keep them for safety)
# The backup is in: ~/techlead-trendlenspro-backup-YYYYMMDD-HHMMSS
# Consider keeping it for 30 days just in case

# Optional: Archive the backup
cd ~
tar -czf techlead-trendlenspro-backup-$(date +%Y%m%d).tar.gz techlead-trendlenspro-backup-*
# Then you can delete the directory
```

---

## Rollback Plan

If something goes wrong, you can roll back:

### Emergency Rollback

```bash
cd /media/rob/Workspace/Development/trendlenspro

# Remove new installation
rm -rf .techlead
rm -rf .claude/agents
rm -rf .claude/commands

# Restore from backup
BACKUP_DIR=~/techlead-trendlenspro-backup-YYYYMMDD-HHMMSS  # Your backup path

cp -r "$BACKUP_DIR/.techlead" .techlead
cp -r "$BACKUP_DIR/.claude" .claude
cp "$BACKUP_DIR/CLAUDE.md" CLAUDE.md

# Reinstall old way
cd /media/rob/Workspace/Development/techLEAD
./install.sh
# Point it to /media/rob/Workspace/Development/trendlenspro
```

---

## Common Issues

### Issue: /techlead command not found

**Solution:** Restart Claude Code completely (quit and reopen)

### Issue: Hooks not firing

**Solution:** Check `.claude-plugin/plugin.json` has correct paths (`.techlead/hooks/...`)

### Issue: Monitor scripts not found

**Solution:** Verify `.techlead/monitor.sh` exists and is executable:
```bash
ls -l .techlead/monitor.sh
chmod +x .techlead/monitor.sh .techlead/monitor-runner.sh
```

### Issue: Container name wrong

**Solution:** Edit `.techlead/config.json`:
```bash
nano .techlead/config.json
# Update "container_name" field
```

### Issue: No history after migration

**Solution:** Check backup was restored:
```bash
ls -lh .techlead/*.jsonl
# Should show file sizes > 0
```

If files are empty, re-run Step 10 with correct backup path.

---

## Summary Checklist

Use this for a quick overview:

- [ ] **Phase 1:** Created backup directory
- [ ] **Phase 1:** Backed up all history files (.jsonl, .log)
- [ ] **Phase 1:** Backed up CLAUDE.md
- [ ] **Phase 1:** Backed up config files
- [ ] **Phase 1:** Noted container name
- [ ] **Phase 1:** Verified backup completeness
- [ ] **Phase 2:** Ran uninstall.sh
- [ ] **Phase 2:** Verified old files removed
- [ ] **Phase 3:** Added plugin marketplace
- [ ] **Phase 3:** Installed plugin
- [ ] **Phase 3:** Ran /techlead-setup
- [ ] **Phase 4:** Restored history files
- [ ] **Phase 4:** Restored CLAUDE.md
- [ ] **Phase 4:** Updated container name in config
- [ ] **Phase 5:** Verified all files present
- [ ] **Phase 5:** Restarted Claude Code completely
- [ ] **Phase 5:** Tested /techlead command
- [ ] **Phase 5:** Verified history accessible

---

## Questions?

If you encounter any issues not covered here:

1. Check your backup directory - nothing is lost!
2. Review the Common Issues section above
3. The backup is always available for rollback

**Your data is safe in:**
```
~/techlead-trendlenspro-backup-YYYYMMDD-HHMMSS/
```

---

**Version:** 1.2.0
**Last Updated:** 2025-10-12
**Created for:** trendlenspro migration
