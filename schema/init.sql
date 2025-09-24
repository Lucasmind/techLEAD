-- Tech LEAD Database Schema
-- Initialize NocoDB tables for project management

-- Projects table for tracking active work
CREATE TABLE IF NOT EXISTS projects_table (
  id SERIAL PRIMARY KEY,
  repository_url VARCHAR(255) NOT NULL,
  project_identifier VARCHAR(255),
  current_focus TEXT,
  status VARCHAR(50) DEFAULT 'planning' CHECK (status IN ('planning', 'active', 'blocked', 'complete', 'paused')),
  telegram_chat_id VARCHAR(100),
  context_summary TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Decision log for audit trail
CREATE TABLE IF NOT EXISTS decisions_log (
  id SERIAL PRIMARY KEY,
  project_id INTEGER REFERENCES projects_table(id) ON DELETE CASCADE,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  decision_type VARCHAR(100) NOT NULL,
  claude_input TEXT,
  claude_output TEXT,
  pm_feedback TEXT,
  final_decision TEXT,
  execution_status VARCHAR(50) DEFAULT 'pending'
);

-- Work log for tracking GitHub workflows
CREATE TABLE IF NOT EXISTS work_log (
  id SERIAL PRIMARY KEY,
  project_id INTEGER REFERENCES projects_table(id) ON DELETE CASCADE,
  issue_number INTEGER NOT NULL,
  pr_number INTEGER,
  github_workflow VARCHAR(50) CHECK (github_workflow IN ('claude', 'claude-test', 'claude-review')),
  status VARCHAR(50) DEFAULT 'running',
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0
);

-- Create indexes for performance
CREATE INDEX idx_projects_status ON projects_table(status);
CREATE INDEX idx_decisions_project ON decisions_log(project_id);
CREATE INDEX idx_work_project ON work_log(project_id);
CREATE INDEX idx_work_issue ON work_log(issue_number);

-- Create update trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE
  ON projects_table FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default project (optional)
-- INSERT INTO projects_table (repository_url, project_identifier, status, context_summary)
-- VALUES ('https://github.com/yourusername/yourrepo', 'INITIAL_PROJECT', 'planning', 'Initial project setup');