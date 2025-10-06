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
  # Found a completion, but we can't trust it's the current job
  # techLEAD posts comment at T, starts monitoring at T+1s
  # Any completion we find now is from a PREVIOUS job (work takes minutes, not seconds)
  # Solution: Always wait for the job to actually run, never exit immediately
  echo -e "${GRAY}Previous job completion found, waiting for new job to start...${NC}"
  JOB_ALREADY_RUNNING=false

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
docker logs -f --tail 2 "$CONTAINER_NAME" 2>&1 | while IFS= read -r LINE; do

  # Check timeout for job start
  if [ "$JOB_STARTED" = false ]; then
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_WAIT))

    if [ $ELAPSED -gt $TIMEOUT ]; then
      echo ""
      echo -e "${RED}✗ Timeout: Job '$JOB_NAME' did not start within ${TIMEOUT}s${NC}"
      exit 1
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

    # Check result
    if echo "$LINE" | grep -q "Succeeded"; then
      echo -e "${GREEN}✓ SUCCESS${NC} ($END_TIMESTAMP)"
      echo -e "${GRAY}Duration: $DURATION_STR${NC}"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      exit 0

    elif echo "$LINE" | grep -q "Failed"; then
      echo -e "${RED}✗ FAILED${NC} ($END_TIMESTAMP)"
      echo -e "${GRAY}Duration: $DURATION_STR${NC}"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo -e "${YELLOW}Check logs:${NC} docker logs $CONTAINER_NAME"
      exit 1

    else
      RESULT=$(echo "$LINE" | grep -oP 'result: \K\w+' || echo "Unknown")
      echo -e "${YELLOW}Job completed: $RESULT${NC} ($END_TIMESTAMP)"
      echo -e "${GRAY}Duration: $DURATION_STR${NC}"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      exit 1
    fi
  fi

done

# Should not reach here (pipe broke or container stopped)
echo ""
echo -e "${RED}✗ Monitoring stopped unexpectedly${NC}"
exit 1
