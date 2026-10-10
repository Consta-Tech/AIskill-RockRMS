# Overlay Plugin Template

A skeleton for building **your church's overlay** to the generic `rockrms` plugin. The generic plugin carries everything true of Rock RMS anywhere; your overlay carries what is true only at your church — instance constants, intentional deviations from stock behavior, local conventions.

The overlay is its own repo, its own plugin, and its own one-plugin marketplace. That way your church controls access (private repos work — GitHub auth gates installs) and ships updates independently of the generic pack.

## How to use this template

1. Copy this directory into a new repo in your church's GitHub org (e.g., `YourOrg/AIskill-RockRMS-ABC`, where ABC is your church's abbreviation). Private is fine — and recommended once instance facts accumulate.
2. Replace every `yourchurch` placeholder in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, and rewrite `skills/instance-facts/SKILL.md` with your instance's real values.
3. Fill in `skills/workspace-defaults/SKILL.md` — it's what makes the generic `rockrms-init` skill scaffold **your** church's workspace layout without interviewing each developer (or delete it to keep the interview).
4. Keep `skills/knowledge-manifest/` — replace the church name in its `SKILL.md` and list every reference your overlay ships in its `manifest.yaml`. The generic plugin's `rockrms-knowledge-current` and `rockrms-knowledge-future` find that skill **by name** and append an "Overlay: Your Church" section rendered from it, so your developers see one catalog.
5. **Do not add a `version` field to `plugin.json`.** Left unset, every git push is a new version and installs auto-update.
6. Publish, then install alongside the generic pack:

   ```bash
   claude plugin marketplace add Consta-Tech/AIskill-RockRMS
   claude plugin install rockrms@consta-tech
   claude plugin marketplace add YourOrg/AIskill-RockRMS-ABC
   claude plugin install rockrms-yourchurch@yourchurch
   ```

   For a **private** overlay, prefer adding its marketplace via SSH so background auto-updates can authenticate: `claude plugin marketplace add git@github.com:YourOrg/AIskill-RockRMS-ABC.git`. Over HTTPS, update it manually with `claude plugin marketplace update yourchurch`.

## Rules that keep overlays healthy

- **Sort content by scope.** Church-as-provenance ("verified on our instance") belongs in the generic pack — contribute it via PR to AIskill-RockRMS. Church-as-required-context (constants, deviations, local config) belongs in the overlay.
- **Cross-plugin references by skill name, never file path.** Installed plugins live in separate directories, so `../` paths across plugins do not resolve. Write "see the `bema-room-management` skill (rockrms plugin)".
- **A deviations skill earns its keep.** When your church deliberately departs from stock Rock or stock plugin behavior, document it in the overlay so nobody — human or Claude — "fixes" a decision back to stock. Model it on `skills/instance-facts/SKILL.md`: a description that tells Claude *when* to read it, and reference files carrying the archived rationale.

## Zero-touch team setup (optional)

Declare both marketplaces and both plugins in your developers' workspace-repo `.claude/settings.json`, and Claude Code offers to install everything when they trust the workspace:

```json
{
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
