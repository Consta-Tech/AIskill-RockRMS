# Basics
RockRMS is a church management system created by Spark Dev and developed between Spark Dev and Triumph Tech. It's been built on Microsoft's .NET framework, and its unique value proposition is that it enables churches to create their own church management system by providing a framework, tools, protocols, and essentially a "blank canvas" where you can define anything that your church might need.

In the context of talking about web development in the context of Rock RMS and Lava, you might hear the word, "Helix". This refers to Triumph's implementation of HTMX for the context of being used within Rock RMS.

Most of its initial documentation can be found at https://community.rockrms.com/developer/helix

The architecture relies on each Rock RMS instance defining a "Lava Application", which can have various "Lava Application Endpoints".

The full route to the endpoint is:
```
/api/v2/lava-app/{SiteId}/{application-slug}/{endpoint-slug}
```

The `{SiteId}` segment is the Rock **Site** Id of the site serving the request (NOT the Lava Application's Id). On the instance where this was verified, the internal site's Site Id is `1` (a common default), so every Lava Application Endpoint URL on that site begins with `/api/v2/lava-app/1/`. Verify the value for your own instance — the method below shows how. Verified May 2026 by:
- HTMX-rewriting `^/RoomManagement/...` from page 6076 (RoomManagement-bound block) → resolved URL had `/lava-app/1/`.
- HTMX-rewriting `^/audit-smallgroups/...` from page 6049 (Audit-SmallGroups-bound block) → resolved URL **also** had `/lava-app/1/`. Same `1` regardless of which Lava Application slug followed it.
- Direct probe: `/api/v2/lava-app/1/audit-smallgroups/list-groups` → 401 (route matched, auth missing). `/api/v2/lava-app/2/...` and `/api/v2/lava-app/99/...` → 404 (route did not match). The number is load-bearing but instance-constant.

If this codebase ever runs on a Rock instance with multiple Sites (e.g., External Site, Internal Site, Mobile Site each with their own `[Site].[Id]`), the `{SiteId}` segment will reflect the Site of the page the user is currently on. **The shorthand `^/...` already handles this** — Helix's HTMX integration substitutes the correct `{SiteId}` at request time, so application code should always use the shorthand and never hardcode `1` (or any other number) into endpoint URLs.

Triumph Tech's shorthand for the full route is:
```
^/{application-slug}/{endpoint-slug}
```

These endpoints can be defined as a GET, POST, PUT, or DELETE request.

Lava Application Endpoints receive two merge fields from incoming requests:
- `{{ QueryString }}` — contains URL query parameters (e.g., from `?key=value`)
- `{{ Form }}` — contains the POST/PUT request body (form-encoded data)

Both can be inspected with `| ToJSON` for debugging.


# Form Serialization Behavior (Tested March 2026)
This section documents how HTMX form serialization behaves inside Rock RMS pages when using the **Lava Application Content** BlockType. These findings are critical for building per-control interactive UIs (e.g., inline-editable table rows).

## The Problem: ASP.NET Page Form Leakage

Rock RMS pages are wrapped in an ASP.NET WebForms `<form>` element. When an HTMX attribute like `hx-post` fires from a control (e.g., a `<select>` or `<button>`), HTMX walks up the DOM looking for the nearest `<form>` ancestor. It finds the ASP.NET page form and serializes **everything** inside it, including:
- `__CVIEWSTATE` (a large encoded blob, often several KB)
- `__EVENTVALIDATION`
- `__EVENTTARGET`, `__EVENTARGUMENT`
- Every `ctl00$...` hidden field on the page (search bars, notification handlers, modal state, etc.)
- Every named form control on the page

This means a simple dropdown change sends kilobytes of irrelevant data to your Lava Application Endpoint. It also means that if multiple rows in a table share the same `name` attribute on their controls, the endpoint receives all of their values with no way to determine which row was actually interacted with.

## `<lava-form>` Does NOT Solve This
Wrapping controls in `<lava-form>` does **not** create a form serialization boundary. The same ViewState and `ctl00$...` fields are still included in the request. `<lava-form>` serves a different purpose (likely wiring up Helix's JavaScript initialization or event delegation), but it does not isolate HTMX serialization scope.

## `hx-params="none"` Is Too Aggressive
Setting `hx-params="none"` does successfully block all form serialization (no ViewState, no `ctl00$...` fields). However, in Helix's implementation, it **also blocks `hx-vals`**, which is non-standard HTMX behavior. The result is a completely empty `Form` object on the endpoint side.

## The Solution: `hx-params` Whitelist + `js:` Prefix `hx-vals`
The correct pattern is to combine an explicit `hx-params` whitelist with dynamically-evaluated `hx-vals`:

```html
<select name="GroupMemberStatus"
    class="form-control"
    hx-post="^/my-app/my-endpoint"
    hx-trigger="change"
    hx-target="closest tr"
    hx-swap="outerHTML"
    hx-params="GroupMemberId,GroupMemberStatus"
    hx-vals='js:{"GroupMemberId": "99999", "GroupMemberStatus": event.target.value}'>
    <option value="0">Inactive</option>
    <option value="1">Active</option>
    <option value="2">Pending</option>
</select>
```

**How this works:**
- `hx-params="GroupMemberId,GroupMemberStatus"` tells HTMX to include **only** these named keys in the request body, filtering out all ViewState and `ctl00$...` noise.
- `hx-vals='js:{...}'` uses the `js:` prefix (supported in Helix) to evaluate JavaScript expressions at request time. `event.target.value` dynamically captures the current value of the triggering element.
- The endpoint receives a clean `Form` object: `{"GroupMemberId": "99999", "GroupMemberStatus": "1"}`

**For buttons** (which have no inherent name/value), the same pattern works:

```html
<button class="btn btn-sm btn-default"
    hx-post="^/my-app/my-endpoint"
    hx-trigger="click"
    hx-target="closest tr"
    hx-swap="outerHTML"
    hx-params="GroupMemberId,Action"
    hx-vals='{"GroupMemberId": "88888", "Action": "ToggleArchive"}'>
    Archive
</button>
```

Note: buttons can use static `hx-vals` (no `js:` prefix) since they don't need to read a dynamic value from a form control.

**Confirmed beyond this BlockType (Tested August 2026).** The same leakage occurs from markup rendered by an **Obsidian Dynamic Data** block — its content also sits inside the ASP.NET page form. Two otherwise-identical buttons measured 38 characters of `Form` data with `hx-params="Id,Label"` against 15,497 characters without it. Treat the whitelist as mandatory for any `hx-post` on a Rock page, regardless of which BlockType emitted the markup. See the `surface-dynamicdata` skill's `DynamicData-With-Htmx.md`.

## `js:` Prefix Requires Object-Literal Form (Tested May 2026)
Helix's HTMX integration parses `hx-vals='js:...'` more strictly than stock HTMX. The contents are expected to be an **object literal** (the `{...}` you see in the canonical example above). Bare expressions — including direct function calls — fail with a swallowed `SyntaxError: Unexpected token '}'` inside `helix-script.js`.

Stock HTMX would happily evaluate `js:getFilterParams()` as a JS expression returning an object; Helix does not.

| Form | Works? |
|---|---|
| `hx-vals='js:{"State": getStateParam()}'` | ✅ Object literal with quoted keys |
| `hx-vals='js:{State: getStateParam(), Foo: helper(event)}'` | ✅ Object literal with bare keys |
| `hx-vals='js:{...getFilterParams()}'` | ✅ Spread of a helper that returns an object |
| `hx-vals='js:getFilterParams()'` | ❌ Bare function call — silently fails |

### Failure mode
The failure is **silent from the user's perspective** but visible in DevTools:
- Inline `onclick` handlers on the same element **do** run (URL pushers, DOM resets, etc.).
- The element's `htmx:trigger` event fires.
- **No** `htmx:configRequest`, **no** `htmx:beforeRequest`, **no** XHR, **no** swap.
- Console shows `SyntaxError: Unexpected token '}'` traced through `helix-script.js` → `HTMLAnchorElement.i` (the click handler).
- Visible symptom: the URL updates (via the surviving `onclick`) but the target region never refreshes — the page appears "stuck" on whatever it was showing before the click.

### Pattern: shaping params at request time
When request-time shaping is needed (date format flips, multi-select CSV joining, sentinel substitution, etc.) and the logic doesn't fit cleanly inside an object literal, write a helper that returns a plain object and **spread** it into `hx-vals`:

```html
<a class="btn btn-primary"
    hx-get="^/my-app/my-endpoint"
    hx-target="#results"
    hx-vals='js:{...getFilterParams()}'
    hx-swap="innerHTML">
    Search
</a>

<script>
function getFilterParams() {
    return {
        DateStart: toIsoDate(document.querySelector('[name="DateStart"]').value),
        DateEnd:   toIsoDate(document.querySelector('[name="DateEnd"]').value),
        State:     getStateParam()
    };
}
</script>
```

The `{...helper()}` form preserves the readability benefit of a named helper while staying inside Helix's required object-literal envelope. The `htmx.ajax(method, url, {values: helper()})` JavaScript API is unaffected by this restriction — only the `hx-vals='js:...'` attribute parser is strict.

## Summary of Tested Behaviors
| Technique | ViewState Blocked? | `hx-vals` Received? | Verdict |
|---|---|---|---|
| No `hx-params`, no `<lava-form>` | No | Yes (mixed in with noise) | Unusable for production |
| Wrapped in `<lava-form>` | No | Yes (mixed in with noise) | Does not help |
| `hx-params="none"` | Yes | **No** (also blocked) | Too aggressive |
| `hx-params="Key1,Key2"` whitelist | Yes | Yes (clean) | **Use this** |

## Additional Confirmed Behaviors
- `hx-trigger="change"` fires correctly on `<select>` elements.
- `hx-trigger="click"` fires correctly on `<button>` elements.
- `hx-target` with CSS selectors (e.g., `"closest tr"`, `"#someId"`) works as expected.
- `hx-swap="outerHTML"` and `hx-swap="innerHTML"` both work as expected.
- Query string parameters (e.g., `hx-post="^/app/endpoint?key=value"`) are received in `{{ QueryString }}` independently from `{{ Form }}`.


# Calling Endpoints from JavaScript (Tested May 2026)
**Always use `htmx.ajax()` — never vanilla `fetch()` — when calling a Lava Application Endpoint from JavaScript.**

The `^/{appSlug}/{endpointSlug}` shorthand only works because Helix's HTMX integration intercepts the URL at request time and rewrites it to `/api/v2/lava-app/{SiteId}/{appSlug}/{endpointSlug}`. That rewrite is wired into:
- HTMX attributes (`hx-get`, `hx-post`, `hx-put`, `hx-delete`)
- The `htmx.ajax(method, url, opts)` JavaScript API

It is NOT wired into:
- `window.fetch(url, ...)`
- `new XMLHttpRequest()` issued by hand
- `$.ajax(...)` (jQuery)
- Any other HTTP client that bypasses HTMX

## The failure mode is loud and visually destructive
A `fetch('^/RoomManagement/_list-accountsTypeahead?q=te', { credentials: 'same-origin' })` resolves to a relative URL where the browser URL-encodes `^` to `%5E`, prepends the current page's directory, and ends up calling something like `https://your.site/page/%5E/RoomManagement/_list-accountsTypeahead?q=te` → **HTTP 404**.

The 404 response body is Rock's full "Page Not Found" HTML (~30 KB) — `<title>`, `<link rel="stylesheet">`, `<script>`, `__VIEWSTATE` inputs, the works. If you then write `resultsEl.innerHTML = await r.text()`, that entire 404 page gets injected into your DOM, re-running stylesheets and scripts and duplicating ASP.NET hidden-input IDs. The page visibly breaks.

## Use `htmx.ajax()` with a target instead
```javascript
htmx.ajax('GET', sourceUrl + '?q=' + encodeURIComponent(value), {
    target: resultsEl,
    swap: 'innerHTML'
}).then(function () {
    // post-render hook (e.g., reveal the dropdown)
}).catch(function (err) {
    console.warn('typeahead request failed.', err);
});
```

`htmx.ajax()` returns a Promise that resolves after the swap settles. The HTMX response pipeline runs as it would for any HTMX-attribute trigger — including OOB swap extraction, `htmx:afterSettle` event firing, and the URL rewrite. Use the lifecycle event (or the Promise's `.then`) for any post-render work.

## When you genuinely need to read the response body (not swap it)
A few use cases — toast lookups, cascade-preview metadata extraction — need the raw response text rather than a DOM swap. The pattern is: swap into a hidden sink and `querySelector` from it.

```javascript
var sink = document.createElement('div');
sink.style.display = 'none';
document.body.appendChild(sink);

htmx.ajax('GET', previewUrl, { target: sink, swap: 'innerHTML' })
    .then(function () {
        var meta = sink.querySelector('#some-id');
        var lossCount = meta ? parseInt(meta.dataset.lossCount || '0', 10) : 0;
        sink.remove();
        // …use lossCount…
    })
    .catch(function (err) {
        sink.remove();
        // …degrade gracefully…
    });
```

## Symptom checklist
If a feature suddenly "breaks the page" the moment it tries to call an endpoint:
1. Devtools Network → look for a request whose URL contains `%5E` somewhere. That is `^` URL-encoded; the smoking gun.
2. Devtools Network → look for a 404 whose response body is Rock's full HTML 404 page.
3. Devtools Console → look for `[appname] … fetch failed` warnings if the catch was hit.
4. View source / `Element.innerHTML` of the swap target → if it contains `<title>` or `<link rel="stylesheet">`, that is Rock's 404 page injected.

The fix is always the same: swap `fetch(...)` for `htmx.ajax('GET', url, { target, swap })`.

## Related: markup HTMX never registered
The symptoms above assume HTMX is driving the request. A control whose element was never *processed* by HTMX fails differently — silently, with no request at all. That is the normal state of any markup injected into the page after HTMX initializes, including everything rendered by an Obsidian Dynamic Data block. See the `surface-dynamicdata` skill's `DynamicData-With-Htmx.md`.


# Programmatic `htmx.ajax()` with `values` (Tested March 2026)
The `htmx.ajax()` JavaScript API supports a `values` option that is the programmatic equivalent of `hx-vals`. When used with a POST request, the values are sent as form-encoded POST body data and are accessible via `{{ Form }}` in the Lava Application Endpoint.

```javascript
htmx.ajax('POST', '^/my-app/my-endpoint', {
    target: '#output',
    swap: 'innerHTML',
    values: { code: someVariable, name: 'example' }
});
```

On the endpoint side:
```
{% assign var_code = Form.code %}
{% assign var_name = Form.name %}
```

## `Form` vs `Body` vs `QueryString`
| Merge Field | What it receives |
|---|---|
| `{{ Form }}` | POST/PUT form-encoded body data (from `hx-vals`, `htmx.ajax values`, or HTML form controls) |
| `{{ Body }}` | `null` when data is sent as form-encoded (tested March 2026) |
| `{{ QueryString }}` | URL query parameters only (e.g., `?key=value`) |

When sending data programmatically via `htmx.ajax()`, **use `values`** (not query string parameters) to avoid URL length limits. The `Form` merge field receives the data regardless of whether it was sent via HTML attributes (`hx-vals`) or the JavaScript API (`values`).

## Inline `<script>` Tags in HTMX-Swapped Content
Inline `<script>` tags in HTML content swapped by HTMX may **not execute**, depending on the HTMX version and configuration. Do not rely on inline scripts in endpoint responses for rendering logic.

**Workaround:** Return data in a non-script format (e.g., a `data-*` attribute on a hidden element) and process it in the parent page's JavaScript via the `htmx:afterSwap` event:

```javascript
document.body.addEventListener('htmx:afterSwap', function (evt) {
    var dataEl = evt.detail.target.querySelector('#my-data');
    if (dataEl && dataEl.dataset.results) {
        var data = JSON.parse(decodeURIComponent(dataEl.dataset.results));
        // render table or process data
    }
});
```


# Example: Batch Submit with `<lava-form>`
The pattern above (per-control `hx-post`) is for **inline, per-row interactions** (e.g., changing a dropdown updates one record immediately). There is a separate use case: **batch submission**, where multiple controls are filled out and then submitted together with a single button click.

For batch submission, `<lava-form>` combined with a single `hx-post` on a submit button is the appropriate pattern. Be aware that the `Form` payload will include the ViewState noise alongside your actual form data — your endpoint will need to ignore the extra keys and read only the ones it cares about.

> The `{[ checkboxlist ]}` and other form-control ShortCodes used in the example below are documented in `Helix-Form-Controls.md` in this skill.

For the sake of example, if I configure a new Block and its BlockType is **Lava Application Content**, and if its Code Template is:
```html
<div>
    <lava-form id="thisForm">
        <div class="panel panel-default">
            <div class="panel-heading">
                HeadingHere
            </div>
            
            <div class="panel-body">
                <div class="table-responsive">
                    <table class="grid-table table table-bordered table-striped table-hover">
                        <thead>
                            <tr>
                                <th scope="col">Column1</th>
                                <th scope="col">Column2</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>
                                    {[ checkboxlist
                                        name:'SelectedRowId'
                                        showlabel:'false'
                                        isrequired:'false'
                                        value:''
                                        columns:'1' ]}
                                        [[ item value:'1' text:'' ]][[ enditem ]]
                                    {[ endcheckboxlist]}
                                </td>
                                <td>
                                    {[ checkboxlist
                                        name:'favorite-colors'
                                        label:'Favorite Colors'
                                        isrequired:'true'
                                        value:'2'
                                        columns:'4' ]}
                                        [[ item value:'1' text:'Red' ]][[ enditem ]]
                                        [[ item value:'2' text:'Green' ]][[ enditem ]]
                                        [[ item value:'3' text:'Blue' ]][[ enditem ]]
                                        [[ item value:'4' text:'Orange' ]][[ enditem ]]
                                        [[ item value:'5' text:'Yellow' ]][[ enditem ]]
                                    {[ endcheckboxlist ]}
                                </td>
                            </tr>
                        </tbody>
                        <tfoot>
                        </tfoot>
                    </table>
                </div>
                
                <div id="someIdentifierForThis" class="alert alert-primary"> </div>
                
                <a class="btn btn-primary" hx-post="^/timtest/testpost?example=999" hx-target="someIdentifierForThis">Save</a>
            </div>
        </div>
    </lava-form>
</div>
```

And if the `/timtest/testpost` Lava Application Endpoint has this Lava:
```
<div class="alert alert-info" role="alert">
    <strong>Some Output</strong> Lorem ipsum dolores sit amet.
    <br>
    <pre>{{ QueryString | ToJSON }}</pre>
    <br>
    <pre>{{ Form | ToJSON }}</pre>
</div>
```

Then when the Save button is clicked, `{{ Form | ToJSON }}` will contain all selected checkbox values **plus** the ViewState and `ctl00$...` noise. The endpoint should only read the keys it expects (e.g., `SelectedRowId`, `favorite-colors`) and ignore the rest.


# Response Headers Are a Blackbox (Tested March 2026, re-verified May 2026)
Lava Application Endpoints do **not** provide a mechanism to set custom HTTP response headers.

This means the standard HTMX pattern of using `HX-Trigger` (for client-side events) or `HX-Push-Url` (for browser URL rewrites) response headers from Lava Application Endpoints is **not available** — those headers never reach the response. May 2026 re-verification of `HX-Push-Url` confirmed this: response headers seen in devtools' Network tab are exclusively the ASP.NET defaults (Cache-Control, Content-Type, Set-Cookie, Vary, etc.); `xhr.getResponseHeader('HX-Push-Url')` returns `null`.

## Implications
- You cannot use `HX-Trigger` to emit custom events from the server.
- You cannot use `HX-Push-Url` to rewrite the browser URL.
- Any client-side notification or URL-update pattern must be driven by the response HTML content itself, not by response headers.
- For toast notifications, see the workaround below using `data-*` attributes and `htmx:afterSettle`. The same shape covers URL-push — pattern documented immediately below.

## Workaround for `HX-Push-Url`: OOB Attribute + `history.pushState`
The endpoint emits a stable OOB target whose `data-push-url` attribute carries the URL to push. The Block's Code Template registers an `htmx:afterSettle` listener that reads the attribute, calls `history.pushState`, and clears the attribute so it doesn't fire again on a later swap that has no URL to push.

**Endpoint side** (only on responses that should change the URL):
```
<div id="rm-push-url" hx-swap-oob="true" data-push-url="/page/6076?ReservationId=42"></div>
```

**Block side** — a placeholder for the OOB target, plus a one-time listener:
```html
<div id="rm-push-url" data-push-url=""></div>

<script>
(function () {
    if (window.__rmPushUrlInstalled) { return; }
    window.__rmPushUrlInstalled = true;

    document.body.addEventListener('htmx:afterSettle', function (e) {
        var xhr = e.detail.xhr;
        if (!xhr || xhr._rmPushUrlHandled) { return; }
        xhr._rmPushUrlHandled = true;

        var pushEl = document.getElementById('rm-push-url');
        var pushUrl = pushEl && pushEl.getAttribute('data-push-url');
        if (pushUrl) {
            history.pushState({}, '', pushUrl);
            pushEl.setAttribute('data-push-url', '');
        }
    });
})();
</script>
```

### Why the listener flags `xhr._rmPushUrlHandled`
`htmx:afterSettle` fires twice when the response contains an OOB element (once for the primary swap, once for the OOB swap), and both fires share the same `xhr`. The flag-on-xhr guard ensures `history.pushState` runs at most once per response. Same dedup pattern as the toast-notification listener below.

### Why the listener clears `data-push-url` after pushing
Subsequent endpoint responses may NOT carry an OOB push (e.g., a chevron-expand inside a tree view that should not pollute browser history). Without the clear, the listener would re-push the previous URL on every later afterSettle. Clearing the attribute makes the OOB div dormant until the next endpoint response re-populates it.

### Round-trip
After `history.pushState`, F5 reloads cleanly at the new URL — the page re-renders normally because the URL is a valid Rock route.


# Toast Notifications via `htmx:afterSettle` (Tested March 2026)
Since response headers are unavailable, the production pattern for toast notifications from Lava Application Endpoints uses three pieces: `data-*` attributes on the response HTML, the `htmx:afterSettle` lifecycle event, and regex on the raw response text.

## `htmx:afterSettle` Fires in Helix
The HTMX lifecycle event `htmx:afterSettle` fires correctly in Helix for both `hx-swap="innerHTML"` and `hx-swap="outerHTML"` swaps.

## The `outerHTML` Gotcha with `e.detail.elt`
The `e.detail.elt` property on the `htmx:afterSettle` event references the **target element** of the swap. With `innerHTML` swaps, this is the container that received the new content — querying it with `querySelector` finds elements inside the response. However, with `outerHTML` swaps, `e.detail.elt` references the **old element that was just replaced** and is no longer connected to the DOM. Running `querySelector` against it will not find anything from the new response content.

**Do not use `e.detail.elt` to read response content when using `outerHTML` swaps.**

## Why Not `DOMParser`?
An earlier approach used `DOMParser` to parse `e.detail.xhr.responseText` into a throwaway document and then `querySelector` for the `data-toast-*` attributes. This works when the root element of the response is a `<div>` or other flow-content element. However, **`DOMParser` fails silently when the root element is a `<tr>`** because `<tr>` is not valid as a direct child of `<body>` in the HTML spec. The parser strips the `<tr>` tags and discards its attributes, so `querySelector('[data-toast-message]')` returns `null`.

Since the primary use case for toast notifications is inline table row updates (where the response root element is a `<tr>`), `DOMParser` is **not reliable** for this purpose.

## The Solution: Regex on `e.detail.xhr.responseText`
Instead of parsing the response as HTML, use regex to extract `data-toast-*` attribute values directly from the raw response string. This is immune to HTML parsing context rules because it never parses — it just reads the string.

### Endpoint Pattern
Include `data-toast-message` and `data-toast-type` attributes on the root element of the response. The toast metadata is embedded in the same HTML that gets swapped into the page — no extra elements or requests needed.

```html
<!-- Lava Application Endpoint returns this -->
<tr data-toast-message="Status updated successfully." data-toast-type="success">
    ...rebuilt row content...
</tr>
```

For error cases (e.g., `{% modifyentity %}` fails):
```html
<tr data-toast-message="Update failed: some error message" data-toast-type="error">
    ...row content reflecting original state...
</tr>
```

### Double-Fire Behavior with OOB Swaps
When a response includes both a primary swap element and an `hx-swap-oob` element (see the OOB section below), `htmx:afterSettle` fires **twice** — once for the primary swap and once for the OOB swap. Both events carry the **same `e.detail.xhr` reference**, which means the same `responseText` and the same toast attributes would be matched twice, resulting in duplicate toasts.

The fix is a deduplication guard: set a flag on the `xhr` object after the first match. The second event sees the flag and exits early. Each new HTMX request creates a new `xhr` object, so the flag does not persist across interactions.

### Listener Pattern (Parent Block)
Add this once in the parent Lava Application Content block's Code Template. It listens globally and processes any HTMX response that contains toast data attributes. Includes the deduplication guard for OOB swap scenarios.

```html
<script>
    document.body.addEventListener('htmx:afterSettle', function(e) {
        var xhr = e.detail.xhr;
        if (xhr._toastHandled) return;

        var responseText = xhr.responseText;
        var messageMatch = responseText.match(/data-toast-message="([^"]*)"/);
        var typeMatch = responseText.match(/data-toast-type="([^"]*)"/);

        if (!messageMatch) return;

        xhr._toastHandled = true;

        var message = messageMatch[1];
        var type = typeMatch ? typeMatch[1] : 'info';

        // Replace the console.log below with your actual toast rendering logic.
        console.log('Toast [' + type + ']: ' + message);
    });
</script>
```

### Confirmed Behaviors
- `htmx:afterSettle` fires for both `innerHTML` and `outerHTML` swaps.
- `e.detail.xhr.responseText` contains the full response body in both swap modes.
- `e.detail.elt` is **unreliable** for `outerHTML` swaps (references the replaced/detached element).
- `DOMParser` is **unreliable** when the response root element is a `<tr>` (parser strips table-context elements and their attributes).
- Regex on raw `responseText` works reliably regardless of the response root element type.
- `htmx:afterSettle` fires **twice** when the response contains an `hx-swap-oob` element (once for primary swap, once for OOB swap).
- The `xhr._toastHandled` deduplication guard prevents duplicate toast rendering from the double-fire.
- Multiple `data-*` attributes can coexist on the same element (e.g., `data-toast-message`, `data-toast-type`).


# Out-of-Band (OOB) Swaps (Tested March 2026)
Standard HTMX supports **out-of-band swaps**: a response can include additional HTML elements marked with `hx-swap-oob="true"`, and HTMX will swap them into matching DOM targets independently of the primary swap. This allows a single endpoint response to update multiple parts of the page.

## OOB Swaps Work in Helix
Tested and confirmed. The primary swap and OOB swap are processed correctly from a single response.

## Response Format
The response contains the primary swap element followed by one or more OOB elements as siblings. Each OOB element must have an `id` matching an existing element in the DOM and the attribute `hx-swap-oob="true"`.

```html
<!-- Primary swap target: rebuilt row -->
<tr id="row-123" data-toast-message="Updated." data-toast-type="success">
    ...rebuilt row content...
</tr>

<!-- Out-of-band swap: updates a separate element in the DOM -->
<span id="section-count" hx-swap-oob="true"><strong>5 of 8</strong></span>
```

## How It Works
1. HTMX receives the full response.
2. It identifies elements with `hx-swap-oob="true"` and **extracts them** from the response before processing the primary swap.
3. The primary swap proceeds normally (e.g., `outerHTML` replaces the target `<tr>`).
4. Each OOB element is swapped into the DOM element with the matching `id`. By default, OOB swaps replace the **outerHTML** of the matching element — the returned element replaces the existing one entirely, so its own `class`, `style`, and `data-*` attributes take effect.

> **Corrected August 2026.** This step previously read `innerHTML`, which was wrong. Verified by returning an OOB element carrying a `style` the original element did not have, and confirming the style took effect. The practical consequence: one OOB element can update a value *and* restyle its container in a single swap — but it must also **re-declare every attribute the original had**, because nothing of the original survives. That is why the OOB spans throughout this codebase repeat their full `class` list (house rule: *the OOB span must replicate all CSS classes from the original element*).

## Confirmed Behaviors
- OOB elements are correctly extracted and do **not** appear inside the primary swap target.
- OOB elements are swapped into their matching DOM targets by `id`.
- The primary swap and OOB swap both complete in a single request/response cycle.
- `htmx:afterSettle` fires **twice** when OOB elements are present (once per swap). See the toast notification section above for the deduplication pattern.
- OOB elements and `data-toast-*` attributes can coexist in the same response without interfering with each other.
- The primary swap element and OOB elements are siblings at the top level of the response (no wrapping container needed).

## OOB resolution is page-wide, not block-scoped (Tested August 2026)
As far as HTMX is concerned the page is one DOM; Rock's block boundaries do not exist. Verified with a single response that updated three regions at once:

- An endpoint invoked from an **Obsidian Dynamic Data** block OOB-swapped elements rendered by a **Lava Application Content** block and by an **HTML Content** block. All three targets updated from one click.
- Markup delivered via OOB is **processed on arrival**, including when it lands in a block that had nothing to do with the request. A `<button>` injected by OOB into the Lava Application Content block fired normally when clicked.
- That injected button then targeted an element back inside the Dynamic Data block — cross-block targeting works in both directions.

The practical consequence: one block can drive the UI of any other block on the page. A Dynamic Data block's write endpoint can refresh a KPI row, a badge, or a counter rendered somewhere else entirely, without a page reload and without those elements knowing where the request came from.

Note that the Dynamic Data side requires `htmx.process()` on the block's own initial render before any of this works — see the `surface-dynamicdata` skill's `DynamicData-With-Htmx.md`.


# `{% sql %}` Timeout Inside an Endpoint (Tested August 2026)
A `{% sql %}` block inside a Lava Application Endpoint defaults to a **30-second** command timeout, and when it expires it fails in a way that every normal error path will miss.

**The default is overridable on the command itself** — `{% sql timeout:'60' %}`, in seconds. See the `language-lava` skill's `Lava-Language.md` → "Sql Command" → "Timeout". This is the primary safeguard; everything below is about what happens when you exceed whatever limit is in force.

## The measurement
A GET endpoint running `WAITFOR DELAY` for a requested duration:

| Requested | Elapsed | HTTP status | `htmx:afterRequest` `successful` | Response body |
|---|---|---|---|---|
| 5s | 5.1s | 200 | `true` | the expected result |
| 35s | 30.7s | 200 | `true` | `Lava Error: (Block: sql) Execution Timeout Expired.` |
| 90s | 30.1s | 200 | `true` | same |
| 150s | 30.2s | 200 | `true` | same |

The probe declared no `timeout:`, so all four runs cut off at the 30-second default regardless of how long the query asked for. There is no *endpoint-level* setting for this — the control lives on the `{% sql %}` command.

## The dangerous part: it is not an error to anything downstream
**The request returns HTTP `200` and HTMX reports `successful = true`.** The failure exists only as a string in the response body. Consequences:

- `htmx:responseError` **never fires**. Neither does `htmx:sendError`.
- HTMX **swaps the error text into the DOM** as though it were content. A table body, a `<tr>`, a badge — whatever the target was, it now contains `Lava Error: (Block: sql) Execution Timeout Expired.`
- An endpoint that returns JSON produces a body that is not JSON, so `JSON.parse` throws and the caller falls into its generic catch — reporting something vague like "unexpected response" rather than "the query timed out."
- Any monitoring that watches HTTP status codes will never see it.

In the observed case the response contained *only* the error string — the rest of the template did not render. That is the safer of the two possibilities (a write endpoint does not proceed on empty result data), but it has only been observed with the `{% sql %}` block near the top of the template; whether a block further down aborts the remaining render is untested.

## Handling it: prevention, not detection
**The standard is that every `{% sql %}` inside an endpoint declares an explicit `timeout:`**, sized from the query's measured worst case rather than left at the default. The safeguard belongs in the Lava, not in client-side JavaScript scattered across the blocks and pages that happen to call the endpoint.

```lava
{% sql return:'array_Roster' timeout:'60' pCamp:'{{ var_Camp }}' %}
    ...
{% endsql %}
```

### A downstream `{% if %}` cannot catch a timeout
Guarding the *result* after the fact does not work for this failure. **Rock discards the entire rendered output and substitutes the error string** — confirmed by placing literal markers both before and after the `{% sql %}` block and finding neither in the response. It is not that the template stops at the failing tag; nothing the template produced survives at all.

So no `{% if %}`, no `{% capture %}`, no fallback markup anywhere in that endpoint can influence what comes back. The only server-side lever is `timeout:` itself.

That is at least the safe direction of failure for a write endpoint: a `{% sql %}` lookup that times out cannot fall through to a `{% modifyentity %}` block with empty data, because the render is already dead.

Testing an empty result (`{% assign obj = array_Ctx | First %}{% if obj == null %}`) is still worth doing — it catches a query that returned no rows, which is a different and more common condition. It does not catch a timeout.

### Detection is deliberately not standardized
With `timeout:` declared from the query's measured worst case, a timeout represents a genuine outage rather than a routine condition — and interception machinery costs more than it returns. Decided 2026-08-13.

For anything that renders a JSON response, the failure already lands safely without new code: the body is not JSON, `JSON.parse` throws, and the caller's existing catch reports that nothing was changed, which is true.

If detection ever becomes unavoidable for a specific endpoint, the HTTP status is useless, so it has to be content-based — an `htmx:beforeSwap` listener checking `event.detail.xhr.responseText` for `Lava Error: (Block: sql)` and cancelling the swap. A last resort for one endpoint, not a house pattern.

### Open question: a server-side wrapper endpoint
Untested idea, parked 2026-08-13. A wrapper endpoint that calls the real one via `{% renderlavaendpoint %}` and inspects the captured output *might* survive the inner abort, since the failing `{% sql %}` lives in the inner template:

```lava
{% capture var_Inner %}{% renderlavaendpoint slug:'real-endpoint' %}{% endcapture %}
{% if var_Inner contains 'Lava Error' %}
    <div class="alert alert-warning">That query took too long.</div>
{% else %}
    {{ var_Inner }}
{% endif %}
```

If the inner abort does not propagate, this is a fully server-side guard with no JavaScript. Two costs even if it works: two endpoint renders per request, and the context-inheritance rules below ("Merge Fields Inside Lava Application Endpoints") mean the producer sees only what `route:` carries — `QueryString` is not inherited and `PageParameter` is null in both. To test: build `_probe-wrap` around `_probe-slow` and call it with `?Seconds=35`.

### Open question: an open `{% dbtransaction %}` when the timeout fires
Untested, raised 2026-08-18. `{% dbtransaction %}` renders its inner content into a buffer and only commits at `{% enddbtransaction %}`, so an endpoint that times out partway through a transaction should never reach the commit — the `using` block disposes and EF6 rolls back an uncommitted transaction. That is the expected outcome, but it has not been observed, and the failure mode if wrong is a partially committed write that the 200-response gives you no signal about.

Worth confirming before putting a `{% dbtransaction %}` inside an endpoint whose query is anywhere near its `timeout:`. See the `language-lava` skill ("DB Transaction Command") for the transaction mechanism, and note the related trap documented there: a `{% sql %}` write inside a transaction cannot set `TransactionResult.Success = false`, so it commits silently when it writes the wrong thing.

## Compared to the Dynamic Data block
The Dynamic Data block exposes a configurable `Timeout Length` (default `30`); an endpoint's `{% sql %}` exposes `timeout:`. **Equivalent controls, same default** — so moving a heavy query out of a Dynamic Data block into an endpoint costs no budget, as long as the `timeout:` is declared to match whatever the block was configured for.


# Merge Fields Inside Lava Application Endpoints (Tested May 2026)
Lava Application Endpoints inherit context differently depending on how they are invoked. Three invocation paths matter:

1. **HTTP request** — HTMX `hx-get` / `hx-post`, or direct browser navigation to the endpoint URL. The endpoint runs in its own request scope with no `RockPage`.
2. **`{% renderlavaendpoint %}` from a Block Code Template.** The endpoint shares the calling Block's full Lava engine context, including `RockPage`.
3. **`{% renderlavaendpoint %}` from another endpoint** (consumer delegating to producer). The producer inherits the consumer's context — typically empty when the consumer was reached via HTMX.

The matrix records what each merge field returns under each invocation path. Verified May 2026 via V5 / V6 / V7 testing.

| Merge field                                                  | HTTP-invoked      | Block-delegated via `{% renderlavaendpoint %}` | Endpoint-delegated via `{% renderlavaendpoint %}`   |
|--------------------------------------------------------------|-------------------|------------------------------------------------|-----------------------------------------------------|
| `{{ QueryString.X }}`                                        | request URL's QS  | Block's QS (= page URL)                        | `route:` URL's QS                                   |
| `{{ PageParameter.X }}` (filter or dot-notation)             | ❌ null           | ✅ Block's value                               | inherits parent — null in HTMX-driven chains        |
| `{{ 'Global' \| Page:'X' }}` (Url, Path, Id, QueryString, …) | ❌ null           | ✅ Block's value                               | inherits parent — null in HTMX-driven chains        |

`{{ Form.X }}` and `{{ Body }}` are populated from the HTTP request body in HTTP-invoked endpoints and aren't typically relevant in the delegated paths (Block calls aren't form-shaped; `route:` is GET-shaped).

## Why this matters for `{% renderlavaendpoint %}` design
- A Block that calls `{% renderlavaendpoint %}` to compose its initial render can rely on `PageParameter` and the `Page` filter family inside the called endpoint — they inherit Block context (V7-confirmed).
- A consumer endpoint that calls `{% renderlavaendpoint %}` to delegate part of its HTMX response cannot rely on those filters in the producer — the producer's `QueryString` is only what `route:` carries, and `PageParameter` / `Page` are null in both consumer and producer (V5 / V6-confirmed).
- Practical implication: in HTMX mutation flows, page-URL params must be threaded explicitly. The Block emits them via `hx-vals` (→ consumer's `Form`); the consumer rebuilds them into `route:` (→ producer's `QueryString`).

## See also
- "`{% renderlavaendpoint %}` and QueryString" — named-parameter behavior under Block-context delegation.
- "`{% renderlavaendpoint %}` from Inside Endpoints" — server-side composition mechanics, OOB pass-through, recursive chains.


# `{% renderlavaendpoint %}` and QueryString (Tested March 2026)
The `{% renderlavaendpoint %}` tag accepts named parameters, but those parameters are **not** accessible via `QueryString` inside the endpoint. `QueryString` in the endpoint reflects the page's actual URL query string, not the tag's parameters.

## The Problem
If you use `{% renderlavaendpoint %}` to render an endpoint inline during page load and pass parameters via the tag:
```
{% renderlavaendpoint slug:'filter-parentgroups' CampusId:'5' SelectedValue:'42' %}
```

Inside the `filter-parentgroups` endpoint, `QueryString.CampusId` and `QueryString.SelectedValue` will be **null** — not `'5'` and `'42'`. The tag's named parameters silently resolve to nothing.

## Why This Happens
`{% renderlavaendpoint %}` renders the endpoint server-side during Lava processing. It does not make an HTTP request, so there is no real URL with query parameters. The endpoint inherits the calling context's full Lava engine scope (request URL, `RockPage`, etc.) — for a Block call from a page render, that means `QueryString` reflects the page URL and `PageParameter` / `Page` filters work as they would in the Block. See "Merge Fields Inside Lava Application Endpoints" above for the full inheritance rule.

## Workaround
If you need to render an endpoint inline AND the endpoint relies on `QueryString` parameters, render the content inline with your own SQL/Lava instead of delegating to `{% renderlavaendpoint %}`. Reserve the endpoint for HTMX requests (where parameters arrive as real HTTP query params via `hx-get`).

This is the pattern used in the Audit SmallGroups application: the Filters block renders the Parent Group dropdown inline on initial page load (with its own SQL query), while the `filter-parentgroups` endpoint handles HTMX cascade refreshes.


# `{% renderlavaendpoint %}` from Inside Endpoints (Tested May 2026)
A Lava Application Endpoint can call `{% renderlavaendpoint %}` to delegate part of its response to another endpoint. The delegation composes server-side — no extra HTTP request — and the producer's primary fragment plus any top-level OOB siblings flow through to the parent response intact.

## Confirmed Behaviors
- **Cross-method delegation works.** A POST endpoint can call `{% renderlavaendpoint %}` to GET a producer endpoint. The producer's body renders inline at the position of the tag in the consumer's response.
- **Single HTTP request.** `{% renderlavaendpoint %}` is server-side composition, not a sub-request. Devtools shows only the consumer's HTTP call — the delegation is in-process.
- **Top-level OOB siblings pass through.** If the producer emits a `<div id="…" hx-swap-oob="true">…</div>` at the top level of its body, that element flows through the consumer's response and lands on its page-DOM target unchanged. A single canonical "render summary" or "render outline" endpoint can therefore be reused across multiple mutation endpoints that all need to refresh those regions.
- **Recursive delegation works (verified to two levels).** Producer A can itself call `{% renderlavaendpoint %}` against producer B, and B's output appears nested inside A's. `route:` parameters propagate one hop at a time — A sees what its caller's `route:` carried; B sees what A's `route:` carried.

## Operational Setup
The **calling** endpoint (the one whose body contains `{% renderlavaendpoint %}`) should need the **"Render Lava Endpoint"** Lava command enabled in its endpoint settings, however, Rock (as of v18) does not have a separate select-checkbox for toggling enable/disable of this Lava Command. Upon testing, it looks like this particular Lava Command is enabled by default in every possible context. The producer endpoint does NOT need this command — it just renders normally.

`route:` accepts Lava variable interpolation in its value:
```
{% assign var_Route = '^/RoomManagement/_render-summary-sidebar?ReservationId=42' %}
{% renderlavaendpoint route:'{{ var_Route }}' method:'get' %}
```
For routes that vary per request (e.g., the ID changes), build the URL with `{% capture %}` first and pass the captured variable into `route:`. Only `route:` and `method:` are honored on the tag — named parameters silently resolve to nothing (see "`{% renderlavaendpoint %}` and QueryString" above).

## Use Case: Shared OOB Region Rendering
Three mutation endpoints (e.g., `commit-section-A`, `commit-section-B`, `transition-state`) all need to refresh the same summary sidebar and progress outline on every response. Without delegation, each endpoint duplicates the sidebar/outline SQL + render block, and the three copies drift over time.

With from-endpoint delegation, each mutation endpoint primary-renders its own transition fragment, then delegates twice for the OOB siblings:
```
{% capture var_SummaryRoute %}^/RoomManagement/_render-summary-sidebar?ReservationId={{ var_ReservationId }}{% endcapture %}
{% capture var_OutlineRoute %}^/RoomManagement/_render-progress-outline?ReservationId={{ var_ReservationId }}{% endcapture %}

<div id="rm-section-N-body" data-toast-message="…" data-toast-type="success">…</div>

{% renderlavaendpoint route:'{{ var_SummaryRoute }}' method:'get' %}
{% renderlavaendpoint route:'{{ var_OutlineRoute }}' method:'get' %}
```
Each delegated producer emits its OOB region at top level, and that element propagates to the page DOM as if the mutation endpoint had inlined it. The drift risk collapses from "three copies to keep in sync" to "one canonical renderer per OOB region."

## Caveat on QueryString Scope (endpoint-to-endpoint only)
When a *consumer endpoint* calls `{% renderlavaendpoint %}` to a producer endpoint, the producer's `{{ QueryString }}` merge field reflects only the URL the consumer carried in `route:` — page-URL params do NOT inherit. A producer that needs `ReservationId` (or any other page-level param) must receive it explicitly through `route:`. This is the typical case in HTMX mutation flows: the consumer endpoint was hit via HTMX (no page-URL inheritance), so it has nothing to forward except what its caller told it via `Form` or `Form`-derived `route:` building.

When a *Block* calls `{% renderlavaendpoint %}` (e.g., during initial page render), the producer endpoint inherits the Block's full context — `QueryString` reflects the page URL, and `PageParameter` / `Page` filter family also work. See the Merge Fields matrix above for the full inheritance rule.

## Context Inheritance and the `{% raw %}` + `| RunLava` Pattern
Because `{% renderlavaendpoint %}` inherits the caller's `RockPage` context (see Merge Fields matrix above), a Block-called producer endpoint can reference `PageParameter.X` and `'Global' | Page:'X'` directly — they resolve to the Block's values without any `route:`-threading.

A workaround was tested where the endpoint wraps page-context references in `{% raw %}…{% endraw %}` and the Block re-evaluates the captured output with `| RunLava`. The pattern works mechanically (V7.2-confirmed), but it is **redundant** for Block-initial-render delegation — the endpoint inherits context anyway (V7.4-confirmed), so the simpler form `{{ PageParameter.X }}` produces the same result. It does not apply to HTMX mutation flows either, because there is no Block-side re-evaluation point in the HTMX swap pipeline. Document for completeness; reach for it only when deferred evaluation is genuinely needed.

**Security note:** `| RunLava` evaluates whatever string it receives. If user-controlled content reaches the captured string, it becomes a Lava-injection vector — the executed Lava inherits the parent's enabled commands (`Sql`, `Cache`, `RockEntity`, etc.). `route:`-threading is the safer alternative because params are explicitly named and scoped.