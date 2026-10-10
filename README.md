# AIskill-RockRMS

A complete **Rock RMS development environment** for your coding agent — Claude Code, Codex, OpenCode, or Antigravity — packaged as a plugin. Install it once and every session gets our house rules, language references, schema docs, and audit workflows — and every improvement pushed to this repo reaches you on your next update.

> **Rock RMS** is an open-source church management system built on ASP.NET. We develop against it with T-SQL, Lava (Rock's Liquid-fork templating language), and HTML/HTMX embedded in Rock Blocks.

## Install

| Host | Install | Type a skill as |
|---|---|---|
| Claude Code | `claude plugin marketplace add Consta-Tech/AIskill-RockRMS` then `claude plugin install rockrms@consta-tech` | `/rockrms:rockrms-init` |
| Codex | `codex plugin marketplace add Consta-Tech/AIskill-RockRMS --ref main` then `codex plugin add rockrms@consta-tech` | `$rockrms:rockrms-init` |
| OpenCode | clone + a one-line plugin loader — see INSTALL.md | `/rockrms-init` |
| Antigravity | `agy plugin install https://github.com/Consta-Tech/AIskill-RockRMS` | `/rockrms-init` |

Then initialize your workspace: `cd` into (or create) your workspace directory, start your agent, and run **`rockrms-init`** — it interviews you and scaffolds the whole workspace (`AGENTS.md`, `_code`, a local `docs/` knowledgebase).

Or scripted: clone this repo and run [`setup.sh --host <name>`](setup.sh). Full per-host setup, verification, updates, and troubleshooting are in **[INSTALL.md](INSTALL.md)**.

## What's inside

| Component | What it does |
|---|---|
| `rules/` + `hooks/` | The house rules — formatting standards (general, SQL, Lava, Workflow Types), Lava conventions, documentation conventions, file organization, knowledge boundaries — **loaded into every session automatically**: a SessionStart hook on Claude Code and Codex (one command per rule chunk, because a single command's output is capped), the OpenCode plugin's system-prompt injection, Antigravity's always-on rules. |
| `skills/rock-sql-schema` | Annotated `CREATE TABLE` references for the Rock database, grouped by JOIN affinity. |
| `skills/rock-blocktypes` | Tested behavior notes for Group Attendance, Sign-Up, and Check-in Schedule Builder blocks, plus cron expressions and Property-vs-Attribute. |
| `skills/bema-room-management` | Full reference for the BEMA Room Management 2.0 plugin (schema, blocks, workflows) as BEMA ships it. |
| `skills/language-lava` | The Lava language reference (Lava ≠ Liquid!), ShortCodes, tested `{% modifyentity %}` behaviors, and boilerplate templates. |
| `skills/language-html-htmx` | Front-end gotchas verified inside Rock blocks (sticky positioning, debounced HTMX triggers, smooth-scroll after cascades). |
| `skills/surface-dynamicdata` | Working in the Dynamic Data block: the Query + Lava Template pair, settings that matter, PageParameterFilter wiring, the `htmx.process()` requirement, and why every "current URL" filter returns the BlockActions endpoint. |
| `skills/surface-htmlcontent` | Working in the HTML Content block: caching and context settings, what renders here that a Dynamic Data block cannot, and the nested-`<form>` trap. |
| `skills/surface-helix` | The Helix workbench: Lava Applications, Endpoints, and the Lava Application Content block — configuration, the devtools dev loop, tested Helix behaviors, Triumph's form controls, Chosen.js re-init. |
| `skills/surface-lava-tester` | The Lava Tester block as a REPL, a console for `{% modifyentity %}` corrections, and a host for measurement probes. |
| `skills/surface-sql-editor` | Rock's SQL Command page versus a desktop client, when to graduate, and how results get back to the agent. |
| `skills/format-tsql` | `format-tsql` — restyles any T-SQL query to house style. |
| `skills/rockrms-audit-pre-push-1` `-2` | The two-part pre-push documentation audit (code files, then READMEs). |
| `skills/rockrms-knowledge-current` `-future` | `rockrms-knowledge-current` — everything the plugin documents, by category and provenance tier, flagged against your instance's Rock version, plus your church overlay's catalog. `rockrms-knowledge-future` — the roadmap. |
| `skills/rockrms-changelog` | `rockrms-changelog` — the newest release notes and the installed commit, plus everything released since you last looked. |
| `skills/rockrms-add-knowledge` | `rockrms-add-knowledge` — turns a URL or excerpt into a cited, `summarized`-tier reference with its catalog row, ready for a PR; it never commits. |
| `skills/rockrms-init` | `rockrms-init` — interviews you and scaffolds a complete workspace from its templates (`AGENTS.md`, `_code`, `docs/`, `input_box/`); reads an installed church overlay's `workspace-defaults` skill instead of interviewing when one is present. |
| `knowledge/` | The catalog: `manifest.yaml` (source of truth), the renderer, and the rendered `Knowledge-current.md` / `Knowledge-future.md`. |

Reference-pack skills load on demand: the agent sees each skill's one-line description in every session and reads the underlying reference files only when the task calls for them.

The skills split along one seam: `language-*` skills carry what is true of a language **anywhere**; `surface-*` skills carry how to collaborate in a particular Rock **workbench** — its settings, its test loop, what its errors look like, and what to hand back to the agent. Knowledge lives in exactly one of them and the other cross-references it by skill name.

Skill names are the same on every host. The generic-sounding ones carry a `rockrms-` prefix so they cannot collide with another plugin's `changelog` or `add-knowledge` on hosts that list skills without a plugin prefix; Claude Code shows them as `/rockrms:rockrms-…`.

## What this plugin knows

The plugin answers only from **documented, cited** references — it is not "trained" on Rock. Every reference file is a row in [`knowledge/manifest.yaml`](knowledge/manifest.yaml) with a source, the Rock version it was verified on, and a provenance tier: `measured` (tested in a live Rock instance), `traced` (read from Rock source or official docs), or `summarized` (condensed from a URL, not yet verified). The rendered catalog is **[knowledge/Knowledge-current.md](knowledge/Knowledge-current.md)**; the roadmap is [knowledge/Knowledge-future.md](knowledge/Knowledge-future.md).

When a question falls outside the catalog, a session says so in one sentence and asks whether to answer from general knowledge (clearly marked unverified) or to start documenting the topic with `rockrms-add-knowledge`.

Releases are date-stamped in [CHANGELOG.md](CHANGELOG.md); `rockrms-changelog` prints the newest one together with the installed commit.

## Church overlays

This plugin carries only **church-agnostic** knowledge. Church-specific content — instance constants, intentional deviations from stock plugin behavior — ships as a separate overlay plugin that your church publishes from its own GitHub org, as its own one-plugin marketplace. Private repos work: GitHub auth gates who can install. A ready-to-copy skeleton with full instructions is in [`examples/overlay-template/`](examples/overlay-template/). The Summit Church runs its overlay this way from a private repo.

## How updates work

The plugin is **unversioned on purpose**: a git commit is the version. Claude Code's background marketplace refresh delivers every push automatically (`claude plugin marketplace update consta-tech` forces it); Codex updates with `codex plugin marketplace upgrade consta-tech`; OpenCode with `git pull` in the vendor clone; Antigravity by reinstalling. `rockrms-changelog` tells you which commit you are on and what has been released since you last looked.

> **Maintainer note:** do not add a `version` field to any of the manifests (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `plugin.json`). Doing so freezes users on that version until it is manually bumped.

## Repository layout

```
AIskill-RockRMS/
├── .claude-plugin/     # Claude Code: plugin.json + marketplace.json (this repo is its own marketplace)
├── .codex-plugin/      # Codex: plugin.json
├── .agents/plugins/    # Codex: marketplace.json
├── .opencode/          # OpenCode: plugins/rockrms.mjs (skills + rules + /rockrms-init) and command/
├── plugin.json         # Antigravity: plugin manifest
├── rules/              # Always-on house rules (hook-injected on Claude Code and Codex; Antigravity rules; OpenCode system prompt)
├── hooks/              # SessionStart hook that injects rules/ (Claude Code and Codex)
├── skills/             # The skill packs (agentskills.io format, host-neutral)
│   └── <skill>/
│       ├── SKILL.md    # Index + when-to-use routing
│       ├── references/ # Reference docs, loaded on demand
│       └── assets/     # Templates and static resources
├── knowledge/          # manifest.yaml (source of truth), render.py, the rendered catalog views
├── evals/              # claude plugin eval suite
├── tests/              # Repo checks that need no model: INSTALL.md structure
├── .githooks/          # pre-commit: render check + hook-slot check (git config core.hooksPath .githooks)
├── .github/workflows/  # knowledge-check: the same checks on every push and PR
├── setup.sh            # One-host installer: --host claude|codex|opencode|antigravity
├── CHANGELOG.md        # Date-stamped releases
├── CONTRIBUTING.md
├── INSTALL.md
└── README.md
```

## Other harnesses

The `skills/` tree follows the [Agent Skills](https://agentskills.io) open standard, so any harness that reads `SKILL.md` (Cursor, GitHub Copilot, Zed, Gemini CLI, …) can use the skills with `npx skills add Consta-Tech/AIskill-RockRMS`; the house rules are then pasted into that harness's instructions file. INSTALL.md has the steps. Adding first-class support for another host means one thin manifest or loader next to the four that exist — the content never changes.

## Contributing

Spot an error, learn a new tested behavior, or want to extend a reference? **[CONTRIBUTING.md](CONTRIBUTING.md)** has the fork-and-PR flow, the generic-versus-overlay sorting rule, the three provenance tiers and the evidence each needs, and the manifest-row and render-check steps. Inside a session, `rockrms-add-knowledge` drafts the reference and its catalog row for you and stops before the commit. Once merged, every developer receives the change on their next update.

Maintained by Consta Tech.
