#!/bin/bash

# Test Tech LEAD Telegram Bot

echo "🤖 Testing Tech LEAD Telegram Bot"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check webhook status
echo -e "${YELLOW}Checking webhook status...${NC}"
webhook_info=$(curl -s "https://api.telegram.org/bot7550244232:AAFJyN4m9JncscjDxJaMK2Nv-OI8XNJ7Zf8/getWebhookInfo")
webhook_url=$(echo "$webhook_info" | jq -r '.result.url')
pending_updates=$(echo "$webhook_info" | jq -r '.result.pending_update_count')
last_error=$(echo "$webhook_info" | jq -r '.result.last_error_message // "none"')

echo "Webhook URL: $webhook_url"
echo "Pending updates: $pending_updates"
echo "Last error: $last_error"
echo ""

# Test the endpoint directly
echo -e "${YELLOW}Testing webhook endpoint...${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" https://techlead.blucas.ca/webhook/telegram-webhook)
if [ "$response" = "200" ] || [ "$response" = "405" ]; then
    echo -e "${GREEN}✅ Webhook endpoint is reachable (HTTP $response)${NC}"
else
    echo -e "${RED}❌ Webhook endpoint returned HTTP $response${NC}"
    echo "Make sure the Telegram Bot Handler workflow is ACTIVE in n8n"
fi
echo ""

# Send a test message
echo -e "${YELLOW}Sending test message via Telegram API...${NC}"
test_response=$(curl -s -X POST "https://api.telegram.org/bot7550244232:AAFJyN4m9JncscjDxJaMK2Nv-OI8XNJ7Zf8/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": "191718134",
    "text": "🧪 Test message from Tech LEAD setup script\n\nIf you see this, the bot is working!\n\nTry sending /help to see available commands."
  }')

if echo "$test_response" | grep -q '"ok":true'; then
    echo -e "${GREEN}✅ Test message sent successfully!${NC}"
    echo "Check your Telegram chat for the message"
else
    echo -e "${RED}❌ Failed to send test message${NC}"
    echo "$test_response" | jq '.'
fi
echo ""

echo -e "${YELLOW}To fully test the webhook:${NC}"
echo "1. Make sure the 'Tech LEAD - Telegram Bot Handler' workflow is ACTIVE in n8n"
echo "2. Send a message to @techLEAD_n8n_bot on Telegram"
echo "3. Check n8n execution history to see if the webhook received it"
echo ""
echo "Commands to test:"
echo "  /help - Show available commands"
echo "  /status - Get current status"
echo "  Hello - Test natural language processing"