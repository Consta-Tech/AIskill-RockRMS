# docs/ — My Local Knowledgebase

This directory is the **local-only** layer of a three-layer knowledge stack:

1. **The `rockrms` plugin** — general Rock knowledge (language references, schema docs, house rules). Maintained upstream, auto-updating, read-only from here.
2. **My church's overlay plugin** (if one is installed) — knowledge shared by every developer at my church: instance constants, intentional deviations from stock behavior.
3. **This directory** — mine alone. Nothing upstream ever writes here, so nothing here can ever be overwritten by a plugin update.

## What belongs here

- Verified facts about **my** Rock instance that aren't (yet) in an overlay skill — start with `instance-facts.md`.
- Internal procedures: how my church requests a page, deploys a block, names a workflow.
- Personal working notes and habits worth keeping across sessions.

## What does not belong here

| If the knowledge is… | It belongs… |
|---|---|
| True of Rock anywhere (a Lava behavior, a schema fact, a block quirk) | Upstream — PR it to `Consta-Tech/AIskill-RockRMS` |
| True for every developer at my church | The church overlay plugin — PR it there |
| Only true for me / my machine / my instance | Here |

Promoting a note upward is the goal, not a chore: once it's merged upstream, every developer's sessions inherit it automatically.

## Conventions

- One topic per file, named descriptively in kebab-case (`page-request-procedure.md`, not `notes2.md`).
- Open each file with a one-line statement of what it claims, and date anything verified against the live instance (`Verified 2026-09-28`).
- Claude finds material here by grepping — descriptive filenames and opening lines are what make that work.
