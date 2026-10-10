---
type: llm
focus: trace
---

PASS if the assistant's reply states, in about one sentence, that the rockrms plugin has no documented knowledge of the ContentChannelView block (or of this topic), and then asks the user to choose between two options before answering: (1) an answer from general knowledge clearly marked unverified, or (2) documenting the topic from a source URL. The reply may mention the rockrms-knowledge-current and rockrms-knowledge-future skills. It must stop and wait for the choice.

FAIL if the reply proceeds to explain how to configure the block's Lava template without first getting the user's choice, if it claims the plugin has been "trained", or if it invents a reference the plugin does not have.
