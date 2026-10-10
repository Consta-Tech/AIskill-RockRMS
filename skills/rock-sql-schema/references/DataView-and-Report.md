# DataView and Report

> **Provenance tier:** `measured` — tested in a live Rock instance (Rock version not recorded). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.



Data filtering, persisted results, report definitions, report columns, and saved queries.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

## Summary

| Table | Description | Key Foreign Keys |
|-------|-------------|------------------|
| DataViewFilter | Hierarchical filter-expression tree nodes that define a DataView's criteria | EntityType, DataView, self-referencing |
| DataView | Saved entity filters with optional persistence scheduling | DataViewFilter (CASCADE), EntityType, Category, Schedule |
| DataViewPersistedValue | Cached entity IDs for DataViews with persistence enabled | DataView (CASCADE) |
| Report | Formatted, exportable report definitions built on top of a DataView | DataView, EntityType, Category |
| ReportField | Individual columns/fields displayed in a report | Report (CASCADE), EntityType (CASCADE) |
| Query | Attribute-value-shaped read structure used for query storage | — |

---

## DataViewFilter
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[DataViewFilter](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ExpressionType] [int] NOT NULL,

[ParentId] [int] NULL,

[EntityTypeId] [int] NULL,

[Selection] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[DataViewId] [int] NULL,

[RelatedDataViewId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[DataViewFilter] ADD CONSTRAINT [PK_dbo.DataViewFilter] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[DataViewFilter]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DataViewId] ON [dbo].[DataViewFilter]

(

[DataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[DataViewFilter]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[DataViewFilter]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[DataViewFilter]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ParentId] ON [dbo].[DataViewFilter]

(

[ParentId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_RelatedDataViewId] ON [dbo].[DataViewFilter]

(

[RelatedDataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DataViewFilter] WITH CHECK ADD CONSTRAINT [FK_dbo.DataViewFilter_dbo.DataView_DataViewId] FOREIGN KEY([DataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[DataViewFilter] CHECK CONSTRAINT [FK_dbo.DataViewFilter_dbo.DataView_DataViewId]

GO

ALTER TABLE [dbo].[DataViewFilter] WITH CHECK ADD CONSTRAINT [FK_dbo.DataViewFilter_dbo.DataView_RelatedDataViewId] FOREIGN KEY([RelatedDataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[DataViewFilter] CHECK CONSTRAINT [FK_dbo.DataViewFilter_dbo.DataView_RelatedDataViewId]

GO

ALTER TABLE [dbo].[DataViewFilter] WITH CHECK ADD CONSTRAINT [FK_dbo.DataViewFilter_dbo.DataViewFilter_ParentId] FOREIGN KEY([ParentId])

REFERENCES [dbo].[DataViewFilter] ([Id])

GO

ALTER TABLE [dbo].[DataViewFilter] CHECK CONSTRAINT [FK_dbo.DataViewFilter_dbo.DataViewFilter_ParentId]

GO

ALTER TABLE [dbo].[DataViewFilter] WITH CHECK ADD CONSTRAINT [FK_dbo.DataViewFilter_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[DataViewFilter] CHECK CONSTRAINT [FK_dbo.DataViewFilter_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[DataViewFilter] WITH CHECK ADD CONSTRAINT [FK_dbo.DataViewFilter_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[DataViewFilter] CHECK CONSTRAINT [FK_dbo.DataViewFilter_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[DataViewFilter] WITH CHECK ADD CONSTRAINT [FK_dbo.DataViewFilter_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[DataViewFilter] CHECK CONSTRAINT [FK_dbo.DataViewFilter_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## DataView
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[DataView](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[CategoryId] [int] NULL,

[EntityTypeId] [int] NOT NULL,

[DataViewFilterId] [int] NULL,

[TransformEntityTypeId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[PersistedScheduleIntervalMinutes] [int] NULL,

[PersistedLastRefreshDateTime] [datetime] NULL,

[IncludeDeceased] [bit] NOT NULL,

[LastRunDateTime] [datetime] NULL,

[RunCount] [int] NULL,

[PersistedLastRunDurationMilliseconds] [int] NULL,

[TimeToRunDurationMilliseconds] [float] NULL,

[RunCountLastRefreshDateTime] [datetime] NULL,

[DisableUseOfReadOnlyContext] [bit] NOT NULL,

[PersistedScheduleId] [int] NULL,

[IconCssClass] [nvarchar](100) NULL,

[HighlightColor] [nvarchar](50) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[DataView] ADD CONSTRAINT [PK_dbo.DataView] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[DataView]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[DataView]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DataViewFilterId] ON [dbo].[DataView]

(

[DataViewFilterId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[DataView]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[DataView]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[DataView]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PersistedScheduleId] ON [dbo].[DataView]

(

[PersistedScheduleId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_TransformEntityTypeId] ON [dbo].[DataView]

(

[TransformEntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DataView] ADD DEFAULT ((0)) FOR [IncludeDeceased]

GO

ALTER TABLE [dbo].[DataView] ADD DEFAULT ((0)) FOR [DisableUseOfReadOnlyContext]

GO

ALTER TABLE [dbo].[DataView] WITH CHECK ADD CONSTRAINT [FK_dbo.DataView_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[DataView] CHECK CONSTRAINT [FK_dbo.DataView_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[DataView] WITH CHECK ADD CONSTRAINT [FK_dbo.DataView_dbo.DataViewFilter_DataViewFilterId] FOREIGN KEY([DataViewFilterId])

REFERENCES [dbo].[DataViewFilter] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[DataView] CHECK CONSTRAINT [FK_dbo.DataView_dbo.DataViewFilter_DataViewFilterId]

GO

ALTER TABLE [dbo].[DataView] WITH CHECK ADD CONSTRAINT [FK_dbo.DataView_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[DataView] CHECK CONSTRAINT [FK_dbo.DataView_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[DataView] WITH CHECK ADD CONSTRAINT [FK_dbo.DataView_dbo.EntityType_TransformEntityTypeId] FOREIGN KEY([TransformEntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[DataView] CHECK CONSTRAINT [FK_dbo.DataView_dbo.EntityType_TransformEntityTypeId]

GO

ALTER TABLE [dbo].[DataView] WITH CHECK ADD CONSTRAINT [FK_dbo.DataView_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[DataView] CHECK CONSTRAINT [FK_dbo.DataView_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[DataView] WITH CHECK ADD CONSTRAINT [FK_dbo.DataView_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[DataView] CHECK CONSTRAINT [FK_dbo.DataView_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[DataView] WITH CHECK ADD CONSTRAINT [FK_dbo.DataView_dbo.Schedule_PersistedScheduleId] FOREIGN KEY([PersistedScheduleId])

REFERENCES [dbo].[Schedule] ([Id])

GO

ALTER TABLE [dbo].[DataView] CHECK CONSTRAINT [FK_dbo.DataView_dbo.Schedule_PersistedScheduleId]

GO
```


## DataViewPersistedValue
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[DataViewPersistedValue](

[DataViewId] [int] NOT NULL,

[EntityId] [int] NOT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DataViewPersistedValue] ADD CONSTRAINT [PK_dbo.DataViewPersistedValue] PRIMARY KEY CLUSTERED

(

[DataViewId] ASC,

[EntityId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DataViewId] ON [dbo].[DataViewPersistedValue]

(

[DataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[DataViewPersistedValue] WITH CHECK ADD CONSTRAINT [FK_dbo.DataViewPersistedValue_dbo.DataView_DataViewId] FOREIGN KEY([DataViewId])

REFERENCES [dbo].[DataView] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[DataViewPersistedValue] CHECK CONSTRAINT [FK_dbo.DataViewPersistedValue_dbo.DataView_DataViewId]

GO
```


## Report
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Report](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[CategoryId] [int] NULL,

[EntityTypeId] [int] NULL,

[DataViewId] [int] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[FetchTop] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[QueryHint] [nvarchar](max) NULL,

[LastRunDateTime] [datetime] NULL,

[RunCount] [int] NULL,

[TimeToRunDurationMilliseconds] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Report] ADD CONSTRAINT [PK_dbo.Report] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CategoryId] ON [dbo].[Report]

(

[CategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Report]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DataViewId] ON [dbo].[Report]

(

[DataViewId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[Report]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Report]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Report]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Report] WITH CHECK ADD CONSTRAINT [FK_dbo.Report_dbo.Category_CategoryId] FOREIGN KEY([CategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_dbo.Report_dbo.Category_CategoryId]

GO

ALTER TABLE [dbo].[Report] WITH CHECK ADD CONSTRAINT [FK_dbo.Report_dbo.DataView_DataViewId] FOREIGN KEY([DataViewId])

REFERENCES [dbo].[DataView] ([Id])

GO

ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_dbo.Report_dbo.DataView_DataViewId]

GO

ALTER TABLE [dbo].[Report] WITH CHECK ADD CONSTRAINT [FK_dbo.Report_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_dbo.Report_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[Report] WITH CHECK ADD CONSTRAINT [FK_dbo.Report_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_dbo.Report_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Report] WITH CHECK ADD CONSTRAINT [FK_dbo.Report_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Report] CHECK CONSTRAINT [FK_dbo.Report_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## ReportField
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[ReportField](

[Id] [int] IDENTITY(1,1) NOT NULL,

[ReportId] [int] NOT NULL,

[ReportFieldType] [int] NOT NULL,

[ShowInGrid] [bit] NOT NULL,

[DataSelectComponentEntityTypeId] [int] NULL,

[Selection] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[ColumnHeaderText] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ColumnOrder] [int] NOT NULL,

[SortOrder] [int] NULL,

[SortDirection] [int] NOT NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsCommunicationRecipientField] [bit] NULL,

[IsCommunicationMergeField] [bit] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[ReportField] ADD CONSTRAINT [PK_dbo.ReportField] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[ReportField]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_DataSelectComponentEntityTypeId] ON [dbo].[ReportField]

(

[DataSelectComponentEntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[ReportField]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[ReportField]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ReportId] ON [dbo].[ReportField]

(

[ReportId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ReportField] ADD DEFAULT ((0)) FOR [ColumnOrder]

GO

ALTER TABLE [dbo].[ReportField] ADD DEFAULT ((0)) FOR [SortDirection]

GO

ALTER TABLE [dbo].[ReportField] WITH CHECK ADD CONSTRAINT [FK_dbo.ReportField_dbo.EntityType_DataSelectComponentEntityTypeId] FOREIGN KEY([DataSelectComponentEntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ReportField] CHECK CONSTRAINT [FK_dbo.ReportField_dbo.EntityType_DataSelectComponentEntityTypeId]

GO

ALTER TABLE [dbo].[ReportField] WITH CHECK ADD CONSTRAINT [FK_dbo.ReportField_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ReportField] CHECK CONSTRAINT [FK_dbo.ReportField_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[ReportField] WITH CHECK ADD CONSTRAINT [FK_dbo.ReportField_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[ReportField] CHECK CONSTRAINT [FK_dbo.ReportField_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[ReportField] WITH CHECK ADD CONSTRAINT [FK_dbo.ReportField_dbo.Report_ReportId] FOREIGN KEY([ReportId])

REFERENCES [dbo].[Report] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[ReportField] CHECK CONSTRAINT [FK_dbo.ReportField_dbo.Report_ReportId]

GO
```


## Query
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Query](

[Id] [int] NOT NULL,

[IsSystem] [bit] NOT NULL,

[AttributeId] [int] NOT NULL,

[EntityId] [int] NULL,

[Value] [ntext] NULL,

[Guid] [uniqueidentifier] NOT NULL,

[CreatedDateTime] [datetime2](3) NULL,

[ModifiedDateTime] [datetime2](3) NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ValueAsDateTime] [datetime2](3) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[ValueAsNumeric] [decimal](18, 2) NULL,

[PersistedTextValue] [ntext] NULL,

[PersistedHtmlValue] [ntext] NULL,

[PersistedCondensedTextValue] [ntext] NULL,

[PersistedCondensedHtmlValue] [ntext] NULL,

[IsPersistedValueDirty] [bit] NOT NULL,

[ValueChecksum] [int] NULL,

[ValueAsBoolean] [bit] NULL,

[ValueAsPersonId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
```
