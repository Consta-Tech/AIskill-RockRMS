# `position: sticky` in Rock's Internal Site

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



CSS `position: sticky` lets an element scroll normally with the page until it hits a configured offset from the viewport, then "pin" there until its containing block scrolls past. It's ideal for floating helper sidebars, on-page tables-of-contents, or persistent action bars.

Two Rock-specific gotchas will silently break a naïve implementation. Both have to be addressed for the helper to actually pin where you expect.


## Gotcha 1 — Bootstrap 3 floats give sticky no room to stick

Rock's internal site uses Bootstrap 3, where `.row > .col-*` columns are **floated** by default. Floated columns size themselves to their own content — they do **not** stretch to match a taller sibling.

Because `position: sticky` is constrained by its **containing block**, a sticky element placed inside a short floated column has almost no scroll-room before its parent's bottom edge reaches it, at which point sticky un-pins and scrolls away with the parent. Symptom: the helper appears static, or barely moves when the user scrolls.

**Fix:** switch the row to flexbox so all columns share the row's height. Default `align-items: stretch` is what you want — explicitly setting `flex-start` reproduces the original bug.

```css
#my-page-container > .row {
    display: flex;
    /* align-items defaults to `stretch`. Do NOT set flex-start —
       that re-introduces the content-height problem. */
}
#my-page-container > .row > [class*="col-"] {
    float: none;
}
```


## Gotcha 2 — Rock's fixed navbar covers the top 80 px of the viewport

Rock's top header is `<nav class="navbar navbar-fixed-top rock-top-header">` — `position: fixed; top: 0; height: 80px; z-index: 1030`. Anything you pin with `top: 0` (or any value below ~80) ends up *behind* the navbar and is invisible until it scrolls past the navbar's bottom edge.

This is easy to misdiagnose: an unrelated DOM element with `id="fixed-header"` exists on some Rock pages and is **statically positioned** despite the name. Don't rely on that id — measure the actual `.navbar.navbar-fixed-top` to find what's pinned to the top.

**Fix:** offset the sticky `top` by the navbar height plus a small breathing room.

```css
.my-sticky-element {
    position: sticky;
    top: 92px;  /* 80px navbar + 12px breathing gap */
}
```


## Canonical example

Working pattern from `_code/Block-LavaApplicationContent/PageId_6076/BlockId_14800.lava` — a three-column Bootstrap 3 layout with a sticky helper sidebar:

```html
<style>
    #my-page-container > .row {
        display: flex;
    }
    #my-page-container > .row > [class*="col-"] {
        float: none;
    }
</style>

<div id="my-page-container">
    <div class="row">
        <div class="col-sm-2">
            {%- comment -%} Left rail (outline, nav, etc.) {%- endcomment -%}
        </div>
        <div class="col-sm-7">
            {%- comment -%} Main content — this column drives the row height {%- endcomment -%}
        </div>
        <div class="col-sm-3">
            <div style="position:sticky; top:92px;">
                {%- comment -%} Sticky helper content {%- endcomment -%}
            </div>
        </div>
    </div>
</div>
```


## Diagnosing a sticky that won't stick

If your sticky element doesn't behave as expected, check the following in this order in the browser console:

1. **Is sticky activating at all?** Compare `getBoundingClientRect().top` of the sticky element against `getComputedStyle(el).top`. After you scroll past activation, `rect.top` should equal the configured `top` value (e.g., 92).

2. **Is the containing block tall enough?** Sticky can only pin within its parent's box. Compare the parent's height to the sticky element's height — the difference is your "stick room." Example: if the sticky is 546 px tall and the parent is 570 px tall, you only have 24 px of stick room before the parent scrolls past.

3. **Is something covering the pinned position?** Walk all `position: fixed` and high-`z-index` elements near the top of the viewport:
    ```javascript
    Array.from(document.querySelectorAll('*'))
        .filter(el => {
            const cs = getComputedStyle(el);
            const r = el.getBoundingClientRect();
            return cs.position === 'fixed'
                && r.top < 100
                && r.height > 0
                && r.width > 200;
        })
        .map(el => ({ cls: el.className, top: getComputedStyle(el).top, h: el.getBoundingClientRect().height|0 }));
    ```
    Anything that returns from this on Rock's internal site is a candidate for what's covering your sticky.

4. **Is an ancestor breaking sticky entirely?** Sticky fails silently if any ancestor has `overflow: hidden/auto/scroll`, a `transform` other than `none`, `will-change: transform`, or `contain: paint|layout`. Walk the ancestor chain and inspect each.
