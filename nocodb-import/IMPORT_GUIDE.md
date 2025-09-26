# NocoDB Import Guide for Tech LEAD

## Step-by-Step Instructions

### 1. Import the Tables

In NocoDB (http://localhost:8810), in your `techLEAD` base:

#### Method A: CSV Import (Recommended)
1. Click **"Create a new Table"** or **"Import"**
2. Choose **"Upload CSV"**
3. Import these files in this order:
   - `projects_table.csv` - Main project configuration
   - `decisions_log.csv` - Decision audit trail (empty initially)
   - `work_log.csv` - Work execution log (empty initially)

#### Method B: JSON Import
1. Click **"Create a new Table"** or **"Import"**
2. Choose **"Upload JSON"**
3. Import `projects_table.json`

### 2. Configure Column Types

After importing, you may need to adjust column types:

#### projects_table
- `id`: Integer, Primary Key, Auto-increment
- `repository_url`: Single Line Text
- `project_identifier`: Single Line Text
- `current_focus`: Long Text
- `status`: Single Select (options: planning, active, blocked, complete, paused)
- `telegram_chat_id`: Single Line Text
- `context_summary`: Long Text
- `created_at`: DateTime
- `updated_at`: DateTime

#### decisions_log
- `id`: Integer, Primary Key, Auto-increment
- `project_id`: Integer (Link to projects_table if possible)
- `timestamp`: DateTime
- `decision_type`: Single Line Text
- `claude_input`: Long Text
- `claude_output`: Long Text
- `pm_feedback`: Long Text
- `final_decision`: Long Text
- `execution_status`: Single Select (options: pending, approved, rejected, completed, failed)

#### work_log
- `id`: Integer, Primary Key, Auto-increment
- `project_id`: Integer (Link to projects_table if possible)
- `issue_number`: Integer
- `pr_number`: Integer (nullable)
- `github_workflow`: Single Select (options: claude, claude-test, claude-review)
- `status`: Single Select (options: running, completed, failed, testing, reviewing)
- `started_at`: DateTime
- `completed_at`: DateTime (nullable)
- `error_message`: Long Text (nullable)
- `retry_count`: Integer (default: 0)

### 3. Set Up Relations (Optional but Recommended)

If NocoDB supports it in the UI:
1. Link `decisions_log.project_id` → `projects_table.id`
2. Link `work_log.project_id` → `projects_table.id`

### 4. Verify the Import

After importing, you should see:
- **projects_table**: 1 row with your Tech LEAD project
- **decisions_log**: Empty (will be populated as Claude makes decisions)
- **work_log**: Empty (will be populated as work is executed)

### 5. Test the API Access

Run this command to verify NocoDB API access:
```bash
source /media/rob/Workspace/Development/techLEAD/.env
curl -X GET "http://localhost:8810/api/v1/db/data/nc/techLEAD/projects_table" \
  -H "xc-token: ${NOCODB_API_TOKEN}" | jq '.'
```

You should see your project data returned.

## Notes

- The CSV files include one sample project row that matches your configuration
- The `status` field is set to "active" so the orchestrator will process it
- Your Telegram chat ID (191718134) is already configured
- The repository URL points to your Tech LEAD GitHub repo

## Next Steps

Once the tables are imported:
1. The Main Orchestrator workflow will fetch from `projects_table`
2. Decisions will be logged to `decisions_log`
3. Work execution will be tracked in `work_log`