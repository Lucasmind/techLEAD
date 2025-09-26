#!/bin/bash

# Fix n8n webhook configuration while preserving data

echo "🔧 Fixing n8n webhook configuration"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}This script will:${NC}"
echo "1. Fix permissions on ~/.n8n"
echo "2. Restart n8n with webhook configuration"
echo "3. Preserve all your workflows and settings"
echo ""

# Fix ownership
echo -e "${YELLOW}Fixing .n8n directory ownership...${NC}"
sudo chown -R 1000:1000 ~/.n8n

# Check how n8n was originally started
echo -e "${YELLOW}Checking original n8n configuration...${NC}"
ORIGINAL_CMD=$(docker inspect n8n 2>/dev/null | jq -r '.[0].Config.Cmd | join(" ")' || echo "")

# Start n8n with webhook configuration
echo -e "${YELLOW}Starting n8n with webhook support...${NC}"
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e WEBHOOK_URL=https://techlead.blucas.ca/ \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest

# Wait for startup
echo -e "${YELLOW}Waiting for n8n to start...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:5678 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ n8n is running!${NC}"
        break
    fi
    sleep 1
done

# Check if it's running
if ! curl -s http://localhost:5678 > /dev/null 2>&1; then
    echo -e "${RED}❌ n8n failed to start${NC}"
    echo "Checking logs..."
    docker logs n8n --tail 20
    exit 1
fi

# Re-activate the workflow
echo ""
echo -e "${YELLOW}Re-activating the Telegram webhook workflow...${NC}"
API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwZGQ0NjQ5Yi0xODA0LTQ5ZTMtOTdiOC0zMTI1ZjgzMTYyZDQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzU4NzM4ODM1fQ.ef9fVrEa-OIMVE0WUxVvFTPtxfHgr1R7w8Se57Aglu4"

# Find and activate the Telegram workflow
WORKFLOW_ID=$(curl -s -X GET http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $API_KEY" \
  | jq -r '.data[] | select(.name | contains("Telegram")) | .id' | head -1)

if [ -n "$WORKFLOW_ID" ]; then
    curl -s -X POST "http://localhost:5678/api/v1/workflows/$WORKFLOW_ID/activate" \
      -H "X-N8N-API-KEY: $API_KEY" > /dev/null
    echo -e "${GREEN}✅ Telegram workflow activated${NC}"
else
    echo -e "${YELLOW}⚠️ No Telegram workflow found. Please activate manually in n8n UI${NC}"
fi

echo ""
echo -e "${GREEN}✅ n8n is now running with webhook support!${NC}"
echo ""
echo "Test the webhook:"
echo "  curl -X POST https://techlead.blucas.ca/webhook/telegram-bot-webhook \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"test\": \"data\"}'"
echo ""
echo "Or send /help to @techLEAD_n8n_bot on Telegram"