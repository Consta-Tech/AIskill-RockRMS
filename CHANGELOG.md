# Changelog

Releases of the `rockrms` plugin are **date-stamped**, newest first. The plugin has no version number on purpose: every commit pushed to `main` reaches installed machines automatically, so a dated section here marks the set of commits worth announcing. `/rockrms:changelog` prints the newest section — and, when the installed commit has moved since you last ran it, every section released in between.

Headings inside a release follow [Keep a Changelog](https://keepachangelog.com): Added, Changed, Fixed, Removed. Contributors add their bullet under `## Unreleased`; the maintainer renames that heading to the release date when cutting a release (see CONTRIBUTING.md).

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
- `knowledge-manifest` skill in `examples/overlay-template/`, so an overlay's catalog is aggregated into `/rockrms:knowledge-current`.

### Changed
- README: "What this plugin knows" section pointing at the rendered catalog, and a Contributing section pointing at CONTRIBUTING.md.

### Fixed
- **House rules were mostly not reaching sessions.** The SessionStart hook emitted all rules as one 50 KB block, and Claude Code keeps only a short preview of a single hook command's output in context (measured: about 9.5 KB arrives intact, about 15 KB does not). Rules are now injected one hook command per rule, with the formatting standards split into chunks under an 8 KB budget; `hooks/inject-rule.sh --check` (run by the pre-commit hook) fails when a rule outgrows its slots.
- `Lava-ModifyEntity/DbTransaction.md` linked to a `RockShop-Plugins/…` path that does not exist inside the plugin; it now names the `bema-room-management` skill.
