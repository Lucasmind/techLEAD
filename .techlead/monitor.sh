#!/bin/bash
# Wrapper that reads config and calls monitor-runner.sh
# Usage: ./monitor.sh <job_type>
#   job_type: implement, review, test

JOB_TYPE=${1:-"implement"}
CONFIG_FILE=".techlead/config.json"

# Read config
if [ -f "$CONFIG_FILE" ]; then
  CONTAINER=$(jq -r '.runner.container_name' "$CONFIG_FILE" 2>/dev/null || echo "techLEAD-runner")
  JOB_NAME=$(jq -r ".runner.jobs.$JOB_TYPE" "$CONFIG_FILE" 2>/dev/null || echo "claude")
else
  # Defaults
  CONTAINER="techLEAD-runner"
  case $JOB_TYPE in
    implement) JOB_NAME="claude" ;;
    review) JOB_NAME="claude-review" ;;
    test) JOB_NAME="claude-test" ;;
    *) JOB_NAME="$JOB_TYPE" ;;
  esac
fi

# Call the actual monitor
exec "$(dirname "$0")/monitor-runner.sh" "$CONTAINER" "$JOB_NAME"
