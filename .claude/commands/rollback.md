---
description: Rollback work using checkpoint tags
---

You are assisting the PM with **rolling back** changes made during techLEAD workflows.

## Loading Context

@CLAUDE.md
@.techlead/workflow_state.json

## Your Role

Help PM safely rollback to a previous checkpoint by:
1. Analyzing available rollback points
2. Explaining what will be kept vs removed
3. Executing the rollback with PM approval
4. Reopening affected issues

## Rollback Process

### Step 1: Analyze Current State

```bash
# Load workflow state
cat .techlead/workflow_state.json

# List available checkpoint tags
git tag -l "before-*" "after-*" --sort=-creatordate | head -20

# Show current commit
git log -1 --oneline
```

### Step 2: Present Rollback Options

**For Single Issue Rollback:**
```
Available rollback point:
- before-issue-42: Removes all work on issue #42

Current: Issue #42 merged
Rollback to: before-issue-42
Result: Issue #42 work removed, needs reimplementation
```

**For Sequence Rollback:**

Parse workflow_state.json checkpoints and present:

```
Sequence: auth-implementation
Started: 2025-10-05 18:00
Issues completed: 5/5

Rollback Options:
1) Rollback entire sequence (before-seq-auth-20251005-1800)
   → Removes: All 5 issues (#42-46)
   → Keeps: Nothing from sequence

2) Rollback to after issue #42 (after-issue-42)
   → Keeps: Issue #42 only
   → Removes: Issues #43-46

3) Rollback to after issue #43 (after-issue-43)
   → Keeps: Issues #42-43
   → Removes: Issues #44-46

4) Rollback to after issue #44 (after-issue-44)
   → Keeps: Issues #42-44
   → Removes: Issues #45-46

5) Rollback to after issue #45 (after-issue-45)
   → Keeps: Issues #42-45
   → Removes: Issue #46

Which option? (1-5 or cancel)
```

### Step 3: Verify Rollback Plan

Show PM:
1. Target tag name
2. Commits that will be removed (git log)
3. Files that will change (git diff --stat)
4. Issues that need reopening

```bash
TARGET_TAG="after-issue-43"

echo "Rollback Plan:"
echo "Target: $TARGET_TAG"
echo ""
echo "Commits to remove:"
git log "$TARGET_TAG..HEAD" --oneline
echo ""
echo "Files affected:"
git diff --stat "$TARGET_TAG" HEAD
echo ""
echo "Issues to reopen: #44, #45, #46"
```

### Step 4: Get PM Approval

Ask PM to confirm:
```
⚠️ WARNING: This will force-push to main branch

Rollback Summary:
- Target: after-issue-43
- Commits removed: 3
- Files affected: 12
- Issues reopened: #44, #45, #46

This action is PERMANENT. Continue? (yes/no)
```

**Only proceed if PM types "yes"**

### Step 5: Execute Rollback

```bash
TARGET_TAG="<approved-tag>"

# 1. Switch to main and fetch latest
git checkout main
git fetch origin

# 2. Reset to target tag
git reset --hard "$TARGET_TAG"

# 3. Force push (requires permissions)
git push --force origin main

# 4. Verify success
git log -1 --oneline
git tag --points-at HEAD

echo "✓ Rollback complete"
```

### Step 6: Reopen Issues

```bash
# Determine which issues to reopen based on rollback point
# From workflow_state.json checkpoints

# Example: Rolled back to after-issue-43, so reopen 44-46
gh issue reopen 44 45 46

# Add comment explaining rollback
gh issue comment 44 --body "Reopening after rollback to checkpoint after-issue-43"
gh issue comment 45 --body "Reopening after rollback to checkpoint after-issue-43"
gh issue comment 46 --body "Reopening after rollback to checkpoint after-issue-43"
```

### Step 7: Update State

```bash
# Archive old workflow state
mv .techlead/workflow_state.json ".techlead/workflow_state.rollback-$(date +%Y%m%d-%H%M%S).json"

# Log rollback to decisions_log.jsonl
echo "{\"action\":\"rollback\",\"from\":\"HEAD\",\"to\":\"$TARGET_TAG\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"reason\":\"PM requested rollback\"}" >> .techlead/decisions_log.jsonl

echo "✓ State updated"
```

## Safety Checks

**Before executing rollback:**

1. ✅ Verify force push permissions on main branch
2. ✅ Confirm no one else is actively working on main
3. ✅ Verify target tag exists and is accessible
4. ✅ Get explicit PM approval (typed "yes")
5. ✅ Show PM what will be lost

**Error Handling:**

If force push fails:
```bash
# Check branch protection rules
gh api repos/:owner/:repo/branches/main/protection

# Inform PM that branch protection prevents force push
# Options:
# 1. Temporarily disable protection (requires admin)
# 2. Create revert PR instead of force push
# 3. Cancel rollback
```

## Alternative: Revert Instead of Reset

If force push is not allowed or safe:

```bash
# Instead of git reset --hard, use git revert
TARGET_TAG="after-issue-43"

# Revert commits in reverse order
COMMITS=$(git log "$TARGET_TAG..HEAD" --format=%H --reverse)

for commit in $COMMITS; do
  git revert --no-edit "$commit"
done

# Push normally (no force required)
git push origin main

# Creates new commits that undo changes
# Preserves history instead of rewriting it
```

**Trade-offs:**
- ✅ Safer (no force push)
- ✅ Preserves history
- ❌ More complex (potential conflicts)
- ❌ Less clean (revert commits in history)

## Recovery from Accidental Rollback

If rollback was a mistake:

```bash
# Find the commit we rolled back from
git reflog | head -20

# Look for: "HEAD@{1}: reset: moving to <tag>"
# The commit before that is what we lost

# Recover
git reset --hard HEAD@{1}
git push --force origin main

echo "✓ Rollback undone"
```

**Note:** Reflog keeps history for ~90 days

## Report to PM

After rollback completion:

```
✓ Rollback Complete

Target: after-issue-43
Commits removed: 3
Files affected: 12
Issues reopened: #44, #45, #46

Next steps:
1. Review why issues #44-46 failed
2. Provide updated guidance to techLEAD
3. Retry implementation with better context

Rollback logged to: decisions_log.jsonl
Old state archived to: workflow_state.rollback-<timestamp>.json
```

## Best Practices

1. **Always verify** before force pushing
2. **Communicate** with team before rollback
3. **Document** why rollback was needed
4. **Learn** from what went wrong
5. **Reopen issues** immediately after rollback
6. **Archive state** for future reference

## When NOT to Rollback

- If others have pulled main and built on it
- If production depends on current main
- If only small fixes are needed (use regular PRs instead)
- If unsure about impact (analyze first)

Instead, consider:
- Creating fix PRs for specific issues
- Using feature flags to disable broken features
- Manual revert of specific commits
