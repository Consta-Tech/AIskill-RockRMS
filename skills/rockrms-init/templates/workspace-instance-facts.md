# Instance Facts

Verified constants for my Rock RMS instance. Record only values that have been **verified against the live instance**, and date each one — a guessed Id in here is worse than no entry.

{{OVERLAY_POINTER}}

## Sites

| Site | URL | Site Id | Verified |
|---|---|---|---|
| Internal (staff) | {{INTERNAL_URL}} | {{INTERNAL_SITE_ID}} | |
| External (public) | {{EXTERNAL_URL}} | | |

Lava Application endpoint URLs begin with `/api/v2/lava-app/{SiteId}/` — the Site Id of the **site serving the request**, not the Lava Application's Id.

## Rock version

| Rock version | Verified |
|---|---|
| {{ROCK_VERSION}} | {{ROCK_VERSION_VERIFIED}} |

Find it under Admin Tools > System Information. The `rockrms` plugin's `rockrms-knowledge-current` skill reads this row to flag references that were verified on a **newer** Rock version than this instance runs; keep it current after every upgrade.

## Key Ids

| Entity | Id | What it is | Verified |
|---|---|---|---|
| | | | |

## Notes

<!-- Anything else verified about this instance: installed plugins, campus structure, … -->
