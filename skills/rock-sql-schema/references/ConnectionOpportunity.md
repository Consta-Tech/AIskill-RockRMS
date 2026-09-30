# ConnectionOpportunity

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Connection opportunities and placement configuration.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## ConnectionOpportunity
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionOpportunity](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[PublicName] [nvarchar](50) NOT NULL,

[Description] [nvarchar](max) NULL,

[PhotoId] [int] NULL,

[ConnectionTypeId] [int] NOT NULL,

[IconCssClass] [nvarchar](100) NULL,

[IsActive] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[Summary] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[Order] [int] NOT NULL,

[ShowStatusOnTransfer] [bit] NOT NULL,

[ShowConnectButton] [bit] NOT NULL,

[ShowCampusOnTransfer] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] ADD CONSTRAINT [PK_dbo.ConnectionOpportunity] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionTypeId] ON [dbo].[ConnectionOpportunity]

(

[ConnectionTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionOpportunity]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionOpportunity]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionOpportunity]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PhotoId] ON [dbo].[ConnectionOpportunity]

(

[PhotoId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] ADD DEFAULT ((0)) FOR [ShowStatusOnTransfer]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] ADD DEFAULT ((0)) FOR [ShowConnectButton]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] ADD DEFAULT ((0)) FOR [ShowCampusOnTransfer]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunity_dbo.BinaryFile_PhotoId] FOREIGN KEY([PhotoId])

REFERENCES [dbo].[BinaryFile] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunity] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunity_dbo.BinaryFile_PhotoId]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunity_dbo.ConnectionType_ConnectionTypeId] FOREIGN KEY([ConnectionTypeId])

REFERENCES [dbo].[ConnectionType] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunity] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunity_dbo.ConnectionType_ConnectionTypeId]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunity_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunity] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunity_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionOpportunity] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunity_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunity] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunity_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ConnectionOpportunityCampus
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionOpportunityCampus](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ConnectionOpportunityId] [int] NOT NULL,

[CampusId] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[DefaultConnectorPersonAliasId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] ADD CONSTRAINT [PK_dbo.ConnectionOpportunityCampus] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[ConnectionOpportunityCampus]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionOpportunityId] ON [dbo].[ConnectionOpportunityCampus]

(

[ConnectionOpportunityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionOpportunityCampus]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DefaultConnectorPersonAliasId] ON [dbo].[ConnectionOpportunityCampus]

(

[DefaultConnectorPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionOpportunityCampus]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionOpportunityCampus]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.ConnectionOpportunity_ConnectionOpportunityId] FOREIGN KEY([ConnectionOpportunityId])

REFERENCES [dbo].[ConnectionOpportunity] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.ConnectionOpportunity_ConnectionOpportunityId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.PersonAlias_DefaultConnectorPersonAliasId] FOREIGN KEY([DefaultConnectorPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.PersonAlias_DefaultConnectorPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityCampus] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityCampus_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ConnectionOpportunityConnectorGroup
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionOpportunityConnectorGroup](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ConnectionOpportunityId] [int] NOT NULL,

[CampusId] [int] NULL,

[ConnectorGroupId] [int] NOT NULL,

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

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] ADD CONSTRAINT [PK_dbo.ConnectionOpportunityConnectorGroup] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CampusId] ON [dbo].[ConnectionOpportunityConnectorGroup]

(

[CampusId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionOpportunityId] ON [dbo].[ConnectionOpportunityConnectorGroup]

(

[ConnectionOpportunityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectorGroupId] ON [dbo].[ConnectionOpportunityConnectorGroup]

(

[ConnectorGroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionOpportunityConnectorGroup]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionOpportunityConnectorGroup]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionOpportunityConnectorGroup]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.Campus_CampusId] FOREIGN KEY([CampusId])

REFERENCES [dbo].[Campus] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.Campus_CampusId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.ConnectionOpportunity_ConnectionOpportunityId] FOREIGN KEY([ConnectionOpportunityId])

REFERENCES [dbo].[ConnectionOpportunity] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.ConnectionOpportunity_ConnectionOpportunityId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.Group_ConnectorGroupId] FOREIGN KEY([ConnectorGroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.Group_ConnectorGroupId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityConnectorGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupCampus_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ConnectionOpportunityGroupConfig
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionOpportunityGroupConfig](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ConnectionOpportunityId] [int] NOT NULL,

[GroupTypeId] [int] NOT NULL,

[GroupMemberRoleId] [int] NULL,

[GroupMemberStatus] [int] NOT NULL,

[UseAllGroupsOfType] [bit] NOT NULL,

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

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] ADD CONSTRAINT [PK_dbo.ConnectionOpportunityGroupConfig] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionOpportunityId] ON [dbo].[ConnectionOpportunityGroupConfig]

(

[ConnectionOpportunityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionOpportunityGroupConfig]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupMemberRoleId] ON [dbo].[ConnectionOpportunityGroupConfig]

(

[GroupMemberRoleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupTypeId] ON [dbo].[ConnectionOpportunityGroupConfig]

(

[GroupTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionOpportunityGroupConfig]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionOpportunityGroupConfig]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.ConnectionOpportunity_ConnectionOpportunityId] FOREIGN KEY([ConnectionOpportunityId])

REFERENCES [dbo].[ConnectionOpportunity] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.ConnectionOpportunity_ConnectionOpportunityId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.GroupType_GroupTypeId] FOREIGN KEY([GroupTypeId])

REFERENCES [dbo].[GroupType] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.GroupType_GroupTypeId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.GroupTypeRole_GroupMemberRoleId] FOREIGN KEY([GroupMemberRoleId])

REFERENCES [dbo].[GroupTypeRole] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.GroupTypeRole_GroupMemberRoleId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroupConfig] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroupConfig_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ConnectionOpportunityGroup
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ConnectionOpportunityGroup](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ConnectionOpportunityId] [int] NOT NULL,

[GroupId] [int] NOT NULL,

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

ALTER TABLE [dbo].[ConnectionOpportunityGroup] ADD CONSTRAINT [PK_dbo.ConnectionOpportunityGroup] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ConnectionOpportunityId] ON [dbo].[ConnectionOpportunityGroup]

(

[ConnectionOpportunityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ConnectionOpportunityGroup]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_GroupId] ON [dbo].[ConnectionOpportunityGroup]

(

[GroupId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ConnectionOpportunityGroup]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ConnectionOpportunityGroup]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroup_dbo.ConnectionOpportunity_ConnectionOpportunityId] FOREIGN KEY([ConnectionOpportunityId])

REFERENCES [dbo].[ConnectionOpportunity] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroup_dbo.ConnectionOpportunity_ConnectionOpportunityId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroup_dbo.Group_GroupId] FOREIGN KEY([GroupId])

REFERENCES [dbo].[Group] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroup_dbo.Group_GroupId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroup_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroup_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroup] WITH CHECK ADD CONSTRAINT [FK_dbo.ConnectionOpportunityGroup_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ConnectionOpportunityGroup] CHECK CONSTRAINT [FK_dbo.ConnectionOpportunityGroup_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```