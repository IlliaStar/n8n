# Demo Script — Daily Weather Briefing

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

**Story:** The weather API returns an error object instead of data. The Transform Data node throws, the main workflow fails, and the error handler automatically sends a Slack alert.

**Paste into pinned data:** `03-api-failure.json`

**Click:** Execute workflow

**What to show:**
- `Transform Data` throws: `"Unexpected API response — missing daily or current fields"`
- Main workflow execution marked as **failed**
- Switch to the **Daily Briefing — Error Handler** workflow → Executions tab
- Show the error alert that was sent to Slack with workflow name, error message, and execution ID
