# CalendarEvent

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Event calendars, event definitions, audience targeting, campus-specific occurrences, content channel links, and registration/group mappings.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| EventCalendar | Calendar container for grouping events | — |
| EventItem | Defines an event with name, description, photo, and approval status | BinaryFile |
| EventCalendarContentChannel | Links a calendar to a content channel for publishing | EventCalendar (CASCADE), ContentChannel (CASCADE) |
| EventCalendarItem | Junction table placing an event on a calendar | EventCalendar (CASCADE), EventItem (CASCADE) |
| EventItemAudience | Target audience tags for an event | EventItem (CASCADE), DefinedValue |
| EventItemOccurrence | A specific campus/schedule instance of an event | EventItem (CASCADE), Campus, Schedule |
| EventItemOccurrenceChannelItem | Links an occurrence to a content channel item | EventItemOccurrence (CASCADE), ContentChannelItem (CASCADE) |
| EventItemOccurrenceGroupMap | Maps an occurrence to a registration instance, group, and campus | EventItemOccurrence (CASCADE), RegistrationInstance (CASCADE), Group (CASCADE), Campus (CASCADE) |

---

## EventCalendar
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EventCalendar](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[IconCssClass] [nvarchar](100) NULL,

[IsActive] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsIndexEnabled] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventCalendar] ADD  CONSTRAINT [PK_dbo.EventCalendar] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EventCalendar]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EventCalendar]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EventCalendar]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventCalendar] ADD  DEFAULT ((0)) FOR [IsIndexEnabled]

GO

ALTER TABLE [dbo].[EventCalendar]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendar_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventCalendar] CHECK CONSTRAINT [FK_dbo.EventCalendar_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventCalendar]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendar_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventCalendar] CHECK CONSTRAINT [FK_dbo.EventCalendar_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## EventItem
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EventItem](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Summary] [nvarchar](max) NULL,

[Description] [nvarchar](max) NULL,

[PhotoId] [int] NULL,

[DetailsUrl] [nvarchar](200) NULL,

[IsActive] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[IsApproved] [bit] NOT NULL,

[ApprovedByPersonAliasId] [int] NULL,

[ApprovedOnDateTime] [datetime] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventItem] ADD  CONSTRAINT [PK_dbo.EventItem] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ApprovedByPersonAliasId] ON [dbo].[EventItem]

(

[ApprovedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EventItem]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EventItem]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EventItem]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PhotoId] ON [dbo].[EventItem]

(

[PhotoId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventItem] ADD  DEFAULT ((0)) FOR [IsApproved]

GO

ALTER TABLE [dbo].[EventItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItem_dbo.BinaryFile_PhotoId] FOREIGN KEY([PhotoId])

REFERENCES [dbo].[BinaryFile] ([Id])

GO

ALTER TABLE [dbo].[EventItem] CHECK CONSTRAINT [FK_dbo.EventItem_dbo.BinaryFile_PhotoId]

GO

ALTER TABLE [dbo].[EventItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItem_dbo.PersonAlias_ApprovedByPersonAliasId] FOREIGN KEY([ApprovedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItem] CHECK CONSTRAINT [FK_dbo.EventItem_dbo.PersonAlias_ApprovedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItem_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItem] CHECK CONSTRAINT [FK_dbo.EventItem_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItem_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItem] CHECK CONSTRAINT [FK_dbo.EventItem_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## EventCalendarContentChannel
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EventCalendarContentChannel](

[Id] [int] IDENTITY(1,1) NOT NULL,

[EventCalendarId] [int] NOT NULL,

[ContentChannelId] [int] NOT NULL,

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

ALTER TABLE [dbo].[EventCalendarContentChannel] ADD  CONSTRAINT [PK_dbo.EventCalendarContentChannel] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ContentChannelId] ON [dbo].[EventCalendarContentChannel]

(

[ContentChannelId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EventCalendarContentChannel]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EventCalendarId] ON [dbo].[EventCalendarContentChannel]

(

[EventCalendarId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EventCalendarContentChannel]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EventCalendarContentChannel]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventCalendarContentChannel]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendarContentChannel_dbo.ContentChannel_ContentChannelId] FOREIGN KEY([ContentChannelId])

REFERENCES [dbo].[ContentChannel] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventCalendarContentChannel] CHECK CONSTRAINT [FK_dbo.EventCalendarContentChannel_dbo.ContentChannel_ContentChannelId]

GO

ALTER TABLE [dbo].[EventCalendarContentChannel]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendarContentChannel_dbo.EventCalendar_EventCalendarId] FOREIGN KEY([EventCalendarId])

REFERENCES [dbo].[EventCalendar] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventCalendarContentChannel] CHECK CONSTRAINT [FK_dbo.EventCalendarContentChannel_dbo.EventCalendar_EventCalendarId]

GO

ALTER TABLE [dbo].[EventCalendarContentChannel]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendarContentChannel_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventCalendarContentChannel] CHECK CONSTRAINT [FK_dbo.EventCalendarContentChannel_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventCalendarContentChannel]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendarContentChannel_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventCalendarContentChannel] CHECK CONSTRAINT [FK_dbo.EventCalendarContentChannel_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## EventCalendarItem
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EventCalendarItem](

[Id] [int] IDENTITY(1,1) NOT NULL,

[EventCalendarId] [int] NOT NULL,

[EventItemId] [int] NOT NULL,

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

ALTER TABLE [dbo].[EventCalendarItem] ADD  CONSTRAINT [PK_dbo.EventCalendarItem] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EventCalendarItem]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EventCalendarId] ON [dbo].[EventCalendarItem]

(

[EventCalendarId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EventItemId] ON [dbo].[EventCalendarItem]

(

[EventItemId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EventCalendarItem]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EventCalendarItem]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventCalendarItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendarItem_dbo.EventCalendar_EventCalendarId] FOREIGN KEY([EventCalendarId])

REFERENCES [dbo].[EventCalendar] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventCalendarItem] CHECK CONSTRAINT [FK_dbo.EventCalendarItem_dbo.EventCalendar_EventCalendarId]

GO

ALTER TABLE [dbo].[EventCalendarItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendarItem_dbo.EventItem_EventItemId] FOREIGN KEY([EventItemId])

REFERENCES [dbo].[EventItem] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventCalendarItem] CHECK CONSTRAINT [FK_dbo.EventCalendarItem_dbo.EventItem_EventItemId]

GO

ALTER TABLE [dbo].[EventCalendarItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendarItem_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventCalendarItem] CHECK CONSTRAINT [FK_dbo.EventCalendarItem_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventCalendarItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventCalendarItem_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventCalendarItem] CHECK CONSTRAINT [FK_dbo.EventCalendarItem_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## EventItemAudience
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EventItemAudience](

[Id] [int] IDENTITY(1,1) NOT NULL,

[EventItemId] [int] NOT NULL,

[DefinedValueId] [int] NOT NULL,

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

ALTER TABLE [dbo].[EventItemAudience] ADD  CONSTRAINT [PK_dbo.EventItemAudience] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EventItemAudience]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DefinedValueId] ON [dbo].[EventItemAudience]

(

[DefinedValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EventItemId] ON [dbo].[EventItemAudience]

(

[EventItemId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EventItemAudience]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EventItemAudience]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventItemAudience]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemAudience_dbo.DefinedValue_DefinedValueId] FOREIGN KEY([DefinedValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[EventItemAudience] CHECK CONSTRAINT [FK_dbo.EventItemAudience_dbo.DefinedValue_DefinedValueId]

GO

ALTER TABLE [dbo].[EventItemAudience]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemAudience_dbo.EventItem_EventItemId] FOREIGN KEY([EventItemId])

REFERENCES [dbo].[EventItem] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventItemAudience] CHECK CONSTRAINT [FK_dbo.EventItemAudience_dbo.EventItem_EventItemId]

GO

ALTER TABLE [dbo].[EventItemAudience]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemAudience_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemAudience] CHECK CONSTRAINT [FK_dbo.EventItemAudience_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventItemAudience]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemAudience_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemAudience] CHECK CONSTRAINT [FK_dbo.EventItemAudience_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## EventItemOccurrence
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EventItemOccurrence](

[Id] [int] IDENTITY(1,1) NOT NULL,

[EventItemId] [int] NOT NULL,

[CampusId] [int] NULL,

[Location] [nvarchar](200) NULL,

[ContactPersonAliasId] [int] NULL,

[ContactPhone] [nvarchar](20) NULL,

[ContactEmail] [nvarchar](75) NULL,

[Note] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ScheduleId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[NextStartDateTime] [datetime] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventItemOccurrence] ADD  CONSTRAINT [PK_dbo.EventItemOccurrence] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[EventItemOccurrence]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ContactPersonAliasId] ON [dbo].[EventItemOccurrence]

(

[ContactPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EventItemOccurrence]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_Email] ON [dbo].[EventItemOccurrence]

(

[ContactEmail] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EventItemId] ON [dbo].[EventItemOccurrence]

(

[EventItemId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EventItemOccurrence]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EventItemOccurrence]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[EventItemOccurrence]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventItemOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampus_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrence] CHECK CONSTRAINT [FK_dbo.EventItemCampus_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[EventItemOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampus_dbo.EventItem_EventItemId] FOREIGN KEY([EventItemId])

REFERENCES [dbo].[EventItem] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventItemOccurrence] CHECK CONSTRAINT [FK_dbo.EventItemCampus_dbo.EventItem_EventItemId]

GO

ALTER TABLE [dbo].[EventItemOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampus_dbo.PersonAlias_ContactPersonAliasId] FOREIGN KEY([ContactPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrence] CHECK CONSTRAINT [FK_dbo.EventItemCampus_dbo.PersonAlias_ContactPersonAliasId]

GO

ALTER TABLE [dbo].[EventItemOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampus_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrence] CHECK CONSTRAINT [FK_dbo.EventItemCampus_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventItemOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampus_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrence] CHECK CONSTRAINT [FK_dbo.EventItemCampus_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventItemOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemOccurrence_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrence] CHECK CONSTRAINT [FK_dbo.EventItemOccurrence_dbo.Schedule_ScheduleId]

GO
```

## EventItemOccurrenceChannelItem
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EventItemOccurrenceChannelItem](

[Id] [int] IDENTITY(1,1) NOT NULL,

[EventItemOccurrenceId] [int] NOT NULL,

[ContentChannelItemId] [int] NOT NULL,

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

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem] ADD  CONSTRAINT [PK_dbo.EventItemOccurrenceChannelItem] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ContentChannelItemId] ON [dbo].[EventItemOccurrenceChannelItem]

(

[ContentChannelItemId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EventItemOccurrenceChannelItem]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EventItemOccurrenceId] ON [dbo].[EventItemOccurrenceChannelItem]

(

[EventItemOccurrenceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EventItemOccurrenceChannelItem]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EventItemOccurrenceChannelItem]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemOccurrenceChannelItem_dbo.ContentChannelItem_ContentChannelItemId] FOREIGN KEY([ContentChannelItemId])

REFERENCES [dbo].[ContentChannelItem] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem] CHECK CONSTRAINT [FK_dbo.EventItemOccurrenceChannelItem_dbo.ContentChannelItem_ContentChannelItemId]

GO

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemOccurrenceChannelItem_dbo.EventItemOccurrence_EventItemOccurrenceId] FOREIGN KEY([EventItemOccurrenceId])

REFERENCES [dbo].[EventItemOccurrence] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem] CHECK CONSTRAINT [FK_dbo.EventItemOccurrenceChannelItem_dbo.EventItemOccurrence_EventItemOccurrenceId]

GO

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemOccurrenceChannelItem_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem] CHECK CONSTRAINT [FK_dbo.EventItemOccurrenceChannelItem_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemOccurrenceChannelItem_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrenceChannelItem] CHECK CONSTRAINT [FK_dbo.EventItemOccurrenceChannelItem_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## EventItemOccurrenceGroupMap
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EventItemOccurrenceGroupMap](

[Id] [int] IDENTITY(1,1) NOT NULL,

[EventItemOccurrenceId] [int] NULL,

[RegistrationInstanceId] [int] NULL,

[GroupId] [int] NULL,

[PublicName] [nvarchar](200) NULL,

[UrlSlug] [nvarchar](200) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[CampusId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap] ADD  CONSTRAINT [PK_dbo.EventItemOccurrenceGroupMap] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[EventItemOccurrenceGroupMap]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EventItemOccurrenceGroupMap]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EventItemOccurrenceId] ON [dbo].[EventItemOccurrenceGroupMap]

(

[EventItemOccurrenceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[EventItemOccurrenceGroupMap]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EventItemOccurrenceGroupMap]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EventItemOccurrenceGroupMap]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RegistrationInstanceId] ON [dbo].[EventItemOccurrenceGroupMap]

(

[RegistrationInstanceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.EventItemCampus_EventItemCampusId] FOREIGN KEY([EventItemOccurrenceId])

REFERENCES [dbo].[EventItemOccurrence] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap] CHECK CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.EventItemCampus_EventItemCampusId]

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap] CHECK CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap] CHECK CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap] CHECK CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.RegistrationInstance_RegistrationInstanceId] FOREIGN KEY([RegistrationInstanceId])

REFERENCES [dbo].[RegistrationInstance] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap] CHECK CONSTRAINT [FK_dbo.EventItemCampusGroupMap_dbo.RegistrationInstance_RegistrationInstanceId]

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap]  WITH CHECK ADD  CONSTRAINT [FK_dbo.EventItemOccurrenceGroupMap_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EventItemOccurrenceGroupMap] CHECK CONSTRAINT [FK_dbo.EventItemOccurrenceGroupMap_dbo.Campus_CampusId]

GO
```
