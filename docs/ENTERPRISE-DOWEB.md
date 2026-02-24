# Enterprise `/doweb` Runtime

This fork adds an enterprise-oriented `/doweb` workflow with:
- container-first execution
- policy + gate enforcement
- TaskMaster task orchestration
- ClawVault memory persistence
- human-gated deployment

---

## What Is Included

### Runtime
- `docker-compose.yml` with profile `enterprise`
- `docker/enterprise-agent.Dockerfile` (Claude Code CLI + Codex CLI + Gemini CLI + jq + rg)
- `docker/entrypoint-enterprise.sh` bootstrap entrypoint
- `.env.enterprise.example` for environment setup

### Enterprise Policy + Memory
- `.doweb/policy/project-run.yaml`
- `.doweb/policy/gates.autonomous.yaml`
- `.doweb/policy/approved-mcp.json`
- `.doweb/clawvault/*` (memory folders)
- `.doweb/evidence/` (gate evidence)
- `.doweb/session.md` (session ledger)

### Integrations
- `scripts/integrations/taskmaster.sh`
- `scripts/integrations/clawvault.sh`

### New Orchestrator Commands
- `setup-enterprise`
- `mode [supervised|semi-autonomous|autonomous]`
- `next-task`
- `close-subtask <task-id>`
- `run-project [max-tasks]`
- `approve-deploy`

---

## Quick Start (Containerized)

1. Prepare env file:

```bash
cp .env.enterprise.example .env.enterprise
```

2. Build image:

```bash
docker compose --profile enterprise build doweb-agent
```

3. Open shell in enterprise runtime:

```bash
docker compose --profile enterprise run --rm doweb-agent bash
```

This automatically mounts your current host directory to `/workspace` in the container.
Run `docker compose ...` from the repository you want to work on.

If your plugin repo and app repo are different, mount the target repo explicitly:

```bash
docker compose --profile enterprise run --rm \
  -v /absolute/path/to/your-app:/project \
  doweb-agent bash
```

Note: the enterprise container runs as root to avoid host UID/GID mismatches when writing mounted workspace and Docker volumes.

4. Authenticate with OAuth subscriptions (no API keys required):

```bash
claude login
codex login
gemini
```

OAuth credentials and CLI state are persisted in Docker volume `doweb-root` (mounted at `/root`), so you normally do this once per machine.

If `gemini` appears to "freeze" after login, it is usually waiting in interactive mode. Exit with `Ctrl+C` and verify auth with:

```bash
./scripts/orchestrate.sh detect-providers
```

5. Bootstrap enterprise folders/policy:

```bash
./scripts/orchestrate.sh setup-enterprise
```

---

## Recommended Workflow


### Global Launcher (`doweb-coder`)

Install a global command that always uses this repo's enterprise runtime:

```bash
./scripts/install-doweb-coder.sh
# if needed: ./scripts/install-doweb-coder.sh "$HOME/.local/bin/doweb-coder"
```

Then from any project directory:

```bash
doweb-coder
```

This will:
- build `doweb-agent` (unless `--no-build` is passed)
- mount your current directory to `/project`
- open a shell in `/project`

Enable automatic update from GitHub before each run:

```bash
doweb-coder --auto-update
# or
DOWEB_AUTO_UPDATE=1 doweb-coder
```

Notes:
- auto-update runs `git pull --ff-only` in your plugin repo
- if local changes exist in plugin repo, auto-update is skipped safely

You can also run a command directly:

```bash
doweb-coder -- ./scripts/orchestrate.sh -d /project next-task
```

### 0) Bootstrap Project Plan

`setup-enterprise` now initializes both enterprise policy and a minimal TaskMaster scaffold:
- `.taskmaster/docs/prd.txt` (starter PRD template)
- `.taskmaster/tasks/tasks.json` (task graph file)

Typical planning flow:

```bash
./scripts/orchestrate.sh setup-enterprise
# edit .taskmaster/docs/prd.txt with Claude and customer input
# then parse/expand using your TaskMaster workflow
# ensure .taskmaster/tasks/tasks.json is populated before run-project
```

### 1) Supervised Mode (default)

```bash
./scripts/orchestrate.sh mode supervised
./scripts/orchestrate.sh next-task
./scripts/orchestrate.sh run-project
# review output and tests
./scripts/orchestrate.sh close-subtask <task-id>
```

### 2) Autonomous Mode (small projects / trusted scope)

```bash
./scripts/orchestrate.sh mode autonomous
./scripts/orchestrate.sh run-project 5
```

In autonomous mode, `close-subtask` requires:
- `.doweb/evidence/<task-id>/gate.json`
- all required gate fields set to `true`
- quorum checks that satisfy policy

### 3) Human Deploy Gate

```bash
./scripts/orchestrate.sh approve-deploy
```

This checks:
- all TaskMaster items are complete
- no blocker tasks remain
- deploy approval evidence is written to `.doweb/evidence/deploy-approval.json`

---

## Hooks and Automation

Hooks are part of plugin runtime behavior (not a separate manual step in daily task execution).  
For enterprise workflows, focus on these checks:

```bash
./scripts/orchestrate.sh doctor hooks
./scripts/orchestrate.sh doctor config
./scripts/orchestrate.sh doctor state
./scripts/orchestrate.sh detect-providers
```

If hooks/config are valid, proceed with:
- `next-task` for dependency-aware selection
- `run-project` for controlled execution
- `close-subtask` for gated completion

---

## Gate Evidence Contract

`close-subtask` in autonomous mode validates:

```json
{
  "tests_passed": true,
  "lint_passed": true,
  "typecheck_passed": true,
  "review_passed": true,
  "security_passed": true,
  "acceptance_passed": true,
  "decision_logged": true,
  "evidence_logged": true,
  "quorum": {
    "providers_total": 3,
    "agreeing": 2,
    "disagreement": false
  }
}
```

The exact required keys are read from `.doweb/policy/gates.autonomous.yaml`.

---

## MCP Policy

MCP allowlist is enforced against `.mcp.json` during `run-project`:
- allowlist file: `.doweb/policy/approved-mcp.json`
- default allowlist includes: `task-master-ai`, `clawvault`, `playwright`, `desktop-commander`, `octo-claw`

---

## Make Targets

```bash
make enterprise-build
make enterprise-shell
make enterprise-up
make enterprise-run
make enterprise-down
```

---

## Security Notes

- Containerization limits host impact but does not make execution risk-free.
- Treat mounted workspace as sensitive; model actions can still modify project files.
- Keep `approve-deploy` human-gated for production.
