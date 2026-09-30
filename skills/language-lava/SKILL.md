---
name: language-lava
description: Lava language reference for Rock RMS. Lava is Rock's templating language, forked from Shopify's Liquid but NOT identical to Liquid — verify syntax here before assuming any Liquid behavior carries over. Covers syntax, filters, tags, commands (sql, modifyentity, dbtransaction, etc.), merge fields, ShortCodes, tested per-entity modifyentity behaviors, and the boilerplate headers for Lava files. Use whenever writing or reviewing Lava, in any block or endpoint; the surface-* skills cover the workbench each kind of Lava runs in.
---

# Lava (Rock RMS Templating Language)

Lava is Rock RMS's templating language — a fork of Shopify's Liquid that has grown Turing-complete with database read/write capabilities. **Do not assume Liquid syntax works in Lava.** When unsure, verify in the references below.

## How to use this skill

`references/Lava-Language.md` is the primary reference and it is large (~5,800 lines). Do not read it end-to-end: **Grep it for the filter, tag, or command name first**, then Read the surrounding section.

This skill carries what is true of the language **anywhere**. What is true of a particular workbench — the Dynamic Data block, the HTML Content block, Helix endpoints, the Lava Tester, Rock's SQL editor — lives in the matching `surface-*` skill.

## File Index

| File | Covers |
|------|--------|
| [Lava-Language.md](references/Lava-Language.md) | The primary language reference: syntax basics, filters, tags, commands (`sql`, `execute`, `modifyentity`, and more), merge fields, and tested behaviors. |
| [Lava-ShortCodes.md](references/Lava-ShortCodes.md) | ShortCodes — Lava's reusable component system (`{[ ]}` syntax): types, parameters, authoring rules. |
| [Lava-ModifyEntity/](references/Lava-ModifyEntity/README.md) | Tested esoteric `{% modifyentity %}` behaviors. The README carries cross-cutting findings (an empty `[[ property ]]` body writes a true SQL `NULL`; setting `Guid` explicitly fails with a cast error; the two kinds of rollback), `DbTransaction.md` documents the `{% dbtransaction %}` mechanism, and per-entity notes cover Schedule and AttendanceOccurrence. |

## Boilerplates (assets/boilerplates/)

When creating a new Lava file, start from the matching boilerplate template — these define the required header-comment structure:

- `boilerplate-LavaEndpoint.md` — for `.lava` files under `_code/LavaApplications/*/Endpoints/` (the workbench is the `surface-helix` skill)
- `boilerplate-block-LavaApplicationContent.md` — for Lava Application Content block files (`surface-helix`)
- `boilerplate-LavaShortcode.md` — for ShortCode implementation files

The Dynamic Data query and Formatted Output boilerplates live in the `surface-dynamicdata` skill. All of these templates are what the `audit-pre-push-1` skill enforces during pre-push audits.

## House rules reminder

The defensive `{% modifyentity %}` rules (separate blocks for separate fields, one declaration per property, named `return:` variables, `{% dbtransaction %}` around dependent writes) and the `var_`/`obj_`/`input_` variable-prefix convention are injected into every session as house rules by this plugin — follow them without being asked.

## Related skills

- `surface-helix` — Helix (Triumph Tech's HTMX integration): Lava Applications and Endpoints, the tested Helix behaviors, Triumph's form-control ShortCodes, and Chosen.js re-initialization.
- `surface-dynamicdata`, `surface-htmlcontent` — what each block does to the Lava pasted into it.
- `surface-lava-tester` — where to measure a Lava behavior this reference does not state.
