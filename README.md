# AIskill-RockRMS

A complete **Rock RMS development environment** for Claude Code, packaged as a plugin. Install it once and every session gets our house rules, language references, schema docs, and audit workflows — and every improvement pushed to this repo reaches you automatically.

> **Rock RMS** is an open-source church management system built on ASP.NET. We develop against it with T-SQL, Lava (Rock's Liquid-fork templating language), and HTML/HTMX embedded in Rock Blocks.

## Install

```bash
claude plugin marketplace add Consta-Tech/AIskill-RockRMS
claude plugin install rockrms@consta-tech
```

Then initialize your workspace: `cd` into (or create) your workspace directory, start `claude`, and run **`/rock-init`** — it interviews you and scaffolds the whole workspace (`CLAUDE.md`, `_code`, a local `docs/` knowledgebase, settings).

Or scripted: clone this repo and run [`setup.sh`](setup.sh). Full setup and troubleshooting are in **[INSTALL.md](INSTALL.md)**.

## What's inside

| Component | What it does |
|---|---|
| `rules/` + `hooks/` | Four house-rule documents (SQL/Lava formatting standards, Lava conventions, documentation conventions, file organization) **injected into every session automatically** via a SessionStart hook. |
| `skills/rock-sql-schema` | Annotated `CREATE TABLE` references for the Rock database, grouped by JOIN affinity. |
| `skills/rock-blocktypes` | Tested behavior notes for Group Attendance, Sign-Up, and Check-in Schedule Builder blocks, plus cron expressions and Property-vs-Attribute. |
| `skills/bema-room-management` | Full reference for the BEMA Room Management 2.0 plugin (schema, blocks, workflows) as BEMA ships it. |
| `skills/language-lava` | The Lava language reference (Lava ≠ Liquid!), ShortCodes, tested `{% modifyentity %}` behaviors, and boilerplate templates. |
| `skills/language-html-htmx` | Front-end gotchas verified inside Rock blocks (sticky positioning, debounced HTMX triggers, smooth-scroll after cascades). |
| `skills/surface-dynamicdata` | Working in the Dynamic Data block: the Query + Lava Template pair, settings that matter, PageParameterFilter wiring, the `htmx.process()` requirement, and why every "current URL" filter returns the BlockActions endpoint. |
| `skills/surface-htmlcontent` | Working in the HTML Content block: caching and context settings, what renders here that a Dynamic Data block cannot, and the nested-`<form>` trap. |
| `skills/surface-helix` | The Helix workbench: Lava Applications, Endpoints, and the Lava Application Content block — configuration, the devtools dev loop, tested Helix behaviors, Triumph's form controls, Chosen.js re-init. |
| `skills/surface-lava-tester` | The Lava Tester block as a REPL, a console for `{% modifyentity %}` corrections, and a host for measurement probes. |
| `skills/surface-sql-editor` | Rock's SQL Command page versus a desktop client, when to graduate, and how results get back to Claude. |
| `skills/format-tsql` | `/rockrms:format-tsql` — restyles any T-SQL query to house style. |
| `skills/audit-pre-push-1` `-2` | The two-part pre-push documentation audit (code files, then READMEs). |
| `skills/knowledge-current` `-future` | `/rockrms:knowledge-current` — everything the plugin documents, by category and provenance tier, flagged against your instance's Rock version, plus your church overlay's catalog. `/rockrms:knowledge-future` — the roadmap. |
| `skills/changelog` | `/rockrms:changelog` — the newest release notes and the installed commit, plus everything released since you last looked. |
| `skills/add-knowledge` | `/rockrms:add-knowledge` — turns a URL or excerpt into a cited, `summarized`-tier reference with its catalog row, ready for a PR; it never commits. |
| `knowledge/` | The catalog: `manifest.yaml` (source of truth), the renderer, and the rendered `Knowledge-current.md` / `Knowledge-future.md`. |
| `commands/rock-init` + `templates/` | `/rock-init` — interviews you and scaffolds a complete workspace repo from the templates; reads an installed church overlay's `workspace-defaults` skill instead of interviewing when one is present. |

Reference-pack skills load on demand: Claude sees each skill's one-line description in every session and reads the underlying reference files only when the task calls for them.

The skills split along one seam: `language-*` skills carry what is true of a language **anywhere**; `surface-*` skills carry how to collaborate in a particular Rock **workbench** — its settings, its test loop, what its errors look like, and what to hand back to Claude. Knowledge lives in exactly one of them and the other cross-references it by skill name.

## What this plugin knows

The plugin answers only from **documented, cited** references — it is not "trained" on Rock. Every reference file is a row in [`knowledge/manifest.yaml`](knowledge/manifest.yaml) with a source, the Rock version it was verified on, and a provenance tier: `measured` (tested in a live Rock instance), `traced` (read from Rock source or official docs), or `summarized` (condensed from a URL, not yet verified). The rendered catalog is **[knowledge/Knowledge-current.md](knowledge/Knowledge-current.md)**; the roadmap is [knowledge/Knowledge-future.md](knowledge/Knowledge-future.md).

When a question falls outside the catalog, a session says so in one sentence and asks whether to answer from general knowledge (clearly marked unverified) or to start documenting the topic with `/rockrms:add-knowledge`.

Releases are date-stamped in [CHANGELOG.md](CHANGELOG.md); `/rockrms:changelog` prints the newest one together with the installed commit.

## Church overlays

This plugin carries only **church-agnostic** knowledge. Church-specific content — instance constants, intentional deviations from stock plugin behavior — ships as a separate overlay plugin that your church publishes from its own GitHub org, as its own one-plugin marketplace. Private repos work: GitHub auth gates who can install. A ready-to-copy skeleton with full instructions is in [`examples/overlay-template/`](examples/overlay-template/). The Summit Church runs its overlay this way from a private repo.

## How updates work

The plugin is **unversioned on purpose**: Claude Code treats each git commit as a new version, and its background marketplace refresh delivers every push to every installed machine — no action needed on your end. To force a refresh: `claude plugin marketplace update consta-tech`.

> **Maintainer note:** do not add a `version` field to `.claude-plugin/plugin.json`. Doing so freezes users on that version until it is manually bumped.

## Repository layout

```
AIskill-RockRMS/
├── .claude-plugin/     # plugin.json + marketplace.json (this repo is its own marketplace)
├── rules/              # Always-on house rules (Claude Code-specific, hook-injected)
├── hooks/              # SessionStart hook that injects rules/
├── commands/           # /rock-init — the workspace initializer
├── templates/          # Workspace files /rock-init scaffolds from
├── skills/             # The skill packs (agentskills.io format, harness-neutral)
│   └── <skill>/
│       ├── SKILL.md    # Index + when-to-use routing
│       ├── references/ # Reference docs, loaded on demand
│       └── assets/     # Templates and static resources
├── knowledge/          # manifest.yaml (source of truth), render.py, the rendered catalog views
├── evals/              # claude plugin eval suite
├── .githooks/          # pre-commit: render check (git config core.hooksPath .githooks)
├── CHANGELOG.md        # Date-stamped releases
├── CONTRIBUTING.md
├── INSTALL.md
└── README.md
```

## Other harnesses (Codex, Zed, …)

Claude Code is the only supported harness today. The `skills/` tree follows the [Agent Skills](https://agentskills.io) open standard, so support for additional harnesses can be added later as thin per-harness manifests without restructuring the content.

## Contributing

Spot an error, learn a new tested behavior, or want to extend a reference? **[CONTRIBUTING.md](CONTRIBUTING.md)** has the fork-and-PR flow, the generic-versus-overlay sorting rule, the three provenance tiers and the evidence each needs, and the manifest-row and render-check steps. Inside a session, `/rockrms:add-knowledge` drafts the reference and its catalog row for you and stops before the commit. Once merged, every developer receives the change automatically on their next session.

Maintained by Consta Tech.
