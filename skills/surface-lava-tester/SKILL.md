---
name: surface-lava-tester
description: Collaborating in Rock's Lava Tester block — a Rock Shop plugin block, usually on an admin-only page with every Lava command enabled, that renders any Lava you paste into it. Covers its three jobs (render a template or fragment, act as a console for {% modifyentity %} writes instead of SQL UPDATE or GUI bulk updates, and run measurement probes against undocumented Lava behavior), what differs from the block you are really targeting (CurrentPerson, PageParameter, the rows / Form / QueryString merge fields), how errors surface, and what to hand back to Claude. Use when testing a piece of Lava outside its block, probing a filter's behavior, or applying a data correction through Lava.
---

# The Lava Tester as a Workbench

The `language-lava` skill says what Lava does. This skill says how to **find out** what Lava does on your instance, and how to use the same block as a safe console for writes.

## What it is

The **Lava Tester** is a block type from the Rock Shop that most Rock instances have installed — one of the community's standard recommendations. You paste Lava in, it renders it, and it shows you the output. Each Lava Tester block has its own **Enabled Lava Commands** setting; because the block normally lives on a page only Rock Admins can reach, the usual configuration is *every command enabled*. In that configuration there is nothing a real block can run that the tester cannot.

Where it lives varies by instance (often under **Admin Tools > Power Tools**). Record the page URL in your workspace's `docs/instance-facts.md` the first time you find it.

## Three jobs

1. **Render a template or a fragment.** Paste a whole Formatted Output template, or just the twelve lines you are unsure about, and read the result before it goes anywhere near a real block.
2. **A console for writes.** When rows need correcting, run a `{% modifyentity %}` command here rather than an `UPDATE` in the SQL editor or a bulk-update in Rock's UI. The entity layer fires its history and validation, and the named `return:` variable reports per-row success. The section below has the sequence.
3. **Probes.** A single-render template that exercises an undocumented behavior and annotates each line with the expected result. The `assets/Lava-Coercion-Probe.lava` file is the model.

## What differs from the target block

The tester can *execute* anything; what it cannot do is *impersonate* the context a real block has. These follow from where each merge field comes from — reason from them, and measure when it matters:

| In the target block | In the Lava Tester |
|---|---|
| `CurrentPerson` is the visitor | `CurrentPerson` is **you**, the admin running the test. Security-sensitive branches will take the admin path. |
| `'Global' \| PageParameter:'x'` reads the target page's URL | Reads the **tester page's** URL. Simulate by appending `?x=value` to the tester's own address. |
| Dynamic Data: `rows` holds the query result | Does not exist. Stub it: run the query in a `{% sql return:'rows' %}` block above the template, or build a small array with `FromJSON`. |
| Lava Application Endpoint: `Form`, `QueryString` | Do not exist. `{% assign %}` a stand-in object with `FromJSON`. |
| Block settings (cache duration, the block's own Enabled Lava Commands) | The tester's settings apply, not the target block's. A template that works here can still be missing a command there. |
| The `^/{app}/{endpoint}` Helix shorthand | Only resolves where the Helix runtime is loaded; the tester renders the string as-is. |

Output is rendered as HTML. A probe that needs its whitespace read literally belongs inside a `<pre>` element.

## Using it as a console for writes

The sequence that keeps a correction reversible and auditable:

1. **Look before writing.** Run a `SELECT` (see the `surface-sql-editor` skill) that returns exactly the rows you intend to change, and keep its count.
2. **Write the command to the house rules** — separate `{% modifyentity %}` blocks for separate fields, one `[[ property ]]` per field, and a named `return:'modify_…'` on every block. The rules are injected into every session; the `language-lava` skill has the full parameter reference.
3. **Dry-run with a rolled-back transaction.** Wrap the command in `{% dbtransaction forcerollback:'true' %} … {% enddbtransaction %}`. Output inside the block is suppressed on rollback, so inspect `TransactionResult` after it — `Success` and `ErrorMessage | Trim` tell you whether the real run would have gone through.
4. **Run it for real,** loop over the rows, and render each `modify_….Success` so a partial failure is visible.
5. **Verify with the same `SELECT`** from step 1. The count and the changed values are the evidence that the correction landed.

## Probes

A probe is how the `language-lava` skill's measured behaviors were produced, and how they get re-verified after a Rock upgrade instead of re-derived. Rules for building one, carried over from `assets/Lava-Coercion-Probe.lava`:

- **One source line per test.** The `{% assign %}` and its output share a line, so each source line yields exactly one output line and no whitespace-control markers are needed.
- **No filter pipes inside an `{% if %}` test.** Lava cannot evaluate them there — pre-assign the value.
- **Riskiest tests last within each group.** A mid-render failure then still leaves the data above it. If output stops early, note where; that is a result too.
- **Annotate every line with `(expect: …)`.** A probe with no expectations is a demo, not a measurement. Mark anything unmeasured `UNVERIFIED`.

Re-run a probe after a Rock upgrade before trusting the recorded behavior, and before relying on an edge case the filter reference does not state.

## Error surface

A Lava error renders as a **red Rock alert** carrying the `Lava Error:` message, in place of the output. Nothing partially renders below it. Read the message before the code — it usually names the tag or filter.

## Handing the result back to Claude

- **Claude has browser tools:** give it the tester page's URL and ask it to read the tab. It sees the input, the output, and any alert.
- **Otherwise:** paste the exact Lava you ran *and* the rendered output (or the alert text), together. Output without its input is not reproducible.
- **Always:** the page URL, and what you expected the output to be.

## Related skills

- `language-lava` — the language reference the probes measure against; the `{% modifyentity %}` parameter reference and the DB Transaction command.
- `surface-sql-editor` — the before-and-after `SELECT` around a write, and why writes do not happen there.
- `surface-dynamicdata`, `surface-htmlcontent`, `surface-helix` — the blocks whose context the tester cannot fully impersonate.
