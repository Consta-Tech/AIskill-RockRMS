# HTMX attributes rendered by an Obsidian Dynamic Data block are never processed

HTMX registers its handlers by scanning the DOM and processing every element that carries an `hx-*` attribute. It performs that scan once, at initialization. **Markup that arrives after the scan is invisible to it.**

Obsidian blocks are Vue components that mount client-side, so a Dynamic Data block's Lava output is injected into the page *after* load — after HTMX has already swept the document. The `hx-get` / `hx-post` attributes in that output are inert strings. Clicking does nothing: no HTTP request, no console error, no visual change.

Tested 2026-08-12 on a throwaway page hosting one Obsidian Dynamic Data block and one Lava Application Content block.


## Where the runtime comes from

**Any Lava Application Content block on the page loads HTMX page-wide — including a block that is not bound to a Lava Application at all.** Adding an empty Lava Application Content block to a page changes `typeof htmx` from `'undefined'` to `'object'` everywhere on that page.

The `^/{app-slug}/{endpoint-slug}` shorthand also resolves correctly from a Dynamic Data block once its markup is processed, and it resolves to the app named in the URL regardless of which application (if any) the Lava Application Content block is bound to. The block is a runtime carrier; the slug in the URL is what selects the application.


## What goes wrong

Load sequence on a page hosting both block types:

1. Page HTML is served. The Lava Application Content block's markup is in it. The Obsidian block's is not.
2. Helix's HTMX bundle loads, registered through the page head.
3. HTMX initializes and processes everything currently in the DOM. Lava Application Content markup: registered. Dynamic Data markup: does not exist yet.
4. `DOMContentLoaded` fires.
5. Vue mounts the Obsidian block and injects its Lava output, `hx-*` attributes and all.
6. Nothing ever processes step 5's markup.

Two consequences follow, and they are the reason this is hard to diagnose:

- **`document.querySelector` against Dynamic Data markup returns `null` at `DOMContentLoaded`.** The elements genuinely do not exist yet.
- **A `<script>` inside the Dynamic Data template executes after the mount, and the mount timing varies between page loads.** Obsidian evaluates script blocks in the injected output. `document.readyState` at that moment has been observed as both `complete` (`DOMContentLoaded` long past — a listener registered there never fires) and `interactive` (`DOMContentLoaded` has not fired yet — a listener registered there *would* fire). Anything keyed to `DOMContentLoaded` therefore works **intermittently**, which is worse than failing outright.


## Fix

One line, as the last thing in the Dynamic Data block's Lava Template, after the closing tag of your wrapper element:

```html
<div class="my-dd-root">
    ...your markup with hx-get / hx-post...
</div>

<script>
    htmx.process(document.querySelector('.my-dd-root'));
</script>
```

No event listener. No `DOMContentLoaded`, no `Sys.Application.add_load`, no `MutationObserver`.

This works because the Dynamic Data template's own script block is the one place on the page whose timing is correct by construction: when it runs, its sibling markup is already in the DOM *and* HTMX is already loaded. Wrapping the call in any event listener is what breaks it.

Markup that HTMX later swaps *into* the block does not need this — HTMX processes its own swapped content automatically. The call is only needed for the block's initial render.


## Why the obvious placements do not work

All four of these produce the identical symptom — clicks do nothing, nothing in Network — for two different underlying reasons:

| Placement of `DOMContentLoaded` handler | Why it fails |
|---|---|
| Inside the Dynamic Data block's Lava Template | Script usually runs after `DOMContentLoaded` has fired, so the handler never runs. Mount timing varies between loads, so this fails *intermittently* rather than consistently |
| Page → Header Content | Handler fires on time, but the Dynamic Data markup does not exist yet — selector returns `null` |
| Lava Application Content block → Post-HTML | Same as above |
| A separate HTML Content block | Same as above |

The first row fails because it is too late. The other three fail because they are too early. Both look like nothing happened.


## Re-renders: the one-liner is self-healing

Two distinct re-render paths were tested 2026-08-12. **Both are safe.**

**HTMX swaps do not re-execute the template's scripts, and do not need to.** The run counter stayed at `#1` across repeated GET swaps that replaced text and POST swaps that replaced whole `<tr>` elements, including out-of-band swaps targeting a sibling element. HTMX processes its own swapped content.

**A PageParameterFilter-driven re-render does re-execute them.** With an Obsidian PageParameterFilter block on the same page, `Filter Selection Action = Apply Filters`:

| `Enable Legacy Reload` | What happens on filter change | Run counter | Result |
|---|---|---|---|
| `False` | Two XHRs — `GetUpdatedFilters` then `GetDynamicData`. Query string updated in place, no navigation. Block re-renders from the server. | advances to `#2`, same `pageLoadId` | Scripts re-execute, `htmx.process()` runs again, controls keep working |
| `True` | Full page navigation | resets to `#1`, new `pageLoadId` | Ordinary fresh load |

The Obsidian Dynamic Data block **does** subscribe to PageParameterFilter selections, and the soft path re-renders it server-side — the render stamp's server-generated timestamp advanced and the row count dropped from 3 to 1 without a page load.

#### Driving the soft path from your own block
The PageParameterFilter block is not required. Tested 2026-09-22 (reading `dynamicData.obs.js`, then publishing from the console): the Dynamic Data block subscribes to `PageMessages.QueryStringChanged` (`'page.core.queryStringChanged'`) on Obsidian's browser bus. On that message it calls `GetDynamicData`, passing the message's `URLSearchParams` as `pageParameterOverrides`, and `'Global' | PageParameter` in the query sees them. Any block's script can publish it:

```js
System.import('@Obsidian/Utility/browserBus').then(function (bus) {
    history.pushState(null, '', newUrl);
    bus.useBrowserBus().publish(bus.PageMessages.QueryStringChanged, new URLSearchParams({ KeyA: a, KeyB: b }));
});
```

- **Overrides merge onto the original page load's PageParameters; they do not replace them.** Leaving a key out of the message keeps its value from the URL the page was *loaded* with, not the current address bar. To clear a key, send it with an empty value.
- **`@Obsidian/Utility/browserBus` is Rock internals, not a documented API.** Put a `.catch()` on the import that falls back to `window.location.assign(newUrl)`, so an upgrade that moves the module costs a reload rather than a dead filter.
- **`pushState` alone re-renders nothing,** and neither does Back/Forward. Handle `popstate` (a `location.reload()` is the simple, honest option).

**Repeated `htmx.process()` calls do not double-bind handlers.** Verified by clicking a POST control after a soft re-render had already run `htmx.process()` a second time under the same page load: exactly one request fired, not two. HTMX guards against re-initializing an element that already carries its internal data, so a control surviving a re-render in place does not accumulate listeners. This is load-bearing for write endpoints — a double-bound button would write two rows per click.

So the single `htmx.process()` call at the end of the template covers every re-render path currently known. No lifecycle hook, no observer.

### If you ever find a path that is not self-healing

No trigger has been found that re-renders the block *without* re-executing its scripts. The signature would be a visibly changed render stamp with **no** new console line, plus dead controls that revive after a manual `htmx.process()` in the console.

If one turns up, re-query the container on each mutation rather than holding a reference — the container element itself may be replaced, which would leave an observer bound to a detached node:

```html
<script>
    (function () {
        if (typeof htmx === 'undefined') { return; }
        var pending = false;
        function processRoot() {
            pending = false;
            var el = document.querySelector('.my-dd-root');
            if (el) { htmx.process(el); }
        }
        processRoot();
        new MutationObserver(function () {
            if (pending) { return; }
            pending = true;
            requestAnimationFrame(processRoot);
        }).observe(document.body, { childList: true, subtree: true });
    })();
</script>
```

Calling `htmx.process()` repeatedly is safe — verified above, not merely inferred from HTMX internals. The `requestAnimationFrame` debounce keeps a body-wide subtree observer from firing once per mutation on a large table.


## Once processed, the block is a first-class HTMX citizen

After the `htmx.process()` call, a Dynamic Data block is not sandboxed in any way — Rock's block boundaries do not exist as far as HTMX is concerned. Verified 2026-08-13, one response updating three regions:

- An endpoint invoked from the Dynamic Data block OOB-swapped elements rendered by a **Lava Application Content** block and by an **HTML Content** block.
- The OOB payload included a `<button>`, which was processed on arrival and fired normally when clicked — despite landing in a block unrelated to the request.
- That injected button targeted an element back inside the Dynamic Data block.

So a Dynamic Data block can drive a KPI row, badge, or counter rendered by any other block on the page. Full detail in the `surface-helix` skill's `Lava-with-Helix.md` → "OOB resolution is page-wide, not block-scoped".


## `hx-params` is required here too

Rock wraps page content in an ASP.NET WebForms `<form>`, and **an Obsidian Dynamic Data block's markup sits inside it**. Any `hx-post` without an `hx-params` whitelist walks up to that form and serializes the whole thing.

Measured 2026-08-13 with two buttons in the same Dynamic Data block, identical except for the attribute:

| Button | `Form` payload | Contents |
|---|---|---|
| `hx-params="Id,Label"` | 38 characters | `Id` and `Label`, nothing else |
| no `hx-params` | 15,497 characters | the two real values, plus ViewState, `__EVENTVALIDATION`, and `ctl00$…` fields |

Roughly 400× per request, on every click. This matters most on exactly the pages where interactive Dynamic Data is attractive — staff on phones, on venue wifi, clicking through a long list.

The measurement above is the `Form | ToJSON` character count, a close proxy for the wire payload; `Content-Length` on the request is the exact figure. The ratio is what drives the conclusion either way.

This confirms that the finding in the `surface-helix` skill's `Lava-with-Helix.md` → "Form Serialization Behavior", originally tested on the Lava Application Content BlockType, generalizes to Obsidian Dynamic Data blocks. Note the three states of the attribute: an explicit whitelist is what you want; omitting it leaks ViewState; and `hx-params="none"` blocks the leak but **also blocks `hx-vals`** in Helix, so it is only safe on requests that send no values of their own.


## Diagnosing an HTMX control that does nothing

**HTMX does not swap on non-2xx responses.** A silent 404 and an unprocessed element look identical from the page — no error, no visual change. This differs from the `fetch()` failure documented in the `surface-helix` skill's `Lava-with-Helix.md` → "Calling Endpoints from JavaScript", where Rock's 404 page gets injected into the DOM and the breakage is loud. Devtools is the only way to tell these apart.

Check in this order:

1. **Network — does a request appear at all?**
    - No request → the element was never processed. This document's case.
    - Request URL contains `%5E` → processed, but the `^/` shorthand was not rewritten.
    - Correct URL, 401 with an empty body → endpoint Security Mode is `Endpoint Execute` with no `Auth` rows. Use `Application View` and check the role inside the Lava.
    - Correct URL, 404 → wrong app slug or endpoint slug, or wrong HTTP method.

2. **Is the runtime even present?** Console: `typeof htmx`. `'undefined'` means no Lava Application Content block is on the page.

3. **Confirm it is a processing problem, not a URL problem.** In the console:
    ```javascript
    htmx.process(document.querySelector('.my-dd-root'));
    ```
    Click again. If it now works, the element was unprocessed and the fix above applies.

4. **Isolate the block type.** Copy the identical control into a Lava Application Content block on the same page. Works there but not in the Dynamic Data block → confirmed processing scope. Dead in both → the endpoint or URL is wrong and the block type is exonerated.

5. **Check where you are in the lifecycle.** From inside the Dynamic Data template:
    ```javascript
    console.log('[dd] script ran · readyState=' + document.readyState);
    ```
    `complete` confirms the block mounted after page load.


## Scope of these findings

Verified on the **Obsidian** version of the Dynamic Data block. The legacy WebForms version renders server-side into the initial page HTML and would not be expected to have this problem — untested. If it turns out to re-render through an ASP.NET UpdatePanel async postback, the correct hook there is `Sys.Application.add_load`, which fires on initial load and after every partial postback; that hook is not relevant to Obsidian blocks.

The same reasoning applies to any Rock block type whose markup is injected client-side, not just Dynamic Data.


## Related

- the `surface-helix` skill's `Lava-with-Helix.md` → "Calling Endpoints from JavaScript" — `htmx.ajax()` vs `fetch()`, and why `fetch('^/...')` 404s.
- the `surface-helix` skill's `Lava-with-Helix.md` → "Form Serialization Behavior" — `hx-params` whitelisting. Required for any `hx-post` on a Rock page, Dynamic Data included, or the request carries ViewState and every `ctl00$...` field on the page.
