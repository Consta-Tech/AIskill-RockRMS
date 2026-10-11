#!/usr/bin/env node
// scripts/opencode-driver.mjs — loads .opencode/plugins/rockrms.mjs against a fake OpenCode
// context and checks what it registers, with no model and no OpenCode install.
//
// Exercises both entry points: V2 setup(ctx) and V1 server(). Fails (exit 1) when the plugin
// registers fewer skills than skills/*/SKILL.md, injects fewer rules than rules/*.md, leaves a
// placeholder or Antigravity frontmatter in the injected text, or does not add /rockrms-init.
//
// Usage: node scripts/opencode-driver.mjs            # run the checks
//        node scripts/opencode-driver.mjs --print    # also print the injected house-rules text
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const pluginPath = path.join(root, '.opencode', 'plugins', 'rockrms.mjs');
const print = process.argv.includes('--print');

const expectedSkills = fs.readdirSync(path.join(root, 'skills'))
  .filter((d) => fs.existsSync(path.join(root, 'skills', d, 'SKILL.md'))).sort();
const expectedRules = fs.readdirSync(path.join(root, 'rules')).filter((f) => f.endsWith('.md')).sort();

const problems = [];
const check = (ok, message) => { if (!ok) problems.push(message); };

const { default: plugin } = await import(pathToFileURL(pluginPath).href);

// ---- V2: setup(ctx) ------------------------------------------------------------------------
const skills = new Map();
const commands = new Map();
const hooks = new Map();
const prompts = [];
const editorFor = (store) => ({
  get: (id) => store.get(id),
  add: (entry) => store.set(entry.id ?? entry.name, entry),
});
await plugin.setup({
  skill: { transform: async (cb) => { cb(editorFor(skills)); return { dispose: async () => {} }; } },
  command: { transform: async (cb) => { cb(editorFor(commands)); return { dispose: async () => {} }; } },
  session: {
    hook: async (name, handler) => { hooks.set(name, handler); return { dispose: async () => {} }; },
    prompt: async (input) => { prompts.push(input); },
  },
});

const registered = [...skills.keys()].sort();
check(JSON.stringify(registered) === JSON.stringify(expectedSkills),
  `V2 skills: registered ${registered.length}, expected ${expectedSkills.length} (${expectedSkills.filter((s) => !skills.has(s)).join(', ') || 'extra names'})`);
for (const skill of skills.values()) {
  check(skill.description && skill.description !== skill.name, `V2 skill ${skill.name} has no description`);
  check(skill.content && !skill.content.startsWith('---'), `V2 skill ${skill.name} content still carries frontmatter`);
}

const init = commands.get('rockrms-init');
check(init, 'V2 command /rockrms-init not registered');
if (init) {
  await init.execute({ sessionID: 'ses_test', prompt: { text: '' }, delivery: 'steer' });
  check(prompts.at(-1)?.text?.includes('rockrms-init'), 'V2 /rockrms-init did not prompt with the skill template');
}

const contextHook = hooks.get('context');
check(contextHook, 'V2 context hook not registered');
let v2Text = '';
if (contextHook) {
  const event = { system: [] };
  await contextHook(event);
  v2Text = event.system.map((p) => p.text ?? String(p)).join('\n');
}
const ruleBlocks = v2Text ? v2Text.split('\n\n---\n\n').length : 0;
check(v2Text.startsWith('# Rock RMS House Rules'), 'V2 injected text lacks the House Rules heading');
check(ruleBlocks === expectedRules.length, `V2 rules: injected ${ruleBlocks} blocks, expected ${expectedRules.length}`);
check(!/trigger: always_on/.test(v2Text), 'V2 injected text still carries Antigravity frontmatter');
check(!/<plugin-root>|\$\{CLAUDE_PLUGIN_ROOT\}/.test(v2Text), 'V2 injected text still carries a plugin-root placeholder');
for (const f of expectedRules) {
  const h1 = fs.readFileSync(path.join(root, 'rules', f), 'utf8').match(/^# .+$/m)?.[0];
  check(h1 && v2Text.includes(h1), `V2 injected text lacks the heading of ${f}`);
}

// ---- V1: server() --------------------------------------------------------------------------
const v1 = await plugin.server();
const config = {};
await v1.config(config);
await v1.config(config); // idempotent on a second load
check(config.skills?.paths?.length === 1 && config.skills.paths[0] === path.join(root, 'skills'),
  'V1 config did not add the skills path exactly once');
check(config.command?.['rockrms-init']?.template?.includes('rockrms-init'), 'V1 config did not register the rockrms-init command');
const output = { system: ['existing system prompt'] };
await v1['experimental.chat.system.transform']({}, output);
check(output.system.length === 1 && output.system[0].includes('# Rock RMS House Rules'),
  'V1 system transform did not append the rules to the last system entry');

// ---- report --------------------------------------------------------------------------------
if (print) process.stdout.write(v2Text + '\n');
for (const p of problems) console.error('ERROR ' + p);
console.log(problems.length
  ? `opencode plugin: ${problems.length} problem(s)`
  : `opencode plugin OK: ${registered.length} skills, ${ruleBlocks} rules, /rockrms-init, V1 and V2`);
process.exit(problems.length ? 1 : 0);
