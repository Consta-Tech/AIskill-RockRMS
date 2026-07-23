# Helix Form Controls

These ShortCodes are form-control components developed by Triumph Tech as part of Helix (see `../Lava-with-Helix.md`). They provide a declarative way to render standard HTML form controls inside **Lava Application Content** blocks without writing raw HTML.

**Categories:** System, Helix

All of these wrap themselves in `{[ rockcontrol ]}`, which renders a standard Bootstrap `form-group` container with label, validation, and `required` styling.

For general ShortCode concepts (types, parameters, authoring rules), see `../Lava-ShortCodes.md`.


---


## Quick Reference

| ShortCode | Type | Accepts Items | Description |
|-----------|------|:---:|-------------|
| `{[ rockcontrol ]}` | Container | No | Base wrapper — renders `form-group` with label and validation |
| `{[ textbox ]}` | Input | No | Single-line text input (supports HTML5 types) |
| `{[ memo ]}` | Input | No | Multi-line textarea |
| `{[ currency ]}` | Input | No | Numeric input with currency symbol addon |
| `{[ dropdown ]}` | Selection | Yes | `<select>` dropdown, optional Chosen.js search |
| `{[ checkboxlist ]}` | Selection | Yes | Checkbox group with column layout |
| `{[ radiobuttonlist ]}` | Selection | Yes | Radio button group with column layout |
| `{[ campuspicker ]}` | Entity Picker | No | Campus selector with type/status/active filtering |
| `{[ definedvaluepicker ]}` | Entity Picker | No | Defined Value selector from a given Defined Type |
| `{[ datepicker ]}` | Date | No | Single date input with calendar popup |
| `{[ daterangepicker ]}` | Date | No | Start / End date pair with calendar popups |
| `{[ rangeslider ]}` | Input | No | Slider control with min/max/step |


---


## Rock Control

Base wrapper that all other form-control ShortCodes use internally. Renders a Bootstrap `form-group` container with an optional label and validation message. Use this directly when you need the standard Rock form-group chrome around custom HTML.

### Example
```lava
{[ rockcontrol label:'My Control' type:'data-text-box' isrequired:'true' validationmessage:'Please enter a value.' ]}
    <input type="text" class="form-control" />
{[ endrockcontrol ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `id` | `rc-{guid}` | Identifier for the control. Auto-generated if omitted. |
| `label` | `Campus` | Label text displayed above the control. |
| `showlabel` | `true` | Whether to display the label. |
| `controltype` | | CSS class appended to the root `form-group` div. |
| `isrequired` | `false` | Adds `required` class and shows validation message when invalid. |
| `validationmessage` | | Message shown when validation fails. |

<details>
<summary>Generated HTML Structure</summary>

```html
<div class="form-group {controltype} required">
    <label class="control-label" for="{id}">{label}</label>
    <div class="control-wrapper">
        {blockContent}
    </div>
    <span id="rfv-{id}" class="validation-error help-inline" style="display:none;">{validationmessage}</span>
</div>
```
</details>


---


## Text Box

Single-line text input. Supports all HTML5 input types (`date`, `email`, `number`, `tel`, `url`, etc.) via the `type` parameter.

### Example
```lava
{[ textbox name:'lastname' label:'Last Name' value:'Decker' ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | `Text Area` | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `name` | `text` | The `name` attribute on the input. |
| `type` | `text` | HTML input type (`date`, `email`, `number`, `password`, `tel`, `url`, etc.). |
| `value` | | Initial value. |
| `size` | | Vertical size class: `xs`, `sm`, `md`, `lg`, `xl`, `xxl`. |
| `width` | | Width class: `xs`, `sm`, `md`, `lg`. |
| `preaddon` | | Add-on rendered before the input (text or `<i class="fa fa-icon"></i>`). |
| `postaddon` | | Add-on rendered after the input. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please enter a value.` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to the `<input>`. |


---


## Memo

Multi-line textarea control.

### Example
```lava
{[ memo label:'Notes' maxlength:'200' name:'notes' rows:'3' value:'Hello Ted!' isrequired:'true' ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | `memo` | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `name` | `memo` | The `name` attribute on the textarea. |
| `rows` | `3` | Number of visible text rows. |
| `maxlength` | | Maximum character count. |
| `value` | | Initial text content. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please insert text` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to the `<textarea>`. |


---


## Currency

Numeric input prepended with the configured currency symbol from `Global` attributes.

### Example
```lava
{[ currency label:'Amount' value:'100.00' isrequired:'true' ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | `Currency` | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `value` | | Initial numeric value. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please specify an amount.` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to the `<input>`. |

<details>
<summary>Generated HTML Structure</summary>

```html
<div class="input-group">
    <span class="input-group-addon">{CurrencySymbol}</span>
    <input type="number" class="form-control" inputmode="decimal" step="0.01" value="{value}" />
</div>
```
</details>


---


## Dropdown

`<select>` dropdown. Enable `longlistenabled` to add Chosen.js search functionality.

### Example
```lava
{[ dropdown label:'Favorite Number' name:'favorite-number' longlistenabled:'true' isrequired:'true' value:'2' ]}
    [[ item value:'1' text:'One' ]][[ enditem ]]
    [[ item value:'2' text:'Two' ]][[ enditem ]]
    [[ item value:'3' text:'Three' ]][[ enditem ]]
{[ enddropdown ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `name` | `dropdown` | The `name` attribute on the `<select>`. |
| `value` | | ID or Guid of the pre-selected option. |
| `longlistenabled` | `false` | Enables Chosen.js search on the dropdown. |
| `controltype` | `rock-drop-down-list` | CSS class appended to the form-group. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please select an item.` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to the `<select>`. |

> **HTMX Limitation:** The `{[ dropdown ]}` ShortCode cannot be used with `hx-vals` because `hx-vals` requires single quotes around its JSON value, which collide with the ShortCode's `additionalattributes` parameter delimiter. Use a raw `<select>` element instead when HTMX attributes are needed. See `../Lava-Helix-ChosenJS.md` for the recommended pattern.


---


## Checkbox List

Renders a group of checkboxes in a configurable column layout. Supports multiple pre-selected values.

### Example
```lava
{[ checkboxlist label:'Favorite Colors' name:'favorite-colors' isrequired:'true' value:'2' columns:'4' ]}
    [[ item value:'1' text:'Red' ]][[ enditem ]]
    [[ item value:'2' text:'Green' ]][[ enditem ]]
    [[ item value:'3' text:'Blue' ]][[ enditem ]]
    [[ item value:'4' text:'Orange' ]][[ enditem ]]
    [[ item value:'5' text:'Yellow' ]][[ enditem ]]
{[ endcheckboxlist ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `name` | `checkbox` | The `name` attribute on each checkbox input. |
| `value` | | Comma-separated list of pre-selected values. |
| `controltype` | `rock-check-box-list` | CSS class appended to the form-group. |
| `columns` | | Number of columns for the checkbox layout. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please select a value.` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to each checkbox input. |

<details>
<summary>Generated HTML Structure</summary>

Each checkbox is rendered as:
```html
<div class="controls js-rockcheckboxlist rock-check-box-list rockcheckboxlist rockcheckboxlist-horizontal in-columns in-columns-{columns} cbl-{name}">
    <label class="checkbox-inline" for="{itemId}">
        <input id="{itemId}" type="checkbox" name="{name}" value="{item.value}" checked>
        <span class="label-text">{item.text}</span>
    </label>
    ...
</div>
```

CSS classes for targeting: `.cbl-{name}`, `.rock-check-box-list`, `.in-columns-{n}`.
</details>


---


## Radio Button List

Renders a group of radio buttons in a configurable column layout. Only one value can be selected.

### Example
```lava
{[ radiobuttonlist label:'Favorite Color' name:'favorite-color' isrequired:'true' value:'2' columns:'4' ]}
    [[ item value:'1' text:'Red' ]][[ enditem ]]
    [[ item value:'2' text:'Green' ]][[ enditem ]]
    [[ item value:'3' text:'Blue' ]][[ enditem ]]
{[ endradiobuttonlist ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `name` | `radiobuttonlist` | The `name` attribute on each radio input. |
| `value` | | The pre-selected value. |
| `type` | `rock-check-box-list` | CSS class appended to the form-group. |
| `columns` | | Number of columns for the radio button layout. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please select at least one item.` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to each radio input. |


---


## Campus Picker

Entity picker for Campus records. Renders as a dropdown (single-select) or checkbox list (multi-select). Supports filtering by campus type, status, and a specific allowlist.

### Example
```lava
{[ campuspicker label:'Primary Campus' value:'1,2' allowmultiple:'true' campustypes:'768' campusstatuses:'765' selectablecampuses:'1,2,5' ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `name` | `campus` | The `name` attribute on the rendered control. |
| `value` | | ID or Guid of the pre-selected campus(es), comma-separated. |
| `valuefield` | `id` | Whether the control value uses campus `id` or `guid`. |
| `includeinactive` | `false` | Whether to include inactive campuses. |
| `campustypes` | | Comma-separated Defined Value IDs to filter campuses by type. |
| `campusstatuses` | | Comma-separated Defined Value IDs to filter campuses by status. |
| `selectablecampuses` | | Comma-separated Campus IDs to restrict the selectable list. |
| `longlistenabled` | `false` | Enables Chosen.js search (single-select mode only). |
| `allowmultiple` | `false` | `true` renders checkboxes; `false` renders a dropdown. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please provide a campus.` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to the rendered control. |

<details>
<summary>Filtering Behavior</summary>

Filters are applied as AND conditions (matching Rock's C# logic):
1. **Type filter** — removes campuses whose `CampusTypeValueId` is not in `campustypes`.
2. **Status filter** — removes campuses whose `CampusStatusValueId` is not in `campusstatuses`.
3. **Selectable filter** — removes campuses whose `Id` is not in `selectablecampuses`.
4. **Active filter** — removes inactive campuses unless `includeinactive` is `true`.

Currently selected values are always re-added to the list to prevent them from disappearing when they fall outside the filter criteria.

Data source: `'All' | FromCache:'Campus'`, sorted by `Order`.
</details>


---


## Defined Value Picker

Entity picker for Defined Values from a specified Defined Type. Renders as a dropdown (single-select) or checkbox list (multi-select).

### Example
```lava
{[ definedvaluepicker label:'Connection Type' value:'1,2' definedtype:'768' allowmultiple:'true' ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `definedtype` | *(required)* | ID or Guid of the Defined Type to populate the picker from. |
| `label` | | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `name` | `definedvalue` | The `name` attribute on the rendered control. |
| `value` | | ID or Guid of the pre-selected value(s), comma-separated. |
| `valuefield` | `id` | Whether the control value uses defined value `id` or `guid`. |
| `longlistenabled` | `false` | Enables Chosen.js search (single-select mode only). |
| `allowmultiple` | `false` | `true` renders checkboxes; `false` renders a dropdown. |
| `includeinactive` | `false` | Whether to include inactive Defined Values. |
| `displaydescriptions` | `false` | Show `Description` instead of `Value` as the display text. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please select a value.` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to the rendered control. |


---


## Date Picker

Single date input with a Rock calendar popup initialized via `Rock.controls.datePicker`.

### Example
```lava
{[ datepicker label:'Start Date' name:'startdate' isrequired:'true' value:'{{ "Now" | Date:"M/d/yyyy" }}' ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | `Date` | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `name` | `date` | The `name` attribute on the input. |
| `value` | | Initial date value (format: `M/d/yyyy`). |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please provide a date.` | Validation message. |
| `additionalattributes` | | Extra HTML attributes added to the `<input>`. |

<details>
<summary>Generated HTML Structure</summary>

```html
<div class="input-group input-width-md js-date-picker date">
    <input name="{name}" type="text" id="{id}" class="form-control" value="{value}">
    <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
</div>
<script>
    Rock.controls.datePicker.initialize({
        id: '{id}',
        startView: 0,
        showOnFocus: true,
        format: 'mm/dd/yyyy',
        todayHighlight: true,
        forceParse: true,
        postbackScript: '',
    });
</script>
```
</details>


---


## Date Range Picker

Renders two date inputs (Start Date and End Date) separated by a "to" label, each with its own Rock calendar popup.

### Example
```lava
{[ daterangepicker label:'Date Range' isrequired:'true' value:'{{ "Now" | Date:"M/d/yyyy" }}' ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | `Date` | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `value` | | Initial date value for both inputs (format: `M/d/yyyy`). |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please provide a valid Date.` | Validation message. |

<details>
<summary>Form Submission Names</summary>

The two date inputs use the `name` parameter with suffixes:
- Start date: `{name}_lower`
- End date: `{name}_upper`

These are the keys that will appear in `{{ Form }}` when submitted via HTMX.
</details>


---


## Range Slider

Slider control rendered via `Rock.controls.rangeSlider` with configurable min, max, and step values.

### Example
```lava
{[ rangeslider label:'Range Slider' min:'0' max:'100' step:'.1' value:'10' ]}
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `label` | `Range Slider` | Label text. |
| `showlabel` | `true` | Whether to display the label. |
| `min` | `0` | Minimum slider value. |
| `max` | `100` | Maximum slider value. |
| `step` | `1` | Increment step size. |
| `value` | `0` | Initial value. |
| `isrequired` | `false` | Makes the field required. |
| `validationmessage` | `Please select a value.` | Validation message. |


---


## Usage with HTMX / Helix

These form-control ShortCodes generate standard HTML form controls. When used inside a `<lava-form>` with an `hx-post` submit button, the control values are included in `{{ Form }}` on the endpoint side (along with ASP.NET ViewState noise — see `../Lava-with-Helix.md` > Form Serialization Behavior).

### Known Limitations

1. **`{[ dropdown ]}` with `hx-vals`:** The ShortCode's `additionalattributes` parameter uses single-quote delimiters, which conflict with `hx-vals`'s JSON syntax. Use a raw `<select>` instead when HTMX attributes are needed on the element. See `../Lava-Helix-ChosenJS.md` for the recommended Chosen.js pattern.

2. **Per-control `hx-post`:** When using inline/per-row interactions (e.g., a dropdown that submits on change), prefer raw HTML controls with explicit `hx-params` whitelists over these ShortCodes. The ShortCodes are best suited for form-based layouts submitted with a single button. See `../Lava-with-Helix.md` > Form Serialization Behavior for the `hx-params` whitelist pattern.

3. **`name` collisions in tables:** If you render these ShortCodes inside table rows (e.g., a `{[ checkboxlist ]}` per row with the same `name`), all rows' values will be submitted together. Use distinct `name` values per row or use the per-control `hx-post` pattern instead.
