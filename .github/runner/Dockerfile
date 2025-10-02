FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=test

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    zip \
    unzip \
    wget \
    libicu70 \
    liblttng-ust1 \
    libkrb5-3 \
    zlib1g \
    libssl3 \
    python3 \
    python3-pip \
    inotify-tools \
    build-essential \
    openjdk-11-jre-headless \
    # Playwright browser dependencies (optional, for E2E testing)
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libatspi2.0-0 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libxcb1 \
    libxkbcommon0 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI and GitHub CLI
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin gh \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 and testing tools
# Note: Adjust Node version based on your project needs
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Optional: Install global npm packages your project needs
# Uncomment and customize as needed
# RUN npm install -g firebase-tools vitest @vitest/ui @vitest/coverage-v8

# Create runner user
RUN useradd -m runner && \
    usermod -aG sudo runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create necessary directories with proper permissions
RUN mkdir -p /home/runner/.claude /home/runner/.cache/claude /home/runner/.local/bin \
    /home/runner/test-results /home/runner/coverage && \
    chown -R runner:runner /home/runner/.claude /home/runner/.cache /home/runner/.local \
    /home/runner/test-results /home/runner/coverage && \
    chmod -R 755 /home/runner/.cache /home/runner/.local

# Create the Claude installation watcher script
# This monitors for Claude installation and sets up project indexing
RUN cat > /home/runner/claude-watcher.sh << 'EOF'
#!/bin/bash

setup_project_index() {
    echo "[Claude Watcher] Claude detected, setting up project index tool..."

    if [ ! -d "$HOME/.claude-code-project-index" ]; then
        git clone https://github.com/ericbuess/claude-code-project-index.git $HOME/.claude-code-project-index
        chmod +x $HOME/.claude-code-project-index/scripts/*.sh $HOME/.claude-code-project-index/scripts/*.py
    fi

    sleep 2

    if [ -f "$HOME/.claude/settings.json" ]; then
        cp $HOME/.claude/settings.json $HOME/.claude/settings.json.bak

        cat > $HOME/.claude/settings.json << 'SETTINGS'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude-code-project-index/scripts/run_python.sh $HOME/.claude-code-project-index/scripts/i_flag_hook.py",
            "timeout": 20
          }
        ]
      }
    ]
  }
}
SETTINGS
        echo "[Claude Watcher] Project index hooks configured successfully"
    fi

    touch $HOME/.claude-project-index-configured
}

echo "[Claude Watcher] Starting to monitor for Claude installation..."

if [ -f "$HOME/.local/bin/claude" ] && [ ! -f "$HOME/.claude-project-index-configured" ]; then
    setup_project_index
fi

while true; do
    inotifywait -q -e create,moved_to --include 'claude$' $HOME/.local/bin 2>/dev/null

    if [ -f "$HOME/.local/bin/claude" ] && [ ! -f "$HOME/.claude-project-index-configured" ]; then
        setup_project_index
        break
    fi

    sleep 5
    if [ -f "$HOME/.local/bin/claude" ] && [ ! -f "$HOME/.claude-project-index-configured" ]; then
        setup_project_index
        break
    fi
done

echo "[Claude Watcher] Monitoring complete, exiting."
EOF

RUN chmod +x /home/runner/claude-watcher.sh && chown runner:runner /home/runner/claude-watcher.sh

# Copy Claude credentials
# IMPORTANT: You need to create a claude-credentials/ directory with your Claude OAuth credentials
COPY claude-credentials/ /home/runner/.claude/
RUN chown -R runner:runner /home/runner/.claude && chmod -R 600 /home/runner/.claude

WORKDIR /home/runner

# Download GitHub Actions runner
ARG RUNNER_VERSION=2.328.0
RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && mkdir -p /home/runner/_work \
    && chown -R runner:runner /home/runner \
    && chmod -R 755 /home/runner

COPY start.sh /home/runner/start.sh
RUN chmod +x /home/runner/start.sh && chown runner:runner /home/runner/start.sh

USER runner

ENTRYPOINT ["/home/runner/start.sh"]
