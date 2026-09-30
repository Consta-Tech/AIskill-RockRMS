# Campus

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Campus definitions, schedules, and topics.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## Campus
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Campus](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[ShortCode] [nvarchar](50) NULL,

[LocationId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[PhoneNumber] [nvarchar](max) NULL,

[LeaderPersonAliasId] [int] NULL,

[ServiceTimes] [nvarchar](500) NULL,

[Description] [nvarchar](max) NULL,

[IsActive] [bit] NULL,

[Url] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[Order] [int] NOT NULL,

[TimeZoneId] [nvarchar](50) NULL,

[CampusStatusValueId] [int] NULL,

[CampusTypeValueId] [int] NULL,

[TeamGroupId] [int] NULL,

[OpenedDate] [date] NULL,

[ClosedDate] [date] NULL,

[TitheMetric] [decimal](8, 2) NULL,

[BeaconId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Campus] ADD CONSTRAINT [PK_dbo.Campus] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusStatusValueId] ON [dbo].[Campus]

(

[CampusStatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusTypeValueId] ON [dbo].[Campus]

(

[CampusTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Campus]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Campus]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LeaderPersonAliasId] ON [dbo].[Campus]

(

[LeaderPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LocationId] ON [dbo].[Campus]

(

[LocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Campus]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Name] ON [dbo].[Campus]

(

[Name] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TeamGroupId] ON [dbo].[Campus]

(

[TeamGroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Campus] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[Campus] WITH CHECK ADD CONSTRAINT [FK_dbo.Campus_dbo.DefinedValue_CampusStatusValueId] FOREIGN KEY([CampusStatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Campus] CHECK CONSTRAINT [FK_dbo.Campus_dbo.DefinedValue_CampusStatusValueId]

GO

ALTER TABLE [dbo].[Campus] WITH CHECK ADD CONSTRAINT [FK_dbo.Campus_dbo.DefinedValue_CampusTypeValueId] FOREIGN KEY([CampusTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Campus] CHECK CONSTRAINT [FK_dbo.Campus_dbo.DefinedValue_CampusTypeValueId]

GO

ALTER TABLE [dbo].[Campus] WITH CHECK ADD CONSTRAINT [FK_dbo.Campus_dbo.Group_TeamGroupId] FOREIGN KEY([TeamGroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[Campus] CHECK CONSTRAINT [FK_dbo.Campus_dbo.Group_TeamGroupId]

GO

ALTER TABLE [dbo].[Campus] WITH CHECK ADD CONSTRAINT [FK_dbo.Campus_dbo.Location_LocationId] FOREIGN KEY([LocationId])

REFERENCES [dbo].[Location] ([Id])

GO

ALTER TABLE [dbo].[Campus] CHECK CONSTRAINT [FK_dbo.Campus_dbo.Location_LocationId]

GO

ALTER TABLE [dbo].[Campus] WITH CHECK ADD CONSTRAINT [FK_dbo.Campus_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Campus] CHECK CONSTRAINT [FK_dbo.Campus_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Campus] WITH CHECK ADD CONSTRAINT [FK_dbo.Campus_dbo.PersonAlias_LeaderPersonAliasId] FOREIGN KEY([LeaderPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Campus] CHECK CONSTRAINT [FK_dbo.Campus_dbo.PersonAlias_LeaderPersonAliasId]

GO

ALTER TABLE [dbo].[Campus] WITH CHECK ADD CONSTRAINT [FK_dbo.Campus_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Campus] CHECK CONSTRAINT [FK_dbo.Campus_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## CampusSchedule
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CampusSchedule](

[Id] [int] IDENTITY(1,1) NOT NULL,

[CampusId] [int] NOT NULL,

[ScheduleId] [int] NOT NULL,

[ScheduleTypeValueId] [int] NOT NULL,

[Order] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CampusSchedule] ADD CONSTRAINT [PK_dbo.CampusSchedule] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[CampusSchedule]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[CampusSchedule]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[CampusSchedule]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[CampusSchedule]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[CampusSchedule]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleTypeValueId] ON [dbo].[CampusSchedule]

(

[ScheduleTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CampusSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusSchedule_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[CampusSchedule] CHECK CONSTRAINT [FK_dbo.CampusSchedule_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[CampusSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusSchedule_dbo.DefinedValue_ScheduleTypeValueId] FOREIGN KEY([ScheduleTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[CampusSchedule] CHECK CONSTRAINT [FK_dbo.CampusSchedule_dbo.DefinedValue_ScheduleTypeValueId]

GO

ALTER TABLE [dbo].[CampusSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusSchedule_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[CampusSchedule] CHECK CONSTRAINT [FK_dbo.CampusSchedule_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[CampusSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusSchedule_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[CampusSchedule] CHECK CONSTRAINT [FK_dbo.CampusSchedule_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[CampusSchedule] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusSchedule_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[CampusSchedule] CHECK CONSTRAINT [FK_dbo.CampusSchedule_dbo.Schedule_ScheduleId]

GO
```


## CampusTopic
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CampusTopic](

[Id] [int] IDENTITY(1,1) NOT NULL,

[TopicTypeValueId] [int] NOT NULL,

[Email] [nvarchar](254) NULL,

[IsPublic] [bit] NOT NULL,

[CampusId] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CampusTopic] ADD CONSTRAINT [PK_dbo.CampusTopic] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[CampusTopic]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[CampusTopic]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[CampusTopic]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[CampusTopic]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TopicTypeValueId] ON [dbo].[CampusTopic]

(

[TopicTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CampusTopic] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusTopic_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[CampusTopic] CHECK CONSTRAINT [FK_dbo.CampusTopic_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[CampusTopic] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusTopic_dbo.DefinedValue_TopicTypeValueId] FOREIGN KEY([TopicTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[CampusTopic] CHECK CONSTRAINT [FK_dbo.CampusTopic_dbo.DefinedValue_TopicTypeValueId]

GO

ALTER TABLE [dbo].[CampusTopic] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusTopic_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[CampusTopic] CHECK CONSTRAINT [FK_dbo.CampusTopic_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[CampusTopic] WITH CHECK ADD CONSTRAINT [FK_dbo.CampusTopic_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[CampusTopic] CHECK CONSTRAINT [FK_dbo.CampusTopic_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```