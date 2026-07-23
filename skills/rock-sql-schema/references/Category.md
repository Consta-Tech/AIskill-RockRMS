# Category

Hierarchical categorization for multiple entity types.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## Category
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Category](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[ParentCategoryId] [int] NULL,

[EntityTypeId] [int] NOT NULL,

[EntityTypeQualifierColumn] [nvarchar](50) NULL,

[EntityTypeQualifierValue] [nvarchar](200) NULL,

[Name] [nvarchar](100) NOT NULL,

[IconCssClass] [nvarchar](100) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[Order] [int] NOT NULL,

[Description] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[HighlightColor] [nvarchar](50) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Category] ADD CONSTRAINT [PK_dbo.Category] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Category]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[Category]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Category]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Category]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ParentCategoryId] ON [dbo].[Category]

(

[ParentCategoryId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Category] WITH CHECK ADD CONSTRAINT [FK_dbo.Category_dbo.Category_ParentCategoryId] FOREIGN KEY([ParentCategoryId])

REFERENCES [dbo].[Category] ([Id])

GO

ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [FK_dbo.Category_dbo.Category_ParentCategoryId]

GO

ALTER TABLE [dbo].[Category] WITH CHECK ADD CONSTRAINT [FK_dbo.Category_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [FK_dbo.Category_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[Category] WITH CHECK ADD CONSTRAINT [FK_dbo.Category_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [FK_dbo.Category_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Category] WITH CHECK ADD CONSTRAINT [FK_dbo.Category_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [FK_dbo.Category_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```