# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Deploying workflows

Use the `/deploy` skill in Claude Code — it handles the steps automatically.

Or run manually: stop n8n first (write conflicts otherwise), then:

```bash
bash .claude/skills/deploy/deploy.sh
```

This imports `error-handler.json` before `daily-briefing.json` — order matters because the main workflow references the error handler by name.

## Architecture

Two workflows with a shared error-handling pattern:

```
daily-briefing.json
  Schedule Trigger (08:00 daily)
    → Config (Set node — single source of truth for all config values)
    → Fetch Weather (HTTP → Open-Meteo, free, no API key)
    → Transform Data (Code node — reshapes response, computes is_critical)
    → Is Critical? (IF node)
        true  → Send Slack Alert → Log to Sheets (Alert)
        false → Log to Sheets (Normal)

error-handler.json
  Error Trigger (fires when daily-briefing fails)
    → Format Error Details (Set node)
    → Notify Error via Slack
```

## Configuration

All user-configurable values live in the **`Config` node** inside `daily-briefing.json`. Edit fields there:

| Field | Default |
|---|---|
| `CITY_NAME` | `Krakow` |
| `CITY_LAT` / `CITY_LON` | `50.0647` / `19.9450` |
| `CITY_TIMEZONE` | `Europe/Warsaw` |
| `SLACK_WEBHOOK_URL` | `YOUR_SLACK_WEBHOOK_URL` |
| `GOOGLE_SHEET_ID` | `YOUR_GOOGLE_SHEET_ID` |

Downstream nodes reference these as `$('Config').item.json.FIELD_NAME`.

**Exception:** `error-handler.json` uses `$vars.SLACK_WEBHOOK_URL` (an n8n environment variable), not the Config node — it has no access to the main workflow's data.

## Alert thresholds

Defined in the `Transform Data` code node: `temp_max > 30°C`, `temp_min < 0°C`, `precipitation > 10mm`, `weather_code >= 95` (thunderstorm). The `is_critical` boolean and `alert_reason` string are set there and drive the IF node.

## Post-deploy manual steps

After importing, in the n8n UI:
1. Set `SLACK_WEBHOOK_URL` and `GOOGLE_SHEET_ID` in the `Config` node
2. Select your Google credential in both `Log to Sheets` nodes
3. Open workflow **Settings → Error Workflow** and select `Daily Briefing — Error Handler`
4. Activate the workflow
