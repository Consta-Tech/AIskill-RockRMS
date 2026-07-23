# Boilerplate Template — Blocks

Applies to `.lava` files under `_code/Block-LavaApplicationContent/PageId_*/`.

## Structure rules

The boilerplate is a Lava block comment (`/- … -/`) at the top of the file. Every field below is on its own line, indented 4 spaces from the comment boundary. Field labels use Title Case followed by a colon.

### Required fields (in this order)

1. **Path** — the file's path relative to the repo root. Always present, always first.
2. **Lava Application Slug** - the slug of the Lava Application
3. **Enabled Lava Commands** - a bulleted list of Lava Commands that must be enabled for this Block to function as intended. If none are required, a single bullet that says: `- none`
4. **Page Parameters this Block reads** — a bulleted list of page parameters (from the URL or page route) that the block consumes. One parameter per bullet, formatted as `{ParamName}: {one-line description}`.
5. **Description** — ONE paragraph in present tense describing what the block renders or does. Maximum ~5 lines. Mention the page role (Create / Edit / Browser / Filters / Content), reveal behavior if applicable, and any global listeners the block installs.

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

### Heuristics

- Blocks are the entry point the user sees — the Description should orient a reader to the block's **page-level role**, not its internal implementation.
- The Boilerplate should aim to be be 121-characters wide
  - In other words, the comment block opens with one forward-slash (`/`) and is followed by 120 dashes (`-`). And the comment block closes with 120 dashes, followed by a forward-slash
  - Technically, it can be as wide as 147-characters. We can be flexible between 121-characters and 147-characters if it'll benefit the formatting of prose. However, it must never exceed 147-characters in width.
- If the block installs global event listeners (e.g., `htmx:afterSwap` handlers on `document.body`), mention them in the Description so future developers know the block has side effects beyond its own DOM.
- Target length: **≤ 20 lines** between the opening and closing comment boundaries.

## Example

```lava
/------------------------------------------------------------------------------------------------------------------------

    Path:
    _code/Block-LavaApplicationContent/PageId_6076/BlockId_14800.lava

    Lava Application Slug:
    RoomManagement

    Enabled Lava Commands:
    - Rock Entity Modify
        - modifyreservation
        - modifyreservationlocation
        - modifyreservationresource
        - modifyschedule
    - Sql

    Page Parameters this Block reads:
    - ReservationId: loads an existing Reservation for editing (optional; omit for new)

    Description:
    Renders the Create / Edit Reservation page. Hosts five wizard sections (When, Location, Resource, Questions, Admin)
    driven by the RoomManagement Lava Application's endpoints.
    Installs a global `htmx:afterSwap` listener on `document.body` to reconcile outline highlighting and auto-unpin
    conflict rows when the DOM changes.

------------------------------------------------------------------------------------------------------------------------/
```
