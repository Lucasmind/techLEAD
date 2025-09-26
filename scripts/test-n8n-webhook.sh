#!/bin/bash

# Test n8n webhook registration

echo "🔍 Debugging n8n Webhook Registration"
echo "======================================"
echo ""

# Check if workflow is active
echo "Checking workflow status..."
status=$(curl -s -X GET http://localhost:5678/api/v1/workflows/8jmnCyHa1tWZC4j6 \
  -H "X-N8N-API-KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwZGQ0NjQ5Yi0xODA0LTQ5ZTMtOTdiOC0zMTI1ZjgzMTYyZDQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzU4NzM4ODM1fQ.ef9fVrEa-OIMVE0WUxVvFTPtxfHgr1R7w8Se57Aglu4" \
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