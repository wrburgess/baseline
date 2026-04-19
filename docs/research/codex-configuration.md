# Codex Configuration — Research & Audit

Parent epic: [#225 — Optimizing AI Contributions](https://github.com/mpimedia/optimus/issues/225)
Issue: [#229 — Audit and optimize Codex configuration across MPI suite](https://github.com/mpimedia/optimus/issues/229)
Scan date: 2026-03-08
Next scan due: 2026-03-22
Codex CLI version audited: 0.111.0

See [README.md](README.md) for quality gate rubric, confidence tiers, and re-scan schedule.

---

## Table of Contents

1. [Codex Configuration Format](#1-codex-configuration-format)
2. [MPI Ecosystem Audit](#2-mpi-ecosystem-audit)
3. [Codex vs Claude Code Comparison](#3-codex-vs-claude-code-comparison)
4. [Best Practices for Review Role](#4-best-practices-for-review-role)
5. [Recommendations](#5-recommendations)
6. [Source Registry](#source-registry)

---

## 1. Codex Configuration Format

### 1.1 Supported Config Files and Locations

Codex uses a layered configuration system with TOML-format config files and Markdown instruction files.

**Configuration files (`config.toml`):**

| Level | Path | Purpose |
|-------|------|---------|
| System | `/etc/codex/config.toml` | Machine-wide defaults (Unix only) |
| User | `~/.codex/config.toml` | Personal defaults across all projects |
| Project | `.codex/config.toml` | Project-specific overrides (requires trust) |
| Subdirectory | `<subdir>/.codex/config.toml` | Directory-scoped overrides (closest wins) |

**Instruction files (`AGENTS.md`):**

| Level | Path | Purpose |
|-------|------|---------|
| Global | `~/.codex/AGENTS.override.md` or `~/.codex/AGENTS.md` | Personal defaults (first non-empty wins) |
| Project root | `<repo>/AGENTS.override.md` or `<repo>/AGENTS.md` | Project-wide instructions |
| Subdirectory | `<subdir>/AGENTS.override.md` or `<subdir>/AGENTS.md` | Directory-scoped instructions |

**Other files in `~/.codex/`:**
- `auth.json` — Authentication credentials
- `history.jsonl` — Session transcripts

There is **no** `codex.json` file. The `.openai/` directory is not used by Codex CLI. [S1, S2]

### 1.2 Config Hierarchy (Precedence)

From highest to lowest priority [S2]:

1. CLI flags and `--config` / `-c` overrides
2. Profile values (`--profile <name>`)
3. Project `.codex/config.toml` (closest directory wins; trusted projects only)
4. User `~/.codex/config.toml`
5. System `/etc/codex/config.toml`
6. Built-in defaults

For instruction files, Codex concatenates from root downward — files closer to the current directory appear later in the combined prompt and effectively override earlier guidance. Concatenation stops at the `project_doc_max_bytes` limit (default: 32 KiB). [S3]

### 1.3 Instruction File Format and Size

- AGENTS.md files are plain Markdown, concatenated with blank lines between levels
- Default size limit: 32 KiB total across all concatenated AGENTS.md files (`project_doc_max_bytes`)
- Empty files are skipped automatically
- `AGENTS.override.md` takes precedence over `AGENTS.md` at the same directory level
- Fallback filenames are configurable via `project_doc_fallback_filenames` in `config.toml`
- The instruction chain is rebuilt on each Codex session start — no caching [S3]

### 1.4 Context Loading Behavior

**On boot:** Codex loads the concatenated AGENTS.md chain and the active `config.toml` settings. There is no equivalent of Claude Code's `@import` or skills progressive disclosure — all instruction content loads upfront.

**In-thread:** Codex does not have a skills/commands system equivalent to Claude Code's `.claude/commands/` or `.claude/skills/`. Custom slash commands exist but are simpler. MCP server tools are loaded at session start and persist. [S1, S4]

### 1.5 Model Selection

Current recommended models [S5]:

| Model | Use Case | Notes |
|-------|----------|-------|
| `gpt-5.4` | Default — professional work, complex tasks | Flagship; combines coding + reasoning + tool use |
| `gpt-5.3-codex` | Complex software engineering | Industry-leading for pure coding tasks |
| `gpt-5.3-codex-spark` | Fast iteration, real-time feedback | Text-only; ChatGPT Pro only |

Model is set via `model` key in `config.toml` or `--model` / `-m` CLI flag. Models can be switched mid-session via `/model` command.

For MPI's review use case, `gpt-5.4` is recommended as the default — its stronger reasoning capabilities are better suited for code review than raw coding performance. [inference]

### 1.6 Key Config.toml Settings

| Setting | Type | Default | Purpose |
|---------|------|---------|---------|
| `model` | string | `"gpt-5.4"` | Default AI model |
| `approval_policy` | string | `"on-request"` | When to prompt before running commands |
| `sandbox_mode` | string | `"workspace-write"` | Filesystem/network access level |
| `web_search` | string | `"cached"` | Web search mode |
| `model_reasoning_effort` | string | `"high"` | Reasoning intensity |
| `project_doc_max_bytes` | integer | 32768 | Max AGENTS.md total size |
| `project_doc_fallback_filenames` | array | `[]` | Alternate instruction file names |

**Feature flags** (under `[features]` table) [S7]:
- `multi_agent` — Agent spawning (experimental, default off)
- `fast_mode` — Service tier selection
- `undo` — Session undo (default off)
- `web_search` — Search tool integration

**MCP servers** are configured under `[mcp_servers.<id>]` in `config.toml` or managed via `codex mcp` CLI commands. [S2, S4]

**CLI commands and flags** [S8]: Codex provides `codex exec` for non-interactive automation (with `--json` output and `--output-schema` validation), `codex mcp` for MCP server management, `codex cloud` for cloud tasks, and `codex resume` for session continuation. The `--profile` flag enables role switching, and `--sandbox` / `--ask-for-approval` flags allow per-invocation overrides.

---

## 2. MPI Ecosystem Audit

### 2.1 Audit Methodology

**Fixed checklist files:** `AGENTS.md`, `.codex/`, `.openai/`, `codex.json`
**Discovery scan:** GitHub code search for keyword `codex` across each repo, plus `.github/` directory listing
**Scan commands:** `gh api repos/<repo>/contents/<path>`, `gh search code "codex" --repo <repo>`

### 2.2 Per-Repo Evidence Table

| Repo | Default Branch | Commit SHA | AGENTS.md | .codex/ | .openai/ | codex.json | Discovery Scan Hits | Additional Paths |
|------|---------------|-----------|-----------|---------|----------|------------|-------------------|-----------------|
| `mpimedia/optimus` | `main` | `00c16b3` | Yes | No | No | No | `AGENTS.md`, `bin/guard-protected-branch`, `docs/architecture/agent-roles.md`, `docs/architecture/agent-workflow.md` | `.github/copilot-instructions.md` |
| `mpimedia/avails_server` | `main` | `392deb6` | Yes | No | No | No | `AGENTS.md`, `bin/guard-protected-branch` | `.github/copilot-instructions.md` |
| `mpimedia/wpa_film_library` | `main` | `c6f77b1` | Yes | No | No | No | `AGENTS.md`, `CLAUDE.md` | `.github/copilot-instructions.md` |
| `mpimedia/garden` | `main` | `3cfef7b` | Yes | No | No | No | `AGENTS.md` | `.github/copilot-instructions.md` |
| `mpimedia/harvest` | `main` | `e3e777a` | Yes | No | No | No | `AGENTS.md`, `CLAUDE.md` | `.github/copilot-instructions.md` |
| `mpimedia/markez-crm` | `main` | `acff9d9` | Yes | No | No | No | (none — no "codex" keyword matches) | `.github/copilot-instructions.md` |
| `mpimedia/mpi-infrastructure` | `main` | `ba70ce4` | Yes | No | No | No | (none — no "codex" keyword matches) | `.github/copilot-instructions.md` |
| `mpimedia/.github` | `main` | `3f84dba` | No | No | No | No | (none — no "codex" keyword matches) | `.github/copilot-instructions.md` |

### 2.3 Audit Summary

**Consistent across all app repos (7/8):**
- AGENTS.md exists at repo root — this is the sole Codex configuration surface
- No `.codex/config.toml` in any repo — no project-level Codex settings
- No `.openai/` or `codex.json` anywhere

**Inconsistencies:**
- `mpimedia/.github` has no AGENTS.md (org-level repo, not an application)
- `markez-crm` and `mpi-infrastructure` have AGENTS.md but no "codex" keyword hits in discovery scan — their AGENTS.md files may not reference Codex specifically
- Only `optimus` has Codex-related documentation beyond AGENTS.md (in `docs/architecture/`)

**Key finding:** AGENTS.md is doing all the work. There is zero Codex-specific configuration (`.codex/config.toml`) in any MPI repo. All Codex behavior customization is instruction-based, not settings-based.

---

## 3. Codex vs Claude Code Comparison

### 3.1 Feature Comparison Matrix

| Capability | Claude Code | Codex CLI | Gap Analysis |
|-----------|-------------|-----------|-------------|
| **Instruction file** | `CLAUDE.md` (auto-loaded) | `AGENTS.md` (auto-loaded) | Equivalent purpose; different naming |
| **Config file format** | `.claude/settings.json` (JSON) | `.codex/config.toml` (TOML) | Different format, similar function |
| **Config hierarchy** | Home → project root → subdirectories | System → user → project → subdirectory → CLI flags | Codex has more layers (system, profiles) |
| **Path-scoped rules** | `.claude/rules/*.md` with `Applies to:` glob | Subdirectory `AGENTS.md` files | Claude Code more granular — rules target file patterns; Codex scopes by directory only |
| **Override mechanism** | No override file | `AGENTS.override.md` at any level | Codex has explicit override support |
| **Custom commands** | `.claude/commands/*.md` (loaded on demand) | Slash commands (simpler) | Claude Code more extensible |
| **Skills** | `.claude/skills/` with progressive disclosure | Not supported | Codex has no equivalent |
| **Hooks** | `.claude/hooks/` (pre/post tool execution) | `notify` array (notifications only) | Claude Code has pre/post hooks; Codex only has post-event notifications |
| **MCP servers** | Settings JSON + MCP config | `config.toml` `[mcp_servers]` + `codex mcp` CLI | Both support MCP; different config format |
| **Profiles** | Not supported | `[profiles.<name>]` in config.toml | Codex can switch named config sets |
| **Instruction size limit** | ~200 lines recommended (no hard limit) | 32 KiB hard limit (`project_doc_max_bytes`) | Codex has an explicit byte ceiling |
| **Context loading** | CLAUDE.md + rules (always) + skills (on demand) + commands (on demand) | AGENTS.md chain (always, all at once) | Claude Code has progressive disclosure; Codex loads everything upfront |
| **Multi-agent** | Built-in (Agent tool, worktrees) | Experimental feature flag | Claude Code more mature |
| **Review command** | No built-in `/review` | `/review` command (diffs, commits, custom instructions) | Codex has dedicated review capability |
| **Exec/automation** | `claude -p "prompt"` (non-interactive) | `codex exec` with JSON output, schemas | Codex more structured for automation |
| **Model switching** | `/model` mid-session | `/model` mid-session | Equivalent |
| **Sandbox** | macOS sandbox (Seatbelt) | macOS/Linux sandbox with configurable levels | Codex more configurable |
| **Cloud tasks** | Not supported | `codex cloud` (submit tasks to cloud) | Codex-only feature |

### 3.2 Configuration Depth Assessment

**Claude Code advantages:**
- Path-scoped rules (`.claude/rules/`) allow targeting specific file types without directory nesting
- Skills provide progressive disclosure — zero token cost until activated
- Hooks enable enforcement (pre-commit checks, branch protection) — not just notifications
- Commands provide on-demand context loading

**Codex advantages:**
- Named profiles for role switching (e.g., `--profile reviewer`)
- `AGENTS.override.md` for temporary instruction overrides without modifying base files
- Built-in `/review` command purpose-built for code review
- `codex exec` with JSON output and schema validation for CI/automation
- Explicit byte limit prevents accidental context bloat

**Shared gaps:**
- Neither tool has a built-in cross-repo config sync mechanism

---

## 4. Best Practices for Review Role

### 4.1 Codex as Reviewer — Current MPI Pattern

Codex serves as the **reviewer and quality gate** in MPI's development process:
- **Plan reviewer** — `/revplan` reviews implementation plans posted on issues
- **PR reviewer** — `/revpr` reviews code changes on pull requests
- Reviews are capped at 3 iterations per loop (#227)

### 4.2 Review-Specific Configuration Recommendations

Based on Codex's built-in `/review` command and configuration capabilities:

**4.2.1 Leverage built-in `/review` command**

Codex's native `/review` command supports [S4]:
- Reviewing diffs against base branches
- Examining uncommitted changes (staged/unstaged/untracked)
- Reviewing specific commits by SHA
- Custom instructions for targeted feedback

This aligns well with Codex's MPI review role. The custom review skills (`/revplan`, `/revpr`) should build on top of the built-in `/review` capabilities rather than reimplementing diff analysis.

**4.2.2 Use profiles for review context**

Codex's profile system enables role-specific configuration [S2]:
```toml
[profiles.reviewer]
model = "gpt-5.4"
model_reasoning_effort = "high"
sandbox_mode = "read-only"      # Filesystem read-only for review safety
approval_policy = "on-request"  # Model decides when to prompt before commands (default behavior)
```

This would allow launching Codex in review mode via `codex --profile reviewer` with appropriate safety defaults — read-only filesystem access via `sandbox_mode` and model-gated approval via `approval_policy`. These are separate concerns: `sandbox_mode` controls filesystem/network access levels (e.g., `read-only`, `workspace-write`, `danger-full-access`), while `approval_policy` controls when Codex prompts before running commands (e.g., `on-request` lets the model decide when to ask, `untrusted` allows trusted commands but prompts for untrusted ones, `never` skips prompts). [inference — profile composition based on S2 config reference]

**4.2.3 Optimize AGENTS.md for review context**

Since Codex loads all AGENTS.md content upfront (no progressive disclosure), the review-relevant sections should be:
- Front-loaded in AGENTS.md (per context rot findings from S1.2 in ai-best-practices.md)
- Focused on standards, patterns, and review checklists — not implementation details
- Within the 32 KiB byte limit across the concatenation chain

Current Optimus AGENTS.md (153 lines) is well within the limit. However, review-specific guidance (P0/P1/P2 priority levels, review checklist) should appear early in the file since Codex's primary role is reviewing. [inference]

**4.2.4 Review context needs**

| Context Type | How Codex Accesses It | Current MPI Status |
|-------------|----------------------|-------------------|
| Project standards | AGENTS.md (auto-loaded) | Covered |
| Architecture patterns | `docs/` (must be read manually) | Not auto-loaded |
| Review checklist | AGENTS.md "Review Guidelines" section | Covered (lines 99-117) |
| PR diffs | Built-in `/review` or GitHub MCP | Available |
| Issue history | GitHub MCP or manual | Available if MCP configured |
| CI/test results | GitHub MCP or `codex exec` | Available if MCP configured |
| Prior review comments | GitHub MCP | Available if MCP configured |

**Key gap:** Architecture docs (`docs/architecture/`, `docs/standards/`) are not auto-loaded into Codex context. Codex must manually read these files during review, consuming context window. Unlike Claude Code, Codex cannot use skills or `@import` to defer loading. Options:
1. Include critical review standards inline in AGENTS.md (increases size but ensures availability)
2. Configure MCP server for docs access (adds baseline token cost)
3. Accept manual file reads as acceptable for review workflows

### 4.3 Sourced Best Practices

**4.3.1 Instruction file structure for reviewers**

The existing research in `ai-best-practices.md` finding F1.1 applies directly: front-load highest-value content in instruction files. For Codex's review role, this means review guidelines and anti-patterns should be the first sections in AGENTS.md, not project description. [S1.2, S1.3 from ai-best-practices.md — cross-reference, not new sources]

**4.3.2 Automation via `codex exec`**

For automated review workflows (e.g., triggered by GitHub Actions), `codex exec` provides structured output [S4]:
```bash
codex exec --json "Review the PR diff for P0/P1 issues" --output-schema review-schema.json
```
This enables deterministic review output that can be parsed and posted as PR comments. [open item — not yet tested in MPI workflows]

---

## 5. Recommendations

### 5.1 Answers to Open Questions

**Q1: What Codex configuration format does OpenAI currently support?**

TOML-format `config.toml` files at system (`/etc/codex/`), user (`~/.codex/`), and project (`.codex/`) levels. Instruction files use Markdown (`AGENTS.md` / `AGENTS.override.md`) with directory-scoped layering. There is no `codex.json` or `.openai/` directory. [S1, S2 — product-behavior claim, primary sources]

**Q2: Is Codex still the intended review tool?**

Yes. Codex has a built-in `/review` command purpose-built for code review, and MPI's `/revplan` and `/revpr` skills are actively used. The GPT-5.4 model's stronger reasoning capabilities make it well-suited for review tasks. Codex continues to receive active development (v0.111.0 as of this scan, with regular changelog updates). [S4, S5, S6 — product-behavior claim, primary sources]

**Q3: Should the central config decision (#232) be resolved first?**

No — #232 does not block this work. However, the findings here should inform #232. Key input: Codex config (`.codex/config.toml`) and Claude Code config (`.claude/`) use different formats and structures, so a shared config repo would need format-specific directories rather than a unified format. AGENTS.md is the only truly shared surface between agents. [inference — MPI-state claim informed by audit evidence]

**Q4: What is the current Codex setup across other MPI repos?**

All 7 app repos have AGENTS.md at the root. No repo has `.codex/config.toml`, `.openai/`, or `codex.json`. The only Codex configuration surface is AGENTS.md. See Section 2 evidence table for per-repo details with commit SHAs. [MPI-state claim, repo audit evidence — branch: main, SHAs in Section 2.2]

**Q5: What's the scope of "review" context?**

Codex needs access to: (a) project standards and anti-patterns (currently in AGENTS.md — auto-loaded), (b) review checklists with priority levels (currently in AGENTS.md — auto-loaded), (c) architecture docs for deeper review context (currently in `docs/` — requires manual file reads). The same `docs/` directory that Claude Code uses is appropriate for Codex, but Codex cannot load it progressively via skills. The practical approach is to keep AGENTS.md focused on review-critical standards and accept manual reads for deeper architecture context. [inference — based on audit of current AGENTS.md content and Codex loading behavior]

### 5.2 Phase 2 Approach Recommendation

**Recommendation: Option B (AGENTS.md Enhancement + Minimal Config)** with a `.codex/config.toml` addition.

**Rationale:**
1. Codex's configuration depth is shallower than Claude Code's — no skills, no path-scoped rules, simpler hooks. Creating a `.codex/` directory that mirrors `.claude/` (Option A) would result in mostly empty directories.
2. AGENTS.md is already doing all the work across all MPI repos. Enhancing it is the lowest-friction path.
3. The one gap worth filling is `.codex/config.toml` for project-level settings (model, approval policy, review profile).
4. Codex's built-in `/review` command and profile system provide review-specific capabilities without requiring extensive custom config.

**Phase 2 scope estimate:**

| Change | Files | Description |
|--------|-------|-------------|
| Add `.codex/config.toml` to Optimus | 1 new file | Model, approval policy, review profile, MCP servers |
| Restructure AGENTS.md | 1 modified file | Front-load review guidelines, add review-specific context |
| Propagate `.codex/config.toml` pattern to other MPI repos | Input for #232 | Via cross-repo sync mechanism |
| Document Codex config in architecture docs | 1 modified file | Update `docs/architecture/overview.md` or add `docs/codex-config.md` |
| **Total** | 3-4 files per repo | Minimal footprint, high impact |

### 5.3 Additional Recommendations

1. **Establish a review profile** — Add `[profiles.reviewer]` to `.codex/config.toml` with read-only sandbox and high reasoning effort. This formalizes Codex's review role in configuration.

2. **Reorder AGENTS.md for review primacy** — Move "Review Guidelines" (currently lines 99-117) to appear before "Architecture" (line 67) and "Asset Pipeline" (line 56). Codex's primary role is reviewing; the instruction file should reflect that.

3. **Configure GitHub MCP for Codex** — Ensure Codex can access PR diffs, issue history, and CI status via MCP. Add `[mcp_servers.github]` to `.codex/config.toml`.

4. **Track Codex versions** — Codex is evolving rapidly (GPT-5.4 launched March 2026, feature flags changing frequently). The 2-week re-scan cadence from #234 should include checking the [Codex changelog](https://developers.openai.com/codex/changelog/) for config-relevant changes.

5. **Evaluate `codex exec` for CI integration** — The structured JSON output from `codex exec` could enable automated review as a GitHub Action step, replacing manual Codex invocation. [open item — requires testing]

---

## Source Registry

### S1: OpenAI — Config Basics
- **URL:** https://developers.openai.com/codex/config-basic/
- **Author/Org:** OpenAI
- **Type:** Primary (vendor docs)
- **Publish/updated date:** 2026 (continuously updated)
- **Access date:** 2026-03-08
- **Credibility:** Platform creator; authoritative on configuration mechanics.
- **Key claims used:** Config file locations, TOML format, hierarchy overview.

### S2: OpenAI — Advanced Configuration
- **URL:** https://developers.openai.com/codex/config-advanced/
- **Author/Org:** OpenAI
- **Type:** Primary (vendor docs)
- **Publish/updated date:** 2026 (continuously updated)
- **Access date:** 2026-03-08
- **Credibility:** Platform creator; authoritative on advanced settings.
- **Key claims used:** Profiles, sandbox policies, MCP server config, shell environment, observability, project root detection.

### S3: OpenAI — Custom Instructions with AGENTS.md
- **URL:** https://developers.openai.com/codex/guides/agents-md
- **Author/Org:** OpenAI
- **Type:** Primary (vendor docs)
- **Publish/updated date:** 2026 (continuously updated)
- **Access date:** 2026-03-08
- **Credibility:** Platform creator; authoritative on instruction file behavior.
- **Key claims used:** File discovery hierarchy, override mechanism, concatenation behavior, size limits, fallback filenames.

### S4: OpenAI — Codex CLI Features
- **URL:** https://developers.openai.com/codex/cli/features/
- **Author/Org:** OpenAI
- **Type:** Primary (vendor docs)
- **Publish/updated date:** 2026 (continuously updated)
- **Access date:** 2026-03-08
- **Credibility:** Platform creator; authoritative on feature capabilities.
- **Key claims used:** `/review` command capabilities, multi-agent (experimental), MCP integration, `codex exec` automation, slash commands.

### S5: OpenAI — Codex Models
- **URL:** https://developers.openai.com/codex/models/
- **Author/Org:** OpenAI
- **Type:** Primary (vendor docs)
- **Publish/updated date:** 2026 (continuously updated)
- **Access date:** 2026-03-08
- **Credibility:** Platform creator; authoritative on model capabilities and recommendations.
- **Key claims used:** GPT-5.4 as flagship, GPT-5.3-Codex for coding, model selection guidance.

### S6: OpenAI — Codex Changelog
- **URL:** https://developers.openai.com/codex/changelog/
- **Author/Org:** OpenAI
- **Type:** Primary (vendor docs)
- **Publish/updated date:** 2026 (continuously updated)
- **Access date:** 2026-03-08
- **Credibility:** Platform creator; authoritative on version history.
- **Key claims used:** GPT-5.4 launch, plugin system (v0.110.0), memory improvements, Windows support.

### S7: OpenAI — Configuration Reference
- **URL:** https://developers.openai.com/codex/config-reference
- **Author/Org:** OpenAI
- **Type:** Primary (vendor docs)
- **Publish/updated date:** 2026 (continuously updated)
- **Access date:** 2026-03-08
- **Credibility:** Platform creator; definitive reference for all config keys.
- **Key claims used:** Complete settings list, feature flags, MCP config structure, approval policies.

### S8: OpenAI — Codex CLI Reference
- **URL:** https://developers.openai.com/codex/cli/reference/
- **Author/Org:** OpenAI
- **Type:** Primary (vendor docs)
- **Publish/updated date:** 2026 (continuously updated)
- **Access date:** 2026-03-08
- **Credibility:** Platform creator; definitive reference for CLI commands.
- **Key claims used:** All CLI flags, subcommands, exec options, safety flags.
