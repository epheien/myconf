---
description: Review code changes, defaults to uncommitted
argument-hint: "[commit|branch|PR-URL]"
---
Use the `subagent` tool to dispatch a code review to the `review` agent type:

- subagent_type: "review"
- run_in_background: false (foreground — wait for the result and present it)
- description: "Code review" (or a short 3-5 word summary of the input)
- prompt: 把用户输入原样传入;若为空,传 "Review uncommitted changes"

User input to review: $ARGUMENTS
