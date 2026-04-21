# Human Collaborator (HC) Guide

This guide is for developers working on Baseline alongside AI collaborators (ACs). It covers your role in the development workflow, how to direct AI agents, what to review, and how to set up your environment.

## About Baseline

Baseline is a Rails 8 application starter template deployed at `https://baseline.kc.tennis`. It serves as the foundation for new projects — providing conventions, tooling, and a working deploy pipeline out of the box.

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
- **Merge PRs** into `main`

## Development Workflow

This is the standard flow for every feature or bug fix:

```
1. You create a GitHub Issue
       |
── Stage 1: Assess ──
2. You run: /assess NNN
   AC analyzes the issue, posts an assessment with options on the Issue
       |
3. You choose an option (comment on the Issue)
       |
── Stage 2: Plan ──
4. You run: /cplan NNN
   AC creates an implementation plan and posts it on the Issue
       |
5. You approve the plan (comment on the Issue)
       |
── Stage 3: Implement ──
6. You run: /impl NNN
   AC creates a branch, writes code + tests,
   runs all quality checks, self-reviews, opens a PR
       |
── Stage 4: Verify ──
7. You run: /verify NNN
   AC self-reviews PR against plan, posts summary on PR
       |
── Stage 5: Deliver ──
8. Reviewer (Codex and/or Copilot) reviews the PR
       |
9. You run: /rtr NNN
   AC reads review comments, proposes resolutions
       |
10. AC makes changes, pushes, replies to review comments
        |
11. You run: /final NNN
    AC rebases, verifies CI, posts Statement of Work on PR
        |
12. You merge the PR → Issue closed
```

## Commands Reference

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
| `/dep-review NNN` | Review a dependency update PR |
| `/db-health` | Run database health diagnostics |

## Pre-Commit Checks

Every commit must pass these four checks:

```bash
bundle exec rubocop -a       # Lint and auto-correct
bundle exec rspec             # Full test suite
bin/brakeman --no-pager -q    # Security static analysis
bin/bundler-audit check       # Vulnerable dependency check
```

CI runs the same checks — if it passes locally, it passes in CI.

## Environment Setup

### 1. Install dependencies

```bash
bundle install
yarn install
```

### 2. Fetch credentials

```bash
bin/setup-credentials         # Fetches development key (requires 1Password CLI)
```

The 1Password account is configured via the `BASELINE_OP_ACCOUNT` env var. Set it in your shell profile before running.

### 3. Prepare the database

```bash
bin/rails db:create db:migrate db:seed
```

### 4. Start the dev server

```bash
bin/dev    # Starts web + JS/CSS watchers + background worker via foreman
```

## Authoritative References

| Document | What It Covers |
|----------|----------------|
| [`CLAUDE.md`](../CLAUDE.md) | Primary AC instructions, patterns, commands, architecture |
| [`AGENTS.md`](../AGENTS.md) | Universal agent instructions, review guidelines |
| [`docs/standards/`](standards/) | Ruby, Rails, testing, code review conventions |
| [`docs/architecture/agent-workflow.md`](architecture/agent-workflow.md) | AC roles, multi-agent patterns |
