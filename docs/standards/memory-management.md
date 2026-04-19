# Memory Management Standards

Standards for managing Claude Code auto-memory (`~/.claude/projects/*/memory/`) across Baseline projects. Based on research findings F5.1–F5.5 from `docs/research/ai-best-practices.md`.

## Auto-Memory vs Repo-Tracked Docs

Auto-memory and repo-tracked docs serve different purposes. The boundary is durability and scope.

**Rule: If it should survive across machines and agents, it belongs in the repo. If it's context from the current engagement that may change, it belongs in auto-memory.**

| Belongs in auto-memory | Belongs in repo (CLAUDE.md / .claude/rules/ / docs/) |
|---|---|
| User preferences learned in conversation | Coding standards, anti-patterns |
| Active project status (what's in progress now) | Workflow process definitions |
| Feedback corrections from HC | Standing instructions (e.g., HC working style) |
| References to external systems discovered in conversation | Architecture, patterns |
| Temporary debugging insights for active work | Conventions derivable from code |
| Issue/PR tracking for in-flight work | Permanent reference material |

**Common mistakes:**
- Saving coding conventions to memory instead of `.claude/rules/` — these should be version-controlled and available on every machine
- Saving standing instructions to memory — these get lost when switching machines or pruning
- Saving architecture knowledge to memory instead of `docs/` — memory is per-machine, docs are shared via git

## Three-Tier Architecture

Memory operates in three tiers with different loading behavior and token costs.

| Tier | Location | Loading | Token Budget | Purpose |
|------|----------|---------|-------------|---------|
| **Hot** | `MEMORY.md` | Always loaded on every conversation | < 200 lines (~800 tokens) | Index/pointers to topic files, active project status |
| **Warm** | Topic files (`*.md` in memory dir) | Loaded when referenced or relevant | ~2,000 tokens per file | Domain knowledge, project details, feedback |
| **Cold** | `docs/`, `.claude/rules/` | Loaded via exploration or path-scoping | No per-file limit | Full reference material, standards, architecture |

**Total auto-memory budget:** Keep under 10,000 tokens across all memory files (~40KB). Beyond this, context rot degrades agent performance (research finding F5.2).

## MEMORY.md Standards

`MEMORY.md` is always loaded into context. Every token counts.

- **Max 200 lines** — content beyond line 200 is silently truncated
- **Index-only** — MEMORY.md contains pointers to topic files, not content itself
- **No frontmatter** — MEMORY.md is a plain Markdown index file
- **Required structure:**
  ```markdown
  # Memory

  ## [Section Name]
  - [Brief description] — see [topic-file.md](topic-file.md) for details

  ## [Section Name]
  - [Pointer to another topic file]
  ```
- **Keep concise** — one line per topic file pointer, brief descriptions only
- **No standing instructions** — these belong in CLAUDE.md or `.claude/rules/`

## Topic File Standards

Topic files are individual memory entries stored alongside MEMORY.md.

### Required Frontmatter

Every topic file must include frontmatter with three fields:

```markdown
---
name: Heroku Migration Status
description: Tracking migration from Heroku to Kamal + DigitalOcean for issue #141
type: project
---

[Content here]
```

| Field | Purpose | Values |
|-------|---------|--------|
| `name` | Human-readable name | Free text |
| `description` | Used by Claude Code to decide retrieval relevance | One line, specific enough to match future queries |
| `type` | Memory category | `user`, `feedback`, `project`, `reference` |

### Memory Types

| Type | When to Use | Examples |
|------|------------|---------|
| `user` | User role, preferences, knowledge level | "HC is senior Rails dev, new to Docker" |
| `feedback` | Corrections to agent behavior | "Don't summarize at end of responses" |
| `project` | Active work, decisions, status | "Epic #225 status and priority order" |
| `reference` | Pointers to external systems | "Pipeline bugs tracked in Linear project INGEST" |

### Content Guidelines

- Lead with the most important information
- Use bullet points, not prose paragraphs
- Include absolute dates, not relative ("2026-03-14", not "last Thursday")
- For `feedback` and `project` types, include **Why:** and **How to apply:** lines
- Keep individual topic files under 50 lines (~200 tokens) when possible
- One topic per file — don't combine unrelated subjects

## What NOT to Store in Memory

These belong elsewhere or are derivable from existing sources:

- **Code patterns and conventions** — derivable from codebase; put in `.claude/rules/`
- **Git history, recent changes** — use `git log` / `git blame`
- **Debugging solutions** — the fix is in the code; the commit message has context
- **Anything in CLAUDE.md or docs/** — don't duplicate repo-tracked content
- **Ephemeral task details** — use conversation context or tasks, not memory
- **Architecture and system design** — belongs in `docs/architecture/`

## Maintenance Cadence

Memory requires active curation. Indiscriminate accumulation degrades agent performance by up to 10% (research finding F5.5).

### When to Review

| Trigger | Action |
|---------|--------|
| **Quarterly** (baseline) | Run `/memory-review`, prune stale entries |
| **After closing an issue/PR** | Remove or archive project-type entries that tracked it |
| **After major features** | Update related topic files, remove debugging notes |
| **Before starting large new work** | Review MEMORY.md for relevance, clean up before adding |

### What to Check

1. **Staleness** — References to closed issues, merged PRs, completed projects
2. **Contradictions** — Entries that conflict with each other or with CLAUDE.md
3. **Duplicates** — Content that repeats what's in CLAUDE.md, `.claude/rules/`, or `docs/`
4. **Misplaced content** — Standing instructions or conventions that belong in repo files
5. **Token budget** — Total memory size approaching 10,000 tokens
6. **Missing frontmatter** — Topic files without `name`, `description`, `type`

### How to Review

Run `/memory-review` — this command audits the current project's memory and recommends specific actions. Do not modify memory files without HC approval.

## Cross-Project Standards

- **Per-project memory** — Each Baseline project has its own memory directory. No sharing between projects.
- **Consistent structure** — All projects should follow these same standards
- **Worktree memory is ephemeral** — Memory created in worktree agents is not preserved. Don't rely on it persisting.
- **Per-machine** — Memory is local to each development machine. Content that must be portable belongs in the repo, not memory.

## File Naming

- Use kebab-case: `heroku-migration.md`, not `heroku_migration.md`
- Name files by topic, not by date: `heroku-migration.md`, not `2026-02-08-notes.md`
- Keep names short and descriptive: 2-4 words

## Research Basis

These standards are informed by:
- **F5.1** — Three-tier memory architecture (Codified Context paper, Anthropic docs)
- **F5.2** — Simple RAG outperforms complex memory systems (MemoryBench)
- **F5.3** — Machine-readable specs over prose (Codified Context, Agentic KB Patterns)
- **F5.5** — Active curation over accumulation (MemoryBench: 10% degradation from indiscriminate storage)
- **S5.5** — 10,000 token budget, 200-line MEMORY.md limit (Claude Code docs, SFEIR)

See `docs/research/ai-best-practices.md` Area 5 for full source details.
