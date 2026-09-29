---
name: surface-helix
description: The Helix workbench for Rock RMS — Lava Applications, their Endpoints, and the Lava Application Content block. Covers what to configure in Rock admin (slugs, HTTP method, Enabled Lava Commands, Security Mode), the edit-save-trigger-inspect dev loop, how to read a failing round-trip in devtools (no request, %5E in the URL, 401, 404, or a 200 carrying "Lava Error"), what to hand back to Claude, and the tested Helix behaviors — form serialization and hx-params, OOB swaps, response headers, {% sql %} timeouts, renderlavaendpoint — plus Triumph's form-control ShortCodes and Chosen.js re-initialization. Use when building or debugging a Lava Application endpoint, a Lava Application Content block, or any HTMX round-trip inside Rock.
---

# Helix as a Workbench

**Helix** is Triumph Tech's HTMX integration for Rock RMS: a page-side runtime plus server-side **Lava Applications** whose **Endpoints** are Lava templates reachable over HTTP. The Lava language is the `language-lava` skill; front-end behaviors verified in Rock are `language-html-htmx`. This skill is the workbench — the pieces you configure in Rock, the loop you iterate in, and the measured Helix behaviors in `references/`.

## The pieces

| Piece | Configured in Rock as | What matters |
|---|---|---|
| **Lava Application** | a record with a **slug** | Namespaces its endpoints. The slug is part of every URL. |
| **Endpoint** | slug, **HTTP method** (GET/POST/PUT/DELETE), **Enabled Lava Commands**, **Security Mode**, the Lava template | *Endpoint Execute* mode requires explicit Auth rows on the endpoint, else the request is a 401 with an empty body; *Application View* inherits the application's View rights and lets you check roles inside the Lava. The template receives `QueryString` (GET) and `Form` (POST body) — inspect either with `\| ToJSON`. `PageParameter` is **null** inside an endpoint invoked over HTTP. |
| **Lava Application Content block** | bound to one Lava Application; its own **Enabled Lava Commands**; a Lava template | Renders the page-side markup **and loads the HTMX runtime page-wide** — any such block, even an empty one, makes `htmx` exist for every block on the page. |

Route: `/api/v2/lava-app/{SiteId}/{application-slug}/{endpoint-slug}`. Application code writes the shorthand `^/{application-slug}/{endpoint-slug}` and lets Helix substitute the Site Id at request time; never hardcode it. `Lava-with-Helix.md` → "Basics" has the verification method for your instance's Site Id.

## File conventions

Per the file-organization house rules: `_code/LavaApplications/{ApplicationName}/Endpoints/{verb}-{noun}.lava`, kebab-case, with a leading underscore for endpoints only other endpoints or blocks call (`_render-section-admin.lava`). The block file lives under `_code/Block-LavaApplicationContent/PageId_{id}/`. Both boilerplate headers are in the `language-lava` skill's `assets/boilerplates/` and are what `audit-pre-push-1` enforces. The endpoint header records the slug, method, enabled commands, and accepted `Form` / `QueryString` keys — the configuration that lives in Rock admin and is otherwise invisible in the repo.

## The dev loop

1. **Edit the file** in the repo to house style.
2. **Paste into Rock** — the endpoint's Lava editor (admin) or the block's template — and save. Confirm the endpoint's method and Enabled Lava Commands match the boilerplate.
3. **Trigger it from the page**, with devtools **Network** open.
4. **Read the round-trip**, in this order:

   | You see | It means |
   |---|---|
   | **No request** | The element was never processed by HTMX. Normal for markup injected after page load (an Obsidian Dynamic Data block — see the `surface-dynamicdata` skill); otherwise check `typeof htmx` in the console. |
   | Request URL contains `%5E` | Processed, but the `^/` shorthand was not rewritten — the Helix runtime is missing or loaded after the markup. |
   | **401**, empty body | Security Mode is *Endpoint Execute* with no Auth rows. |
   | **404** | Wrong application slug, wrong endpoint slug, or wrong HTTP method. A `fetch('^/…')` from your own JavaScript also 404s, because only HTMX rewrites the shorthand — use `htmx.ajax()`. |
   | **200** whose body is `Lava Error: …` | The template failed at render. HTMX swaps that text into the target as content and reports success. A `{% sql %}` timeout looks exactly like this. |
   | **200**, wrong markup | Read `Form \| ToJSON` / `QueryString \| ToJSON` at the top of the endpoint's output to see what actually arrived. |

5. **Iterate**, then commit the file — the repo, not Rock, is the source of truth.

## Handing a failure back to Claude

- The **page URL**, and the **request URL, status, and response body** from the Network panel (Copy → Copy response).
- Any **console error** verbatim — Helix swallows some `hx-vals` syntax errors into `helix-script.js`, so also say whether the request fired at all.
- **Observed versus expected**, including what the target element contained afterwards.
- If Claude has browser tools, give it the page URL and let it read the tab and the console itself.

## Conventions worth adopting in any Helix project

These recur across the applications this knowledge was verified in and are generic enough to carry:

- **`hx-params` whitelist on every `hx-post`.** The block's markup sits inside Rock's ASP.NET page form; without the whitelist the request serializes ViewState and every `ctl00$…` field (measured at roughly 400× the payload). `hx-params="none"` also blocks `hx-vals`, so name the keys.
- **`hx-vals='js:{…}'` must be an object literal.** Helix parses it more strictly than stock HTMX.
- **Size `{% sql timeout:'…' %}` from the measured worst case** on any endpoint whose query approaches 30 seconds. Nothing downstream can catch a timeout; the `timeout:` is the only safeguard (injected house rule).
- **Named `return:` on every `{% modifyentity %}`, `{% dbtransaction %}` around dependent writes,** and a `{% if var_HasEdit %}` UI gate wherever a mutation runs `securityenabled:'false'`.
- **Response headers are a black box.** `HX-Push-Url` and friends do not reach the browser. Emit an out-of-band `<div id="…-push-url" data-push-url="…">` and let the block's `htmx:afterSettle` listener call `history.pushState`; same shape for a full redirect. The block includes an empty placeholder so the OOB target exists at page load.
- **Toast attributes on the response root** (`data-toast-message`, `data-toast-type`), surfaced by one body-delegated `htmx:afterSettle` listener in the block — not per-endpoint script.
- **Self-loader for composition.** A returned `<div hx-get="^/app/next-step" hx-trigger="load" hx-swap="outerHTML">` chains to the next endpoint without `{% renderlavaendpoint %}`.
- **OOB swaps replace `outerHTML`**, so an OOB element must re-declare every attribute (classes included) the original had. OOB resolution is page-wide — one response can update elements rendered by other blocks.
- **No `<form>` in block or endpoint markup** — the browser drops a form nested in Rock's page form and its buttons post the page back. See the `surface-htmlcontent` skill's `No-Nested-Forms.md`.

## File index

| File | Covers |
|---|---|
| [Lava-with-Helix.md](references/Lava-with-Helix.md) | The tested Helix behaviors: route and Site Id, form serialization and the `hx-params` whitelist, `js:` object-literal rule, calling endpoints from JavaScript (`htmx.ajax()` versus `fetch()`), inline scripts in swapped content, toast notifications via `htmx:afterSettle`, OOB swaps (`outerHTML`, page-wide), response headers as a black box and the push-url workaround, `{% sql %}` timeout inside an endpoint, merge-field inheritance, `{% renderlavaendpoint %}` and QueryString. |
| [Helix-Form-Controls.md](references/Helix-Form-Controls.md) | Triumph's form-control ShortCodes (all wrapping `{[ rockcontrol ]}`) for Lava Application Content blocks — declarative Bootstrap form groups with label, validation, and required styling, and their HTMX limitations. |
| [Lava-Helix-ChosenJS.md](references/Lava-Helix-ChosenJS.md) | Chosen.js plus jQuery inside Helix pages — re-initializing after `htmx:afterSettle` with the `.chzn-done` exclusion class. |

## Related skills

- `language-lava` — the language, the `{% modifyentity %}` and DB Transaction commands, the `PageParameter` / `Page` filter caveats inside endpoints, the `{% sql %}` `timeout:` parameter, and the endpoint and block boilerplates.
- `language-html-htmx` — debounced `hx-trigger` losing the event, smooth-scroll after cascading swaps, sticky positioning under Bootstrap 3.
- `surface-dynamicdata` — HTMX inside an Obsidian Dynamic Data block, which needs `htmx.process()` and inherits everything above.
- `surface-htmlcontent` — the block that renders during the page request; where the runtime does and does not exist.
