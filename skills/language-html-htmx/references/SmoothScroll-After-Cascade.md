# Smooth-scrolling to a target after an HTMX cascade

When an HTMX response installs loader divs that subsequently fire their own GETs (a *cascade*), naïve calls to `scrollIntoView({behavior:'smooth'})` fail in three distinct ways. The working pattern is a **debounced latch** keyed off `htmx:afterSettle`.

The root cause is that `scrollIntoView`'s smooth-scroll trajectory is computed exactly once, at call time, against:

1. the document's *current* layout (where the target sits relative to the viewport), AND
2. the document's *current* maximum scroll offset (`scrollHeight - innerHeight`).

Layout shifts after the call do not re-trigger the scroll. The animation completes at the position computed up front, no matter what the layout looks like by the time it lands.


## Failure 1 — Scroll on the commit response's `afterSettle`

Calling `scrollIntoView({block:'start'})` from the commit's `afterSettle` is too early. Section bodies have just been swapped to short loader/placeholder divs (often ~40-50px each), so the target section likely sits inside the viewport. The browser sees "already in view at the requested alignment" and makes the call a no-op. By the time the loaders' GET responses arrive ~200ms later and expand the layout by hundreds of px, the original scroll attempt is gone.

**Symptom:** `scrollIntoView` is invoked exactly once, but `window.scrollY` never changes. The target ends up far below the fold.


## Failure 2 — Scroll once on the first loaded-body `afterSettle`

Waiting until the target's body class transitions out of `rm-section-loader`/`rm-section-placeholder` is necessary but not sufficient. Many Lava-rendered sections include their *own* nested HTMX loaders — for example, the location picker's tbody has its own `hx-trigger="load"` that lazily fetches the available-locations tree. That nested GET fires *after* the section-body swap, *after* your `scrollIntoView` call, and grows the document by hundreds of pixels.

When `scrollIntoView` was called, the smooth-scroll target Y was clamped to `document.scrollHeight - window.innerHeight` of *that moment*. The animation reaches the clamped Y and stops. The document keeps growing afterward, but the scroll has already completed at the wrong position.

**Symptom:** The page scrolls part-way down, then stops. The target section's top edge ends up well below the configured `scroll-margin-top` offset.


## Failure 3 — Re-fire `scrollIntoView` on every `afterSettle` while latched

Keeping the target ID latched and re-calling `scrollIntoView` on each subsequent `afterSettle` works *functionally* — successive smooth-scroll calls cancel each other and re-target as the document grows, so the animation eventually converges on the correct Y.

But each new call cancels the previous one **mid-animation**, which the user perceives as a stutter or course-correction rather than a glide. In testing on the Create flow this reproduced as visible jank in two of three runs.

**Symptom:** The page scrolls to roughly the right place but the motion is stuttery, like the browser is fighting itself.


## Fix — debounced latch

Latch the target ID on the commit's `afterSettle`. Then on every subsequent `afterSettle`, reset a ~250ms debounce timer. When HTMX falls quiet for the debounce window, all nested loaders have settled and the layout is stable — fire `scrollIntoView` exactly once. A separate ~3s safety timer releases the latch unconditionally so a stuck load can't hold the user's manual scroll hostage.

```javascript
var pendingScrollTargetId = null;
var debounceTimer = null;
var safetyTimer = null;

function attemptScroll() {
    if (!pendingScrollTargetId) { return false; }
    var section = document.getElementById(pendingScrollTargetId);
    var body = section && section.querySelector('.rm-section-body');
    if (body
        && !body.classList.contains('rm-section-loader')
        && !body.classList.contains('rm-section-placeholder')) {
        section.scrollIntoView({ behavior: 'smooth', block: 'start' });
        return true;
    }
    return false;
}

function clearLatch() {
    pendingScrollTargetId = null;
    if (debounceTimer) { clearTimeout(debounceTimer); debounceTimer = null; }
    if (safetyTimer)   { clearTimeout(safetyTimer);   safetyTimer = null; }
}

document.body.addEventListener('htmx:afterSettle', function (e) {
    var xhr = e.detail.xhr;
    if (!xhr) { return; }

    //  Stage 1 — latch the target on the commit's afterSettle. The xhr-keyed
    //  flag prevents re-latching for the same response's settling phase.
    if (!xhr._scrollHandled) {
        xhr._scrollHandled = true;
        var scrollEl = document.getElementById('rm-scroll-target');
        var targetId = scrollEl && scrollEl.getAttribute('data-target-id');
        if (targetId) {
            pendingScrollTargetId = targetId;
            scrollEl.setAttribute('data-target-id', '');
            if (safetyTimer) { clearTimeout(safetyTimer); }
            safetyTimer = setTimeout(function () {
                attemptScroll();
                clearLatch();
            }, 3000);
        }
    }

    //  Stage 2 — every afterSettle while latched resets the debounce. When
    //  no afterSettle has fired for 250ms, htmx is quiet → scroll once.
    if (pendingScrollTargetId) {
        if (debounceTimer) { clearTimeout(debounceTimer); }
        debounceTimer = setTimeout(function () {
            debounceTimer = null;
            if (attemptScroll()) { clearLatch(); }
            //  else: body still loading; next afterSettle will re-arm
        }, 250);
    }
});
```

The 250ms debounce is long enough that nested loaders on a local network (typically <100ms) all complete inside the window, but short enough to still feel responsive. The 3s safety timer is the backstop.

The navbar offset is supplied by `scroll-margin-top` on the target element itself (in this codebase: `.rm-section { scroll-margin-top: 90px; }` — see `skills/language-html-htmx/references/Sticky-Positioning.md` Gotcha 2 for the navbar height). `scrollIntoView({block:'start'})` honors `scroll-margin-top`, so no manual Y arithmetic is required.


## Canonical example

`_code/Block-LavaApplicationContent/PageId_6076/BlockId_14800.lava` ships the working pattern. The Lava endpoint stamps the next-active section onto the OOB div via:

```lava
{% assign var_NextActiveSection = 0 %}
{% if var_Section2Loader %}
    {% assign var_NextActiveSection = 2 %}
{% elsif var_Section3Loader %}
    {% assign var_NextActiveSection = 3 %}
{% elsif var_Section4Loader %}
    {% assign var_NextActiveSection = 4 %}
{% endif %}

{% if var_Mode == 'create' and var_NextActiveSection > 0 %}
<div id="rm-scroll-target" hx-swap-oob="true" data-target-id="rm-section-{{ var_NextActiveSection }}"></div>
{% endif %}
```

The Block's initial layout includes an empty `<div id="rm-scroll-target" data-target-id=""></div>` next to the existing `<div id="rm-push-url" data-push-url="">` so the OOB swap has a target to replace. The Block's `htmx:afterSettle` listener is the debounced latch shown above (with `rm-` prefixed helper names — `rmAttemptScroll` / `rmClearScrollLatch` — to namespace).


## Diagnosing a smooth scroll that doesn't land

If a `scrollIntoView` call appears to do nothing, or scrolls only partway, instrument the page in the browser console:

1. **Confirm `scrollIntoView` was actually called.** Monkey-patch it on the target and log:
    ```javascript
    var section = document.getElementById('your-target-id');
    var orig = section.scrollIntoView.bind(section);
    section.scrollIntoView = function () {
        console.log('scrollIntoView', {
            scrollY: window.scrollY,
            rectTop: section.getBoundingClientRect().top,
            maxScrollY: document.documentElement.scrollHeight - window.innerHeight
        });
        return orig.apply(this, arguments);
    };
    ```
    If `maxScrollY` at call time is less than the Y the target *should* land at, your scroll is being clamped (Failure 2). Wait for nested loaders.

2. **Look for late `htmx:afterSettle` events.** A capture-phase listener catches them all:
    ```javascript
    document.body.addEventListener('htmx:afterSettle', function (e) {
        var url = (e.detail.xhr && e.detail.xhr.responseURL) || '';
        console.log('afterSettle', url, {
            scrollY: window.scrollY,
            docH: document.documentElement.scrollHeight
        });
    }, true);
    ```
    Trigger the action and watch for events firing *after* your scroll attempt — those are the layout shifts you need to debounce against.

3. **Check `scroll-margin-top` is on the target itself.** The property is consulted on the element passed to `scrollIntoView`. Setting it on `body` or a wrapper does nothing for the call.

4. **Verify nothing is competing with `window` for scrolling.** Walk the parent chain:
    ```javascript
    var el = document.getElementById('your-target-id').parentElement;
    while (el) {
        var cs = getComputedStyle(el);
        if (cs.overflowY === 'auto' || cs.overflowY === 'scroll') {
            console.log('scroll container:', el);
        }
        el = el.parentElement;
    }
    ```
    A nested scroll container absorbs the call, leaving `window.scrollY` unchanged.
