---
name: workspace-defaults
description: Your Church's workspace scaffold defaults, consumed by the rockrms plugin's /rock-init command — church code repo, _code layout, .claude/settings.json content, and CLAUDE.md placeholder values. Use when initializing, repairing, or auditing a developer workspace at Your Church.
---

# Your Church Workspace Defaults

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.


The values `/rock-init` uses instead of interviewing a developer at your church. With this skill installed, the only interview question left is the git preference. (Delete this skill from your overlay if you'd rather developers answer the interview themselves.)

## Code layout

<!-- Pick one of the two layouts and delete the other. -->

- Workspace repos are named `claude-rockrms-<name>` and live under `~/GitHub/`.
- The shared church code repo is **`YourOrg/your-church-code-repo`** (if private, clone with `gh repo clone`).
- It is cloned as a **sibling** of the workspace, and `_code` is symlinked into it: `ln -s ../your-church-code-repo/_code _code`.

<!-- Or, with no shared code repo: "`_code` is a plain directory inside the workspace." -->

## Instance basics

Skip the instance-basics interview question — shared constants live in this plugin's `instance-facts` skill. Still scaffold `docs/instance-facts.md`, filling `{{OVERLAY_POINTER}}` with:

> Church-wide constants live in the `rockrms-yourchurch` plugin's `instance-facts` skill — that skill is authoritative. This file is for personal or not-yet-upstreamed values only.

## `.claude/settings.json`

```json
{
  "permissions": {
    "additionalDirectories": ["../your-church-code-repo"]
  },
  "extraKnownMarketplaces": {
    "consta-tech": {
      "source": { "source": "github", "repo": "Consta-Tech/AIskill-RockRMS" }
    },
    "yourchurch": {
      "source": { "source": "github", "repo": "YourOrg/AIskill-RockRMS-ABC" }
    }
  },
  "enabledPlugins": {
    "rockrms@consta-tech": true,
    "rockrms-yourchurch@yourchurch": true
  }
}
```

## CLAUDE.md placeholder values

| Placeholder | Value |
|---|---|
| `{{CHURCH_SUFFIX}}` | ` at Your Church` |
| `{{PLUGINS_PARAGRAPH}}` | "House rules, language references (Lava, T-SQL, HTMX), Rock schema docs, audit skills, and Your Church-specific knowledge come from the `rockrms` and `rockrms-yourchurch` Claude Code plugins. The house rules are injected automatically at session start — follow them." |
| `{{CODE_LAYOUT_BULLET}}` | "`_code/` is a symlink into my sibling clone of `YourOrg/your-church-code-repo`. All Rock code lives there. Commits and PRs for code changes happen in that repo, not this one." |
| `{{COMMIT_TARGET}}` | `in the your-church-code-repo repo` |
| `{{OVERLAY_NOTES}}` | One bullet per overlay skill worth flagging in every session, e.g. "Instance constants live in the `rockrms-yourchurch` plugin's `instance-facts` skill." |
