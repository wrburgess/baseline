# AI Agent Best Practices — Vetted Source Registry

Parent epic: [#225 — Optimizing AI Contributions](https://github.com/mpimedia/optimus/issues/225)
Issue: [#234 — Research independent, validated best practices](https://github.com/mpimedia/optimus/issues/234)
Last scan: 2026-03-07
Next scan due: 2026-03-21

See [README.md](README.md) for quality gate rubric, confidence tiers, and re-scan schedule.

---

## Table of Contents

1. [Area 1: Agent Configuration & Context Management](#area-1-agent-configuration--context-management)
2. [Area 3: AI-Assisted Software Development Process](#area-3-ai-assisted-software-development-process)
3. [Area 5: Domain Knowledge & Institutional Memory](#area-5-domain-knowledge--institutional-memory)
4. [Area 2: Multi-Agent Workflows](#area-2-multi-agent-workflows)
5. [Area 4: Cross-Repository & Team-Scale AI Usage](#area-4-cross-repository--team-scale-ai-usage)
6. [Anti-Patterns](#anti-patterns)
7. [Traceability Matrix](#traceability-matrix)

---

## Area 1: Agent Configuration & Context Management

**Priority:** HIGH
**Epic issues informed:** #228, #229, #238, #239, #240
**Topics:** Instruction file structure, context window management, memory/persistence patterns, token efficiency, Cowork scheduling integration
**Related research:** [codex-configuration.md](codex-configuration.md) — Codex-specific configuration audit and comparison (issue #229)

### Sources

#### S1.1: Anthropic — Best Practices for Claude Code & CLAUDE.md
- **URL:** https://code.claude.com/docs/en/best-practices
- **Author/Org:** Anthropic
- **Type:** Vendor docs
- **Date:** Updated through early 2026
- **Credibility:** Platform creator, authoritative on mechanics. No independent benchmarks, but based on internal team usage.
- **Key Claims:** CLAUDE.md should target under 200 lines. File hierarchy loads recursively (home > project root > subdirectories). `@path/to/file` import syntax allows referencing docs without embedding. Skills (`.claude/skills/`) load on demand, consuming no tokens until activated. `/init` generates a starter CLAUDE.md.
- **Evidence:** Based on Anthropic internal teams' usage (PDF: "How Anthropic Teams Use Claude Code").
- **Relevance to MPI:** Optimus CLAUDE.md is ~237 lines — above recommended 200-line ceiling. Could benefit from offloading detailed docs to skills or `@import` references.
- **Limitations:** Vendor source; no independent validation of the 200-line threshold.

#### S1.2: Chroma Research — Context Rot: How Increasing Input Tokens Impacts LLM Performance
- **URL:** https://research.trychroma.com/context-rot
- **Author/Org:** Chroma (Hong et al.)
- **Type:** Engineering research / benchmark
- **Date:** 2025
- **Credibility:** Tested 18 models with controlled experiments, reproducible toolkit on GitHub. Quantitative accuracy measurements.
- **Key Claims:** LLM performance degrades as context length increases, even on simple retrieval. Performance drops 30%+ when relevant information sits in the middle (U-shaped attention curve). Models have an "attention budget" that depletes with each additional token. GPT-4 accuracy dropped from 98.1% to 64.1% based on information placement.
- **Evidence:** Quantitative benchmarks across 18 models including Claude, GPT-4, Gemini 2.5, Qwen3.
- **Relevance to MPI:** Validates keeping CLAUDE.md concise. Critical instructions should appear at top or bottom, not buried in middle. Cross-repo context should not be loaded unless needed.
- **Limitations:** Synthetic needle-in-haystack tasks, not real coding workflows.

#### S1.3: Potapov.dev — The Definitive Guide to CLAUDE.md
- **URL:** https://potapov.dev/blog/claude-md-guide/
- **Author/Org:** Potapov (independent developer)
- **Type:** Engineering blog
- **Date:** 2025/2026
- **Credibility:** Practical experience with detailed examples. Experience-based, not controlled experiments.
- **Key Claims:** Priority order matters more than length — "what Claude keeps getting wrong" should be first. Past ~500 lines, Claude skims rather than reads. Short, specific rules survive compaction better than paragraphs. After compaction, CLAUDE.md content arrives wrapped in "may or may not be relevant" — weakening all instructions. Enforcement rules should live in hooks or settings deny rules, not CLAUDE.md.
- **Evidence:** Behavioral observations with specific compaction failure examples.
- **Relevance to MPI:** The "Anti-Patterns (Never Do)" section is critical enforcement content that should migrate to hooks/deny rules. The existing `enforce-branch-creation.sh` hook already demonstrates this pattern.
- **Limitations:** Single author, no controlled study.

#### S1.4: Anthropic — Extend Claude with Skills & Skill Authoring Best Practices
- **URL:** https://code.claude.com/docs/en/skills and https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- **Author/Org:** Anthropic
- **Type:** Vendor docs
- **Date:** 2025-2026
- **Credibility:** Platform specification with clear loading behavior.
- **Key Claims:** Skills use progressive disclosure: only metadata loaded at startup; SKILL.md loaded on relevance match; references loaded on demand. Scripts execute via bash without loading contents into context. Individual reference files should stay under 200 lines. Directory structure: `SKILL.md` + `references/` + `scripts/` + `templates/`.
- **Evidence:** Architectural specification with concrete file structure examples.
- **Relevance to MPI:** MPI currently has zero skills defined. Existing `.claude/commands/` files are candidates for migration to skills format. Domain-specific knowledge (notifications, permissions, enumerables) should become skills.
- **Limitations:** No independent measurement of token savings from skills vs. inline CLAUDE.md.

#### S1.5: Factory.ai — The Context Window Problem: Scaling Agents Beyond Token Limits
- **URL:** https://factory.ai/news/context-window-problem
- **Author/Org:** Factory.ai
- **Type:** Engineering blog / vendor
- **Date:** 2025
- **Credibility:** AI coding agent company with production deployments. References Chroma research.
- **Key Claims:** Typical enterprise monorepo spans thousands of files and millions of tokens. "Write" strategy (saving context outside the window) is the most powerful context engineering technique. Rolling summary of prior turns, persisting anchored summaries, is key for multi-step work.
- **Evidence:** Cost analysis, references to Chroma's context rot research.
- **Relevance to MPI:** With 7+ repos, the "write" strategy (externalize context to files) is directly applicable. Existing MEMORY.md approach partially implements this. Structured handoff documents between sessions should be standardized.
- **Limitations:** Vendor perspective; promotes own product.

#### S1.6: Google Developers Blog — Architecting Efficient Context-Aware Multi-Agent Framework
- **URL:** https://developers.googleblog.com/architecting-efficient-context-aware-multi-agent-framework-for-production/
- **Author/Org:** Hangfei Lin, Google
- **Type:** Engineering blog (major tech company)
- **Date:** December 2025, updated February 2026
- **Credibility:** Google engineer, production ADK framework. Architectural patterns with clear specifications.
- **Key Claims:** Context should be treated as a "compiled view" over tiered, stateful storage (Session, Memory, Artifacts). "Context engineering" is a first-class discipline. Strict scoped context handoffs are essential in multi-agent workflows.
- **Evidence:** Architectural design patterns from Google's ADK framework.
- **Relevance to MPI:** Tiered storage model maps to Claude Code: session = conversation, memory = CLAUDE.md + auto-memory, artifacts = skills + references. MPI should formalize these tiers.
- **Limitations:** Google-specific (ADK), not Claude Code-specific.

#### S1.7: Richard Porter — Claude Code Token Management: 8 Strategies to Save 50-70%
- **URL:** https://dev.to/richardporter/claude-code-token-management-8-strategies-to-save-50-70-on-pro-plan-3hob
- **Author/Org:** Richard Joseph Porter (independent developer)
- **Type:** Engineering blog
- **Date:** 2026
- **Credibility:** Practical Claude Code user with specific token measurements.
- **Key Claims:** `/clear` between tasks and a good CLAUDE.md can cut consumption by 50-70%. MCP servers consume context even when idle (Linear alone: ~14K tokens). Keep sessions under 30K tokens for complex work. Use plan mode (Shift+Tab) before implementation. `/compact` proactively at 70% capacity, not at auto-compact's 95%.
- **Evidence:** Specific token counts, practical measurements.
- **Relevance to MPI:** 3 MCP servers enabled (context7, github, heroku). Each consumes baseline tokens. Heroku server may not be needed every session. Model routing guidance applicable to agent strategy.
- **Limitations:** Single developer's experience; savings may vary.

#### S1.8: Anthropic — Run Prompts on a Schedule & Cowork Scheduled Tasks
- **URL:** https://code.claude.com/docs/en/scheduled-tasks and https://support.claude.com/en/articles/13854387-schedule-recurring-tasks-in-cowork
- **Author/Org:** Anthropic
- **Type:** Vendor docs
- **Date:** 2026
- **Credibility:** Platform feature documentation.
- **Key Claims:** Two scheduling systems: Desktop (persistent, GUI) and CLI (`/loop`, session-scoped). Desktop scheduled tasks fire fresh sessions with full access. For headless persistent scheduling: system cron jobs calling `claude -p "prompt"`. Desktop tasks only run while machine is awake and Claude Desktop is open.
- **Evidence:** Feature specification with usage examples.
- **Relevance to MPI:** For 2-week re-scan cadence, GitHub Actions scheduled workflow (`claude -p`) is most reliable for team-wide automation. Desktop Cowork is good for individual developer cadences.
- **Limitations:** Desktop scheduling requires machine to be awake/open.

### Findings

#### F1.1: Restructure CLAUDE.md with Priority-Based Ordering
- **Confidence:** High
- **Sources:** S1.1 (Anthropic), S1.2 (Chroma), S1.3 (Potapov)
- **Recommendation:** Reorder CLAUDE.md to front-load highest-value content. Current structure leads with project description; it should lead with error-prevention rules. Suggested order: (1) Critical rules / anti-patterns, (2) Required workflow commands, (3) Agent attribution, (4) Tech stack and commands, (5) Architecture pointers (as `@import` references).
- **Evidence:** Context rot shows 30%+ performance drop for mid-context information (Chroma). Potapov confirms priority order > length. Anthropic recommends under 200 lines.
- **MPI Application:** Trim CLAUDE.md from ~237 to under 200 lines by moving detailed asset pipeline, permissions, and testing docs to `@docs/` imports or skills. Keep "Anti-Patterns" and "Required Workflow" at top.
- **Epic Issues:** #228, #229

#### F1.2: Migrate Anti-Pattern Enforcement from CLAUDE.md to Hooks/Settings
- **Confidence:** Medium
- **Sources:** S1.3 (Potapov), S1.1 (Anthropic hooks docs)
- **Recommendation:** The 15 "Never Do" anti-patterns are enforcement rules that get weakened by compaction. Move enforceable rules to hooks (PreToolUse) and settings deny rules. Keep only contextual "why" explanations in CLAUDE.md.
- **Evidence:** After compaction, CLAUDE.md instructions arrive with "may or may not be relevant" disclaimer. Hooks execute at system level and cannot be compacted. Existing `enforce-branch-creation.sh` proves this pattern works.
- **MPI Application:** Create hooks for: blocking fixture file creation, blocking inline JS in templates, blocking controller spec creation, enforcing `archive!` over `destroy` on archivable models. Add settings deny rules for file patterns.
- **Epic Issues:** #228, #238

#### F1.3: Implement Skills for Domain Knowledge
- **Confidence:** Medium
- **Sources:** S1.4 (Anthropic skills docs), S1.1 (Anthropic best practices), S1.3 (Potapov)
- **Recommendation:** Create `.claude/skills/` directory with skills for domain-specific knowledge. Use progressive disclosure: SKILL.md frontmatter loads at startup (cheap), full content loads on demand.
- **Evidence:** Anthropic skills architecture explicitly supports this: domain knowledge that is only relevant sometimes should be skills, not inline CLAUDE.md. Reference files under skills don't consume tokens until read.
- **MPI Application:** Candidate skills: `permissions-system/`, `notification-system/`, `enumerable-pattern/`, `asset-pipeline/`, `form-patterns/`, `multi-repo-ops/`.
- **Epic Issues:** #229, #228

#### F1.4: Adopt Context Tiering Strategy
- **Confidence:** Medium
- **Sources:** S1.6 (Google ADK), S1.5 (Factory.ai), S1.2 (Chroma)
- **Recommendation:** Formalize three-tier context architecture: (1) Always-loaded — CLAUDE.md core (under 200 lines), (2) On-demand — Skills, `@import` references, (3) External — docs/, project board state, handoff documents.
- **Evidence:** Google ADK demonstrates "compiled view" over tiered storage improves reliability. Factory.ai confirms "write" strategy is most powerful context engineering technique.
- **MPI Application:** Current CLAUDE.md mixes all three tiers. Separate them: core rules in CLAUDE.md, domain knowledge in skills, detailed docs as `@import` references.
- **Epic Issues:** #228, #229, #239

#### F1.5: Optimize Token Consumption Practices
- **Confidence:** High
- **Sources:** S1.7 (Porter), S1.2 (Chroma), S1.1 (Anthropic)
- **Recommendation:** Establish team-wide token management practices: `/clear` between unrelated tasks, `/compact` proactively at 70% capacity, audit MCP server enablement, model routing (Sonnet for routine, Opus for architecture), keep sessions under 30K tokens for complex work.
- **Evidence:** Porter reports 50-70% savings from `/clear` + good CLAUDE.md. Each MCP server consumes 10-15K baseline tokens idle. Performance degrades with longer contexts regardless of model.
- **MPI Application:** Consider making heroku MCP server opt-in per session. Document `/compact` cadence in workflow docs. Add model routing guidance to agent workflow documentation.
- **Epic Issues:** #238, #240

#### F1.6: Use PreCompact Hooks for State Preservation
- **Confidence:** Medium
- **Sources:** S1.3 (Potapov), S1.1 (Anthropic hooks docs)
- **Recommendation:** Implement a PreCompact hook that snapshots working state to a file before compaction, ensuring critical context survives the compaction boundary.
- **Evidence:** After compaction, CLAUDE.md content is downgraded. Dynamic state injection "hits harder than a static rule in CLAUDE.md that the compaction summary has already downgraded."
- **MPI Application:** Add PreCompact hook to `.claude/hooks/` that writes current task state. Important for long-running implementation sessions.
- **Epic Issues:** #238, #228

#### F1.7: Re-scan Cadence via GitHub Actions (Preferred)
- **Confidence:** Low
- **Sources:** S1.8 (Anthropic scheduling docs)
- **Recommendation:** For 2-week automated re-scan: use GitHub Actions scheduled workflow with `claude -p`. Desktop Cowork scheduled tasks as supplement for individual workflows.
- **Evidence:** Desktop tasks require machine awake/open (fragile for team cadence). GitHub Actions is machine-independent and CI-native. `claude -p` supports headless execution.
- **MPI Application:** Create `.github/workflows/research-rescan.yml` with `on: schedule: - cron: '0 9 1,15 * *'`. Workflow runs `claude -p` with rescan prompt. Results posted as PR.
- **Epic Issues:** #238

---

## Area 3: AI-Assisted Software Development Process

**Priority:** HIGH
**Epic issues informed:** #227, #230, #231
**Topics:** Issue-to-merge workflows, human-in-the-loop optimization, AI QA patterns, measuring AI contribution quality

### Sources

#### S3.1: METR — Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity
- **URL:** https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
- **Author/Org:** METR (Model Evaluation & Threat Research)
- **Type:** Academic paper (peer-reviewed RCT, arXiv: 2507.09089)
- **Date:** July 2025
- **Credibility:** Randomized controlled trial, 16 experienced developers, 246 tasks, pre-registered hypotheses. Quantitative results with confidence intervals.
- **Key Claims:** AI tools made experienced developers 19% SLOWER on their own mature codebases (95% CI: -0.33 to -0.05). Developers perceived a 20% speedup — significant perception-reality disconnect. Less than 44% of AI-generated code was accepted. AI tools most beneficial for unfamiliar codebases and less experienced developers.
- **Evidence:** Pre-registered RCT with 246 real tasks, controlled for difficulty, statistical analysis.
- **Relevance to MPI:** Optimus is a mature Rails codebase. This warns that AI productivity gains may not apply — or may be negative — for experienced developers on mature codebases. Workflow design must account for this.
- **Limitations:** Small sample (16 developers), early-2025 tools (improved since), open-source focus.

#### S3.2: Atlassian — HULA: Human-In-the-Loop Software Development Agents
- **URL:** https://www.atlassian.com/blog/atlassian-engineering/hula-blog-autodev-paper-human-in-the-loop-software-development-agents
- **Author/Org:** Atlassian Engineering (accepted at ICSE 2025 SEIP)
- **Type:** Academic paper + engineering blog (peer-reviewed, production deployed)
- **Date:** November 2024, deployed 2025
- **Credibility:** ICSE-accepted paper. Real deployment metrics: 79% plan generation, 82% approval, 25% PR completion, ~900 merged PRs.
- **Key Claims:** Three-agent architecture (AI Planner, AI Coder, Human Agent). 79% of work items got valid plans; 82% approved. 87% of approved plans produced code; only 25% reached PR stage. ~900 PRs merged in production. Humans add most value at plan review and code review stages.
- **Evidence:** SWE-bench results (31% pass), real deployment metrics.
- **Relevance to MPI:** Three-agent pattern maps to MPI's workflow. Only 25% of code reaches PR but 82% of plans are approved — investing in planning yields higher returns than improving generation.
- **Limitations:** Atlassian-specific (Java-heavy), proprietary infrastructure.

#### S3.3: GitClear — AI Copilot Code Quality: 2025 Data
- **URL:** https://www.gitclear.com/ai_assistant_code_quality_2025_research
- **Author/Org:** GitClear (independent code analytics)
- **Type:** Industry research report / benchmark
- **Date:** February 2025
- **Credibility:** 211 million lines of code analyzed across 5 years (2020-2024). Large-scale quantitative analysis.
- **Key Claims:** Code duplication rose from 8.3% to 12.3% of changed lines (2021-2024). Code churn (new code revised within 2 weeks) increased from 5.5% to 7.9%. Refactoring dropped from 25% to under 10% of changed lines. "Moved" code fell below 10% — a 44% drop.
- **Evidence:** 211M lines analyzed, 5-year trend data, multiple corroborating metrics.
- **Relevance to MPI:** Direct warning: AI agents generating code could increase technical debt through duplication and reduced refactoring. Workflow should include explicit refactoring steps and code health checks as mandatory gates.
- **Limitations:** Correlation not causation, no per-language breakdown.

#### S3.4: DX — How 18 Companies Measure AI's Impact in Engineering
- **URL:** https://getdx.com/blog/how-top-companies-measure-ai-impact-in-engineering/
- **Author/Org:** DX (Laura Tacho, CTO) with data from GitHub, Google, Dropbox, Microsoft, T-Mobile
- **Type:** Industry survey / research report
- **Date:** 2025
- **Credibility:** 135,000+ developers across 435 companies. Named company case studies.
- **Key Claims:** AI tools save avg 3.6 hours/week; daily users see 60% higher PR throughput. Positive: Ease +10.4%, Change Confidence +10.6%, Quality +6.7%. Negative: Knowledge Gaps -16.1%, Time Loss -18.2%. Companies that measure well track speed AND quality side-by-side. Only 20% of teams actually measure AI impact with engineering metrics.
- **Evidence:** 135K+ developers surveyed, 435 companies.
- **Relevance to MPI:** Need measurement framework before scaling AI usage. Knowledge gaps and time loss are real negative impacts to track alongside productivity gains.
- **Limitations:** Self-reported, selection bias, DX sells measurement tools.

#### S3.5: Addy Osmani — My LLM Coding Workflow Going Into 2026
- **URL:** https://addyosmani.com/blog/ai-coding-workflow/
- **Author/Org:** Addy Osmani (Engineering Leader, Google Chrome)
- **Type:** Engineering blog (practitioner)
- **Date:** December 2025
- **Credibility:** Well-known Google engineering leader. Specific workflow patterns with examples.
- **Key Claims:** Planning-first approach is the cornerstone. Small iterative chunks dramatically reduce error rates. Context management is the primary quality lever. "AI agents can propose code, never own it." Second AI session with different model for critique is effective quality gate.
- **Evidence:** Personal production experience at Google, team adoption results.
- **Relevance to MPI:** Workflow maps well to CLAUDE.md + multi-agent pattern. Emphasis on specs/plans, small chunks, and automated quality gates aligns with RuboCop/RSpec/Brakeman pipeline.
- **Limitations:** Single practitioner, Google-specific tooling.

#### S3.6: CodeScene — Agentic AI Coding: Best Practice Patterns for Speed with Quality
- **URL:** https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality
- **Author/Org:** CodeScene (Adam Tornhill)
- **Type:** Engineering blog + product research
- **Date:** 2025
- **Credibility:** Adam Tornhill is a recognized authority on code health. Code Health metric validated via peer-reviewed research.
- **Key Claims:** AI assistants increase defect risk by 30%+ in unhealthy codebases. Healthy codebases benefit from AI acceleration without same quality degradation. Agents need measurable quality targets — without them, they optimize for speed at quality's expense.
- **Evidence:** Peer-reviewed Code Health metric, production codebase analysis, defect correlation data.
- **Relevance to MPI:** Codebase health is a precondition for AI effectiveness. MPI's existing quality gates (RuboCop, Brakeman, testing) create the right foundation.
- **Limitations:** Vendor perspective (CodeScene sells Code Health product).

#### S3.7: Kief Morris / Martin Fowler — Humans and Agents in Software Engineering Loops
- **URL:** https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html
- **Author/Org:** Kief Morris (Thoughtworks), Martin Fowler's site
- **Type:** Engineering blog (industry thought leadership)
- **Date:** 2025
- **Credibility:** Thoughtworks is a respected consultancy; Fowler's site has high editorial standards. Conceptual framework from consulting engagements.
- **Key Claims:** Three postures: "in the loop" (micromanaging), "out of the loop" (fully autonomous), "on the loop" (managing the working loop). "On the loop" is optimal — humans design, constrain, and oversee rather than execute.
- **Evidence:** Conceptual framework with practical consulting examples.
- **Relevance to MPI:** "On the loop" directly describes MPI's target state. CLAUDE.md is the loop definition. Quality gates are loop constraints. Human role shifts to designing better loops.
- **Limitations:** Conceptual, not empirical.

#### S3.8: Microsoft Engineering — Enhancing Code Quality at Scale with AI-Powered Code Reviews
- **URL:** https://devblogs.microsoft.com/engineering-at-microsoft/enhancing-code-quality-at-scale-with-ai-powered-code-reviews/
- **Author/Org:** Microsoft Engineering
- **Type:** Vendor engineering blog
- **Date:** 2025
- **Credibility:** Production metrics: 90%+ PR coverage, 600K+ PRs/month.
- **Key Claims:** AI-powered code review scaled to 90%+ of PRs across Microsoft. Internal testing informed GitHub Copilot for PR Reviews. Human-in-the-loop review flows essential — AI augments, does not replace reviewers.
- **Evidence:** Production scale metrics.
- **Relevance to MPI:** Validates AI-assisted code review at scale. MPI could adopt Copilot PR reviews as additional layer alongside human review.
- **Limitations:** First-party vendor (Microsoft owns GitHub).

### Findings

#### F3.1: Experienced Developers on Mature Codebases May Not Benefit from AI Code Generation
- **Confidence:** High
- **Sources:** S3.1 (METR RCT), S3.4 (DX knowledge gaps/time loss)
- **Recommendation:** Do not assume AI agents will speed up experienced developers on Optimus. Scope agent tasks to areas where AI demonstrably helps (boilerplate, test generation, unfamiliar code areas) rather than deep modifications to well-understood business logic.
- **Evidence:** METR RCT showed 19% slowdown for experienced devs on their own repos. DX found -18.2% time loss and -16.1% knowledge gaps. Developers consistently overestimate AI benefit (perceived +20% vs actual -19%).
- **MPI Application:** Agent tasks should target new feature scaffolding, test generation, cross-repo patterns — not deep business logic changes in well-known code. Track actual time-to-completion to validate.
- **Epic Issues:** #227, #230

#### F3.2: Planning Quality is the Primary Lever for AI Agent Effectiveness
- **Confidence:** High
- **Sources:** S3.2 (Atlassian HULA), S3.5 (Osmani), S3.6 (CodeScene)
- **Recommendation:** Invest heavily in specifications and planning before agents write code. Plan quality determines output quality more than any other factor.
- **Evidence:** Atlassian shows 82% plan approval but only 25% code reaches PR — plan-to-code conversion is the bottleneck. Osmani identifies planning-first as "cornerstone." CodeScene: agents need explicit, measurable quality targets.
- **MPI Application:** Require structured spec (issue description + acceptance criteria + file paths + constraints) before code generation. The existing `/review-issue` → `/cplan` flow already supports this. Consider a mandatory "plan review" gate.
- **Epic Issues:** #227, #230, #231

#### F3.3: Automated Quality Gates are Non-Negotiable for AI-Generated Code
- **Confidence:** High
- **Sources:** S3.3 (GitClear), S3.6 (CodeScene), S3.5 (Osmani), S3.8 (Microsoft)
- **Recommendation:** AI code must pass same or stricter quality gates as human code. Gates should run WITHIN the agent's feedback loop, not just at PR time.
- **Evidence:** GitClear: 4x growth in code clones, 44% higher churn, refactoring collapsed. CodeScene: 30%+ defect risk increase in unhealthy codebases. Microsoft: 600K+ PRs/month with AI review.
- **MPI Application:** MPI's gate pipeline (RuboCop, RSpec, Brakeman, bundler-audit) is well-positioned. Agent workflow should: generate code → run RuboCop -a → run RSpec → run Brakeman → fix → repeat. Consider adding code duplication check (e.g., `flay`) given GitClear findings.
- **Epic Issues:** #231, #227

#### F3.4: The Optimal Human Role is "On the Loop"
- **Confidence:** Medium
- **Sources:** S3.7 (Morris/Fowler), S3.2 (Atlassian), S3.5 (Osmani)
- **Recommendation:** Shift human effort from writing code to designing better constraints, specifications, and quality loops. Focus on: defining task scope, reviewing plans, setting quality thresholds, reviewing final output.
- **Evidence:** Morris's "on the loop" framework. Atlassian: humans add most value at plan review (82%) and code review. Osmani: "AI agents can propose code, never own it."
- **MPI Application:** CLAUDE.md is already a "loop definition." Human role should be: (1) write issue with spec, (2) review plan, (3) review final PR. Humans should NOT review every line change in real-time.
- **Epic Issues:** #230, #227

#### F3.5: Measure Speed AND Quality Side-by-Side
- **Confidence:** High
- **Sources:** S3.4 (DX), S3.3 (GitClear), S3.1 (METR)
- **Recommendation:** Establish paired metrics: PR throughput + change failure rate, code generation speed + code churn, task completion + test coverage delta.
- **Evidence:** DX: successful companies measure speed and quality side-by-side. GitClear: optimizing for speed alone causes 4x code clones, 44% higher churn. METR: perceived speedup masks actual slowdown. Only 20% of teams measure with engineering metrics.
- **MPI Application:** Track paired metrics for AI agent work: PR throughput + post-deploy bugs, task completion time + SimpleCov delta, lines added + churn rate, agent task count + human review time. Compare AI-assisted PRs (tagged) vs human-only.
- **Epic Issues:** #231, #227

#### F3.6: Small Iterative Chunks Dramatically Outperform Monolithic Generation
- **Confidence:** High
- **Sources:** S3.5 (Osmani), S3.2 (Atlassian), S3.6 (CodeScene)
- **Recommendation:** Constrain agents to small, focused tasks. The existing "<15 files for single agent" guidance is well-calibrated.
- **Evidence:** Osmani: small loops reduce catastrophic errors. Atlassian breaks work into plan → code → review with checkpoints. CodeScene: LLMs excel at contained tasks.
- **MPI Application:** Existing single-agent guideline aligns. For `/orch`, decompose large features into sub-tasks each under 15 files with own spec, PR, and quality gate pass.
- **Epic Issues:** #230, #227

#### F3.7: Use a Second AI Model as a Code Critique Layer
- **Confidence:** Medium
- **Sources:** S3.5 (Osmani), S3.8 (Microsoft)
- **Recommendation:** Add a "reviewer agent" step where a second AI session critiques code before human review.
- **Evidence:** Osmani recommends a second AI session with different model to critique. Microsoft covers 90%+ of 600K PRs/month with AI review.
- **MPI Application:** After agent generates PR, run GitHub Copilot review (or second Claude session) checking for MPI anti-patterns. Frees human reviewers to focus on architecture and business logic. Could be a GitHub Action on AI-tagged PRs.
- **Epic Issues:** #231, #230

#### F3.8: Codebase Health is a Precondition for AI Agent Effectiveness
- **Confidence:** Medium
- **Sources:** S3.6 (CodeScene), S3.3 (GitClear), S3.1 (METR)
- **Recommendation:** Maintain high codebase health before scaling AI agent usage. AI amplifies existing quality — good codebases improve, unhealthy codebases degrade.
- **Evidence:** CodeScene: 30%+ defect risk increase in unhealthy codebases. GitClear: declining refactoring, increasing duplication. METR: AI struggled most in large, complex codebases.
- **MPI Application:** MPI's quality infrastructure maintains health. Before expanding agent scope, ensure current metrics are green. Consider code health tracking (complexity, duplication) in CI.
- **Epic Issues:** #231, #227

---

## Area 5: Domain Knowledge & Institutional Memory

**Priority:** HIGH
**Epic issues informed:** #233, #238
**Topics:** Teaching AI business domain knowledge, persistent memory strategies, knowledge base architecture for AI consumption

### Sources

#### S5.1: Codified Context: Infrastructure for AI Agents in a Complex Codebase
- **URL:** https://arxiv.org/html/2602.20478v1
- **Author/Org:** Aristidis Vasilopoulos (independent researcher)
- **Type:** Academic paper (arXiv preprint)
- **Date:** February 2026
- **Credibility:** Documents 108,000-line C# system built with AI agents across 283 sessions, 2,801 prompts, 1,197 agent invocations, 16,522 autonomous agent turns.
- **Key Claims:** Single-file manifests do not scale beyond modest codebases. Three-tier memory needed: (1) hot-memory constitution (always loaded), (2) specialized domain-expert agents (per task), (3) cold-memory knowledge base (on demand). Specialized agents embed substantial project-specific domain knowledge — often over half of agent content. AGENTS.md associated with 29% runtime reduction and 17% output token reduction.
- **Evidence:** Quantitative data across 283 sessions, four case studies.
- **Relevance to MPI:** Three-tier model maps to: CLAUDE.md as hot memory, .claude/rules/ as specialized agents, docs/ as cold-memory. Validates need for modular rules.
- **Limitations:** Single-developer study, C# not Ruby/Rails, observational.

#### S5.2: Anthropic — Effective Context Engineering for AI Agents
- **URL:** https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- **Author/Org:** Anthropic
- **Type:** Vendor engineering blog
- **Date:** December 2025
- **Credibility:** First-party guidance from Claude Code builders. Framework-level, limited benchmarks.
- **Key Claims:** Context engineering is the progression of prompt engineering. Four strategies: Write (persist outside window), Select (pull relevant in), Compress (summarize), Isolate (multi-agent separation). "Intelligence is not the bottleneck, context is." Many agents with isolated contexts outperform single-agent for complex tasks.
- **Evidence:** Architectural reasoning from building Claude Code.
- **Relevance to MPI:** Write/Select/Compress/Isolate maps to: Write = MEMORY.md + docs/, Select = @-imports + .claude/rules/, Compress = /compact, Isolate = parallel worktree agents.
- **Limitations:** Vendor source, framework-level, no independent validation.

#### S5.3: MemoryBench: A Benchmark for Memory and Continual Learning in LLM Systems
- **URL:** https://arxiv.org/abs/2510.17281
- **Author/Org:** Academic researchers (multi-institution)
- **Type:** Academic paper (arXiv)
- **Date:** October 2025, revised December 2025
- **Credibility:** Formal benchmark with systematic comparison of Mem0, A-Mem, MemoryOS against RAG baselines.
- **Key Claims:** None of the advanced memory systems (A-Mem, Mem0, MemoryOS) consistently outperform RAG baselines. Indiscriminate memory storage propagates errors and degrades long-term performance. Utility-based and retrieval-history-based deletion strategies yield up to 10% performance gains over naive memory.
- **Evidence:** Systematic benchmark across four question categories, multiple system implementations.
- **Relevance to MPI:** Critical cautionary finding. A well-organized docs/ folder may outperform complex memory tooling. Focus on document quality and organization over memory infrastructure.
- **Limitations:** Evaluates conversational memory, not specifically code-agent memory.

#### S5.4: 6 Agentic Knowledge Base Patterns Emerging in the Wild
- **URL:** https://thenewstack.io/agentic-knowledge-base-patterns/
- **Author/Org:** Bill Doerrfeld / The New Stack
- **Type:** Engineering blog / industry analysis
- **Date:** February 2026
- **Credibility:** Established independent tech publication. References LinkedIn's 70% triage reduction (LinkedIn's own claim).
- **Key Claims:** Six patterns: coding assistant playbooks, integration knowledge centers, multi-agent home bases, shared business context layers, semantic layers, MCP-powered capability layers. LinkedIn's CAPT framework achieved 70% reduction in triage time for 1,000+ engineers. KB content should mirror a senior employee's mental toolkit, structured for machine consumption.
- **Evidence:** Case studies from LinkedIn, Amazon, Epicor, others.
- **Relevance to MPI:** "Coding assistant playbook" maps to CLAUDE.md + .claude/rules/. "Shared business context layer" relevant for MPI's multi-app ecosystem.
- **Limitations:** LinkedIn metrics self-reported. Descriptive, not prescriptive.

#### S5.5: Claude Code Memory Documentation + SFEIR Optimization Guide
- **URL:** https://code.claude.com/docs/en/memory and https://institute.sfeir.com/en/claude-code/claude-code-memory-system-claude-md/optimization/
- **Author/Org:** Anthropic + SFEIR Institute
- **Type:** Vendor docs + independent guide
- **Date:** 2026
- **Credibility:** Platform docs plus independent European tech training institute.
- **Key Claims:** Memory hierarchy: Enterprise Policy > Project Memory > Project Rules > User Memory. Target under 200 lines per CLAUDE.md; effective files are 30-100 lines. Total memory should not exceed 10,000 tokens (4.8% of 200K window). Teams of 5+ use 4-8 modular rule files. Path-scoped rules in .claude/rules/ only load when matching files are active.
- **Evidence:** Practical guidelines, token budget calculations.
- **Relevance to MPI:** Directly actionable. CLAUDE.md may be too large. Path-scoped rules align with admin vs. public pipeline architecture.
- **Limitations:** "40% more likely" claim lacks sourcing.

#### S5.6: Retrieval-Augmented Code Generation Survey (Repository-Level)
- **URL:** https://arxiv.org/abs/2510.04905
- **Author/Org:** Academic researchers
- **Type:** Academic survey paper
- **Date:** October 2025, revised January 2026
- **Credibility:** Systematic literature review with taxonomy.
- **Key Claims:** Repository-level code generation requires long-range dependencies, global semantic consistency, cross-file coherence. Three retrieval modalities: dense (vector), graph-based (AST), hybrid. Claude Code uses "index-free RAG" (keyword search + file reading) — works well for organized codebases.
- **Evidence:** Systematic review of retrieval strategies.
- **Relevance to MPI:** Well-organized code enables simpler retrieval. Claude Code's approach means MPI benefits most from code organization and clear naming over custom retrieval infrastructure.
- **Limitations:** Academic focus, doesn't address Rails specifically.

### Findings

#### F5.1: Adopt Three-Tier Memory Architecture
- **Confidence:** Medium
- **Sources:** S5.1 (Codified Context), S5.2 (Anthropic context engineering), S5.5 (Claude Code docs)
- **Recommendation:** Adopt three tiers: (1) Hot — concise CLAUDE.md under 100 lines with universal conventions and retrieval hooks, (2) Warm — .claude/rules/ with path-scoped, domain-specific rules loaded contextually, (3) Cold — detailed specs in docs/ referenced on demand via @-imports.
- **Evidence:** Codified Context paper showed 29% runtime reduction, 17% token savings. Anthropic recommends same pattern. Claude Code hierarchy supports this.
- **MPI Application:** Restructure CLAUDE.md into three tiers. Hot: core conventions, anti-patterns, required workflow. Warm: path-scoped rules for admin pipeline, public pipeline, API, testing, authorization. Cold: existing docs/ files. Apply to Optimus first, then propagate.
- **Epic Issues:** #226, #233, #238

#### F5.2: Simple RAG Outperforms Complex Memory Systems — Organization Over Infrastructure
- **Confidence:** High
- **Sources:** S5.3 (MemoryBench), S5.6 (RACG Survey), S5.2 (Anthropic)
- **Recommendation:** Invest in document quality, clear file naming, and logical directory structure rather than complex memory tooling. Do NOT invest in Mem0, vector databases, or custom RAG at this stage.
- **Evidence:** MemoryBench showed no advanced memory system consistently beats simple RAG. RACG survey confirms keyword-based approach works for organized repos. Indiscriminate storage degrades performance (up to 10% worse).
- **MPI Application:** Focus on: consistent file naming across repos, clear directory structure mirroring domain concepts, docs written for AI consumption (explicit file paths, parameter names, not prose-heavy), regular pruning of stale docs.
- **Epic Issues:** #238, #233

#### F5.3: Encode Domain Knowledge as Machine-Readable Specs, Not Human Prose
- **Confidence:** High
- **Sources:** S5.1 (Codified Context), S5.4 (Agentic KB Patterns), S5.2 (Anthropic)
- **Recommendation:** Rewrite domain docs for AI consumption: explicit code patterns with file paths, parameter names, expected behavior. Bullet points and code blocks, not narrative paragraphs. Each doc scoped to single subsystem.
- **Evidence:** Codified Context: over half of effective agent content is project-specific domain knowledge encoded directly. Agentic KB Patterns: mirror "senior employee's mental toolkit, structured for machine consumption." Claude docs: "concise bullet-point instructions are 40% more likely to be followed."
- **MPI Application:** Audit existing docs/. Rewrite key documents (system_permissions.md, notification_system.md) in structured format: domain concept, file locations, key patterns with code snippets, common pitfalls. The existing agent guides are a good start — extend the pattern.
- **Epic Issues:** #226, #233, #238

#### F5.4: Path-Scoped Rules Enable Domain-Specific Guidance Without Token Bloat
- **Confidence:** Medium
- **Sources:** S5.5 (Claude Code docs/SFEIR), S5.1 (Codified Context), S5.2 (Anthropic)
- **Recommendation:** Use .claude/rules/ with path-scoped rules. Prevents loading admin pipeline rules when working on public pipeline code, or testing rules when editing migrations.
- **Evidence:** Path-scoped rules only load when matching files active. 10,000-token budget means selectivity essential. Teams average 4-8 rule files.
- **MPI Application:** Create rules for: `app/controllers/admin/` (Pundit, Pagy, Ransack), `app/controllers/api/` (JWT, serialization), `spec/` (shared contexts, FactoryBot), `app/components/` (ViewComponent), `db/migrate/` (strong_migrations), `app/javascript/admin/`, `app/javascript/public/`. Under 50 lines each.
- **Epic Issues:** #226, #233, #238

#### F5.5: Institutional Memory Requires Active Curation, Not Accumulation
- **Confidence:** High
- **Sources:** S5.3 (MemoryBench), S5.1 (Codified Context), S5.2 (Anthropic)
- **Recommendation:** Establish regular cadence for reviewing and pruning memory. Indiscriminate accumulation degrades performance. Memory should be treated as code: reviewed, versioned, pruned.
- **Evidence:** MemoryBench: indiscriminate storage propagates errors. Utility-based deletion yields 10% gains. Codified Context: specifications are "living documents updated by the AI at the developer's direction."
- **MPI Application:** Review CLAUDE.md and MEMORY.md quarterly for stale content. After major features, update related docs/ and rules/. Use /compact regularly. Add CI check or reminder when docs may be stale relative to code changes.
- **Epic Issues:** #238, #233

#### F5.6: Cross-Repo Domain Knowledge Needs a Shared Business Context Layer
- **Confidence:** Medium
- **Sources:** S5.4 (Agentic KB Patterns), S5.1 (Codified Context)
- **Recommendation:** Create shared domain knowledge package referenced across MPI repos. Business domain definitions (content licensing, avails, media distribution), cross-repo decisions, shared conventions.
- **Evidence:** Agentic KB Patterns: "shared business context layers" emerging for multi-app ecosystems. LinkedIn's CAPT framework: centralized playbooks across 1,000+ engineers.
- **MPI Application:** Lightest approach: standardize `docs/mpi-domain/` folder template in each repo covering domain concepts for that app's role. Or shared skills in `~/.claude/skills/mpi-standards/`.
- **Epic Issues:** #233, #238

---

## Area 2: Multi-Agent Workflows

**Priority:** STANDARD
**Epic issues informed:** #226, #230
**Topics:** Agent orchestration patterns, handoff mechanisms, review loop design, quality gate patterns

### Sources

#### S2.1: Anthropic — 2026 Agentic Coding Trends Report
- **URL:** https://resources.anthropic.com/2026-agentic-coding-trends-report
- **Author/Org:** Anthropic
- **Type:** Industry report (vendor)
- **Date:** 2026 Q1
- **Credibility:** Customer deployment data from Rakuten, TELUS, Zapier. Vendor source.
- **Key Claims:** 2026 is the year multi-agent systems replace single-agent. Orchestrator delegates to specialized agents. Engineering roles shifting toward supervision and system design.
- **Evidence:** Customer case studies, internal research.
- **Relevance to MPI:** Validates MPI's multi-agent architecture. MPI is ahead of most organizations.
- **Limitations:** Vendor-produced, favors Anthropic products.

#### S2.2: CodeScene — Agentic AI Coding: Best Practice Patterns for Speed with Quality
- **URL:** https://codescene.com/blog/agentic-ai-coding-best-practice-patterns-for-speed-with-quality
- **Author/Org:** CodeScene (Adam Tornhill)
- **Type:** Technical blog with research backing
- **Date:** 2025-2026
- **Credibility:** High. Independent code quality company. Peer-reviewed Code Health metric.
- **Key Claims:** Agentic coding requires MORE rigor. Code health safeguards at three levels: continuous, pre-commit, PR pre-flight. 41% more defects without guardrails. Velocity gains cancelled after 2 months due to complexity.
- **Evidence:** Defect rate data, complexity measurements, controlled studies.
- **Relevance to MPI:** Three-tier safeguard model maps to rubocop + rspec + brakeman + bundler-audit. Validates "all four must pass" rule.
- **Limitations:** CodeScene sells code quality tooling.

#### S2.3: Mike Mason — AI Coding Agents in 2026: Coherence Through Orchestration, Not Autonomy
- **URL:** https://mikemason.ca/writing/ai-coding-agents-jan-2026/
- **Author/Org:** Mike Mason (independent)
- **Type:** Practitioner analysis
- **Date:** January 2026
- **Credibility:** High. Independent, cross-references DORA Report.
- **Key Claims:** DORA 2025: 90% AI adoption increase correlates with 9% bug rate climb, 91% code review time increase, 154% PR size increase. Parallelism is key multiplier. Agents excel at bounded tasks with clear criteria.
- **Evidence:** DORA statistics, industry survey data.
- **Relevance to MPI:** Validates human-in-the-loop workflow. DORA data is a warning to track PR size and review time.
- **Limitations:** Correlation ≠ causation.

#### S2.4: QuantumBlack (McKinsey) — Agentic Workflows for Software Development
- **URL:** https://medium.com/quantumblack/agentic-workflows-for-software-development-dc8e64f4a79d
- **Author/Org:** QuantumBlack, AI by McKinsey
- **Type:** Enterprise research
- **Date:** February 2026
- **Credibility:** Medium-High. Production patterns across engagements.
- **Key Claims:** Deterministic workflow engine (not LLM) should control sequencing. Knowledge agent for project context critical for coherence. Moving beyond POCs requires evaluations and IAM for agents.
- **Evidence:** Client engagements.
- **Relevance to MPI:** Validates command-driven approach where humans drive sequencing.
- **Limitations:** Enterprise focus.

#### S2.5: Addy Osmani — LLM Coding Workflow / Conductors to Orchestrators
- **URL:** https://addyosmani.com/blog/ai-coding-workflow/
- **Author/Org:** Addy Osmani (Google Chrome)
- **Type:** Practitioner documentation
- **Date:** 2026
- **Credibility:** High. Well-known engineering leader.
- **Key Claims:** Supervised AI usage. Structured "prompt plan" files. Small loops reduce errors. Role evolving: coder → conductor → orchestrator.
- **Evidence:** Personal production workflow.
- **Relevance to MPI:** "Prompt plan" maps to `/cplan`. Small loops support step-by-step workflow.
- **Limitations:** Single practitioner.

#### S2.6: Claude Code — Agent Teams and Subagents
- **URL:** https://code.claude.com/docs/en/agent-teams and https://code.claude.com/docs/en/sub-agents
- **Author/Org:** Anthropic
- **Type:** Product documentation
- **Date:** 2026
- **Credibility:** Authoritative for capabilities.
- **Key Claims:** Subagents: focused workers with own context. Agent Teams: independent teammates (experimental). Each agent gets own worktree with auto-cleanup.
- **Evidence:** Feature specifications.
- **Relevance to MPI:** Worktree-based parallel workflow aligns with built-in capabilities.
- **Limitations:** Agent Teams experimental.

#### S2.7: Google — Agent Development Kit (ADK) Loop Agent Documentation
- **URL:** https://google.github.io/adk-docs/
- **Author/Org:** Google
- **Type:** Vendor documentation
- **Date:** 2025-2026
- **Credibility:** Platform documentation for Google's agent framework.
- **Key Claims:** CriticAgent returns "STOP" signal when quality thresholds met. Loop agents support iteration caps with rollback. Deterministic evaluation gates between agent steps.
- **Evidence:** Framework specification.
- **Relevance to MPI:** Informs exit criteria and iteration cap patterns for review loops.
- **Limitations:** Google ADK-specific, not Claude Code.

#### S2.8: AGENTS.md Specification
- **URL:** https://agents.md/
- **Author/Org:** Community specification (multi-vendor)
- **Type:** Open standard
- **Date:** 2025-2026
- **Credibility:** Adopted by 60k+ projects. Tool-agnostic standard.
- **Key Claims:** AGENTS.md serves as universal instruction file recognized by multiple AI tools. Directory-tree proximity inheritance. Designed to complement tool-specific files (CLAUDE.md, .cursorrules).
- **Evidence:** Adoption metrics, multi-tool compatibility.
- **Relevance to MPI:** Validates MPI's dual-file approach (AGENTS.md + CLAUDE.md).
- **Limitations:** Not yet recognized by Claude Code directly (uses CLAUDE.md).

### Findings

#### F2.1: Deterministic Workflow Engines Should Drive Sequencing, Not Agents
- **Confidence:** High
- **Sources:** S2.4 (McKinsey), S2.2 (CodeScene), S2.3 (Mason), S2.5 (Osmani)
- **Recommendation:** Maintain command-driven workflow where humans control sequencing. Do not allow agents to self-determine workflow order.
- **Evidence:** McKinsey: agents struggle with meta-level workflow decisions. CodeScene: 41% more defects without structured guardrails.
- **MPI Application:** Already well-aligned. Formalize exit criteria for each step so transitions are gated on verifiable conditions.
- **Epic Issues:** #226, #230

#### F2.2: Parallel Worktree-Based Agents Are the Proven Scaling Pattern
- **Confidence:** Medium
- **Sources:** S2.6 (Claude Code docs), S2.3 (Mason), S2.1 (Anthropic Trends)
- **Recommendation:** Continue worktree isolation. Use subagents for <15 files. Evaluate Agent Teams when stable.
- **Evidence:** Multiple sources confirm worktree isolation as standard. Mason: parallelism is key multiplier.
- **MPI Application:** Already documented. Improvements: clearer subagent vs. team criteria, integration testing after merge, competing-agents pattern for critical features.
- **Epic Issues:** #226, #230

#### F2.3: Three-Tier Quality Gates Are Emerging as Standard
- **Confidence:** High
- **Sources:** S2.2 (CodeScene), S2.3 (Mason)
- **Recommendation:** Formalize: Tier 1 (Blocking) — rubocop, rspec, brakeman, bundler-audit. Tier 2 (Threshold) — coverage, PR size. Tier 3 (Regression) — complexity, drift.
- **Evidence:** CodeScene: continuous + pre-commit + PR pre-flight. DORA: PR sizes growing 154%.
- **MPI Application:** Tier 1 enforced. Add Tier 2 (SimpleCov, PR size) and Tier 3 (flog/flay).
- **Epic Issues:** #226, #230

#### F2.4: Review Loops Need Exit Criteria and Iteration Caps
- **Confidence:** Medium
- **Sources:** S2.4 (McKinsey), S2.7 (Google ADK)
- **Recommendation:** Cap review-fix cycles at 3. Define explicit exit criteria per workflow step.
- **Evidence:** Research recommends 3-5 iteration caps with rollback to human.
- **MPI Application:** After `/impl`, auto-complete if all checks pass. During `/rtr`, cap at 3 cycles. Define "done" per command.
- **Epic Issues:** #230, #226

#### F2.5: Implementer-Reviewer Pattern — Use Selectively
- **Confidence:** Medium
- **Sources:** S2.5 (Osmani), S2.2 (CodeScene)
- **Recommendation:** Generator-critic for high-risk changes. Deterministic verification for routine. Track whether review comments correlate with actual defects.
- **Evidence:** Quality assurance at cost of latency. Deterministic checks more cost-effective for routine work.
- **MPI Application:** Claude implements, Copilot reviews — good balance. For routine PRs, rely on four checks. For complex, add second reviewer.
- **Epic Issues:** #226, #230

#### F2.6: Agent-Generated Code Increases Complexity — Track It
- **Confidence:** High
- **Sources:** S2.2 (CodeScene), S2.3 (Mason/DORA)
- **Recommendation:** Monitor complexity and defect trends. Don't assume passing tests = maintained quality.
- **Evidence:** 41% more defects, velocity cancelled at 2 months (CodeScene). 9% bug rate climb, 154% PR size increase (DORA).
- **MPI Application:** Track PR size, time-to-merge, review cycles. Periodic flog/flay analysis.
- **Epic Issues:** #226, #230

---

## Area 4: Cross-Repository & Team-Scale AI Usage

**Priority:** STANDARD
**Epic issues informed:** #232, #235, #236
**Topics:** Standardizing AI config across repos, propagating best practices, scaling beyond individual contributors

### Sources

#### S4.1: Mercari Engineering — Taming Agents in the Mercari Web Monorepo
- **URL:** https://engineering.mercari.com/en/blog/entry/20251030-taming-agents-in-the-mercari-web-monorepo/
- **Author/Org:** Mercari Engineering (~1,800 engineers)
- **Type:** Engineering blog / case study
- **Date:** October 2025
- **Credibility:** High. Production case study, large org, concrete implementation.
- **Key Claims:** Consolidated tool-specific configs into single AGENTS.md. AGENTS.md as entrypoint linking to topical rule files. Directory-tree proximity inheritance. Automated doc sync.
- **Evidence:** Production implementation with specific patterns.
- **Relevance to MPI:** Root AGENTS.md linking to topical docs mirrors Optimus pattern.
- **Limitations:** Monorepo; MPI is polyrepo.

#### S4.2: Rajiv Pant — Polyrepo Synthesis and Claude Memory
- **URL:** https://rajiv.com/blog/2025/11/30/polyrepo-synthesis-synthesis-coding-across-multiple-repositories-with-claude-code-in-visual-studio-code/
- **Author/Org:** Rajiv Pant (CTO-level, formerly NYT/Hearst)
- **Type:** Technical blog
- **Date:** November-December 2025
- **Credibility:** Medium-High. Named production projects.
- **Key Claims:** "CLAUDE.md context mesh" gives ecosystem awareness. Cross-repo impact analysis. Pattern cross-pollination across codebases.
- **Evidence:** Specific cross-repo examples.
- **Relevance to MPI:** MPI apps share data patterns. Context mesh lets agents understand propagation.
- **Limitations:** Two-repo example; MPI has 9.

#### S4.3: Gravitee — State of AI Agent Security 2026 Report
- **URL:** https://www.gravitee.io/blog/state-of-ai-agent-security-2026-report-when-adoption-outpaces-control
- **Author/Org:** Gravitee (750 respondents)
- **Type:** Industry survey
- **Date:** February 2026
- **Credibility:** Medium-High. Large sample.
- **Key Claims:** 88% reported security incidents. Only 21.9% treat agents as identity-bearing entities. Only 47.1% actively monitored.
- **Evidence:** 750 executives surveyed.
- **Relevance to MPI:** MPI's Co-Authored-By requirement ahead of 78% of organizations.
- **Limitations:** Enterprise scale (250+ employees).

#### S4.4: DX — AI Code Generation: Enterprise Adoption
- **URL:** https://getdx.com/blog/ai-code-enterprise-adoption/
- **Author/Org:** DX
- **Type:** Industry report
- **Date:** 2025
- **Credibility:** Medium-High. 266-company sample.
- **Key Claims:** Process-first orgs achieve 3x better adoption. 60% lower gains without training. Onboarding halved with daily AI.
- **Evidence:** Multi-company quantitative data.
- **Relevance to MPI:** Validates standards-in-CLAUDE.md approach.
- **Limitations:** Aggregate data.

#### S4.5: GitHub — Agent HQ and Enterprise AI Controls
- **URL:** https://github.blog/news-insights/company-news/welcome-home-agents/
- **Author/Org:** GitHub
- **Type:** Product announcement
- **Date:** February 2026 (GA)
- **Credibility:** Authoritative for capabilities.
- **Key Claims:** Centralized multi-vendor agent management. MCP allowlist. Audit logs with actor_is_agent.
- **Evidence:** GA release.
- **Relevance to MPI:** Could provide governance layer. Verify plan support.
- **Limitations:** Enterprise-tier features.

#### S4.6: Knostic — Governance for AI Coding Assistants
- **URL:** https://www.knostic.ai/blog/ai-coding-assistant-governance
- **Author/Org:** Knostic
- **Type:** Vendor guide
- **Date:** 2025-2026
- **Credibility:** Medium. Actionable framework.
- **Key Claims:** Logging, audit trails, code attribution, approved model lists, config drift detection.
- **Evidence:** Framework with SOC 2 references.
- **Relevance to MPI:** Config drift detection maps to cross-repo alignment.
- **Limitations:** Generic, not for small teams.

### Findings

#### F4.1: Hierarchical Configuration Inheritance is the Proven Pattern
- **Confidence:** High
- **Sources:** S4.1 (Mercari), S4.2 (Pant), S1.1 (Anthropic)
- **Recommendation:** Three-tier hierarchy: org-level standards → per-repo config → directory-level rules. Optimus as canonical source.
- **Evidence:** Mercari consolidated into hierarchical AGENTS.md. Claude Code supports system > user > project > directory inheritance.
- **MPI Application:** Shared "MPI Standards" section in every CLAUDE.md. Per-repo sections for architecture/domain. projects.json maps ecosystem.
- **Epic Issues:** #232, #235, #236

#### F4.2: Maintain Dual AGENTS.md + CLAUDE.md
- **Confidence:** High
- **Sources:** S4.1 (Mercari), S2.8 (AGENTS.md spec)
- **Recommendation:** AGENTS.md = tool-agnostic (Copilot, others). CLAUDE.md = Claude-specific. AGENTS.md is the portable propagation artifact.
- **Evidence:** Mercari consolidated for multi-tool. AGENTS.md recognized by 60k+ projects.
- **MPI Application:** Ensure AGENTS.md has Copilot review content. CLAUDE.md references AGENTS.md, doesn't duplicate.
- **Epic Issues:** #232, #235

#### F4.3: Agent Identity and Attribution as Security Foundation
- **Confidence:** Medium
- **Sources:** S4.3 (Gravitee), S4.5 (GitHub), S4.6 (Knostic)
- **Recommendation:** Extend beyond commits. Traceable: who authorized, what agent, what permissions, scope.
- **Evidence:** 21.9% treat agents as identity-bearing; 88% had incidents. GitHub audit logs support this.
- **MPI Application:** Ahead of industry. Extend: agent per PR, MCP logging, identity in permissions.
- **Epic Issues:** #235, #236

#### F4.4: Configuration Propagation via Template Pattern
- **Confidence:** Medium
- **Sources:** S4.1 (Mercari), S4.2 (Pant)
- **Recommendation:** Formalize Optimus as config template. Defined propagation when CLAUDE.md/AGENTS.md change.
- **Evidence:** Mercari automated sync. `/compare` command exists.
- **MPI Application:** Standards in Optimus first. `/compare` diffs downstream. Sync PRs for drift. CI workflow possible via mpi-application-workflows.
- **Epic Issues:** #232, #236

#### F4.5: Process Investment Outweighs Tool Investment 3:1
- **Confidence:** Medium
- **Sources:** S4.4 (DX)
- **Recommendation:** Document processes over adopting tools. Training and command libraries first.
- **Evidence:** 3x better adoption treating AI as process challenge. 60% lower gains without training.
- **MPI Application:** Command library is strong. Add: prompting patterns doc, "getting started" guide, propagate commands to downstream repos.
- **Epic Issues:** #232, #236

#### F4.6: MCP Governance Requires Explicit Allowlisting
- **Confidence:** Low
- **Sources:** S4.5 (GitHub), S4.6 (Knostic)
- **Recommendation:** Document approved MCP servers, data scope, permitted actions per repo.
- **Evidence:** GitHub MCP allowlist. Knostic: identity-tied logging.
- **MPI Application:** Review .claude/settings.json. Document approved servers. Include in propagation.
- **Epic Issues:** #235, #236

#### F4.7: Fleet Management — Monitor, Don't Invest Yet
- **Confidence:** Medium
- **Sources:** S4.5 (GitHub), S4.3 (Gravitee)
- **Recommendation:** Monitor Agent HQ. Current per-repo config sufficient for MPI's scale.
- **Evidence:** Agent HQ targets large orgs. MPI is smaller.
- **MPI Application:** Revisit at 3+ concurrent agent users or compliance requirements.
- **Epic Issues:** #236

---

## Anti-Patterns

Practices that research shows are counterproductive. Cross-referenced across multiple sources.

### AP1: Stuffing Everything into CLAUDE.md (High Confidence)
- **Sources:** S1.1, S1.2, S1.3, S5.1, S5.5
- **Pattern:** Loading all project context, architecture docs, and enforcement rules into a single CLAUDE.md.
- **Why it fails:** Context rot degrades retrieval by 30%+ (Chroma). Past 500 lines, Claude skims (Potapov). Single-file manifests don't scale (Codified Context). After compaction, all instructions get "may or may not be relevant" disclaimer.
- **Instead:** Three-tier architecture (F1.4, F5.1). Hooks for enforcement (F1.2). Skills for domain knowledge (F1.3).

### AP2: Trusting AI Speed Perception Without Measurement (High Confidence)
- **Sources:** S3.1, S3.4, S2.2
- **Pattern:** Assuming AI tools are faster because they feel faster.
- **Why it fails:** METR: perceived 20% speedup, actual 19% slower. CodeScene: velocity gains cancelled at 2 months. Only 20% of teams measure.
- **Instead:** Track paired metrics (F3.5). Measure completion time, not perception.

### AP3: Skipping Planning to "Just Let the Agent Code" (High Confidence)
- **Sources:** S3.2, S3.5, S3.6, S2.4
- **Pattern:** Vague instructions expecting good output through iteration.
- **Why it fails:** 82% plan approval, only 25% code reaches PR (Atlassian). Agents without quality targets optimize for speed (CodeScene). Agents struggle with meta-level decisions (McKinsey).
- **Instead:** Structured specs before code (F3.2). Use `/review-issue` → `/cplan` flow.

### AP4: Removing Quality Gates for AI Code (High Confidence)
- **Sources:** S3.3, S3.6, S2.2, S2.3
- **Pattern:** Relaxing checks because "the AI should handle that."
- **Why it fails:** 4x code duplication, 44% higher churn (GitClear). 41% more defects without guardrails (CodeScene). 9% bug rate climb (DORA).
- **Instead:** Gates WITHIN agent loop (F3.3). Add complexity monitoring (F2.6).

### AP5: Complex Memory Before Organized Docs (Medium Confidence)
- **Sources:** S5.3, S5.6, S5.2
- **Pattern:** Investing in vector DBs or custom RAG before organizing docs.
- **Why it fails:** No advanced memory system consistently beats simple RAG (MemoryBench). Indiscriminate storage degrades by 10%. Claude Code's search works for organized repos.
- **Instead:** Document quality and structure first (F5.2). Organization > infrastructure.

### AP6: Full Agent Autonomy Over Workflow (Medium Confidence)
- **Sources:** S2.4, S2.2, S3.7
- **Pattern:** Letting agents decide what to do next.
- **Why it fails:** Agents struggle with workflow decisions (McKinsey). "On the loop" outperforms "out of the loop" (Morris/Fowler).
- **Instead:** Command-driven with deterministic sequencing (F2.1).

### AP7: Treating All AI Output as Equal Quality (Medium Confidence)
- **Sources:** S3.1, S3.3, S2.2
- **Pattern:** Uniform trust regardless of task type.
- **Why it fails:** AI slower on mature codebases, faster on unfamiliar (METR). Excels at boilerplate, increases duplication (GitClear).
- **Instead:** Scope to strengths (F3.1). More scrutiny on high-risk changes (F2.5).

### AP8: Accumulating Memory Without Pruning (Medium Confidence)
- **Sources:** S5.3, S5.1, S5.2
- **Pattern:** Continuously adding to memory without reviewing.
- **Why it fails:** Indiscriminate storage propagates errors (MemoryBench). Deletion yields 10% gains over naive accumulation.
- **Instead:** Active curation (F5.5). Treat memory as code: review, version, prune.


---

## Traceability Matrix

Each finding maps to epic issues with confidence level and review date.

| ID | Finding Summary | Confidence | Epic Issues | Area | Date |
|----|----------------|------------|-------------|------|------|
| F1.1 | Restructure CLAUDE.md with priority-based ordering | High | #228, #229 | 1 | 2026-03-07 |
| F1.2 | Migrate anti-pattern enforcement to hooks/settings | Medium | #228, #238 | 1 | 2026-03-07 |
| F1.3 | Implement skills for domain knowledge | Medium | #229, #228 | 1 | 2026-03-07 |
| F1.4 | Adopt context tiering strategy | Medium | #228, #229, #239 | 1 | 2026-03-07 |
| F1.5 | Optimize token consumption practices | High | #238, #240 | 1 | 2026-03-07 |
| F1.6 | Use PreCompact hooks for state preservation | Medium | #238, #228 | 1 | 2026-03-07 |
| F1.7 | Re-scan cadence via GitHub Actions | Low | #238 | 1 | 2026-03-07 |
| F2.1 | Deterministic workflow sequencing, not agent-driven | High | #226, #230 | 2 | 2026-03-07 |
| F2.2 | Parallel worktree agents are proven pattern | Medium | #226, #230 | 2 | 2026-03-07 |
| F2.3 | Three-tier quality gates emerging as standard | High | #226, #230 | 2 | 2026-03-07 |
| F2.4 | Review loops need exit criteria and iteration caps | Medium | #230, #226 | 2 | 2026-03-07 |
| F2.5 | Implementer-reviewer pattern — use selectively | Medium | #226, #230 | 2 | 2026-03-07 |
| F2.6 | Agent code increases complexity — track it | High | #226, #230 | 2 | 2026-03-07 |
| F3.1 | Experienced devs on mature codebases may not benefit | High | #227, #230 | 3 | 2026-03-07 |
| F3.2 | Planning quality is the primary lever | High | #227, #230, #231 | 3 | 2026-03-07 |
| F3.3 | Automated quality gates non-negotiable | High | #231, #227 | 3 | 2026-03-07 |
| F3.4 | Optimal human role is "on the loop" | Medium | #230, #227 | 3 | 2026-03-07 |
| F3.5 | Measure speed AND quality side-by-side | High | #231, #227 | 3 | 2026-03-07 |
| F3.6 | Small iterative chunks outperform monolithic | High | #230, #227 | 3 | 2026-03-07 |
| F3.7 | Second AI model as code critique layer | Medium | #231, #230 | 3 | 2026-03-07 |
| F3.8 | Codebase health is precondition | Medium | #231, #227 | 3 | 2026-03-07 |
| F4.1 | Hierarchical config inheritance is proven pattern | High | #232, #235, #236 | 4 | 2026-03-07 |
| F4.2 | Maintain dual AGENTS.md + CLAUDE.md | High | #232, #235 | 4 | 2026-03-07 |
| F4.3 | Agent identity and attribution as security foundation | Medium | #235, #236 | 4 | 2026-03-07 |
| F4.4 | Config propagation via template pattern | Medium | #232, #236 | 4 | 2026-03-07 |
| F4.5 | Process investment outweighs tool investment 3:1 | Medium | #232, #236 | 4 | 2026-03-07 |
| F4.6 | MCP governance requires explicit allowlisting | Low | #235, #236 | 4 | 2026-03-07 |
| F4.7 | Fleet management — monitor, don't invest yet | Medium | #236 | 4 | 2026-03-07 |
| F5.1 | Three-tier memory architecture | Medium | #226, #233, #238 | 5 | 2026-03-07 |
| F5.2 | Simple RAG outperforms complex memory systems | High | #238, #233 | 5 | 2026-03-07 |
| F5.3 | Domain knowledge as machine-readable specs | High | #226, #233, #238 | 5 | 2026-03-07 |
| F5.4 | Path-scoped rules for domain guidance | Medium | #226, #233, #238 | 5 | 2026-03-07 |
| F5.5 | Active memory curation over accumulation | High | #238, #233 | 5 | 2026-03-07 |
| F5.6 | Shared business context layer for cross-repo | Medium | #233, #238 | 5 | 2026-03-07 |

### Confidence Summary

| Level | Count | Percentage |
|-------|-------|------------|
| High | 15 | 44% |
| Medium | 17 | 50% |
| Low | 2 | 6% |

### Source Composition

| Type | Count | Sources |
|------|-------|---------|
| Academic papers | 4 | S3.1, S5.1, S5.3, S5.6 |
| Independent engineering blogs | 10 | S1.2 (Chroma), S1.3, S1.7, S2.3, S3.3, S3.5, S3.7, S4.2, S5.4, S5.5 (SFEIR) |
| Industry research/reports | 3 | S3.4, S4.3, S4.4 |
| Open standards | 1 | S2.8 (AGENTS.md spec) |
| Vendor docs | 11 | S1.1, S1.4, S1.5 (Factory.ai), S1.6 (Google), S1.8, S2.1, S2.6, S2.7 (Google ADK), S4.5 (GitHub), S4.6 (Knostic), S5.2 |
| Production case studies | 3 | S3.2 (Atlassian), S3.8 (Microsoft), S4.1 (Mercari) |
| Practitioner blogs | 4 | S2.2 (CodeScene), S2.4 (McKinsey), S2.5 (Osmani), S3.6 (CodeScene) |

**Independent-to-vendor ratio:** 25:11 (69% independent) — meets source composition rule.
**Total sources:** 36

### Coverage — Findings per Issue

| Issue | Findings |
|-------|----------|
| #226 | F2.1, F2.2, F2.3, F2.4, F2.5, F2.6, F5.1, F5.3, F5.4 |
| #227 | F3.1, F3.2, F3.3, F3.4, F3.5, F3.6, F3.8 |
| #228 | F1.1, F1.2, F1.3, F1.4, F1.6 |
| #229 | F1.1, F1.3, F1.4 |
| #230 | F2.1, F2.2, F2.3, F2.4, F2.5, F2.6, F3.1, F3.2, F3.4, F3.6, F3.7 |
| #231 | F3.2, F3.3, F3.5, F3.7, F3.8 |
| #232 | F4.1, F4.2, F4.4, F4.5 |
| #233 | F5.1, F5.2, F5.3, F5.4, F5.5, F5.6 |
| #235 | F4.1, F4.2, F4.3, F4.6 |
| #236 | F4.1, F4.3, F4.4, F4.5, F4.6, F4.7 |
| #238 | F1.2, F1.5, F1.6, F1.7, F5.1, F5.2, F5.3, F5.4, F5.5, F5.6 |
| #239 | F1.4 |
| #240 | F1.5 |

**In scope:** #226, #227, #228, #229, #230, #231, #232, #233, #235, #236, #238, #239, #240
**Permanently out of scope:** #237 (UI/UX research process — design domain, not agent workflow; if research is needed, it should be a separate task scoped to design/UX sources)
