# Reservation Linkage List

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ReservationLinkageList.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

Secondary block (implements `ISecondaryBlock`) that sits on a Reservation Detail page. Displays every `ReservationLinkage` row for the current reservation, i.e., every core-Rock `EventItemOccurrence` (and its Calendar Items / Content Items) that this reservation is tied to.

Clicking a row opens the [Reservation Linkage Detail](ReservationLinkageDetail.md) page to edit it; the Calendar Item and Content Item columns render as hyperlinks into their own detail pages.

## Block Attributes

| Attribute (Display Name) | Type | Default | Key |
|---|---|---|---|
| Linkage Page | LinkedPage | `Rock.SystemGuid.Page.REGISTRATION_INSTANCE_LINKAGE` | `LinkagePage` |
| Calendar Item Page | LinkedPage | `Rock.SystemGuid.Page.EVENT_DETAIL` | `CalendarItemDetailPage` |
| Content Item Page | LinkedPage | `Rock.SystemGuid.Page.CONTENT_DETAIL` | `ContentItemDetailPage` |

> The default for **Linkage Page** re-uses the core-Rock registration-instance linkage Page Guid. In practice, the Room Management plugin's own linkage detail page should be configured here — leaving the default in place points the Add button at an unrelated core page.

## Page Parameters

| Parameter | Use |
|---|---|
| `ReservationId` | Integer. Which [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) owns the linkages. If missing, the block hides. |

## Data Flow

### Reads

- [`Reservation`](../sql-tables/Reservation-and-Type.md#reservation) — authorization check + fallback Hide.
- [`ReservationLinkage`](../sql-tables/Reservation-Linkage.md#reservationlinkage) — `ReservationLinkageService.Queryable()` with these eager-load paths:
    - `EventItemOccurrence.EventItem.EventCalendarItems.EventCalendar`
    - `EventItemOccurrence.ContentChannelItems.ContentChannelItem`
- Orders by `SortProperty` if a column header was clicked, otherwise by `CreatedDateTime DESC`.

### Writes

- **Delete row**: removes the `ReservationLinkage` row. No cascade — the underlying `EventItemOccurrence` / `EventItem` / `ContentChannelItem` are all core-Rock entities and are left alone.

## Linked Pages

| Key | Display name | Query string passed | Default |
|---|---|---|---|
| `LinkagePage` | Linkage Page | `LinkageId` + `ReservationId` | Registration Instance Linkage page (core Rock) |
| `CalendarItemDetailPage` | Calendar Item Page | `EventCalendarId`, `EventItemId` | Event Detail (core Rock) |
| `ContentItemDetailPage` | Content Item Page | `ContentItemId` | Content Detail (core Rock) |

## Notable Behaviors

- **`ISecondaryBlock`** — `SetVisible(bool)` toggles the whole `pnlDetails` visibility. The host Reservation Detail block uses this to hide linkages when the reservation is being created (no Reservation.Id yet to attach to).
- **Add button visibility is driven by authorization**:
    - Shown if the current person has `ADMINISTRATE` on the reservation **or** has `EDIT` and (is the `CreatedBy`, is the `AdministrativeContact`, or `ReservationId == 0`).
    - Otherwise hidden.
- The row-databound handler renders the Calendar Item and Content Item cells by hand — it loops through each `EventCalendarItem` under the `EventItem` and each `ContentChannelItem` under the `EventItemOccurrence`, linkifying where a LinkedPage URL resolves and falling back to plain text where it doesn't.
- Export filename/title is set to `{reservationName} Linkages` / `{reservationName}ReservationLinkages` on Grid rebind.
- No grid filter controls are wired up — the `fLinkages_DisplayFilterValue` handler only has a `default` branch that blanks the value. The markup likely declares `fLinkages` but this block doesn't actually persist any filter preferences.
