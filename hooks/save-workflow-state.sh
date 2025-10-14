#!/bin/bash
# PostToolUse hook for TodoWrite
# Logs that state should be persisted

# Exit silently if not in a techLEAD project
if [ ! -d ".techlead" ]; then
    exit 0
fi

TIMESTAMP=$(date -Iseconds)
echo "[$TIMESTAMP] TodoWrite called - workflow state updated" >> .techlead/workflow_state.log

# Note: Actual state saving happens in techLEAD's workflow logic
# This hook just logs for audit trail
exit 0
