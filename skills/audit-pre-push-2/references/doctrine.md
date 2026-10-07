# Pre-Push Audit Doctrine — Part 2: README Files

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.


The rules Step 5 of the `audit-pre-push-2` skill applies to every in-scope README.

## Version-stamped section flattening

When a README contains multiple sections whose headings include version stamps (e.g., `## v0.2 conventions (additions)`, `## v0.3 conventions (additions — standalone Browser pages)`, `## v0.4 conventions (additions)`), flatten them:

1. Merge the content from all versioned sections into a single section under a clean, present-tense heading (e.g., `## Conventions`).
2. Remove version prefixes from individual items within the merged section (e.g., `"v0.4.4 added pre-fill from…"` → `"Pre-fills from…"`).
3. Deduplicate: if an item in a later versioned section supersedes an earlier one, keep only the latest.
4. Renumber the merged list sequentially.
5. If any versioned section contains narrative that is architecturally significant (explains *why* a convention exists, not just *what* it is), preserve the substance in the merged section or move it to a `## History` section as a bullet.

This flattening rule applies to **any** version-stamped heading pattern, not just "conventions" — e.g., `## v0.5 additions`, `### File index (v0.2 + v0.3 + v0.4)`, `## v0.3 notes`.

## Stable references (DO NOT delete)

| Pattern | Example |
|---|---|
| Skill reference paths | `references/Lava-Language.md`, the `rock-sql-schema` skill |
| Memory file references | `feedback_*.md`, `reference_*.md`, `project_*.md`, `user_*.md` |
| External URLs | BEMA GitHub URLs, Rock community URLs, any http/https link |
| Internal cross-file references | `_render-summary-sidebar.lava Section 6` (verify accuracy; update if stale) |

## README content guidelines

- Present tense throughout. No version-stamped prose.
- READMEs describe the **current state** of the directory's contents. Git history covers the past.
- Cross-file conventions that apply to multiple files in the directory belong here, not in individual file boilerplates.
- File index tables should be the authoritative map of the directory's contents.
