---
command: approve-deploy
description: Human deployment approval gate with evidence artifact
version: 1.0.0
category: enterprise
tags: [doweb, deploy, approval]
created: 2026-02-23
updated: 2026-02-23
---

# Approve Deploy

Final deployment gate:
- verifies all tasks are completed
- verifies no blockers remain
- writes deployment approval evidence

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/orchestrate.sh approve-deploy
```
