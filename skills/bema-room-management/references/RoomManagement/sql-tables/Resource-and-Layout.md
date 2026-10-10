# Resource and Layout

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Two independently-configurable master tables:

- **Resource** — anything reservable that isn't a room (audio gear, chairs, projectors, vehicles, etc.). Reusable across many reservations.
- **LocationLayout** — per-Location layout presets (e.g., "Theater / 200 chairs" vs. "Round tables / 120 people" for the same room). A `ReservationLocation` can select one of the parent Location's layouts.

---

## Resource

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_Resource](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Name] [nvarchar](50) NULL,
    [CategoryId] [int] NULL,
    [CampusId] [int] NULL,
    [Quantity] [int] NULL,
    [Note] [nvarchar](2000) NULL,
    [Guid] [uniqueidentifier] NOT NULL,
    [CreatedDateTime] [datetime] NULL,
    [ModifiedDateTime] [datetime] NULL,
    [CreatedByPersonAliasId] [int] NULL,
    [ModifiedByPersonAliasId] [int] NULL,
    [ForeignKey] [nvarchar](50) NULL,
    [ForeignGuid] [uniqueidentifier] NULL,
    [ForeignId] [int] NULL,
    [ApprovalGroupId] [int] NULL,
    [LocationId] [int] NULL,
    [IsActive] [bit] NULL,
    [PhotoId] [int] NULL
) ON [PRIMARY]
;

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_Resource]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_Resource] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `Name` | nvarchar(50) | Display name of the resource. |
| `CategoryId` | int (FK, NULL) | FK → [Category](../../../../rock-sql-schema/references/Category.md). Category tree the resource lives in (useful for the Resource picker UX). |
| `CampusId` | int (FK, NULL) | FK → [Campus](../../../../rock-sql-schema/references/Campus.md). NULL = resource is available to all campuses. |
| `Quantity` | int (NULL) | Total quantity owned (e.g., 50 chairs, 2 mics). The `ReservationResource.Quantity` column records how many of this pool are reserved per reservation. |
| `Note` | nvarchar(2000) | Free-form internal note about the resource. |
| `Guid`, audit columns | — | Standard Rock. |
| `ApprovalGroupId` | int (FK, NULL) | FK → [Group](../../../../rock-sql-schema/references/Group.md). Members of this group act as the approvers for reservations that include this resource. |
| `LocationId` | int (FK, NULL) | FK → [Location](../../../../rock-sql-schema/references/database-structure-tables.md#location). Optional "home" location the resource lives in. |
| `IsActive` | bit (NULL) | Whether the resource is available in pickers. |
| `PhotoId` | int (FK, NULL) | FK → BinaryFile. Photo of the resource (displayed in the ResourceDetail block). |

### Foreign keys

| Column | References |
|---|---|
| `CategoryId` | [Category](../../../../rock-sql-schema/references/Category.md) |
| `CampusId` | [Campus](../../../../rock-sql-schema/references/Campus.md) |
| `ApprovalGroupId` | [Group](../../../../rock-sql-schema/references/Group.md) |
| `LocationId` | [Location](../../../../rock-sql-schema/references/database-structure-tables.md#location) |
| `PhotoId` | BinaryFile *(core Rock, not yet documented in `skills/rock-sql-schema/references/`)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

> The FK `FK__com_bemaservices_RoomManagement_Reservation_Photo` is named after the Reservation table but is actually on `Resource.PhotoId` — likely a copy-paste naming bug in the plugin's migration. The constraint itself correctly references `BinaryFile`.

---

## LocationLayout

Per-Location layout presets. A Location can have 0..N layouts (e.g., "Theater", "Banquet Rounds", "Classroom"), one of which can be the default. A `ReservationLocation.LocationLayoutId` picks one for a specific reservation.

```sql
CREATE TABLE [dbo].[_com_bemaservices_RoomManagement_LocationLayout](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [IsSystem] [bit] NOT NULL,
    [LocationId] [int] NOT NULL,
    [Name] [nvarchar](50) NULL,
    [Description] [nvarchar](max) NULL,
    [IsActive] [bit] NOT NULL,
    [IsDefault] [bit] NOT NULL,
    [LayoutPhotoId] [int] NULL,
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

ALTER TABLE [dbo].[_com_bemaservices_RoomManagement_LocationLayout]
    ADD CONSTRAINT [PK__com_bemaservices_RoomManagement_LocationLayout] PRIMARY KEY CLUSTERED ([Id] ASC)
;
```

### Columns

| Column | Type | Notes |
|---|---|---|
| `Id` | int (PK, identity) | Primary key. |
| `IsSystem` | bit | Locks editing from the admin UI. |
| `LocationId` | int (FK, NOT NULL) | FK → [Location](../../../../rock-sql-schema/references/database-structure-tables.md#location). The Location this layout applies to. |
| `Name` | nvarchar(50) | Display name (e.g., "Theater"). |
| `Description` | nvarchar(max) | Longer description. |
| `IsActive` | bit | Whether the layout shows up in pickers. |
| `IsDefault` | bit | If 1, this layout is pre-selected when a reservation picks this Location. |
| `LayoutPhotoId` | int (FK, NULL) | FK → BinaryFile. Optional photo/diagram of the layout (displayed at the BlockAttribute-configured height on the `LocationLayoutList` block). |
| `Guid`, audit columns | — | Standard Rock. |

### Foreign keys

| Column | References |
|---|---|
| `LocationId` | [Location](../../../../rock-sql-schema/references/database-structure-tables.md#location) |
| `LayoutPhotoId` | BinaryFile *(core Rock, not yet documented in `skills/rock-sql-schema/references/`)* |
| `CreatedByPersonAliasId`, `ModifiedByPersonAliasId` | [PersonAlias](../../../../rock-sql-schema/references/Person-and-PersonAlias.md#personalias) |

### Uniqueness is not enforced at DB level

There is no DB constraint preventing two layouts on the same Location from both being `IsDefault = 1`. The admin UI is expected to enforce "at most one default" by flipping the previous default off when a new default is saved.
