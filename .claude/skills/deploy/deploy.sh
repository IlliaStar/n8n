#!/usr/bin/env bash
set -euo pipefail

WORKFLOWS_DIR="$(cd "$(dirname "$0")/../../.." && pwd)/workflows"

# --- Stop all n8n processes ---
echo "Stopping any running n8n processes..."
# Kill all node processes with n8n in their command line (catches orphans)
powershell -NoProfile -Command "
  Get-WmiObject Win32_Process |
  Where-Object { \$_.CommandLine -like '*n8n*' } |
  ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }
" > /dev/null 2>&1 || true
# Wait for port to be free
for i in $(seq 1 15); do
  curl -s http://localhost:5678/healthz > /dev/null 2>&1 || break
  sleep 1
done

# --- Import workflows (order matters: error handler first) ---
echo ""
echo "Importing n8n workflows..."
echo ""

n8n import:workflow --input="$WORKFLOWS_DIR/error-handler.json"
n8n import:workflow --input="$WORKFLOWS_DIR/daily-briefing.json"

echo ""
echo "Import complete."

# --- Start n8n ---
echo "Starting n8n..."
n8n start &
N8N_PID=$!

# Wait until ready
for i in $(seq 1 30); do
  if curl -s http://localhost:5678/healthz > /dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo ""
echo "n8n is ready at http://localhost:5678"

# --- Open browser ---
if command -v start > /dev/null 2>&1; then
  start http://localhost:5678
elif command -v xdg-open > /dev/null 2>&1; then
  xdg-open http://localhost:5678
elif command -v open > /dev/null 2>&1; then
  open http://localhost:5678
fi

echo ""
echo "Remaining steps in the n8n UI:"
echo "  1. Set SLACK_WEBHOOK_URL and GOOGLE_SHEET_ID in the Config node"
echo "  2. Select Google credentials in both Log to Sheets nodes"
echo "  3. Workflow Settings → Error Workflow → select 'Daily Briefing — Error Handler'"
echo "  4. Activate the workflow"
echo ""
