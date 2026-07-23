# Block and BlockType

Block type definitions and block instances.

> For a full index of all Rock RMS SQL table schemas and additional context, see `README.md`.

---

## BlockType
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[BlockType](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[Path] [nvarchar](260) NULL,

[Name] [nvarchar](100) NOT NULL,

[Description] [nvarchar](max) NULL,

[Guid] [uniqueidentifier] NOT NULL,

[Category] [nvarchar](100) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[IsCommon] [bit] NOT NULL,

[EntityTypeId] [int] NULL,

[SiteTypeFlags] [int] NOT NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[BlockType] ADD CONSTRAINT [PK_dbo.BlockType] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[BlockType]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_EntityTypeId] ON [dbo].[BlockType]

(

[EntityTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[BlockType]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[BlockType]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[BlockType] ADD DEFAULT ((0)) FOR [IsCommon]

GO

ALTER TABLE [dbo].[BlockType] ADD DEFAULT ((0)) FOR [SiteTypeFlags]

GO

ALTER TABLE [dbo].[BlockType] WITH CHECK ADD CONSTRAINT [FK_dbo.BlockType_dbo.EntityType_EntityTypeId] FOREIGN KEY([EntityTypeId])

REFERENCES [dbo].[EntityType] ([Id])

GO

ALTER TABLE [dbo].[BlockType] CHECK CONSTRAINT [FK_dbo.BlockType_dbo.EntityType_EntityTypeId]

GO

ALTER TABLE [dbo].[BlockType] WITH CHECK ADD CONSTRAINT [FK_dbo.BlockType_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BlockType] CHECK CONSTRAINT [FK_dbo.BlockType_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[BlockType] WITH CHECK ADD CONSTRAINT [FK_dbo.BlockType_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[BlockType] CHECK CONSTRAINT [FK_dbo.BlockType_dbo.PersonAlias_ModifiedByPersonAliasId]

GO
```


## Block
```sql
SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[Block](

[Id] [int] IDENTITY(1,1) NOT NULL,

[IsSystem] [bit] NOT NULL,

[PageId] [int] NULL,

[LayoutId] [int] NULL,

[BlockTypeId] [int] NOT NULL,

[Zone] [nvarchar](100) NOT NULL,

[Order] [int] NOT NULL,

[Name] [nvarchar](100) NOT NULL,

[CssClass] [nvarchar](100) NULL,

[OutputCacheDuration] [int] NOT NULL,

[Guid] [uniqueidentifier] NOT NULL,

[PreHtml] [nvarchar](max) NULL,

[PostHtml] [nvarchar](max) NULL,

[CreatedDateTime] [datetime] NULL,

[ModifiedDateTime] [datetime] NULL,

[CreatedByPersonAliasId] [int] NULL,

[ModifiedByPersonAliasId] [int] NULL,

[ForeignKey] [nvarchar](100) NULL,

[ForeignGuid] [uniqueidentifier] NULL,

[ForeignId] [int] NULL,

[SiteId] [int] NULL,

[AdditionalSettings] [nvarchar](max) NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[Block] ADD CONSTRAINT [PK_dbo.Block] PRIMARY KEY CLUSTERED

(

[Id] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_BlockTypeId] ON [dbo].[Block]

(

[BlockTypeId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_CreatedByPersonAliasId] ON [dbo].[Block]

(

[CreatedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Guid] ON [dbo].[Block]

(

[Guid] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_LayoutId] ON [dbo].[Block]

(

[LayoutId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_ModifiedByPersonAliasId] ON [dbo].[Block]

(

[ModifiedByPersonAliasId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_PageId] ON [dbo].[Block]

(

[PageId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [IX_SiteId] ON [dbo].[Block]

(

[SiteId] ASC

)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Block] WITH CHECK ADD CONSTRAINT [FK_dbo.Block_dbo.BlockType_BlockTypeId] FOREIGN KEY([BlockTypeId])

REFERENCES [dbo].[BlockType] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[Block] CHECK CONSTRAINT [FK_dbo.Block_dbo.BlockType_BlockTypeId]

GO

ALTER TABLE [dbo].[Block] WITH CHECK ADD CONSTRAINT [FK_dbo.Block_dbo.Layout_LayoutId] FOREIGN KEY([LayoutId])

REFERENCES [dbo].[Layout] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[Block] CHECK CONSTRAINT [FK_dbo.Block_dbo.Layout_LayoutId]

GO

ALTER TABLE [dbo].[Block] WITH CHECK ADD CONSTRAINT [FK_dbo.Block_dbo.Page_PageId] FOREIGN KEY([PageId])

REFERENCES [dbo].[Page] ([Id])

ON DELETE CASCADE

GO

ALTER TABLE [dbo].[Block] CHECK CONSTRAINT [FK_dbo.Block_dbo.Page_PageId]

GO

ALTER TABLE [dbo].[Block] WITH CHECK ADD CONSTRAINT [FK_dbo.Block_dbo.PersonAlias_CreatedByPersonAliasId] FOREIGN KEY([CreatedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Block] CHECK CONSTRAINT [FK_dbo.Block_dbo.PersonAlias_CreatedByPersonAliasId]

GO

ALTER TABLE [dbo].[Block] WITH CHECK ADD CONSTRAINT [FK_dbo.Block_dbo.PersonAlias_ModifiedByPersonAliasId] FOREIGN KEY([ModifiedByPersonAliasId])

REFERENCES [dbo].[PersonAlias] ([Id])

GO

ALTER TABLE [dbo].[Block] CHECK CONSTRAINT [FK_dbo.Block_dbo.PersonAlias_ModifiedByPersonAliasId]

GO

ALTER TABLE [dbo].[Block] WITH CHECK ADD CONSTRAINT [FK_dbo.Block_dbo.Site_SiteId] FOREIGN KEY([SiteId])

REFERENCES [dbo].[Site] ([Id])

GO

ALTER TABLE [dbo].[Block] CHECK CONSTRAINT [FK_dbo.Block_dbo.Site_SiteId]

GO
```