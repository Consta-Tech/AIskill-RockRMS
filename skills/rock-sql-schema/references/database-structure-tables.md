# Database Structure Tables

Type system, entity metadata, devices, scheduling, and service infrastructure.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| FieldType | Registered field type classes that control how attribute values are edited and displayed | — |
| EntityType | Registered .NET entity types with indexing, field type, and feature flags | FieldType |
| DefinedType | Named groupings of defined values (Rock's lookup-list taxonomy) | FieldType, Category |
| DefinedValue | Individual lookup values belonging to a defined type | DefinedType (CASCADE), Category |
| EntitySet | Named, expirable collections of entities used for batch operations | EntityType, DefinedValue, self-referencing |
| EntitySetItem | Individual entity references within an entity set | EntitySet (CASCADE) |
| Device | Kiosks, printers, and other hardware devices used for check-in and printing | DefinedValue, Location, self-referencing |
| DeviceLocation | Junction table linking devices to the locations they serve | Device (CASCADE), Location (CASCADE) |
| PersonalDevice | Mobile phones and personal devices registered to a person for push notifications | PersonAlias, DefinedValue, Site |
| Schedule | Recurring or one-time schedules defined via iCalendar content | Category |
| ScheduleCategoryExclusion | Date ranges during which all schedules in a category are excluded | Category (CASCADE) |
| ServiceJob | Background job definitions with cron expressions and last-run status | — |
| ServiceJobHistory | Execution history records for service jobs | ServiceJob (CASCADE) |
| ServiceLog | Append-only log of external service calls (address standardization, geocoding, etc.) | — |

---

## FieldType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[FieldType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[Assembly] [nvarchar](100) NOT NULL,

[Class] [nvarchar](100) NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[FieldType] ADD CONSTRAINT [PK_dbo.FieldType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[FieldType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_FieldTypeClass] ON [dbo].[FieldType]

(

[Class] ASC,

[Assembly] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[FieldType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[FieldType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[FieldType] WITH CHECK ADD CONSTRAINT [FK_dbo.FieldType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FieldType] CHECK CONSTRAINT [FK_dbo.FieldType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[FieldType] WITH CHECK ADD CONSTRAINT [FK_dbo.FieldType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[FieldType] CHECK CONSTRAINT [FK_dbo.FieldType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## EntityType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EntityType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](100) NULL,

[AssemblyName] [nvarchar](260) NULL,

[FriendlyName] [nvarchar](100) NULL,

[IsEntity] [bit] NOT NULL,

[IsSecured] [bit] NOT NULL,

[IsCommon] [bit] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[SingleValueFieldTypeId] [int] NULL,

[MultiValueFieldTypeId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsIndexingEnabled] [bit] NOT NULL,

[IndexResultTemplate] [nvarchar](max) NULL,

[IndexDocumentUrl] [nvarchar](max) NULL,

[LinkUrlLavaTemplate] [nvarchar](max) NULL,

[AttributesSupportPrePostHtml] [bit] NOT NULL,

[AttributesSupportShowOnBulk] [bit] NOT NULL,

[IsAchievementsEnabled] [bit] NOT NULL,

[IsMessageBusEventPublishEnabled] [bit] NOT NULL,

[IsRelatedToInteractionTrackedOnCreate] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[EntityType] ADD CONSTRAINT [PK_dbo.EntityType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EntityType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_MultiValueFieldTypeId] ON [dbo].[EntityType]

(

[MultiValueFieldTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Name] ON [dbo].[EntityType]

(

[Name] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SingleValueFieldTypeId] ON [dbo].[EntityType]

(

[SingleValueFieldTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EntityType] ADD DEFAULT ((0)) FOR [IsIndexingEnabled]

GO

ALTER TABLE [dbo].[EntityType] ADD DEFAULT ((0)) FOR [AttributesSupportPrePostHtml]

GO

ALTER TABLE [dbo].[EntityType] ADD DEFAULT ((0)) FOR [AttributesSupportShowOnBulk]

GO

ALTER TABLE [dbo].[EntityType] ADD DEFAULT ((0)) FOR [IsAchievementsEnabled]

GO

ALTER TABLE [dbo].[EntityType] ADD DEFAULT ((0)) FOR [IsMessageBusEventPublishEnabled]

GO

ALTER TABLE [dbo].[EntityType] ADD DEFAULT ((0)) FOR [IsRelatedToInteractionTrackedOnCreate]

GO

ALTER TABLE [dbo].[EntityType] WITH CHECK ADD CONSTRAINT [FK_dbo.EntityType_dbo.FieldType_MultiValueFieldTypeId] FOREIGN KEY([MultiValueFieldTypeId])

REFERENCES [dbo].[FieldType] ([Id])

GO

ALTER TABLE [dbo].[EntityType] CHECK CONSTRAINT [FK_dbo.EntityType_dbo.FieldType_MultiValueFieldTypeId]

GO

ALTER TABLE [dbo].[EntityType] WITH CHECK ADD CONSTRAINT [FK_dbo.EntityType_dbo.FieldType_SingleValueFieldTypeId] FOREIGN KEY([SingleValueFieldTypeId])

REFERENCES [dbo].[FieldType] ([Id])

GO

ALTER TABLE [dbo].[EntityType] CHECK CONSTRAINT [FK_dbo.EntityType_dbo.FieldType_SingleValueFieldTypeId]

GO
```


## DefinedType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[DefinedType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[FieldTypeId] [int] NULL,

[Order] [int] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[HelpText] [nvarchar](max) NULL,

[CategoryId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsActive] [bit] NOT NULL,

[EnableSecurityOnValues] [bit] NOT NULL,

[CategorizedValuesEnabled] [bit] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[DefinedType] ADD CONSTRAINT [PK_dbo.DefinedType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[DefinedType]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[DefinedType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_FieldTypeId] ON [dbo].[DefinedType]

(

[FieldTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[DefinedType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[DefinedType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DefinedType] ADD DEFAULT ((1)) FOR [IsActive]

GO

ALTER TABLE [dbo].[DefinedType] ADD DEFAULT ((0)) FOR [EnableSecurityOnValues]

GO

ALTER TABLE [dbo].[DefinedType] WITH CHECK ADD CONSTRAINT [FK_dbo.DefinedType_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[DefinedType] CHECK CONSTRAINT [FK_dbo.DefinedType_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[DefinedType] WITH CHECK ADD CONSTRAINT [FK_dbo.DefinedType_dbo.FieldType_FieldTypeId] FOREIGN KEY([FieldTypeId])

REFERENCES [dbo].[FieldType] ([Id])

GO

ALTER TABLE [dbo].[DefinedType] CHECK CONSTRAINT [FK_dbo.DefinedType_dbo.FieldType_FieldTypeId]

GO

ALTER TABLE [dbo].[DefinedType] WITH CHECK ADD CONSTRAINT [FK_dbo.DefinedType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[DefinedType] CHECK CONSTRAINT [FK_dbo.DefinedType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[DefinedType] WITH CHECK ADD CONSTRAINT [FK_dbo.DefinedType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[DefinedType] CHECK CONSTRAINT [FK_dbo.DefinedType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## DefinedValue
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[DefinedValue](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[DefinedTypeId] [int] NOT NULL,

[Order] [int] NOT NULL,

[Value] [nvarchar](250) NOT NULL,

[Description] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsActive] [bit] NOT NULL,

[CategoryId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[DefinedValue] ADD CONSTRAINT [PK_dbo.DefinedValue] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[DefinedValue]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[DefinedValue]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DefinedTypeId] ON [dbo].[DefinedValue]

(

[DefinedTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[DefinedValue]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[DefinedValue]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DefinedValue] ADD DEFAULT ((1)) FOR [IsActive]

GO

ALTER TABLE [dbo].[DefinedValue] WITH CHECK ADD CONSTRAINT [FK_dbo.DefinedValue_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[DefinedValue] CHECK CONSTRAINT [FK_dbo.DefinedValue_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[DefinedValue] WITH CHECK ADD CONSTRAINT [FK_dbo.DefinedValue_dbo.DefinedType_DefinedTypeId] FOREIGN KEY([DefinedTypeId])

REFERENCES [dbo].[DefinedType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[DefinedValue] CHECK CONSTRAINT [FK_dbo.DefinedValue_dbo.DefinedType_DefinedTypeId]

GO

ALTER TABLE [dbo].[DefinedValue] WITH CHECK ADD CONSTRAINT [FK_dbo.DefinedValue_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[DefinedValue] CHECK CONSTRAINT [FK_dbo.DefinedValue_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[DefinedValue] WITH CHECK ADD CONSTRAINT [FK_dbo.DefinedValue_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[DefinedValue] CHECK CONSTRAINT [FK_dbo.DefinedValue_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## EntitySet
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EntitySet](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ParentEntitySetId] [int] NULL,

[Name] [nvarchar](100) NULL,

[EntityTypeId] [int] NULL,

[ExpireDateTime] [datetime] NULL,

[Order] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[EntitySetPurposeValueId] [int] NULL,

[Note] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[EntitySet] ADD CONSTRAINT [PK_dbo.EntitySet] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EntitySet]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntitySetPurposeValueId] ON [dbo].[EntitySet]

(

[EntitySetPurposeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[EntitySet]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EntitySet]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EntitySet]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ParentEntitySetId] ON [dbo].[EntitySet]

(

[ParentEntitySetId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EntitySet] WITH CHECK ADD CONSTRAINT [FK_dbo.EntitySet_dbo.DefinedValue_EntitySetPurposeValueId] FOREIGN KEY([EntitySetPurposeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[EntitySet] CHECK CONSTRAINT [FK_dbo.EntitySet_dbo.DefinedValue_EntitySetPurposeValueId]

GO

ALTER TABLE [dbo].[EntitySet] WITH CHECK ADD CONSTRAINT [FK_dbo.EntitySet_dbo.EntitySet_ParentEntitySetId] FOREIGN KEY([ParentEntitySetId])

REFERENCES [dbo].[EntitySet] ([Id])

GO

ALTER TABLE [dbo].[EntitySet] CHECK CONSTRAINT [FK_dbo.EntitySet_dbo.EntitySet_ParentEntitySetId]

GO

ALTER TABLE [dbo].[EntitySet] WITH CHECK ADD CONSTRAINT [FK_dbo.EntitySet_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[EntitySet] CHECK CONSTRAINT [FK_dbo.EntitySet_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[EntitySet] WITH CHECK ADD CONSTRAINT [FK_dbo.EntitySet_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EntitySet] CHECK CONSTRAINT [FK_dbo.EntitySet_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EntitySet] WITH CHECK ADD CONSTRAINT [FK_dbo.EntitySet_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EntitySet] CHECK CONSTRAINT [FK_dbo.EntitySet_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## EntitySetItem
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[EntitySetItem](

[Id] [int] IDENTITY(1,1) NOT NULL,

[EntitySetId] [int] NOT NULL,

[Order] [int] NOT NULL,

[EntityId] [int] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignKey] [nvarchar](100) NULL,

[AdditionalMergeValuesJson] [nvarchar](max) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[EntitySetItem] ADD CONSTRAINT [PK_dbo.EntitySetItem] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[EntitySetItem]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntitySetId] ON [dbo].[EntitySetItem]

(

[EntitySetId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntitySetId_EntityId] ON [dbo].[EntitySetItem]

(

[EntitySetId] ASC,

[EntityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[EntitySetItem]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[EntitySetItem]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[EntitySetItem] WITH CHECK ADD CONSTRAINT [FK_dbo.EntitySetItem_dbo.EntitySet_EntitySetId] FOREIGN KEY([EntitySetId])

REFERENCES [dbo].[EntitySet] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[EntitySetItem] CHECK CONSTRAINT [FK_dbo.EntitySetItem_dbo.EntitySet_EntitySetId]

GO

ALTER TABLE [dbo].[EntitySetItem] WITH CHECK ADD CONSTRAINT [FK_dbo.EntitySetItem_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EntitySetItem] CHECK CONSTRAINT [FK_dbo.EntitySetItem_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[EntitySetItem] WITH CHECK ADD CONSTRAINT [FK_dbo.EntitySetItem_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[EntitySetItem] CHECK CONSTRAINT [FK_dbo.EntitySetItem_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## Device
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Device](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NOT NULL,

[Description] [nvarchar](max) NULL,

[DeviceTypeValueId] [int] NOT NULL,

[LocationId] [int] NULL,

[IPAddress] [nvarchar](45) NULL,

[PrinterDeviceId] [int] NULL,

[PrintFrom] [int] NOT NULL,

[PrintToOverride] [int] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsActive] [bit] NOT NULL,

[HasCamera] [bit] NOT NULL,

[CameraBarcodeConfigurationType] [int] NULL,

[KioskType] [int] NULL,

[ProxyDeviceId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Device] ADD CONSTRAINT [PK_dbo.Device] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Device]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DeviceTypeValueId] ON [dbo].[Device]

(

[DeviceTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Device]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LocationId] ON [dbo].[Device]

(

[LocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Device]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Name] ON [dbo].[Device]

(

[Name] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PrinterDeviceId] ON [dbo].[Device]

(

[PrinterDeviceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Device] ADD DEFAULT ((1)) FOR [IsActive]

GO

ALTER TABLE [dbo].[Device] ADD DEFAULT ((0)) FOR [HasCamera]

GO

ALTER TABLE [dbo].[Device] WITH CHECK ADD CONSTRAINT [FK_dbo.Device_dbo.DefinedValue_DeviceTypeValueId] FOREIGN KEY([DeviceTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_dbo.Device_dbo.DefinedValue_DeviceTypeValueId]

GO

ALTER TABLE [dbo].[Device] WITH CHECK ADD CONSTRAINT [FK_dbo.Device_dbo.Device_PrinterDeviceId] FOREIGN KEY([PrinterDeviceId])

REFERENCES [dbo].[Device] ([Id])

GO

ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_dbo.Device_dbo.Device_PrinterDeviceId]

GO

ALTER TABLE [dbo].[Device] WITH CHECK ADD CONSTRAINT [FK_dbo.Device_dbo.Device_ProxyDeviceId] FOREIGN KEY([ProxyDeviceId])

REFERENCES [dbo].[Device] ([Id])

GO

ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_dbo.Device_dbo.Device_ProxyDeviceId]

GO

ALTER TABLE [dbo].[Device] WITH CHECK ADD CONSTRAINT [FK_dbo.Device_dbo.Location_LocationId] FOREIGN KEY([LocationId])

REFERENCES [dbo].[Location] ([Id])

GO

ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_dbo.Device_dbo.Location_LocationId]

GO

ALTER TABLE [dbo].[Device] WITH CHECK ADD CONSTRAINT [FK_dbo.Device_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_dbo.Device_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Device] WITH CHECK ADD CONSTRAINT [FK_dbo.Device_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Device] CHECK CONSTRAINT [FK_dbo.Device_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## DeviceLocation
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[DeviceLocation](

[DeviceId] [int] NOT NULL,

[LocationId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DeviceLocation] ADD CONSTRAINT [PK_dbo.DeviceLocation] PRIMARY KEY CLUSTERED

(

[DeviceId] ASC,

[LocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DeviceId] ON [dbo].[DeviceLocation]

(

[DeviceId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LocationId] ON [dbo].[DeviceLocation]

(

[LocationId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DeviceLocation] WITH CHECK ADD CONSTRAINT [FK_dbo.DeviceLocation_dbo.Device_DeviceId] FOREIGN KEY([DeviceId])

REFERENCES [dbo].[Device] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[DeviceLocation] CHECK CONSTRAINT [FK_dbo.DeviceLocation_dbo.Device_DeviceId]

GO

ALTER TABLE [dbo].[DeviceLocation] WITH CHECK ADD CONSTRAINT [FK_dbo.DeviceLocation_dbo.Location_LocationId] FOREIGN KEY([LocationId])

REFERENCES [dbo].[Location] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[DeviceLocation] CHECK CONSTRAINT [FK_dbo.DeviceLocation_dbo.Location_LocationId]

GO
```


## PersonalDevice
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[PersonalDevice](

[Id] [int] IDENTITY(1,1) NOT NULL,

[PersonAliasId] [int] NULL,

[DeviceRegistrationId] [nvarchar](max) NULL,

[NotificationsEnabled] [bit] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ForeignId] [int] NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignKey] [nvarchar](100) NULL,

[PersonalDeviceTypeValueId] [int] NULL,

[PlatformValueId] [int] NULL,

[DeviceUniqueIdentifier] [nvarchar](50) NULL,

[DeviceVersion] [nvarchar](100) NULL,

[MACAddress] [nvarchar](12) NULL,

[IsActive] [bit] NOT NULL,

[SiteId] [int] NULL,

[Manufacturer] [nvarchar](50) NULL,

[Model] [nvarchar](50) NULL,

[Name] [nvarchar](50) NULL,

[LastSeenDateTime] [datetime] NULL,

[LastVerifiedDateTime] [datetime] NULL,

[LocationPermissionStatus] [int] NOT NULL,

[IsPreciseLocationEnabled] [bit] NOT NULL,

[LocationPermissionDisabledDateTime] [datetime] NULL,

[IsBeaconMonitoringEnabled] [bit] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[PersonalDevice] ADD CONSTRAINT [PK_dbo.PersonalDevice] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[PersonalDevice]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[PersonalDevice]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[PersonalDevice]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonalDeviceTypeValueId] ON [dbo].[PersonalDevice]

(

[PersonalDeviceTypeValueId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersonAliasId] ON [dbo].[PersonalDevice]

(

[PersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SiteId] ON [dbo].[PersonalDevice]

(

[SiteId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PersonalDevice] ADD DEFAULT ((1)) FOR [IsActive]

GO

ALTER TABLE [dbo].[PersonalDevice] ADD DEFAULT ((0)) FOR [LocationPermissionStatus]

GO

ALTER TABLE [dbo].[PersonalDevice] ADD DEFAULT ((0)) FOR [IsPreciseLocationEnabled]

GO

ALTER TABLE [dbo].[PersonalDevice] ADD DEFAULT ((0)) FOR [IsBeaconMonitoringEnabled]

GO

ALTER TABLE [dbo].[PersonalDevice] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonalDevice_dbo.DefinedValue_PersonalDeviceTypeValueId] FOREIGN KEY([PersonalDeviceTypeValueId])

REFERENCES [dbo].[DefinedValue] ([Id])

GO

ALTER TABLE [dbo].[PersonalDevice] CHECK CONSTRAINT [FK_dbo.PersonalDevice_dbo.DefinedValue_PersonalDeviceTypeValueId]

GO

ALTER TABLE [dbo].[PersonalDevice] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonalDevice_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[PersonalDevice] CHECK CONSTRAINT [FK_dbo.PersonalDevice_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[PersonalDevice] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonalDevice_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[PersonalDevice] CHECK CONSTRAINT [FK_dbo.PersonalDevice_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[PersonalDevice] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonalDevice_dbo.PersonAlias_PersonAliasId] FOREIGN KEY([PersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[PersonalDevice] CHECK CONSTRAINT [FK_dbo.PersonalDevice_dbo.PersonAlias_PersonAliasId]

GO

ALTER TABLE [dbo].[PersonalDevice] WITH CHECK ADD CONSTRAINT [FK_dbo.PersonalDevice_dbo.Site_SiteId] FOREIGN KEY([SiteId])

REFERENCES [dbo].[Site] ([Id])

GO

ALTER TABLE [dbo].[PersonalDevice] CHECK CONSTRAINT [FK_dbo.PersonalDevice_dbo.Site_SiteId]

GO
```


## Schedule
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Schedule](

[Id] [int] IDENTITY(1,1) NOT NULL,

[Name] [nvarchar](50) NULL,

[Description] [nvarchar](max) NULL,

[iCalendarContent] [nvarchar](max) NULL,

[CheckInStartOffsetMinutes] [int] NULL,

[CheckInEndOffsetMinutes] [int] NULL,

[EffectiveStartDate] [date] NULL,

[EffectiveEndDate] [date] NULL,

[CategoryId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[WeeklyDayOfWeek] [int] NULL,

[WeeklyTimeOfDay] [time](7) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsActive] [bit] NOT NULL,

[Order] [int] NOT NULL,

[AutoInactivateWhenComplete] [bit] NOT NULL,

[AbbreviatedName] [nvarchar](50) NULL,

[IsPublic] [bit] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Schedule] ADD CONSTRAINT [PK_dbo.Schedule] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[Schedule]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Schedule]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Schedule]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Schedule]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [IX_Name] ON [dbo].[Schedule]

(

[Name] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Schedule] ADD DEFAULT ((0)) FOR [IsActive]

GO

ALTER TABLE [dbo].[Schedule] ADD DEFAULT ((0)) FOR [Order]

GO

ALTER TABLE [dbo].[Schedule] ADD DEFAULT ((0)) FOR [AutoInactivateWhenComplete]

GO

ALTER TABLE [dbo].[Schedule] ADD DEFAULT ((1)) FOR [IsPublic]

GO

ALTER TABLE [dbo].[Schedule] WITH CHECK ADD CONSTRAINT [FK_dbo.Schedule_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[Schedule] CHECK CONSTRAINT [FK_dbo.Schedule_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[Schedule] WITH CHECK ADD CONSTRAINT [FK_dbo.Schedule_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Schedule] CHECK CONSTRAINT [FK_dbo.Schedule_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Schedule] WITH CHECK ADD CONSTRAINT [FK_dbo.Schedule_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Schedule] CHECK CONSTRAINT [FK_dbo.Schedule_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ScheduleCategoryExclusion
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ScheduleCategoryExclusion](

[Id] [int] IDENTITY(1,1) NOT NULL,

[CategoryId] [int] NOT NULL,

[Title] [nvarchar](50) NOT NULL,

[StartDate] [datetime] NOT NULL,

[EndDate] [datetime] NOT NULL,

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

ALTER TABLE [dbo].[ScheduleCategoryExclusion] ADD CONSTRAINT [PK_dbo.ScheduleCategoryExclusion] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[ScheduleCategoryExclusion]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ScheduleCategoryExclusion]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ScheduleCategoryExclusion]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ScheduleCategoryExclusion]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ScheduleCategoryExclusion] WITH CHECK ADD CONSTRAINT [FK_dbo.ScheduleCategoryExclusion_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ScheduleCategoryExclusion] CHECK CONSTRAINT [FK_dbo.ScheduleCategoryExclusion_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[ScheduleCategoryExclusion] WITH CHECK ADD CONSTRAINT [FK_dbo.ScheduleCategoryExclusion_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ScheduleCategoryExclusion] CHECK CONSTRAINT [FK_dbo.ScheduleCategoryExclusion_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ScheduleCategoryExclusion] WITH CHECK ADD CONSTRAINT [FK_dbo.ScheduleCategoryExclusion_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ScheduleCategoryExclusion] CHECK CONSTRAINT [FK_dbo.ScheduleCategoryExclusion_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ServiceJob
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ServiceJob](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[IsActive] [bit] NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[Assembly] [nvarchar](260) NULL,

[Class] [nvarchar](100) NOT NULL,

[CronExpression] [nvarchar](120) NOT NULL,

[LastSuccessfulRunDateTime] [datetime] NULL,

[LastRunDateTime] [datetime] NULL,

[LastRunDurationSeconds] [int] NULL,

[LastStatus] [nvarchar](50) NULL,

[LastStatusMessage] [nvarchar](max) NULL,

[LastRunSchedulerName] [nvarchar](40) NULL,

[NotificationEmails] [nvarchar](1000) NULL,

[NotificationStatus] [int] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[EnableHistory] [bit] NOT NULL,

[HistoryCount] [int] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ServiceJob] ADD CONSTRAINT [PK_dbo.ServiceJob] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ServiceJob]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ServiceJob]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ServiceJob]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ServiceJob] ADD DEFAULT ((0)) FOR [EnableHistory]

GO

ALTER TABLE [dbo].[ServiceJob] ADD DEFAULT ((0)) FOR [HistoryCount]

GO

ALTER TABLE [dbo].[ServiceJob] WITH CHECK ADD CONSTRAINT [FK_dbo.ServiceJob_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ServiceJob] CHECK CONSTRAINT [FK_dbo.ServiceJob_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ServiceJob] WITH CHECK ADD CONSTRAINT [FK_dbo.ServiceJob_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ServiceJob] CHECK CONSTRAINT [FK_dbo.ServiceJob_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ServiceJobHistory
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ServiceJobHistory](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ServiceJobId] [int] NOT NULL,

[ServiceWorker] [nvarchar](45) NULL,

[StartDateTime] [datetime] NULL,

[StopDateTime] [datetime] NULL,

[Status] [nvarchar](50) NULL,

[StatusMessage] [nvarchar](max) NULL,

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

ALTER TABLE [dbo].[ServiceJobHistory] ADD CONSTRAINT [PK_dbo.ServiceJobHistory] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ServiceJobHistory]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ServiceJobHistory]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ServiceJobHistory]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ServiceJobId] ON [dbo].[ServiceJobHistory]

(

[ServiceJobId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ServiceJobHistory] WITH CHECK ADD CONSTRAINT [FK_dbo.ServiceJobHistory_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ServiceJobHistory] CHECK CONSTRAINT [FK_dbo.ServiceJobHistory_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ServiceJobHistory] WITH CHECK ADD CONSTRAINT [FK_dbo.ServiceJobHistory_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ServiceJobHistory] CHECK CONSTRAINT [FK_dbo.ServiceJobHistory_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[ServiceJobHistory] WITH CHECK ADD CONSTRAINT [FK_dbo.ServiceJobHistory_dbo.ServiceJob_ServiceJobId] FOREIGN KEY([ServiceJobId])

REFERENCES [dbo].[ServiceJob] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ServiceJobHistory] CHECK CONSTRAINT [FK_dbo.ServiceJobHistory_dbo.ServiceJob_ServiceJobId]

GO
```


## ServiceLog
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ServiceLog](

[Id] [int] IDENTITY(1,1) NOT NULL,

[LogDateTime] [datetime] NULL,

[Input] [nvarchar](max) NULL,

[Type] [nvarchar](50) NULL,

[Name] [nvarchar](50) NULL,

[Result] [nvarchar](200) NULL,

[Success] [bit] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ServiceLog] ADD CONSTRAINT [PK_dbo.ServiceLog] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ServiceLog]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ServiceLog]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ServiceLog]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ServiceLog] WITH CHECK ADD CONSTRAINT [FK_dbo.ServiceLog_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ServiceLog] CHECK CONSTRAINT [FK_dbo.ServiceLog_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ServiceLog] WITH CHECK ADD CONSTRAINT [FK_dbo.ServiceLog_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ServiceLog] CHECK CONSTRAINT [FK_dbo.ServiceLog_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```
