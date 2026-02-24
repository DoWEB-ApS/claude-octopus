---
command: run-project
description: Run a full project loop over TaskMaster tasks
version: 1.0.0
category: enterprise
tags: [doweb, autonomous, orchestration]
created: 2026-02-23
updated: 2026-02-23
---

# Run Project

Execute ready tasks in sequence with policy enforcement.

## Usage

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/orchestrate.sh run-project
${CLAUDE_PLUGIN_ROOT}/scripts/orchestrate.sh run-project 3
```

`3` limits execution to the next three ready tasks.
