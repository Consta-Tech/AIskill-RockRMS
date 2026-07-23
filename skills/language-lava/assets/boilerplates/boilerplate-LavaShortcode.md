# Boilerplate Template — ShortCodes

Applies to `.lava` files under `_code/ShortCodes/ShortCodeId_*/`.

## Structure rules

The boilerplate is a Lava block comment (`/- … -/`) at the top of the file. Every field below is on its own line, indented 4 spaces from the comment boundary. Field labels use Title Case followed by a colon.

### Required fields (in this order)

1. **Path** — the file's path relative to the repo root. Always present, always first.
2. **ShortCode Tag Name** — the exact, case-sensitive tag name registered in Rock's ShortCode admin.
3. **ShortCode Type** — `Inline` or `Block`.
4. **Enabled Lava Commands (set in ShortCode admin)** - a bulleted list of Lava Commands that must be enabled for this Block to function as intended. If none are required, a single bullet that says: `- none`
5. **Parameters** — a bulleted list of parameters the ShortCode accepts. One per line, formatted as: `{param}     ({type}, required|optional, default {value if optional}) — {one-line description}`.
6. **Example Usage** — a single invocation example showing the tag with representative parameter values. Indented 8 spaces from the comment boundary.

#### About Lava Commands

As of 2026-MAY-27 (and Rock v18.2), this is the full list of Lava Commands that have a checkbox in the Block's configuration UI:
1. All
2. Adaptive Message
3. AI Search
4. Cache
5. Execute
6. Interaction Content Channel Item Write
7. Interaction Intent Write
8. Interaction Write
9. Observe
10. Reservation Summaries
11. Rock Entity
12. Rock Entity Delete
13. Rock Entity Modify
14. Search
15. Sql
16. Web Request
17. Workflow Activate

- **`renderlavaendpoint`** does not have a corresponding checkbox in Rock's Enabled Lava Commands admin UI. Even if the file uses this command, do not list it. If it's the only command present, replace the list with `-` (none required).
- If a boilerplate needs to specify multiple Lava Commands, the bulletlist should order the Lava Commands in the order shown above.
- Avoid configuring a block with the 'All' checkbox checked, unless user specifically mentions wanting that checkbox checked.
- It has been confirmed that the 'Execute' Lava Command will be retired after Rock v18.
- 'Rock Entity' is the umbrella that includes using Lava for querying (READ) any entities. Examples:
  - `{% person ... %}...{% endperson %}`
  - `{% group ... %}...{% endgroup %}`
- 'Rock Entity Delete' is the umbrella that includes using Lava for deleting any entities. Examples:
  - `{% deletegroup ... %}...{% enddeletegroup %}`
  - `{% deletereservation ... %}...{% enddeletereservation %}`
- 'Rock Entity Modify' is the umbrella that includes using Lava for modifying (UPDATE) or creating any entities. Examples:
  - `{% modifyreservation ... %}...{% endmodifyreservation %}`
  - `{% modifyschedule ... %}...{% endmodifyschedule %}`

### Optional fields

7. **Output** — include only when the ShortCode emits a scalar value or a non-obvious format. One paragraph or a short bullet list describing what it returns.

### Excluded fields

- **Used by** — dependency tracing (which files consume this ShortCode) belongs in the corresponding `README.md` for the ShortCode directory, not in the boilerplate. If a boilerplate currently contains a "Used by" list, flag it for relocation to the README.

### Heuristics

- The Boilerplate should aim to be be 121-characters wide
  - In other words, the comment block opens with one forward-slash (`/`) and is followed by 120 dashes (`-`). And the comment block closes with 120 dashes, followed by a forward-slash
  - Technically, it can be as wide as 147-characters. We can be flexible between 121-characters and 147-characters if it'll benefit the formatting of prose. However, it must never exceed 147-characters in width.
- There is an empty `    ` between `Lava Application Slug` and `Lava Endpoint Slug`. This is because the IDE has a coloriztion of whitespaces, and including that empty space between `Lava Application Slug` and `Lava Endpoint Slug` makes it easier for the Developer to visually read those two related pieces of information together.
- The **Parameters** list should reflect the ShortCode's *current* interface. Remove parameters that were deprecated or renamed in earlier versions.
- The **Used by** list is valuable for tracing dependencies — keep it accurate. When auditing, verify that each listed consumer still exists and still calls this ShortCode.
- Target length: **≤ 30 lines** between the opening and closing comment boundaries.

## Example

```lava
/------------------------------------------------------------------------------------------------------------------------

    Path:
    _code/ShortCodes/ShortCodeId_140/ShortCodeId_140.lava

    ShortCode Tag Name:
    RmQuestionInput
    
    ShortCode Type:
    Inline

    Enabled Lava Commands (set in ShortCode admin):
    - Sql

    Parameters:
    - attributeId     (int, required) — the AttributeId of the question to render
    - entityId        (int, required) — the EntityId of the target entity (Reservation, Location, or Resource)
    - entityTypeId    (int, required) — the EntityTypeId corresponding to the target entity
    - disabled        (bool, optional, default false) — renders the input in read-only mode

    Example Usage:
    {[ RmQuestionInput
        attributeId:'{{ question.AttributeId }}'
        entityId:'{{ ReservationId }}'
        entityTypeId:'54' ]}

------------------------------------------------------------------------------------------------------------------------/
```
