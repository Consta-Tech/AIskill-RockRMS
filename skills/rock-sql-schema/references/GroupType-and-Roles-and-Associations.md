# GroupType, Roles, and Associations

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Group taxonomy configuration — types, roles, associations, and location types.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| GroupType | Group taxonomy — behavior and settings shared by every group of the type | DefinedType, DefinedValue, GroupType (self-referencing), GroupTypeRole, SystemCommunication (many), SystemEmail (many), WorkflowType |
| GroupTypeAssociation | Which group types are allowed as children of a group type (can contain cycles) | GroupType (many) |
| GroupTypeRole | Roles available to members of groups of this type (e.g., Leader, Member) | GroupType (CASCADE) |
| GroupTypeLocationType | Location types allowed for groups of this type | DefinedValue (CASCADE), GroupType (CASCADE) |

---

## GroupType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[GroupTerm] [nvarchar](100) NOT NULL,

[GroupMemberTerm] [nvarchar](100) NOT NULL,

[DefaultGroupRoleId] [int] NULL,

[AllowMultipleLocations] [bit] NOT NULL,

[ShowInGroupList] [bit] NOT NULL,

[ShowInNavigation] [bit] NOT NULL,

[IconCssClass] [nvarchar](100) NULL,

[TakesAttendance] [bit] NOT NULL,

[AttendanceRule] [int] NOT NULL,

[AttendancePrintTo] [int] NOT NULL,

[Order] [int] NOT NULL,

[InheritedGroupTypeId] [int] NULL,

[LocationSelectionMode] [int] NOT NULL,

[GroupTypePurposeValueId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[EnableLocationSchedules] [bit] NULL,

[AllowedScheduleTypes] [int] NOT NULL,

[SendAttendanceReminder] [bit] NOT NULL,

[IgnorePersonInactivated] [bit] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[ShowConnectionStatus] [bit] NOT NULL,

[AttendanceCountsAsWeekendService] [bit] NOT NULL,

[GroupCapacityRule] [int] NOT NULL,

[GroupsRequireCampus] [bit] NOT NULL,

[GroupAttendanceRequiresLocation] [bit] NOT NULL,

[GroupAttendanceRequiresSchedule] [bit] NOT NULL,

[IsIndexEnabled] [bit] NOT NULL,

[ShowMaritalStatus] [bit] NOT NULL,

[GroupViewLavaTemplate] [nvarchar](max) NULL,

[AllowSpecificGroupMemberAttributes] [bit] NOT NULL,

[EnableSpecificGroupRequirements] [bit] NOT NULL,

[AllowGroupSync] [bit] NOT NULL,

[AllowSpecificGroupMemberWorkflows] [bit] NOT NULL,

[EnableGroupHistory] [bit] NOT NULL,

[GroupTypeColor] [nvarchar](100) NULL,

[GroupStatusDefinedTypeId] [int] NULL,

[AdministratorTerm] [nvarchar](100) NULL,

[ShowAdministrator] [bit] NOT NULL,

[EnableGroupTag] [bit] NOT NULL,

[IsSchedulingEnabled] [bit] NOT NULL,

[ScheduleConfirmationSystemEmailId] [int] NULL,

[ScheduleReminderSystemEmailId] [int] NULL,

[ScheduleCancellationWorkflowTypeId] [int] NULL,

[ScheduleConfirmationEmailOffsetDays] [int] NULL,

[ScheduleReminderEmailOffsetDays] [int] NULL,

[RequiresReasonIfDeclineSchedule] [bit] NOT NULL,

[EnableRSVP] [bit] NOT NULL,

[EnableInactiveReason] [bit] NOT NULL,

[RequiresInactiveReason] [bit] NOT NULL,

[AllowAnyChildGroupType] [bit] NOT NULL,

[ScheduleConfirmationSystemCommunicationId] [int] NULL,

[ScheduleReminderSystemCommunicationId] [int] NULL,

[RSVPReminderSystemCommunicationId] [int] NULL,

[RSVPReminderOffsetDays] [int] NULL,

[IsCapacityRequired] [bit] NOT NULL,

[ScheduleConfirmationLogic] [int] NOT NULL,

[AttendanceReminderSystemCommunicationId] [int] NULL,

[AttendanceReminderSendStartOffsetMinutes] [int] NULL,

[AttendanceReminderFollowupDays] [nvarchar](100) NULL,

[IsPeerNetworkEnabled] [bit] NOT NULL,

[RelationshipGrowthEnabled] [bit] NOT NULL,

[RelationshipStrength] [int] NOT NULL,

[LeaderToLeaderRelationshipMultiplier] [decimal](8, 2) NOT NULL,

[LeaderToNonLeaderRelationshipMultiplier] [decimal](8, 2) NOT NULL,

[NonLeaderToNonLeaderRelationshipMultiplier] [decimal](8, 2) NOT NULL,

[NonLeaderToLeaderRelationshipMultiplier] [decimal](8, 2) NOT NULL,

[AlreadyEnrolledMatchingLogic] [int] NOT NULL,

[ScheduleCoordinatorNotificationTypes] [int] NULL,

[IsConcurrentCheckInPrevented] [bit] NOT NULL,

[IsChatAllowed] [bit] NOT NULL,

[IsChatEnabledForAllGroups] [bit] NOT NULL,

[IsLeavingChatChannelAllowed] [bit] NOT NULL,

[IsChatChannelPublic] [bit] NOT NULL,

[IsChatChannelAlwaysShown] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupType] ADD CONSTRAINT [PK_dbo.GroupType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttendanceReminderSystemCommunicationId] ON [dbo].[GroupType]

(

[AttendanceReminderSystemCommunicationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DefaultGroupRoleId] ON [dbo].[GroupType]

(

[DefaultGroupRoleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupStatusDefinedTypeId] ON [dbo].[GroupType]

(

[GroupStatusDefinedTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypePurposeValueId] ON [dbo].[GroupType]

(

[GroupTypePurposeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_InheritedGroupTypeId] ON [dbo].[GroupType]

(

[InheritedGroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleCancellationWorkflowTypeId] ON [dbo].[GroupType]

(

[ScheduleCancellationWorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleConfirmationSystemEmailId] ON [dbo].[GroupType]

(

[ScheduleConfirmationSystemEmailId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ScheduleReminderSystemEmailId] ON [dbo].[GroupType]

(

[ScheduleReminderSystemEmailId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [AllowedScheduleTypes]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [SendAttendanceReminder]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IgnorePersonInactivated]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [ShowConnectionStatus]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [AttendanceCountsAsWeekendService]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [GroupCapacityRule]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [GroupsRequireCampus]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [GroupAttendanceRequiresLocation]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [GroupAttendanceRequiresSchedule]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsIndexEnabled]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [ShowMaritalStatus]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [AllowSpecificGroupMemberAttributes]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [EnableSpecificGroupRequirements]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [AllowGroupSync]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [AllowSpecificGroupMemberWorkflows]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [EnableGroupHistory]

GO

ALTER TABLE [dbo].[GroupType] ADD CONSTRAINT [DF__GroupType__AdministratorTerm] DEFAULT ('Administrator') FOR [AdministratorTerm]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [ShowAdministrator]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [EnableGroupTag]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsSchedulingEnabled]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [RequiresReasonIfDeclineSchedule]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [EnableRSVP]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [EnableInactiveReason]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [RequiresInactiveReason]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [AllowAnyChildGroupType]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsCapacityRequired]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [ScheduleConfirmationLogic]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsPeerNetworkEnabled]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [RelationshipGrowthEnabled]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [RelationshipStrength]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((1.0)) FOR [LeaderToLeaderRelationshipMultiplier]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((1.0)) FOR [LeaderToNonLeaderRelationshipMultiplier]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((1.0)) FOR [NonLeaderToNonLeaderRelationshipMultiplier]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((1.0)) FOR [NonLeaderToLeaderRelationshipMultiplier]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [AlreadyEnrolledMatchingLogic]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsConcurrentCheckInPrevented]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsChatAllowed]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsChatEnabledForAllGroups]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsLeavingChatChannelAllowed]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsChatChannelPublic]

GO

ALTER TABLE [dbo].[GroupType] ADD DEFAULT ((0)) FOR [IsChatChannelAlwaysShown]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.DefinedType_GroupStatusDefinedTypeId] FOREIGN KEY([GroupStatusDefinedTypeId])

REFERENCES [dbo].[DefinedType] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.DefinedType_GroupStatusDefinedTypeId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.DefinedValue_GroupTypePurposeValueId] FOREIGN KEY([GroupTypePurposeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.DefinedValue_GroupTypePurposeValueId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.GroupType_InheritedGroupTypeId] FOREIGN KEY([InheritedGroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.GroupType_InheritedGroupTypeId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.GroupTypeRole_DefaultGroupRoleId] FOREIGN KEY([DefaultGroupRoleId])

REFERENCES [dbo].[GroupTypeRole] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.GroupTypeRole_DefaultGroupRoleId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.SystemCommunication_AttendanceReminderSystemCommunicationId] FOREIGN KEY([AttendanceReminderSystemCommunicationId])

REFERENCES [dbo].[SystemCommunication] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.SystemCommunication_AttendanceReminderSystemCommunicationId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.SystemCommunication_ScheduleConfirmationSystemCommunicationId] FOREIGN KEY([ScheduleConfirmationSystemCommunicationId])

REFERENCES [dbo].[SystemCommunication] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.SystemCommunication_ScheduleConfirmationSystemCommunicationId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.SystemCommunication_ScheduleReminderSystemCommunicationId] FOREIGN KEY([ScheduleReminderSystemCommunicationId])

REFERENCES [dbo].[SystemCommunication] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.SystemCommunication_ScheduleReminderSystemCommunicationId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.SystemEmail_ScheduleConfirmationSystemEmailId] FOREIGN KEY([ScheduleConfirmationSystemEmailId])

REFERENCES [dbo].[SystemEmail] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.SystemEmail_ScheduleConfirmationSystemEmailId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.SystemEmail_ScheduleReminderSystemEmailId] FOREIGN KEY([ScheduleReminderSystemEmailId])

REFERENCES [dbo].[SystemEmail] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.SystemEmail_ScheduleReminderSystemEmailId]

GO

ALTER TABLE [dbo].[GroupType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupType_dbo.WorkflowType_ScheduleCancellationWorkflowTypeId] FOREIGN KEY([ScheduleCancellationWorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

GO

ALTER TABLE [dbo].[GroupType] CHECK CONSTRAINT [FK_dbo.GroupType_dbo.WorkflowType_ScheduleCancellationWorkflowTypeId]

GO
```


## GroupTypeAssociation
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupTypeAssociation](

[GroupTypeId] [int] NOT NULL,

[ChildGroupTypeId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupTypeAssociation] ADD CONSTRAINT [PK_dbo.GroupTypeAssociation] PRIMARY KEY CLUSTERED

(

[GroupTypeId] ASC,

[ChildGroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ChildGroupTypeId] ON [dbo].[GroupTypeAssociation]

(

[ChildGroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[GroupTypeAssociation]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupTypeAssociation] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupTypeAssociation_dbo.GroupType_ChildGroupTypeId] FOREIGN KEY([ChildGroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[GroupTypeAssociation] CHECK CONSTRAINT [FK_dbo.GroupTypeAssociation_dbo.GroupType_ChildGroupTypeId]

GO

ALTER TABLE [dbo].[GroupTypeAssociation] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupTypeAssociation_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[GroupTypeAssociation] CHECK CONSTRAINT [FK_dbo.GroupTypeAssociation_dbo.GroupType_GroupTypeId]

GO
```


## GroupTypeRole
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupTypeRole](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[GroupTypeId] [int] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[Order] [int] NOT NULL,

[MaxCount] [int] NULL,

[MinCount] [int] NULL,

[IsLeader] [bit] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[CanView] [bit] NOT NULL,

[CanEdit] [bit] NOT NULL,

[ReceiveRequirementsNotifications] [bit] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[CanManageMembers] [bit] NOT NULL,

[IsExcludedFromPeerNetwork] [bit] NOT NULL,

[IsCheckInAllowed] [bit] NOT NULL,

[ChatRole] [int] NOT NULL,

[CanTakeAttendance] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD CONSTRAINT [PK_dbo.GroupTypeRole] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[GroupTypeRole]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[GroupTypeRole]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[GroupTypeRole]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[GroupTypeRole]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD DEFAULT ((0)) FOR [CanView]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD DEFAULT ((0)) FOR [CanEdit]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD DEFAULT ((0)) FOR [ReceiveRequirementsNotifications]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD DEFAULT ((0)) FOR [CanManageMembers]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD DEFAULT ((0)) FOR [IsExcludedFromPeerNetwork]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD CONSTRAINT [DF_dbo.GroupTypeRole_IsCheckInAllowed] DEFAULT ((1)) FOR [IsCheckInAllowed]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD DEFAULT ((0)) FOR [ChatRole]

GO

ALTER TABLE [dbo].[GroupTypeRole] ADD DEFAULT ((0)) FOR [CanTakeAttendance]

GO

ALTER TABLE [dbo].[GroupTypeRole] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupTypeRole_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupTypeRole] CHECK CONSTRAINT [FK_dbo.GroupTypeRole_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[GroupTypeRole] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupTypeRole_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupTypeRole] CHECK CONSTRAINT [FK_dbo.GroupTypeRole_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[GroupTypeRole] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupTypeRole_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[GroupTypeRole] CHECK CONSTRAINT [FK_dbo.GroupTypeRole_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## GroupTypeLocationType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[GroupTypeLocationType](

[GroupTypeId] [int] NOT NULL,

[LocationTypeValueId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupTypeLocationType] ADD CONSTRAINT [PK_dbo.GroupTypeLocationType] PRIMARY KEY CLUSTERED

(

[GroupTypeId] ASC,

[LocationTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GroupTypeLocationType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupTypeLocationType_dbo.DefinedValue_LocationTypeValueId] FOREIGN KEY([LocationTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupTypeLocationType] CHECK CONSTRAINT [FK_dbo.GroupTypeLocationType_dbo.DefinedValue_LocationTypeValueId]

GO

ALTER TABLE [dbo].[GroupTypeLocationType] WITH CHECK ADD CONSTRAINT [FK_dbo.GroupTypeLocationType_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[GroupTypeLocationType] CHECK CONSTRAINT [FK_dbo.GroupTypeLocationType_dbo.GroupType_GroupTypeId]

GO
```