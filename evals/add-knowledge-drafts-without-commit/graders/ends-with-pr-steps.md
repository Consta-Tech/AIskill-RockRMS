---
type: llm
---

PASS if the final message says the work was not committed and lists the steps the user runs by hand to commit, push the branch, and open the pull request (git add / git commit / git push and a PR step), and names the new reference file and its manifest row.

FAIL if the final message claims to have committed or pushed, or gives no instructions for opening the PR.
