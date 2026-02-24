---
command: close-subtask
description: Close a subtask with gate validation and memory logging
version: 1.0.0
category: enterprise
tags: [doweb, gates, taskmaster]
created: 2026-02-23
updated: 2026-02-23
---

# Close Subtask

Close one task with policy-aware checks:
- autonomous mode validates `.doweb/evidence/<task>/gate.json`
- supervised mode requires explicit human approval

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/orchestrate.sh close-subtask <task-id>
```
