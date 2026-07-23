# Location

Physical or virtual places in the campus/building hierarchy. Locations form a tree via `[ParentLocationId]`, support geocoded addresses + GeoPoint/GeoFence shapes, and carry room-specific metadata (capacity thresholds, printer device, beacon).

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## Location
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Location](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ParentLocationId] [int] NULL,

[Name] [nvarchar](100) NULL,

[IsActive] [bit] NOT NULL,

[LocationTypeValueId] [int] NULL,

[GeoPoint] [geography] NULL,

[GeoFence] [geography] NULL,

[Street1] [nvarchar](100) NULL,

[Street2] [nvarchar](100) NULL,

[City] [nvarchar](50) NULL,

[State] [nvarchar](50) NULL,

[Country] [nvarchar](50) NULL,

[AssessorParcelId] [nvarchar](50) NULL,

[StandardizeAttemptedDateTime] [datetime] NULL,

[StandardizeAttemptedServiceType] [nvarchar](50) NULL,

[StandardizeAttemptedResult] [nvarchar](200) NULL,

[StandardizedDateTime] [datetime] NULL,

[GeocodeAttemptedDateTime] [datetime] NULL,

[GeocodeAttemptedServiceType] [nvarchar](50) NULL,

[GeocodeAttemptedResult] [nvarchar](200) NULL,

[GeocodedDateTime] [datetime] NULL,

[PrinterDeviceId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[IsGeoPointLocked] [bit] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ImageId] [int] NULL,

[PostalCode] [nvarchar](50) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[County] [nvarchar](50) NULL,

[Barcode] [nvarchar](40) NULL,

[SoftRoomThreshold] [int] NULL,

[FirmRoomThreshold] [int] NULL,

[BeaconId] [int] NULL,

[Description] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Location] ADD  CONSTRAINT [PK_dbo.Location] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Location]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Location]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ImageId] ON [dbo].[Location]

(

[ImageId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LocationTypeValueId] ON [dbo].[Location]

(

[LocationTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Location]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ParentLocationId] ON [dbo].[Location]

(

[ParentLocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PrinterDeviceId] ON [dbo].[Location]

(

[PrinterDeviceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Location_dbo.BinaryFile_ImageId] FOREIGN KEY([ImageId])

REFERENCES [dbo].[BinaryFile] ([Id])

GO

ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_dbo.Location_dbo.BinaryFile_ImageId]

GO

ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Location_dbo.DefinedValue_LocationTypeValueId] FOREIGN KEY([LocationTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_dbo.Location_dbo.DefinedValue_LocationTypeValueId]

GO

ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Location_dbo.Device_PrinterDeviceId] FOREIGN KEY([PrinterDeviceId])

REFERENCES [dbo].[Device] ([Id])

GO

ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_dbo.Location_dbo.Device_PrinterDeviceId]

GO

ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Location_dbo.Location_ParentLocationId] FOREIGN KEY([ParentLocationId])

REFERENCES [dbo].[Location] ([Id])

GO

ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_dbo.Location_dbo.Location_ParentLocationId]

GO

ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Location_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_dbo.Location_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Location_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_dbo.Location_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

SET ARITHABORT ON

SET CONCAT_NULL_YIELDS_NULL ON

SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS ON

SET ANSI_PADDING ON

SET ANSI_WARNINGS ON

SET NUMERIC_ROUNDABORT OFF

GO

CREATE SPATIAL INDEX [IX_GeoFence] ON [dbo].[Location]

(

[GeoFence]

)USING  GEOGRAPHY_GRID 

WITH (GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), 

CELLS_PER_OBJECT = 16, STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100) ON [PRIMARY]

GO

SET ARITHABORT ON

SET CONCAT_NULL_YIELDS_NULL ON

SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS ON

SET ANSI_PADDING ON

SET ANSI_WARNINGS ON

SET NUMERIC_ROUNDABORT OFF

GO

CREATE SPATIAL INDEX [IX_GeoPoint] ON [dbo].[Location]

(

[GeoPoint]

)USING  GEOGRAPHY_GRID 

WITH (GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), 

CELLS_PER_OBJECT = 16, STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100) ON [PRIMARY]

GO
```

---

## Gotchas

### `[Location]` has no `[CampusId]` column

The Campus → Location relationship goes the **other** direction:

- `[Campus].[LocationId]` (FK to `[Location].[Id]`) anchors each Campus at a root Location.
- Locations belonging to a Campus are descendants of that root, traversed via `[Location].[ParentLocationId]`.

C# convenience: `Location.CampusId` is computed in C# (e.g., via `LocationService.GetCampusForLocation`) by walking up the parent chain — it's not a DB column. Rock's own blocks (per `skills/rock-blocktypes/references/GroupAttendance.md`, "Campus filter" row) apply this post-query, not in SQL.

To filter Locations by Campus in SQL, use a recursive CTE that anchors at each `[Campus].[LocationId]` and descends via `[Location].[ParentLocationId]`:

```sql
WITH CampusLocationTree AS (
    --- Anchor: each Campus's root Location.
    SELECT
        c.[Id] AS "CampusId"
      , c.[Name] AS "CampusName"
      , l.[Id] AS "LocationId"
    FROM
        [Campus] c
        INNER JOIN [Location] l ON l.[Id] = c.[LocationId]
    UNION ALL
    --- Recursive: descend via [Location].[ParentLocationId]; carry the Campus tag down.
    SELECT clt.[CampusId], clt.[CampusName], l.[Id]
    FROM
        [Location] l
        INNER JOIN CampusLocationTree clt ON l.[ParentLocationId] = clt.[LocationId]
)
SELECT
    l.[Id] AS "LocationId"
  , l.[Name]
  , clt.[CampusId]
  , clt.[CampusName]
FROM
    [Location] l
    OUTER APPLY (
        --- TOP 1 guards against the rare case where a Location appears under multiple Campus
        --- subtrees (e.g., one Campus root nested inside another Campus's tree).
        SELECT TOP 1 [CampusId], [CampusName]
        FROM CampusLocationTree
        WHERE [LocationId] = l.[Id]
    ) clt
WHERE
    @CampusId = 0
    OR EXISTS (
        SELECT 1
        FROM CampusLocationTree clt2
        WHERE clt2.[LocationId] = l.[Id] AND clt2.[CampusId] = @CampusId
    )
OPTION (MAXRECURSION 32)
;
```

`OUTER APPLY (SELECT TOP 1 …)` ensures one row per Location for the display Campus tag even if the tree has multi-Campus weirdness; `EXISTS` does the actual filter.

Working example: `_code/LavaApplications/RoomManagement/Endpoints/_list-availableLocations.lava` (the `array_Locations` query).
