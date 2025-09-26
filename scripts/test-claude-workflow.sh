#!/bin/bash

# Simple test script to trigger Claude workflows in n8n

echo "Testing Claude CLI Test workflow..."
echo "=================================="

# Test 1: Simple prompt
echo "Test 1: Simple question"
curl -X POST http://192.168.1.237:5678/webhook-test/claude-test \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is 2+2?"}' \
  2>/dev/null | python3 -m json.tool

echo ""
echo "Test 2: JSON output"
curl -X POST http://192.168.1.237:5678/webhook-test/claude-test \
  -H "Content-Type: application/json" \
  -d '{"prompt": "List 3 colors", "json": true}' \
  2>/dev/null | python3 -m json.tool

echo ""
echo "Testing Claude CLI Advanced workflow..."
echo "======================================="

# Test different cases
echo "Test 1: Simple question"
curl -X POST http://192.168.1.237:5678/webhook-test/claude-advanced \
  -H "Content-Type: application/json" \
  -d '{"test_case": "simple"}' \
  2>/dev/null | python3 -m json.tool

echo ""
echo "Test 2: Math calculation"
curl -X POST http://192.168.1.237:5678/webhook-test/claude-advanced \
  -H "Content-Type: application/json" \
  -d '{"test_case": "math"}' \
  2>/dev/null | python3 -m json.tool

echo ""
echo "Test 3: Tech LEAD decision"
curl -X POST http://192.168.1.237:5678/webhook-test/claude-advanced \
  -H "Content-Type: application/json" \
  -d '{"test_case": "tech_lead"}' \
  2>/dev/null | python3 -m json.tool