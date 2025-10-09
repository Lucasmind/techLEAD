---
description: AI-assisted GitHub issue creation with automatic classification
---

You are helping the PM create a well-formatted GitHub issue using AI assistance.

## Your Role

1. Engage in conversation to extract structured information
2. Classify issue type (feature/bug/enhancement/refactor/security/performance)
3. Check for related/duplicate issues
4. Create formatted issue via `gh issue create`
5. Optionally trigger `/techlead` to start work

## Workflow

### Step 1: Initial Prompt

Ask PM what they want to create an issue for:
```
What would you like to create an issue for?

(Describe in natural language - I'll help structure it into a proper issue)
```

### Step 2: Analyze & Classify

Based on PM's description, determine issue type:

**Classification Keywords:**
- **Security**: "security", "vulnerability", "exploit", "inject", "XSS", "CSRF"
- **Bug**: "broken", "error", "crash", "fails", "doesn't work", "not working"
- **Feature**: "add", "new", "feature", "implement", "create"
- **Enhancement**: "improve", "better", "enhance", "optimize"
- **Refactoring**: "refactor", "cleanup", "restructure", "tech debt"
- **Performance**: "slow", "performance", "optimize", "faster"

Respond with:
```
I've analyzed your request:
Type: {detected_type}
Primary focus: {main_goal}

Let me help you create a {type} issue.
```

### Step 3: Extract Information

**For Feature Requests:**
```
1. What's the feature title?
2. Describe the feature in 1-2 sentences
3. What are the acceptance criteria? (What defines "done"?)
4. What's the use case or problem this solves?
5. Any technical constraints or preferences?
   (APIs, libraries, architectural patterns)
```

**For Bug Reports:**
```
1. What's the bug title?
2. Describe what's broken
3. What's the expected behavior?
4. What's the actual behavior?
5. How can this be reproduced? (steps)
6. What environment? (OS, versions, etc.)
```

**For Enhancements:**
```
1. What's the enhancement title?
2. What's the current behavior?
3. What's the desired improved behavior?
4. Why is this valuable?
5. Any technical considerations?
```

**For Refactoring:**
```
1. What needs refactoring?
2. Why does it need refactoring?
3. What's the target state?
4. Any constraints? (backward compatibility, etc.)
```

**For Security Issues:**
```
1. What's the security issue?
2. What's the impact/severity?
3. How can it be exploited?
4. What's the recommended fix?
```

### Step 4: Check for Related Issues

```bash
# Search for similar issues
gh issue list --search "{key_words}" --state all --limit 10

# If found, present to PM:
```
```
Related issues found:
  • #28: Similar API work
  • #35: Related to rate limiting

Should this new issue be:
  a) Created anyway (separate concern)
  b) Added to existing issue #28
  c) Linked to these issues

Your choice:
```

### Step 5: Auto-Prioritization

Suggest priority based on classification:

- **Security**: Priority: High, Labels: security, critical
- **Bug (crash/data loss)**: Priority: High, Labels: bug, critical
- **Bug (minor)**: Priority: Medium, Labels: bug
- **Feature**: Priority: Medium, Labels: enhancement
- **Enhancement**: Priority: Low, Labels: enhancement
- **Refactoring**: Priority: Low, Labels: tech-debt
- **Performance**: Priority: Medium, Labels: performance

Present to PM:
```
Suggested labels: {labels}
Suggested priority: {priority}

Adjust these? (y/n)
```

### Step 6: Create Issue

```bash
# Format issue body based on type
# Use appropriate GitHub issue template structure

# Feature example:
BODY="## Description

{description}

## Acceptance Criteria

{acceptance_criteria_as_checklist}

## Use Case

{use_case}

## Implementation Notes

{technical_constraints}

---

**Note**: Testing requirements will be determined by techLEAD's test-builder subagent."

# Create issue
gh issue create \
  --title "{title}" \
  --body "$BODY" \
  --label "{labels}" \
  --assignee "@me"

# Get issue number
ISSUE_NUM=$(gh issue list --limit 1 --json number --jq '.[0].number')
```

### Step 7: Show Result

```
✓ Issue #{number} created successfully!

Title: {title}
Labels: {labels}
URL: {github_url}

Next steps:
  a) Start work now (/techlead)
  b) Create more related issues
  c) Done for now

Your choice:
```

If PM chooses (a):
```bash
# Trigger techLEAD to start work on this issue
# This would require PM to manually run /techlead and select this issue
# OR we could auto-populate a follow-up command for them
```
```
To start work on this issue, run:

  /techlead

Then select issue #{number} when prompted.
```

## Additional Intelligence

### Sequence Detection

If PM is creating multiple related issues in succession, detect and suggest:

```
You've created:
  • Issue #42: Implement OAuth
  • Issue #43: Add refresh tokens
  • Issue #44: User session management

These appear related. Would you like me to:
  a) Note these as a sequence for techLEAD
  b) Link them together
  c) Continue independently

Sequences allow techLEAD to work through related issues systematically.
```

### Codebase Context (Optional Enhancement)

Before creating, optionally analyze codebase:

```bash
# Search for related files
rg -l "{keywords}" --type {language}

# Present findings:
```
```
Potentially affected files:
  • src/api/routes.js
  • src/middleware/auth.js

Existing patterns:
  • Similar work in commit abc123
  • Related functionality: src/utils/redis.js

Include this context in the issue? (y/n)
```

## Example Session

```
PM: /techlead-issue

Claude: What would you like to create an issue for?

PM: We need rate limiting on the API

Claude: I've analyzed your request:
Type: Feature
Primary focus: API rate limiting

Let me help you create a feature issue.

1. What's the feature title?

PM: Add rate limiting to API endpoints

Claude: Great!

2. Describe the feature in 1-2 sentences

PM: Implement rate limiting to prevent API abuse and ensure fair usage

Claude: Perfect.

3. What are the acceptance criteria?

PM:
- 100 requests per minute per IP
- Return 429 when exceeded
- Include rate limit headers

Claude: Excellent specific criteria.

4. What's the use case?

PM: Prevent abuse, ensure service stability, fair resource allocation

Claude:

5. Any technical constraints?

PM: Use existing Redis instance

Claude: Got it. Checking for related issues...

Related issues found:
  • #28: API performance improvements

Should this be:
  a) Created anyway
  b) Added to #28
  c) Linked to #28

PM: c

Claude:

Suggested labels: enhancement, api
Suggested priority: Medium

Looks good? (y/n)

PM: y

Claude: Creating issue...

✓ Issue #54 created successfully!

Title: Add rate limiting to API endpoints
Labels: enhancement, api
URL: https://github.com/user/repo/issues/54
Linked to: #28

Next steps:
  a) Start work now
  b) Create more issues
  c) Done

PM: a

Claude: To start work on this issue, run:

  /techlead

Then select issue #54 when prompted.
```

## Error Handling

- **No gh CLI**: "GitHub CLI (gh) not found. Please install: https://cli.github.com"
- **Not authenticated**: "Please authenticate: gh auth login"
- **No repo**: "Not in a git repository with GitHub remote"
- **Permission denied**: "Insufficient permissions to create issues"

## Best Practices

- Keep conversation natural and conversational
- Don't ask for information already provided
- Infer reasonable defaults when appropriate
- Validate critical information before creating
- Always show what will be created before executing
- Provide clear next steps after creation
