# Group

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Core group entity, demographics, history, and sync.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## Group
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Group](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[ParentGroupId] [int] NULL,

[GroupTypeId] [int] NOT NULL,

[CampusId] [int] NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[IsSecurityRole] [bit] NOT NULL,

[IsActive] [bit] NOT NULL,

[Order] [int] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[AllowGuests] [bit] NULL,

[ScheduleId] [int] NULL,

[IsPublic] [bit] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[GroupCapacity] [int] NULL,

[RequiredSignatureDocumentTemplateId] [int] NULL,

[InactiveDateTime] [datetime] NULL,

[IsArchived] [bit] NOT NULL,

[ArchivedDateTime] [datetime] NULL,

[ArchivedByPersonAliasId] [int] NULL,

[StatusValueId] [int] NULL,

[GroupAdministratorPersonAliasId] [int] NULL,

[SchedulingMustMeetRequirements] [bit] NOT NULL,

[AttendanceRecordRequiredForCheckIn] [int] NOT NULL,

[ScheduleCoordinatorPersonAliasId] [int] NULL,

[InactiveReasonValueId] [int] NULL,

[InactiveReasonNote] [nvarchar](max) NULL,

[RSVPReminderSystemCommunicationId] [int] NULL,

[RSVPReminderOffsetDays] [int] NULL,

[DisableScheduleToolboxAccess] [bit] NOT NULL,

[DisableScheduling] [bit] NOT NULL,

[GroupSalutation] [nvarchar](250) NULL,

[GroupSalutationFull] [nvarchar](250) NULL,

[ElevatedSecurityLevel] [int] NOT NULL,

[ConfirmationAdditionalDetails] [nvarchar](max) NULL,

[ReminderSystemCommunicationId] [int] NULL,

[ReminderOffsetDays] [int] NULL,

[ReminderAdditionalDetails] [nvarchar](max) NULL,

[ScheduleConfirmationLogic] [int] NULL,

[RelationshipGrowthEnabledOverride] [bit] NULL,

[RelationshipStrengthOverride] [int] NULL,

[LeaderToLeaderRelationshipMultiplierOverride] [decimal](8, 2) NULL,

[LeaderToNonLeaderRelationshipMultiplierOverride] [decimal](8, 2) NULL,

[NonLeaderToNonLeaderRelationshipMultiplierOverride] [decimal](8, 2) NULL,

[NonLeaderToLeaderRelationshipMultiplierOverride] [decimal](8, 2) NULL,

[IsSpecialNeeds] [bit] NOT NULL,

[ScheduleCoordinatorNotificationTypes] [int] NULL,

[IsChatEnabledOverride] [bit] NULL,

[IsLeavingChatChannelAllowedOverride] [bit] NULL,

[IsChatChannelPublicOverride] [bit] NULL,

[IsChatChannelAlwaysShownOverride] [bit] NULL,

[ChatChannelKey] [nvarchar](100) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Group] ADD CONSTRAINT [PK_dbo.Group] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ArchivedByPersonAliasId] ON [dbo].[Group]

(

[ArchivedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[Group]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Group]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupAdministratorPersonAliasId] ON [dbo].[Group]

(

[GroupAdministratorPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId_CampusId] ON [dbo].[Group]

(

[GroupTypeId] ASC,

[CampusId] ASC

)

INCLUDE([ParentGroupId],[Name],[IsActive],[Order],[Guid],[IsArchived],[StatusValueId],[RelationshipStrengthOverride]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Group]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_InactiveReasonValueId] ON [dbo].[Group]

(

[InactiveReasonValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Group]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ParentGroupId_GroupTypeId] ON [dbo].[Group]

(

[ParentGroupId] ASC,

[GroupTypeId] ASC

)

INCLUDE([IsActive],[IsArchived]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RequiredSignatureDocumentTemplateId] ON [dbo].[Group]

(

[RequiredSignatureDocumentTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleCoordinatorPersonAliasId] ON [dbo].[Group]

(

[ScheduleCoordinatorPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[Group]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_StatusValueId] ON [dbo].[Group]

(

[StatusValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Group] ADD DEFAULT ((1)) FOR [IsPublic]

GO

ALTER TABLE [dbo].[Group] ADD DEFAULT ((0)) FOR [IsArchived]

GO

ALTER TABLE [dbo].[Group] ADD DEFAULT ((0)) FOR [SchedulingMustMeetRequirements]

GO

ALTER TABLE [dbo].[Group] ADD DEFAULT ((0)) FOR [AttendanceRecordRequiredForCheckIn]

GO

ALTER TABLE [dbo].[Group] ADD DEFAULT ((0)) FOR [DisableScheduleToolboxAccess]

GO

ALTER TABLE [dbo].[Group] ADD DEFAULT ((0)) FOR [DisableScheduling]

GO

ALTER TABLE [dbo].[Group] ADD DEFAULT ((0)) FOR [ElevatedSecurityLevel]

GO

ALTER TABLE [dbo].[Group] ADD DEFAULT ((0)) FOR [IsSpecialNeeds]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.DefinedValue_InactiveReasonValueId] FOREIGN KEY([InactiveReasonValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.DefinedValue_InactiveReasonValueId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.DefinedValue_StatusValueId] FOREIGN KEY([StatusValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.DefinedValue_StatusValueId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.Group_ParentGroupId] FOREIGN KEY([ParentGroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.Group_ParentGroupId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_ArchivedByPersonAliasId] FOREIGN KEY([ArchivedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_ArchivedByPersonAliasId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_GroupAdministratorPersonAliasId] FOREIGN KEY([GroupAdministratorPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_GroupAdministratorPersonAliasId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_ScheduleCoordinatorPersonAliasId] FOREIGN KEY([ScheduleCoordinatorPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.PersonAlias_ScheduleCoordinatorPersonAliasId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.Schedule_ScheduleId]

GO

ALTER TABLE [dbo].[Group] WITH CHECK ADD CONSTRAINT [FK_dbo.Group_dbo.SignatureDocumentType_RequiredSignatureDocumentTypeId] FOREIGN KEY([RequiredSignatureDocumentTemplateId])

REFERENCES [dbo].[SignatureDocumentTemplate] ([Id])

GO

ALTER TABLE [dbo].[Group] CHECK CONSTRAINT [FK_dbo.Group_dbo.SignatureDocumentType_RequiredSignatureDocumentTypeId]

GO
```


## GroupDemographicType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupDemographicType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupTypeId] [int] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[ComponentEntityTypeId] [int] NOT NULL,

[RoleFilter] [nvarchar](100) NULL,

[IsAutomated] [bit] NOT NULL,

[LastRunDurationSeconds] [int] NULL,

[RunOnPersonUpdate] [bit] NOT NULL,

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

ALTER TABLE [dbo].[GroupDemographicType] ADD CONSTRAINT [PK_dbo.GroupDemographicType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ComponentEntityTypeId] ON [dbo].[GroupDemographicType]

(

[ComponentEntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupDemographicType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[GroupDemographicType]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupDemographicType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupDemographicType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupDemographicType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicType_dbo.EntityType_ComponentEntityTypeId] FOREIGN KEY([ComponentEntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[GroupDemographicType] CHECK CONSTRAINT [FK_dbo.GroupDemographicType_dbo.EntityType_ComponentEntityTypeId]

GO

ALTER TABLE [dbo].[GroupDemographicType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicType_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupDemographicType] CHECK CONSTRAINT [FK_dbo.GroupDemographicType_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[GroupDemographicType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupDemographicType] CHECK CONSTRAINT [FK_dbo.GroupDemographicType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupDemographicType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupDemographicType] CHECK CONSTRAINT [FK_dbo.GroupDemographicType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## GroupDemographicValue
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupDemographicValue](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupId] [int] NOT NULL,

[GroupDemographicTypeId] [int] NOT NULL,

[RelatedEntityTypeId] [int] NULL,

[RelatedEntityId] [int] NULL,

[Value] [nvarchar](max) NULL,

[ValueAsGuid] [uniqueidentifier] NULL,

[ValueAsNumeric] [decimal](18, 2) NULL,

[ValueAsBoolean] [bit] NULL,

[LastCalculatedDateTime] [datetime] NULL,

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

ALTER TABLE [dbo].[GroupDemographicValue] ADD CONSTRAINT [PK_dbo.GroupDemographicValue] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupDemographicValue]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupDemographicTypeId] ON [dbo].[GroupDemographicValue]

(

[GroupDemographicTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[GroupDemographicValue]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupDemographicValue]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupDemographicValue]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RelatedEntityTypeId] ON [dbo].[GroupDemographicValue]

(

[RelatedEntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupDemographicValue] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.EntityType_RelatedEntityTypeId] FOREIGN KEY([RelatedEntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[GroupDemographicValue] CHECK CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.EntityType_RelatedEntityTypeId]

GO

ALTER TABLE [dbo].[GroupDemographicValue] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupDemographicValue] CHECK CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupDemographicValue] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.GroupDemographicType_GroupDemographicTypeId] FOREIGN KEY([GroupDemographicTypeId])

REFERENCES [dbo].[GroupDemographicType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupDemographicValue] CHECK CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.GroupDemographicType_GroupDemographicTypeId]

GO

ALTER TABLE [dbo].[GroupDemographicValue] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupDemographicValue] CHECK CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupDemographicValue] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupDemographicValue] CHECK CONSTRAINT [FK_dbo.GroupDemographicValue_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## GroupHistorical
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupHistorical](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupId] [int] NOT NULL,

[GroupName] [nvarchar](100) NULL,

[GroupTypeId] [int] NOT NULL,

[GroupTypeName] [nvarchar](100) NULL,

[CampusId] [int] NULL,

[ParentGroupId] [int] NULL,

[Description] [nvarchar](max) NULL,

[ScheduleId] [int] NULL,

[ScheduleName] [nvarchar](max) NULL,

[ScheduleModifiedDateTime] [datetime] NULL,

[IsArchived] [bit] NOT NULL,

[ArchivedDateTime] [datetime] NULL,

[ArchivedByPersonAliasId] [int] NULL,

[IsActive] [bit] NOT NULL,

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

[ForeignKey] [nvarchar](100) NULL,

[StatusValueId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupHistorical] ADD CONSTRAINT [PK_dbo.GroupHistorical] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ArchivedByPersonAliasId] ON [dbo].[GroupHistorical]

(

[ArchivedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[GroupHistorical]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupHistorical]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[GroupHistorical]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_GroupIdCurrentRow] ON [dbo].[GroupHistorical]

(

[GroupId] ASC,

[CurrentRowIndicator] ASC

)

WHERE ([CurrentRowIndicator]=(1))

WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[GroupHistorical]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupHistorical]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupHistorical]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ParentGroupId] ON [dbo].[GroupHistorical]

(

[ParentGroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[GroupHistorical]

(

[ScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupHistorical_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[GroupHistorical] CHECK CONSTRAINT [FK_dbo.GroupHistorical_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[GroupHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupHistorical_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[GroupHistorical] CHECK CONSTRAINT [FK_dbo.GroupHistorical_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupHistorical_dbo.Group_ParentGroupId] FOREIGN KEY([ParentGroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[GroupHistorical] CHECK CONSTRAINT [FK_dbo.GroupHistorical_dbo.Group_ParentGroupId]

GO

ALTER TABLE [dbo].[GroupHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupHistorical_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[GroupHistorical] CHECK CONSTRAINT [FK_dbo.GroupHistorical_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[GroupHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupHistorical_dbo.PersonAlias_ArchivedByPersonAliasId] FOREIGN KEY([ArchivedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupHistorical] CHECK CONSTRAINT [FK_dbo.GroupHistorical_dbo.PersonAlias_ArchivedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupHistorical_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupHistorical] CHECK CONSTRAINT [FK_dbo.GroupHistorical_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupHistorical_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupHistorical] CHECK CONSTRAINT [FK_dbo.GroupHistorical_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupHistorical_dbo.Schedule_ScheduleId] FOREIGN KEY([ScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

GO

ALTER TABLE [dbo].[GroupHistorical] CHECK CONSTRAINT [FK_dbo.GroupHistorical_dbo.Schedule_ScheduleId]

GO
```


## GroupSync
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupSync](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupId] [int] NOT NULL,

[GroupTypeRoleId] [int] NOT NULL,

[SyncDataViewId] [int] NOT NULL,

[WelcomeSystemEmailId] [int] NULL,

[ExitSystemEmailId] [int] NULL,

[AddUserAccountsDuringSync] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[WelcomeSystemCommunicationId] [int] NULL,

[ExitSystemCommunicationId] [int] NULL,

[ScheduleIntervalMinutes] [int] NULL,

[LastRefreshDateTime] [datetime] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupSync] ADD CONSTRAINT [PK_dbo.GroupSync] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupSync]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ExitSystemEmailId] ON [dbo].[GroupSync]

(

[ExitSystemEmailId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_GroupIdGroupTypeRoleId] ON [dbo].[GroupSync]

(

[GroupId] ASC,

[GroupTypeRoleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupSync]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupSync]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SyncDataViewId] ON [dbo].[GroupSync]

(

[SyncDataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WelcomeSystemEmailId] ON [dbo].[GroupSync]

(

[WelcomeSystemEmailId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.DataView_SyncDataViewId] FOREIGN KEY([SyncDataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.DataView_SyncDataViewId]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.GroupTypeRole_GroupTypeRoleId] FOREIGN KEY([GroupTypeRoleId])

REFERENCES [dbo].[GroupTypeRole] ([Id])

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.GroupTypeRole_GroupTypeRoleId]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.SystemCommunication_ExitSystemCommunicationId] FOREIGN KEY([ExitSystemCommunicationId])

REFERENCES [dbo].[SystemCommunication] ([Id])

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.SystemCommunication_ExitSystemCommunicationId]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.SystemCommunication_WelcomeSystemCommunicationId] FOREIGN KEY([WelcomeSystemCommunicationId])

REFERENCES [dbo].[SystemCommunication] ([Id])

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.SystemCommunication_WelcomeSystemCommunicationId]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.SystemEmail_ExitSystemEmailId] FOREIGN KEY([ExitSystemEmailId])

REFERENCES [dbo].[SystemEmail] ([Id])

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.SystemEmail_ExitSystemEmailId]

GO

ALTER TABLE [dbo].[GroupSync] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupSync_dbo.SystemEmail_WelcomeSystemEmailId] FOREIGN KEY([WelcomeSystemEmailId])

REFERENCES [dbo].[SystemEmail] ([Id])

GO

ALTER TABLE [dbo].[GroupSync] CHECK CONSTRAINT [FK_dbo.GroupSync_dbo.SystemEmail_WelcomeSystemEmailId]

GO
```