# Inside a Dynamic Data block, every "current URL" source is the API endpoint

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



`SetUrlParameter` is fine. What is not fine is the thing you feed it. A Dynamic Data block renders its Lava inside an AJAX **BlockActions** call, so every filter that reports "the page the reader is on" reports the endpoint the block was fetched from instead.

Measured 11-SEP-2026 on an Obsidian Dynamic Data block:

| Lava | Returns |
|---|---|
| `'Global' \| Page:'Url'` | `https://{your-rock-host}/api/v2/BlockActions/{blockGuid}/{actionGuid}/GetDynamicData` |
| `'Current' \| SetUrlParameter:'CampusId','0'` | that same API URL, with `?CampusId=0` appended |
| `'Global' \| Page:'Path'` | `/api/v2/BlockActions/{blockGuid}/{actionGuid}/GetDynamicData` |
| `'Global' \| Page:'QueryString'` | empty string |

Nothing errors and nothing comes back empty, which is what makes this expensive to find: `SetUrlParameter` does its job correctly on the wrong URL, and the link renders as a perfectly ordinary anchor that navigates into the API and returns JSON.

## The workaround

A **relative query string** — `<a href="?Month=2026-08&CampusId=6">` — which the browser resolves against the document URL rather than against anything Lava knows. The trade is that you give up what `SetUrlParameter` was doing for you: choosing `?` versus `&`, and replacing an existing parameter instead of appending a duplicate. So write the whole query string at every link, and only in a block whose parameter set is small enough to enumerate. Note that constraint in a comment where you do it — adding a third parameter later means revisiting every link.

`{% capture %}` is the right tool for building those, and each one belongs on a single line — whitespace inside a capture survives into the value, and a newline in the middle of an `href` is a broken link. (This is the standing exception to the house rule that one-line strings are built with `| Append`: the capture switches on an `{% if %}` mid-string, which `Append` cannot express in one statement.)

```
{% capture url_PrevMonth %}?Month={{ var_PrevMonthKey }}{% if var_IsCampusView %}&CampusId={{ input_CampusId }}{% endif %}{% endcapture %}
{% capture url_AllCampuses %}?Month={{ var_ShownMonthKey }}{% endcapture %}
```

## Why only this block

It is the re-render path. The block fetches its content through `GetDynamicData`, and Lava's page-context filters answer for that request. A plain **HTML Content** block renders during the page request, where `Page:'Url'` is the page URL and `SetUrlParameter` builds correct absolute links — see the `surface-htmlcontent` skill. The `PageParameter` filter is unaffected in either block: the block action carries the page's parameters through (and merges any overrides — see `PageParameterFilter-Wiring.md`).
