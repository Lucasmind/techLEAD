#!/bin/bash
# SubagentStop hook
# Logs subagent completion for tracking

# Exit silently if not in a techLEAD project
if [ ! -d ".techlead" ]; then
    exit 0
fi

TIMESTAMP=$(date -Iseconds)
AGENT_NAME="${1:-unknown}"

# Append to work log
echo "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"subagent_complete\",\"agent\":\"$AGENT_NAME\"}" >> .techlead/work_log.jsonl

exit 0
