// .opencode/plugins/rockrms.mjs — OpenCode plugin for the rockrms skill pack.
//
// OpenCode V2 (2.0+) calls setup(ctx); V1 (1.18.29+) calls server(). Both paths do the same
// three things, so a clone of this repository is a complete install on either version:
//   1. register every skills/*/SKILL.md so the agent can load it with its skill tool,
//   2. inject rules/*.md — the house rules — into the system prompt on every turn (the
//      equivalent of the SessionStart hook Claude Code and Codex run),
//   3. register /rockrms-init as a slash command that loads the rockrms-init skill.
//
// Install (see INSTALL.md > OpenCode): clone the repo under ~/.config/opencode/vendor/rockrms
// and add a one-line loader in ~/.config/opencode/plugins/rockrms.js that re-exports this file.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '../..');
const skillsDir = path.join(root, 'skills');
const rulesDir = path.join(root, 'rules');
const commandPath = path.join(__dirname, '..', 'command', 'rockrms-init.md');

const PLUGIN_ID = 'rockrms';
const INIT_COMMAND = 'rockrms-init';
const FRONTMATTER = /^---[^\S\r\n]*\r?\n([\s\S]*?)\r?\n---[^\S\r\n]*(?:\r?\n|$)/;

function stripFrontmatter(text) {
  return text.replace(FRONTMATTER, '');
}

// Reads the flat `key: value` lines of a SKILL.md frontmatter; every rockrms skill keeps
// its name and description on one line each, so no YAML parser is needed.
function frontmatter(text) {
  const out = {};
  const match = text.match(FRONTMATTER);
  if (!match) return out;
  for (const line of match[1].split(/\r?\n/)) {
    const colon = line.indexOf(':');
    if (colon > 0) out[line.slice(0, colon).trim()] = line.slice(colon + 1).trim().replace(/^(['"])(.*)\1$/, '$2');
  }
  return out;
}

function loadSkills() {
  const skills = [];
  for (const dir of fs.readdirSync(skillsDir).sort()) {
    const skillPath = path.join(skillsDir, dir, 'SKILL.md');
    if (!fs.existsSync(skillPath)) continue;
    const raw = fs.readFileSync(skillPath, 'utf8');
    const meta = frontmatter(raw);
    const name = meta.name || dir;
    skills.push({
      id: name,
      name,
      description: meta.description || name,
      path: skillPath,
      content: stripFrontmatter(raw).trim(),
    });
  }
  return skills;
}

// The house rules, concatenated once per process. Frontmatter (Antigravity's trigger line) is
// stripped, and the plugin-root placeholder the rules use for grep commands becomes a real path.
let houseRulesText = null;
function houseRules() {
  if (houseRulesText !== null) return houseRulesText;
  const files = fs.readdirSync(rulesDir).filter((f) => f.endsWith('.md')).sort();
  const parts = files.map((f) =>
    stripFrontmatter(fs.readFileSync(path.join(rulesDir, f), 'utf8'))
      .replace(/\$\{CLAUDE_PLUGIN_ROOT\}|<plugin-root>/g, root)
      .trim(),
  );
  houseRulesText = '# Rock RMS House Rules (injected by the rockrms plugin)\n\n' + parts.join('\n\n---\n\n');
  return houseRulesText;
}

// Command frontmatter is JSON so both loaders can share it without a YAML parser.
async function commandDefinition() {
  const raw = await fs.promises.readFile(commandPath, 'utf8');
  const match = raw.match(FRONTMATTER);
  if (!match) throw new Error('Missing command frontmatter: ' + commandPath);
  return { ...JSON.parse(match[1]), template: raw.replace(FRONTMATTER, '').trim() };
}

export default {
  id: PLUGIN_ID,

  async setup(ctx) {
    try {
      const skills = loadSkills();
      await ctx.skill.transform((editor) => {
        for (const skill of skills) {
          if (editor.get(skill.id)) continue;
          editor.add(skill);
        }
      });
    } catch {
      // Skill registration is best-effort; the rules and command below still load.
    }

    try {
      const command = await commandDefinition();
      await ctx.command.transform((editor) => {
        if (editor.get && editor.get(INIT_COMMAND)) return;
        editor.add({
          name: INIT_COMMAND,
          description: command.description,
          execute: ({ sessionID, prompt, delivery }) =>
            ctx.session.prompt({
              ...prompt,
              sessionID,
              text: prompt.text ? `${command.template}\n\n${prompt.text}` : command.template,
              delivery,
            }),
        });
      });
    } catch {
      // Keep skills and rules available if command registration fails.
    }

    try {
      await ctx.session.hook('context', (event) => {
        event.system.push({ type: 'text', text: houseRules() });
      });
    } catch {
      // Optional hook failures must not block plugin loading.
    }
  },

  async server() {
    return {
      config: async (config) => {
        config.skills = config.skills || {};
        config.skills.paths = config.skills.paths || [];
        if (!config.skills.paths.includes(skillsDir)) config.skills.paths.push(skillsDir);

        try {
          config.command = config.command || {};
          if (!config.command[INIT_COMMAND]) config.command[INIT_COMMAND] = await commandDefinition();
        } catch {
          // Keep skill discovery available if command registration fails.
        }
      },

      'experimental.chat.system.transform': async (_input, output) => {
        const text = houseRules();
        if (output.system.length > 0) {
          output.system[output.system.length - 1] += '\n\n' + text;
        } else {
          output.system.push(text);
        }
      },
    };
  },
};
