#!/bin/bash
# Monitors GitHub Actions runner via Docker logs
# Usage: ./monitor-runner.sh <container_name> <job_name>

CONTAINER_NAME=${1:-"techLEAD-runner"}
JOB_NAME=${2:-"claude"}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Monitoring GitHub Actions Runner${NC}"
echo "Container: $CONTAINER_NAME"
echo "Job: $JOB_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify container exists and is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo -e "${RED}✗ Container '$CONTAINER_NAME' not running${NC}"
  echo ""
  echo "Available containers:"
  docker ps -a --format 'table {{.Names}}\t{{.Status}}'
  exit 1
fi

echo -e "${GRAY}Checking current runner state...${NC}"

# Get the LAST line of logs to determine actual current state
LAST_LINE=$(docker logs --tail 1 "$CONTAINER_NAME" 2>&1)

# Check if the last line shows our job completed
if echo "$LAST_LINE" | grep -qE "Job $JOB_NAME completed with result:"; then
  # Extract timestamp from log line
  LOG_TIMESTAMP=$(echo "$LAST_LINE" | grep -oP '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}Z')

  if [ -n "$LOG_TIMESTAMP" ]; then
    # Convert to epoch seconds
    LOG_TIME=$(date -d "$LOG_TIMESTAMP" +%s 2>/dev/null || echo "0")
    CURRENT_TIME=$(date +%s)
    AGE=$((CURRENT_TIME - LOG_TIME))

    # Check age to determine if this could be current job
    if [ "$LOG_TIME" != "0" ] && [ "$AGE" -le 30 ]; then
      # SUSPICIOUS: Completion within 30 seconds is highly unlikely
      # Real implementation work takes minutes, not seconds
      # This could be a race condition or the job actually failed instantly
      echo -e "${YELLOW}⚠ Recent completion detected (${AGE}s ago) - verifying...${NC}"

      # Check if we can find evidence of the job actually running
      RECENT_LOGS=$(docker logs --tail 10 "$CONTAINER_NAME" 2>&1)
      if echo "$RECENT_LOGS" | grep -qE "Running job: $JOB_NAME"; then
        # Found evidence of job running - completion is likely legitimate
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        if echo "$LAST_LINE" | grep -q "Succeeded"; then
          echo -e "${GREEN}✓ Job completed: SUCCESS${NC} (verified)"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          exit 0
        elif echo "$LAST_LINE" | grep -q "Failed"; then
          echo -e "${RED}✗ Job completed: FAILED${NC} (verified)"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo ""
          echo -e "${YELLOW}Check logs:${NC} docker logs $CONTAINER_NAME"
          exit 1
        fi
      else
        # No evidence of job running - don't trust this completion
        echo -e "${GRAY}No evidence of job execution, waiting for new job...${NC}"
        JOB_ALREADY_RUNNING=false
      fi
    else
      # Old completion (>30s ago) - definitely not current job
      echo -e "${GRAY}Old job completion found (${AGE}s ago), waiting for new job...${NC}"
      JOB_ALREADY_RUNNING=false
    fi
  else
    # Couldn't parse timestamp, treat as waiting
    echo -e "${GRAY}Waiting for job to start...${NC}"
    JOB_ALREADY_RUNNING=false
  fi

elif echo "$LAST_LINE" | grep -qE "Running job: $JOB_NAME"; then
  # Job is currently running
  echo -e "${GREEN}✓ Job already running${NC}"
  echo ""
  echo -e "${GRAY}Monitoring in progress...${NC}"
  echo ""
  JOB_ALREADY_RUNNING=true
else
  # Last line doesn't show our job - need to wait for it to start
  echo -e "${GRAY}Waiting for job to start...${NC}"
  JOB_ALREADY_RUNNING=false
fi

# Monitor variables
JOB_STARTED=$JOB_ALREADY_RUNNING
START_TIMESTAMP=""
TIMEOUT=300  # 5 minutes to wait for job start
START_WAIT=$(date +%s)

# If job already running, we need to skip historical completions in the tail buffer
# Only process completions that come AFTER we see the current "Running job" line
SEEN_CURRENT_RUN=false
if [ "$JOB_ALREADY_RUNNING" = false ]; then
  SEEN_CURRENT_RUN=true  # Not already running, so process all lines normally
fi

# Tail Docker logs - use --tail 2 to capture current state (single-threaded runner)
# Line 1: Previous state, Line 2: Current state, then -f follows new lines
# Use process substitution and break to exit cleanly
EXIT_CODE=""
while IFS= read -r LINE; do

  # Check timeout for job start
  if [ "$JOB_STARTED" = false ]; then
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_WAIT))

    if [ $ELAPSED -gt $TIMEOUT ]; then
      echo ""
      echo -e "${RED}✗ Timeout: Job '$JOB_NAME' did not start within ${TIMEOUT}s${NC}"
      EXIT_CODE=1
      break
    fi
  fi

  # Detect job start
  if echo "$LINE" | grep -qE "Running job: $JOB_NAME"; then
    SEEN_CURRENT_RUN=true  # Mark that we've seen the current running instance
    if [ "$JOB_STARTED" = false ]; then
      JOB_STARTED=true
      START_TIMESTAMP=$(echo "$LINE" | grep -oP '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}Z' || date -u +%Y-%m-%dT%H:%M:%SZ)
      echo -e "${GREEN}✓ Job started${NC} ($START_TIMESTAMP)"
      echo ""
      echo -e "${GRAY}Running... (this may take several minutes)${NC}"
      echo ""
    fi
  fi

  # Detect job completion - but only if we've seen the current run
  # This prevents processing old completion messages from the tail buffer
  if [ "$SEEN_CURRENT_RUN" = true ] && echo "$LINE" | grep -qE "Job $JOB_NAME completed with result:"; then
    END_TIMESTAMP=$(echo "$LINE" | grep -oP '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}Z' || date -u +%Y-%m-%dT%H:%M:%SZ)

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Calculate duration
    if [ -n "$START_TIMESTAMP" ] && [ -n "$END_TIMESTAMP" ]; then
      START_SEC=$(date -d "$START_TIMESTAMP" +%s 2>/dev/null || echo "0")
      END_SEC=$(date -d "$END_TIMESTAMP" +%s 2>/dev/null || echo "0")

      if [ "$START_SEC" != "0" ] && [ "$END_SEC" != "0" ]; then
        DURATION=$((END_SEC - START_SEC))
        MINUTES=$((DURATION / 60))
        SECONDS=$((DURATION % 60))
        DURATION_STR="${MINUTES}m ${SECONDS}s"
      else
        DURATION_STR="unknown"
      fi
    else
      DURATION_STR="unknown"
    fi

    # Check result and break
    if echo "$LINE" | grep -q "Succeeded"; then
      echo -e "${GREEN}✓ SUCCESS${NC} ($END_TIMESTAMP)"
      echo -e "${GRAY}Duration: $DURATION_STR${NC}"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      EXIT_CODE=0
      break

    elif echo "$LINE" | grep -q "Failed"; then
      echo -e "${RED}✗ FAILED${NC} ($END_TIMESTAMP)"
      echo -e "${GRAY}Duration: $DURATION_STR${NC}"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo -e "${YELLOW}Check logs:${NC} docker logs $CONTAINER_NAME"
      EXIT_CODE=1
      break

    else
      RESULT=$(echo "$LINE" | grep -oP 'result: \K\w+' || echo "Unknown")
      echo -e "${YELLOW}Job completed: $RESULT${NC} ($END_TIMESTAMP)"
      echo -e "${GRAY}Duration: $DURATION_STR${NC}"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      EXIT_CODE=1
      break
    fi
  fi

done < <(docker logs -f --tail 2 "$CONTAINER_NAME" 2>&1)

# Exit with the code set during monitoring
if [ -n "$EXIT_CODE" ]; then
  exit $EXIT_CODE
fi

# Should not reach here (process substitution ended without setting exit code)
echo ""
echo -e "${RED}✗ Monitoring stopped unexpectedly${NC}"
exit 1
