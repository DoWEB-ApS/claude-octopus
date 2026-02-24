---
command: doweb
description: Primary /doweb entrypoint for enterprise orchestration
version: 1.0.0
category: workflow
tags: [doweb, enterprise, orchestration]
created: 2026-02-23
updated: 2026-02-23
---

# Doweb

Primary enterprise command namespace.

## Usage

```bash
/doweb:mode
/doweb:next-task
/doweb:run-project
```

## Execution Contract

1. Resolve intent from user input.
2. If it maps to enterprise flow, run `scripts/orchestrate.sh` with the matching command.
3. Enforce policy-driven behavior from `.doweb/policy/project-run.yaml`.
