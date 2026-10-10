# About Documentation

> **Provenance tier:** `traced` — read from source or official documentation and cited (house convention, no Rock version). Catalogued in the plugin's knowledge manifest; `rockrms-knowledge-current` lists every entry.


Documentation happens at three levels:
1. Documenting with in-file comments
2. Documenting with directory READMEs
3. Documenting with shared reference docs in the AIskill-RockRMS skill pack


## Comments inside a file
### Boilerplate
Each file will have at least one comment block: The boilerplate at the top of the file.

This boilerplate must be written using the comment-syntax of the language corresponding to that file's context.
- Most of the time, the context is an HTML Block with an enabled Lava engine, therefore, the boilerplate will be a Lava comment.
- Sometimes, the context is a SQL console, therefore, the boilerplate will be a SQL comment.
- For `.html` documentation files in ShortCodes, use HTML comment syntax (`<!-- ... -->`). ShortCode documentation follows a slightly different rendering engine than the rest of Rock, so the usual "prefer Lava comments so they don't survive past the render engine" rule does not apply here.

This boilerplate must begin with the Path to the file.

After the Path to the file, this boilerplate can include a variety of notes, including but not limited to:
1. The end-goal (purpose, intent) of this code
2. The necessary input parameters for this code
3. The underlying assumptions for this code
4. The necessary Rock RMS version for this code

#### Examples
```
/****************************************************************************************
    
    Path:
    _code/Block-DynamicData/PageId_1213/BlockId_14121-Query.lava.sql
    
    1. Unless your IDE can show you syntax-highlighting for both SQL and Lava simultaneously, choose SQL.
    2. This first section identifies the PageParameterFilter values and uses Lava in order to convert them into something we can use the in SQL queries below.
    
****************************************************************************************/
```
```
/---------------------------------------------------------------------------------------------------------

    Path:
    _code/Block-HTMLContent/PageId_1128/BlockId_6222-ListOfCoachingGroups.lava
    
    This Lava is used to mimic the Group List Personalized Lava Block type. However, rather than showing a list of Groups where CurrentPerson is the Leader, it shows a list of Groups where CurrentPerson is the Coach.
    
    Required Lava Command(s):
    - Rock Entity
    - Sql
    
---------------------------------------------------------------------------------------------------------/
```

If the Lava file was created by copy+pasting an existing Lava Template (maybe it was written by SparkDev or Triumph in core Rock), then please make note of it like this:
```
/---------------------------------------------------------------------------------------------------------

    Path:
    _code/Block-HTMLContent/PageId_1128/BlockId_6222-ListOfCoachingGroups.lava
    
    This Lava is found in
    PageId=1128, BlockId=6222, [Block.Name] > [Block.ConfigurationSection] > Block.ConfigurationField
    
    i am copy+pasting this here from the VRL Rock Site.
    i copy+pasted this on 09-APR-2024
    
---------------------------------------------------------------------------------------------------------/
```


#### Lava Application Endpoints
Endpoint files follow a similar boilerplate pattern but include endpoint-specific fields:
```
/---------------------------------------------------------------------------------------------------------

    Path:
    _code/LavaApplications/{ApplicationName}/Endpoints/{endpoint-slug}.lava

    Lava Application Slug:
    {slug}

    Lava Endpoint Slug:
    {endpoint-slug}

    HTTP Method:
    GET or POST

    Enabled Lava Commands:
    - {CommandName}

    Accepts (Form merge field):
    - {key}: {description}

    Description:
    {What this endpoint does.}

---------------------------------------------------------------------------------------------------------/
```

- The "Accepts" section is used for POST endpoints that receive form data via `{{ Form }}`. GET endpoints document their query parameters in the Description instead.
- The "Enabled Lava Commands" field lists the commands that must be enabled on this endpoint in Rock's admin UI for the Lava to execute correctly. Use `-` if no commands are needed.


#### Boilerplate templates
Field-by-field templates for the boilerplate ship with the plugin's skills — the Dynamic Data pair in the `surface-dynamicdata` skill's `assets/boilerplates/`, the other three in the `language-lava` skill's. A workspace may override any of them with its own `.claude/templates/` copy:

| Template | Applies to |
|---|---|
| `boilerplate-block-DynamicData-Query.md` | `-Query.lava.sql` files under `_code/Block-DynamicData/PageId_*/` |
| `boilerplate-block-DynamicData-FormattedOutput.md` | `-FormattedOutput.lava` files under `_code/Block-DynamicData/PageId_*/` |
| `boilerplate-block-LavaApplicationContent.md` | `.lava` files under `_code/Block-LavaApplicationContent/PageId_*/` |
| `boilerplate-LavaEndpoint.md` | `.lava` files under `_code/LavaApplications/*/Endpoints/` |
| `boilerplate-LavaShortcode.md` | `.lava` files under `_code/ShortCodes/ShortCodeId_*/` |


### Choosing the comment syntax in a `.lava.sql` file
A Dynamic Data query passes through two engines: Lava renders the file first, and SQL Server then receives whatever Lava produced. So the two comment syntaxes are not interchangeable — they have different destinations.

- A **Lava** comment (`//-` for one line, `/- ... -/` for a block) is stripped by the Lava engine. It never reaches SQL Server.
- A **SQL** comment (`--` for one line, `/* ... */` for a block) survives into the query text SQL Server parses, and will show up in Profiler and in the cached plan.

Two rules follow from that:

1. **The boilerplate is always a SQL block comment** (`/* ... */`). It should survive into the text you paste into your SQL client when you are debugging the query outside of Rock.
2. **Line comments are layer-matched.** A note about Lava-layer code takes a Lava comment; a note about SQL takes a SQL comment.

```
{% assign input_CampusId = 'Global' | PageParameter:'c1' | AsInteger %} //- Campus picker on the PageParameterFilter Block

-- Stage 1: @FilteredRows — one row per Attendance record. All filtering happens here.
DECLARE @FilteredRows table (
```

Getting this backwards costs little but costs something real: a `--` comment written *about a Lava assignment* ships a sentence about Lava to the database on every single execution, where it surfaces in a query plan somebody else is trying to read.

### In-line comments
In addition to the boilerplate, each file can have many in-line comments.

It's understandable that shorter files might omit in-line comments because the boilerplate is sufficient.

For longer files, expect an in-line comment for each logical section or code block.


## README inside each subdirectory
This repository is structured with GitHub in mind. When opening a subdirectory, if it contains a README.md, GitHub will render it as the page content in addition to a list-view of the other files in that subdirectory.

Therefore, each subdirectory should have a README.md written with the intent of offering context to the developer who is navigating this code via GitHub's UI.

These README documents are intended to contain details that are specific to that subdirectory. For example:
1. The overview of what all the folders/files in this subdirectory are meant to do.
2. The specific Rock version that might be necessary for the folders/files in this subdirectory.
3. Any other directories that these code files might be relying on.
4. Any websites that have relevant information for reference.


## Shared Reference Docs in AIskill-RockRMS
Knowledge that pertains to all Rock RMS development lives in the `Consta-Tech/AIskill-RockRMS` repository and reaches every developer through this plugin's skill references.

Shared knowledge about anything related to configuring things in Rock, writing code for Rock, and tested/verified/confirmed behaviors that are specific to Rock. When you learn something new that is worth sharing (a tested behavior, a gotcha, a schema note), propose it as a PR to `Consta-Tech/AIskill-RockRMS` so the whole team receives it automatically.


## Writing Style

### Spell out BlockType and entity names in prose
Write "Dynamic Data block" and "Lava Application Content block" — never "DD block" or "LAC block". The same goes for any shorthand coined mid-conversation: PageParameterFilter, AttendanceOccurrence, RegistrationInstance, and so on.

An abbreviation that is obvious while you are working is not obvious months later, and these documents are read by collaborators who were never in the conversation where the shorthand was invented. The cost of spelling it out is a few characters; the cost of not doing so is a reader who has to reverse-engineer what "DD" meant.

This applies to prose in shared reference docs, to README files, and to in-file comment blocks. Inside code samples, identifiers such as CSS class names and log prefixes are placeholders a reader will rename anyway — but prefer a spelled-out or abbreviation-free name there too when it costs nothing (`my-block-root` over `my-dd-root`).