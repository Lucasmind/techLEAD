#!/bin/bash

# Script to get your Telegram Chat ID

source /media/rob/Workspace/Development/techLEAD/.env

echo "📱 Telegram Bot Chat ID Finder"
echo "==============================="
echo ""
echo "Your bot name: @$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" | jq -r '.result.username')"
echo ""
echo "Please follow these steps:"
echo "1. Open Telegram"
echo "2. Search for your bot by its username (shown above)"
echo "3. Send any message to your bot (like 'Hello')"
echo "4. Press Enter here to continue..."
read

# Get the latest updates
UPDATES=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates")

# Extract chat IDs
echo ""
echo "Found the following chat IDs:"
echo "$UPDATES" | jq -r '.result[] | select(.message != null) | "Chat ID: \(.message.chat.id) | From: \(.message.from.first_name) | Message: \(.message.text)"'

CHAT_ID=$(echo "$UPDATES" | jq -r '.result[-1].message.chat.id // empty')

if [ ! -z "$CHAT_ID" ]; then
    echo ""
    echo "✅ Your Chat ID is: $CHAT_ID"
    echo ""
    echo "Would you like to update your .env file with this Chat ID? (y/n)"
    read -r response
    if [[ "$response" == "y" ]]; then
        sed -i "s/TELEGRAM_CHAT_ID=.*/TELEGRAM_CHAT_ID=$CHAT_ID/" /media/rob/Workspace/Development/techLEAD/.env
        echo "✅ Updated .env file with Chat ID: $CHAT_ID"
    fi
else
    echo ""
    echo "❌ No messages found. Please:"
    echo "1. Make sure you sent a message to your bot"
    echo "2. Try running this script again"
fi