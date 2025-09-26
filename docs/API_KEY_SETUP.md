# Setting Up n8n API Key Permanently

## Option 1: Using .env file (RECOMMENDED)

1. **Edit the `.env` file** in the project root:
   ```bash
   nano /media/rob/Workspace/Development/techLEAD/.env
   ```

2. **Replace the placeholder** with your actual API key:
   ```env
   N8N_API_KEY=n8n_api_your_actual_key_here
   ```

3. **Load the environment variables** in your current session:
   ```bash
   source /media/rob/Workspace/Development/techLEAD/.env
   export $(cat /media/rob/Workspace/Development/techLEAD/.env | grep -v '^#' | xargs)
   ```

## Option 2: Add to your shell profile (User-wide)

1. **For bash** (~/.bashrc):
   ```bash
   echo 'export N8N_API_URL="http://localhost:5678"' >> ~/.bashrc
   echo 'export N8N_API_KEY="your-actual-api-key"' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **For zsh** (~/.zshrc):
   ```bash
   echo 'export N8N_API_URL="http://localhost:5678"' >> ~/.zshrc
   echo 'export N8N_API_KEY="your-actual-api-key"' >> ~/.zshrc
   source ~/.zshrc
   ```

## Option 3: Using systemd environment (System-wide)

1. **Create environment file**:
   ```bash
   sudo nano /etc/environment.d/n8n.conf
   ```

2. **Add the variables**:
   ```
   N8N_API_URL=http://localhost:5678
   N8N_API_KEY=your-actual-api-key
   ```

## Option 4: If running n8n with Docker

Add to your n8n container in docker-compose.yml:

```yaml
services:
  n8n:
    image: n8nio/n8n
    environment:
      - N8N_API_URL=http://localhost:5678
      - N8N_API_KEY=${N8N_API_KEY}
      - N8N_PUBLIC_API_ENABLED=true
```

## Option 5: Create a wrapper script

Create `/media/rob/Workspace/Development/techLEAD/scripts/setup-env.sh`:

```bash
#!/bin/bash
# Tech LEAD Environment Setup

# Load environment variables
export N8N_API_URL="http://localhost:5678"
export N8N_API_KEY="your-actual-api-key"
export NOCODB_API_URL="http://localhost:8080"

echo "✅ Tech LEAD environment configured"
```

Then run: `source scripts/setup-env.sh`

## Getting your n8n API Key

1. Open n8n UI: http://localhost:5678
2. Go to **Settings** (bottom left)
3. Click on **API**
4. Click **Create an API Key**
5. Copy the generated key
6. Use it in any of the options above

## Verify Configuration

After setting up, verify with:
```bash
echo "N8N_API_URL: $N8N_API_URL"
echo "N8N_API_KEY: $N8N_API_KEY"

# Test the connection
curl -X GET "$N8N_API_URL/api/v1/workflows" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json"
```

## Security Note

- Never commit the `.env` file with real keys to git
- The `.gitignore` already excludes `.env`
- Use `.env.example` as a template for others