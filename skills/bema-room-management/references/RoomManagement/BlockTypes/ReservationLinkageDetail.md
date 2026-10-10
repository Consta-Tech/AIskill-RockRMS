# Reservation Linkage Detail

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ReservationLinkageDetail.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

A 4-step wizard that links a `Reservation` to a core-Rock `EventItemOccurrence`. The wizard can either:

1. Create a **brand-new** `EventItem` (with calendar items, audiences, attributes, and photo), then create a **new** `EventItemOccurrence` for it, OR
2. Select an **existing** `EventItem` and either create a new occurrence for it or link to an existing one.

The result is always exactly one new `ReservationLinkage` row tying the reservation to an `EventItemOccurrence`. Companion to [Reservation Linkage List](ReservationLinkageList.md), which is the landing grid that opens this wizard.

## Block Attributes

### Standard

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Default Calendar | EventCalendarField | *(none)* | `DefaultCalendar` |
| Allow Creating New Calendar Events | BooleanField | `true` | `AllowCreatingNewCalendarEvents` |
| Include Inactive Calendar Items | BooleanField | `true` | `IncludeInactiveCalendarItems` |
| Completion Workflow | WorkflowTypeField | *(none)* | `CompletionWorkflow` |
| Display Link to Event Details Page on Confirmation Screen | BooleanField | `true` | `DisplayEventDetailsLink` |
| External Event Details Page | LinkedPage | `Rock.SystemGuid.Page.EVENT_DETAILS` | `EventDetailsPage` |

### Advanced — Lava instructions per wizard step

These render at the top of each step as guidance for the user. Each receives the standard common merge fields plus `ActiveWizardStep` (enum name) and `Page` (1-based index).

| Attribute | Shown on step | Key |
|---|---|---|
| Event Instructions Lava Template | Event | `LavaInstruction_Event` |
| Event Occurrence Instructions Lava Template | EventOccurrence | `LavaInstruction_EventOccurrence` |
| Summary Instructions Lava Template | Summary | `LavaInstruction_Summary` |
| Wizard Finished Instructions Lava Template | Finished | `LavaInstruction_Finished` |

## Page Parameters

| Parameter | Use |
|---|---|
| `ReservationId` | Integer. The [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) to attach the new linkage to. If missing, the wizard still renders but `CommitChanges` short-circuits with no write. |

## Wizard Flow

Steps are tracked by the private enum `ActiveWizardStep { ViewReservation, EditReservation, Event, EventOccurrence, Summary, Finished }`. The wizard starts at `Event` on first load.

| Step | User picks | Skipped when |
|---|---|---|
| **Event** | Toggle: new event vs. existing event. If existing, select the `EventItem` and (if it has occurrences) select one of its `EventItemOccurrence`s or create a new one. | Never — always first step. |
| **EventOccurrence** | If creating a new occurrence: location description, contact person/phone/email, schedule (iCal), and occurrence-level note. | Skipped when no event is selected and new-event toggle is off (→ jumps to Summary). |
| **Summary** | Review-only. Shows a bullet list describing what will be created. | — |
| **Finished** | Read-only result pane with links to the new Event / Event Occurrence / External Event Details page. | — |

### Panel visibility rules

| Control | Rule |
|---|---|
| `pnlNewEventSelection` (toggle: new vs. existing event) | Hidden entirely when `AllowCreatingNewCalendarEvents = false`. |
| `pnlNewOccurrenceSelection` (toggle: new vs. existing occurrence) | Only shown if the user picked an existing event **and** that event already has occurrences. |
| `pnlNewOccurrence` / `pnlExistingOccurrence` | Swap based on the `tglOccurrenceSelection` toggle. |
| `pnlWizard` (the step-indicator strip) | Hidden on `ViewReservation`, `EditReservation`, and `Finished`. |

### Back-button rules (`SetupWizardButtons`)

- `lbEvent` is enabled from step 2 onward.
- `lbEventOccurrence` is enabled on Summary *only if* the user chose to create/select an event (otherwise the EventOccurrence step was skipped).
- No forward skipping — user must advance through `lbNext_*`.

## Data Flow

### Reads

- [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) — to pre-fill `Name`, `Schedule.iCalendarContent`, `CampusId`, contact fields.
- [`EventCalendar`](../../../../rock-sql-schema/references/CalendarEvent.md#eventcalendar) — populates `cblCalendars` (only calendars the current person has `EDIT` on).
- [`EventItem`](../../../../rock-sql-schema/references/CalendarEvent.md#eventitem) — lookup when user picks an existing event.
- `EventItemOccurrences` — populates the "existing occurrence" dropdown; ordered by `NextStartDateTime`.
- `DefinedType` `MARKETING_CAMPAIGN_AUDIENCE_TYPE` — populates the audience dialog dropdown for new events.

### Writes (in `CommitChanges`, wrapped in a single `RockContext.WrapTransaction`)

#### Branch A: `tglEventSelection = true` (new event)

1. Create `EventItem` with `Name`, `Summary`, `Description` (HTML), `IsActive = true`, optional `PhotoId`.
2. Add `EventItemAudience` rows for each item in `ViewState["AudiencesState"]`.
3. For each selected calendar in `cblCalendars` (intersected with the in-memory state list `ViewState["ItemsState"]`), add an `EventCalendarItem` — `CopyPropertiesFrom` each row in state so any attribute values carry over.
4. `SaveChanges` — persists the event.
5. For each `EventCalendarItem`, call `LoadAttributes` → `GetEditValues(phEventItemAttributes)` → `SaveAttributeValues()`. **Note: this runs *after* the first SaveChanges, outside the audience/calendar inserts — intentional so the newly persisted ids exist for attribute writes, but it means the transaction still holds past this call since everything is inside `WrapTransaction`.**

#### Branch B: `tglEventSelection = false` (existing event)

1. `eventItem = EventItemService.Get( eipSelectedEvent.SelectedValueAsId() )`.

#### Then (both branches), if `eventItem != null`:

- If `tglOccurrenceSelection = true` (new occurrence): build `EventItemOccurrence` with `CampusId`, `Location`, `ContactPersonAliasId`, `ContactPhone`, `ContactEmail`, `Note`, and `Schedule { iCalendarContent }`. `SaveChanges`.
- Else: `eventItemOccurrence = EventItemOccurrenceService.Get( ddlSelectedOccurrence )`.
- Insert `ReservationLinkage { ReservationId, EventItemOccurrenceId }`. `SaveChanges`.

#### After commit

`LaunchPostWizardWorkflow` fires if `CompletionWorkflow` is set. Workflow attributes passed:

| Attribute key | Value |
|---|---|
| `Reservation` | `reservation.Guid` |
| `EventItemOccurrenceGuid` | `reservation.EventItemOccurrence.Guid` (if present) |

Workflow is launched via `WorkflowService.Process(...)` and errors are swallowed (captured into an unused local).

## ViewState & Session

This block keeps **meaningful state across postbacks** in two unusual places:

| Where | Key | Contents |
|---|---|---|
| `ViewState` | `EventItem` | JSON-serialized `EventItem` (reference-loop-safe). |
| `ViewState` | `EventItemOccurrence` | JSON-serialized `EventItemOccurrence`. |
| `ViewState` | `AudiencesState` | `List<int>` of selected audience `DefinedValueId`s. |
| `ViewState` | `ItemsState` | JSON list of `EventCalendarItem` with any attribute edits. |
| `ViewState` | `hfActiveDialog` | Dialog name string (`"EVENTITEMAUDIENCE"`). |
| `Session` | `CurrentCalendars` | `List<int>` of selected calendar ids. **Session, not ViewState** — see caveat below. |

### `Session["CurrentCalendars"]` caveat

If `Session["CurrentCalendars"]` is lost mid-wizard (session expiry), `ShowItemAttributes` rehydrates from `cblCalendars.SelectedValuesAsInt` **and** resets the user back to step 1. If the checkbox list is also empty by that point, an empty list is stored and the user loses any calendar selection they'd made. Session state is shared across pages within the site, so this key can also leak across tabs.

## Linked Pages

| Key | Default | Query string passed |
|---|---|---|
| `EventDetailsPage` | `Rock.SystemGuid.Page.EVENT_DETAILS` | `EventOccurrenceId` |
| *(hardcoded)* `Rock.SystemGuid.Page.EVENT_DETAIL` | — | `EventItemId` |
| *(hardcoded)* `Rock.SystemGuid.Page.EVENT_OCCURRENCE` | — | `EventItemOccurrenceId` |

Two of these are **hardcoded core Rock page Guids** in `SetResultLinks`, not block attributes — if an organization moves those internal pages, the success-screen links would break.

## Notable Behaviors

- **No-cache headers are forced** on every OnInit: `Page.Response.Cache.SetCacheability(NoCache)`, `SetExpires(-1hr)`, `SetNoStore()`. Prevents browsers from showing a stale wizard mid-flow.
- **Print CSS is injected**: `~/Plugins/com_bemaservices/RoomManagement/Assets/Styles/print.css` is appended to `Page.Header`. Also `~/Styles/fluidbox.css`.
- **Calendar filter is EDIT-authorized only**: `cblCalendars` lists only calendars where `calendar.IsAuthorized(EDIT, CurrentPerson)`. A user without EDIT on any calendar sees an empty list.
- **`ExitWizard()` navigates to parent page** carrying only `ReservationId`. Used by the top-left back link and the bottom-right return link on the Finished panel.
- **Single transaction across all writes**: all SaveChanges in `CommitChanges` run inside `rockContext.WrapTransaction`, so a failure anywhere rolls back the whole new event + occurrence + linkage creation.
- **Reservation’s iCalendarContent is carried into the default occurrence schedule** — when `Init_SetValuesFromReservation` runs, `sbEventOccurrenceSchedule.iCalendarContent` is pre-filled from the reservation, so a new occurrence defaults to the same schedule unless the user changes it.
- **`BreadCrumb` sets `RockPage.Title` and `BrowserTitle`** to the reservation name — overwrites whatever the page was otherwise going to show.
- **`result.ReservationId`/`ReservationName` are set only if an EventItemOccurrence ends up created-or-linked** — if the user walks through with no event selected, the Finished screen still renders but the reservation title line ends up blank and all result-links are hidden.
- **Audience dialog filters already-picked values out of the dropdown**, but no similar filter is applied to the calendars check-list — the user can re-toggle calendars freely.
