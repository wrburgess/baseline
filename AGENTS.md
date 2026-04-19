# AGENTS.md

Instructions for all AI coding agents (Claude Code, Copilot, Codex, and others) working in this repository.

## About This Project

Optimus is the Ruby on Rails application template and reference implementation for the MPI Media application ecosystem. Standards, conventions, and architectural decisions originate here and propagate to the other applications.

## MPI Application Ecosystem

| Project | GitHub Repo | Role |
|---------|-------------|------|
| **Optimus** (this repo) | `mpimedia/optimus` | Application template and pattern source |
| **Markaz** (Avails) | `mpimedia/avails_server` | Central data repository for MPI Media |
| **SFA** | `mpimedia/wpa_film_library` | Video clip hosting and search engine |
| **Garden** | `mpimedia/garden` | Static site generator for MPI sites |
| **Harvest** | `mpimedia/harvest` | Public-facing transaction and ecommerce platform |
| **Markaz CRM** | `mpimedia/markez-crm` | CRM (to be merged into Markaz) |
| **Infrastructure** | `mpimedia/mpi-infrastructure` | Infrastructure configuration and provisioning |
| **CI Workflows** | `mpimedia/mpi-application-workflows` | Shared reusable GitHub Actions workflows |
| **.github** | `mpimedia/.github` | Organization-level GitHub configuration |

## Tech Stack

Ruby / Rails / PostgreSQL / Hotwire (Turbo + Stimulus) / Bootstrap 5.3 / ViewComponent / esbuild / Sass. See `.tool-versions`, `Gemfile`, and `package.json` for exact versions.

## Commands

```bash
bin/dev                                # Rails server only
foreman start -f Procfile.development  # Full dev stack (web, js, css, worker)
bundle exec rspec                      # All tests
bundle exec rspec spec/models/user_spec.rb:42  # Single line
bundle exec rubocop -a                 # Lint + auto-correct
bin/brakeman                           # Security scan
bin/bundler-audit                      # Vulnerable dependencies
```

## Pre-Commit Requirements

**All must pass before committing:**

1. `bundle exec rubocop -a` — zero offenses
2. `bundle exec rspec` — zero failures
3. `bin/brakeman --no-pager -q` — no warnings
4. `bin/bundler-audit check` — no vulnerabilities

## Testing

- RSpec with FactoryBot (never fixtures)
- Request specs for controllers (not controller specs)
- Minimize mocks — use real objects
- **Permission strategy:** Policy specs use real permission records; request specs stub Pundit; feature specs use `authorized_admin_setup`; component/model/job specs need no permission setup.
- See `docs/standards/testing.md` for full conventions

## Asset Pipeline

Two completely separate pipelines — admin and public:

| Pipeline | JS Entry | CSS Entry | Layout | Route Prefix |
|----------|----------|-----------|--------|--------------|
| Admin | `app/javascript/admin/index.js` | `app/assets/stylesheets/admin.scss` | `admin.html.erb` | `/admin/` |
| Public | `app/javascript/public/index.js` | `app/assets/stylesheets/public.scss` | `application.html.erb` | `/` |

Stimulus controllers are pipeline-specific (`admin/controllers/` vs `public/controllers/`). Each pipeline creates its own independent Stimulus Application instance. Admin imports Bootstrap JS + Tom Select; public does not.

## Architecture

| Concern | Admin | Public | API |
|---------|-------|--------|-----|
| Base Controller | `AdminController` | `ApplicationController` | `ApiController` |
| Auth | Devise + Pundit | Devise | JWT Bearer |
| Routes | `namespace :admin` | Root-level | `namespace :api / :v1` |
| Components | `app/components/admin/` | `app/components/` (shared) | N/A |

Key patterns — read the code and docs for details:
- **Authorization**: Pundit with `User → SystemGroups → SystemRoles → SystemPermissions`. Every admin action must call `authorize`.
- **Forms**: tom-select for selects (`wrapper: :tom_select_label_inset`), floating labels for text (`wrapper: :floating_label_form`)
- **Models**: Include concerns `Archivable` (soft delete), `Loggable` (audit trail), `Notifiable` (events)
- **Enumerables**: Module in `app/modules/` + concern in `app/models/concerns/`
- **Jobs**: GoodJob (Postgres-backed, no Redis)

See `docs/architecture/overview.md` for full details.

## Anti-Patterns (Never Do)

- Never suggest React, Vue, or other JS frameworks — Hotwire (Turbo + Stimulus) only
- Never use inline JavaScript — Stimulus controllers only
- Never use fixtures — FactoryBot only
- Never use controller specs — request specs only
- Never hard-delete archivable records — use `archive!` / `unarchive!`
- Never add a global `master.key` or `credentials.yml.enc` — per-environment credentials only
- Never skip `authorize` in admin controller actions
- Never use Redis for background jobs — GoodJob is Postgres-backed
- Never mix admin and public assets — separate pipelines, separate Stimulus controllers
- Never hardcode permission checks — use Pundit policies and `access_authorized?`
- Never use `policy_scope` without defining `ransackable_attributes` — Ransack exposes fields
- Never use `default_scope` — use named scopes
- Always prefer Rails per-environment credentials over `ENV` for application secrets and configuration — `ENV` is acceptable for platform/runtime vars (`DATABASE_URL`, `PORT`, `RAILS_ENV`) set by the deployment environment
- Never add React, Vue, Alpine.js, Angular, or other SPA/component frameworks — use Stimulus, Hotwire, and native JS (utility libraries like Bootstrap JS and Tom Select are fine)
- Never disable Brakeman or Bundler-Audit warnings without a documented justification comment (`# brakeman:disable Reason — Approved by [name] on [date]`)

## Review Guidelines

### P0 — Must Fix
- Security vulnerabilities (SQL injection, XSS, missing authorization)
- Missing `authorize` call in admin controller actions
- Broken tests or tests that don't test what they claim
- Credentials or secrets in code
- Data loss risks (irreversible migrations, missing `dependent:`)

### P1 — Should Fix
- N+1 queries (use `includes` / `eager_load`)
- Missing validations for required business constraints
- Pattern violations (architecture, naming, structure)
- Missing tests for new functionality

### P2 — Consider
- Naming improvements
- Performance optimizations
- Additional edge case coverage

## Multi-Agent Coordination

- **File ownership is exclusive** — no two agents modify the same file simultaneously
- **Shared interfaces defined upfront** — method signatures, model attributes, route paths
- **Migrations belong to one agent** — typically the model/data stream
- **One agent handles integration** — merges streams, runs full test suite, creates PR

See `docs/architecture/agent-workflow.md` for full patterns.

## Agent Attribution (Required — No Exceptions)

Every AI agent **must** include attribution on all work:

- **Commits**: `Co-Authored-By: Agent Name <email>` trailer
- **PRs**: Agent name in description footer
- **Comments**: Attribution line (e.g., `— Claude Code (Opus 4.5)` or `— GitHub Copilot`)

If multiple agents contribute, include a `Co-Authored-By` line for each.

## PR Instructions

- PR title: under 70 characters, descriptive
- PR body: Summary, Changes Made, Technical Approach, Testing, Checklist
- Link to issue: `Closes #NNN` or `Part of #NNN`

## Documentation

Standards and architecture docs are in `docs/`. Key references:
- `docs/standards/testing.md` — Test conventions
- `docs/standards/code-review.md` — Review checklist
- `docs/standards/style.md` — Naming and formatting
- `docs/architecture/overview.md` — Full architecture
- `docs/system_permissions.md` — Authorization system
- `docs/notification_system.md` — Notification system
