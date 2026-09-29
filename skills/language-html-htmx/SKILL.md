---
name: language-html-htmx
description: Tested HTML, CSS, and HTMX behaviors and gotchas for front-end code inside Rock RMS blocks — position:sticky under Bootstrap 3 floated columns, debounced hx-trigger losing the event object inside hx-vals, and smooth-scrolling after cascading HTMX swaps. Use when writing or debugging HTML/HTMX/JavaScript embedded in Rock blocks, especially when front-end behavior differs from what plain-web experience predicts.
---

# HTML / HTMX Esoterica for Rock Blocks

`references/` collects front-end behaviors that were verified by testing inside Rock RMS blocks. Each file is symptom-oriented: find the symptom, read that file.

## File Index

| File | Symptom it solves |
|------|-------------------|
| [Sticky-Positioning.md](references/Sticky-Positioning.md) | `position: sticky` element doesn't pin, or un-pins almost immediately — Rock's internal site uses Bootstrap 3 floated columns, which give sticky no room to stick. |
| [Debounced-Triggers-Lose-Event.md](references/Debounced-Triggers-Lose-Event.md) | An HTMX request silently stops firing once you add `delay:` to `hx-trigger` — the debounce timer outlives the DOM event, so `event` inside `hx-vals='js:{...}'` is `undefined`. |
| [SmoothScroll-After-Cascade.md](references/SmoothScroll-After-Cascade.md) | `scrollIntoView({behavior:'smooth'})` lands in the wrong place after an HTMX response that triggers follow-up GETs — the fix is a debounced latch keyed off `htmx:afterSettle`. |

## Related skills

- `surface-helix` — Helix (Rock's HTMX implementation for Lava Applications), its tested behaviors, Triumph's form controls, and the Chosen.js re-initialization pattern after HTMX swaps.
- `surface-dynamicdata` — why `hx-*` attributes rendered by an Obsidian Dynamic Data block are inert until the template calls `htmx.process()`.
- `surface-htmlcontent` — the nested-`<form>` trap and where the HTMX runtime on a page comes from.
- `language-lava` — the Lava these blocks and endpoints are written in.
