# CLAUDE.md

Optimus is the Ruby on Rails template and reference implementation for the MPI Media application suite. Conventions originate here and flow to all MPI apps.

## MPI Media

MPI Media is a film and television distributor (labels: Watermelon Pictures, Dark Sky Films, MPI Classics), focused on the North American marketplace. The application suite supports internal staff managing catalog/sales/distribution and public users browsing, purchasing, and interacting with MPI's content.

**Apps:** Markaz (internal catalog/data), SFA (public + internal stock footage), Garden (public sites + internal CMS), Harvest (public ecommerce + internal), CRM (internal), Optimus (dev team template). All share: Ruby/Rails, PostgreSQL, Hotwire, Bootstrap 5.3, ViewComponent, GoodJob, Pundit, RSpec/FactoryBot. See @.claude/projects.json for full registry.

## Quality Expectations

- Research the codebase before proposing solutions — read existing code, don't guess from file names
- Check if Rails conventions or established gems already solve the problem before building custom
- Explain why you chose an approach over alternatives — in assessments, plans, and PR descriptions
- Never declare work done until the self-review checklist passes (see @.claude/rules/self-review.md)
- Never claim something "can't be tested" without researching the stack first (Capybara, Selenium CDP, VCR)
- Testing is a first-class deliverable, not an afterthought — feature specs protect the user experience from regressions and must never be skipped or minimized
- Run tests as you develop, not just before committing — catch failures early by running relevant specs after each significant change
- Consider writing tests first (TDD) for complex business logic — let the tests define the expected behavior, then implement to pass them
- Before submitting any work, ask: "What would a critical reviewer flag here?" — then fix it before they see it

## Anti-Patterns (Never Do)

- Never hard-delete archivable records — use `archive!` / `unarchive!`
- Never add a global `master.key` or `credentials.yml.enc` — per-environment credentials only
- Never skip `authorize` in admin controller actions

Domain-specific anti-patterns auto-load from `.claude/rules/` when touching relevant files:
- @.claude/rules/backend.md — models, controllers, jobs, authorization, gem preferences
- @.claude/rules/frontend.md — JavaScript, views, components, assets
- @.claude/rules/testing.md — specs, factories, coverage, definition of done
- @.claude/rules/security.md — credentials, scanning, secrets
- @.claude/rules/migrations.md — database migrations, strong_migrations
- @.claude/rules/self-review.md — quality checklist before declaring done

## Required Workflow

**ALWAYS run before committing or pushing:**

```bash
bundle exec rubocop -a
bundle exec rspec
bin/brakeman --no-pager -q
bin/bundler-audit check
```

All four must pass. No exceptions. Write tests that protect against regressions, not tests that hit a coverage number.

## Agent Attribution (Required)

See `AGENTS.md` for full attribution rules. Summary:
- **Commits** — `Co-Authored-By: <Agent Name> <agent-email>`
- **PRs, PR reviews, issue comments** — Attribution line (e.g., `— Claude Code (Opus 4.6)`)

## HC Working Instructions

1. Ask questions one at a time to remove ambiguity — do NOT guess
2. Research and present recommendations, alternatives, and best practices when options arise
3. Ask about MPI business context when it affects the work — what the app does, who uses it, why a feature matters, how apps relate to each other

## Permissions and Autonomy

**Feature branches:** Full autonomy — commit, edit, refactor without asking. Only ask for requirement clarification.
**`main` branch:** Ask before any changes. Check first: `git branch --show-current`
**Core vs peripheral:** When working on core business logic (payment flows, data integrity, authorization, public-facing UX), flag it to the HC and work synchronously — present decisions as you go, don't batch them. For standard patterns (CRUD, admin views, test generation, refactoring), work autonomously per branch permissions.

## Commit and PR Standards

Verbose, detailed documentation required. Commit messages: summary line + detailed body (what, why, approach, decisions). PRs: Summary, Changes, Technical Approach, Testing, Checklist sections.

## Key Commands

```bash
bin/dev                                        # Rails server only
foreman start -f Procfile.development          # Full dev stack
bin/rails credentials:edit --environment production
bin/kamal deploy                               # Production
bin/kamal deploy -d staging                    # Staging
```

## Agent Strategy

- **Single agent** — Default. Scope < 15 files or tightly coupled.
- **Parallel agents** — 15+ files, independent subsystems. Use `/orch NNN`.
- **Background agents** — Long-running tasks while main agent continues.

## Architecture (Pointers)

- **Authorization** — Pundit: `User → SystemGroups → SystemRoles → SystemPermissions`. See @docs/system_permissions.md.
- **Forms** — Select inputs: `tom_select`. See @app/views/admin/system_groups/_form.html.erb.
- **Enumerable pattern** — Module in `app/modules/`, concern in `app/models/concerns/`. See @app/modules/notification_distribution_methods.rb.
- **Notifications** — See @docs/notification_system.md.
- **Asset pipelines** — Two separate pipelines (admin/public). See @.claude/rules/frontend.md.
- **Lifecycle** — Assess → Plan → Implement → Verify → Deliver. See @docs/standards/development-lifecycle.md. Skills: `/assess`, `/cplan`, `/impl`, `/verify`, `/rtr`, `/final`.
- **Testing** — See @.claude/rules/testing.md and @docs/standards/testing.md.
- **Self-review** — Auto-loads on `app/`, `spec/`, `lib/`. See @.claude/rules/self-review.md.
- **Migration safety** — `strong_migrations` enforced. See @.claude/rules/migrations.md.
- **MCP** — See @docs/architecture/mcp-integration-audit.md.
- **Memory** — See @docs/standards/memory-management.md. Run `/memory-review` to audit.
- **Full architecture** — See @docs/architecture/overview.md.
