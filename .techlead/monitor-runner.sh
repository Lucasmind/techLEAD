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

echo -e "${GRAY}Waiting for job to start...${NC}"

# Get current timestamp to only watch new logs
SINCE_TIME=$(date -u +%Y-%m-%dT%H:%M:%S)

# Monitor variables
JOB_STARTED=false
START_TIMESTAMP=""
TIMEOUT=300  # 5 minutes to wait for job start
START_WAIT=$(date +%s)

# Tail Docker logs
docker logs -f --since "$SINCE_TIME" "$CONTAINER_NAME" 2>&1 | while IFS= read -r LINE; do

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
    if [ "$JOB_STARTED" = false ]; then
      JOB_STARTED=true
      START_TIMESTAMP=$(echo "$LINE" | grep -oP '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}Z' || date -u +%Y-%m-%dT%H:%M:%SZ)
      echo -e "${GREEN}✓ Job started${NC} ($START_TIMESTAMP)"
      echo ""
      echo -e "${GRAY}Running... (this may take several minutes)${NC}"
      echo ""
    fi
  fi

  # Detect job completion
  if echo "$LINE" | grep -qE "Job $JOB_NAME completed with result:"; then
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
