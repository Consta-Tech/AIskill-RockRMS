# ConnectionType and Status

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Connection framework type-level configuration — types, statuses, automations, and workflows.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## ConnectionType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[Description] [nvarchar](max) NULL,

[IconCssClass] [nvarchar](100) NULL,

[EnableFutureFollowup] [bit] NOT NULL,

[EnableFullActivityList] [bit] NOT NULL,

[OwnerPersonAliasId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[RequiresPlacementGroupToConnect] [bit] NOT NULL,

[DaysUntilRequestIdle] [int] NOT NULL,

[IsActive] [bit] NOT NULL,

[EnableRequestSecurity] [bit] NOT NULL,

[ConnectionRequestDetailPageId] [int] NULL,

[ConnectionRequestDetailPageRouteId] [int] NULL,

[DefaultView] [int] NOT NULL,

[RequestHeaderLava] [nvarchar](max) NULL,

[RequestBadgeLava] [nvarchar](max) NULL,

[Order] [int] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionType] ADD CONSTRAINT [PK_dbo.ConnectionType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionRequestDetailPageId] ON [dbo].[ConnectionType]

(

[ConnectionRequestDetailPageId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionRequestDetailPageRouteId] ON [dbo].[ConnectionType]

(

[ConnectionRequestDetailPageRouteId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_OwnerPersonAliasId] ON [dbo].[ConnectionType]

(

[OwnerPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionType] ADD DEFAULT ((0)) FOR [RequiresPlacementGroupToConnect]

GO

ALTER TABLE [dbo].[ConnectionType] ADD DEFAULT ((0)) FOR [DaysUntilRequestIdle]

GO

ALTER TABLE [dbo].[ConnectionType] ADD DEFAULT ((0)) FOR [IsActive]

GO

ALTER TABLE [dbo].[ConnectionType] ADD DEFAULT ((0)) FOR [EnableRequestSecurity]

GO

ALTER TABLE [dbo].[ConnectionType] ADD DEFAULT ((0)) FOR [DefaultView]

GO

ALTER TABLE [dbo].[ConnectionType] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[ConnectionType] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionType_dbo.Page_ConnectionRequestDetailPageId] FOREIGN KEY([ConnectionRequestDetailPageId])

REFERENCES [dbo].[Page] ([Id])

GO

ALTER TABLE [dbo].[ConnectionType] CHECK CONSTRAINT [FK_dbo.ConnectionType_dbo.Page_ConnectionRequestDetailPageId]

GO

ALTER TABLE [dbo].[ConnectionType] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionType_dbo.PageRoute_ConnectionRequestDetailPageRouteId] FOREIGN KEY([ConnectionRequestDetailPageRouteId])

REFERENCES [dbo].[PageRoute] ([Id])

GO

ALTER TABLE [dbo].[ConnectionType] CHECK CONSTRAINT [FK_dbo.ConnectionType_dbo.PageRoute_ConnectionRequestDetailPageRouteId]

GO

ALTER TABLE [dbo].[ConnectionType] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionType] CHECK CONSTRAINT [FK_dbo.ConnectionType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionType] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionType] CHECK CONSTRAINT [FK_dbo.ConnectionType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionType] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionType_dbo.PersonAlias_OwnerPersonAliasId] FOREIGN KEY([OwnerPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionType] CHECK CONSTRAINT [FK_dbo.ConnectionType_dbo.PersonAlias_OwnerPersonAliasId]

GO
```


## ConnectionStatus
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionStatus](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[Description] [nvarchar](max) NULL,

[ConnectionTypeId] [int] NULL,

[IsCritical] [bit] NOT NULL,

[IsDefault] [bit] NOT NULL,

[IsActive] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[AutoInactivateState] [bit] NOT NULL,

[Order] [int] NOT NULL,

[HighlightColor] [nvarchar](50) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionStatus] ADD CONSTRAINT [PK_dbo.ConnectionStatus] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionTypeId] ON [dbo].[ConnectionStatus]

(

[ConnectionTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionStatus]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionStatus]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionStatus]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionStatus] ADD DEFAULT ((0)) FOR [AutoInactivateState]

GO

ALTER TABLE [dbo].[ConnectionStatus] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[ConnectionStatus] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionStatus_dbo.ConnectionType_ConnectionTypeId] FOREIGN KEY([ConnectionTypeId])

REFERENCES [dbo].[ConnectionType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionStatus] CHECK CONSTRAINT [FK_dbo.ConnectionStatus_dbo.ConnectionType_ConnectionTypeId]

GO

ALTER TABLE [dbo].[ConnectionStatus] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionStatus_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionStatus] CHECK CONSTRAINT [FK_dbo.ConnectionStatus_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionStatus] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionStatus_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionStatus] CHECK CONSTRAINT [FK_dbo.ConnectionStatus_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ConnectionStatusAutomation
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionStatusAutomation](

[Id] [int] IDENTITY(1,1) NOT NULL,

[AutomationName] [nvarchar](50) NOT NULL,

[SourceStatusId] [int] NOT NULL,

[DestinationStatusId] [int] NOT NULL,

[DataViewId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[GroupRequirementsFilter] [int] NOT NULL,

[Order] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] ADD CONSTRAINT [PK_dbo.ConnectionStatusAutomation] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionStatusAutomation]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DataViewId] ON [dbo].[ConnectionStatusAutomation]

(

[DataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DestinationStatusId] ON [dbo].[ConnectionStatusAutomation]

(

[DestinationStatusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionStatusAutomation]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionStatusAutomation]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SourceStatusId] ON [dbo].[ConnectionStatusAutomation]

(

[SourceStatusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] ADD DEFAULT ((0)) FOR [GroupRequirementsFilter]

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.ConnectionStatus_DestinationStatusId] FOREIGN KEY([DestinationStatusId])

REFERENCES [dbo].[ConnectionStatus] ([Id])

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] CHECK CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.ConnectionStatus_DestinationStatusId]

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.ConnectionStatus_SourceStatusId] FOREIGN KEY([SourceStatusId])

REFERENCES [dbo].[ConnectionStatus] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] CHECK CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.ConnectionStatus_SourceStatusId]

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.DataView_DataViewId] FOREIGN KEY([DataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] CHECK CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.DataView_DataViewId]

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] CHECK CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionStatusAutomation] CHECK CONSTRAINT [FK_dbo.ConnectionStatusAutomation_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ConnectionWorkflow
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionWorkflow](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ConnectionTypeId] [int] NULL,

[ConnectionOpportunityId] [int] NULL,

[WorkflowTypeId] [int] NOT NULL,

[TriggerType] [int] NOT NULL,

[QualifierValue] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[ManualTriggerFilterConnectionStatusId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionWorkflow] ADD CONSTRAINT [PK_dbo.ConnectionWorkflow] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionOpportunityId] ON [dbo].[ConnectionWorkflow]

(

[ConnectionOpportunityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionTypeId] ON [dbo].[ConnectionWorkflow]

(

[ConnectionTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionWorkflow]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionWorkflow]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ManualTriggerFilterConnectionStatusId] ON [dbo].[ConnectionWorkflow]

(

[ManualTriggerFilterConnectionStatusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionWorkflow]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowTypeId] ON [dbo].[ConnectionWorkflow]

(

[WorkflowTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.ConnectionOpportunity_ConnectionOpportunityId] FOREIGN KEY([ConnectionOpportunityId])

REFERENCES [dbo].[ConnectionOpportunity] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.ConnectionOpportunity_ConnectionOpportunityId]

GO

ALTER TABLE [dbo].[ConnectionWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.ConnectionStatus_ManualTriggerFilterConnectionStatusId] FOREIGN KEY([ManualTriggerFilterConnectionStatusId])

REFERENCES [dbo].[ConnectionStatus] ([Id])

GO

ALTER TABLE [dbo].[ConnectionWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.ConnectionStatus_ManualTriggerFilterConnectionStatusId]

GO

ALTER TABLE [dbo].[ConnectionWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.ConnectionType_ConnectionTypeId] FOREIGN KEY([ConnectionTypeId])

REFERENCES [dbo].[ConnectionType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.ConnectionType_ConnectionTypeId]

GO

ALTER TABLE [dbo].[ConnectionWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.WorkflowType_WorkflowTypeId] FOREIGN KEY([WorkflowTypeId])

REFERENCES [dbo].[WorkflowType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionWorkflow_dbo.WorkflowType_WorkflowTypeId]

GO
```