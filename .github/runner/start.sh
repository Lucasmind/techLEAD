#!/bin/bash

# Start the Claude watcher in the background
/home/runner/claude-watcher.sh > /home/runner/claude-watcher.log 2>&1 &

# GitHub runner startup script
set -e

# Required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is required"
    exit 1
fi

if [ -z "$GITHUB_REPOSITORY" ]; then
    echo "Error: GITHUB_REPOSITORY environment variable is required (format: owner/repo)"
    exit 1
fi

# Optional environment variables
RUNNER_NAME=${RUNNER_NAME:-"docker-runner-$(hostname)"}
RUNNER_WORKDIR=${RUNNER_WORKDIR:-"/home/runner/_work"}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,linux,x64,docker"}

# Get registration token
echo "Requesting registration token..."
REG_TOKEN=$(curl -sX POST -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/registration-token" | jq -r .token)

if [ -z "$REG_TOKEN" ] || [ "$REG_TOKEN" = "null" ]; then
    echo "Error: Failed to get registration token. Check your GITHUB_TOKEN and GITHUB_REPOSITORY."
    exit 1
fi

# Configure the runner
echo "Configuring runner..."
./config.sh \
    --url "https://github.com/${GITHUB_REPOSITORY}" \
    --token "${REG_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --work "${RUNNER_WORKDIR}" \
    --labels "${RUNNER_LABELS}" \
    --unattended \
    --replace

# Function to handle cleanup
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token "${REG_TOKEN}"
}

# Set up signal handlers for graceful shutdown
trap cleanup SIGTERM SIGINT

# Run the runner
echo "Starting runner..."
./run.sh &

# Wait for the runner process
wait $!
