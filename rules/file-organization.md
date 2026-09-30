# File Organization Rules

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `/rockrms:knowledge-current` lists every entry.



## Repository Layout

```
{workspace-repo}/
    _code/           # All code lives here (may be a symlink into a shared code repo)
    input_box/       # Gitignored dropbox for rough drafts
```

All code intended for Rock RMS lives under `_code/`, organized first by **block type**, then by **scope** (PageId, CategoryId, or named application).


## General Principles

- All code that I write to be used within a Rock instance lives under `_code/`.
- Each top-level directory within `_code/` represents a distinct category (BlocksTypes, DataViews, LavaApplications, ShortCodes, etc.).
- Every directory that contains working files **must** include a `README.md` explaining what it contains and any relevant context.
- Never place files at the `_code/` root — always nest them in the appropriate category directory.
- Reference documentation that is relevant to all Rock code is delivered by this plugin's skills (`rock-sql-schema`, `language-lava`, `rock-blocktypes`, etc.), not stored in the workspace repo.


## Directory Structures

### Blocks (`Block-{Type}/`)

Any code that is written to be used within a Rock Block is grouped by Block Type, then by Page.

```
_code/Block-{BlockTypeName}/PageId_{id}/
```

- `{BlockTypeName}` matches the Rock block type name (e.g., `DynamicData`, `HTMLContent`, `LavaApplicationContent`).
- Each page gets its own `PageId_{id}/` subdirectory.
- If a page contains multiple block instances, all related files for that page live in the same `PageId_{id}/` directory.
- Within the `PageId_{id}` directory, the files are named by `BlockId_{id}`
- The same `PageId_{id}` may appear under multiple `Block-{Type}/` directories. This is expected — a single Rock page can contain blocks of different types, and each block's code is filed under its own block type.

#### Block-DynamicData

```
Block-DynamicData/
    PageId_{id}/
        BlockId_{id}-Query.lava.sql
        BlockId_{id}-FormattedOutput.lava
        README.md
    README.md
```

- Each PageId directory contains files for one or more Dynamic Data blocks on that page.
- `-Query.lava.sql` contains the SQL query (with optional Lava templating).
- `-FormattedOutput.lava` contains the formatted output template.
- A block may have only a query, only a formatted output, or both.

#### Block-HTMLContent

```
Block-HTMLContent/
    PageId_{id}/
        BlockId_{id}.lava
        BlockId_{id}-{DescriptiveName}.lava
        README.md
    README.md
```

- Files are plain `.lava` with no suffix when the block has no special role.
- Use a `-{DescriptiveName}` suffix when the block serves a named/shared purpose (e.g., `BlockId_14164-SharedPageMenu.lava`).
- A PageId directory may contain multiple blocks.

#### Block-LavaApplicationContent

```
Block-LavaApplicationContent/
    PageId_{id}/
        BlockId_{id}.lava
        README.md
    README.md
```

- Same naming convention as HTMLContent blocks.


### DataViews (`DataViews/`)

DataView SQL files are grouped by category.

```
DataViews/
    CategoryId_{id}/
        DataViewId_{id}.sql
        README.md
    README.md
```

- Each DataView category gets a `CategoryId_{id}/` directory.
- Individual DataViews are stored as `DataViewId_{id}.sql` or `DataViewId_{id}.lava.sql`.
- Each `CategoryId_{id}/` directory includes a `README.md` describing the category and its DataViews.


### Lava Applications (`LavaApplications/`)

Each application gets a named directory with an `Endpoints/` subdirectory.

```
LavaApplications/
    {ApplicationName}/
        Endpoints/
            {action}.lava
        README.md
    README.md
```

- Endpoint files are named `{action}.lava` where `{action}` is a lowercase, hyphen-separated (kebab-case) description that follows the "verb+object" pattern (e.g., `list-configs`, `update-group`, `filter-parentgroups`).
- The HTTP method (GET, POST, etc.) is configured in the Lava Application endpoint settings in Rock, not in the filename. The endpoint's boilerplate comment documents which method it expects.
- The `README.md` at the application level describes the application's purpose, its endpoints, and any setup or configuration notes.


### ShortCodes (`ShortCodes/`)

Each ShortCode gets its own directory containing the code, documentation, and a README.

```
ShortCodes/
    ShortCodeId_{id}/
        ShortCodeId_{id}.lava
        documentation-ShortCodeId_{id}.html
        README.md
    README.md
```

- The `.lava` file contains the ShortCode implementation.
- The `.html` file contains the ShortCode's documentation/help markup (intended for the internal site of Rock).
- The `README.md` describes the ShortCode's purpose, parameters, and usage (intended for the developer viewing this in GitHub site or IDE).


### System Communications (`SystemCommunications/`)

Version-controlled templates for Rock's System Communications.

```
SystemCommunications/
    SystemCommunicationId_{id}/
        SystemCommunicationId_{id}-{Part}.lava
        README.md
    README.md
```

- Each System Communication gets a `SystemCommunicationId_{id}/` directory.
- The `.lava` file is named `SystemCommunicationId_{id}-{Part}.lava`, where `{Part}` identifies the template section (e.g., `EmailBody`).
- The `README.md` describes the System Communication's purpose, when it was captured, and any auditing context.


## Documentation (shared reference docs)

- Shared reference material (SQL table schemas, language references, tested behaviors) lives in the `Consta-Tech/AIskill-RockRMS` repository and reaches every developer through this plugin's skill references — it is not working code and does not live in `_code/`.
- To improve or extend the shared docs, open a PR against `Consta-Tech/AIskill-RockRMS`.


## Rules for Creating New Files

When adding a new file to the repo:

1. **Determine the block type first.** The top-level directory under `_code/` is always dictated by the Rock block type or entity type.
2. **Find or create the correct scope directory.** Use the PageId, CategoryId, or application name as appropriate.
3. **Use the exact Rock entity ID in the filename.** Do not rename or alias IDs.
4. **Add a descriptive suffix only when it adds clarity.** Plain `BlockId_{id}.lava` is fine for most HTML Content blocks. Use a suffix like `-SharedPageMenu` or `-FormattedOutput` when the block has a specific named role or when a page has multiple blocks that need differentiation.
5. **Always create a README.md** in any new directory.
6. **Never place files directly in a block-type root directory.** Files always go inside a PageId, CategoryId, or named application subdirectory.


## What Does NOT Go in `_code/`

- Reference documentation → the `Consta-Tech/AIskill-RockRMS` repo (delivered via this plugin's skills)
- Rules and conventions → the `Consta-Tech/AIskill-RockRMS` repo (`rules/`, injected at session start)
- Build tooling, scripts, CI config → repo root or dedicated top-level directories as needed
