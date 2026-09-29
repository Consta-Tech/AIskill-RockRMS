# A `<form>` inside a Rock block is dropped, and its buttons post the page back

Every Rock page is wrapped in a single ASP.NET WebForms `<form id="form1">`. HTML does not allow a `<form>` inside another `<form>`, and the browser's parser resolves the conflict by **discarding the inner form tag** — including one that arrives via `innerHTML` or an HTMX swap. The inner form's controls survive as ordinary children of `form1`.

Two consequences follow:

1. **Any `type="submit"` button (the default type for `<button>`) now submits `form1`** — a full-page ASP.NET postback. A Lava Application Content block comes back blank after it, because the postback re-renders the page without the block's client-side state.
2. **`method="dialog"` does nothing.** A native `<dialog>` whose Cancel button relied on `<form method="dialog">` to close it will instead post the page back. Measured 2026-09-21 on a reservation-editing page: clicking Cancel in a conflict dialog reloaded the page.

## The fix

- Never write `<form>` in block or endpoint markup — not for layout, not for `method="dialog"`.
- Give every button an explicit `type="button"` and do the work in JavaScript or through `hx-*` attributes. For a `<dialog>`, call `dlg.close(value)` from the button's handler.
- A native `<dialog>` opened with `showModal()` is otherwise fine inside a block.

## Why HTMX still works without a form

HTMX does not need a `<form>` element to send values. `hx-post` with an `hx-params` whitelist and `hx-vals` (or `hx-include`) assembles the payload from named elements directly — and the whitelist is what stops the request from serializing all of `form1`, ViewState included. See the `surface-helix` skill's `Lava-with-Helix.md` → "Form Serialization Behavior".
