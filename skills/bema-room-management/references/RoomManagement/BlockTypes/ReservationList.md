# Reservation List & Conflicting Reservation List

**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source files**:
- `RoomManagement (plugin package)/RoomManagement/ReservationList.ascx.cs`
- `RoomManagement (plugin package)/RoomManagement/ConflictingReservationList.ascx.cs`

**Rock Category**: BEMA Services > Room Management

These two blocks are near-twins — same filter set, same underlying query. Differences:

|  | Reservation List | Conflicting Reservation List |
|---|---|---|
| Shows every matching reservation | ✅ | ❌ (only rows where conflict info is non-empty) |
| Runs `GenerateConflictInfo()` per row | ❌ | ✅ |
| Has `DatabaseTimeout` attribute | ❌ | ✅ (default 180s) |
| Has Campus filter | ✅ | ❌ |
| Has bulk Email Contacts action | ✅ | ❌ |

They're documented together because the filter behavior and query options are 1:1 identical — if you know one, you know the other.

## Purpose

- **Reservation List** — the main admin grid of reservations. Rich filter panel, row-click drills into [Reservation Detail](ReservationDetail.md), and a bulk action lets staff fire off a Rock `Communication` to the Admin and/or Event contacts of every selected reservation in one click.
- **Conflicting Reservation List** — same grid, narrowed to reservations whose resources/locations overlap with at least one *other* reservation. Used by staff to find and triage scheduling clashes.

## Block Attributes

### Reservation List

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Detail Page | LinkedPage | *(none — required)* | `DetailPage` |
| Related Entity Query String Parameter | TextField | *(empty)* | *(default — property name used as key)* |

### Conflicting Reservation List

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Detail Page | LinkedPage | *(none)* | `DetailPage` |
| Database Timeout | IntegerField | `180` | `DatabaseTimeoutSeconds` |
| Related Entity Query String Parameter | TextField | *(empty)* | `RelatedEntityQueryStringParameter` |

## Page Parameters

Neither block declares a page parameter directly. Both *may* read one dynamic parameter whose **name** is provided by the `Related Entity Query String Parameter` block attribute:

| Configured value | Parameter Claude reads | Behavior |
|---|---|---|
| `EventItemOccurrenceId` | `EventItemOccurrenceId` | Restricts the grid to reservations linked to this EventItemOccurrence (via `ReservationLinkage`). Time window expands from today+1mo to today+5yrs. |
| *anything else* | n/a | Shows the inline message `Unsupported Related Entity QueryString Parameter '...'`. |

In other words: `EventItemOccurrenceId` is the **only** relation the blocks support today — the attribute exists but any other value is rejected.

## Grid Filters (persisted per-user per-block via `gfSettings`)

| Filter key | Applies to Reservation List | Applies to Conflicting | Source control |
|---|---|---|---|
| `Reservation Name` | ✅ | ✅ | `tbName` — matches `ReservationQueryOptions.Name` (substring on `Reservation.Name`). |
| `Reservation Type` | ✅ | ✅ | `cblReservationType` — bound to active `ReservationType` rows. |
| `Ministry` | ✅ | ✅ | `cblMinistry` — bound to `ReservationMinistry.DistinctBy(Name)`. Filter passes names (not Ids) into `ReservationQueryOptions.MinistryNames`. |
| `Created By`, `Event Contact`, `Admin Contact` | ✅ | ✅ | Person pickers. Passed as `CreatorPersonId`, `EventContactPersonId`, `AdministrativeContactPersonId`. |
| `Approval State` | ✅ | ✅ | `cblApproval` — bound to the `ReservationApprovalState` enum. |
| `Start Time`, `End Time` | ✅ | ✅ | `dtpStartDateTime`, `dtpEndDateTime`. Defaults: today → today+1mo, or today → today+5yrs when the related-entity filter is active. |
| `Resources` | ✅ | ✅ | `rpResource` → `ReservationQueryOptions.ResourceIds`. |
| `Locations` | ✅ | ✅ | `lipLocation` — **important**: each selected location is expanded to include its descendants *and* its ancestors via `LocationService.GetAllDescendentIds()` + `GetAllAncestorIds()`. Passed as `ReservationQueryOptions.LocationIds`. |
| `Campuses` | ✅ | ❌ | `cpCampuses` → `ReservationQueryOptions.CampusIds`. |

The "display value" renderer for each filter is custom per key — Ids are resolved back to Names (Ministry, Type, Campus, Resource, Location, Person) so the filter summary chip is human-readable.

## Data Flow

### Reads

- [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) — via `ReservationService.Queryable(ReservationQueryOptions)`.
- [`ReservationType`](../sql-tables/Reservation-and-Type.md#reservationtype) — for the type filter dropdown.
- [`ReservationMinistry`](../sql-tables/Reservation-and-Type.md#reservationministry) — `DistinctBy(Name).OrderBy(Name)` for the ministry filter.
- [`Location`](../../../../rock-sql-schema/references/database-structure-tables.md#location) — for tree expansion when filtering by location.
- [`Person`](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#person) — for resolving filter display values.

After the base query, the plugin helper `qry.GetReservationSummaries(start, end, includeCancelled)` expands recurring reservations into per-occurrence summaries (or for Conflicting, into IDs used to re-load the entity for conflict inspection).

### Writes — Reservation List only

The grid carries a custom Action dropdown with three items:

| Option | Value |
|---|---|
| Email Admin Contacts of Selected Reservations | `EMAIL_ADMIN` |
| Email Event Contacts of Selected Reservations | `EMAIL_EVENT` |
| Email Admin and Event Contacts of Selected Reservations | `EMAIL_ADMIN_AND_EVENT` |

When the user picks one (and has at least one row selected), the block:

1. Collects distinct `PersonAlias.PersonId`s for the chosen contact role(s).
2. Creates a `Communication` row (`IsBulkCommunication=true`, `Status=Transient`, `SenderPersonAliasId=CurrentPersonAliasId`), with `Reservations` added as an `AdditionalMergeField` key.
3. BulkInserts one `CommunicationRecipient` per distinct primary alias. **Each recipient's `AdditionalMergeValues` only include the reservations *they specifically* are a contact on** — so the Lava template in the communication sees a filtered list per person.
4. Redirects to `{Site.CommunicationPage}?CommunicationId={newId}` so the user can draft and send.

Recipient resolution is chunked to 1000 PersonIds at a time to avoid SQL parameter-limit errors.

### Writes — Conflicting Reservation List

*(None.)*

## Conflict Detection (Conflicting Reservation List only)

1. Run the same filtered query.
2. Get the list of matching Reservation Ids (via `GetReservationSummaries(...).Select(rs => rs.ReservationId)`).
3. Re-load the full `Reservation` entities.
4. For each, call `reservationService.GenerateConflictInfo(reservation, detailPageUrl)` — this plugin helper returns an HTML snippet describing every overlap (or empty string if none).
5. Only include the reservation in the output if `conflictInfo` is non-empty.
6. Wrap the whole loop in a try/catch for `TimeoutException` — on timeout, show "There are too many reservations to analyze. Please narrow down your search or extend the timeout window in the block settings." and give up.

The configurable `DatabaseTimeout` also drives `ScriptManager.AsyncPostBackTimeout` and `Server.ScriptTimeout` (both set to `DatabaseTimeout + 5` seconds) so that the page doesn't time out before the SQL query does.

## Grid Columns

### Reservation List

| Column | Source |
|---|---|
| ReservationType | `ReservationType.Name` |
| ReservationName | `Reservation.Name` |
| Locations | Comma-delimited `ReservationLocations.Select(rl => rl.Location.Name)` |
| Resources | Comma-delimited `ReservationResources.Select(rr => rr.Resource.Name)` |
| EventStartDateTime, EventEndDateTime, ReservationStartDateTime, ReservationEndDateTime | Raw datetimes (from the summary). |
| EventDateTimeDescription | From `ReservationSummary`. |
| ReservationDateTimeDescription | Suffixed with ` (Mon)` for single-day or ` (Mon-Fri)` for multi-day — uses 3-letter `DayOfWeek`. |
| ApprovalState | `r.ApprovalState.ConvertToString()` (humanized from the enum). |

Plus the dynamic EntityType attribute columns for `Reservation`.

### Conflicting Reservation List

Projection into `ConflictedReservation` (a private nested class):

| Column | Source |
|---|---|
| Id | `Reservation.Id` |
| ReservationType | `ReservationType.Name` |
| ReservationName | `Reservation.Name` |
| Locations | Comma-delimited location names |
| Resources | Comma-delimited resource names |
| StartDate | `FirstOccurrenceStartDateTime` |
| Schedule | `FriendlyReservationTime` |
| Conflicts | HTML from `GenerateConflictInfo()` |
| ApprovalState | `r.ApprovalState.ConvertToString()` |

## Linked Pages

| Block | Key | Query string passed |
|---|---|---|
| Both | `DetailPage` | `ReservationId` |

## Notable Behaviors

- **Ministry filter matches by Name, not Id** (shared with [RequestorChange](RequestorChange.md)). Two `ReservationMinistry` rows sharing a Name count as one — consequence of `DistinctBy(Name)`.
- **Location filter expands both up and down the tree** — picking "Building A" includes every descendant room *and* every ancestor (the campus, the address, etc.). This is unusual; most Rock filters only expand downward.
- **Related-entity filter widens the time window to 5 years** — when an `EventItemOccurrenceId` is in the querystring, the defaults switch from "today → today+1mo" to "today → today+5yrs" so the block can find reservations scheduled well after the page load.
- **ConflictingReservationList has no Campus filter** — likely an oversight given the block was branched off ReservationList.
- The Reservation List uses a `RockDropDownList` injected into the grid's custom-action area and a `HiddenField + client-side script + RaisePostBackEvent` pattern to pipe the selection into code-behind. The underlying key is `PostbackEventArgument.GridActionChanged`.
- `ClearFilterClick` (Reservation List only) calls `gfSettings.DeleteFilterPreferences()`, resetting all stored filter values for the current user on this block.
- `_ddlCommunicate_SelectedIndexChanged` exists as a stub that throws `NotImplementedException` — dead code, never wired up.
