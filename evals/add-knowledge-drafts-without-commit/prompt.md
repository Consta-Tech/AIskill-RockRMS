---
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Grep, Glob, Skill, Bash, Write, Edit]
---

Please add the Content Channel View block to the rockrms plugin's documented knowledge. A clone of the plugin repo is already at `./AIskill-RockRMS` in this directory — work there, and do not try to fetch anything from the network; use the excerpt below as the source.

Topic: the Content Channel View block (core Rock, `RockWeb/Blocks/Cms/ContentChannelView.ascx`).
Source to cite: https://github.com/SparkDevNetwork/Rock/blob/develop/RockWeb/Blocks/Cms/ContentChannelView.ascx.cs

Excerpt (my own notes from reading that file today):

- The block renders the items of one Content Channel through a Lava template. Block settings include Channel (the content channel to show), Lava Template (the merge template; `Items` is the list of channel items in scope), Items Per Page, Cache Duration (seconds, with a separate Output Cache Duration and Item Cache Duration), Enable Debug, Merge Content (run Lava inside each item's content), Set Page Title (use the first item's title), Order (the sort expression), Filter Id (an optional DataViewFilter applied to the items), Query Parameter Filtering (allow URL parameters to filter by attribute), RSS Autodiscover, Meta Description Attribute, Meta Image Attribute, and Detail Page (a linked page for the item).
- With Query Parameter Filtering enabled, a query-string key matching an item attribute key narrows the list to items whose attribute has that value.
- Personalization segments and request filters, when enabled on the channel, further narrow the items; the block also respects each item's Start/Expire dates and the channel's "requires approval" status.
- The Lava template can call `Items | Where:'...'` on any item property or attribute; campus-specific filtering is usually done through an item attribute of the Campus field type combined with Query Parameter Filtering, not through a block setting.
