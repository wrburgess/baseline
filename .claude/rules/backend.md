# Backend Rules

Applies to: `app/models/`, `app/controllers/`, `app/modules/`, `app/jobs/`

## Rails Ecosystem First

Before building any custom solution, research whether Rails conventions, established gems, or engines already solve the problem. The Rails ecosystem's strength is battle-tested, community-maintained solutions.

- **Check Rails built-ins first** — ActiveRecord callbacks, concerns, validations, enums, delegations, STI, polymorphic associations. Don't build what Rails already provides.
- **Check established gems second** — search RubyGems, Ruby Toolbox, and community recommendations. Prefer gems with active maintenance, strong test suites, and wide adoption.
- **Build custom only when justified** — if no existing solution fits, explain why in the assessment/plan. "I couldn't find a gem for this" is acceptable. "I didn't look" is not.
- **During `/assess` and `/cplan`** — explicitly list gems and Rails patterns considered for the solution, even if rejected. This shows due diligence and gives the HC options.

### Gem Preferences

When multiple gems solve the same problem, use these:

| Problem | Use | Not |
|---------|-----|-----|
| Testing | RSpec, FactoryBot, Shoulda-matchers | Minitest, fixtures |
| Background jobs | GoodJob (Postgres-backed) | Sidekiq, Solid Queue, Redis-backed |
| Authorization | Pundit | CanCanCan, Action Policy |
| Authentication | Devise | Sorcery, Clearance |
| Search/filter | Ransack | pg_search (unless full-text needed) |
| Forms | Simple Form | Formtastic, default Rails forms |
| Pagination | Pagy | Kaminari, will_paginate |
| Components | ViewComponent | Draper, Cells |
| Serialization | Jbuilder | AMS, Blueprinter, JSONAPI::Serializer |
| File uploads | Active Storage | CarrierWave, Shrine |
| Admin views | Custom (Bootstrap 5 + Hotwire) | ActiveAdmin, Administrate, Trestle |

## Authorization

- Every admin controller action must call `authorize`
- Use Pundit policies and `access_authorized?` — never hardcode permission checks
- Authorization chain: `User → SystemGroups → SystemRoles → SystemPermissions`
- Define `ransackable_attributes` when using `policy_scope` — Ransack exposes fields

## Models

- Use `archive!` / `unarchive!` for soft-delete — never `destroy` on archivable records
- Include `Loggable` concern for audit trails on new models
- Enumerable pattern: module in `app/modules/`, concern in `app/models/concerns/`
  - Reference: `app/modules/notification_distribution_methods.rb`

## Controllers

- Admin controllers inherit from `AdminController` (Devise + Pundit)
- Public controllers inherit from `ApplicationController` (Devise)
- API controllers inherit from `ApiController` (JWT Bearer)
- Routes: admin under `namespace :admin`, API under `namespace :api / :v1`

## Background Jobs

- GoodJob only (Postgres-backed) — never Redis
- See `docs/architecture/overview.md` for job patterns

## Forms (Admin)

- Select inputs: `tom_select` (`as: :tom_select`, `wrapper: :tom_select_label_inset`)
- Text/textarea: `wrapper: :floating_label_form`
- Booleans: `wrapper: :custom_boolean_switch`
- Dates: `wrapper: :datepicker`
- Wrap in `simple_form_for([:admin, instance])`
- Two-column layout: `row > col-12 col-lg-6`
- Reference: `app/views/admin/system_groups/_form.html.erb`

## Credentials

- Per-environment only — never add a global `master.key` or `credentials.yml.enc`

## Anti-Patterns

- Never use `default_scope` — use named scopes instead
- Prefer `find_each` for large result sets (100+ records) — avoid `.all.each` on entire tables
- Prefer preloaded data or counter caches over `.count` in loops
- Never add service object gems (Interactor, Trailblazer, Dry-Transaction) — use plain Ruby in `app/services/` if needed
- Never add serializer gems (AMS, Blueprinter) — prefer jbuilder
- Never add decorator gems (Draper) — use ViewComponent
