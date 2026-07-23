# GroupLocation and Schedule

Where and when groups meet — locations, schedules, and exclusions.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## GroupScheduleExclusion
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupScheduleExclusion](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupTypeId] [int] NOT NULL,

[StartDate] [date] NULL,

[EndDate] [date] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupScheduleExclusion] ADD CONSTRAINT [PK_dbo.GroupScheduleExclusion] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupScheduleExclusion]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[GroupScheduleExclusion]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupScheduleExclusion]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupScheduleExclusion]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupScheduleExclusion] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupScheduleExclusion_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupScheduleExclusion] CHECK CONSTRAINT [FK_dbo.GroupScheduleExclusion_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[GroupScheduleExclusion] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupScheduleExclusion_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupScheduleExclusion] CHECK CONSTRAINT [FK_dbo.GroupScheduleExclusion_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupScheduleExclusion] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupScheduleExclusion_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupScheduleExclusion] CHECK CONSTRAINT [FK_dbo.GroupScheduleExclusion_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## GroupLocation
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupLocation](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupId] [int] NOT NULL,

[LocationId] [int] NOT NULL,

[GroupLocationTypeValueId] [int] NULL,

[IsMailingLocation] [bit] NOT NULL,

[IsMappedLocation] [bit] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[GroupMemberPersonAliasId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[Order] [int] NOT NULL,

[IsOverflowLocation] [bit] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocation] ADD CONSTRAINT [PK_dbo.GroupLocation] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupLocation]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[GroupLocation]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupLocationTypeValueId] ON [dbo].[GroupLocation]

(

[GroupLocationTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupMemberPersonAliasId] ON [dbo].[GroupLocation]

(

[GroupMemberPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupLocation]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LocationId] ON [dbo].[GroupLocation]

(

[LocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupLocation]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocation] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[GroupLocation] ADD DEFAULT ((0)) FOR [IsOverflowLocation]

GO

ALTER TABLE [dbo].[GroupLocation] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocation_dbo.DefinedValue_GroupLocationTypeValueId] FOREIGN KEY([GroupLocationTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[GroupLocation] CHECK CONSTRAINT [FK_dbo.GroupLocation_dbo.DefinedValue_GroupLocationTypeValueId]

GO

ALTER TABLE [dbo].[GroupLocation] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocation_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocation] CHECK CONSTRAINT [FK_dbo.GroupLocation_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupLocation] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocation_dbo.Location_LocationId] FOREIGN KEY([LocationId])

REFERENCES [dbo].[Location] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocation] CHECK CONSTRAINT [FK_dbo.GroupLocation_dbo.Location_LocationId]

GO

ALTER TABLE [dbo].[GroupLocation] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocation_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupLocation] CHECK CONSTRAINT [FK_dbo.GroupLocation_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupLocation] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocation_dbo.PersonAlias_GroupMemberPersonAliasId] FOREIGN KEY([GroupMemberPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocation] CHECK CONSTRAINT [FK_dbo.GroupLocation_dbo.PersonAlias_GroupMemberPersonAliasId]

GO

ALTER TABLE [dbo].[GroupLocation] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocation_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupLocation] CHECK CONSTRAINT [FK_dbo.GroupLocation_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## GroupLocationHistorical
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupLocationHistorical](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupLocationId] [int] NULL,

[GroupId] [int] NOT NULL,

[GroupLocationTypeValueId] [int] NULL,

[GroupLocationTypeName] [nvarchar](250) NULL,

[LocationId] [int] NOT NULL,

[LocationName] [nvarchar](max) NULL,

[LocationModifiedDateTime] [datetime] NULL,

[EffectiveDateTime] [datetime] NOT NULL,

[ExpireDateTime] [datetime] NOT NULL,

[CurrentRowIndicator] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocationHistorical] ADD CONSTRAINT [PK_dbo.GroupLocationHistorical] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupLocationHistorical]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[GroupLocationHistorical]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupLocationId] ON [dbo].[GroupLocationHistorical]

(

[GroupLocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupLocationHistorical]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LocationId] ON [dbo].[GroupLocationHistorical]

(

[LocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_LocationIdCurrentRow] ON [dbo].[GroupLocationHistorical]

(

[GroupLocationId] ASC,

[CurrentRowIndicator] ASC

)

WHERE ([CurrentRowIndicator]=(1))

WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupLocationHistorical]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocationHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[GroupLocationHistorical] CHECK CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupLocationHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.GroupLocation_GroupLocationId] FOREIGN KEY([GroupLocationId])

REFERENCES [dbo].[GroupLocation] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocationHistorical] CHECK CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.GroupLocation_GroupLocationId]

GO

ALTER TABLE [dbo].[GroupLocationHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.Location_LocationId] FOREIGN KEY([LocationId])

REFERENCES [dbo].[Location] ([Id])

GO

ALTER TABLE [dbo].[GroupLocationHistorical] CHECK CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.Location_LocationId]

GO

ALTER TABLE [dbo].[GroupLocationHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupLocationHistorical] CHECK CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupLocationHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupLocationHistorical] CHECK CONSTRAINT [FK_dbo.GroupLocationHistorical_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## GroupLocationHistoricalSchedule
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupLocationHistoricalSchedule](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupLocationHistoricalId] [int] NOT NULL,

[ScheduleId] [int] NOT NULL,

[ScheduleName] [nvarchar](max) NULL,

[ScheduleModifiedDateTime] [datetime] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocationHistoricalSchedule] ADD CONSTRAINT [PK_dbo.GroupLocationHistoricalSchedule] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupLocationHistoricalId] ON [dbo].[GroupLocationHistoricalSchedule]

(

[GroupLocationHistoricalId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupLocationHistoricalSchedule]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[GroupLocationHistoricalSchedule]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocationHistoricalSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationHistoricalSchedule_dbo.GroupLocationHistorical_GroupLocationHistoricalId] FOREIGN KEY([GroupLocationHistoricalId])

REFERENCES [dbo].[GroupLocationHistorical] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocationHistoricalSchedule] CHECK CONSTRAINT [FK_dbo.GroupLocationHistoricalSchedule_dbo.GroupLocationHistorical_GroupLocationHistoricalId]

GO

ALTER TABLE [dbo].[GroupLocationHistoricalSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationHistoricalSchedule_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

GO

ALTER TABLE [dbo].[GroupLocationHistoricalSchedule] CHECK CONSTRAINT [FK_dbo.GroupLocationHistoricalSchedule_dbo.Schedule_ScheduleId]

GO
```


## GroupLocationSchedule
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupLocationSchedule](

[GroupLocationId] [int] NOT NULL,

[ScheduleId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocationSchedule] ADD CONSTRAINT [PK_dbo.GroupLocationSchedule] PRIMARY KEY CLUSTERED

(

[GroupLocationId] ASC,

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupLocationId] ON [dbo].[GroupLocationSchedule]

(

[GroupLocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[GroupLocationSchedule]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocationSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationSchedule_dbo.GroupLocation_GroupLocationId] FOREIGN KEY([GroupLocationId])

REFERENCES [dbo].[GroupLocation] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocationSchedule] CHECK CONSTRAINT [FK_dbo.GroupLocationSchedule_dbo.GroupLocation_GroupLocationId]

GO

ALTER TABLE [dbo].[GroupLocationSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationSchedule_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocationSchedule] CHECK CONSTRAINT [FK_dbo.GroupLocationSchedule_dbo.Schedule_ScheduleId]

GO
```


## GroupLocationScheduleConfig
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupLocationScheduleConfig](

[GroupLocationId] [int] NOT NULL,

[ScheduleId] [int] NOT NULL,

[MinimumCapacity] [int] NULL,

[DesiredCapacity] [int] NULL,

[MaximumCapacity] [int] NULL,

[ConfirmationAdditionalDetails] [nvarchar](max) NULL,

[ConfigurationName] [nvarchar](100) NULL,

[ReminderAdditionalDetails] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocationScheduleConfig] ADD CONSTRAINT [PK_dbo.GroupLocationScheduleConfig] PRIMARY KEY CLUSTERED

(

[GroupLocationId] ASC,

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupLocationId] ON [dbo].[GroupLocationScheduleConfig]

(

[GroupLocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[GroupLocationScheduleConfig]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupLocationScheduleConfig] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationScheduleConfig_dbo.GroupLocation_GroupLocationId] FOREIGN KEY([GroupLocationId])

REFERENCES [dbo].[GroupLocation] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocationScheduleConfig] CHECK CONSTRAINT [FK_dbo.GroupLocationScheduleConfig_dbo.GroupLocation_GroupLocationId]

GO

ALTER TABLE [dbo].[GroupLocationScheduleConfig] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupLocationScheduleConfig_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupLocationScheduleConfig] CHECK CONSTRAINT [FK_dbo.GroupLocationScheduleConfig_dbo.Schedule_ScheduleId]

GO
```