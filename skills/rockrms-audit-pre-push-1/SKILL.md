---
name: rockrms-audit-pre-push-1
description: Pre-push audit, part 1 of 2 — audits comments, boilerplate headers, and inline documentation across .lava, .html, .sql, and .lava.sql code files before pushing to the shared repository. Documentation-only pass, no behavioral code changes. Use when the user wants to run the pre-push audit or clean up comments and boilerplates before a push; run before rockrms-audit-pre-push-2.
---

# Pre-Push Audit — Part 1: Code Files

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Audit comments, boilerplate headers, and inline documentation across code files in preparation for pushing to the shared repository. This is a **documentation-only pass** — no behavioral code changes, no file renames, no file deletions, no auto-commits.

Part 2 (the `rockrms-audit-pre-push-2` skill) handles README files and should be run after this skill completes.

---

## Step 0 — Determine scope

If `$ARGUMENTS` is provided, treat it as the target directory path (relative to repo root). Verify the path exists; if it doesn't, tell the user and stop.

If `$ARGUMENTS` is empty, ask the user which scope to audit:

1. **Entire repo** — all tracked files from the repo root
2. **Working tree** — only files with uncommitted changes (`git diff --name-only` + `git diff --cached --name-only`)
3. **Staged files only** — only files staged for commit (`git diff --cached --name-only`)
4. **Specific directory** — ask the user to provide a path

Once scope is established, proceed to file discovery.

---

## Step 1 — Discover files

Scan the resolved scope for files matching these **hardcoded audit types**:

- `.lava`
- `.html`
- `.sql`
- `.lava.sql`

Exclude `README.md` files — those are handled by `rockrms-audit-pre-push-2`.

If the scan reveals file types outside the hardcoded list (e.g., `.js`, `.css`, `.json`), present them to the user in a numbered list and ask which to include or exclude before proceeding.

---

## Step 2 — Select boilerplate templates

Ask the user: **"Which boilerplate template(s) should I enforce for files in this scope?"**

Check two locations for available `.md` template files:

1. This plugin's shared boilerplates, relative to this skill's directory: `../language-lava/assets/boilerplates/` (`boilerplate-LavaEndpoint.md`, `boilerplate-block-LavaApplicationContent.md`, `boilerplate-LavaShortcode.md`) and `../surface-dynamicdata/assets/boilerplates/` (`boilerplate-block-DynamicData-Query.md`, `boilerplate-block-DynamicData-FormattedOutput.md`).
2. The project's own `.claude/templates/`, if it exists — project-local templates take precedence when both define a template for the same file category.

Each template file contains prose descriptions and heuristic guidelines followed by an `## Example` section showing the desired boilerplate with proper whitespace, block formatting, and list formatting. Read the full template file — apply the heuristic guidelines for judgment calls and use the Example as the concrete structural reference.

Present whatever templates are found as a numbered list the user can select from.

If the user indicates that certain file categories don't have a template yet, or that no template enforcement is needed for this run, note that and skip boilerplate structure enforcement for those files. Still proceed with comment hygiene, ephemeral reference cleanup, and the remaining audit steps.

If no templates exist in either location, inform the user and ask whether to proceed with comment hygiene only or stop so they can create templates first.

---

## Step 3 — Version stamp handling

Scan the in-scope files for version stamps (patterns like `v0.X`, `v1.X`, `Tag: vX.Y`, `(vX.Y.Z)`, `**vX.Y:** …`, `// vX.Y.Z`).

If version stamps are found, show the user what the current version marker(s) look like and ask: **"What version number should I normalize to?"**

Apply the user's answer per § Version stamp rules in `references/doctrine.md`.

If no version stamps are found, skip this step silently.

---

## Step 4 — Choose output directory

Ask the user: **"Where should I save the audit report and extraction notes?"**

Suggest `input_box/` as the default (since it is gitignored and won't be committed). Accept any directory the user specifies. Create it if it doesn't exist.

Two files will be written to this directory:

- `_audit-extractions.md` — content flagged for relocation to READMEs (consumed by `rockrms-audit-pre-push-2`)
- `_audit-report.md` — full summary of changes made and items flagged for review

---

## Step 5 — Execute the audit

Process each in-scope file. For every file, apply the rules in `references/doctrine.md` — read it before the first file. The audit has two action categories:

### Auto-apply (low-risk, applied without asking)

1. **Delete ephemeral references** — remove any line or citation matching the patterns in `references/doctrine.md` § Ephemeral reference patterns. If removing a reference collapses the surrounding sentence into something nonsensical, flag it for review instead.
2. **Strip version stamp markers** — delete version-stamp prefixes from inline comments (e.g., `// v0.4.7 — added pre-fill` becomes `// added pre-fill`, or delete entirely if the comment is pure version narration with no surviving substance).
3. **Delete "what changed" narrations** — remove comments that narrate *what changed* rather than explaining *why the code works this way*. Timelines and change history are inferrable from git. Examples of narration to delete: `"In v0.4.4 we added X"`, `"This was refactored from Y in sprint 3"`, `"Moved here from Z.lava"`.
4. **Format SQL** — for `.sql` files, `.lava.sql` files, and any `.lava` file containing embedded SQL via `{% sql %}...{% endsql %}`, apply the `format-tsql` skill (bundled in this plugin). This is deterministic and safe to auto-apply.
5. **Normalize version stamps** — replace surviving version markers with the version number the user provided in Step 3.

### Flag for review (presented to user for discernment)

1. **TODO / FIXME / HACK comments** — surface each one with its file path and line number. Do not auto-remove.
2. **Inline comments exceeding 3 lines** — flag any single-line comment or `//`-style comment block that spans more than 3 consecutive lines.
3. **Comment blocks exceeding 7 lines** — flag any `{% comment %}...{% endcomment %}` block (or equivalent) that spans more than 7 lines.
4. **Content candidates for README relocation** — flag boilerplate content that would be more appropriate in the corresponding directory's README (e.g., cross-file conventions, algorithm explanations that apply to multiple files, architectural decision records). Write the candidate content to `_audit-extractions.md` with a heading indicating where it should land (e.g., `# To: Endpoints/README.md § OOB contract`).
5. **Collapsed sentences** — any case where deleting an ephemeral reference leaves a sentence fragment or grammatically broken prose that requires a rewrite.
6. **Boilerplate structure violations** — if a template was selected in Step 2, flag any file whose boilerplate header doesn't conform (missing fields, extra fields, wrong order, exceeds the template's line count).

---

## Doctrine

The rules Step 5 applies — ephemeral reference patterns to delete, stable references to keep, and the boilerplate, inline-comment, and version-stamp rules — live in [references/doctrine.md](references/doctrine.md). The ephemeral-patterns table is meant to grow as the repo evolves; add new patterns there, not here.

---

## Hard guardrails

- ❌ Do NOT change executable code (Lava expressions, SQL logic, HTML structure, JS logic, CSS rules). Only comments and prose change.
- ❌ Do NOT change `{% raw %}` / `{% endraw %}` boundaries — those are functional.
- ❌ Do NOT rename or delete files.
- ❌ Do NOT auto-commit. Present the summary report and stop.
- ❌ Do NOT create files outside the user-specified output directory (Step 4).
- ❌ Do NOT touch README.md files — those are `rockrms-audit-pre-push-2`'s scope.
- ❌ Do NOT propose follow-up work or next steps. The user drives what happens after the audit.

---

## Step 6 — Summary report

After all files are processed, write `_audit-report.md` to the output directory (from Step 4). Structure the report as:

### 1. Auto-applied changes

For each file that was modified, list:
- File path
- Number of ephemeral references deleted
- Number of version stamps normalized
- Number of "what changed" narrations removed
- Whether SQL was reformatted (yes/no)

### 2. Flagged for review

Group by flag type:
- **TODO / FIXME / HACK** — file path, line number, comment text
- **Oversized inline comments (>3 lines)** — file path, line number, line count
- **Oversized comment blocks (>7 lines)** — file path, line number, line count
- **README relocation candidates** — file path, destination, brief description (full content in `_audit-extractions.md`)
- **Collapsed sentences** — file path, line number, the broken sentence
- **Boilerplate structure violations** — file path, what's missing/extra/wrong vs. the template

### 3. Extraction notes summary

List each entry written to `_audit-extractions.md` with its intended destination, for easy reference when running `rockrms-audit-pre-push-2`.

### 4. Unexpected file types

List any non-hardcoded file types encountered and the user's decision (included or excluded).

---

Surface the path of the summary report to the user and stop.
