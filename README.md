# AIskill-RockRMS

A complete **Rock RMS development environment** for Claude Code, packaged as a plugin. Install it once and every session gets our house rules, language references, schema docs, and audit workflows — and every improvement pushed to this repo reaches you automatically.

> **Rock RMS** is an open-source church management system built on ASP.NET. We develop against it with T-SQL, Lava (Rock's Liquid-fork templating language), and HTML/HTMX embedded in Rock Blocks.

## Install

```bash
claude plugin marketplace add Consta-Tech/AIskill-RockRMS
claude plugin install rockrms@consta-tech
```

Or scripted: clone this repo and run [`setup.sh`](setup.sh). Full setup — including the developer workspace repo, the `_code` symlink, and troubleshooting — is in **[INSTALL.md](INSTALL.md)**.

## What's inside

| Component | What it does |
|---|---|
| `rules/` + `hooks/` | Four house-rule documents (SQL/Lava formatting standards, Lava conventions, documentation conventions, file organization) **injected into every session automatically** via a SessionStart hook. |
| `skills/rock-sql-schema` | Annotated `CREATE TABLE` references for the Rock database, grouped by JOIN affinity. |
| `skills/rock-blocktypes` | Tested behavior notes for Group Attendance, Sign-Up, and Check-in Schedule Builder blocks, plus cron expressions and Property-vs-Attribute. |
| `skills/bema-room-management` | Full reference for the BEMA Room Management 2.0 plugin (schema, blocks, workflows) as BEMA ships it. |
| `skills/language-lava` | The Lava language reference (Lava ≠ Liquid!), Helix/HTMX, ShortCodes, form controls, tested `{% modifyentity %}` behaviors, and boilerplate templates. |
| `skills/language-html-htmx` | Front-end gotchas verified inside Rock blocks (sticky positioning, debounced HTMX triggers, smooth-scroll after cascades). |
| `skills/format-tsql` | `/rockrms:format-tsql` — restyles any T-SQL query to house style. |
| `skills/audit-pre-push-1` `-2` | The two-part pre-push documentation audit (code files, then READMEs). |

Reference-pack skills load on demand: Claude sees each skill's one-line description in every session and reads the underlying reference files only when the task calls for them.

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
├── skills/             # The skill packs (agentskills.io format, harness-neutral)
│   └── <skill>/
│       ├── SKILL.md    # Index + when-to-use routing
│       ├── references/ # Reference docs, loaded on demand
│       └── assets/     # Templates and static resources
├── INSTALL.md
└── README.md
```

## Other harnesses (Codex, Zed, …)

Claude Code is the only supported harness today. The `skills/` tree follows the [Agent Skills](https://agentskills.io) open standard, so support for additional harnesses can be added later as thin per-harness manifests without restructuring the content.

## Contributing

Spot an error, learn a new tested behavior, or want to extend a reference? Clone this repo, make the change, and open a PR. Once merged, every developer receives it automatically on their next session.

Maintained by Consta Tech.
