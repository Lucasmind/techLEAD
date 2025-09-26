#!/bin/bash

# Setup Cloudflare Tunnel for Tech LEAD Telegram Bot

echo "🌐 Setting up Cloudflare Tunnel for Tech LEAD"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if we need to add DNS record
echo -e "${YELLOW}Step 1: DNS Configuration${NC}"
echo "Please add a CNAME record in your Cloudflare DNS:"
echo ""
echo "  Type: CNAME"
echo "  Name: techlead"
echo "  Target: 77ab3cea-017a-4c05-959c-9320d2389fed.cfargotunnel.com"
echo "  Proxy: ON (orange cloud)"
echo ""
echo "Press Enter once you've added the DNS record..."
read

# Update cloudflared config
echo -e "${YELLOW}Step 2: Updating Cloudflare Tunnel Configuration${NC}"
sudo cp /home/rob/.cloudflared/config.yml /home/rob/.cloudflared/config.yml.backup
sudo cp /media/rob/Workspace/Development/techLEAD/cloudflare/config.yml /home/rob/.cloudflared/config.yml

# Restart cloudflared
echo -e "${YELLOW}Step 3: Restarting Cloudflare Tunnel${NC}"
sudo systemctl restart cloudflared
sleep 3

# Check status
if sudo systemctl is-active --quiet cloudflared; then
    echo -e "${GREEN}✅ Cloudflare Tunnel is running${NC}"
else
    echo -e "${YELLOW}⚠️ Cloudflare Tunnel failed to start. Check logs with: sudo journalctl -u cloudflared${NC}"
    exit 1
fi

# Set Telegram webhook
echo -e "${YELLOW}Step 4: Setting Telegram Webhook${NC}"
source /media/rob/Workspace/Development/techLEAD/.env

WEBHOOK_URL="https://techlead.blucas.ca/webhook/telegram-webhook"

echo "Setting webhook to: $WEBHOOK_URL"

response=$(curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/setWebhook" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"${WEBHOOK_URL}\"}")

if echo "$response" | grep -q '"ok":true'; then
    echo -e "${GREEN}✅ Telegram webhook set successfully!${NC}"
else
    echo -e "${YELLOW}⚠️ Failed to set webhook:${NC}"
    echo "$response" | jq '.'
fi

# Verify webhook
echo ""
echo -e "${YELLOW}Step 5: Verifying Webhook${NC}"
curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getWebhookInfo" | jq '.'

echo ""
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo ""
echo "Your Tech LEAD bot webhook is now accessible at:"
echo "  https://techlead.blucas.ca/webhook/telegram-webhook"
echo ""
echo "Test it by sending a message to @techLEAD_n8n_bot on Telegram!"