---
name: instance-facts
description: Your Church's Rock RMS instance constants — site URLs, the Site Id for Lava Application endpoint URLs, and other locally verified configuration values. Use when constructing Lava Application endpoint URLs or whenever a task needs this church's concrete instance values rather than generic Rock guidance.
---

# Your Church's Rock Instance Facts

Concrete values for Your Church's Rock RMS instance. Generic Rock and Lava guidance lives in the `rockrms` plugin; this skill holds only what is true for this church specifically.

## Sites

- The internal (staff) site is `rock.yourchurch.org`, **Site Id `?`** — verify it with the method in the `language-lava` skill's `Lava-with-Helix.md`, then record the value here.
- Every Lava Application Endpoint URL on that site begins with `/api/v2/lava-app/{SiteId}/`.

## Adding facts

When a session verifies a new instance constant (a load-bearing PageId, a DefinedValue Id, a site setting), add it here via PR so every developer's future sessions inherit it.
