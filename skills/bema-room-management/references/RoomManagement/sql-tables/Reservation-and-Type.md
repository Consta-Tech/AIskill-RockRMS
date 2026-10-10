# Reservation and Type

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



The core of the Room Management plugin. A **Reservation** represents one request for a room/resource booking. Its **ReservationType** controls how that reservation is classified, whose approval it requires, what's optional vs. required on the form, and how long it can run. Each Reservation has child rows for the locations it uses, the resources it needs, and (optionally) the door-lock schedule and a classification "ministry".

> For plugin-level cross-links and enum values, see [the sql-tables README](README.md).
> `ReservationLinkage` (to EventItemOccurrence) is documented separately in [Reservation-Linkage.md](Reservation-Linkage.md). Workflow triggers/approval-groups are in [Reservation-Workflow.md](Reservation-Workflow.md).

---

## Reservation

The top-level entity. One row per request. Stores the schedule, contacts, approvals, and totals; everything else hangs off child tables below.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_Reservation](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Name] [nvarchar](50) NULL,
    [ScheduleId] [int] NOT NULL,
    [CampusId] [int] NULL,
    [ReservationMinistryId] [int] NULL,
    [ReservationStatusId] [int] NULL,
    [RequesterAliasId] [int] NULL,
    [ApproverAliasId] [int] NULL,
    [SetupTime] [int] NULL,
    [CleanupTime] [int] NULL,
    [NumberAttending] [int] NULL,
    [Note] [nvarchar](2500) NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL,
    [ApprovalState] [int] NOT NULL,
    [SetupPhotoId] [int] NULL,
    [EventContactPersonAliasId] [int] NULL,
    [EventContactPhone] [nvarchar](50) NULL,
    [EventContactEmail] [nvarchar](400) NULL,
    [AdministrativeContactPersonAliasId] [int] NULL,
    [AdministrativeContactPhone] [nvarchar](50) NULL,
    [AdministrativeContactEmail] [nvarchar](400) NULL,
    [ReservationTypeId] [int] NOT NULL,
    [FirstOccurrenceStartDateTime] [datetime] NULL,
    [LastOccurrenceEndDateTime] [datetime] NULL,
    [EventItemOccurrenceId] [int] NULL,
    [InitialApproverAliasId] [int] NULL,
    [InitialApprovalDateTime] [datetime] NULL,
    [SpecialApproverAliasId] [int] NULL,
    [SpecialApprovalDateTime] [datetime] NULL,
    [FinalApproverAliasId] [int] NULL,
    [FinalApprovalDateTime] [datetime] NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_Reservation]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_Reservation] PRIMARY KEY CLUSTERED ([Id] ASC)
;

CREATE NONCLUSTERED INDEX [IX_EventItemOccurrenceId]
    ON [dbo].[_com_bemaservices_RoomManagement_Reservation] ([EventItemOccurrenceId] ASC)
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_Reservation]
    ADD DEFAULT ((1)) FOR [ApprovalState]
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `Name` | nvarchar(50) | The reservation's display name (e.g., "Youth Worship Night"). |
| `ScheduleId` | int (FK, NOT NULL) | FK → [Schedule](../../../../rock-sql-schema/references/database-structure-tables.md#schedule). The iCal/schedule that drives `FirstOccurrenceStartDateTime` / `LastOccurrenceEndDateTime`. |
| `CampusId` | int (FK, NULL) | FK → [Campus](../../../../rock-sql-schema/references/Campus.md). Optional unless `ReservationType.IsCampusRequired = 1`. |
| `ReservationMinistryId` | int (FK, NULL) | FK → [ReservationMinistry](#reservationministry). Plugin-local "ministry" classification scoped to a ReservationType. |
| `ReservationStatusId` | int (NULL) | **Not referenced by a FK constraint.** Legacy/unused. `ApprovalState` replaced it. |
| `RequesterAliasId` | int (FK, NULL) | FK → [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias). The person on whose behalf the reservation was created (may differ from `CreatedByPersonAliasId`). |
| `ApproverAliasId` | int (FK, NULL) | FK → PersonAlias. Legacy single-approver column, pre-dates the three-stage (Initial / Special / Final) approval columns below. |
| `SetupTime` | int (NULL) | Minutes of setup time before `FirstOccurrenceStartDateTime`. Default sourced from `ReservationType.DefaultSetupTime`. |
| `CleanupTime` | int (NULL) | Minutes of cleanup time after `LastOccurrenceEndDateTime`. Default sourced from `ReservationType.DefaultCleanupTime`. |
| `NumberAttending` | int (NULL) | Expected attendance. Required if `ReservationType.IsNumberAttendingRequired = 1`. |
| `Note` | nvarchar(2500) | Free-form note from the requester. |
| `Guid` | uniqueidentifier | Standard Rock Guid. |
| `CreatedDateTime` / `ModifiedDateTime` | datetime | Standard Rock audit timestamps. |
| `CreatedByPersonAliasId` / `ModifiedByPersonAliasId` | int (FK) | Standard Rock audit. FK → PersonAlias. |
| `ForeignKey` / `ForeignGuid` / `ForeignId` | — | Standard Rock foreign-system identifiers. |
| `ApprovalState` | int (NOT NULL, default 1) | Enum `ReservationApprovalState`: 0=Draft, 1=PendingInitialApproval, 2=Approved, 3=Denied, 4=ChangesNeeded, 5=PendingFinalApproval, 6=PendingSpecialApproval, 7=Cancelled. **Distinct from the 1-indexed child enums** on `ReservationLocation` / `ReservationResource` — see [ApprovalState-Enums.md](../ApprovalState-Enums.md) for the full table. |
| `SetupPhotoId` | int (FK, NULL) | FK → BinaryFile. Optional diagram/photo showing desired room setup. |
| `EventContactPersonAliasId` | int (FK, NULL) | FK → PersonAlias. Person on site during the event. |
| `EventContactPhone` | nvarchar(50) | Event-day contact phone. |
| `EventContactEmail` | nvarchar(400) | Event-day contact email. |
| `AdministrativeContactPersonAliasId` | int (FK, NULL) | FK → PersonAlias. Administrative contact (may differ from requester and event contact). |
| `AdministrativeContactPhone` | nvarchar(50) | Administrative contact phone. |
| `AdministrativeContactEmail` | nvarchar(400) | Administrative contact email. |
| `ReservationTypeId` | int (FK, NOT NULL) | FK → [ReservationType](#reservationtype). Drives form required-fields, approvers, duration caps. |
| `FirstOccurrenceStartDateTime` | datetime | Cached from the Schedule for indexing/sorting. Populated by plugin's `PopulateFirstLastOccurrenceDateTimes` service job. |
| `LastOccurrenceEndDateTime` | datetime | Cached end of last occurrence. Same populator as above. |
| `EventItemOccurrenceId` | int (NULL) | **Not FK-constrained** but conceptually points to an [EventItemOccurrence](../../../../rock-sql-schema/references/CalendarEvent.md#eventitemoccurrence). The plugin's preferred linkage path is via the `ReservationLinkage` child table, but this column also exists. |
| `InitialApproverAliasId` | int (FK, NULL) | FK → PersonAlias. Filled when the Initial approval stage completes. |
| `InitialApprovalDateTime` | datetime | When initial approval happened. |
| `SpecialApproverAliasId` | int (FK, NULL) | FK → PersonAlias. Filled for reservations that required Special (e.g., override) approval. |
| `SpecialApprovalDateTime` | datetime | When special approval happened. |
| `FinalApproverAliasId` | int (FK, NULL) | FK → PersonAlias. Filled when the Final approval stage completes (the reservation reaches `Approved`). |
| `FinalApprovalDateTime` | datetime | When final approval happened. |

### Foreign keys

| Column | References |
|---|---|
| `ScheduleId` | [Schedule](../../../../rock-sql-schema/references/database-structure-tables.md#schedule) |
| `CampusId` | [Campus](../../../../rock-sql-schema/references/Campus.md) |
| `ReservationMinistryId` | [ReservationMinistry](#reservationministry) |
| `ReservationTypeId` | [ReservationType](#reservationtype) |
| `SetupPhotoId` | BinaryFile *(core Rock, not yet documented in `skills/rock-sql-schema/references/`)* |
| `RequesterAliasId`, `ApproverAliasId`, `EventContactPersonAliasId`, `AdministrativeContactPersonAliasId`, `InitialApproverAliasId`, `SpecialApproverAliasId`, `FinalApproverAliasId`, `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

### Approval flow

The three approval columns map to `ReservationApprovalState` transitions driven by `ReservationType` and `ReservationApprovalGroup` (see [Reservation-Workflow.md](Reservation-Workflow.md)):

```
Draft
  └──→ PendingInitialApproval ──(InitialApproverAliasId + InitialApprovalDateTime set)──→ PendingFinalApproval
                                                                                              │
       or ──→ ChangesNeeded                                                                   │
       or ──→ PendingSpecialApproval ──(SpecialApprover set)──────────────────────────────────┤
                                                                                              ▼
                                                                                          Approved
                                                                                           (FinalApproverAliasId +
                                                                                            FinalApprovalDateTime set)
       or ──→ Denied
       or ──→ Cancelled
```

---

## ReservationType

Configuration for a class of reservations. Drives whose approval is required (`InitialApprovalGroup`, `FinalApprovalGroup`, `OverrideApprovalGroup`), what's required on the form (`IsNumberAttendingRequired`, `IsContactDetailsRequired`, `IsSetupTimeRequired`, `IsCampusRequired`), and duration limits.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationType](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [IsSystem] [bit] NOT NULL,
    [Name] [nvarchar](50) NULL,
    [Description] [nvarchar](max) NULL,
    [IsActive] [bit] NOT NULL,
    [IconCssClass] [nvarchar](50) NULL,
    [FinalApprovalGroupId] [int] NULL,
    [SuperAdminGroupId] [int] NULL,
    [DefaultSetupTime] [int] NULL,
    [IsNumberAttendingRequired] [bit] NOT NULL,
    [IsContactDetailsRequired] [bit] NOT NULL,
    [IsSetupTimeRequired] [bit] NOT NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL,
    [IsReservationBookedOnApproval] [bit] NOT NULL,
    [DefaultCleanupTime] [int] NULL,
    [OverrideApprovalGroupId] [int] NULL,
    [InitialApprovalGroupId] [int] NULL,
    [IsCampusRequired] [bit] NOT NULL,
    [ContactPhoneTypeValueId] [int] NULL,
    [MaximumReservationDuration] [int] NULL,
    [DefaultReservationDuration] [int] NOT NULL,
    [LocationRequirement] [int] NULL,
    [ResourceRequirement] [int] NULL,
    [DisplayReservationDoorLockSchedules] [bit] NOT NULL,
    [DoorLockInstructions] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationType]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationType] PRIMARY KEY CLUSTERED ([Id] ASC)
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationType] ADD DEFAULT ((0)) FOR [IsReservationBookedOnApproval];
ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationType] ADD DEFAULT ((0)) FOR [DisplayReservationDoorLockSchedules];
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `IsSystem` | bit | Locks editing from the admin UI. |
| `Name` | nvarchar(50) | Display name of the reservation type. |
| `Description` | nvarchar(max) | Longer description. |
| `IsActive` | bit | Whether this type is available to requesters. |
| `IconCssClass` | nvarchar(50) | CSS icon class displayed next to the type name in the UI. |
| `FinalApprovalGroupId` | int (FK, NULL) | FK → [Group](../../../../rock-sql-schema/references/Group.md). Members of this group are the default **final** approvers. See also the per-campus overrides in [ReservationApprovalGroup](Reservation-Workflow.md#reservationapprovalgroup). |
| `SuperAdminGroupId` | int (FK, NULL) | FK → Group. Super-admin override group. |
| `DefaultSetupTime` | int | Default `SetupTime` applied to new reservations of this type. |
| `IsNumberAttendingRequired` | bit | If 1, `Reservation.NumberAttending` is required. |
| `IsContactDetailsRequired` | bit | If 1, event contact / admin contact details are required. |
| `IsSetupTimeRequired` | bit | If 1, setup time is required. |
| `Guid`, `CreatedDateTime`, `ModifiedDateTime`, `CreatedByPersonAliasId`, `ModifiedByPersonAliasId`, `ForeignKey`, `ForeignGuid`, `ForeignId` | — | Standard Rock fields. |
| `IsReservationBookedOnApproval` | bit (default 0) | If 1, the reservation's Location block is "booked" the moment approval lands (vs. booked on creation). |
| `DefaultCleanupTime` | int | Default `CleanupTime` applied to new reservations. |
| `OverrideApprovalGroupId` | int (FK, NULL) | FK → Group. Members who can override and approve regardless of other rules. |
| `InitialApprovalGroupId` | int (FK, NULL) | FK → Group. Members of this group handle the **initial** approval stage. |
| `IsCampusRequired` | bit | If 1, `Reservation.CampusId` is required. |
| `ContactPhoneTypeValueId` | int (NULL) | Points to a [DefinedValue](../../../../rock-sql-schema/references/database-structure-tables.md#definedvalue) (phone-number-type) used by the block when capturing contact phone. |
| `MaximumReservationDuration` | int (NULL) | Cap on total duration (minutes). |
| `DefaultReservationDuration` | int (NOT NULL) | Default duration in minutes. |
| `LocationRequirement` | int (NULL) | Enum `ReservationTypeRequirement`: 0=Hide, 1=Allow, 2=Require. Governs whether the Location picker is shown / required. |
| `ResourceRequirement` | int (NULL) | Same enum as above — governs the Resource picker. |
| `DisplayReservationDoorLockSchedules` | bit (default 0) | If 1, the door-lock schedule UI appears on the reservation form. |
| `DoorLockInstructions` | nvarchar(max) | Instructions shown above the door-lock editor. |

### Foreign keys

| Column | References |
|---|---|
| `FinalApprovalGroupId`, `InitialApprovalGroupId`, `OverrideApprovalGroupId`, `SuperAdminGroupId` | [Group](../../../../rock-sql-schema/references/Group.md) |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |
| `ContactPhoneTypeValueId` | [DefinedValue](../../../../rock-sql-schema/references/database-structure-tables.md#definedvalue) *(no FK constraint — referenced by `DefinedValueField` block attributes)* |

> The SQL doesn't constrain `ContactPhoneTypeValueId` to `DefinedValue.Id`; enforcement lives in C#.

---

## ReservationMinistry

Per-ReservationType classification "ministries" (a lookup list scoped to a ReservationType). Each Reservation may pick at most one.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationMinistry](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Name] [nvarchar](50) NULL,
    [Description] [nvarchar](1) NULL,
    [Order] [int] NOT NULL,
    [IsActive] [bit] NOT NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL,
    [ReservationTypeId] [int] NOT NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationMinistry]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationMinistry] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `Name` | nvarchar(50) | Display name. |
| `Description` | **nvarchar(1)** | ⚠ Appears to be a schema bug — the column is sized at 1 character. Effectively unused; treat as "not a real description field". |
| `Order` | int | Sort order in pickers. |
| `IsActive` | bit | Whether it appears in pickers. |
| `Guid`, audit columns | — | Standard Rock. |
| `ReservationTypeId` | int (FK, NOT NULL) | FK → [ReservationType](#reservationtype). A ministry is scoped to one type. |

### Foreign keys

| Column | References |
|---|---|
| `ReservationTypeId` | [ReservationType](#reservationtype) |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

---

## ReservationLocation

Child of Reservation. One row per room/location the reservation uses. Includes its own approval state (so a reservation can be partially approved for some rooms, pending on others) and an optional `LocationLayoutId` pointer.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationLocation](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ReservationId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL,
    [ApprovalState] [int] NOT NULL,
    [LocationLayoutId] [int] NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationLocation]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationLocation] PRIMARY KEY CLUSTERED ([Id] ASC)
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationLocation] ADD DEFAULT ((1)) FOR [ApprovalState];
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `ReservationId` | int (FK, NOT NULL) | FK → [Reservation](#reservation). |
| `LocationId` | int (FK, NOT NULL) | FK → [Location](../../../../rock-sql-schema/references/database-structure-tables.md#location). `ON DELETE CASCADE`. |
| `Guid`, audit columns | — | Standard Rock. |
| `ApprovalState` | int (NOT NULL, default 1) | Enum `ReservationLocationApprovalState`: **1=Unapproved, 2=Approved, 3=Denied** (1-indexed — there is no `0`). Per-location approval within the parent reservation. **Not the same enum as the parent `Reservation.ApprovalState`** despite `Approved=2` and `Denied=3` overlapping; see [ApprovalState-Enums.md](../ApprovalState-Enums.md). |
| `LocationLayoutId` | int (FK, NULL) | FK → [LocationLayout](Resource-and-Layout.md#locationlayout). Optional layout preset selected for this location. |

### Foreign keys

| Column | References |
|---|---|
| `ReservationId` | [Reservation](#reservation) |
| `LocationId` | [Location](../../../../rock-sql-schema/references/database-structure-tables.md#location) *(CASCADE)* |
| `LocationLayoutId` | [LocationLayout](Resource-and-Layout.md#locationlayout) |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

---

## ReservationLocationType

Junction between ReservationType and Location *type* (via DefinedValue). Filters which kinds of Locations are bookable for a given ReservationType.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationLocationType](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ReservationTypeId] [int] NOT NULL,
    [LocationTypeValueId] [int] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [ForeignKey] [nvarchar](100) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationLocationType]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationLocationType] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `ReservationTypeId` | int (FK, NOT NULL) | FK → [ReservationType](#reservationtype). |
| `LocationTypeValueId` | int (FK, NOT NULL) | FK → [DefinedValue](../../../../rock-sql-schema/references/database-structure-tables.md#definedvalue) (typically from the Location Type DefinedType). `ON DELETE CASCADE`. **Note:** The XML summary calls this "workflow type identifier", but the name and FK show it's the location-type DefinedValue. |
| Audit columns | — | Standard Rock. |

### Foreign keys

| Column | References |
|---|---|
| `ReservationTypeId` | [ReservationType](#reservationtype) |
| `LocationTypeValueId` | [DefinedValue](../../../../rock-sql-schema/references/database-structure-tables.md#definedvalue) *(CASCADE)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

---

## ReservationResource

Child of Reservation (and optionally of a specific ReservationLocation). One row per resource instance used by the reservation, with its own approval state and quantity.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationResource](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ReservationId] [int] NOT NULL,
    [ResourceId] [int] NOT NULL,
    [Quantity] [int] NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL,
    [ApprovalState] [int] NOT NULL,
    [ReservationLocationId] [int] NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationResource]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationResource] PRIMARY KEY CLUSTERED ([Id] ASC)
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationResource] ADD DEFAULT ((1)) FOR [ApprovalState];
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `ReservationId` | int (FK, NOT NULL) | FK → [Reservation](#reservation). |
| `ResourceId` | int (FK, NOT NULL) | FK → [Resource](Resource-and-Layout.md#resource). |
| `Quantity` | int (NULL) | How many of the Resource this reservation needs. |
| `Guid`, audit columns | — | Standard Rock. |
| `ApprovalState` | int (NOT NULL, default 1) | Enum `ReservationResourceApprovalState`: **1=Unapproved, 2=Approved, 3=Denied** (1-indexed — there is no `0`). **Same shape as `ReservationLocationApprovalState`, distinct from the parent `Reservation.ApprovalState`.** See [ApprovalState-Enums.md](../ApprovalState-Enums.md). |
| `ReservationLocationId` | int (FK, NULL) | FK → [ReservationLocation](#reservationlocation). When set, ties the resource to a specific location in the reservation (e.g., "these mics go in Room A"). `ON DELETE CASCADE`. NULL = resource is unassigned to a specific location. |

### Foreign keys

| Column | References |
|---|---|
| `ReservationId` | [Reservation](#reservation) |
| `ResourceId` | [Resource](Resource-and-Layout.md#resource) |
| `ReservationLocationId` | [ReservationLocation](#reservationlocation) *(CASCADE)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

---

## ReservationDoorLockSchedule

Optional child of Reservation. Describes door-unlock/lock offsets (in minutes) relative to the reservation window. Used by facilities teams to coordinate automated door access.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationDoorLockSchedule](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ReservationId] [int] NOT NULL,
    [StartTimeOffset] [int] NOT NULL,
    [EndTimeOffset] [int] NOT NULL,
    [Note] [nvarchar](max) NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_ReservationDoorLockSchedule]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_ReservationDoorLockSchedule] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `ReservationId` | int (FK, NOT NULL) | FK → [Reservation](#reservation). `ON DELETE CASCADE`. |
| `StartTimeOffset` | int | Offset (minutes) from the reservation start at which the door should unlock. Negative = before start. |
| `EndTimeOffset` | int | Offset (minutes) from the reservation end at which the door should lock. Positive = after end. |
| `Note` | nvarchar(max) | Free-form note for facilities staff. |
| `Guid`, audit columns | — | Standard Rock. |

### Foreign keys

| Column | References |
|---|---|
| `ReservationId` | [Reservation](#reservation) *(CASCADE)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

### Gated by ReservationType

The door-lock UI only appears when `ReservationType.DisplayReservationDoorLockSchedules = 1`. Content in `ReservationType.DoorLockInstructions` is shown above the door-lock editor.
