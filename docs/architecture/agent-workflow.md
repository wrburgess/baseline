# Agent Workflow Architecture

This document describes how AI agents (Claude Code, Copilot) interact in the MPI development workflow.

## Agent Roles

For the full role registry with knowledge domains, construct mapping, and cross-repo applicability, see [`agent-roles.md`](agent-roles.md).

### Agent Tools

| Agent Tool | Primary Function | Trigger |
|------------|-----------------|---------|
| **Claude Code (CC)** | Primary development agent — analyzes issues, plans, implements, creates PRs | Human invokes via CLI commands |
| **Codex** | Plan reviewer and PR reviewer — quality gate | Human invokes via CLI or automated triggers |
| **GitHub Copilot** | Automated PR reviewer and inline code assistant | Automatic on PR creation via repository settings, or IDE integration |

### Knowledge Roles

Roles are **contexts loaded into the same agent**, not separate agents. Each role represents knowledge domains and conventions that activate based on the task and files being worked on. A single session may use multiple roles. The "Primary Construct" column describes the **target architecture** proposed in #228/#229 — some constructs are not yet implemented.

| # | Role | Primary Construct | Cross-Repo? |
|---|------|-------------------|-------------|
| 1 | Product Manager | Memory + shared business context (deferred — #233) | All apps |
| 2 | Front End Designer | Rules (`app/components/`, `app/assets/`) + skill | Apps with UI |
| 3 | Frontend Developer | Rules (`app/javascript/`, `app/views/`) | Apps with UI |
| 4 | Backend Developer | Rules (`app/models/`, `app/controllers/`, `db/`) | All Rails apps |
| 5 | Testing & QA | Rules (`spec/`) + review skills | All apps |
| 6 | Infrastructure | Skill (triggered, not always-loaded) | Infra + deploy configs |
| 7 | External Services | Skill (per-service, on-demand) | Varies by app |
| 8 | Digital Presence Optimization | Skill (triggered for public-facing work) | Garden, Harvest, SFA |

## Workflow

See `docs/standards/development-lifecycle.md` for the full lifecycle reference.

```
── Stage 1: Assess (/assess NNN) ──
1. HC creates GitHub Issue
        │
2. CC analyzes issue, posts assessment + options on Issue
        │
3. HC sends assessment to Codex for review
        │
4. HC chooses option
        │
── Stage 2: Plan (/cplan NNN) ──
5. CC creates plan (including testing strategy + agent strategy)
   └── Posts plan on Issue
        │
6. HC sends plan to Codex for review
        │
7. HC approves plan
        │
── Stage 3: Implement (/impl NNN) ──
8. CC implements
   ├── Creates branch (or worktree via wt)
   ├── Writes code + tests per plan's testing strategy
   ├── Runs rubocop + rspec + brakeman + bundler-audit
   ├── Self-reviews against checklist
   ├── Creates PR with implementation notes
   └── Posts brief link on Issue
        │
── Stage 4: Verify (/verify NNN) ──
9. CC self-reviews PR against plan
   ├── Checks plan alignment and scope creep
   ├── Reviews test quality
   └── Posts self-review summary on PR
        │
── Stage 5: Deliver (/final NNN) ──
10. Reviewer (Codex and/or Copilot) reviews the PR
    └── Posts code review with P0/P1/P2 findings
        │
11. CC reads review comments (/rtr NNN)
    ├── Categorizes comments
    ├── Proposes resolutions
    └── Presents options to HC
        │
12. HC chooses which comments to address
        │
13. CC addresses review comments, pushes, replies
        │
14. CC finalizes (/final NNN)
    ├── Rebases, verifies CI
    ├── Posts SOW on PR, links SOW on Issue
    └── Notifies HC ready for merge
        │
15. HC merges PR → Issue closed
```

## Configuration Files

| File | Agent | Purpose |
|------|-------|---------|
| `CLAUDE.md` | Claude Code | Primary instructions, patterns, commands, architecture |
| `AGENTS.md` | All agents | Universal agent instructions, review guidelines, architecture |
| `.github/copilot-instructions.md` | GitHub Copilot | Copilot-specific instructions and patterns |
| `.claude/settings.json` | Claude Code | Permissions, hooks configuration |
| `.claude/commands/*.md` | Claude Code | Reusable workflow command templates |

## Review Severity Levels

Automated reviewers use severity levels defined in `AGENTS.md`:

- **P0 — Must Fix**: Security vulnerabilities, missing authorization, broken tests, credentials in code, data loss risks
- **P1 — Should Fix**: N+1 queries, missing validations, pattern violations, missing tests, exposed Ransack attributes
- **P2 — Consider**: Naming, organization, performance, edge cases

Copilot flags issues based on `.github/copilot-instructions.md` and the severity definitions in `AGENTS.md`.

## Agent Attribution

Every agent must include attribution on all work. This is enforced by `CLAUDE.md`, `AGENTS.md`, and `.github/copilot-instructions.md`:

```
Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
Co-Authored-By: GitHub Copilot <noreply@github.com>
```

## GitHub Copilot Code Review Setup

### Prerequisites

- GitHub Copilot enabled for the repository (requires a Copilot Business or Enterprise plan, or individual Pro plan)
- `.github/copilot-instructions.md` committed to the repository with project-specific guidance

### Enable Automatic PR Review

1. Go to repository **Settings → Copilot → Code review**
2. Enable **automatic code review** for pull requests
3. Copilot reads `.github/copilot-instructions.md` for project-specific patterns and review criteria

### Manual Review Trigger

Request a Copilot review on any PR through the GitHub UI:

1. Open the PR on GitHub
2. Click **Reviewers** in the sidebar
3. Select **Copilot** from the reviewer list

Or use the GitHub CLI:

```bash
gh pr edit NNN --add-reviewer copilot
```

### What Copilot Reviews

Copilot evaluates PRs against:

- `.github/copilot-instructions.md` — project-specific patterns, architecture, conventions
- General code quality — security, performance, correctness
- The severity levels defined in `AGENTS.md` (P0/P1/P2)

## Multi-Agent Patterns

### When to Use Multiple Agents

| Scenario | Strategy | Example |
|----------|----------|---------|
| Small feature (< 5 files) | Single agent, simple branch | Add a field to a form |
| Medium feature (5-15 files) | Single agent, evaluate worktree | New CRUD resource |
| Large feature (15+ files, independent subsystems) | Parallel agents via worktrees | New module with models, controllers, views, specs |
| Urgent hotfix alongside feature work | Worktree for isolation | Fix bug on main while feature branch continues |

### Parallel Agent Workflow

When a plan calls for parallel agents, use the `/orch NNN` command to generate an orchestration plan. The workflow is:

```
1. HC approves plan with parallel strategy
        │
2. CC creates orchestration plan (/orch NNN)
   ├── Defines work streams with exclusive file ownership
   ├── Creates worktrees via wt create <branch>
   └── Posts orchestration plan on Issue
        │
3. HC approves orchestration plan
        │
4. Agents execute in parallel
   ├── Agent A: Stream 1 (e.g., models + migrations)
   ├── Agent B: Stream 2 (e.g., controllers + views)
   └── Each agent runs pre-commit checks on their scope
        │
5. Integration
   ├── First stream merges to integration branch
   ├── Subsequent streams rebase and merge
   ├── Full test suite runs on integrated code
   └── Single PR created from integration branch
        │
6. Normal review flow continues (/verify → Copilot review → /rtr → /final)
```

### File Ownership Rules

When multiple agents work in parallel, conflicts are prevented through exclusive file ownership:

- **No two agents modify the same file** — if they must, one owns it and the other waits
- **Shared interfaces are defined upfront** — method signatures, model attributes, route paths
- **Database migrations belong to one stream** — typically the model/data stream
- **Spec files follow their source** — the agent that writes `app/models/foo.rb` also writes `spec/models/foo_spec.rb`

### Worktree vs Worktrunk Decision

| Tool | When to Use |
|------|-------------|
| `git worktree add` | One-off isolation, simple parallel work |
| `wt create` (Worktrunk) | Multi-agent work needing shared hooks, config, and commit message generation |
| Simple branch | Single agent, single focus, no isolation needed |

### Agent Communication

Agents coordinate through:

1. **Issue comments** — orchestration plan defines contracts between streams
2. **Shared interface definitions** — method signatures and expected behavior documented before work starts
3. **Completion signals** — each agent commits and pushes when their stream is done
4. **Integration agent** — one agent (usually Main) handles merging all streams

## Command Quick Reference

### Lifecycle Commands

| Command | Stage | Purpose |
|---------|-------|---------|
| `/assess NNN` | 1. Assess | Analyze issue, research codebase, propose options |
| `/cplan NNN` | 2. Plan | Create implementation plan with testing + agent strategy |
| `/impl NNN` | 3. Implement | Execute plan, self-review, create PR |
| `/verify NNN` | 4. Verify | Self-review PR against plan |
| `/final NNN` | 5. Deliver | Post SOW on PR, link on Issue, prepare for merge |
| `/rtr NNN` | (Deliver) | Read and respond to PR review comments |

### Supporting Commands

| Command | Purpose |
|---------|---------|
| `/orch NNN` | Design multi-agent orchestration (when `/cplan` recommends parallel) |
| `/explore TOPIC` | Deep-dive into a codebase area |
| `/compare REPO` | Diff standards against another MPI repo |
| `/dep-review NNN` | Review Dependabot/dependency update PR |
| `/db-health` | Run database health diagnostics |
| `/memory-review` | Audit auto-memory and recommend maintenance |

All commands are top-level files in `.claude/commands/`. See `docs/standards/development-lifecycle.md` for the full workflow reference.
