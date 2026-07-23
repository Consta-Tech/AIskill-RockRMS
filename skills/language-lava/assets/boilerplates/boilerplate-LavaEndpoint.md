# Boilerplate Template — Endpoints

Applies to `.lava` files under `_code/LavaApplications/*/Endpoints/`.

## Structure rules

The boilerplate is a Lava block comment (`/- … -/`) at the top of the file. Every field below is on its own line, indented 4 spaces from the comment boundary. Field labels use Title Case followed by a colon.

### Required fields (in this order)

1. **Path** — the file's path relative to the repo root. Always present, always first.
2. **Lava Application Slug** — the slug of the parent Lava Application.
3. **Lava Endpoint Slug** — the slug registered in Rock's Lava Application admin.
4. **HTTP Method** — `GET` or `POST` or `PUT`. One value only.
5. **Enabled Lava Commands** - a bulleted list of Lava Commands that must be enabled for this Block to function as intended. If none are required, a single bullet that says: `- none`
6. **Accepts** — what the endpoint receives. Use `Accepts (Form merge field):` for POST endpoints or `Accepts (QueryString):` for GET endpoints. One parameter per bullet, formatted as `{key}: {one-line description}`. Include only the section that matches the HTTP method; delete the other.
7. **Description** — ONE paragraph in present tense describing what the endpoint does, what it returns, and who calls it. Maximum ~5 lines.

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

8. **Response shape** — include only when the response uses OOB regions or a non-trivial structure. Keep it to a single-line pointer to the README section that documents the full contract. Do not inline the full OOB shape here.

### Heuristics

- The Boilerplate should aim to be be 121-characters wide
  - In other words, the comment block opens with one forward-slash (`/`) and is followed by 120 dashes (`-`). And the comment block closes with 120 dashes, followed by a forward-slash
  - Technically, it can be as wide as 147-characters. We can be flexible between 121-characters and 147-characters if it'll benefit the formatting of prose. However, it must never exceed 147-characters in width.
- There is an empty `    ` between `Lava Application Slug` and `Lava Endpoint Slug`. This is because the IDE has a coloriztion of whitespaces, and including that empty space between `Lava Application Slug` and `Lava Endpoint Slug` makes it easier for the Developer to visually read those two related pieces of information together.
- The Description should explain the endpoint's **current behavior**, not its history. No version stamps, no "added in vX.Y" prose, no conversation citations.
- If the boilerplate currently contains multi-paragraph explanations (OOB contracts, algorithm walkthroughs, cross-endpoint conventions), those belong either in the directory README (cross-file) or in an inline `{% comment %}` near the relevant code (single-file). Leave a one-line pointer in the boilerplate.
- Target length: **≤ 30 lines** between the opening and closing comment boundaries.

## Example

```lava
/------------------------------------------------------------------------------------------------------------------------

    Path:
    _code/LavaApplications/RoomManagement/Endpoints/_add-reservationLocation.lava

    Lava Application Slug:
    RoomManagement
    
    Lava Endpoint Slug:
    _add-reservationLocation

    HTTP Method:
    POST

    Enabled Lava Commands:
    - Rock Entity Modify
        - modifyreservationlocation
    - Sql

    Accepts (Form merge field):
    - ReservationId         (int, required)
    - LocationId            (int, required)
    - LocationLayoutId      (int, optional)

    Description:
    Inserts a ReservationLocation junction row after running a recurrence-aware server-side conflict check
    (per-occurrence overlap via `| DatesFromICal:200`).
    Locations do not carry BufferTime. Returns OOB-driven HTML fragments for the picker tbody, summary panel, and
    outline — see Endpoints/README.md § "OOB contract".

------------------------------------------------------------------------------------------------------------------------/
```
