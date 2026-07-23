# Conflicting Reservation List

**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ConflictingReservationList.ascx.cs`
**Rock Category**: BEMA Services > Room Management

See the combined write-up under [Reservation List & Conflicting Reservation List](ReservationList.md) — this block shares ~80% of its code with `ReservationList` and is documented jointly there.

## Quick reference

- **Detail Page** (required `LinkedPage`) — `ReservationId`.
- **Database Timeout** (`IntegerField`, default 180s) — also drives `ScriptManager.AsyncPostBackTimeout` and `Server.ScriptTimeout` (DatabaseTimeout + 5).
- **Related Entity Query String Parameter** (`TextField`) — supports only `EventItemOccurrenceId`.
- No Campus filter (unlike Reservation List).
- No bulk Email Contacts action (unlike Reservation List).
- Only shows rows where `ReservationService.GenerateConflictInfo(reservation, detailPageUrl)` returns a non-empty string.
- On `TimeoutException`, renders "There are too many reservations to analyze. Please narrow down your search or extend the timeout window in the block settings." instead of the grid.
