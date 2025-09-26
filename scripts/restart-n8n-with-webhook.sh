#!/bin/bash

# Restart n8n with proper webhook URL configuration

echo "🔄 Restarting n8n with correct webhook configuration"
echo "====================================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}This will restart n8n with the correct webhook URL.${NC}"
echo -e "${YELLOW}Your workflows and data will be preserved.${NC}"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

echo -e "${YELLOW}Stopping current n8n container...${NC}"
docker stop n8n

echo -e "${YELLOW}Starting n8n with webhook configuration...${NC}"
docker run -d --rm \
  --name n8n \
  -p 5678:5678 \
  -e N8N_PROTOCOL=https \
  -e N8N_HOST=techlead.blucas.ca \
  -e WEBHOOK_URL=https://techlead.blucas.ca/ \
  -e N8N_ENCRYPTION_KEY=88ba1bdc42e648699ae82a03de4f4375afc5aaca0382287158ca64b9c8c0671b \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest

# Wait for n8n to start
echo -e "${YELLOW}Waiting for n8n to start...${NC}"
sleep 10

# Check if n8n is running
if curl -s http://localhost:5678 > /dev/null; then
    echo -e "${GREEN}✅ n8n is running${NC}"
else
    echo -e "${RED}❌ n8n failed to start${NC}"
    echo "Check logs with: docker logs n8n"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ n8n restarted with webhook support!${NC}"
echo ""
echo "Now you need to:"
echo "1. Open n8n: http://192.168.1.237:5678"
echo "2. Find your Telegram webhook workflow"
echo "3. Make sure it's activated (toggle on)"
echo "4. Test by sending /help to @techLEAD_n8n_bot"
echo ""
echo "Webhooks will now work at: https://techlead.blucas.ca/webhook/*"