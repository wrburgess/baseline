# MCP, Plugin, and Documentation Access Audit

This document captures the full audit of MCP servers, CLI tools, plugins, and documentation sources used by AI agents across the MPI suite. It defines canonical per-repo profiles, a documentation access hierarchy, and surface configuration recommendations.

**Issue:** #239 | **Epic:** #225 | **Date:** 2026-03-08

---

## Key Finding: Deferred Tool Loading

Claude Code automatically defers MCP tool definitions when they exceed 10% of the context window. Deferred tools are **not loaded into context at boot** — they only enter context when discovered via ToolSearch. The ToolSearch meta-tool adds ~500 tokens of overhead regardless of how many deferred tools exist.

**Implication:** The primary cost of excess MCP servers is not boot tokens but **ToolSearch noise** — more deferred tools means lower signal-to-noise when Claude searches for the right tool, and increased risk of Claude choosing an MCP tool over a more efficient CLI approach.

Sources:
- Claude Code cost management docs
- Tool Search documentation
- Community benchmarks (see References section)

---

## MCP Server Audit

### Current State (All Repos)

All 5 MPI repos (optimus, avails, sfa, garden, harvest) share identical `.mcp.json` configurations with 8 MCP servers:

| Server | Configured Tools | Full Tool Set | Type |
|--------|-----------------|---------------|------|
| GitHub | 40 | 40 | HTTP (api.githubcopilot.com) |
| Heroku | 36 | 36 | stdio (npx @heroku/mcp-server) |
| Context7 | 2 | 2 | HTTP (mcp.context7.com) |
| Honeybadger | 4 | 4 | stdio (npx @iflow-mcp/honeybadger-mcp) |
| AWS | 2 | 2 | stdio (uvx awslabs.aws-api-mcp-server) |
| Cloudflare | 2 | 2 | HTTP (mcp.cloudflare.com) |
| DO Databases | 18 | 39 | HTTP (databases.mcp.digitalocean.com) |
| DO Droplets | 9 | 43 | HTTP (droplets.mcp.digitalocean.com) |
| **Total** | **113** | **168** | |

Additionally, a `claude_ai_Cloudflare_Developer_Platform` server (25 tools) is loaded from the Claude platform, bringing the total to **193 deferred tool definitions**.

### Duplicate Integrations

| Duplicate | Source A | Source B | Resolution |
|-----------|----------|----------|------------|
| Context7 | `context7` MCP server (`.mcp.json`) | `context7@claude-plugins-official` plugin | **Remove MCP server** — plugin is superior (adds skill auto-triggering) |
| Cloudflare | `cloudflare` MCP server (`.mcp.json`, 2 tools) | `claude_ai_Cloudflare_Developer_Platform` (25 tools) | **Keep `.mcp.json` server** (Code Mode, 2 tools for full API) — **remove `claude_ai` server** (HC-manual: disconnect in Claude.ai settings) |

### MCP vs CLI Comparison

For each MCP server with a CLI equivalent, we evaluated auth complexity, context cost, response quality, and community consensus.

#### GitHub MCP (40 tools) vs `gh` CLI

| Dimension | GitHub MCP | `gh` CLI |
|-----------|-----------|----------|
| Auth | Bearer token in `.mcp.json` (Copilot OAuth, rotates) | `gh auth login` (OAuth, persisted in `~/.config/gh/`) |
| Context cost | ~500 tokens (ToolSearch) + per-tool when loaded | 0 tokens at boot |
| Response quality | Structured JSON | Formatted text (or JSON via `--json`) |
| Coverage | 40 tools (PRs, issues, repos, code search, reviews) | Full GitHub API via `gh api` + all subcommands |
| Debugging | Opaque MCP errors | Transparent stderr, exit codes |
| Benchmark | Higher token overhead per operation | 28-33% better token efficiency |

**Verdict: Remove GitHub MCP. Use `gh` CLI.**

Community consensus strongly favors `gh` over the GitHub MCP. Claude is well-trained on `gh` syntax, the CLI provides full API coverage, and benchmarks show significant token savings. Auth is simpler (one-time `gh auth login` vs managing tokens in `.mcp.json`).

#### Heroku MCP (36 tools) vs `heroku` CLI

| Dimension | Heroku MCP | `heroku` CLI |
|-----------|-----------|-------------|
| Auth | `HEROKU_API_KEY` in `.mcp.json` env | `heroku login` (OAuth) or `HEROKU_API_KEY` env var |
| Context cost | ~500 tokens (shared ToolSearch) + per-tool | 0 tokens |
| Boot overhead | Spawns Node.js process via `npx` each session | Already-installed binary |
| Implementation | Wraps the `heroku` CLI internally | Native |

**Verdict: Remove Heroku MCP. Use `heroku` CLI.**

The Heroku MCP server literally wraps the `heroku` CLI under the hood. There is no unique capability. Keep the CLI for now (HC decision to retain Heroku access pending Kamal migration).

#### DigitalOcean MCP (2 servers, 82 total tools) vs `doctl` CLI

| Dimension | DO MCP (databases + droplets) | `doctl` CLI |
|-----------|------------------------------|-------------|
| Auth | Bearer token (DO API token) per server | `doctl auth init` or env var |
| Context cost | ~500 tokens (shared ToolSearch) + per-tool | 0 tokens |
| Server count | 2 separate HTTP servers | 1 CLI binary |
| Coverage | 27 configured tools (subset) | Full DO API (60+ resource types) |

**Verdict: Remove both DO MCP servers. Use `doctl` CLI.**

Two separate MCP servers for what one CLI covers entirely. Infrastructure tasks are rare in daily development. `doctl` provides full coverage with zero context overhead.

#### AWS MCP (2 tools) vs `aws` CLI

| Dimension | AWS MCP | `aws` CLI |
|-----------|---------|----------|
| Auth | AWS keys in `.mcp.json` env | `~/.aws/credentials` or env vars |
| Context cost | Minimal (2 tools) | 0 tokens |
| Unique value | `suggest_aws_commands` for API discovery | Claude well-trained on common `aws` commands |
| Safety | `READ_OPERATIONS_ONLY=true` enforced | Requires CLAUDE.md instruction for read-only |
| Boot overhead | Spawns Python process via `uvx` | Already-installed binary |

**Verdict: Remove AWS MCP. Use `aws` CLI.**

Marginal call — the 2-tool footprint is minimal and the API discovery feature has some value. However, AWS tasks are infrequent in MPI development, Claude handles `aws` CLI well, and read-only enforcement can be documented in CLAUDE.md. Removing eliminates one more stdio process and credential to manage.

#### Cloudflare MCP (2 tools, Code Mode) vs `wrangler` CLI

| Dimension | Cloudflare Code Mode MCP | `wrangler` CLI |
|-----------|------------------------|----------------|
| Auth | Bearer token (Cloudflare API token) | `wrangler login` or env var |
| Context cost | ~1,000 tokens total (2 tools) | 0 tokens |
| Coverage | Entire Cloudflare API (2,500+ endpoints) via 2 tools | Workers/Pages/R2/D1 subset |
| Design | Model writes JS against typed API spec | Standard CLI subcommands |

**Verdict: Keep Cloudflare Code Mode MCP.**

This is a well-designed MCP that provides access to the entire Cloudflare API through just 2 tools at ~1,000 tokens — a model for how MCP servers should work. `wrangler` covers only a subset. For repos that use Cloudflare services, this MCP earns its token cost.

#### Honeybadger MCP (4 tools) — No CLI Equivalent

| Dimension | Honeybadger MCP |
|-----------|----------------|
| Auth | API key in `.mcp.json` env |
| Context cost | Minimal (4 tools) |
| CLI alternative | None — no Honeybadger CLI exists |
| Value | Error tracking, fault analysis, notice retrieval |

**Verdict: Keep Honeybadger MCP.**

No CLI alternative exists. Small footprint (4 tools). Valuable for debugging production errors across MPI apps. Only include in repos that have Honeybadger projects configured.

### Decision Matrix Summary

| Server | Tools | Verdict | Rationale | Enforcement |
|--------|-------|---------|-----------|-------------|
| GitHub MCP | 40 | **Remove** | `gh` CLI is faster, cheaper, better debuggable | Update `.mcp.json.example` |
| Heroku MCP | 36 | **Remove** | Wraps the CLI internally; use `heroku` CLI directly | Update `.mcp.json.example` |
| DO Databases MCP | 18 | **Remove** | `doctl` CLI covers everything with zero context cost | Update `.mcp.json.example` |
| DO Droplets MCP | 9 | **Remove** | Same as above | Update `.mcp.json.example` |
| AWS MCP | 2 | **Remove** | `aws` CLI sufficient; infrequent use | Update `.mcp.json.example` |
| Context7 MCP | 2 | **Remove** | Duplicated by Context7 plugin (which is superior) | Update `.mcp.json.example` |
| Cloudflare claude_ai | 25 | **Remove** | Redundant with Code Mode server | HC-manual: disconnect in Claude.ai |
| Cloudflare Code Mode | 2 | **Keep** | Excellent design, full API via 2 tools | Stays in `.mcp.json.example` |
| Honeybadger MCP | 4 | **Keep** | No CLI alternative, small footprint | Stays in `.mcp.json.example` |

**Before:** 8 servers, 113 configured tools (193 including platform server)
**After:** 2 servers, 6 configured tools
**Reduction:** 107 configured tool definitions removed (95% reduction); 187 total tools removed including platform server

---

## Plugin Audit

### Current State

9 plugins enabled globally in `~/.claude/settings.json`:

| Plugin | Type | What It Adds | MPI Relevance | Verdict |
|--------|------|-------------|---------------|---------|
| `context7` | Tools + Skills | 2 MCP tools (resolve-library-id, query-docs) + auto-trigger skill for library docs | **High** — Rails, gem, and JS library docs | **Keep** |
| `playwright` | Tools | 22 tools (browser automation, screenshots, form filling, navigation) | **Medium-High** — feature specs, visual testing, debugging Stimulus | **Keep** |
| `pr-review-toolkit` | Agents + Skills | 6 specialized review agents (code-reviewer, comment-analyzer, type-design-analyzer, silent-failure-hunter, pr-test-analyzer, code-simplifier) | **High** — directly supports code review workflow | **Keep** |
| `code-review` | Agents + Skills | Automated multi-agent PR review with CLAUDE.md compliance checking and confidence scoring | **High** — complements pr-review-toolkit with automation | **Keep** |
| `skill-creator` | Skills | Create, modify, and benchmark custom skills | **Medium** — active use during Epic #225 | **Keep** (re-evaluate after epic) |
| `feature-dev` | Agents + Skills | 3 agents (code-architect, code-explorer, code-reviewer) + 7-phase guided feature dev | **Low** — MPI has own workflow (`/orch`, `/cplan`, `/impl`) | **Disable** (HC-manual) |
| `frontend-design` | Skills | Generates "distinctive, bold" UI with animations and custom styles | **Conflicts** — MPI uses Bootstrap 5.3 with minimal custom styles | **Disable** (HC-manual) |
| `ralph-loop` | Skills + Hook | Recurring task loop via Stop hook that intercepts session exits | **Low** — aggressive hook, niche use case | **Disable** (HC-manual; enable per-project when needed) |
| `figma` | Tools + Skills | 13 tools (design context, screenshots, code connect) + design-to-code skills | **Low-Medium** — default React+Tailwind output requires heavy adaptation for Rails/Bootstrap/ViewComponent | **Per-project** (HC-manual) |

### Disabled Plugins

| Plugin | Reason Disabled | Recommendation |
|--------|----------------|----------------|
| `worktrunk@worktrunk` | Worktree management | **Evaluate re-enabling** if multi-agent worktree workflows increase |
| `solargraph@claude-code-lsps` | Ruby LSP integration | **Evaluate re-enabling** — could improve Ruby code intelligence |

### Plugin Recommendations

**4 plugins recommended for disabling:**

1. **`feature-dev`** — MPI has its own documented development workflow (`/orch`, `/cplan`, `/impl`, CLAUDE.md architecture pointers). The generic 7-phase guided workflow duplicates this and may conflict with MPI's custom agent strategy.

2. **`frontend-design`** — Its philosophy of "bold aesthetic choices" and "high-impact animations" directly conflicts with MPI's Bootstrap-standard, minimal-custom-styles approach. It could cause agents to generate unnecessary CSS/animations instead of using Bootstrap utility classes.

3. **`ralph-loop`** — The Stop hook intercepts all session exits when active, which is disruptive for normal workflows. MPI's background agent patterns and `/orch` orchestration already cover iterative task needs. Enable per-project only when specifically planning a long iterative loop.

4. **`figma`** — The Figma MCP outputs React+Tailwind by default, requiring significant adaptation for MPI's Rails/Bootstrap/ViewComponent stack. Only enable in projects where Figma designs are actively being translated to code with custom design system rules.

**5 plugins recommended to keep:** `context7`, `playwright`, `pr-review-toolkit`, `code-review`, `skill-creator`.

**Key action:** Remove the Context7 MCP server from `.mcp.json` to eliminate the duplicate with the Context7 plugin. The plugin is strictly superior because it includes auto-triggering on library/framework questions.

**Note:** Plugin changes are global (`~/.claude/settings.json`) and affect all projects, not just MPI repos. All plugin recommendations are HC-manual actions with instructions.

---

## Documentation Access Hierarchy

Agents should follow this numbered priority order when seeking information:

### Priority Order

1. **CLAUDE.md + `.claude/rules/`** (always loaded at boot)
   - Project conventions, anti-patterns, required workflows
   - Backend, frontend, testing, and migration rules
   - Architecture pointers to detailed docs

2. **In-repo `docs/`** (read on demand, zero boot cost)
   - `docs/architecture/overview.md` — system architecture
   - Domain-specific docs (permissions, notifications, deployment)
   - Standards docs (`docs/standards/`)

3. **Existing codebase** (read on demand)
   - Read existing code before modifying — discover patterns from implementation
   - Reference files cited in CLAUDE.md (e.g., `app/views/admin/system_groups/_form.html.erb` for form patterns)

4. **Context7 plugin** (on demand, for external library docs)
   - Use for Rails, gem, and JS library documentation
   - Auto-triggers on library/framework questions
   - Provides up-to-date docs that may be newer than training data

5. **Memory files** (`~/.claude/projects/*/memory/`)
   - Cross-session knowledge, project patterns, HC preferences
   - Referenced on demand, MEMORY.md always loaded

6. **Web search / Web fetch** (last resort)
   - For information not available in any of the above
   - Prefer official documentation URLs
   - Use for researching new libraries, debugging unusual errors

### Anti-Patterns

- Do not web search for information available in `docs/` or CLAUDE.md
- Do not use Context7 for project-specific patterns (use in-repo docs)
- Do not rely on memory for architecture details (use docs — memory can go stale)
- Do not skip reading existing code before suggesting changes

---

## Per-Repo Canonical Profiles

Each MPI repo should include only the MCP servers it actually needs. Profiles are defined here; cross-repo propagation is #232's scope.

### Service-to-Repo Mapping

| Service | Optimus | Avails | SFA | Garden | Harvest |
|---------|---------|--------|-----|--------|---------|
| Cloudflare (Code Mode) | Template only | Yes | Yes | Yes | Yes |
| Honeybadger | Template only | Yes | Yes | Yes | Yes |
| Heroku (CLI, pending removal) | CLI | CLI | CLI | — | CLI |

**Notes:**
- **GitHub** access via `gh` CLI (all repos) — no MCP server needed
- **Heroku** access via `heroku` CLI (repos with Heroku apps) — no MCP server needed. Pending removal post-Kamal migration.
- **DigitalOcean** access via `doctl` CLI (when needed) — no MCP server needed
- **AWS** access via `aws` CLI (when needed) — no MCP server needed
- **Context7** access via plugin (all repos) — no MCP server needed
- **Optimus** has no Honeybadger project (it's a template app) and no Cloudflare presence
- **Garden** has no Heroku app (static site generator)

### Canonical `.mcp.json` Profiles

**Normative schema:** `.mcp.json.example` in the Optimus repo is the single source of truth for MCP server configuration. The JSON snippets below are simplified summaries — always refer to `.mcp.json.example` for the exact schema, including Honeybadger's multi-project env var pattern (`HONEYBADGER_PROJECT_SFA`, `HONEYBADGER_PROJECT_AVAILS`, etc.).

#### Optimus (Template)

Optimus itself has no production deployment, no Honeybadger project, and no Cloudflare presence — it does not need MCP servers at runtime. However, `.mcp.json.example` in the Optimus repo contains the production profile (Cloudflare + Honeybadger) because it serves as the **reference template** that other MPI repos copy during onboarding. Developers working only on Optimus can use an empty `.mcp.json` or skip `bin/setup-mcp` entirely.

#### Avails, SFA, Harvest (Production Rails Apps)

Use `.mcp.json.example` as-is. Both Cloudflare (Code Mode) and Honeybadger are relevant for production Rails apps with error monitoring and Cloudflare-managed domains.

#### Garden (Static Site Generator)

Use `.mcp.json.example` as-is. Garden uses Cloudflare for hosting and has a Honeybadger project for error tracking. No Heroku app (static site), so no `heroku` CLI needed.

### Tool Count Comparison

| Repo | Before (tools) | After (tools) | Reduction |
|------|---------------|--------------|-----------|
| Optimus | 113 | 6 (template) / 0 (runtime) | 95-100% |
| Avails | 113 | 6 | 95% |
| SFA | 113 | 6 | 95% |
| Garden | 113 | 6 | 95% |
| Harvest | 113 | 6 | 95% |

---

## Surface Configuration Recommendations

| Surface | MCP Servers | Plugins | CLI Tools | Notes |
|---------|------------|---------|-----------|-------|
| **TUI** (primary) | Full per-repo profile | All enabled | All available | Primary development surface |
| **Desktop app** | Full per-repo profile | All enabled | All available | Same as TUI — no reason to differentiate |
| **VS Code** | Full per-repo profile | Code-focused subset | All available | Consider disabling figma, ralph-loop if not used in IDE |
| **Background agents** | Per-repo profile | Minimal (pr-review-toolkit, code-review) | Task-specific | Agents in worktrees should only load what the task needs |
| **Codex** | N/A (different tool model) | N/A | Limited shell access | Codex uses its own integration layer (#229) |

**Recommendation:** Keep TUI and Desktop identical. For VS Code and background agents, the per-repo `.mcp.json` profile already limits servers appropriately. Plugin configuration is global and cannot currently be per-surface, so no changes needed there.

---

## HC-Manual Action Checklist

These changes cannot be enforced via committed files and require manual HC action:

### MCP Servers
- [ ] **Remove `claude_ai_Cloudflare_Developer_Platform`** — Disconnect in Claude.ai account settings or Claude Desktop MCP settings. This removes 25 redundant tools.
- [ ] **Remove Context7 MCP from `.mcp.json`** after confirming Context7 plugin works correctly — run a test query with the plugin to verify.
- [ ] **Apply per-repo `.mcp.json` profiles** — After running `bin/setup-mcp` on Optimus, manually update `.mcp.json` in avails, sfa, garden, and harvest repos (or wait for #232 propagation mechanism).
- [ ] **Verify CLI tools are authenticated** — Ensure `gh auth status`, `heroku auth:whoami`, `doctl auth list`, and `aws sts get-caller-identity` all work before removing MCP servers.

### Plugins (in `~/.claude/settings.json` — affects ALL projects)
- [ ] **Disable `feature-dev`** — Set `"feature-dev@claude-plugins-official": false`. MPI's own workflow (`/orch`, `/cplan`, `/impl`) supersedes the generic 7-phase guided workflow.
- [ ] **Disable `frontend-design`** — Set `"frontend-design@claude-plugins-official": false`. Its "bold aesthetics" philosophy conflicts with MPI's Bootstrap-standard approach.
- [ ] **Disable `ralph-loop`** — Set `"ralph-loop@claude-plugins-official": false`. The Stop hook intercepts all session exits. Re-enable per-project only when planning a long iterative loop.
- [ ] **Disable `figma` globally** — Set `"figma@claude-plugins-official": false`. Re-enable per-project when translating Figma designs, with custom design system rules for Rails/Bootstrap/ViewComponent output.
- [ ] **Evaluate `worktrunk@worktrunk`** — Consider re-enabling if multi-agent worktree workflows become common.
- [ ] **Evaluate `solargraph@claude-code-lsps`** — Consider re-enabling for improved Ruby code intelligence.

---

## CLI Authentication Quick Reference

After removing MCP servers, ensure these CLI tools are authenticated:

| CLI Tool | Auth Command | Persistence |
|----------|-------------|-------------|
| `gh` | `gh auth login` | `~/.config/gh/hosts.yml` |
| `heroku` | `heroku login` | `~/.netrc` |
| `doctl` | `doctl auth init` | `~/.config/doctl/config.yaml` |
| `aws` | `aws configure` or `~/.aws/credentials` | `~/.aws/` |
| `wrangler` | `wrangler login` | `~/.wrangler/config/` |

---

## References

- [Claude Code cost management docs](https://code.claude.com/docs/en/costs)
- [Claude Code MCP integration docs](https://code.claude.com/docs/en/mcp)
- [Tool Search documentation](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool)
- [MCP vs CLI benchmarks](https://mariozechner.at/posts/2025-08-15-mcp-vs-cli/)
- [Cloudflare Code Mode announcement](https://blog.cloudflare.com/code-mode-mcp/)
- [GitHub CLI vs MCP consensus](https://ejholmes.github.io/2026/02/28/mcp-is-dead-long-live-the-cli.html)
- [Optimizing MCP context usage](https://scottspence.com/posts/optimising-mcp-server-context-usage-in-claude-code)
