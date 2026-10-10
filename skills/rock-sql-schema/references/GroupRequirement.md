# GroupRequirement

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Requirement type definitions, group-level application, and per-member completion tracking.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| GroupRequirementType | Requirement definitions — SQL, DataView, or manual check, with due-date and workflow settings | Category, DataView (many), WorkflowType (many) |
| GroupRequirement | A requirement type applied to a specific group or group type, optionally for one role | Attribute, DataView, Group, GroupRequirementType (CASCADE), GroupType, GroupTypeRole (CASCADE) |
| GroupMemberRequirement | A group member's status on one requirement — met, warning, due date, manual completion | GroupMember (CASCADE), GroupRequirement (CASCADE), PersonAlias (many), Workflow (many) |

---

## GroupRequirementType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupRequirementType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](max) NOT NULL,

[Description] [nvarchar](max) NULL,

[CanExpire] [bit] NOT NULL,

[ExpireInDays] [int] NULL,

[RequirementCheckType] [int] NOT NULL,

[SqlExpression] [nvarchar](max) NULL,

[DataViewId] [int] NULL,

[PositiveLabel] [nvarchar](150) NULL,

[NegativeLabel] [nvarchar](150) NULL,

[CheckboxLabel] [nvarchar](150) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[WarningSqlExpression] [nvarchar](max) NULL,

[WarningDataViewId] [int] NULL,

[WarningLabel] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IconCssClass] [nvarchar](100) NULL,

[DueDateType] [int] NOT NULL,

[DueDateOffsetInDays] [int] NULL,

[CategoryId] [int] NULL,

[DoesNotMeetWorkflowTypeId] [int] NULL,

[ShouldAutoInitiateDoesNotMeetWorkflow] [bit] NOT NULL,

[DoesNotMeetWorkflowLinkText] [nvarchar](50) NULL,

[WarningWorkflowTypeId] [int] NULL,

[ShouldAutoInitiateWarningWorkflow] [bit] NOT NULL,

[WarningWorkflowLinkText] [nvarchar](50) NULL,

[Summary] [nvarchar](2000) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupRequirementType] ADD CONSTRAINT [PK_dbo.GroupRequirementType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[GroupRequirementType]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupRequirementType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DataViewId] ON [dbo].[GroupRequirementType]

(

[DataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DoesNotMeetWorkflowTypeId] ON [dbo].[GroupRequirementType]

(

[DoesNotMeetWorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupRequirementType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupRequirementType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WarningDataViewId] ON [dbo].[GroupRequirementType]

(

[WarningDataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WarningWorkflowTypeId] ON [dbo].[GroupRequirementType]

(

[WarningWorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupRequirementType] ADD DEFAULT ((0)) FOR [DueDateType]

GO

ALTER TABLE [dbo].[GroupRequirementType] ADD DEFAULT ((0)) FOR [ShouldAutoInitiateDoesNotMeetWorkflow]

GO

ALTER TABLE [dbo].[GroupRequirementType] ADD DEFAULT ((0)) FOR [ShouldAutoInitiateWarningWorkflow]

GO

ALTER TABLE [dbo].[GroupRequirementType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirementType_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirementType] CHECK CONSTRAINT [FK_dbo.GroupRequirementType_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[GroupRequirementType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirementType_dbo.DataView_DataViewId] FOREIGN KEY([DataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirementType] CHECK CONSTRAINT [FK_dbo.GroupRequirementType_dbo.DataView_DataViewId]

GO

ALTER TABLE [dbo].[GroupRequirementType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirementType_dbo.DataView_WarningDataViewId] FOREIGN KEY([WarningDataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirementType] CHECK CONSTRAINT [FK_dbo.GroupRequirementType_dbo.DataView_WarningDataViewId]

GO

ALTER TABLE [dbo].[GroupRequirementType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirementType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirementType] CHECK CONSTRAINT [FK_dbo.GroupRequirementType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupRequirementType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirementType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirementType] CHECK CONSTRAINT [FK_dbo.GroupRequirementType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupRequirementType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirementType_dbo.WorkflowType_DoesNotMeetWorkflowTypeId] FOREIGN KEY([DoesNotMeetWorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirementType] CHECK CONSTRAINT [FK_dbo.GroupRequirementType_dbo.WorkflowType_DoesNotMeetWorkflowTypeId]

GO

ALTER TABLE [dbo].[GroupRequirementType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirementType_dbo.WorkflowType_WarningWorkflowTypeId] FOREIGN KEY([WarningWorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirementType] CHECK CONSTRAINT [FK_dbo.GroupRequirementType_dbo.WorkflowType_WarningWorkflowTypeId]

GO
```


## GroupRequirement
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupRequirement](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupId] [int] NULL,

[GroupRequirementTypeId] [int] NOT NULL,

[GroupRoleId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[GroupTypeId] [int] NULL,

[MustMeetRequirementToAddMember] [bit] NOT NULL,

[AppliesToAgeClassification] [int] NOT NULL,

[AppliesToDataViewId] [int] NULL,

[AllowLeadersToOverride] [bit] NOT NULL,

[DueDateAttributeId] [int] NULL,

[DueDateStaticDate] [datetime] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupRequirement] ADD CONSTRAINT [PK_dbo.GroupRequirement] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AppliesToDataViewId] ON [dbo].[GroupRequirement]

(

[AppliesToDataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupRequirement]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DueDateAttributeId] ON [dbo].[GroupRequirement]

(

[DueDateAttributeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_GroupId_GroupTypeId_GroupRequirementTypeId_GroupRoleId] ON [dbo].[GroupRequirement]

(

[GroupId] ASC,

[GroupTypeId] ASC,

[GroupRequirementTypeId] ASC,

[GroupRoleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupRequirement]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupRequirement]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupRequirement] ADD DEFAULT ((0)) FOR [MustMeetRequirementToAddMember]

GO

ALTER TABLE [dbo].[GroupRequirement] ADD DEFAULT ((0)) FOR [AppliesToAgeClassification]

GO

ALTER TABLE [dbo].[GroupRequirement] ADD DEFAULT ((0)) FOR [AllowLeadersToOverride]

GO

ALTER TABLE [dbo].[GroupRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirement_dbo.Attribute_DueDateAttributeId] FOREIGN KEY([DueDateAttributeId])

REFERENCES [dbo].[Attribute] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirement] CHECK CONSTRAINT [FK_dbo.GroupRequirement_dbo.Attribute_DueDateAttributeId]

GO

ALTER TABLE [dbo].[GroupRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirement_dbo.DataView_AppliesToDataViewId] FOREIGN KEY([AppliesToDataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirement] CHECK CONSTRAINT [FK_dbo.GroupRequirement_dbo.DataView_AppliesToDataViewId]

GO

ALTER TABLE [dbo].[GroupRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirement_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirement] CHECK CONSTRAINT [FK_dbo.GroupRequirement_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[GroupRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirement_dbo.GroupRequirementType_GroupRequirementTypeId] FOREIGN KEY([GroupRequirementTypeId])

REFERENCES [dbo].[GroupRequirementType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupRequirement] CHECK CONSTRAINT [FK_dbo.GroupRequirement_dbo.GroupRequirementType_GroupRequirementTypeId]

GO

ALTER TABLE [dbo].[GroupRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirement_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirement] CHECK CONSTRAINT [FK_dbo.GroupRequirement_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[GroupRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirement_dbo.GroupTypeRole_GroupRoleId] FOREIGN KEY([GroupRoleId])

REFERENCES [dbo].[GroupTypeRole] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupRequirement] CHECK CONSTRAINT [FK_dbo.GroupRequirement_dbo.GroupTypeRole_GroupRoleId]

GO

ALTER TABLE [dbo].[GroupRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirement_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirement] CHECK CONSTRAINT [FK_dbo.GroupRequirement_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupRequirement_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupRequirement] CHECK CONSTRAINT [FK_dbo.GroupRequirement_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## GroupMemberRequirement
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupMemberRequirement](

[Id] [int] IDENTITY(1,1) NOT NULL,

[GroupMemberId] [int] NOT NULL,

[GroupRequirementId] [int] NOT NULL,

[RequirementMetDateTime] [datetime] NULL,

[LastRequirementCheckDateTime] [datetime] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[RequirementFailDateTime] [datetime] NULL,

[RequirementWarningDateTime] [datetime] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[DoesNotMeetWorkflowId] [int] NULL,

[WarningWorkflowId] [int] NULL,

[WasManuallyCompleted] [bit] NOT NULL,

[ManuallyCompletedByPersonAliasId] [int] NULL,

[ManuallyCompletedDateTime] [datetime] NULL,

[WasOverridden] [bit] NOT NULL,

[OverriddenByPersonAliasId] [int] NULL,

[OverriddenDateTime] [datetime] NULL,

[DueDate] [datetime] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] ADD CONSTRAINT [PK_dbo.GroupMemberRequirement] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupMemberRequirement]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DoesNotMeetWorkflowId] ON [dbo].[GroupMemberRequirement]

(

[DoesNotMeetWorkflowId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupMemberId] ON [dbo].[GroupMemberRequirement]

(

[GroupMemberId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupRequirementId] ON [dbo].[GroupMemberRequirement]

(

[GroupRequirementId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupMemberRequirement]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ManuallyCompletedByPersonAliasId] ON [dbo].[GroupMemberRequirement]

(

[ManuallyCompletedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupMemberRequirement]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_OverriddenByPersonAliasId] ON [dbo].[GroupMemberRequirement]

(

[OverriddenByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WarningWorkflowId] ON [dbo].[GroupMemberRequirement]

(

[WarningWorkflowId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] ADD DEFAULT ((0)) FOR [WasManuallyCompleted]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] ADD DEFAULT ((0)) FOR [WasOverridden]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.GroupMember_GroupMemberId] FOREIGN KEY([GroupMemberId])

REFERENCES [dbo].[GroupMember] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupMemberRequirement] CHECK CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.GroupMember_GroupMemberId]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.GroupRequirement_GroupRequirementId] FOREIGN KEY([GroupRequirementId])

REFERENCES [dbo].[GroupRequirement] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupMemberRequirement] CHECK CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.GroupRequirement_GroupRequirementId]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberRequirement] CHECK CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.PersonAlias_ManuallyCompletedByPersonAliasId] FOREIGN KEY([ManuallyCompletedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberRequirement] CHECK CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.PersonAlias_ManuallyCompletedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberRequirement] CHECK CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.PersonAlias_OverriddenByPersonAliasId] FOREIGN KEY([OverriddenByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberRequirement] CHECK CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.PersonAlias_OverriddenByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.Workflow_DoesNotMeetWorkflowId] FOREIGN KEY([DoesNotMeetWorkflowId])

REFERENCES [dbo].[Workflow] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberRequirement] CHECK CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.Workflow_DoesNotMeetWorkflowId]

GO

ALTER TABLE [dbo].[GroupMemberRequirement] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.Workflow_WarningWorkflowId] FOREIGN KEY([WarningWorkflowId])

REFERENCES [dbo].[Workflow] ([Id])

GO

ALTER TABLE [dbo].[GroupMemberRequirement] CHECK CONSTRAINT [FK_dbo.GroupMemberRequirement_dbo.Workflow_WarningWorkflowId]

GO
```