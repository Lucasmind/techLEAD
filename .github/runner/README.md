# GitHub Actions Runner (Docker)

Self-hosted GitHub Actions runner for techLEAD workflows.

## Quick Start

### Option 1: Use GitHub-Hosted Runners (Recommended for beginners)

If you don't want to set up a local runner, you can use GitHub's hosted runners instead:

1. Edit `.github/workflows/claude.yml` and `.github/workflows/claude-code-review.yml`
2. Comment out the `runs-on: [self-hosted, linux, x64, techlead]` line
3. Uncomment the `runs-on: ubuntu-latest` line
4. Push your changes to GitHub

**That's it!** Your workflows will run on GitHub's infrastructure.

### Option 2: Self-Hosted Runner (Advanced)

For more control and faster execution, run your own runner locally:

#### Prerequisites

- Docker and Docker Compose installed
- GitHub Personal Access Token with `repo` and `workflow` scopes
- Claude OAuth credentials

#### Setup Steps

1. **Create Claude credentials directory:**
   ```bash
   mkdir -p claude-credentials
   # Copy your Claude OAuth credentials to claude-credentials/
   # Location on your system: ~/.claude/.credentials.json
   cp ~/.claude/.credentials.json claude-credentials/
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   vim .env
   ```

   Update these required values:
   ```bash
   GITHUB_TOKEN=ghp_your_github_token_here
   GITHUB_REPOSITORY=yourusername/yourrepo
   CONTAINER_NAME=techlead-runner
   RUNNER_LABELS=self-hosted,linux,x64,techlead
   ```

3. **Build and start the runner:**
   ```bash
   docker-compose up -d --build
   ```

4. **Verify it's running:**
   ```bash
   docker logs techlead-runner
   ```

   You should see:
   ```
   √ Connected to GitHub
   Current runner version: '2.328.0'
   Listening for Jobs
   ```

5. **Update techLEAD monitoring config:**
   ```bash
   # Edit your project's .techlead/config.json
   vim ../../.techlead/config.json
   ```

   Set the container name:
   ```json
   {
     "runner": {
       "container_name": "techlead-runner"
     }
   }
   ```

## GitHub Personal Access Token

Create a token at: https://github.com/settings/tokens

**Required scopes:**
- `repo` (Full control of private repositories)
- `workflow` (Update GitHub Action workflows)

## Claude OAuth Credentials

The runner needs your Claude credentials to run Claude Code actions.

**Location:** `~/.claude/.credentials.json`

Copy this file to `claude-credentials/.credentials.json`:
```bash
cp ~/.claude/.credentials.json claude-credentials/
```

## Monitoring

Check runner status:
```bash
docker logs techlead-runner -f
```

Restart runner:
```bash
docker-compose restart
```

Stop runner:
```bash
docker-compose down
```

## Troubleshooting

### Runner not appearing in GitHub

1. Check logs: `docker logs techlead-runner`
2. Verify `GITHUB_TOKEN` has correct scopes
3. Verify `GITHUB_REPOSITORY` format (owner/repo)
4. Check token isn't expired

### Workflows not triggering

1. Verify runner labels match workflow files
2. In `.github/workflows/claude.yml`, check:
   ```yaml
   runs-on: [self-hosted, linux, x64, techlead]
   ```
   Must match `RUNNER_LABELS` in `.env`

### Claude credentials not found

1. Verify `claude-credentials/.credentials.json` exists
2. Check file permissions (should be readable by Docker)
3. Rebuild container: `docker-compose up -d --build`

## Multiple Runners

To run multiple runners (parallel execution):

1. Uncomment `github-runner-2` section in `docker-compose.yml`
2. Add to `.env`:
   ```bash
   CONTAINER_NAME_2=techlead-runner-2
   RUNNER_NAME_2=techlead-runner-2
   ```
3. Restart: `docker-compose up -d`

## Advanced Configuration

### Custom Node.js Packages

Edit `Dockerfile` and add to the npm install section:
```dockerfile
RUN npm install -g your-package-name
```

### Different Node Version

Edit `Dockerfile` line 63:
```dockerfile
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
```

### Custom System Dependencies

Add to the `apt-get install` section in `Dockerfile`.

## Security Notes

- **Never commit `.env`** - it contains your GitHub token
- **Never commit `claude-credentials/`** - contains OAuth secrets
- Both are in `.gitignore` by default
- Rotate tokens regularly
- Use separate tokens for different projects

## Updating

Update runner version:

1. Edit `docker-compose.yml`:
   ```yaml
   args:
     RUNNER_VERSION: 2.330.0  # Update version
   ```

2. Rebuild:
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

## Uninstall

Remove runner from GitHub and stop container:

```bash
docker-compose down -v
rm -rf claude-credentials
```

Then go to your GitHub repository settings → Actions → Runners and delete the runner.

## Support

For issues or questions:
- Check techLEAD main README.md
- Open an issue on GitHub
- Review Docker logs: `docker logs techlead-runner`
