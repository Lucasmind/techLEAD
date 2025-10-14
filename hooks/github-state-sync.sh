#!/bin/bash
# PostToolUse hook for GitHub operations
# Logs GitHub interactions

# Exit silently if not in a techLEAD project
if [ ! -d ".techlead" ]; then
    exit 0
fi

TIMESTAMP=$(date -Iseconds)
TOOL_NAME="${1:-unknown}"

echo "[$TIMESTAMP] GitHub operation: $TOOL_NAME" >> .techlead/github_ops.log

exit 0
