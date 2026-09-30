# Lava ShortCodes

> **Provenance tier:** `summarized` — condensed from the cited source, **not yet verified** in Rock (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



ShortCodes are Lava's reusable component system. They let a Lava specialist write a complex template once and expose it as a simple tag that anyone can invoke with named parameters — no knowledge of the underlying markup required.

```lava
{[ youtube id:'8kpHK4YIwY4' showinfo:'false' controls:'false' ]}
```

The `{[ ]}` syntax is the third of Lava's three fundamental patterns (alongside `{% %}` for logic and `{{ }}` for output). See `Lava-Language.md` > Syntax Basics.

Official documentation: https://community.rockrms.com/developer/bookcontent/33


---


## Types of ShortCodes

### Inline ShortCodes

Self-closing tags with no inner content. All behavior is controlled by parameters.

```lava
{[ youtube id:'8kpHK4YIwY4' showinfo:'false' controls:'false' ]}
```

### Block ShortCodes

Have an opening and closing tag. Content between the tags is passed to the ShortCode's template as the `{{ blockContent }}` variable.

```lava
{[ parallax image:'https://example.com/bg.jpg' speed:'0.2' height:'400px' ]}
    <h1>Hello World</h1>
{[ endparallax ]}
```

By default, Lava expressions inside `blockContent` are processed before the ShortCode receives them. To pass raw, unprocessed content, add `disablelavamerge:'true'` as a parameter.


---


## How ShortCodes Work

Each ShortCode is a Lava template stored in Rock's admin UI. When Rock encounters a `{[ tagname ]}` call, it:

1. Looks up the ShortCode registered under that tag name.
2. Passes each parameter as a merge field into the ShortCode's Lava template.
3. For Block ShortCodes, also passes the inner content as `{{ blockContent }}`.
4. Renders the ShortCode's template and inserts the result.

> **Tag names are case-sensitive.** The lookup in step 1 matches the **Tag Name** field as it was saved in Rock admin, character for character. `{[ ResourceAvailability ]}` and `{[ resourceavailability ]}` are distinct names — only the one that matches the saved Tag Name will resolve. The error reads `Lava Error: Unknown shortcode '<name>'` when the lookup fails. (Confirmed by direct test on 2026-04-24 — the same call worked PascalCase and errored lowercase against a Tag Name saved as `ResourceAvailability`.)
>
> Practical implication: stock Rock and Helix Form Control ShortCodes are conventionally registered with lowercase Tag Names (`accordion`, `chart`, `kpi`, `dropdown`, `textbox`, `youtube`, etc.) and must be invoked lowercase. Custom ShortCodes authored in this repo (`PAGFF`, `RSVPatt`, `LocationFromIdentifier`, `CreateAsanaTask`, `ResourceAvailability`) are registered PascalCase and must be invoked PascalCase. Always check the ShortCode's `README.md` (Tag Name field) or the boilerplate of `ShortCodeId_{id}.lava` for the registered casing.


### Parameters

Parameters are key-value pairs passed in the `{[ ]}` tag. Inside the ShortCode's template, each parameter is available as a merge field with the same name.

> **Parameter keys must be all lowercase.** Mixed-case or uppercase keys will not resolve correctly inside the ShortCode template.

ShortCode authors can define default values for parameters, ensuring the merge field always exists in the template even if the caller omits it.

Rock also auto-provides a `uniqueid` parameter (format: `id-{guid}`) on every ShortCode invocation. This is useful for generating unique CSS IDs and JavaScript variable names without manual GUID generation.


### Enabled Lava Commands

Each ShortCode can have Lava Commands (e.g., RockEntity, Sql) enabled in its own configuration. These commands run regardless of whether the calling Block also enables them. This means a ShortCode can use `{% sql %}` internally even if the Block it's called from doesn't have the Sql command enabled.

> **`{% sql %}` named parameters (`pFoo:'...'` → `@pFoo`) work inside a ShortCode's template the same as inside a Lava Application Endpoint.** A ShortCode parameter (e.g. `firstname`) can be bound to a `{% sql %}` parameter and referenced in the query as `@pFirstName`, with no special handling needed for the fact that the SQL is executing from inside a ShortCode rather than an endpoint. Verified when hardening a ShortCode against SQL injection — parameterizing was the fix.


### Item Configuration (`[[ item ]]`)

Block ShortCodes can accept structured child items using double-bracket syntax:

```lava
{[ googlemap height:'400px' scrollwheel:'false' ]}
    [[ marker location:'33.640705,-112.280198' title:'My Location' ]]
        <strong>Marker content here</strong>
    [[ endmarker ]]
{[ endgooglemap ]}
```

Rock parses these `[[ ]]` blocks, removes them from `blockContent`, and makes them available as variables inside the ShortCode's template:
- **Plural form** (`markers`) — an array of all items, each with its attributes and inner content.
- **Singular form** (`marker`) — the single item (useful when only one is expected).

This is the mechanism behind ShortCodes like `{[ dropdown ]}` accepting `[[ item ]]` children, or `{[ googlemap ]}` accepting `[[ marker ]]` children.


### Passing Objects (Rock v10+)

By default, parameter values are strings. To pass an actual Lava object (e.g., an entity or collection) into a ShortCode, omit the quotes around the value:

```lava
{% group where:'GroupTypeId == 25' %}
    {[ grouplistformat groups:groupItems ]}
{% endgroup %}
```

Here `groupItems` is passed as a live object, not a string. This enables ShortCodes that operate on entity collections without requiring SQL or entity commands internally.


---


## Where ShortCodes Live

### In Rock Admin

**Admin Tools > CMS Configuration > Lava Shortcodes**

Each ShortCode definition includes:
- **Name** and **Tag Name** — the tag name determines the `{[ tagname ]}` syntax used in Lava.
- **Type** — Inline or Block.
- **Parameters** — documented defaults and descriptions.
- **Lava Markup** — the template that renders when the ShortCode is invoked.
- **Enabled Lava Commands** — commands available inside the ShortCode's template.

### In This Repository

Custom ShortCodes that we author and maintain live in `_code/ShortCodes/`, organized by `ShortCodeId_{id}/`. Each contains the `.lava` implementation, a `.html` documentation file (for Rock's internal help), and a `README.md`. These use the exact same ShortCode mechanism described above — the only difference is authorship.


---


## ShortCodes Shipped with Rock

Rock ships with ShortCodes for common UI patterns. These are available on any Rock instance without additional configuration:

| ShortCode | Description |
|-----------|-------------|
| `{[ accordion ]}` | Collapsible accordion panels |
| `{[ aicompletion ]}` | AI text completion |
| `{[ chart ]}` | Chart rendering |
| `{[ easypiechart ]}` | Animated circular chart |
| `{[ followicon ]}` | Entity follow/unfollow toggle |
| `{[ googleheatmap ]}` | Google Maps heatmap overlay |
| `{[ googlemap ]}` | Google Maps embed with markers |
| `{[ googlestaticmap ]}` | Static Google Maps image |
| `{[ kpi ]}` | Key performance indicator display |
| `{[ mediaplayer ]}` | Audio/video media player |
| `{[ networkgraph ]}` | Network relationship visualization |
| `{[ panel ]}` | Bootstrap panel container |
| `{[ parallax ]}` | Parallax scrolling background |
| `{[ sankeydiagram ]}` | Sankey flow diagram (Rock v17+) |
| `{[ scheduledcontent ]}` | Time-based content visibility |
| `{[ scripturize ]}` | Bible reference link injection |
| `{[ sparklinechart ]}` | Inline sparkline chart |
| `{[ trendchart ]}` | Trend line chart |
| `{[ vimeo ]}` | Vimeo video embed |
| `{[ wordcloud ]}` | Word cloud visualization |
| `{[ youtube ]}` | YouTube video embed |


---


## Category Reference

Detailed parameter references, examples, and usage notes for documented ShortCodes live in `ShortCodes/`, organized by category. Each file covers a group of related ShortCodes.

| File | Categories | ShortCodes |
|------|------------|------------|
| Helix-Form-Controls (in the `surface-helix` skill) | System, Helix | rockcontrol, textbox, memo, currency, dropdown, checkboxlist, radiobuttonlist, campuspicker, definedvaluepicker, datepicker, daterangepicker, rangeslider |
