# GroupMember

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Group membership, assignments, history, and automation.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## GroupMember
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupMember](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[GroupId] [int] NOT NULL,

[PersonId] [int] NOT NULL,

[GroupRoleId] [int] NOT NULL,

[GroupMemberStatus] [int] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[GuestCount] [int] NULL,

[DateTimeAdded] [datetime] NULL,

[IsNotified] [bit] NOT NULL,

[Note] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[GroupOrder] [int] NULL,

[InactiveDateTime] [datetime] NULL,

[IsArchived] [bit] NOT NULL,

[ArchivedDateTime] [datetime] NULL,

[ArchivedByPersonAliasId] [int] NULL,

[ScheduleTemplateId] [int] NULL,

[ScheduleStartDate] [date] NULL,

[ScheduleReminderEmailOffsetDays] [int] NULL,

[CommunicationPreference] [int] NOT NULL,

[GroupTypeId] [int] NOT NULL,

[IsChatMuted] [bit] NOT NULL,

[IsChatBanned] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMember] ADD CONSTRAINT [PK_dbo.GroupMember] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ArchivedByPersonAliasId] ON [dbo].[GroupMember]

(

[ArchivedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupMember]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId_PersonId_GroupRoleId] ON [dbo].[GroupMember]

(

[GroupId] ASC,

[PersonId] ASC,

[GroupRoleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupMemberGroupIdGroupRoleIdGroupMemberStatus] ON [dbo].[GroupMember]

(

[GroupId] ASC,

[GroupRoleId] ASC,

[GroupMemberStatus] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[GroupMember]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupMember]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupMember]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonId] ON [dbo].[GroupMember]

(

[PersonId] ASC

)

INCLUDE([Id],[GroupId],[GroupRoleId],[GroupMemberStatus]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleTemplateId] ON [dbo].[GroupMember]

(

[ScheduleTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMember] ADD DEFAULT ((0)) FOR [IsNotified]

GO

ALTER TABLE [dbo].[GroupMember] ADD DEFAULT ((0)) FOR [IsArchived]

GO

ALTER TABLE [dbo].[GroupMember] ADD DEFAULT ((0)) FOR [CommunicationPreference]

GO

ALTER TABLE [dbo].[GroupMember] ADD DEFAULT ((0)) FOR [IsChatMuted]

GO

ALTER TABLE [dbo].[GroupMember] ADD DEFAULT ((0)) FOR [IsChatBanned]

GO

ALTER TABLE [dbo].[GroupMember] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMember_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupMember] CHECK CONSTRAINT [FK_dbo.GroupMember_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupMember] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMember_dbo.GroupMemberScheduleTemplate_ScheduleTemplateId] FOREIGN KEY([ScheduleTemplateId])

REFERENCES [dbo].[GroupMemberScheduleTemplate] ([Id])

GO

ALTER TABLE [dbo].[GroupMember] CHECK CONSTRAINT [FK_dbo.GroupMember_dbo.GroupMemberScheduleTemplate_ScheduleTemplateId]

GO

ALTER TABLE [dbo].[GroupMember] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMember_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[GroupMember] CHECK CONSTRAINT [FK_dbo.GroupMember_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[GroupMember] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMember_dbo.GroupTypeRole_GroupRoleId] FOREIGN KEY([GroupRoleId])

REFERENCES [dbo].[GroupTypeRole] ([Id])

GO

ALTER TABLE [dbo].[GroupMember] CHECK CONSTRAINT [FK_dbo.GroupMember_dbo.GroupTypeRole_GroupRoleId]

GO

ALTER TABLE [dbo].[GroupMember] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMember_dbo.Person_PersonId] FOREIGN KEY([PersonId])

REFERENCES [dbo].[Person] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupMember] CHECK CONSTRAINT [FK_dbo.GroupMember_dbo.Person_PersonId]

GO

ALTER TABLE [dbo].[GroupMember] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMember_dbo.PersonAlias_ArchivedByPersonAliasId] FOREIGN KEY([ArchivedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMember] CHECK CONSTRAINT [FK_dbo.GroupMember_dbo.PersonAlias_ArchivedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMember] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMember_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMember] CHECK CONSTRAINT [FK_dbo.GroupMember_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMember] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMember_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMember] CHECK CONSTRAINT [FK_dbo.GroupMember_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## GroupMemberAssignment
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupMemberAssignment](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupMemberId] [int] NOT NULL,

[LocationId] [int] NULL,

[ScheduleId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ConfirmationSentDateTime] [datetime] NULL,

[LastReminderSentDateTime] [datetime] NULL,

[GroupId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberAssignment] ADD CONSTRAINT [PK_dbo.GroupMemberAssignment] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupMemberAssignment]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_GroupMemberIdLocationIdScheduleId] ON [dbo].[GroupMemberAssignment]

(

[GroupMemberId] ASC,

[LocationId] ASC,

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupMemberAssignment]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupMemberAssignment]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberAssignment] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupMemberAssignment] CHECK CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupMemberAssignment] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.GroupMember_GroupMemberId] FOREIGN KEY([GroupMemberId])

REFERENCES [dbo].[GroupMember] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberAssignment] CHECK CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.GroupMember_GroupMemberId]

GO

ALTER TABLE [dbo].[GroupMemberAssignment] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.Location_LocationId] FOREIGN KEY([LocationId])

REFERENCES [dbo].[Location] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberAssignment] CHECK CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.Location_LocationId]

GO

ALTER TABLE [dbo].[GroupMemberAssignment] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberAssignment] CHECK CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberAssignment] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberAssignment] CHECK CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberAssignment] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberAssignment] CHECK CONSTRAINT [FK_dbo.GroupMemberAssignment_dbo.Schedule_ScheduleId]

GO
```


## GroupMemberHistorical
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupMemberHistorical](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupMemberId] [int] NOT NULL,

[GroupId] [int] NOT NULL,

[GroupRoleId] [int] NOT NULL,

[GroupRoleName] [nvarchar](100) NULL,

[IsLeader] [bit] NOT NULL,

[GroupMemberStatus] [int] NOT NULL,

[IsArchived] [bit] NOT NULL,

[ArchivedDateTime] [datetime] NULL,

[ArchivedByPersonAliasId] [int] NULL,

[InactiveDateTime] [datetime] NULL,

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

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberHistorical] ADD CONSTRAINT [PK_dbo.GroupMemberHistorical] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ArchivedByPersonAliasId] ON [dbo].[GroupMemberHistorical]

(

[ArchivedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupMemberHistorical]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[GroupMemberHistorical]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupMemberId] ON [dbo].[GroupMemberHistorical]

(

[GroupMemberId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_GroupMemberIdCurrentRow] ON [dbo].[GroupMemberHistorical]

(

[GroupMemberId] ASC,

[CurrentRowIndicator] ASC

)

WHERE ([CurrentRowIndicator]=(1))

WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupRoleId] ON [dbo].[GroupMemberHistorical]

(

[GroupRoleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupMemberHistorical]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupMemberHistorical]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberHistorical] CHECK CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupMemberHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.GroupMember_GroupMemberId] FOREIGN KEY([GroupMemberId])

REFERENCES [dbo].[GroupMember] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberHistorical] CHECK CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.GroupMember_GroupMemberId]

GO

ALTER TABLE [dbo].[GroupMemberHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.GroupTypeRole_GroupRoleId] FOREIGN KEY([GroupRoleId])

REFERENCES [dbo].[GroupTypeRole] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberHistorical] CHECK CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.GroupTypeRole_GroupRoleId]

GO

ALTER TABLE [dbo].[GroupMemberHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.PersonAlias_ArchivedByPersonAliasId] FOREIGN KEY([ArchivedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberHistorical] CHECK CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.PersonAlias_ArchivedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberHistorical] CHECK CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberHistorical] CHECK CONSTRAINT [FK_dbo.GroupMemberHistorical_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## GroupMemberScheduleTemplate
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupMemberScheduleTemplate](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[GroupTypeId] [int] NULL,

[ScheduleId] [int] NOT NULL,

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

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] ADD CONSTRAINT [PK_dbo.GroupMemberScheduleTemplate] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupMemberScheduleTemplate]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[GroupMemberScheduleTemplate]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupMemberScheduleTemplate]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupMemberScheduleTemplate]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[GroupMemberScheduleTemplate]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberScheduleTemplate_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] CHECK CONSTRAINT [FK_dbo.GroupMemberScheduleTemplate_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberScheduleTemplate_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] CHECK CONSTRAINT [FK_dbo.GroupMemberScheduleTemplate_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberScheduleTemplate_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] CHECK CONSTRAINT [FK_dbo.GroupMemberScheduleTemplate_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberScheduleTemplate_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberScheduleTemplate] CHECK CONSTRAINT [FK_dbo.GroupMemberScheduleTemplate_dbo.Schedule_ScheduleId]

GO
```


## GroupMemberWorkflowTrigger
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupMemberWorkflowTrigger](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsActive] [bit] NOT NULL,

[GroupTypeId] [int] NULL,

[GroupId] [int] NULL,

[Name] [nvarchar](100) NULL,

[WorkflowTypeId] [int] NOT NULL,

[TriggerType] [int] NOT NULL,

[TypeQualifier] [nvarchar](200) NULL,

[WorkflowName] [nvarchar](100) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[Order] [int] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberWorkflowTrigger] ADD CONSTRAINT [PK_dbo.GroupMemberWorkflowTrigger] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[GroupMemberWorkflowTrigger]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[GroupMemberWorkflowTrigger]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupMemberWorkflowTrigger]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowTypeId] ON [dbo].[GroupMemberWorkflowTrigger]

(

[WorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberWorkflowTrigger] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[GroupMemberWorkflowTrigger] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberWorkflowTrigger_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupMemberWorkflowTrigger] CHECK CONSTRAINT [FK_dbo.GroupMemberWorkflowTrigger_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupMemberWorkflowTrigger] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberWorkflowTrigger_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupMemberWorkflowTrigger] CHECK CONSTRAINT [FK_dbo.GroupMemberWorkflowTrigger_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[GroupMemberWorkflowTrigger] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberWorkflowTrigger_dbo.WorkflowType_WorkflowTypeId] FOREIGN KEY([WorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupMemberWorkflowTrigger] CHECK CONSTRAINT [FK_dbo.GroupMemberWorkflowTrigger_dbo.WorkflowType_WorkflowTypeId]

GO
```