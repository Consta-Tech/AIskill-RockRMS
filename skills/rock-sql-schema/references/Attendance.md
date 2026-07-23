# Attendance

Check-in configuration, occurrence events, individual attendance records, label data, and analytics.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| CheckInLabel | Label template definitions for check-in printing | — |
| AttendanceCode | Security codes issued during check-in | — |
| AttendanceCheckInSession | Groups related check-in events into a single kiosk session | Device |
| AttendanceOccurrence | A specific group + location + schedule + date event | Group (CASCADE), Location (CASCADE), Schedule (SET NULL), DefinedValue, StepType, GroupType (CASCADE) |
| Attendance | Individual person attendance record for an occurrence | AttendanceOccurrence, AttendanceCode, AttendanceCheckInSession (SET NULL), Campus (CASCADE), Device, DefinedValue (many), PersonAlias (CASCADE) |
| AttendanceData | Check-in label print data stored as a 1:1 extension of Attendance | Attendance (CASCADE, shared PK) |
| AnalyticsSourceAttendance | Denormalized analytics fact table for attendance reporting | — |

---

## CheckInLabel
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[CheckInLabel](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[IsActive] [bit] NOT NULL,

[IsSystem] [bit] NOT NULL,

[LabelFormat] [int] NOT NULL,

[LabelType] [int] NOT NULL,

[Content] [nvarchar](max) NULL,

[PreviewImage] [varbinary](max) NULL,

[AdditionalSettingsJson] [nvarchar](max) NULL,

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

ALTER TABLE [dbo].[CheckInLabel] ADD  CONSTRAINT [PK_dbo.CheckInLabel] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[CheckInLabel]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[CheckInLabel]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[CheckInLabel]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CheckInLabel]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CheckInLabel_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[CheckInLabel] CHECK CONSTRAINT [FK_dbo.CheckInLabel_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[CheckInLabel]  WITH CHECK ADD  CONSTRAINT [FK_dbo.CheckInLabel_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[CheckInLabel] CHECK CONSTRAINT [FK_dbo.CheckInLabel_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```

## AttendanceCode
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceCode](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IssueDateTime] [datetime] NOT NULL,

[Code] [nvarchar](10) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttendanceCode] ADD  CONSTRAINT [PK_dbo.AttendanceCode] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Code_IssueDateTime] ON [dbo].[AttendanceCode]

(

[Code] ASC,

[IssueDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttendanceCode]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_IssueDateTime] ON [dbo].[AttendanceCode]

(

[IssueDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
```

## AttendanceCheckInSession
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceCheckInSession](

[Id] [int] IDENTITY(1,1) NOT NULL,

[DeviceId] [int] NULL,

[ClientIpAddress] [nvarchar](45) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttendanceCheckInSession] ADD  CONSTRAINT [PK_dbo.AttendanceCheckInSession] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DeviceId] ON [dbo].[AttendanceCheckInSession]

(

[DeviceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttendanceCheckInSession]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttendanceCheckInSession]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceCheckInSession_dbo.Device_DeviceId] FOREIGN KEY([DeviceId])

REFERENCES [dbo].[Device] ([Id])

GO

ALTER TABLE [dbo].[AttendanceCheckInSession] CHECK CONSTRAINT [FK_dbo.AttendanceCheckInSession_dbo.Device_DeviceId]

GO
```

## AttendanceOccurrence
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceOccurrence](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupId] [int] NULL,

[LocationId] [int] NULL,

[ScheduleId] [int] NULL,

[OccurrenceDate] [date] NOT NULL,

[DidNotOccur] [bit] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[Notes] [nvarchar](max) NULL,

[AnonymousAttendanceCount] [int] NULL,

[StepTypeId] [int] NULL,

[AcceptConfirmationMessage] [nvarchar](max) NULL,

[DeclineConfirmationMessage] [nvarchar](max) NULL,

[ShowDeclineReasons] [bit] NOT NULL,

[DeclineReasonValueIds] [nvarchar](250) NULL,

[SundayDate] [date] NOT NULL,

[Name] [nvarchar](250) NULL,

[OccurrenceDateKey] [int] NOT NULL,

[AttendanceTypeValueId] [int] NULL,

[AttendanceReminderLastSentDateTime] [datetime] NULL,

[RootGroupTypeId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttendanceOccurrence] ADD  CONSTRAINT [PK_dbo.AttendanceOccurrence] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[AttendanceOccurrence]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_GroupId_LocationID_ScheduleID_Date] ON [dbo].[AttendanceOccurrence]

(

[GroupId] ASC,

[LocationId] ASC,

[ScheduleId] ASC,

[OccurrenceDate] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttendanceOccurrence]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LocationId] ON [dbo].[AttendanceOccurrence]

(

[LocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[AttendanceOccurrence]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_OccurrenceDate] ON [dbo].[AttendanceOccurrence]

(

[OccurrenceDate] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_OccurrenceDateKey] ON [dbo].[AttendanceOccurrence]

(

[OccurrenceDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RootGroupTypeId] ON [dbo].[AttendanceOccurrence]

(

[RootGroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[AttendanceOccurrence]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_StepTypeId] ON [dbo].[AttendanceOccurrence]

(

[StepTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SundayDate] ON [dbo].[AttendanceOccurrence]

(

[SundayDate] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttendanceOccurrence] ADD  DEFAULT ((1)) FOR [ShowDeclineReasons]

GO

ALTER TABLE [dbo].[AttendanceOccurrence] ADD  DEFAULT ('1753-01-01T00:00:00.000') FOR [SundayDate]

GO

ALTER TABLE [dbo].[AttendanceOccurrence] ADD  DEFAULT ((0)) FOR [OccurrenceDateKey]

GO

ALTER TABLE [dbo].[AttendanceOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.DefinedValue_AttendanceTypeValueId] FOREIGN KEY([AttendanceTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[AttendanceOccurrence] CHECK CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.DefinedValue_AttendanceTypeValueId]

GO

ALTER TABLE [dbo].[AttendanceOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttendanceOccurrence] CHECK CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[AttendanceOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.GroupType_RootGroupTypeId] FOREIGN KEY([RootGroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttendanceOccurrence] CHECK CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.GroupType_RootGroupTypeId]

GO

ALTER TABLE [dbo].[AttendanceOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.Location_LocationId] FOREIGN KEY([LocationId])

REFERENCES [dbo].[Location] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttendanceOccurrence] CHECK CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.Location_LocationId]

GO

ALTER TABLE [dbo].[AttendanceOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttendanceOccurrence] CHECK CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[AttendanceOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttendanceOccurrence] CHECK CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[AttendanceOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

ON DELETE SET NULL

GO

ALTER TABLE [dbo].[AttendanceOccurrence] CHECK CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.Schedule_ScheduleId]

GO

ALTER TABLE [dbo].[AttendanceOccurrence]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.StepType_StepTypeId] FOREIGN KEY([StepTypeId])

REFERENCES [dbo].[StepType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttendanceOccurrence] CHECK CONSTRAINT [FK_dbo.AttendanceOccurrence_dbo.StepType_StepTypeId]

GO
```

## Attendance
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Attendance](

[Id] [int] IDENTITY(1,1) NOT NULL,

[DeviceId] [int] NULL,

[SearchTypeValueId] [int] NULL,

[AttendanceCodeId] [int] NULL,

[QualifierValueId] [int] NULL,

[StartDateTime] [datetime] NOT NULL,

[EndDateTime] [datetime] NULL,

[DidAttend] [bit] NULL,

[Note] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[CampusId] [int] NULL,

[PersonAliasId] [int] NULL,

[RSVP] [int] NOT NULL,

[Processed] [bit] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[SearchValue] [nvarchar](max) NULL,

[SearchResultGroupId] [int] NULL,

[OccurrenceId] [int] NOT NULL,

[CheckedInByPersonAliasId] [int] NULL,

[ScheduledToAttend] [bit] NULL,

[RequestedToAttend] [bit] NULL,

[ScheduleConfirmationSent] [bit] NULL,

[ScheduleReminderSent] [bit] NULL,

[RSVPDateTime] [datetime] NULL,

[DeclineReasonValueId] [int] NULL,

[ScheduledByPersonAliasId] [int] NULL,

[AttendanceCheckInSessionId] [int] NULL,

[PresentDateTime] [datetime] NULL,

[PresentByPersonAliasId] [int] NULL,

[CheckedOutByPersonAliasId] [int] NULL,

[IsFirstTime] [bit] NULL,

[CheckInStatus] [int] NOT NULL,

[SourceValueId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Attendance] ADD  CONSTRAINT [PK_dbo.Attendance] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttendanceCheckInSessionId] ON [dbo].[Attendance]

(

[AttendanceCheckInSessionId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[Attendance]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CheckedOutByPersonAliasId] ON [dbo].[Attendance]

(

[CheckedOutByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Attendance]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DeclineReasonValueId] ON [dbo].[Attendance]

(

[DeclineReasonValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Attendance]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Attendance]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_OccurrenceId] ON [dbo].[Attendance]

(

[OccurrenceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[Attendance]

(

[PersonAliasId] ASC

)

INCLUDE([Id],[StartDateTime],[DidAttend],[CampusId]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PresentByPersonAliasId] ON [dbo].[Attendance]

(

[PresentByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_QualifierValueId] ON [dbo].[Attendance]

(

[QualifierValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduledByPersonAliasId] ON [dbo].[Attendance]

(

[ScheduledByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SearchResultGroupId] ON [dbo].[Attendance]

(

[SearchResultGroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SearchTypeValueId] ON [dbo].[Attendance]

(

[SearchTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SourceValueId] ON [dbo].[Attendance]

(

[SourceValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_StartDateTime_DidAttend] ON [dbo].[Attendance]

(

[StartDateTime] ASC,

[DidAttend] ASC

)

INCLUDE([Id],[CampusId],[PersonAliasId]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Attendance] ADD  DEFAULT ((0)) FOR [RSVP]

GO

ALTER TABLE [dbo].[Attendance] ADD  DEFAULT ((1)) FOR [OccurrenceId]

GO

ALTER TABLE [dbo].[Attendance] ADD  DEFAULT ((0)) FOR [CheckInStatus]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.AttendanceCheckInSession_AttendanceCheckInSessionId] FOREIGN KEY([AttendanceCheckInSessionId])

REFERENCES [dbo].[AttendanceCheckInSession] ([Id])

ON DELETE SET NULL

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.AttendanceCheckInSession_AttendanceCheckInSessionId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.AttendanceCode_AttendanceCodeId] FOREIGN KEY([AttendanceCodeId])

REFERENCES [dbo].[AttendanceCode] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.AttendanceCode_AttendanceCodeId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.AttendanceOccurrence_OccurrenceId] FOREIGN KEY([OccurrenceId])

REFERENCES [dbo].[AttendanceOccurrence] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.AttendanceOccurrence_OccurrenceId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.DefinedValue_DeclineReasonValueId] FOREIGN KEY([DeclineReasonValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.DefinedValue_DeclineReasonValueId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.DefinedValue_QualifierValueId] FOREIGN KEY([QualifierValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.DefinedValue_QualifierValueId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.DefinedValue_SearchTypeValueId] FOREIGN KEY([SearchTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.DefinedValue_SearchTypeValueId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.DefinedValue_SourceValueId] FOREIGN KEY([SourceValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.DefinedValue_SourceValueId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.Device_DeviceId] FOREIGN KEY([DeviceId])

REFERENCES [dbo].[Device] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.Device_DeviceId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.Group_SearchResultGroupId] FOREIGN KEY([SearchResultGroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.Group_SearchResultGroupId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_CheckedOutByPersonAliasId] FOREIGN KEY([CheckedOutByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_CheckedOutByPersonAliasId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_PersonAliasId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_PresentByPersonAliasId] FOREIGN KEY([PresentByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_PresentByPersonAliasId]

GO

ALTER TABLE [dbo].[Attendance]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_ScheduledByPersonAliasId] FOREIGN KEY([ScheduledByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_dbo.Attendance_dbo.PersonAlias_ScheduledByPersonAliasId]

GO
```

## AttendanceData
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttendanceData](

[Id] [int] NOT NULL,

[LabelData] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttendanceData] ADD  CONSTRAINT [PK_dbo.AttendanceData] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_Id] ON [dbo].[AttendanceData]

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttendanceData]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AttendanceData_dbo.Attendance_Id] FOREIGN KEY([Id])

REFERENCES [dbo].[Attendance] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttendanceData] CHECK CONSTRAINT [FK_dbo.AttendanceData_dbo.Attendance_Id]

GO
```

## AnalyticsSourceAttendance
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AnalyticsSourceAttendance](

[Id] [int] IDENTITY(1,1) NOT NULL,

[AttendanceId] [int] NOT NULL,

[AttendanceDateKey] [int] NOT NULL,

[AttendanceTypeId] [int] NULL,

[DaysSinceLastAttendanceOfType] [int] NULL,

[IsFirstAttendanceOfType] [bit] NOT NULL,

[Count] [int] NOT NULL,

[PersonKey] [int] NULL,

[CurrentPersonKey] [int] NULL,

[LocationId] [int] NULL,

[CampusId] [int] NULL,

[ScheduleId] [int] NULL,

[GroupId] [int] NULL,

[PersonAliasId] [int] NULL,

[DeviceId] [int] NULL,

[SearchTypeName] [nvarchar](max) NULL,

[StartDateTime] [datetime] NOT NULL,

[EndDateTime] [datetime] NULL,

[RSVP] [int] NOT NULL,

[DidAttend] [bit] NULL,

[Note] [nvarchar](max) NULL,

[SundayDate] [date] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[AnalyticsSourceAttendance] ADD  CONSTRAINT [PK_dbo.AnalyticsSourceAttendance] PRIMARY KEY CLUSTERED 

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttendanceDateKey] ON [dbo].[AnalyticsSourceAttendance]

(

[AttendanceDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_AttendanceId] ON [dbo].[AnalyticsSourceAttendance]

(

[AttendanceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttendanceType_CurrentPerson_StartDateTime] ON [dbo].[AnalyticsSourceAttendance]

(

[AttendanceTypeId] ASC,

[CurrentPersonKey] ASC,

[StartDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AnalyticsSourceAttendance]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_StartDateTime] ON [dbo].[AnalyticsSourceAttendance]

(

[StartDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO
```
