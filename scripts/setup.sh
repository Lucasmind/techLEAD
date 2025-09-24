#!/bin/bash

# Tech LEAD Setup Script
set -e

echo "🚀 Setting up Tech LEAD..."

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting." >&2; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose is required but not installed. Aborting." >&2; exit 1; }
command -v claude >/dev/null 2>&1 || { echo "Claude CLI is required but not installed. Please install from claude.ai" >&2; exit 1; }

# Create .env from example if not exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your credentials"
fi

# Start services
echo "Starting Docker services..."
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Check service health
docker-compose ps

echo "✅ Services started successfully!"
echo ""
echo "Next steps:"
echo "1. Edit .env with your credentials"
echo "2. Access NocoDB at http://localhost:8080"
echo "3. Run schema/init.sql in NocoDB"
echo "4. Import n8n workflows from workflows/ directory"
echo "5. Configure Telegram bot webhook"
echo ""
echo "Run './scripts/test-claude-cli.sh' to verify Claude CLI is working"