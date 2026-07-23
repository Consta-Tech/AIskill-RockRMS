---
name: language-lava
description: Lava language reference for Rock RMS. Lava is Rock's templating language, forked from Shopify's Liquid but NOT identical to Liquid — verify syntax here before assuming any Liquid behavior carries over. Covers syntax, filters, tags, commands (sql, modifyentity, etc.), the Helix/HTMX framework and Lava Applications, ShortCodes, Helix form controls, and tested per-entity modifyentity behaviors. Use whenever writing or reviewing Lava templates, Lava Application endpoints, or ShortCodes.
---

# Lava (Rock RMS Templating Language)

Lava is Rock RMS's templating language — a fork of Shopify's Liquid that has grown Turing-complete with database read/write capabilities. **Do not assume Liquid syntax works in Lava.** When unsure, verify in the references below.

## How to use this skill

`references/Lava-Language.md` is the primary reference and it is large (~5,800 lines). Do not read it end-to-end: **Grep it for the filter, tag, or command name first**, then Read the surrounding section.

## File Index

| File | Covers |
|------|--------|
| [Lava-Language.md](references/Lava-Language.md) | The primary language reference: syntax basics, filters, tags, commands (`sql`, `execute`, `modifyentity`, and more), merge fields, and tested behaviors. |
| [Lava-with-Helix.md](references/Lava-with-Helix.md) | Helix — Triumph Tech's HTMX implementation for Rock. Lava Applications and Endpoints, the `/api/v2/lava-app/{SiteId}/{application-slug}/{endpoint-slug}` route shape, and endpoint patterns. |
| [Helix-Form-Controls.md](references/Helix-Form-Controls.md) | Triumph's form-control ShortCodes (all wrapping `{[ rockcontrol ]}`) for Lava Application Content blocks — declarative Bootstrap form-groups with label/validation/required styling. |
| [Lava-Helix-ChosenJS.md](references/Lava-Helix-ChosenJS.md) | Chosen.js + jQuery inside Helix pages — the `htmx:afterSettle` re-initialization pattern with the `.chzn-done` exclusion class. |
| [Lava-ShortCodes.md](references/Lava-ShortCodes.md) | ShortCodes — Lava's reusable component system (`{[ ]}` syntax): types, parameters, authoring rules. |
| [Lava-ModifyEntity/](references/Lava-ModifyEntity/README.md) | Tested esoteric `{% modifyentity %}` behaviors. The README carries cross-cutting findings (an empty `[[ property ]]` body writes a true SQL `NULL`; setting `Guid` explicitly fails with a cast error) plus per-entity notes for Schedule and AttendanceOccurrence. |

## Boilerplates (assets/boilerplates/)

When creating a new Lava file, start from the matching boilerplate template — these define the required header-comment structure:

- `boilerplate-LavaEndpoint.md` — for `.lava` files under `_code/LavaApplications/*/Endpoints/`
- `boilerplate-block-LavaApplicationContent.md` — for Lava Application Content block files
- `boilerplate-LavaShortcode.md` — for ShortCode implementation files

These same templates are what the `audit-pre-push-1` skill enforces during pre-push audits.

## House rules reminder

The three defensive `{% modifyentity %}` rules (separate blocks for separate fields, one declaration per property, named `return:` variables) and the `var_`/`obj_` variable-prefix convention are injected into every session as house rules by this plugin — follow them without being asked.
