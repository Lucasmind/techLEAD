# /techlead-setup - Complete techLEAD Installation

You are helping the user complete techLEAD setup after plugin installation.

## What This Command Does

This command runs the `finalsetup.sh` script to:
- Create `.techlead/` directory structure
- Install monitoring scripts (monitor.sh, monitor-runner.sh)
- Install hook scripts for state management
- Copy guidance templates
- Create state and log files
- Set up default configuration

## Your Task

1. **Locate the finalsetup.sh script:**
   - If techLEAD was installed as a plugin, the script is in the plugin directory
   - Check common locations:
     - `./scripts/finalsetup.sh` (if in techLEAD repo)
     - Plugin installation directory

2. **Run the script:**
   ```bash
   bash ./scripts/finalsetup.sh
   ```

   If the script is not found in the current directory, help the user locate it:
   ```bash
   find ~/.claude/plugins -name "finalsetup.sh" 2>/dev/null
   ```

3. **Verify setup completed:**
   After running the script, verify:
   - `.techlead/` directory exists
   - `.techlead/monitor.sh` and `.techlead/monitor-runner.sh` exist and are executable
   - `.techlead/hooks/` contains hook scripts
   - `.techlead/config.json` exists

4. **Provide next steps:**
   After successful setup, inform the user:

   ```
   ✅ techLEAD setup complete!

   Next steps:
   1. Set up GitHub Actions workflows:
      https://docs.claude.com/en/docs/claude-code/github-actions

      Or use: /install-github-app

   2. If using self-hosted runners, configure with label 'techlead'

   3. Start orchestrating: /techlead
   ```

## Error Handling

If the script fails:
- Check if the user is in the correct directory
- Verify the script has execute permissions
- Check for error messages in the script output
- Offer to run setup steps manually if needed

## Important Notes

- This command should be run AFTER installing the techLEAD plugin
- It's safe to run multiple times (won't overwrite existing config)
- GitHub Actions workflows must be set up separately using Claude's official documentation
