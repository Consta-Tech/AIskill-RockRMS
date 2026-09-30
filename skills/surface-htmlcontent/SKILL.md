---
name: surface-htmlcontent
description: Working in Rock's HTML Content block with Lava enabled — the block settings that change behavior (Enabled Lava Commands, Cache Duration, Context Parameter and Context Name, Validate Markup, versioning and approval), what this block can do that a Dynamic Data block cannot (it renders during the page request, so Page:'Url' and SetUrlParameter return the real page and HTMX processes its markup at page load), and its traps (cached output ignores page parameters and the current person unless the Context Parameter captures them; a <form> written inside the block is dropped and its buttons post the whole page back). Use when writing, debugging, or reviewing an HTML Content block, or choosing between HTML Content and another block type.
---

# The HTML Content Block as a Workbench

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Rock's most general block: HTML plus Lava, rendered when the page is requested. The `language-lava` skill covers the Lava and the `language-html-htmx` skill covers front-end behavior verified inside Rock; this skill covers what the **block** does to what you paste into it.

## Settings that change behavior

As declared in Rock's Obsidian block source (`Rock.Blocks/Cms/HtmlContentDetail`, `develop` branch, read September 2026 — names may differ slightly by version):

| Setting | Default | Why it matters |
|---|---|---|
| **Enabled Lava Commands** | none | A `{% sql %}`, `{% modifyentity %}`, or entity command that is not enabled here fails at render, however correct the Lava is. Check this before debugging the Lava. |
| **Cache Duration** (seconds) | `0` | Above zero, the block caches the **rendered HTML after Lava has resolved**. The cache key is the block plus the Context Parameter/Name value — **not** the current person and **not** the page's other query-string parameters. Any Lava that varies by `CurrentPerson` or by a PageParameter the Context Parameter does not name will serve one visitor's output to the next. Keep it `0` while developing; raise it only for content that is genuinely the same for everyone. |
| **Cache Tags** | — | Lets a group of blocks' caches be expired together. |
| **Context Parameter** / **Context Name** | — | Content personalized per query-string value. Two blocks with the **same** Context Name and Context Parameter **share the same stored content** — the mechanism behind one menu block edited once and shown on several pages. |
| **Validate Markup** | on | On save, the HTML is parsed for mismatched tags *after Lava is neutralized*, so a `</div>` that only appears in one `{% if %}` branch reads as unbalanced. The first save warns; saving again acknowledges the warning and proceeds. |
| **Enable Versioning** / **Require Approval** | off | Versioning keeps prior content; approval (which requires versioning) holds new content until approved, so a "saved" edit can be invisible on the page. |
| **Code Editor by Default** | on | Opens the code view rather than the visual editor. The visual editor rewrites markup; keep this on for anything with Lava in it. |
| **Image / Document Root Folder**, **User Specific Folders** | `~/Content` | Where the editor's uploads land. |

Merge fields the content receives: `CurrentPerson` (and the legacy `Person`), `CurrentPage`, `CurrentVisitor`, `CurrentBrowser`, `CurrentPersonCanEdit`, `CurrentPersonCanAdministrate`, `PageParameter`, `GlobalAttribute`, `Campuses`, `RockVersion`, `Date`, `Time`, `DayOfWeek`, plus `Context.{EntityTypeName}` for any page context entity.

## What renders here that does not render elsewhere

The block renders **during the page request**, so it sees the real page:

- `'Global' | Page:'Url'`, `Page:'Path'`, `Page:'QueryString'`, and `'Current' | SetUrlParameter:…` return the page the reader is on. Build links with them freely. (Inside a Dynamic Data block every one of these returns the block's API endpoint instead — see the `surface-dynamicdata` skill.)
- Its markup is in the page HTML when HTMX initializes, so `hx-*` attributes are processed at load without any `htmx.process()` call. The HTMX **runtime** is only present, though, when a Lava Application Content block is on the same page — check `typeof htmx` in the console before blaming the markup. See the `surface-helix` skill.
- `{[ shortcode ]}` calls, including chart ShortCodes over a `{% sql %}` result, render here with no grid machinery in the way.

## Choosing this block

- A **grid** with export, Communicate, and Merge Template actions over a query → Dynamic Data (`surface-dynamicdata`).
- **Round-trips without a page load** (HTMX, endpoints) → Lava Application Content (`surface-helix`).
- Everything else that is HTML plus Lava — a KPI tile row, a shared menu, a chart, a page-menu replacement with badges, a table injected beside a core block — is this block.

## Traps

- **No `<form>` inside the block.** Every Rock page is already one ASP.NET `<form>`, and the browser drops a nested form — its buttons fall through to the page form, and a submit posts the whole page back. Details and the fix are in `references/No-Nested-Forms.md`.
- **Caching hides your edits and other people's data.** Symptom: a change that "did not take", or a page showing the previous visitor's name. Check Cache Duration first.
- **Approval hides your edits.** Symptom: a save that succeeds and changes nothing. Check Require Approval.
- **A missing enabled command looks like a Lava bug.** The error names the command; enable it on the block.

## The test loop

1. Edit the file in `_code/Block-HTMLContent/PageId_{id}/` to house style, with the Lava boilerplate at the top.
2. In Rock, block **Edit HTML** → code editor → paste → **Save**. Acknowledge a markup warning only after reading it.
3. Load the page with the parameters the block reads, and as the kind of person the block is for — an admin sees every branch.
4. A Lava error renders as red `Lava Error:` text in the block's place. Copy it verbatim.
5. Hand back to Claude: the **page URL** including its query string, **observed versus expected**, and the error text if any. If Claude has browser tools, give it the URL and let it read the tab.

A block on an admin-only page with Lava enabled also serves as a **probe host** when no Lava Tester is installed — see the `surface-lava-tester` skill for the probe pattern.

## Related skills

- `language-lava` — the language; `language-html-htmx` — sticky positioning, debounced triggers, smooth-scroll after swaps, all verified inside Rock blocks.
- `surface-dynamicdata` — the grid block, and why its URL filters lie.
- `surface-helix` — where the HTMX runtime comes from and how endpoints are built.
