#!/bin/bash
# Tech LEAD Environment Setup Script
# This script loads all necessary environment variables for Tech LEAD

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Loading Tech LEAD environment...${NC}"

# Check if .env file exists
ENV_FILE="/media/rob/Workspace/Development/techLEAD/.env"
if [ -f "$ENV_FILE" ]; then
    # Export variables from .env file
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
    echo -e "${GREEN}✅ Environment variables loaded from .env${NC}"
else
    echo -e "${YELLOW}⚠️  .env file not found at $ENV_FILE${NC}"
    echo "Creating from template..."
    cp "${ENV_FILE}.example" "$ENV_FILE" 2>/dev/null
    echo "Please edit $ENV_FILE with your actual API keys"
    exit 1
fi

# Verify critical variables
if [ -z "$N8N_API_KEY" ] || [ "$N8N_API_KEY" = "your-actual-n8n-api-key-here" ]; then
    echo -e "${YELLOW}⚠️  N8N_API_KEY not configured${NC}"
    echo "Please add your n8n API key to the .env file"
    echo "Get it from: http://localhost:5678 -> Settings -> API"
else
    echo -e "${GREEN}✅ N8N API configured${NC}"
fi

# Display current configuration
echo -e "\n${YELLOW}Current Configuration:${NC}"
echo "N8N_API_URL: ${N8N_API_URL:-not set}"
echo "N8N_API_KEY: ${N8N_API_KEY:0:20}..." # Show only first 20 chars for security
echo "NOCODB_API_URL: ${NOCODB_API_URL:-not set}"
echo "TELEGRAM_BOT_TOKEN: ${TELEGRAM_BOT_TOKEN:0:10}..." # Show only first 10 chars

# Test n8n connection if API key is set
if [ ! -z "$N8N_API_KEY" ] && [ "$N8N_API_KEY" != "your-actual-n8n-api-key-here" ]; then
    echo -e "\n${YELLOW}Testing n8n API connection...${NC}"
    response=$(curl -s -o /dev/null -w "%{http_code}" "${N8N_API_URL}/api/v1/workflows" -H "X-N8N-API-KEY: ${N8N_API_KEY}")
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}✅ n8n API connection successful${NC}"
    else
        echo -e "${YELLOW}⚠️  n8n API connection failed (HTTP $response)${NC}"
        echo "Please verify your API key and that n8n is running"
    fi
fi

echo -e "\n${GREEN}Environment ready! You can now run Tech LEAD commands.${NC}"