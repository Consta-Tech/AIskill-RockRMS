# Debounced HTMX triggers lose `event` inside `hx-vals`

HTMX's `hx-vals='js:{...}'` lets you compute the request payload from JavaScript at request time. Inside that JS expression, you usually have access to an `event` variable referring to the DOM event that triggered the request.

That access **breaks silently** when the trigger includes a `delay:` modifier (debounce). The request stops firing, but nothing on the page tells you why.


## What goes wrong

When you write a trigger like `hx-trigger="keyup changed delay:250ms"`, HTMX schedules the request via `setTimeout(..., 250)`. By the time that timer callback runs, the original keyup event has long since gone out of scope — so `event` inside the `hx-vals` JS expression is `undefined`.

Accessing `event.target.value` (or any other property of `event`) throws:

```
TypeError: Cannot read properties of undefined (reading 'target')
```

HTMX catches this exception inside its request-configuration pipeline and **swallows it**. The result:

- No HTTP request is sent.
- No `htmx:beforeRequest`, `htmx:afterRequest`, or `htmx:responseError` events fire.
- The element's `htmx-internal-data.queuedRequests` ends up with a stalled entry, `xhr.readyState: 0`, `delayed: true`.
- The only visible signal is a JS console exception that doesn't mention HTMX by name.

The same `hx-vals` pattern works fine on a non-debounced trigger like `change` or `click`, because the request fires synchronously from the event handler — `event` is still in scope.


## Fix

Inside any `hx-vals='js:{...}'` whose `hx-trigger` includes `delay:`, reference the input by ID/selector instead of via `event`:

```html
<!-- ❌ Breaks silently — event is undefined when the debounce fires -->
<input id="my-name-filter" type="text"
    hx-get="/some/endpoint"
    hx-trigger="keyup changed delay:250ms"
    hx-vals='js:{"Name": event.target.value}'>

<!-- ✅ Works — getElementById resolves at request time, no event needed -->
<input id="my-name-filter" type="text"
    hx-get="/some/endpoint"
    hx-trigger="keyup changed delay:250ms"
    hx-vals='js:{"Name": document.getElementById("my-name-filter").value}'>
```

For mixed-element forms where one input is debounced and another is not, prefer ID/selector references uniformly across **all** of them. That removes a class of foot-gun: if you later add `delay:` to the previously-instant trigger, nothing breaks.


## Canonical example

`_code/LavaApplications/RoomManagement/Endpoints/_render-section-reservationResource.lava` has two filters above the Resource picker — a Resource Name `<input>` (debounced) and a Category `<select>` (no debounce):

```html
{%- comment -%} Category — change fires synchronously, event is valid {%- endcomment -%}
<select id="rm-resourcepicker-category"
    hx-get="^/RoomManagement/_list-availableResources"
    hx-trigger="change"
    hx-vals='js:{"CategoryId": event.target.value, "Name": document.getElementById("rm-resourcepicker-name").value, "ReservationId": "{{ var_ReservationId }}"}'>
    ...
</select>

{%- comment -%} Name — debounced; both fields read by ID, never event {%- endcomment -%}
<input type="text" id="rm-resourcepicker-name"
    hx-get="^/RoomManagement/_list-availableResources"
    hx-trigger="keyup changed delay:250ms"
    hx-vals='js:{"CategoryId": document.getElementById("rm-resourcepicker-category").value, "Name": document.getElementById("rm-resourcepicker-name").value, "ReservationId": "{{ var_ReservationId }}"}'>
```

Note that the Category select still uses `event.target.value` for its own value — that's safe because `change` is non-debounced. The Name input never uses `event`.


## Diagnosing a debounced trigger that won't fire

If a debounced HTMX-driven input does nothing when typed, check the following in this order in the browser console:

1. **Is there a TypeError on `target`?** Look for `Cannot read properties of undefined (reading 'target')` (or `'value'`, `'currentTarget'`, etc.). That string is the smoking gun.

2. **Is HTMX actually wired to the element?** Inspect the element's internal data:
    ```javascript
    document.getElementById('my-input')['htmx-internal-data']
    ```
    If `listenerInfos` includes an entry for the trigger event (e.g. `keyup`), HTMX is wired correctly — the bug is in `hx-vals`, not in element registration.

3. **Did the request actually queue?** From the same internal-data object:
    ```javascript
    const d = document.getElementById('my-input')['htmx-internal-data'];
    ({
        lastValue: d.lastValue,           // HTMX saw the change
        delayed: d.delayed,               // debounce timer was scheduled
        queuedRequests: d.queuedRequests, // request is stalled here
        xhrReadyState: d.xhr && d.xhr.readyState
    })
    ```
    `queuedRequests: [{...}]` with `xhr.readyState: 0` and no recent `htmx:afterRequest` event is the canonical "stalled by hx-vals exception" footprint.

4. **Confirm the endpoint side works.** Bypass the input entirely and call the endpoint via HTMX's pipeline:
    ```javascript
    htmx.ajax('GET', '/api/v2/lava-app/{appId}/{App}/{endpoint}', {
        target: '#my-target',
        swap: 'innerHTML',
        values: { /* the same params your hx-vals would compute */ }
    });
    ```
    If this works but the typed-input path doesn't, the bug is in `hx-vals`. If both fail, the bug is server-side.

5. **Then fix the `hx-vals`.** Replace any `event.*` reference with the ID/selector equivalent.
