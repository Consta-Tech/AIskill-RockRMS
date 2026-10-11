# AIskill-RockRMS

A **Rock RMS development environment** for your coding agent — Claude Code, Codex, OpenCode, or Antigravity — packaged as a plugin. Install it once: every session gets our house rules, the Lava and T-SQL references, the database schema, and the audit workflows, and every improvement pushed here reaches you on your next update.

> **Rock RMS** is an open-source church management system built on ASP.NET. We develop against it with T-SQL, Lava (Rock's Liquid-fork templating language), and HTML/HTMX embedded in Rock Blocks.

## Install

Paste this into your coding agent:

```text
Install the rockrms plugin from https://github.com/Consta-Tech/AIskill-RockRMS — follow the repo's INSTALL.md for my agent, then run its rockrms-init skill in this directory.
```

Or follow **[INSTALL.md](INSTALL.md)** yourself: one block per agent with install, verify, update, and uninstall steps, then `rockrms-init` to scaffold your workspace. Prefer to watch? [Install walkthrough on YouTube](https://youtu.be/Kr5t_K2I0r4) (Claude Code, desktop app and terminal; recorded before the multi-host release, so it shows `/rockrms:rock-init` where the plugin now says `/rockrms:rockrms-init`).

## What changes

Ask the same question with and without the plugin: *"My Helix endpoint's `{% sql %}` sometimes returns `Lava Error: Execution Timeout Expired` — why doesn't my htmx error handler catch it?"*

<table>
<tr><td width="50%">

**Without**

> This usually indicates a SQL timeout. You can catch it with an `{% if %}` around the result, or handle the error status in `htmx:responseError`. You may also want to look at your query's indexes, and consider increasing the timeout in web.config…

</td><td width="50%">

**With**

> Measured behavior (`surface-helix` › Lava-with-Helix.md, tier **measured**, Rock v18.2): when `{% sql %}` times out, Rock discards the whole rendered template and returns that string with HTTP **200**. So no `{% if %}` in the template and no handler keyed on HTTP status can see it. The one safeguard is sizing: `{% sql timeout:'60' %}`, from the query's measured worst case.
>
> Separately, `{% if obj == null %}` after `| First` is still worth writing — it catches an empty result, which is a different and more common condition.

</td></tr>
</table>

Every answer names its reference, its provenance tier, and the Rock version it was verified on. When a topic is not documented yet, the session says so in one sentence and asks whether to answer from general knowledge (marked unverified) or to start a cited reference with `rockrms-add-knowledge`.

## What's inside

| | What it does |
|---|---|
| **House rules** (`rules/`) | Formatting standards for SQL, Lava, and Workflow Types, Lava conventions, documentation and file-organization conventions, knowledge boundaries. Loaded into every session automatically on every host. |
| **Reference packs** (5 skills) | `rock-sql-schema` (annotated `CREATE TABLE` scripts grouped by JOIN affinity), `rock-blocktypes`, `bema-room-management`, `language-lava` (Lava ≠ Liquid), `language-html-htmx`. Loaded on demand. |
| **Surface skills** (5 skills) | How to work in each Rock workbench: `surface-dynamicdata`, `surface-htmlcontent`, `surface-helix`, `surface-lava-tester`, `surface-sql-editor` — settings that matter, the test loop, what the errors look like. |
| **Workflows** (4 skills) | `format-tsql` restyles a query to house style; `rockrms-audit-pre-push-1` and `-2` run the pre-push documentation audit; `rockrms-init` interviews you and scaffolds a workspace. |
| **Catalog** (4 skills + `knowledge/`) | `rockrms-knowledge-current` lists everything documented, by category and tier, flagged against your Rock version; `rockrms-knowledge-future` is the roadmap; `rockrms-changelog` prints the newest release and your installed commit; `rockrms-add-knowledge` drafts a cited reference from a URL. |

The full list with every reference file is **[knowledge/Knowledge-current.md](knowledge/Knowledge-current.md)**. Skill names are the same on every host; the generic-sounding ones carry a `rockrms-` prefix so they cannot collide with another plugin's, which Claude Code shows as `/rockrms:rockrms-…`.

## Church overlays

This plugin carries only **church-agnostic** knowledge. Instance constants and intentional deviations from stock behavior ship as a separate overlay plugin your church publishes from its own GitHub org, private repos included. The ready-to-copy skeleton is [`examples/overlay-template/`](examples/overlay-template/).

## How updates work

The plugin is **unversioned on purpose**: a git commit is the version, so every push to `main` reaches installed machines on their next refresh (Claude Code refreshes in the background; the other hosts' update commands are in INSTALL.md). Releases are date-stamped in [CHANGELOG.md](CHANGELOG.md), and `rockrms-changelog` shows what has been released since you last looked.

## Contributing

Spot an error or learn a new tested behavior? **[CONTRIBUTING.md](CONTRIBUTING.md)** has the fork-and-PR flow, the three provenance tiers and the evidence each needs, and the one check to run. Working on a clone with an agent? It reads [AGENTS.md](AGENTS.md) for the repository map. Once merged, every developer receives the change on their next update.

## License

[MIT](LICENSE). Maintained by Consta Tech.
