#!/bin/bash

# Update cloudflared configuration for Tech LEAD

echo "🌐 Updating Cloudflare Tunnel Configuration"
echo "==========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Backup current config
echo -e "${YELLOW}Creating backup of current config...${NC}"
sudo cp /etc/cloudflared/config.yml "/etc/cloudflared/config.yml.backup-$(date +%Y%m%d-%H%M%S)"

# Copy new config
echo -e "${YELLOW}Applying new configuration...${NC}"
sudo cp /media/rob/Workspace/Development/techLEAD/cloudflare/cloudflared-config-updated.yml /etc/cloudflared/config.yml

# Restart cloudflared service
echo -e "${YELLOW}Restarting cloudflared service...${NC}"
sudo systemctl restart cloudflared

# Wait for service to start
sleep 3

# Check service status
if sudo systemctl is-active --quiet cloudflared; then
    echo -e "${GREEN}✅ Cloudflare tunnel service is running${NC}"
else
    echo -e "${RED}❌ Cloudflare tunnel failed to start${NC}"
    echo "Check logs with: sudo journalctl -u cloudflared -n 50"
    exit 1
fi

# Test the new route
echo ""
echo -e "${YELLOW}Testing Tech LEAD route...${NC}"
response=$(curl -s -o /dev/null -w "%{http_code}" https://techlead.blucas.ca/)

if [ "$response" = "200" ] || [ "$response" = "404" ]; then
    echo -e "${GREEN}✅ Route is working (HTTP $response)${NC}"
    echo ""
    echo "The tunnel is now routing:"
    echo "  https://techlead.blucas.ca → http://192.168.1.237:5678"
else
    echo -e "${RED}❌ Route test failed (HTTP $response)${NC}"
fi

echo ""
echo -e "${GREEN}Configuration updated successfully!${NC}"
echo ""
echo "Next step: Test the Telegram webhook at https://techlead.blucas.ca/webhook/..."