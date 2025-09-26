#!/bin/bash

# Test n8n webhook registration

echo "🔍 Debugging n8n Webhook Registration"
echo "======================================"
echo ""

# Load environment variables
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
elif [ -f "../.env" ]; then
    export $(cat ../.env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found. Please copy .env.example to .env and configure it."
    exit 1
fi

# Check required environment variables
if [ -z "$N8N_API_KEY" ]; then
    echo "Error: N8N_API_KEY must be set in .env file"
    exit 1
fi

# Check if workflow is active (using workflow ID as parameter)
WORKFLOW_ID="${1:-8jmnCyHa1tWZC4j6}"
echo "Checking workflow status for ID: $WORKFLOW_ID..."
status=$(curl -s -X GET ${N8N_API_URL:-http://localhost:5678}/api/v1/workflows/$WORKFLOW_ID \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  | jq '{id, name, active}')

echo "$status"
echo ""

# Try different webhook paths
echo "Testing webhook paths:"
echo "----------------------"

paths=(
  "webhook/8jmnCyHa1tWZC4j6-telegram"
  "webhook/telegram-webhook"
  "webhook/8jmnCyHa1tWZC4j6/telegram-webhook"
)

for path in "${paths[@]}"; do
  echo -n "Testing /$path ... "
  response=$(curl -s -o /dev/null -w "%{http_code}" https://techlead.blucas.ca/$path -X POST -H "Content-Type: application/json" -d '{"test": true}')
  echo "HTTP $response"
done

echo ""
echo "Possible issues:"
echo "1. Webhook node might need 'responseMode' set to 'lastNode' instead of 'responseNode'"
echo "2. The workflow might need to be manually tested in n8n UI first"
echo "3. n8n might need WEBHOOK_URL environment variable set correctly"