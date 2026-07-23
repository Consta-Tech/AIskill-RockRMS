# Chosen.js in Rock RMS + Helix (HTMX)

## Availability
Chosen.js and jQuery are loaded globally in Rock RMS pages. No additional script imports needed.

## Initialization Pattern (Tested March 2026)
Chosen must be initialized after HTMX swaps content into the DOM. Use an `htmx:afterSettle` listener on `document.body`. Target uninitialized selects using the `.chzn-done` exclusion class (Chosen adds this after initialization):
```javascript
document.body.addEventListener('htmx:afterSettle', function(e) {
    if (typeof $ !== 'undefined' && $.fn.chosen) {
        $('.js-conndefault-chosen:not(.chzn-done)').chosen({
            width: '100%',
            search_contains: true,
            no_results_text: 'No match found',
            disable_search_threshold: 10
        });
    }
});
```

## jQuery→Native Event Bridge (Required for HTMX)
Chosen fires jQuery `change` events on the hidden `<select>`, not native DOM events. HTMX's `hx-trigger="change"` listens for native events and will never see Chosen's jQuery events. A bridge is required:
```javascript
if (typeof $ !== 'undefined') {
    $(document).on('change', '.js-conndefault-chosen', function(e) {
        if (!e.originalEvent) {
            this.dispatchEvent(new Event('change', { bubbles: true }));
        }
    });
}
```

The `!e.originalEvent` guard prevents infinite loops: native events wrapped by jQuery have `originalEvent` set, while Chosen's programmatic triggers do not.

## CSS Considerations
- `overflow: hidden` on any ancestor element will clip the Chosen dropdown menu.
- The `{[ dropdown ]}` Lava Shortcode (see `ShortCodes/Helix-Form-Controls.md`) cannot be used with HTMX because `hx-vals` requires single quotes that collide with the shortcode's `additionalattributes` parameter delimiter.
- Use raw `<select>` elements with the class `chosen-select` or a custom class (e.g., `js-conndefault-chosen`).

## Lava `| Where` Filter and Null Values
When building `<option>` lists using `| Where` to match a current value, the filter throws if the comparison value is null. Always null-guard:
```lava
{% if row.SomeId != null and row.SomeId != '' %}
    {% assign var_Filtered = array_Options | Where:'OptionId', row.SomeId | Size %}
{% endif %}
```