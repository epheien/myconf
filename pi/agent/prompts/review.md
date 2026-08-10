---
description: Review code changes, defaults to uncommitted
argument-hint: "[commit|branch|PR-URL]"
---

Dispatch a code review of the requested changes to the `review` subagent and present the findings.

Use the `subagent` tool to run the review as a single foreground child (wait for the result so the findings stream into this conversation):

- agent: `review`
- child task: the review target is `$ARGUMENTS` — a commit hash, branch name, or PR URL/number. Pass it through as-is; the agent decides how to interpret it.
- If the target is empty, the child task is: "Review all uncommitted changes (`git diff`, `git diff --cached`, `git status --short`)."

Do not run your own ad-hoc review; delegate to the `review` subagent with the `subagent` tool, then present the returned feedback.
