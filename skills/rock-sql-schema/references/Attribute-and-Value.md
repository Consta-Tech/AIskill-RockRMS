# Attribute and Value

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



Attribute definitions, stored values, history, matrix (tabular) data, and entity reference tracking.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.
>
> For the conceptual distinction between Properties (table columns / C# model fields) and Attributes (EAV custom fields), see `skills/rock-blocktypes/references/Rock-Attribute-Property.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| Attribute | Defines custom fields for any entity type | EntityType, FieldType |
| AttributeCategory | Junction table linking attributes to categories | Attribute (CASCADE), Category (CASCADE) |
| AttributeQualifier | Configuration key/value pairs that constrain an attribute's field type behavior | Attribute (CASCADE) |
| AttributeValue | Stores actual data values for attributes on specific entity instances | Attribute (CASCADE) |
| AttributeValueHistorical | Point-in-time history of attribute value changes (SCD Type 2) | AttributeValue (CASCADE) |
| AttributeReferencedEntity | Tracks entities referenced within an attribute's default value or configuration | Attribute (CASCADE) |
| AttributeValueReferencedEntity | Tracks entities referenced within a specific attribute value's stored data | AttributeValue (CASCADE) |
| AttributeMatrixTemplate | Defines the column structure and constraints for matrix (tabular) attributes | — |
| AttributeMatrix | An instance of a matrix tied to a template | AttributeMatrixTemplate (CASCADE) |
| AttributeMatrixItem | Individual rows within an attribute matrix | AttributeMatrix, AttributeMatrixTemplate |

---

## Attribute
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Attribute](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[FieldTypeId] [int] NOT NULL,

[EntityTypeId] [int] NULL,

[EntityTypeQualifierColumn] [nvarchar](50) NULL,

[EntityTypeQualifierValue] [nvarchar](200) NULL,

[Key] [nvarchar](1000) NOT NULL,

[Name] [nvarchar](1000) NOT NULL,

[Description] [nvarchar](max) NULL,

[Order] [int] NOT NULL,

[IsGridColumn] [bit] NOT NULL,

[DefaultValue] [nvarchar](max) NULL,

[IsMultiValue] [bit] NOT NULL,

[IsRequired] [bit] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[IconCssClass] [nvarchar](100) NULL,

[AllowSearch] [bit] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsIndexEnabled] [bit] NOT NULL,

[IsAnalytic] [bit] NOT NULL,

[IsAnalyticHistory] [bit] NOT NULL,

[IsActive] [bit] NOT NULL,

[EnableHistory] [bit] NOT NULL,

[PreHtml] [nvarchar](max) NULL,

[PostHtml] [nvarchar](max) NULL,

[AbbreviatedName] [nvarchar](100) NULL,

[ShowOnBulk] [bit] NOT NULL,

[IsPublic] [bit] NOT NULL,

[AttributeColor] [nvarchar](100) NULL,

[DefaultPersistedTextValue] [nvarchar](max) NULL,

[DefaultPersistedHtmlValue] [nvarchar](max) NULL,

[DefaultPersistedCondensedTextValue] [nvarchar](max) NULL,

[DefaultPersistedCondensedHtmlValue] [nvarchar](max) NULL,

[IsDefaultPersistedValueDirty] [bit] NOT NULL,

[IsSuppressHistoryLogging] [bit] NOT NULL,

[DefaultValueChecksum] AS (checksum([DefaultValue])) PERSISTED,

[AdditionalSettingsJson] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Attribute] ADD CONSTRAINT [PK_dbo.Attribute] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Attribute]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ARITHABORT ON

SET CONCAT_NULL_YIELDS_NULL ON

SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS ON

SET ANSI_PADDING ON

SET ANSI_WARNINGS ON

SET NUMERIC_ROUNDABORT OFF

GO

CREATE NONCLUSTERED INDEX [IX_DefaultValueChecksum] ON [dbo].[Attribute]

(

[DefaultValueChecksum] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[Attribute]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId_EntityTypeQualifierColumn_EntityTypeQualifierValue_Key] ON [dbo].[Attribute]

(

[EntityTypeId] ASC,

[EntityTypeQualifierColumn] ASC,

[EntityTypeQualifierValue] ASC

)

INCLUDE([Key]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FieldTypeId] ON [dbo].[Attribute]

(

[FieldTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Attribute]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Attribute]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((0)) FOR [AllowSearch]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((0)) FOR [IsIndexEnabled]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((0)) FOR [IsAnalytic]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((0)) FOR [IsAnalyticHistory]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((1)) FOR [IsActive]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((0)) FOR [EnableHistory]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((0)) FOR [ShowOnBulk]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((0)) FOR [IsPublic]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((1)) FOR [IsDefaultPersistedValueDirty]

GO

ALTER TABLE [dbo].[Attribute] ADD DEFAULT ((0)) FOR [IsSuppressHistoryLogging]

GO

ALTER TABLE [dbo].[Attribute] WITH CHECK ADD CONSTRAINT [FK_dbo.Attribute_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[Attribute] CHECK CONSTRAINT [FK_dbo.Attribute_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[Attribute] WITH CHECK ADD CONSTRAINT [FK_dbo.Attribute_dbo.FieldType_FieldTypeId] FOREIGN KEY([FieldTypeId])

REFERENCES [dbo].[FieldType] ([Id])

GO

ALTER TABLE [dbo].[Attribute] CHECK CONSTRAINT [FK_dbo.Attribute_dbo.FieldType_FieldTypeId]

GO

ALTER TABLE [dbo].[Attribute] WITH CHECK ADD CONSTRAINT [FK_dbo.Attribute_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Attribute] CHECK CONSTRAINT [FK_dbo.Attribute_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Attribute] WITH CHECK ADD CONSTRAINT [FK_dbo.Attribute_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Attribute] CHECK CONSTRAINT [FK_dbo.Attribute_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## AttributeCategory
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeCategory](

[AttributeId] [int] NOT NULL,

[CategoryId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeCategory] ADD CONSTRAINT [PK_dbo.AttributeCategory] PRIMARY KEY CLUSTERED

(

[AttributeId] ASC,

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeId] ON [dbo].[AttributeCategory]

(

[AttributeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[AttributeCategory]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeCategory] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeCategory_dbo.Attribute_AttributeId] FOREIGN KEY([AttributeId])

REFERENCES [dbo].[Attribute] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttributeCategory] CHECK CONSTRAINT [FK_dbo.AttributeCategory_dbo.Attribute_AttributeId]

GO

ALTER TABLE [dbo].[AttributeCategory] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeCategory_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttributeCategory] CHECK CONSTRAINT [FK_dbo.AttributeCategory_dbo.Category_CategoryId]

GO
```


## AttributeQualifier
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeQualifier](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[AttributeId] [int] NOT NULL,

[Key] [nvarchar](100) NOT NULL,

[Value] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeQualifier] ADD CONSTRAINT [PK_dbo.AttributeQualifier] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_AttributeIdKey] ON [dbo].[AttributeQualifier]

(

[AttributeId] ASC,

[Key] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttributeQualifier]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeQualifier] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeQualifier_dbo.Attribute_AttributeId] FOREIGN KEY([AttributeId])

REFERENCES [dbo].[Attribute] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttributeQualifier] CHECK CONSTRAINT [FK_dbo.AttributeQualifier_dbo.Attribute_AttributeId]

GO
```


## AttributeValue
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeValue](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[AttributeId] [int] NOT NULL,

[EntityId] [int] NULL,

[Value] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ValueAsDateTime] [datetime] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[ValueAsNumeric] [decimal](18, 2) NULL,

[PersistedTextValue] [nvarchar](max) NULL,

[PersistedHtmlValue] [nvarchar](max) NULL,

[PersistedCondensedTextValue] [nvarchar](max) NULL,

[PersistedCondensedHtmlValue] [nvarchar](max) NULL,

[IsPersistedValueDirty] [bit] NOT NULL,

[ValueChecksum] AS (checksum([Value])),

[ValueAsBoolean] [bit] NULL,

[ValueAsPersonId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeValue] ADD CONSTRAINT [PK_dbo.AttributeValue] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeId] ON [dbo].[AttributeValue]

(

[AttributeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_AttributeIdEntityId] ON [dbo].[AttributeValue]

(

[AttributeId] ASC,

[EntityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[AttributeValue]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityId_AttributeId] ON [dbo].[AttributeValue]

(

[EntityId] ASC,

[AttributeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttributeValue]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[AttributeValue]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ValueAsBoolean] ON [dbo].[AttributeValue]

(

[ValueAsBoolean] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ValueAsDateTime] ON [dbo].[AttributeValue]

(

[ValueAsDateTime] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ValueAsNumeric] ON [dbo].[AttributeValue]

(

[ValueAsNumeric] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ValueAsPersonId] ON [dbo].[AttributeValue]

(

[ValueAsPersonId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ARITHABORT ON

SET CONCAT_NULL_YIELDS_NULL ON

SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS ON

SET ANSI_PADDING ON

SET ANSI_WARNINGS ON

SET NUMERIC_ROUNDABORT OFF

GO

CREATE NONCLUSTERED INDEX [IX_ValueChecksum] ON [dbo].[AttributeValue]

(

[ValueChecksum] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeValue] ADD DEFAULT ((1)) FOR [IsPersistedValueDirty]

GO

ALTER TABLE [dbo].[AttributeValue] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeValue_dbo.Attribute_AttributeId] FOREIGN KEY([AttributeId])

REFERENCES [dbo].[Attribute] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttributeValue] CHECK CONSTRAINT [FK_dbo.AttributeValue_dbo.Attribute_AttributeId]

GO

ALTER TABLE [dbo].[AttributeValue] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeValue_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeValue] CHECK CONSTRAINT [FK_dbo.AttributeValue_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[AttributeValue] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeValue_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeValue] CHECK CONSTRAINT [FK_dbo.AttributeValue_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## AttributeValueHistorical
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeValueHistorical](

[Id] [int] IDENTITY(1,1) NOT NULL,

[AttributeValueId] [int] NOT NULL,

[Value] [nvarchar](max) NULL,

[ValueFormatted] [nvarchar](max) NULL,

[ValueAsNumeric] [decimal](18, 2) NULL,

[ValueAsDateTime] [datetime] NULL,

[ValueAsBoolean] [bit] NULL,

[ValueAsPersonId] [int] NULL,

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

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeValueHistorical] ADD CONSTRAINT [PK_dbo.AttributeValueHistorical] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeValueId] ON [dbo].[AttributeValueHistorical]

(

[AttributeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_AttributeValueIdCurrentRow] ON [dbo].[AttributeValueHistorical]

(

[AttributeValueId] ASC,

[CurrentRowIndicator] ASC

)

WHERE ([CurrentRowIndicator]=(1))

WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[AttributeValueHistorical]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttributeValueHistorical]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[AttributeValueHistorical]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeValueHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeValueHistorical_dbo.AttributeValue_AttributeValueId] FOREIGN KEY([AttributeValueId])

REFERENCES [dbo].[AttributeValue] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttributeValueHistorical] CHECK CONSTRAINT [FK_dbo.AttributeValueHistorical_dbo.AttributeValue_AttributeValueId]

GO

ALTER TABLE [dbo].[AttributeValueHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeValueHistorical_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeValueHistorical] CHECK CONSTRAINT [FK_dbo.AttributeValueHistorical_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[AttributeValueHistorical] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeValueHistorical_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeValueHistorical] CHECK CONSTRAINT [FK_dbo.AttributeValueHistorical_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## AttributeReferencedEntity
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeReferencedEntity](

[Id] [bigint] IDENTITY(1,1) NOT NULL,

[AttributeId] [int] NOT NULL,

[EntityTypeId] [int] NOT NULL,

[EntityId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeReferencedEntity] ADD CONSTRAINT [PK_dbo.AttributeReferencedEntity] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeId] ON [dbo].[AttributeReferencedEntity]

(

[AttributeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId_EntityId] ON [dbo].[AttributeReferencedEntity]

(

[EntityTypeId] ASC,

[EntityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeReferencedEntity] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeReferencedEntity_dbo.Attribute_AttributeId] FOREIGN KEY([AttributeId])

REFERENCES [dbo].[Attribute] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttributeReferencedEntity] CHECK CONSTRAINT [FK_dbo.AttributeReferencedEntity_dbo.Attribute_AttributeId]

GO
```


## AttributeValueReferencedEntity
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeValueReferencedEntity](

[Id] [bigint] IDENTITY(1,1) NOT NULL,

[AttributeValueId] [int] NOT NULL,

[EntityTypeId] [int] NOT NULL,

[EntityId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeValueReferencedEntity] ADD CONSTRAINT [PK_dbo.AttributeValueReferencedEntity] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeValueId] ON [dbo].[AttributeValueReferencedEntity]

(

[AttributeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId_EntityId] ON [dbo].[AttributeValueReferencedEntity]

(

[EntityTypeId] ASC,

[EntityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeValueReferencedEntity] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeValueReferencedEntity_dbo.AttributeValue_AttributeValueId] FOREIGN KEY([AttributeValueId])

REFERENCES [dbo].[AttributeValue] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttributeValueReferencedEntity] CHECK CONSTRAINT [FK_dbo.AttributeValueReferencedEntity_dbo.AttributeValue_AttributeValueId]

GO
```


## AttributeMatrixTemplate
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeMatrixTemplate](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[IsActive] [bit] NOT NULL,

[MinimumRows] [int] NULL,

[MaximumRows] [int] NULL,

[FormattedLava] [nvarchar](max) NULL,

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

ALTER TABLE [dbo].[AttributeMatrixTemplate] ADD CONSTRAINT [PK_dbo.AttributeMatrixTemplate] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[AttributeMatrixTemplate]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttributeMatrixTemplate]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[AttributeMatrixTemplate]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeMatrixTemplate] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrixTemplate_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeMatrixTemplate] CHECK CONSTRAINT [FK_dbo.AttributeMatrixTemplate_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[AttributeMatrixTemplate] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrixTemplate_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeMatrixTemplate] CHECK CONSTRAINT [FK_dbo.AttributeMatrixTemplate_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## AttributeMatrix
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeMatrix](

[Id] [int] IDENTITY(1,1) NOT NULL,

[AttributeMatrixTemplateId] [int] NOT NULL,

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

ALTER TABLE [dbo].[AttributeMatrix] ADD CONSTRAINT [PK_dbo.AttributeMatrix] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeMatrixTemplateId] ON [dbo].[AttributeMatrix]

(

[AttributeMatrixTemplateId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[AttributeMatrix]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttributeMatrix]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[AttributeMatrix]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeMatrix] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrix_dbo.AttributeMatrixTemplate_AttributeMatrixTemplateId] FOREIGN KEY([AttributeMatrixTemplateId])

REFERENCES [dbo].[AttributeMatrixTemplate] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[AttributeMatrix] CHECK CONSTRAINT [FK_dbo.AttributeMatrix_dbo.AttributeMatrixTemplate_AttributeMatrixTemplateId]

GO

ALTER TABLE [dbo].[AttributeMatrix] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrix_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeMatrix] CHECK CONSTRAINT [FK_dbo.AttributeMatrix_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[AttributeMatrix] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrix_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeMatrix] CHECK CONSTRAINT [FK_dbo.AttributeMatrix_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## AttributeMatrixItem
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[AttributeMatrixItem](

[Id] [int] IDENTITY(1,1) NOT NULL,

[AttributeMatrixId] [int] NOT NULL,

[Order] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[AttributeMatrixTemplateId] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeMatrixItem] ADD CONSTRAINT [PK_dbo.AttributeMatrixItem] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_AttributeMatrixId] ON [dbo].[AttributeMatrixItem]

(

[AttributeMatrixId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[AttributeMatrixItem]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[AttributeMatrixItem]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[AttributeMatrixItem]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AttributeMatrixItem] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrixItem_dbo.AttributeMatrix_AttributeMatrixId] FOREIGN KEY([AttributeMatrixId])

REFERENCES [dbo].[AttributeMatrix] ([Id])

GO

ALTER TABLE [dbo].[AttributeMatrixItem] CHECK CONSTRAINT [FK_dbo.AttributeMatrixItem_dbo.AttributeMatrix_AttributeMatrixId]

GO

ALTER TABLE [dbo].[AttributeMatrixItem] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrixItem_dbo.AttributeMatrixTemplate_AttributeMatrixTemplateId] FOREIGN KEY([AttributeMatrixTemplateId])

REFERENCES [dbo].[AttributeMatrixTemplate] ([Id])

GO

ALTER TABLE [dbo].[AttributeMatrixItem] CHECK CONSTRAINT [FK_dbo.AttributeMatrixItem_dbo.AttributeMatrixTemplate_AttributeMatrixTemplateId]

GO

ALTER TABLE [dbo].[AttributeMatrixItem] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrixItem_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeMatrixItem] CHECK CONSTRAINT [FK_dbo.AttributeMatrixItem_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[AttributeMatrixItem] WITH CHECK ADD CONSTRAINT [FK_dbo.AttributeMatrixItem_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[AttributeMatrixItem] CHECK CONSTRAINT [FK_dbo.AttributeMatrixItem_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```
