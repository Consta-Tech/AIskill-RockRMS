# Changelog

Releases of the `rockrms` plugin are **date-stamped**, newest first. The plugin has no version number on purpose: every commit pushed to `main` reaches installed machines automatically, so a dated section here marks the set of commits worth announcing. The `rockrms-changelog` skill prints the newest section — and, when the installed commit has moved since you last ran it, every section released in between.

Headings inside a release follow [Keep a Changelog](https://keepachangelog.com): Added, Changed, Fixed, Removed. Contributors add their bullet under `## Unreleased`; the maintainer renames that heading to the release date when cutting a release (see CONTRIBUTING.md).

## Unreleased

### Changed
- **`rules/formatting-standards.md` is split by language:** `formatting-standards.md` (every language: indentation, boilerplate placement, dates), `formatting-standards-sql.md`, `formatting-standards-lava.md`, `formatting-standards-workflowtypes.md`. Antigravity truncates any rule file over 24,000 bytes and the single file had reached 25,335. The plugin copy also gains the "Dates go big-to-small" rule the upstream repo added, and every rule file now opens with the `trigger: always_on` frontmatter Antigravity requires (stripped before injection everywhere else).
- **Hook chunks shrink to 6,000 bytes** (`hooks/inject-rule.sh`), under Codex's ~2,500-token per-hook default as well as Claude Code's cap; `hooks/hooks.json` now lists 13 chunk commands, and Codex runs that same file (it hardcodes the path). `inject-rule.sh --all` prints every rule as one block for review. `inject-rule.sh --check` now also enforces the Antigravity frontmatter and the 24,000-byte cap.
- **No heredocs in the shipped scripts** (`inject-rule.sh`, `plugin-identity.sh`): Codex's read-only sandbox cannot create the temp file a heredoc needs, which made `plugin-identity.sh` print three errors before its header. The identity header now names the host it found the install under (Claude Code, Codex, Antigravity, OpenCode, or git checkout).
- **README rewritten shorter:** a paste-into-your-agent install line and the install video first, one with-and-without example of the knowledge-boundaries behavior, the eighteen skills grouped into five rows, and a License line. The repository tree moved to `AGENTS.md`; the per-host install table lives only in INSTALL.md.
- **`surface-dynamicdata`'s description is quoted** — it contains a `: ` that strict YAML parsers (Antigravity) reject in a plain scalar, which made the skill invisible there.

### Added
- **OpenCode plugin** (`.opencode/plugins/rockrms.mjs`): registers every skill, injects the house rules into the system prompt on every turn, and adds a `/rockrms-init` command. Supports OpenCode V2 (`setup`) and V1 1.18.29+ (`server`).
- **Codex and Antigravity manifests:** `.codex-plugin/plugin.json` + `.agents/plugins/marketplace.json` (Codex reads this repo as a marketplace named `consta-tech`, same as Claude Code), and a root `plugin.json` (Antigravity). `setup.sh --host claude|codex|opencode|antigravity` runs the install for one host; `.github/workflows/knowledge-check.yml` validates every manifest and the OpenCode plugin on each push.
- **INSTALL.md rewritten per host** — one block each for Claude Code, Codex, OpenCode, and Antigravity (Install / Verify / Update / Uninstall / House rules), plus a generic agent-skills route, a per-host workspace-init table, and a "How the house rules load" table. `tests/check-install-docs.py` keeps that structure (pre-commit and the workflow run it). README and CONTRIBUTING describe the four hosts; the overlay template says what an overlay needs per host.
- **Skill names:** `changelog`, `knowledge-current`, `knowledge-future`, `add-knowledge`, `audit-pre-push-1`, and `audit-pre-push-2` are now `rockrms-changelog`, `rockrms-knowledge-current`, `rockrms-knowledge-future`, `rockrms-add-knowledge`, `rockrms-audit-pre-push-1`, and `rockrms-audit-pre-push-2`. Agent Skills hosts other than Claude Code invoke skills without a plugin prefix, so the generic names needed one of their own. In Claude Code they appear as `/rockrms:rockrms-…`.
- **`/rock-init` is now the `rockrms-init` skill** (`/rockrms:rockrms-init` in Claude Code), with its templates under `skills/rockrms-init/templates/`. It writes an `AGENTS.md` — the instruction file Claude Code, Codex, OpenCode, and Antigravity all read — plus a one-line `CLAUDE.md` that imports it; `.claude/settings.json` is written only when the running agent is Claude Code.
- **`AGENTS.md` at the repo root** (with a one-line `CLAUDE.md` importing it): the map for an agent working on a clone — source of truth per area, entry point per host, the rules that are not derivable from the code (no version field, `rockrms-` prefix, rule-file caps, no heredocs in shipped scripts), and the verification commands. Installed sessions never read it.
- **`scripts/`** — contributor tooling only. `scripts/check.sh` runs every model-free check (catalog, hook slots, host manifests, strict-YAML skill frontmatter, INSTALL.md structure, and a new `scripts/opencode-driver.mjs` that loads the OpenCode plugin against a fake context and asserts every skill, every rule, and `/rockrms-init` on both the V1 and V2 paths); the pre-commit hook and the GitHub workflow both run that one script. `tests/check-install-docs.py` moved to `scripts/`.
- **Host-neutral wording:** skills locate the plugin root from their own path (`${CLAUDE_PLUGIN_ROOT}` is used when a host sets it, no longer required); `knowledge/changelog.sh` and `knowledge/plugin-identity.sh` default to the directory above themselves and store the "since you last checked" marker under `~/.local/share/rockrms/` when no host data directory exists; the surface skills say "the agent" rather than "Claude"; the knowledge-boundaries rule names skills bare and lists how each host types them.

## 2026-10-06

### Added
- **Table of contents** at the top of the Lava reference (`language-lava` > `Lava-Language.md`), listing every section and subsection.
- **`## Summary` table** in 13 `rock-sql-schema` references that lacked one: one row per table, with a description and its key foreign keys. All 21 schema references now open with one.

### Changed
- **`audit-pre-push-1` and `audit-pre-push-2`:** their Doctrine sections moved into each skill's `references/doctrine.md`, bringing both SKILL.md files under 200 lines.
- **`/rockrms:add-knowledge`:** a reference over 100 lines now gets a table of contents (or, for a schema file, a Summary row per table), and a new file is indexed in `references/README.md` too when the skill keeps one.

## 2026-09-29

The first date-stamped release. At this release the plugin ships twelve skills (`rock-sql-schema`, `rock-blocktypes`, `bema-room-management`, `language-lava`, `language-html-htmx`, five `surface-*` workbench skills, `format-tsql`, and the two `audit-pre-push` skills), five injected house rules, the `/rock-init` workspace initializer with its templates, and the overlay template under `examples/`.

### Added
- **Knowledge catalog.** `knowledge/manifest.yaml` is the single source of truth for what the plugin documents: 81 entries at launch, one per reference file, each with a category, an owning skill, a source URL, the Rock version it was verified on, and a provenance tier (`measured`, `traced`, `summarized`). `knowledge/render.py` renders it into `knowledge/Knowledge-current.md` and `knowledge/Knowledge-future.md` and checks that both are current; the render check runs from `.githooks/pre-commit`.
- **Provenance header** in every catalogued reference file, stating its tier and the Rock version it was verified on.
- **Four skills:** `/rockrms:knowledge-current` (what is documented, grouped by category and tier, flagged against your instance's Rock version, plus any installed church overlay's catalog), `/rockrms:knowledge-future` (the roadmap), `/rockrms:changelog` (this file's newest section plus the installed commit, remembering what you last saw), and `/rockrms:add-knowledge` (drafts a cited, `summarized`-tier reference from a URL or excerpt, adds its manifest row, re-renders, and stops before any commit).
- **Always-on rule `knowledge-boundaries`:** when a Rock question falls outside the catalog, the session says so in one sentence and asks whether to answer from general knowledge (marked unverified) or to start documenting the topic.
- `/rock-init` now asks for the instance's Rock version (skippable) and writes it as a row in `docs/instance-facts.md`; the `knowledge-current` skill reads that row.
- `CONTRIBUTING.md`: fork-and-PR flow, the generic-versus-overlay sorting rule, the three tiers and the evidence each needs, the manifest-row requirement, the render check, the summarize-and-cite licensing stance, and how a church proposes a roadmap row.
- `evals/`: a `claude plugin eval` suite covering the four skills and the ask-first fallback.
- `knowledge-check` GitHub Action: runs the catalog and hook-slot checks on every push and pull request.
- Workspace CLAUDE.md template: a sixth session-opener menu option that runs the three catalog skills.
- `knowledge-manifest` skill in `examples/overlay-template/`, so an overlay's catalog is aggregated into `/rockrms:knowledge-current`.

### Changed
- README: "What this plugin knows" section pointing at the rendered catalog, and a Contributing section pointing at CONTRIBUTING.md.

### Fixed
- **House rules were mostly not reaching sessions.** The SessionStart hook emitted all rules as one 50 KB block, and Claude Code keeps only a short preview of a single hook command's output in context (measured: about 9.5 KB arrives intact, about 15 KB does not). Rules are now injected one hook command per rule, with the formatting standards split into chunks under an 8 KB budget; `hooks/inject-rule.sh --check` (run by the pre-commit hook) fails when a rule outgrows its slots.
- `Lava-ModifyEntity/DbTransaction.md` linked to a `RockShop-Plugins/…` path that does not exist inside the plugin; it now names the `bema-room-management` skill.
