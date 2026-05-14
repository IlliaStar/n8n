---
name: deploy
description: This skill should be used when the user asks to "deploy", "deploy flows", "deploy workflows", "push workflows to n8n", "update n8n", or wants to deploy n8n workflow files from this project to the local n8n instance.
version: 1.0.0
---

# Deploy n8n Workflows

Run `deploy.sh` (located in the same directory as this skill) from the project root.

## Steps

1. Warn the user that **n8n must be stopped** before deploying to avoid write conflicts.
2. Ask for confirmation to proceed.
3. Run the script:

```bash
bash .claude/skills/deploy/deploy.sh
```

4. Report the output to the user.
5. Check if n8n is already running by attempting `curl -s http://localhost:5678/healthz`. If it responds, skip the start step. Otherwise start n8n in the background:

```bash
n8n start
```

Wait for the line `Editor is now accessible via: http://localhost:5678` in the output.

6. Open the browser:

```bash
start http://localhost:5678
```

7. Remind the user of manual steps still required in the n8n UI:
   - Set `SLACK_WEBHOOK_URL` and `GOOGLE_SHEET_ID` in the **Config** node (if still placeholder values)
   - Select Google credentials in both **Log to Sheets** nodes
   - Workflow **Settings → Error Workflow** → select `Daily Briefing — Error Handler`
   - Activate the workflow
