# Demo Script — Daily Weather Briefing

## What this workflow does

**Daily Weather Briefing** is an automated morning weather monitor for Krakow.

Every day at 08:00 it:
1. Fetches the day's forecast from the Open-Meteo API (free, no API key needed)
2. Evaluates whether conditions are critical — extreme heat (>30°C), frost (<0°C), heavy rain (>10mm), or thunderstorm
3. **If critical** — sends an immediate Slack alert with the reason
4. **If not critical** — logs the full forecast to a Google Sheet for historical tracking
5. **If it fails** — a dedicated error handler fires automatically and sends a Slack alert with the error details

No manual intervention needed. If something goes wrong or the weather is dangerous, you find out instantly.

---

## Before you start

1. Open **Daily Weather Briefing** in n8n
2. Make sure the workflow is **not active** (avoid accidental scheduled runs during the demo)
3. Click the **Fetch Weather** node → run it once → click the **pin icon** to lock its output
   - This lets us swap mock data without touching the real API

---

## Scenario 1 — Normal day, no alert

**Steps:**
1. Open the **Fetch Weather** node → replace pinned data with the contents of `01-normal-weather.json`
2. Click **Execute workflow**

**What to point out:**
- `Transform Data` output → `is_critical: false`, `alert_reason: "None"`
- `Is Critical?` node → routes to the **false** branch
- `Log to Sheets (Normal)` runs — a new row is appended to the sheet
- No Slack message is sent

---

## Scenario 2 — Critical weather, Slack alert fires

**Steps:**
1. Open the **Fetch Weather** node → replace pinned data with the JSON below (or paste from `02-critical-weather.json`)
2. Click **Execute workflow**

```json
{
  "latitude": 50.0647,
  "longitude": 19.945,
  "timezone": "Europe/Warsaw",
  "current": {
    "time": "2025-05-14T08:00",
    "temperature_2m": 33.1,
    "weathercode": 99,
    "windspeed_10m": 72.0
  },
  "daily": {
    "time": ["2025-05-14"],
    "temperature_2m_max": [35.8],
    "temperature_2m_min": [-2.1],
    "precipitation_sum": [42.5],
    "weathercode": [99]
  }
}
```

**What to point out:**
- `Transform Data` output → `is_critical: true`
- `alert_reason`: `"High temp 35.8°C, Low temp -2.1°C, Heavy rain 42.5mm, Storm: Thunderstorm + heavy hail"`
- `Is Critical?` node → routes to the **true** branch
- `Send Slack Alert` fires — show the Slack message that arrived
- `Log to Sheets (Normal)` also runs — the row is logged regardless

---

## Scenario 3 — API failure, error handler fires automatically

> Note: error handlers only fire on **scheduled (production) executions**, not manual test runs. We'll simulate that by activating the workflow with a 1-minute schedule and a broken URL.

**Step 1 — Set the schedule to every minute:**
1. Click the **Schedule Trigger** node
2. Change the cron expression to `* * * * *`
3. Save

**Step 2 — Break the API URL:**
1. Click the **Fetch Weather** node
2. Change the URL to `https://invalid-api.example.com`
3. Save

**Step 3 — Activate and watch:**
1. Make sure **Daily Briefing — Error Handler** is Published (active)
2. Confirm it is linked: main workflow **⋯ → Settings → Error Workflow → Daily Briefing — Error Handler**
3. Click **Publish** on the main workflow
4. Wait up to 1 minute for the scheduler to fire

**What to point out:**
- **Executions** tab on the main workflow → execution marked as **Failed**
- Switch to **Daily Briefing — Error Handler → Executions** → a new execution triggered automatically
- Open it — show the Slack message with workflow name, error message, last node, and execution ID

**Step 4 — Clean up after the demo:**
1. Deactivate the main workflow
2. Restore **Schedule Trigger** cron to `0 8 * * *`
3. Restore **Fetch Weather** URL to `https://api.open-meteo.com/v1/forecast`
4. Save and republish
