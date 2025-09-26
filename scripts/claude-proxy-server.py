#!/usr/bin/env python3
"""
Simple HTTP proxy server to allow n8n container to execute Claude CLI on host
Run this on the host machine to provide Claude CLI access to n8n
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import subprocess
import sys
import os

class ClaudeProxyHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/execute':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)

            try:
                data = json.loads(post_data.decode('utf-8'))
                prompt = data.get('prompt', 'Hello')
                use_json = data.get('json', False)
                max_turns = data.get('max_turns', 1)
                test_case = data.get('test_case', None)

                # Build command based on test case
                if test_case:
                    cmd = self._build_test_command(test_case, data)
                else:
                    # Build basic command
                    cmd = ['claude', '-p', prompt]
                    if use_json:
                        cmd.extend(['--output-format', 'json'])
                    if max_turns > 1:
                        cmd.extend(['--max-turns', str(max_turns)])

                # Execute command
                if isinstance(cmd, str):
                    # Shell command
                    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
                else:
                    # Direct command
                    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)

                response = {
                    'success': result.returncode == 0,
                    'stdout': result.stdout,
                    'stderr': result.stderr,
                    'returncode': result.returncode,
                    'command': cmd if isinstance(cmd, list) else cmd
                }

                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(response).encode('utf-8'))

            except subprocess.TimeoutExpired:
                self.send_error(504, "Command timeout")
            except Exception as e:
                self.send_error(500, str(e))
        else:
            self.send_error(404, "Not found")

    def _build_test_command(self, test_case, data):
        """Build command based on test case"""
        if test_case == "simple":
            return 'claude -p "What is the capital of France?"'
        elif test_case == "math":
            return 'claude -p "Calculate: (15 * 23) + (47 / 3) - 12"'
        elif test_case == "json":
            return 'claude -p "List 3 programming languages with their creation years" --output-format json'
        elif test_case == "tech_lead":
            context = {
                "role": "Tech LEAD",
                "task": "select_issue",
                "issues": [
                    {"number": 1, "title": "Add user authentication", "priority": "high"},
                    {"number": 2, "title": "Fix typo in README", "priority": "low"},
                    {"number": 3, "title": "Implement API endpoints", "priority": "medium"}
                ]
            }
            json_str = json.dumps(context)
            return f"echo '{json_str}' | claude -p 'You are Tech LEAD. Analyze these issues and select which one to work on first. Output your decision as JSON with fields: selected_issue_number, reasoning, estimated_hours' --output-format json"
        else:
            prompt = data.get('prompt', 'Hello Claude')
            return ['claude', '-p', prompt]

    def log_message(self, format, *args):
        """Override to reduce logging"""
        if '/execute' in args[0]:
            print(f"[Claude Proxy] Executing command")
        return

if __name__ == '__main__':
    PORT = 8888
    print(f"Starting Claude Proxy Server on port {PORT}")
    print(f"n8n can now call http://192.168.1.237:{PORT}/execute")
    print("Press Ctrl+C to stop")

    server = HTTPServer(('0.0.0.0', PORT), ClaudeProxyHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        sys.exit(0)