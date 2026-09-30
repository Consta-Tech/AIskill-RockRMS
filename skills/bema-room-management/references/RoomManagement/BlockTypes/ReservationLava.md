# Reservation Lava

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ReservationLava.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

The "main" reservation calendar/list block staff use day-to-day. A Lava-rendered pane that:

1. Shows a date-scoped list of reservations.
2. Supports **Day / Week / Month / Year** view modes and three "show by" filters: **All** / **My Reservations** / **My Approvals**.
3. Lets the user pick from multiple Lava templates ("Reservation Views", defined as `DefinedValue`s) — each view is its own Lava template with its own enabled Lava commands.
4. Can **print a PDF report** (Room Setup Sheet, Schedule, etc.) via pluggable `ReportTemplate` components (also `DefinedValue`s).
5. Persists *all* user-chosen filters and the view mode as **per-person block preferences**, so each staff member gets their own remembered setup.

## Block Attributes

### Filter Settings

Each filter has a 4-position display mode: `1=Hidden`, `2=Plain`, `3=Panel Open`, `4=Panel Closed`.

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Location Filter Display Mode | CustomRadioListField | `1` (Hidden) | `LocationFilterDisplayMode` |
| Resource Filter Display Mode | CustomRadioListField | `1` (Hidden) | `ResourceFilterDisplayMode` |
| Campus Filter Display Mode | CustomRadioListField | `1` (Hidden) | `CampusFilterDisplayMode` |
| Ministry Filter Display Mode | CustomRadioListField | `1` (Hidden) | `MinistryFilterDisplayMode` |
| Approval Filter Display Mode | CustomRadioListField | `1` (Hidden) | `ApprovalFilterDisplayMode` |
| Reservation Type Filter Display Mode | CustomRadioListField | `1` (Hidden) | `ReservationTypeFilterDisplayMode` |
| Show Date Range Filter | BooleanField | `false` | *(default)* |

### Lava Settings

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Details Page | LinkedPage | *(none)* | *(default)* |
| Visible Printable Report Options | DefinedValueField | `5D53E2F0-…FA5B0B`, `46C855B0-…FB3DD2` | *(default)* |
| Visible Reservation View Options | DefinedValueField | `67EA36B0-…700DC0` | *(default)* |
| Enable Debug | BooleanField | `false` | *(default)* |

- **Visible Printable Report Options** points at DefinedType `13B169EA-A090-45FF-8B11-A9E02776E35E` (plugin's **Printable Reservation Reports** DefinedType).
- **Visible Reservation View Options** points at DefinedType `32EC3B34-01CF-4513-BC2E-58ECFA91D010` (plugin's **Reservation Views** DefinedType).

### View Settings

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Default View Option | CustomDropdownListField (`Day,Week,Month`) | `Week` | *(default)* |
| Start of Week Day | DayOfWeekField | `Sunday` | `StartofWeekDay` |
| Show Small Calendar | BooleanField | `true` | *(default)* |
| Show Day View | BooleanField | `false` | *(default)* |
| Show Week View | BooleanField | `true` | *(default)* |
| Show Month View | BooleanField | `true` | *(default)* |
| Show Year View | BooleanField | `false` | *(default)* |
| Download Reports | BooleanField | `true` | *(default)* |

## Page Parameters

| Parameter | Use |
|---|---|
| `SelectedDate` | Optional. Deep-link to a specific date — pre-positions the calendar there. |

## Block Person Preferences

This block **does not** use per-user filter preferences (`gfSettings`). Instead, it uses **per-person block preferences** (`GetBlockPersonPreferences()`). Keys:

| Key | Example value | Set by |
|---|---|---|
| `ViewMode` | `"Week"` | View-mode buttons |
| `ReservationViewId` | Id of a DefinedValue in the `Reservation Views` type | View dropdown |
| `ShowBy` | `0` / `1` / `2` (enum below) | All / My Reservations / My Approvals buttons |
| `Locations` | Comma-delimited `LocationId` list | Location picker |
| `Resources` | Comma-delimited `ResourceId` list | Resource picker |
| `Campuses` | Comma-delimited `CampusId` list | Campus checkbox list |
| `Ministries` | Comma-delimited `ReservationMinistryId` list | Ministry checkbox list |
| `ApprovalState` | Comma-delimited `ReservationApprovalState` int list | Approval checkbox list |
| `ReservationType` | Comma-delimited `ReservationTypeId` list | Reservation-type checkbox list |
| `StartDate`, `EndDate` | Date strings | Date-range pickers |

The `ShowBy` enum values: `All = 0`, `MyReservations = 1`, `MyApprovals = 2`.

## Data Flow

### Reads

- [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) — via `ReservationService.Queryable(ReservationQueryOptions)`.
- [`ReservationType`](../sql-tables/Reservation-and-Type.md#reservationtype), [`ReservationMinistry`](../sql-tables/Reservation-and-Type.md#reservationministry) — filter options.
- [`Location`](../../../../rock-sql-schema/references/database-structure-tables.md#location) — descendant/ancestor tree expansion (same as [Reservation List](ReservationList.md)).
- [`Campus`](../../../../rock-sql-schema/references/Campus.md) — `CampusCache.All(includeInactive: false)`.
- Two `DefinedType` caches (by Guid above) — views and report templates.

### Writes

Block preferences only — see above. No reservation data is written.

Additionally, `Session["CalendarVisibleDate"]` is stamped whenever the user navigates the small calendar. This affects only this session, across all pages on the site.

### ShowBy mapping

| Button / enum | `ReservationQueryOptions` setting |
|---|---|
| All | (no person filter) |
| MyReservations | `ReservationsByPersonId = CurrentPerson.Id` |
| MyApprovals | `ApprovalsByPersonId = CurrentPerson.Id` |

### Time window

`FilterStartDate` / `FilterEndDate` are computed from `ViewMode`:

| ViewMode | Range |
|---|---|
| Day | Selected date only |
| Week | `StartOfWeek(firstDayOfWeek)` → `EndOfWeek(firstDayOfWeek)` |
| Month | 1st of month → last of month |
| Year (current year) | Today → Dec 31 of current year |
| Year (future year) | Jan 1 → Dec 31 of picked year |

When "Show Date Range Filter" is enabled and the user has set explicit start/end dates in preferences, those override the auto-computed range.

Reservations are then expanded via `qry.GetReservationSummaries(start, end, includeCancelled=true)`.

## Rendering: Views & Reports

### Views (Lava templates)

Each "Reservation View" is a row in the `32EC3B34-01CF-4513-BC2E-58ECFA91D010` DefinedType, with these attributes on each DefinedValue:

| Attribute | Purpose |
|---|---|
| `Lava` | The Lava template body. |
| `LavaCommands` | The Lava commands enabled when rendering the template. |

The block reads both off the selected DefinedValueCache and calls `lavaTemplate.ResolveMergeFields(mergeFields, lavaCommands)`.

### Lava merge fields

| Merge field | Type | Notes |
|---|---|---|
| `TimeFrame` | string | `"Day"` / `"Week"` / `"Month"` / `"Year"`. |
| `FilterStartDate`, `FilterEndDate` | DateTime? | Resolved date window. |
| `DetailsPage` | string | Resolved URL for the `DetailsPage` LinkedPage. |
| `CurrentPerson` | `Person` | Standard Rock. |
| `ReservationSummaries` | list-of-lists | Reservations grouped by `EventStartDateTime.Date`. |
| `ReservationDates` | list-of-objects | Per-date dictionary with `Date`, `Reservations`, `Locations`, `Resources` (rich projection for calendar/setup-sheet templates). |

Each reservation object inside `ReservationSummaries` has the same property bag as documented for the [Reservation Lava Kiosk](ReservationLavaKiosk.md#lava-merge-fields) plus `ApprovalStateInt`, `UnassignedResources`, `SetupPhotoLink`, `ReservationMinistry`.

### Reports (PDF)

Each "Printable Reservation Report" is a row in the `13B169EA-A090-45FF-8B11-A9E02776E35E` DefinedType, with these attributes:

| Attribute | Purpose |
|---|---|
| `ReportLogo` | URL (or site-relative path) to the logo image. |
| `ReportTemplate` | Guid of an `EntityType` that implements `ReportTemplate` (resolved via `ReportTemplateContainer.GetComponent()`). |
| `ReportFont` | Font name to pass to the template. |
| `Lava` | Per-reservation Lava template used inside the report. |

The block wires `rptReports` as a `PostBackControl` (so the page can stream binary PDF content back) and calls `reportTemplate.GenerateReport(...)`. The response header is set to `inline` or `attachment` based on the **Download Reports** block attribute.

## Notable Behaviors

- **`<script>` detection workaround**: `BindDataOrReloadPage()` first rasterizes the Lava template with a stub merge-field set and checks whether the output contains `<script`. If it does, the block calls `NavigateToCurrentPageReference()` to force a full page load instead of an UpdatePanel refresh — otherwise ASP.NET's UpdatePanel won't re-execute the scripts. This is a Lava-template-specific gotcha worth knowing when authoring Reservation Views.
- **Ministry filter is Name-based** (DistinctBy Name), same pattern as [Reservation List](ReservationList.md) and [RequestorChange](RequestorChange.md).
- **Location filter expands both ancestors and descendants**, same pattern as Reservation List.
- **`EnableCampusContext` reference is orphaned**: `SetFilterControls` checks `GetAttributeValue("EnableCampusContext")`, but no such attribute is declared on this block — always returns empty-string, so the campus-context fallback never fires. Likely a bug carried over from another block.
- **View-mode visibility rule**: `btn{Day,Week,Month,Year}` buttons are only rendered when (a) more than one view is enabled AND (b) that specific view's "Show X View" attribute is true. If only one view is enabled, the button strip is hidden entirely.
- **View dropdown hides when only one view is enabled** — `divViewDropDown.Visible = definedValueList.Count > 1`.
- **`Session["CalendarVisibleDate"]`** is used to carry the calendar's visible month across postbacks. It's in Session (not ViewState), so it persists across block rebinds but also leaks across pages within the same session.
- **`ClearFilters` clears all per-person preferences** in one shot (Locations, Resources, Campuses, Ministries, ApprovalState, ReservationType, StartDate, EndDate). `ShowBy` and `ViewMode` are preserved.
- **Version display**: `lVersionText.Text = VersionInfo.GetPluginProductVersionNumber()` — renders the plugin version somewhere in the UI (useful when debugging a site running an old copy).
- **`ShowWarning` / `ShowError` are defined but not called** — dead code (same as in [ReservationLavaKiosk](ReservationLavaKiosk.md)).
- The `ypYearPicker` control (year picker used by Year mode) renders year options and defaults to current year.
- Scripts/styles auto-injected: `circle-progress.js`, `event-calendar.js`, `moment.js`, `event-calendar.css` from the plugin's Assets folder.
