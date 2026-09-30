# Resource List

> **Provenance tier:** `traced` — read from source or official documentation and cited (Rock v18.2.4). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



**Plugin**: BEMA Services — Room Management 2.0 (v2.6.5.16)
**Source file**: `RoomManagement (plugin package)/RoomManagement/ResourceList.ascx.cs`
**Rock Category**: BEMA Services > Room Management

## Purpose

Filterable grid of all `Resource` rows (reservable items like chairs, mics, projectors). Administrators use it to browse, add, and edit resources. Each row links through to [Resource Detail](ResourceDetail.md).

## Block Attributes

*(None — only a LinkedPage.)*

## Page Parameters

*(None read by this block. It emits `ResourceId` when navigating to the detail page.)*

## Data Flow

- **Reads from**: [`Resource`](../sql-tables/Resource-and-Layout.md#resource) via `ResourceService.Queryable(true)`, with these optional filters:

    | Grid filter | Applied to |
    |---|---|
    | Category | `Resource.CategoryId = {filter}` |
    | Campus | `Resource.Campus.Id = {filter}` |

- **Writes**: nothing directly — all edits happen in the detail page.
- **Attributes**: The grid sets `gResources.EntityTypeId = EntityTypeCache.Get<Resource>().Id` so that dynamic attribute columns configured on the Resource entity type are rendered automatically.

## Linked Pages

| Key | Display name | Query string passed | Default |
|---|---|---|---|
| `DetailPage` | Detail Page | `ResourceId` (0 for "Add") | *(none — required)* |

## Notable Behaviors

- Filter state is persisted via `gfSettings.SetFilterPreference` / `GetFilterPreference` (per-user, per-block).
- Ordering: `Category.Name` then `Resource.Name`.
- Filter display values are humanized: `Category` → category name, `Campus` → campus name (via `CategoryCache` / `CampusCache`).
