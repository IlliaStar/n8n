# Demo Scenarios

These files mock the Open-Meteo API response for testing the **Daily Weather Briefing** workflow without waiting for the scheduler.

## How to use

1. Open the workflow in n8n
2. Click the **Fetch Weather** node
3. Run the node once (to get real output), then click **Pin data** — or paste the scenario JSON directly into the pinned data field
4. Click **Execute workflow** to run through the rest of the nodes

## Scenarios

| File | What it tests | Expected result |
|---|---|---|
| `01-normal-weather.json` | Mild spring day, no alerts | `is_critical: false` → skips Slack alert → logs to Sheets |
| `02-critical-weather.json` | Extreme heat + storm + heavy rain + frost | `is_critical: true` → sends Slack alert → logs to Sheets |
| `03-api-failure.json` | API returns error object (missing `daily`/`current`) | Transform Data throws → error handler fires → Slack error alert |

## Critical thresholds (defined in Transform Data node)

- `temp_max > 30°C`
- `temp_min < 0°C`
- `precipitation > 10mm`
- `weather_code >= 95` (thunderstorm)
