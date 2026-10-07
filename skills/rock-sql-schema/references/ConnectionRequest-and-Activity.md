# ConnectionRequest and Activity

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Connection request processing and activity tracking.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| ConnectionRequest | A person's request for an opportunity, with its state, status, connector, and placement group | Campus, ConnectionOpportunity (CASCADE), ConnectionStatus, ConnectionType, Group, PersonAlias (many) |
| ConnectionRequestWorkflow | Workflow instances launched for a connection request | ConnectionRequest (CASCADE), ConnectionWorkflow, Workflow |
| ConnectionActivityType | Activity types available for logging against requests of a ConnectionType | ConnectionType (CASCADE) |
| ConnectionRequestActivity | Logged activity (notes, contacts, assignments) on a connection request | ConnectionActivityType, ConnectionOpportunity, ConnectionRequest, PersonAlias |

---

## ConnectionRequest
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionRequest](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ConnectionOpportunityId] [int] NOT NULL,

[PersonAliasId] [int] NOT NULL,

[Comments] [nvarchar](max) NULL,

[ConnectionStatusId] [int] NOT NULL,

[ConnectionState] [int] NOT NULL,

[FollowupDate] [datetime] NULL,

[CampusId] [int] NULL,

[AssignedGroupId] [int] NULL,

[ConnectorPersonAliasId] [int] NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[AssignedGroupMemberRoleId] [int] NULL,

[AssignedGroupMemberStatus] [int] NULL,

[AssignedGroupMemberAttributeValues] [nvarchar](max) NULL,

[CreatedDateKey] [int] NULL,

[Order] [int] NOT NULL,

[ConnectionTypeId] [int] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionRequest] ADD CONSTRAINT [PK_dbo.ConnectionRequest] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AssignedGroupId] ON [dbo].[ConnectionRequest]

(

[AssignedGroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[ConnectionRequest]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionOpportunityId] ON [dbo].[ConnectionRequest]

(

[ConnectionOpportunityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionStatusId] ON [dbo].[ConnectionRequest]

(

[ConnectionStatusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionTypeId] ON [dbo].[ConnectionRequest]

(

[ConnectionTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectorPersonAliasId] ON [dbo].[ConnectionRequest]

(

[ConnectorPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionRequest]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedDateKey] ON [dbo].[ConnectionRequest]

(

[CreatedDateKey] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionRequest]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionRequest]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[ConnectionRequest]

(

[PersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionRequest] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.ConnectionOpportunity_ConnectionOpportunityId] FOREIGN KEY([ConnectionOpportunityId])

REFERENCES [dbo].[ConnectionOpportunity] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.ConnectionOpportunity_ConnectionOpportunityId]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.ConnectionStatus_ConnectionStatusId] FOREIGN KEY([ConnectionStatusId])

REFERENCES [dbo].[ConnectionStatus] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.ConnectionStatus_ConnectionStatusId]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.ConnectionType_ConnectionTypeId] FOREIGN KEY([ConnectionTypeId])

REFERENCES [dbo].[ConnectionType] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.ConnectionType_ConnectionTypeId]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.Group_AssignedGroupId] FOREIGN KEY([AssignedGroupId])

REFERENCES [dbo].[Group] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.Group_AssignedGroupId]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.PersonAlias_ConnectorPersonAliasId] FOREIGN KEY([ConnectorPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.PersonAlias_ConnectorPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionRequest] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequest_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequest] CHECK CONSTRAINT [FK_dbo.ConnectionRequest_dbo.PersonAlias_PersonAliasId]

GO
```


## ConnectionRequestWorkflow
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionRequestWorkflow](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ConnectionRequestId] [int] NOT NULL,

[ConnectionWorkflowId] [int] NOT NULL,

[WorkflowId] [int] NOT NULL,

[TriggerType] [int] NOT NULL,

[TriggerQualifier] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] ADD CONSTRAINT [PK_dbo.ConnectionRequestWorkflow] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionRequestId] ON [dbo].[ConnectionRequestWorkflow]

(

[ConnectionRequestId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionWorkflowId] ON [dbo].[ConnectionRequestWorkflow]

(

[ConnectionWorkflowId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionRequestWorkflow]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionRequestWorkflow]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionRequestWorkflow]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_WorkflowId] ON [dbo].[ConnectionRequestWorkflow]

(

[WorkflowId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.ConnectionRequest_ConnectionRequestId] FOREIGN KEY([ConnectionRequestId])

REFERENCES [dbo].[ConnectionRequest] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.ConnectionRequest_ConnectionRequestId]

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.ConnectionWorkflow_ConnectionWorkflowId] FOREIGN KEY([ConnectionWorkflowId])

REFERENCES [dbo].[ConnectionWorkflow] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.ConnectionWorkflow_ConnectionWorkflowId]

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.Workflow_WorkflowId] FOREIGN KEY([WorkflowId])

REFERENCES [dbo].[Workflow] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestWorkflow] CHECK CONSTRAINT [FK_dbo.ConnectionRequestWorkflow_dbo.Workflow_WorkflowId]

GO
```


## ConnectionActivityType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionActivityType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[ConnectionTypeId] [int] NULL,

[IsActive] [bit] NOT NULL,

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

ALTER TABLE [dbo].[ConnectionActivityType] ADD CONSTRAINT [PK_dbo.ConnectionActivityType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionTypeId] ON [dbo].[ConnectionActivityType]

(

[ConnectionTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionActivityType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionActivityType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionActivityType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionActivityType] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionActivityType_dbo.ConnectionType_ConnectionTypeId] FOREIGN KEY([ConnectionTypeId])

REFERENCES [dbo].[ConnectionType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionActivityType] CHECK CONSTRAINT [FK_dbo.ConnectionActivityType_dbo.ConnectionType_ConnectionTypeId]

GO

ALTER TABLE [dbo].[ConnectionActivityType] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionActivityType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionActivityType] CHECK CONSTRAINT [FK_dbo.ConnectionActivityType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionActivityType] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionActivityType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionActivityType] CHECK CONSTRAINT [FK_dbo.ConnectionActivityType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ConnectionRequestActivity
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionRequestActivity](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ConnectionRequestId] [int] NOT NULL,

[ConnectionActivityTypeId] [int] NOT NULL,

[ConnectorPersonAliasId] [int] NULL,

[ConnectionOpportunityId] [int] NOT NULL,

[Note] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] ADD CONSTRAINT [PK_dbo.ConnectionRequestActivity] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionActivityTypeId] ON [dbo].[ConnectionRequestActivity]

(

[ConnectionActivityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionOpportunityId] ON [dbo].[ConnectionRequestActivity]

(

[ConnectionOpportunityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionRequestId] ON [dbo].[ConnectionRequestActivity]

(

[ConnectionRequestId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectorPersonAliasId] ON [dbo].[ConnectionRequestActivity]

(

[ConnectorPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionRequestActivity]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionRequestActivity]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionRequestActivity]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.ConnectionActivityType_ConnectionActivityTypeId] FOREIGN KEY([ConnectionActivityTypeId])

REFERENCES [dbo].[ConnectionActivityType] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] CHECK CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.ConnectionActivityType_ConnectionActivityTypeId]

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.ConnectionOpportunity_ConnectionOpportunityId] FOREIGN KEY([ConnectionOpportunityId])

REFERENCES [dbo].[ConnectionOpportunity] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] CHECK CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.ConnectionOpportunity_ConnectionOpportunityId]

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.ConnectionRequest_ConnectionRequestId] FOREIGN KEY([ConnectionRequestId])

REFERENCES [dbo].[ConnectionRequest] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] CHECK CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.ConnectionRequest_ConnectionRequestId]

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.PersonAlias_ConnectorPersonAliasId] FOREIGN KEY([ConnectorPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] CHECK CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.PersonAlias_ConnectorPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] CHECK CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionRequestActivity] CHECK CONSTRAINT [FK_dbo.ConnectionRequestActivity_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```