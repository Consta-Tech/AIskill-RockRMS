---
name: audit-pre-push-2
description: Pre-push audit, part 2 of 2 — audits README.md files for structural consistency, stale content, version-stamped sections, and file-index accuracy; optionally absorbs extraction notes produced by audit-pre-push-1. Documentation-only pass, no behavioral code changes. Use after audit-pre-push-1 when preparing to push to the shared repository.
---

# Pre-Push Audit — Part 2: README Files

Audit README.md files across the scoped directories for structural consistency, stale content, version-stamped sections, and file index accuracy. Optionally absorb extraction notes produced by the `audit-pre-push-1` skill.

This is a **documentation-only pass** — no behavioral code changes, no file renames, no file deletions, no auto-commits.

---

## Step 0 — Determine scope

If `$ARGUMENTS` is provided, treat it as the target directory path (relative to repo root). Verify the path exists; if it doesn't, tell the user and stop.

If `$ARGUMENTS` is empty, ask the user which scope to audit:

1. **Entire repo** — all `README.md` files from the repo root
2. **Working tree** — only `README.md` files with uncommitted changes (`git diff --name-only` + `git diff --cached --name-only`)
3. **Staged files only** — only `README.md` files staged for commit (`git diff --cached --name-only`)
4. **Specific directory** — ask the user to provide a path; audit all `README.md` files under that directory recursively

Once scope is established, discover all `README.md` files within it and proceed.

---

## Step 1 — Check for extraction notes

Ask the user: **"Did you run `audit-pre-push-1` before this? If so, where is the `_audit-extractions.md` file?"**

- If the user provides a path, read the file and keep its contents available for Step 5 (absorption).
- If the user says no or the file doesn't exist, proceed without it. Skip extraction absorption in Step 5.

---

## Step 2 — Version number

If an extraction file was loaded in Step 1, check whether it or a co-located `_audit-report.md` contains a version number from audit-1. If found, confirm it with the user: **"Audit-1 used version `{version}`. Should I use the same?"**

If no version number is available, ask: **"What version number should I normalize to?"**

Scan the in-scope READMEs for version stamps (patterns like `Tag: vX.Y`, `## v0.X additions`, `## v0.X conventions`, `(vX.Y.Z)`, version-stamped section headings). If version stamps are found, show the user what the current markers look like before applying the normalization.

If no version stamps are found anywhere, skip this step silently.

---

## Step 3 — Discuss README structure

For each distinct directory level represented in the in-scope READMEs, ask the user what sections and structure they expect. Present the directory levels as a grouped list so the user can describe expectations per level rather than per file.

For example, if the scope contains:

- Top-level READMEs (`_code/LavaApplications/README.md`)
- Application-level READMEs (`_code/LavaApplications/RoomManagement/README.md`)
- Directory-level READMEs (`_code/LavaApplications/RoomManagement/Endpoints/README.md`)
- Per-item READMEs (`_code/ShortCodes/ShortCodeId_140/README.md`, `_code/Block-LavaApplicationContent/PageId_6076/README.md`)

...then group them by level and ask: **"For each level, what sections should the README contain? (e.g., Overview, File index, Conventions, History, etc.)"**

Accept whatever structure the user describes. If the user says "just clean them up, I don't have a specific structure in mind," proceed with comment hygiene, version flattening, and index verification only — skip structural enforcement.

---

## Step 4 — Choose output directory

Ask the user: **"Where should I save the audit report?"**

Suggest `input_box/` as the default. Accept any directory the user specifies. Create it if it doesn't exist.

One file will be written to this directory:

- `_audit-report-readmes.md` — full summary of changes made and items flagged for review

---

## Step 5 — Execute the audit

Process each in-scope README. For every file, apply the rules in `references/doctrine.md` — read it before the first file. The audit has two action categories:

### Auto-apply (low-risk, applied without asking)

1. **Update file index tables** — verify each file index table against what is actually on disk in the README's directory. Auto-apply the following corrections:
   - Add rows for files present on disk but missing from the index.
   - Remove rows for files listed in the index but no longer on disk.
   - For newly added rows, use a placeholder purpose description: `(pending — describe this file's purpose)`.
   - Preserve the existing table format (column order, alignment, separators).

2. **Fix internal references** — verify that internal cross-references to directories and files in the repo still resolve. Auto-apply corrections:
   - Update paths that have moved or been renamed (if the correct new path can be determined unambiguously from the working tree).
   - Delete references to paths that no longer exist and have no obvious replacement. If deleting a reference collapses the surrounding sentence, flag it for review instead.

3. **Delete ephemeral references** — apply the same ephemeral reference patterns from `audit-pre-push-1`:
   - Conversation/chat citations (`conv 12`, `chat 25`, `per conversation with…`)
   - Prompt file references (`prompt0-3.md`, `prompt2-1.md`, any `prompt*.md`)
   - `input_box/` paths, `.trash/` paths, `.DS_Store` references
   - `idea/`, `inspiration/`, `diagnosis/` directory references
   - Reference material filenames in gitignored dirs (`notes-v0.4.md`, `answers-for-X.md`, `current-state-XX.md`, `brainstormX.md`, `future-features.md`)
   - "Note to self" markers

4. **Normalize version stamps** — replace surviving version markers with the version number from Step 2.

5. **Delete "what changed" narrations** — remove prose that narrates what changed rather than explaining the current state. Timelines are inferrable from git.

### Flag for review (presented to user for discernment)

1. **Version-stamped section headings** — flag sections like `## v0.2 conventions (additions)`, `## v0.3 additions`, `## v0.4 conventions`. Propose flattening them into a single current-state heading (e.g., `## Conventions`). Show the user what the flattened result would look like — merge the content, remove version prefixes, rewrite in present tense, deduplicate items that appear across multiple versioned sections.

2. **Extraction absorption** — if `_audit-extractions.md` was loaded in Step 1, present each extraction entry to the user with its intended destination. For each entry, show:
   - The content to be absorbed
   - The target README and section (e.g., `Endpoints/README.md § "OOB contract"`)
   - A proposed placement within the README

   Let the user approve, modify, or skip each entry.

3. **Missing "Used by" sections in ShortCode READMEs** — for any README under `_code/ShortCodes/ShortCodeId_*/`, check whether a "Used by" or "Consumers" section exists. If not, flag it. If the extraction file contains "Used by" data relocated from a ShortCode boilerplate, propose adding it.

4. **Structural violations** — if the user defined expected sections in Step 3, flag any README that is missing required sections or contains sections not in the expected structure.

5. **Stale file index descriptions** — if a file index row's purpose description appears inconsistent with the file's current boilerplate header (read the first comment block of the referenced file to compare), flag it for the user to reconcile.

6. **Collapsed sentences** — any case where deleting an ephemeral reference or stale path leaves a sentence fragment or grammatically broken prose.

7. **Oversized sections** — flag any single README section that exceeds ~50 lines, as a prompt for the user to consider whether it should be split or condensed.

---

## Doctrine

The rules Step 5 applies — version-stamped section flattening, stable references to keep, and the README content guidelines — live in [references/doctrine.md](references/doctrine.md).

---

## Hard guardrails

- ❌ Do NOT change executable code in any file (Lava, SQL, HTML, JS, CSS). Only README prose changes.
- ❌ Do NOT rename or delete files.
- ❌ Do NOT auto-commit. Present the summary report and stop.
- ❌ Do NOT create files outside the user-specified output directory (Step 4), except for modifications to existing in-scope README files.
- ❌ Do NOT touch non-README files — those are `audit-pre-push-1`'s scope. Exception: reading the first comment block of a `.lava` / `.html` file to verify a file index description is permitted (read-only).
- ❌ Do NOT propose follow-up work or next steps. The user drives what happens after the audit.

---

## Step 6 — Summary report

After all READMEs are processed, write `_audit-report-readmes.md` to the output directory (from Step 4). Structure the report as:

### 1. Auto-applied changes

For each README that was modified, list:
- File path
- File index corrections (rows added / rows removed)
- Internal references fixed
- Ephemeral references deleted
- Version stamps normalized
- "What changed" narrations removed

### 2. Flagged for review

Group by flag type:
- **Version-stamped sections to flatten** — file path, current headings, proposed merged heading
- **Extraction absorption** — file path, extraction source, proposed placement, user decision (approved / modified / skipped)
- **Missing "Used by" sections** — file path (ShortCode READMEs only)
- **Structural violations** — file path, missing or unexpected sections vs. Step 3 expectations
- **Stale file index descriptions** — file path, row, discrepancy with boilerplate
- **Collapsed sentences** — file path, line number, the broken sentence
- **Oversized sections** — file path, section heading, line count

### 3. Template recommendations

For each distinct directory level audited, assess whether the README structure was consistent enough across files at that level to warrant a reusable template. If so, suggest adding a template to the plugin's shared boilerplates (`skills/language-lava/assets/boilerplates/` in `Consta-Tech/AIskill-RockRMS`, proposed via PR) or to the project's own `.claude/templates/`, and describe what it would contain. For example:

> **Suggested template: `readme-shortcode.md`**
> ShortCode-level READMEs at `_code/ShortCodes/ShortCodeId_*/README.md` all follow the same pattern: Overview, Used by, Parameters reference, History. Consider saving this as a template for future audits.

Only suggest templates where the pattern is genuinely consistent. If READMEs at a given level vary too much to standardize, say so.

---

Surface the path of the summary report to the user and stop.
