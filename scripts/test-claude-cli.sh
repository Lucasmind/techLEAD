#!/bin/bash

# Test Claude CLI integration
echo "Testing Claude CLI..."

# Create test prompt
TEST_JSON='{"role":"Tech LEAD","task":"test","query":"What is 2+2?"}'

# Test Claude
echo "$TEST_JSON" | claude --prompt "You are Tech LEAD. Answer this simple test: what is 2+2? Return JSON: {\"answer\": \"your_answer\", \"status\": \"ok\"}"

if [ $? -eq 0 ]; then
    echo "✅ Claude CLI is working!"
else
    echo "❌ Claude CLI test failed. Check your installation."
    exit 1
fi