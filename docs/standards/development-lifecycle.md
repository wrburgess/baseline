# Baseline Development Lifecycle

## Purpose

Defines how an AI Contributor (AC) works from problem definition through delivery across all Baseline projects. Designed to be model-agnostic — the stages and quality gates stay the same as AC capabilities improve. What changes over time is which gates require external review vs. self-review.

## Roles

- **HC** — Human Contributor. Makes decisions, approves gates, owns the product.
- **AC** — AI Contributor. Does the work, self-reviews, responds to feedback.
- **Reviewer** — External AI reviewer (currently Codex). Provides unbiased critique.

## The Lifecycle

### Stage 1: Assess (`/assess`)

**Trigger:** HC assigns an issue or asks AC to review one.

**AC produces:**
- Summary of the problem and its impact
- Research into the codebase (relevant files, existing patterns, dependencies)
- 2-3 options with trade-offs, not just one recommendation
- Risk assessment for each option
- Questions for HC if requirements are ambiguous (ask, don't guess)

**Quality gate:** HC sends assessment to Reviewer. Reviewer checks for:
- Missing options or trade-offs not considered
- Incorrect assumptions about the codebase
- Requirements gaps or misunderstandings
- Architectural concerns

**Exit:** HC picks an option (or asks for revisions). AC does not proceed without a chosen option.

---

### Stage 2: Plan (`/cplan`)

**Trigger:** HC picks an option from the assessment.

**AC produces:**
- Step-by-step implementation plan with specific file paths
- Testing strategy: what spec types, what scenarios, what edge cases — decided now, not during implementation
- Migration plan if database changes are involved
- List of files to create/modify (used to determine single-agent vs. parallel)
- If 15+ files or independent subsystems: recommend parallel agents via `/orch`

**Quality gate:** HC sends plan to Reviewer. Reviewer checks for:
- Steps that are too vague to implement without guessing
- Missing edge cases in the testing strategy
- Architectural patterns that don't match the codebase
- Requirements from the issue that aren't addressed in the plan

**Exit:** HC approves plan (or asks for revisions). AC does not write code without an approved plan.

---

### Stage 3: Implement (`/impl`)

**Trigger:** HC approves the plan.

**AC does:**
- Creates feature branch
- Implements according to the plan, step by step
- Writes tests per the testing strategy defined in Stage 2
- Follows `.claude/rules/testing.md` — definition of done, full coverage, strict naming
- Runs all checks: `bundle exec rubocop -a`, `bundle exec rspec`, `bin/brakeman --no-pager -q`, `bin/bundler-audit check`

**Quality gate:** AC self-review before requesting any review. Checklist:
- [ ] Every item in the plan is implemented
- [ ] Every test scenario from the plan is covered
- [ ] Model specs: all validations, associations, scopes, callbacks, public methods
- [ ] Request specs: response content, DB side effects, authorization, flash/redirects
- [ ] Feature specs: at least one per controller action type
- [ ] Edge cases: invalid params, duplicates, boundary values
- [ ] "What would the Reviewer flag here?" — identify and fix before moving on
- [ ] All four checks pass (`bundle exec rubocop -a`, `bundle exec rspec`, `bin/brakeman --no-pager -q`, `bin/bundler-audit check`)

**Exit:** All checks pass and self-review checklist is complete. AC creates PR.

---

### Stage 4: Verify (`/verify`)

**Trigger:** PR is created.

**AC does:**
- Reviews its own PR diff against the approved plan
- Checks for drift: anything implemented that wasn't in the plan? Anything in the plan that's missing?
- Reviews test quality: are assertions meaningful or just status-code checks?
- Reads every test and asks: "If this test passed but the feature was broken, would I know?"
- Writes thorough PR description per commit/PR standards

**Quality gate:** AC self-review of the complete PR. Checklist:
- [ ] PR description includes summary, changes, technical approach, testing, checklist
- [ ] No files changed that aren't in the plan (no scope creep)
- [ ] Every plan item has a corresponding test
- [ ] No "TODO" or "needs manual testing" comments remain
- [ ] Diff is clean: no debug code, no commented-out code, no unrelated changes

**Exit:** Self-review passes. HC is notified PR is ready for Reviewer.

---

### Stage 5: Deliver (`/final`)

**Trigger:** HC sends PR to Reviewer.

**Reviewer checks for:**
- Testing gaps (the most common finding)
- Code quality, naming, structure
- Security concerns
- Edge cases not covered
- Requirements from the issue not addressed

**AC responds to Reviewer feedback:**
- Fix every P1 and P2 finding
- For P3 findings: fix or explain why not (HC decides)
- Do not argue with Reviewer findings unless factually incorrect — if the Reviewer flags it, it's a real gap

**SOW (Statement of Work) — AC generates and posts on the PR before merge:**
1. **Issue** — link and one-line summary
2. **Option chosen** — which approach from assessment and why
3. **Technical decisions** — non-obvious choices and reasoning
4. **What changed** — files created/modified/deleted with purpose
5. **Testing coverage** — spec types, scenarios, notable edge cases
6. **Reviewer findings** — what was caught and how it was resolved
7. **Known limitations** — anything intentionally deferred
8. **Follow-up items** — issues created for future work

AC posts a reference link on the original issue pointing to the SOW on the PR.

**Exit:** Reviewer finds no P1/P2 issues. SOW is posted. HC merges.

---

## When to Skip or Compress Stages

| Scenario | Approach |
|----------|----------|
| Trivial fix (typo, config change, dependency bump) | Assess → Implement → Deliver (skip Plan, compress self-review) |
| Bug fix with obvious cause | Assess → Plan (brief) → Implement → Deliver |
| Large feature (15+ files) | Full lifecycle + `/orch` for parallel agents |
| Documentation-only change | Implement → Deliver |

HC decides when to compress. AC does not self-select a compressed workflow.

## Skill Mapping

| Stage | Skill | Status |
|-------|-------|--------|
| Assess | `/assess` | Renamed from `/review-issue` |
| Plan | `/cplan` | Updated to require testing strategy |
| Implement | `/impl` | Updated to include self-review checklist |
| Verify | `/verify` | New — PR self-review against plan |
| Deliver | `/final` | Updated to generate SOW + link on issue |
| Parallel orchestration | `/orch` | Triggered by plan when 15+ files |
| Review response | `/rtr` | Unchanged — respond to PR review comments |

**Deprecated:** `/esti` — agent estimation is folded into the Plan stage (`/cplan`). Remove references to `/esti` in other skills as they are updated.

## Measuring Improvement

Track over time:
- **Reviewer P1/P2 findings per PR** — goal: trending toward zero
- **Passes per stage** — goal: 1 pass (Reviewer confirms, not corrects)
- **HC interventions** — goal: HC makes decisions, not corrections

When Reviewer consistently finds nothing at a stage, HC can experiment with dropping that review and relying on self-review alone.
