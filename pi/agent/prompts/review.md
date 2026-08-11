---
description: Review code changes, defaults to uncommitted
argument-hint: "[revision|branch|PR-URL]"
---

Dispatch a code review of the requested changes to the `review` subagent and present the findings.

Use the `subagent` tool to run the review as a single foreground child (wait for the result so the findings stream into this conversation):

- agent: `review`
- child task: the review target is `$ARGUMENTS` — a git revision (commit hash, or `HEAD` and `HEAD`-prefixed forms such as `HEAD~1`, `HEAD^`, `HEAD@{n}`, including ranges like `HEAD~3..HEAD`), a branch name, or a PR URL/number. Pass it through as-is; the agent decides how to interpret it.
- **Constraint on `HEAD` notation**: any target starting with `HEAD` (`HEAD`, `HEAD~N`, `HEAD^`, `HEAD@{n}`, `HEAD~N..HEAD`) is a git revision, never a branch name. Pass it through unchanged so the subagent resolves it with `git show` / `git diff`; do not coerce it into a branch-aware form (do not rewrite it to `origin/...`, append `...HEAD` — the three-dot branch-comparison form — or treat it as a branch to compare against).
- If the target is empty, the child task is: "Review all uncommitted changes (`git diff`, `git diff --cached`, `git status --short`)."

Do not run your own ad-hoc review; delegate to the `review` subagent with the `subagent` tool, then present the returned feedback.
