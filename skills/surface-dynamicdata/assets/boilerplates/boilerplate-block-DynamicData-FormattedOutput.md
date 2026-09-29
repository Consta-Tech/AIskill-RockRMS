# Boilerplate Template — Dynamic Data Formatted Output

Applies to `-FormattedOutput.lava` files under `_code/Block-DynamicData/PageId_*/`.

## Structure rules

The boilerplate is a **Lava** block comment (`/- … -/`) at the top of the file. Unlike the query file, this one renders to HTML and nothing downstream needs to read the header, so a Lava comment is correct — it is stripped before it reaches the browser.

Every field below is on its own line, indented 4 spaces from the comment boundary. Field labels use Title Case followed by a colon.

### Required fields (in this order)

1. **Path** — the file's path relative to the repo root. Always present, always first.
2. **PageParameters** — a bulleted list of the parameters this template reads *directly*, one per bullet, formatted as `{key} ({FieldType}): {how the template uses it}`. Parameters that only the paired query reads are documented in that query's boilerplate, not here. If this template reads none, a single bullet that says `- none`.
3. **Description** — *optional*. One paragraph, present tense, describing what the template renders. Maximum ~5 lines.

There is deliberately **no "Enabled Lava Commands" field.** Which commands the block allows is Rock configuration on the block, not a property of this file; if the template needs one, note it inline at the point of use.

### Heuristics

- Name the paired query file in the Description when one exists. The two files are meaningless apart, and a reader who opens the formatted output first has no other way to find the shape of `rows`.
- If the template installs any global JavaScript side effect — an event listener on `document.body`, a call to `htmx.process()` — say so in the Description. A Dynamic Data Block mounts client-side, so these are easy to miss and hard to debug. See `references/DynamicData-With-Htmx.md` in this skill for the HTMX case specifically.
- The boilerplate should aim to be 121 characters wide.
  - In other words, the comment block opens with one forward-slash (`/`) followed by 120 dashes (`-`), and closes with 120 dashes followed by a forward-slash.
  - Technically it can be as wide as 147 characters. Be flexible between 121 and 147 where it benefits the prose, but never exceed 147.
- Target length: **≤ 20 lines** between the opening and closing comment boundaries.

## Example

```lava
/------------------------------------------------------------------------------------------------------------------------

    Path:
    _code/Block-DynamicData/PageId_6180/BlockId_15034-FormattedOutput.lava

    PageParameters:
    - c1 (Campus): highlights the matching column header when a membership Campus is selected

    Description:
    Renders the rows returned by BlockId_15034-Query.lava.sql as a responsive card list rather than the default Grid,
    grouping Attendees by their membership Campus. Calls htmx.process() on the Block root after render so that the
    per-row detail links are wired up.

------------------------------------------------------------------------------------------------------------------------/
```
