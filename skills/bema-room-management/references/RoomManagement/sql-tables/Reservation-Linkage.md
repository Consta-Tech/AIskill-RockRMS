# Reservation Linkage

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



A tiny junction table that ties one Room Management `Reservation` to one Rock `EventItemOccurrence`. Typically created by the **Reservation Linkage Detail** BlockType wizard ([BlockTypes/ReservationLinkageDetail.md](../BlockTypes/ReservationLinkageDetail.md)) so that a reservation and a calendared event share a single source of truth about the date/time and the room.

> Note: `Reservation.EventItemOccurrenceId` also exists as a column, but the plugin's preferred linkage path is through this table because it supports zero-or-many linkages per reservation.

---

## ReservationLinkage

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationLinkage](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ReservationId] [int] NOT NULL,
    [EventItemOccurrenceId] [int] NOT NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationLinkage]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationLinkage] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `ReservationId` | int (FK, NOT NULL) | FK → [Reservation](Reservation-and-Type.md#reservation). `ON DELETE CASCADE`. |
| `EventItemOccurrenceId` | int (FK, NOT NULL) | FK → [EventItemOccurrence](../../../../rock-sql-schema/references/CalendarEvent.md#eventitemoccurrence). `ON DELETE CASCADE`. |
| `Guid`, audit columns | — | Standard Rock. |

### Foreign keys

| Column | References |
|---|---|
| `ReservationId` | [Reservation](Reservation-and-Type.md#reservation) *(CASCADE)* |
| `EventItemOccurrenceId` | [EventItemOccurrence](../../../../rock-sql-schema/references/CalendarEvent.md#eventitemoccurrence) *(CASCADE)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

### Cardinality

A Reservation can have 0..N linkages. The `ReservationLinkageList` block renders these for a given Reservation. Deleting either side cascades the linkage row away.
