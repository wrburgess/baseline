# Anti-Patterns — Canonical Inventory

Single source of truth for all negative instructions enforced across the MPI application suite. Agent configuration files (`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.claude/rules/*.md`) derive their anti-pattern sections from this inventory.

When adding or modifying rules, update this file first, then propagate to the relevant surfaces.

## Inventory

| ID | Rule | Severity | Scope | Enforcement | Target Surfaces | Source |
|----|------|----------|-------|-------------|-----------------|--------|
| AP-01 | Never suggest React, Vue, or other JS frameworks — Hotwire (Turbo + Stimulus) only | Hard | Frontend | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-02 | Never use inline JavaScript — Stimulus controllers only | Hard | Frontend | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-03 | Never use fixtures — FactoryBot only | Hard | Testing | settings.json deny | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-04 | Never use controller specs — request specs only | Hard | Testing | settings.json deny | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-05 | Never hard-delete archivable records — use `archive!` / `unarchive!` | Hard | Models | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-06 | Never add a global `master.key` or `credentials.yml.enc` — per-environment credentials only | Hard | Security | settings.json deny | CLAUDE.md, AGENTS.md, copilot-instructions.md, rules/security.md | Original |
| AP-07 | Never skip `authorize` in admin controller actions | Hard | Controllers | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-08 | Never use Redis for background jobs — GoodJob is Postgres-backed | Hard | Backend | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-09 | Never mix admin and public assets — separate pipelines, separate Stimulus controllers | Hard | Frontend | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-10 | Never hardcode permission checks — use Pundit policies and `access_authorized?` | Hard | Controllers | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-11 | Never use `policy_scope` without defining `ransackable_attributes` — Ransack exposes fields | Hard | Controllers | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | Original |
| AP-12 | Never use `default_scope` — use named scopes | Hard | Models | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md, rules/backend.md | HC decision (#240) |
| AP-13 | Always prefer Rails per-environment credentials over `ENV` for application secrets and configuration — `ENV` is acceptable for platform/runtime vars (`DATABASE_URL`, `PORT`, `RAILS_ENV`) set by the deployment environment | Hard | Security | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md, rules/security.md | HC decision (#240) |
| AP-14 | Never add React, Vue, Alpine.js, Angular, or other SPA/component frameworks — use Stimulus, Hotwire, and native JS (utility libraries like Bootstrap JS and Tom Select are fine) | Hard | Frontend | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md | HC decision (#240) |
| AP-15 | Never disable Brakeman or Bundler-Audit warnings without a documented justification comment (`# brakeman:disable Reason — Approved by [name] on [date]`) | Hard | Security | Advisory | CLAUDE.md, AGENTS.md, copilot-instructions.md, rules/security.md | HC decision (#240) |
| AP-16 | Prefer `find_each` for large result sets (100+ records) — avoid `.all.each` on entire tables | Advisory | Models | Advisory | rules/backend.md | `docs/standards/query-patterns.md` |
| AP-17 | Prefer preloaded data or counter caches over `.count` in loops | Advisory | Models | Advisory | rules/backend.md | `docs/standards/query-patterns.md` |
| AP-18 | Never add service object gems (Interactor, Trailblazer, Dry-Transaction) — use plain Ruby | Advisory | Gems | Advisory | rules/backend.md | HC decision (#240) |
| AP-19 | Never add serializer gems (AMS, Blueprinter) — prefer jbuilder | Advisory | Gems | Advisory | rules/backend.md | HC decision (#240) |
| AP-20 | Never add decorator gems (Draper) — use ViewComponent | Advisory | Gems | Advisory | rules/backend.md | HC decision (#240) |
| AP-21 | Never add CSS frameworks beyond Bootstrap 5.3 | Advisory | Frontend | Advisory | rules/frontend.md | `docs/standards/design.md` |
| AP-22 | Never add inline styles in ERB templates | Advisory | Frontend | Advisory | rules/frontend.md | `docs/standards/style.md` |
| AP-23 | Prefer testing through the public interface — avoid testing private methods directly | Advisory | Testing | Advisory | rules/testing.md | `docs/standards/testing.md` |
| AP-24 | Prefer `freeze_time` or `travel_to` over `sleep` for time-dependent tests | Advisory | Testing | Advisory | rules/testing.md | `docs/standards/testing.md` |
| AP-25 | Never use `change_column_null` without `safety_assured` and separate validation step | Advisory | Migrations | Advisory | rules/migrations.md | strong_migrations |
| AP-26 | Never add a column with a default on a large table in a single migration step | Advisory | Migrations | Advisory | rules/migrations.md | strong_migrations |
| AP-27 | Never commit secrets, API keys, or tokens to the repository | Hard | Security | Advisory | rules/security.md | `docs/standards/code-review.md` |

## Severity Definitions

- **Hard** — Universal rule. Appears in CLAUDE.md, AGENTS.md, and copilot-instructions.md. No exceptions without HC approval.
- **Advisory** — Contextual guidance. Appears in path-scoped rule files (`.claude/rules/*.md`) only. Soft preference that may have valid exceptions.

## Maintenance

- Update this inventory first, then propagate changes to target surfaces
- Cross-repo propagation tracked in issue #232
- Review cadence: when new architecture decisions are made or existing patterns change
