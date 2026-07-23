# About Documentation
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

Shared knowledge about anything related to configuring things in Rock, writing code for Rock, and tested/verified/confirmed behaviors that are specific to Rock.

When you learn something new that is worth sharing (a tested behavior, a gotcha, a schema note), propose it as a PR to `Consta-Tech/AIskill-RockRMS` so the whole team receives it automatically.