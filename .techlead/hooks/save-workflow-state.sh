#!/bin/bash
# PostToolUse hook for TodoWrite
# Logs that state should be persisted

TIMESTAMP=$(date -Iseconds)
echo "[$TIMESTAMP] TodoWrite called - workflow state updated" >> .techlead/workflow_state.log

# Note: Actual state saving happens in techLEAD's workflow logic
# This hook just logs for audit trail
exit 0
