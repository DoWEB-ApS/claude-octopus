# Claude Octopus

Every model has blind spots. Claude Octopus fills them by orchestrating Codex, Gemini, and Claude together — three perspectives, adversarial review, and consensus gathering so no single model's gaps slip through.

> This fork uses the `/doweb:*` namespace for enterprise workflows.

<p align="center">
  <img src="assets/social-preview.jpg" alt="Claude Octopus" width="640">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Version-8.22.6-blue" alt="Version 8.22.6">
  <img src="https://img.shields.io/badge/Claude_Code-v2.1.34+-blueviolet" alt="Requires Claude Code v2.1.34+">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License">
</p>

---

## Quickstart

**Install** — inside Claude Code or from your terminal:

```bash
/plugin marketplace add https://github.com/DoWEB-ApS/claude-octopus.git
/plugin install claude-octopus@doweb-plugins
```

Then run setup:

```
/doweb:setup
```

Setup detects installed providers, shows what's missing, and walks you through configuration. You need **zero** external providers to start — Claude is built in. Add Codex or Gemini for multi-AI features.

**Try it now:**

```bash
/doweb:research OAuth 2.1 patterns          # Multi-source synthesis
/doweb:review                                # Code review with security analysis
/doweb:debate monorepo vs microservices      # Three-way AI debate
```

### Enterprise Container Quickstart (`/doweb`)

```bash
cp .env.enterprise.example .env.enterprise
docker compose --profile enterprise build doweb-agent
docker compose --profile enterprise run --rm doweb-agent bash

claude login  # OAuth subscription
codex login   # OAuth subscription
gemini        # OAuth subscription
task-master --help  # Task Master CLI (full app) in container

./scripts/orchestrate.sh setup-enterprise
./scripts/orchestrate.sh mode supervised
./scripts/orchestrate.sh next-task
```

`setup-enterprise` bootstraps `.doweb/*`, initializes Task Master (`task-master init` when CLI is available, scaffold fallback otherwise), and writes a baseline `.mcp.json` (`octo-claw`, `playwright`, `context7`) so you can plan before execution.

OAuth tokens and CLI state are persisted in Docker volume `doweb-root` (mounted at `/root`), so login is usually a one-time step per machine.
If `gemini` appears to hang after login, it is usually in interactive mode; exit with `Ctrl+C` and run `./scripts/orchestrate.sh detect-providers` to confirm auth state.
`install.sh` (plugin installer) is auto-run at container startup by default (`DOWEB_AUTO_PLUGIN_INSTALL=true`).
The enterprise container intentionally runs as root to avoid UID/GID write issues on mounted repos/volumes.
Run the compose command from the repo you want mounted at `/project`, or attach another repo with:
`docker compose --profile enterprise run --rm -v /absolute/path/to/app:/project doweb-agent bash`

For full enterprise flow (TaskMaster + ClawVault + autonomous gates), see [docs/ENTERPRISE-DOWEB.md](docs/ENTERPRISE-DOWEB.md).

Global launcher install:
`./scripts/install-doweb-coder.sh` then run `doweb-coder` from any project folder.

Auto-update before run:
`DOWEB_AUTO_UPDATE=1 doweb-coder` (or `doweb-coder --auto-update`)

---

## What It Does

Five commands that show the full range:

```bash
/doweb:embrace build stripe integration     # Full lifecycle: research -> PRD -> code -> review
/doweb:research htmx vs react in 2026       # Triple-perspective synthesis from 3 providers
/doweb:tdd create user auth                 # Disciplined red-green-refactor orchestration
/doweb:debate monorepo vs microservices     # Formal adversarial debate between AI providers
/doweb:deck q3 product strategy             # Brief -> research -> outline gate -> PPTX export
```

Each command orchestrates up to three AI providers, applies quality gates, and produces a deliverable. Here's the full set:

### Core Commands

| Command | What it does |
|---------|-------------|
| `/doweb:embrace` | Full 4-phase workflow: discover, define, develop, deliver |
| `/doweb:research` | Deep multi-source research with synthesis |
| `/doweb:review` | Multi-perspective code review |
| `/doweb:tdd` | Test-driven development with red-green-refactor |
| `/doweb:debug` | Systematic 4-phase debugging |
| `/doweb:security` | OWASP vulnerability scan |
| `/doweb:debate` | Structured three-way AI debate |
| `/doweb:prd` | AI-optimized PRD with 100-point scoring |
| `/doweb:extract` | Reverse-engineer design systems from code or URLs |
| `/doweb:deck` | Slide deck generation with outline approval gate |
| `/doweb:docs` | Export to PPTX, DOCX, PDF |
| `/doweb:schedule` | Scheduled workflow runner with cron, budget gates, kill switches |
| `/doweb:brainstorm` | Creative thought partner session |
| `doctor` | Environment diagnostics — 8 check categories with filtering and JSON output |

Don't remember the command name? Just describe what you need:

```
/doweb research microservices patterns    -> routes to discover phase
/doweb build user authentication          -> routes to develop phase
/doweb compare Redis vs DynamoDB          -> routes to debate
```

The smart router parses your intent and selects the right workflow.

[Full command reference (39 commands)](docs/COMMAND-REFERENCE.md)

---

## How It Works

### Three Providers, One Workflow

Claude Octopus coordinates Codex (OpenAI), Gemini (Google), and Claude (Anthropic) across every workflow. Each provider has a distinct role:

| Provider | Role |
|----------|------|
| Codex | Implementation depth — code patterns, technical analysis, architecture |
| Gemini | Ecosystem breadth — alternatives, security review, research synthesis |
| Claude | Orchestration — quality gates, consensus building, final synthesis |

Providers run in parallel for research, sequentially for problem scoping, and adversarially for review. A 75% consensus quality gate prevents questionable work from shipping.

### Double Diamond Phases

Four structured phases adapted from the UK Design Council's methodology:

| Phase | Command | What happens |
|-------|---------|-------------|
| Discover | `/doweb:discover` | Multi-AI research and broad exploration |
| Define | `/doweb:define` | Requirements clarification with consensus |
| Develop | `/doweb:develop` | Implementation with quality gates |
| Deliver | `/doweb:deliver` | Adversarial review and go/no-go scoring |

Run phases individually or all four with `/doweb:embrace`. Configure autonomy: supervised (approve each phase), semi-autonomous (intervene on failures), or autonomous (run all four).

### 31 Personas

Specialized agents that activate automatically based on your request. When you say "audit my API for vulnerabilities," security-auditor activates. When you say "write a research paper," academic-writer takes over.

Categories: Software Engineering (11), Specialized Development (6), Documentation & Communication (5), Research & Strategy (4), Creative & Design (3).

[Full persona reference](docs/AGENTS.md) | [All 44 skills](docs/COMMAND-REFERENCE.md)

---

## Providers and Cost

### Authentication

| Method | Codex | Gemini | Claude |
|--------|-------|--------|--------|
| OAuth (recommended) | `codex login` — included in ChatGPT subscription | Google account — included in AI subscription | Built into Claude Code |
| API key | `OPENAI_API_KEY` — per-token billing | `GEMINI_API_KEY` — per-token billing | Built into Claude Code |

OAuth users pay nothing beyond their existing subscriptions.

### What Works Without External Providers

Everything except multi-AI features. You get all 31 personas, structured workflows, smart routing, context detection, and every skill. Multi-AI orchestration (parallel analysis, debate, consensus) activates when external providers are configured.

---

## Trust and Safety

**Namespace isolation** — Only `/doweb:*` commands and `doweb` natural language prefix activate the plugin. Your existing Claude Code setup is untouched.

**Data locations** — Results in `~/.claude-octopus/results/`, logs in `~/.claude-octopus/logs/`, project state in `.octo/`. Nothing hidden.

**No telemetry** — No usage data collected. No phone-home. Fully open source.

**Provider transparency** — Visual indicators (colored dots) show exactly which providers are running and when external APIs are called. You always know what's happening.

**Clean uninstall** — `/plugin uninstall claude-octopus@doweb-plugins` removes everything. If you see a scope error, add `--scope project`. No residual config changes.

---

## OpenClaw Compatibility

Claude Octopus ships with a compatibility layer for [OpenClaw](https://github.com/openclaw/openclaw), the open-source AI assistant framework. This lets you expose Octopus workflows to messaging platforms (Telegram, Discord, Signal, WhatsApp) without modifying the Claude Code plugin.

### Architecture

```
Claude Code Plugin (unchanged)
  └── .mcp.json ─── MCP Server ─── orchestrate.sh
                                        ↑
OpenClaw Extension ─────────────────────┘
```

Three components, zero changes to the core plugin:

| Component | Location | Purpose |
|-----------|----------|---------|
| MCP Server | `mcp-server/` | Exposes 10 Octopus tools via Model Context Protocol |
| OpenClaw Extension | `openclaw/` | Wraps workflows for OpenClaw's extension API |
| Skill Schema | `mcp-server/src/schema/skill-schema.json` | Universal skill metadata format |

### MCP Server

The MCP server auto-starts when the plugin is enabled (via `.mcp.json`). It exposes:

- `octopus_discover`, `octopus_define`, `octopus_develop`, `octopus_deliver` — Individual phases
- `octopus_embrace` — Full Double Diamond workflow
- `octopus_debate`, `octopus_review`, `octopus_security` — Specialized workflows
- `octopus_list_skills`, `octopus_status` — Introspection

Any MCP-compatible client can connect to the server.

### OpenClaw Extension

Install in an OpenClaw instance:

```bash
npm install @claude-octopus/openclaw
```

The extension registers as an OpenClaw plugin with configurable workflows, autonomy modes, and Claude Code path resolution.

### Build & Validate

```bash
./scripts/build-openclaw.sh          # Regenerate skill registry from frontmatter
./scripts/build-openclaw.sh --check  # CI mode — exits non-zero if out of sync
./tests/validate-openclaw.sh         # 13-check validation suite
```

---

## FAQ

**Do I need all three AI providers?**
No. One external provider plus Claude gives you multi-AI features. No external providers still gives you personas, workflows, and skills.

**Will this break my existing Claude Code setup?**
No. Activates only with the `octo` prefix. Results stored separately. Uninstalls cleanly.

**What happens if a provider times out?**
The workflow continues with available providers. You'll see the status in the visual indicators.

---

## Documentation

- [Command Reference](docs/COMMAND-REFERENCE.md) — All 39 commands
- [Enterprise `/doweb` Runtime](docs/ENTERPRISE-DOWEB.md) — Container profile, policy gates, TaskMaster/ClawVault flow
- [Architecture](docs/ARCHITECTURE.md) — How it works internally
- [Plugin Architecture](docs/PLUGIN-ARCHITECTURE.md) — Plugin structure
- [Agents & Personas](docs/AGENTS.md) — All 31 personas
- [Visual Indicators](docs/VISUAL-INDICATORS.md) — Provider status
- [Debug Mode](docs/DEBUG_MODE.md) — Troubleshooting
- [Changelog](CHANGELOG.md)

---

## Attribution

- **[wolverin0/claude-skills](https://github.com/wolverin0/claude-skills)** — AI Debate Hub. MIT License.
- **[obra/superpowers](https://github.com/obra/superpowers)** — Discipline skills patterns. MIT License.
- **[UK Design Council](https://www.designcouncil.org.uk/our-resources/the-double-diamond/)** — Double Diamond methodology.

---

## Contributing

1. [Report issues](https://github.com/DoWEB-ApS/claude-octopus/issues)
2. Submit PRs following existing code style
3. `git clone https://github.com/DoWEB-ApS/claude-octopus.git && make test`

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## License

MIT — see [LICENSE](LICENSE)

<p align="center">
  <a href="https://github.com/DoWEB-ApS">DoWEB-ApS</a> | MIT License | <a href="https://github.com/DoWEB-ApS/claude-octopus/issues">Report Issues</a>
</p>
