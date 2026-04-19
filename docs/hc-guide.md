# Human Collaborator (HC) Guide

This guide is for developers working on MPI Rails applications alongside AI collaborators (ACs). It covers your role in the development workflow, how to direct AI agents, what to review, and how to set up your environment.


## Terminology

| Term | Meaning |
|------|---------|
| **HC** | Human Collaborator — you |
| **AC** | AI Collaborator — any AI agent (Claude Code, GitHub Copilot, Codex) |
| **CC** | Claude Code — the primary AC for development work |
| **Reviewer** | External AI reviewer — currently Codex and/or GitHub Copilot |

## Your Role

You are the decision-maker. ACs propose, you choose. ACs implement, you verify. ACs review code, you review business logic and UX. The workflow is designed so that ACs handle the mechanical work while you focus on judgment calls that require domain knowledge, user empathy, and architectural vision.

Specifically, you:

- **Create issues** describing what needs to be built or fixed
- **Choose options** when the AC presents alternatives
- **Approve plans** before implementation starts
- **Review PRs** for business correctness, UX, and things ACs miss
- **Request merges** when satisfied with the work
- **Merge PRs** into `main`

## Development Workflow

This is the standard flow for every feature or bug fix:

```
1. You create a GitHub Issue
       |
── Stage 1: Assess ──
2. You run: /assess NNN
   AC analyzes the issue, asks clarifying questions,
   posts an assessment with options on the Issue
       |
3. You send assessment to Reviewer for validation
       |
4. You choose an option (comment on the Issue)
       |
── Stage 2: Plan ──
5. You run: /cplan NNN
   AC creates an implementation plan (including testing
   strategy and agent strategy) and posts it on the Issue
       |
6. You send plan to Reviewer for validation
       |
7. You approve the plan (comment on the Issue)
       |
── Stage 3: Implement ──
8. You run: /impl NNN
   AC creates a branch, writes code + tests,
   runs all quality checks, self-reviews, opens a PR
       |
── Stage 4: Verify ──
9. You run: /verify NNN
   AC self-reviews PR against plan, checks test quality,
   posts self-review summary on PR
       |
── Stage 5: Deliver ──
10. Reviewer (Codex and/or Copilot) reviews the PR
    (P0/P1/P2 findings posted as review comments)
        |
11. You run: /rtr NNN
    AC reads the review comments, categorizes them,
    proposes resolutions for you to choose from
        |
12. You choose which comments to address
        |
13. AC makes changes, pushes, replies to review comments
        |
14. You review the PR yourself (see "What to Review" below)
        |
15. You run: /final NNN
    AC rebases, verifies CI, posts Statement of Work on PR,
    links SOW on the original Issue
        |
16. You merge the PR → Issue closed
```

### For Larger Work

If the plan involves many files or independent subsystems, you can use:

- `/orch NNN` — AC designs a multi-agent orchestration plan with work streams and file ownership (agent strategy is determined during `/cplan`)

## Commands Reference

Run these as slash commands in Claude Code CLI:

### Core Workflow

| Command | Stage | What It Does |
|---------|-------|--------------|
| `/assess NNN` | 1. Assess | Analyze issue, post assessment + options |
| `/cplan NNN` | 2. Plan | Create implementation plan with testing + agent strategy |
| `/impl NNN` | 3. Implement | Implement plan, self-review, create PR |
| `/verify NNN` | 4. Verify | Self-review PR against plan, check test quality |
| `/rtr NNN` | 5. Deliver | Read and respond to Reviewer comments |
| `/final NNN` | 5. Deliver | Rebase, verify CI, post SOW, prepare for merge |

### Supporting Commands

| Command | What It Does |
|---------|--------------|
| `/orch NNN` | Design multi-agent work streams (when `/cplan` recommends parallel) |
| `/explore TOPIC` | Deep-dive into a codebase area |
| `/compare REPO` | Diff standards against another MPI repo |
| `/dep-review NNN` | Review a dependency update PR |
| `/db-health` | Run database health diagnostics |

### Quick Examples

```bash
# Stage 1: Assess
/assess 42            # AC posts analysis and options
# (send to Reviewer, then comment: "Option B")

# Stage 2: Plan
/cplan 42             # AC posts plan with testing strategy
# (send to Reviewer, then comment: "Approved")

# Stage 3: Implement
/impl 42              # AC implements, self-reviews, opens PR

# Stage 4: Verify
/verify 42            # AC self-reviews PR against plan

# Stage 5: Deliver
# (Copilot reviews → you run /rtr 42 → AC fixes)
/final 42             # AC posts SOW on PR, links on Issue
# (you merge on GitHub)
```

## What to Review

ACs are good at writing correct code, following patterns, and catching syntax issues. They are less reliable at business logic, UX coherence, and production-scale concerns. Focus your review on what ACs miss.

### Business Logic

- Does the implementation match the actual business requirement?
- Are edge cases from real-world usage handled?
- Do notification messages and permission names make sense to end users?

### User Experience

- Do flash messages read naturally?
- Are form labels clear to non-technical users?
- Is the sort order on index pages sensible?
- Is the show page layout logical — most important fields first?

### Data Integrity

- Are `dependent:` options correct? (`:destroy` vs `:nullify` vs `:restrict_with_error`)
- Do validations match actual business constraints?
- Could a migration fail on existing production data?

### Security

- Is authorization checking the right permission (not just present)?
- Are Ransack search attributes appropriately scoped?

### Agent-Specific Concerns

- Did the AC follow existing patterns or introduce new ones without justification?
- Is the AC attribution present on all commits?
- Did the AC over-engineer? (Extra abstractions, defensive code for impossible states)
- Are there "AI-isms"? (Overly verbose comments, unnecessary nil checks, generic error messages)

### Before Approving

- Pull the branch and run `bin/dev` — does the page actually work?
- Click through the UI flow manually
- Check the browser console for JavaScript errors
- Verify the page looks correct on a narrow viewport

See [docs/standards/hc-review-checklist.md](standards/hc-review-checklist.md) for the full checklist.

## Pre-Commit Requirements

Whether you commit code yourself or direct an AC to do it, every commit must pass these four checks:

```bash
bundle exec rubocop -a       # Lint and auto-correct
bundle exec rspec             # Full test suite
bin/brakeman --no-pager -q    # Security static analysis
bin/bundler-audit check       # Vulnerable dependency check
```

No exceptions. CI runs the same checks — if it passes locally, it passes in CI.

## Review Severity Levels

When Copilot or Claude Code reviews a PR, findings use these severity levels:

| Level | Meaning | Action |
|-------|---------|--------|
| **P0 — Must Fix** | Security, correctness, data integrity | Block merge until resolved |
| **P1 — Should Fix** | Performance, patterns, coverage | Fix before merge in most cases |
| **P2 — Consider** | Style, naming, edge cases | Address at your discretion |

## Branch Permissions

ACs operate under branch-based permissions:

- **Feature branches** — ACs have full autonomy (commit, edit, refactor without asking)
- **`main` branch** — ACs must ask before any change

This means once you approve a plan and run `/impl`, the AC will work independently on a feature branch without pausing to ask permission at every step.

## Environment Setup

### 1. Clone and install

```bash
git clone git@github.com:mpimedia/optimus.git
cd optimus
bin/setup                     # Bundle install, db:prepare, assets, clear
```

### 2. Runtime versions

Install [mise](https://mise.jdx.dev/) to manage Ruby, Node, PostgreSQL, and Yarn versions.

**Install mise:**

```bash
# macOS (Homebrew)
brew install mise

# Activate mise (add to ~/.zshrc or ~/.bashrc)
eval "$(mise activate zsh)"   # or bash
```

**Install project runtimes:**

```bash
# Install all runtimes defined in .tool-versions
mise install

# Or install individually
mise install ruby@4.0.1
mise install node@25.5.0
mise install postgres@17.6
mise install yarn@4.12.0
```

**Verify versions:**

```bash
mise current                  # Show all active versions
ruby --version                # ruby 4.0.1
node --version                # v25.5.0
pg_config --version           # PostgreSQL 17.6
yarn --version                # 4.12.0
```

**Useful mise commands:**

```bash
mise list                     # Show all installed versions
mise outdated                 # Check for newer versions
mise use ruby@4.0.1           # Set version in .tool-versions
```

### 3. Claude Code setup

```bash
# MCP servers (Cloudflare, Honeybadger — see docs/architecture/mcp-integration-audit.md)
bin/setup-mcp
# Or manually: cp .mcp.json.example .mcp.json and fill in Cloudflare + Honeybadger keys
# GitHub, Heroku, DO, AWS use CLI tools instead (gh, heroku, doctl, aws)

# Required plugin (replaces Context7 MCP server)
claude plugin install context7@claude-plugins-official

# Optional: Ruby LSP plugin
claude plugin marketplace add boostvolt/claude-code-lsps
claude plugin install solargraph@claude-code-lsps

# Enable LSP (add to ~/.zshrc or ~/.bashrc)
export ENABLE_LSP_TOOL=1
```

### 4. Personal AC settings (optional)

Create `.claude/settings.local.json` for personal Claude Code permissions beyond the shared defaults. This file is gitignored.

### 5. Development server

```bash
bin/dev                       # Starts web server, JS/CSS watchers, background worker
```

This runs `foreman` with `Procfile.development` on port 8000.

## Related Documentation

| Document | What It Covers |
|----------|---------------|
| [Architecture Overview](architecture/overview.md) | Optimus-specific models, controllers, patterns |
| [Agent Workflow](architecture/agent-workflow.md) | AC roles, multi-agent patterns, Copilot setup |
| [HC Review Checklist](standards/hc-review-checklist.md) | Detailed review checklist for HC PR reviews |
| [Testing Standards](standards/testing.md) | RSpec conventions, factory patterns, shared contexts |
| [Code Review Standards](standards/code-review.md) | Review checklist for all reviewers |
| [Style Standards](standards/style.md) | Ruby, CSS, JS, ERB conventions |
