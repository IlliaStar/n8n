# Demo Script — Daily Weather Briefing

## What this workflow does

**Daily Weather Briefing** is an automated morning weather monitor for Krakow.

Every day at 08:00 it:
1. Fetches the day's forecast from the Open-Meteo API (free, no API key)
2. Evaluates whether conditions are critical — extreme heat (>30°C), frost (<0°C), heavy rain (>10mm), or thunderstorm
3. **If critical** — sends an immediate Slack alert with the reason
4. **Always** — logs the full forecast to a Google Sheet for historical tracking
5. **If it fails** — a dedicated error handler fires automatically and sends a Slack alert with the error details

No manual intervention needed. If something goes wrong or the weather is dangerous, you find out instantly.

---

## Setup before demo

1. Open **Daily Weather Briefing** in n8n
2. Make sure the workflow is **not active** (to avoid accidental scheduled runs)
3. Click **Fetch Weather** node → **Output** tab → click the pin icon to lock output

---

## Scenario 1 — Normal run, no alert

**Story:** It's a mild spring day in Krakow. The workflow runs, fetches weather, decides nothing is critical, and silently logs the data to Google Sheets.

**Paste into pinned data:** `01-normal-weather.json`

**Click:** Execute workflow

**What to show:**
- `Transform Data` output: `is_critical: false`, `alert_reason: "None"`
- `Is Critical?` routes to the **false** branch
- `Log to Sheets (Normal)` runs — row appended to the sheet
- No Slack message sent

---

## Scenario 2 — Critical weather alert

**Story:** Extreme conditions hit at once — heatwave, frost overnight, violent thunderstorm, and 42mm of rain. All four thresholds are breached simultaneously.

**Paste into pinned data:** `02-critical-weather.json`

**Click:** Execute workflow

**What to show:**
- `Transform Data` output: `is_critical: true`
- `alert_reason`: `"High temp 35.8°C, Low temp -2.1°C, Heavy rain 42.5mm, Storm: Thunderstorm + heavy hail"`
- `Is Critical?` routes to the **true** branch
- `Send Slack Alert` fires — show the Slack message
- `Log to Sheets (Alert)` runs — row appended with all alert details

---

## Scenario 3 — API failure, error handler fires

**Story:** The weather API is unreachable. The workflow fails mid-run, and the error handler automatically fires and sends a Slack alert with full error context.

> ⚠️ Error handlers only fire on **production (scheduled) executions**, not manual ones. Follow the steps below to simulate a real scheduled run.

**Step 1 — Change the schedule trigger to every minute:**
1. Open **Daily Weather Briefing**
2. Click the **Schedule Trigger** node
3. Change the cron expression to `* * * * *` (every minute)
4. Save the node

**Step 2 — Break the Fetch Weather URL:**
1. Click the **Fetch Weather** node
2. Change the URL to something invalid, e.g. `https://invalid-api.example.com`
3. Save the node

**Step 3 — Activate and watch:**
1. Make sure **Daily Briefing — Error Handler** is Published (active)
2. Make sure the error handler is linked: **⋯ → Settings → Error Workflow → Daily Briefing — Error Handler**
3. Click **Publish** on the main workflow to activate it
4. Wait up to 1 minute for the scheduler to fire

**What to show:**
- **Executions** tab on the main workflow — execution marked as **failed**
- Switch to **Daily Briefing — Error Handler → Executions** — a new execution triggered automatically
- Slack message received with workflow name, error message, last node, and execution ID

**Step 4 — Clean up after demo:**
1. Deactivate the main workflow
2. Restore the Schedule Trigger to `0 8 * * *`
3. Restore the Fetch Weather URL to `https://api.open-meteo.com/v1/forecast`
4. Save and republish
