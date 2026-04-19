# Agent Roles & Knowledge Domains

Parent epic: [#225 — Optimizing AI Contributions](https://github.com/mpimedia/optimus/issues/225)
Issue: [#226 — Define and organize AI agent roles and knowledge domains](https://github.com/mpimedia/optimus/issues/226)

---

## Overview

### AC vs HC Roles

AI Contributors (ACs) don't map 1:1 to Human Contributors (HCs). An HC designer and an HC developer are different people with different skills. An AC can span multiple domains in a single session. The organizational structure below optimizes for how ACs actually work — loading focused context per task — rather than mirroring HC org charts.

**Roles are contexts, not agents.** Each role represents a set of knowledge domains and conventions that get loaded into the same underlying agent (Claude Code, Codex, etc.) depending on what task is being performed. A single session may activate multiple roles.

### Construct Mapping Strategy

Role knowledge maps to Claude Code constructs based on two dimensions. This describes the **current architecture** for #228/#229, implemented in Optimus via `.claude/rules/` and `.claude/commands/`.

| Dimension | Construct | When Loaded | Example |
|-----------|-----------|-------------|---------|
| **Where you are** (file context) | `.claude/rules/` (path-scoped) | Automatically when matching files are active | Backend rules load when editing `app/models/` |
| **What you're doing** (task context) | `.claude/commands/` (skills) | On demand when skill is invoked | `/impl` loads implementation workflow |
| **Always needed** (universal) | `CLAUDE.md` (hot memory) | Every session, on boot | Anti-patterns, required workflow, tech stack |
| **Reference material** (deep detail) | `docs/` (cold memory) | On demand via `@import` or agent exploration | Architecture guides, system docs |

This aligns with research findings:
- **F5.1:** Three-tier memory architecture (hot/warm/cold)
- **F5.4:** Path-scoped rules enable domain-specific guidance without token bloat
- **F5.3:** Domain knowledge should be machine-readable specs, not prose

### Shared Knowledge Baseline

Every role inherits this baseline understanding:

- **MPI Application Suite** — All 10 projects, their repos, relationships, and roles (see `.claude/projects.json` and `docs/architecture/overview.md`)
- **Development workflow** — The command-driven process (`/revi → /cplan → /impl → /rtr → /final`) per `docs/architecture/agent-workflow.md`
- **Quality gates** — rubocop, rspec, brakeman, bundler-audit must pass before commit (per `CLAUDE.md`)
- **Agent attribution** — Required on all commits, PRs, and comments (per `CLAUDE.md`)
- **Anti-patterns** — The "Never Do" list (per `CLAUDE.md`)
- **Performance awareness** — All dev roles carry baseline performance consciousness (query efficiency, N+1 avoidance, caching awareness)
- **Security awareness** — OWASP top 10, Brakeman compliance, credential handling

---

## Role Registry

### 1. Product Manager

**Status:** Deferred to #233 (Tier 4)

**Purpose:** Accumulate and maintain MPI business domain knowledge so ACs can make informed product decisions without constant HC consultation.

**Knowledge Domains:**
- Television and film distribution business
- Royalty accounting, reporting, and tracking
- Distribution rights and contracts
- Customer relationship management
- Theatre booking and screening request management
- Stock footage clip management
- Vimeo OTT management
- Title and episode content management
- Website content management
- Business knowledge: Watermelon Pictures, Dark Sky Films, MPI Home Video, MPI Media

**Construct Mapping:**
- Memory files (`~/.claude/projects/*/memory/`) — Persistent business context accumulated over time
- Shared business context layer — Cross-repo domain definitions (per F5.6)
- Skills — For business-domain queries and product decision support

**Cross-Repo Applicability:** All MPI applications (each app serves a business domain)

**Relationship to Other Roles:** Informs all roles with business context. Frontend/Backend developers need product understanding to make implementation decisions.

---

### 2. Front End Designer

**Purpose:** UI/UX design decisions, visual consistency, accessibility compliance, and design system stewardship.

**Knowledge Domains:**
- User interface design principles
- Bootstrap 5 component library and customization
- Responsive design patterns
- Atomic design principles
- Accessibility compliance (WCAG)
- MPI Design System (`mpimedia/mpi-design-system`)
- Color, typography, and spacing conventions
- Tom-select input styling (admin pipeline)

**Construct Mapping:**
- Path-scoped rules: `app/components/` — ViewComponent design patterns
- Path-scoped rules: `app/assets/stylesheets/` — CSS/Sass conventions
- Skill: Design audit / review (triggered, not always-loaded)
- Reference: `docs/standards/design.md`

**Cross-Repo Applicability:** Apps with UI — Optimus, Markaz, SFA, Harvest, Garden

**Relationship to Other Roles:** Collaborates with Frontend Developer. Designer decides *what it looks like*; Frontend Developer decides *how to build it*. In AC context, these may activate in the same session but load different rules.

---

### 3. Frontend Developer

**Purpose:** Implement UI using Hotwire (Turbo + Stimulus), ViewComponent, and the MPI asset pipeline architecture.

**Knowledge Domains:**
- Ruby (ERB templates)
- JavaScript (Stimulus controllers)
- HTML semantics
- ViewComponent gem patterns
- Bootstrap 5 component usage
- Stimulus controller architecture
- Turbo Frames and Turbo Streams
- Hotwire patterns (per `docs/standards/hotwire-patterns.md`)
- Admin vs public asset pipeline separation
- esbuild configuration
- Node/Yarn tooling
- MPI Design System integration

**Construct Mapping:**
- Path-scoped rules: `app/javascript/admin/` — Admin Stimulus controllers, Bootstrap JS, tom-select
- Path-scoped rules: `app/javascript/public/` — Public Stimulus controllers (no Bootstrap JS)
- Path-scoped rules: `app/views/` — ERB conventions, partial patterns
- Path-scoped rules: `app/components/` — ViewComponent patterns
- Reference: `docs/standards/hotwire-patterns.md`, `docs/asset_pipeline.md`

**Cross-Repo Applicability:** Apps with UI — Optimus, Markaz, SFA, Harvest, Garden

**Relationship to Other Roles:** Implements designs from Front End Designer. Works alongside Backend Developer for controller/view integration.

---

### 4. Backend Developer

**Purpose:** Server-side Ruby on Rails development including models, controllers, API endpoints, database design, and business logic.

**Knowledge Domains:**
- Ruby (idiomatic patterns)
- Ruby on Rails framework
- PostgreSQL (queries, migrations, indexes)
- Devise (authentication)
- Pundit (authorization — policies, system permissions)
- Ransack (search/filter in admin)
- Pagy (pagination)
- GoodJob (background jobs — Postgres-backed, not Redis)
- Searchkick / Elasticsearch
- Maintenance Tasks gem
- Strong Migrations (safe migration patterns)
- API development (JWT Bearer auth, JSON serialization)
- MCP development
- Archivable / Loggable / Notifiable concerns
- Enumerable pattern (`app/modules/`)

**Construct Mapping:**
- Path-scoped rules: `app/models/` — Associations, validations, concerns, scopes
- Path-scoped rules: `app/controllers/admin/` — Pundit `authorize`, Pagy, Ransack, `ransackable_attributes`
- Path-scoped rules: `app/controllers/api/` — JWT auth, serialization patterns
- Path-scoped rules: `db/migrate/` — Strong Migrations, safe migration patterns
- Reference: `docs/system_permissions.md`, `docs/system_permissions_agent_guide.md`
- Reference: `docs/notification_system.md`, `docs/notification_system_agent_guide.md`
- Reference: `docs/standards/query-patterns.md`, `docs/standards/caching.md`

**Cross-Repo Applicability:** All Rails apps — Optimus, Markaz, SFA, Harvest, Markaz CRM

**Relationship to Other Roles:** Core implementation role. Frontend Developer depends on controller actions and view data. Testing & QA validates backend behavior.

---

### 5. Testing & QA

**Purpose:** Ensure code quality through automated testing, code review, and quality gate enforcement.

**Knowledge Domains:**
- RSpec (request specs, model specs, policy specs, feature specs, job specs)
- Capybara (feature/integration tests)
- FactoryBot (test data — never fixtures)
- Shared contexts (`policy_setup`, `authorized_admin_setup`)
- SimpleCov (coverage tracking, 90% target)
- RuboCop (style enforcement)
- Brakeman (security scanning)
- Bundler Audit (dependency vulnerabilities)
- GitHub Actions CI/CD
- Pull request review (P0/P1/P2 severity levels)
- End-to-end testing patterns

**Construct Mapping:**
- Path-scoped rules: `spec/` — RSpec conventions, shared context usage, FactoryBot patterns
- Path-scoped rules: `spec/requests/` — Request spec patterns (not controller specs)
- Path-scoped rules: `spec/policies/` — Policy spec patterns with real permission records
- Skills: Review skills (`/rtr`, `/final`) — triggered during review workflow
- Reference: `docs/standards/testing.md`, `docs/standards/code-review.md`

**Cross-Repo Applicability:** All apps

**Relationship to Other Roles:** Validates work from all developer roles. Codex serves as the primary automated reviewer; Claude Code writes tests during implementation.

---

### 6. Infrastructure

**Purpose:** Deployment, hosting, CI/CD pipelines, and infrastructure provisioning.

**Knowledge Domains:**
- Kamal (deployment)
- Terraform (infrastructure as code)
- DigitalOcean (droplets, databases, spaces)
- AWS S3, IAM, SNS, CloudFront
- Cloudflare (DNS, caching, Turnstile, API)
- GitHub Actions (CI/CD workflows)
- Coolify (application hosting)
- Docker / containerization
- SSL/TLS certificate management
- `mpimedia/mpi-infrastructure` repo
- `mpimedia/mpi-application-workflows` repo

**Construct Mapping:**
- Skill: Infrastructure / deployment operations (triggered, not always-loaded)
- Skill: `db-health` diagnostic
- Reference: `docs/deployment.md`, `docs/architecture/mpi-infrastructure.md`

**Cross-Repo Applicability:** All apps (deployment), plus dedicated `mpi-infrastructure` and `mpi-application-workflows` repos

**Relationship to Other Roles:** Supports all developer roles with deployment and CI. Backend Developer depends on infrastructure for database and service configuration.

---

### 7. External Services

**Purpose:** Integration with third-party APIs and external service providers.

**Knowledge Domains:**
- Postmark API (email delivery)
- Elasticsearch / Searchkick
- Trello API
- Cloudflare Turnstile (bot protection)
- Cloudflare API
- AWS S3 / Azure Storage / Dropbox (file storage)
- Microsoft SharePoint
- DigitalOcean API
- MS Dynamics Business Central API
- Mailchimp API
- Stripe API (payments)
- Vimeo OTT API
- Getty Enterprise Submission Portal (ESP) API

**Construct Mapping:**
- Skills: Per-service integration skills (loaded only when working with that service)
- Reference: Service-specific docs as needed (external API docs via Context7/MCP)

**Cross-Repo Applicability:** Varies by app and service:
- Stripe → Harvest
- Vimeo OTT → SFA, Markaz
- Getty ESP → SFA
- Postmark → All apps with email
- Elasticsearch → Optimus, Markaz, SFA
- MS Dynamics → Markaz

**Relationship to Other Roles:** Backend Developer implements integrations; External Services provides API-specific knowledge and patterns.

---

### 8. Digital Presence Optimization

**Purpose:** SEO, AI/LLM discoverability, and platform visibility for public-facing MPI properties.

**Knowledge Domains:**
- Traditional SEO (meta tags, sitemaps, structured data)
- AI/LLM discoverability (schema.org, llms.txt, structured content)
- Social and platform visibility (Open Graph, Twitter Cards)
- Google Search Console patterns
- Core Web Vitals optimization
- Accessibility as SEO factor

**Construct Mapping:**
- Skill: DPO audit / optimization (triggered for public-facing work)
- Path-scoped rules: `app/views/static/` — Public page SEO patterns (if applicable)
- Reference: DPO standards doc (to be created)

**Cross-Repo Applicability:** Public-facing apps — Garden, Harvest, SFA

**Relationship to Other Roles:** Frontend Developer implements DPO recommendations. Backend Developer handles structured data and sitemap generation.

---

## Construct Mapping Summary

### Path-Scoped Rules (`.claude/rules/`)

The starter set (`backend.md`, `testing.md`, `migrations.md`, `frontend.md`) is implemented. Additional rule files are tracked for future iterations.

| Proposed Rule File | Path Scope | Roles Served | Key Content |
|-----------|------------|--------------|-------------|
| `admin-controllers.md` | `app/controllers/admin/` | Backend Developer | Pundit, Pagy, Ransack, ransackable_attributes |
| `api-controllers.md` | `app/controllers/api/` | Backend Developer | JWT auth, serialization |
| `models.md` | `app/models/` | Backend Developer | Associations, validations, concerns, scopes |
| `migrations.md` | `db/migrate/` | Backend Developer | Strong Migrations, safe patterns |
| `admin-js.md` | `app/javascript/admin/` | Frontend Developer | Bootstrap JS, tom-select, admin Stimulus |
| `public-js.md` | `app/javascript/public/` | Frontend Developer | Public Stimulus (no Bootstrap JS) |
| `views.md` | `app/views/` | Frontend Developer, Designer | ERB conventions, partial patterns |
| `components.md` | `app/components/` | Frontend Developer, Designer | ViewComponent patterns |
| `stylesheets.md` | `app/assets/stylesheets/` | Designer | Sass conventions, Bootstrap customization |
| `specs.md` | `spec/` | Testing & QA | RSpec, FactoryBot, shared contexts |
| `request-specs.md` | `spec/requests/` | Testing & QA | Request spec patterns |
| `policy-specs.md` | `spec/policies/` | Testing & QA | Policy specs with real permissions |

**Token budget:** Each rule file should be under 50 lines (per F5.4: total memory under 10,000 tokens). Target 4-8 active rule files per session.

### Skills (`.claude/commands/`)

| Skill Category | Roles Served | Examples |
|----------------|--------------|---------|
| Workflow | All | `/impl`, `/cplan`, `/rtr`, `/final`, `/revi` |
| Infrastructure | Infrastructure | Deployment, `db-health` |
| External Services | External Services | Per-service integration guides |
| Design | Designer | Design audit, accessibility check |
| DPO | Digital Presence Optimization | SEO audit, structured data check |
| Performance | All dev roles (specialist mode) | Performance audit, query analysis |

### CLAUDE.md (Always Loaded)

CLAUDE.md should contain **only** universal content needed every session:
- Anti-patterns (never do)
- Required workflow (quality gates)
- Agent attribution rules
- Tech stack summary
- Architecture pointers (as `@import` references to docs/)
- MPI ecosystem reference (pointer to `.claude/projects.json`)

Role-specific knowledge does **not** belong in CLAUDE.md — it belongs in path-scoped rules or skills.

---

## Cross-Repo Applicability Matrix

| Role | Optimus | Markaz | SFA | Garden | Harvest | CRM | Infra | CI | Design System | .github |
|------|---------|--------|-----|--------|---------|-----|-------|----|---------------|---------|
| Product Manager | Y | Y | Y | Y | Y | Y | — | — | — | — |
| Front End Designer | Y | Y | Y | Y | Y | — | — | — | Y | — |
| Frontend Developer | Y | Y | Y | Y | Y | — | — | — | Y | — |
| Backend Developer | Y | Y | Y | — | Y | Y | — | — | — | — |
| Testing & QA | Y | Y | Y | Y | Y | Y | Y | Y | Y | — |
| Infrastructure | Y | Y | Y | Y | Y | Y | Y | Y | — | Y |
| External Services | Y | Y | Y | — | Y | — | — | — | — | — |
| Digital Presence Opt. | — | — | Y | Y | Y | — | — | — | — | — |

**Legend:** Y = applicable, — = not applicable

**Notes:**
- Garden is a static site generator — Backend Developer may not apply (depends on tech stack)
- Design System repo is shared UI components — Designer and Frontend Developer are primary consumers
- .github is org-level config — only Infrastructure role applies

---

## Research References

This role registry is informed by the following validated findings from [docs/research/ai-best-practices.md](../research/ai-best-practices.md):

### Multi-Agent Workflows (Area 2)
- **F2.1 (High):** Deterministic workflow sequencing — roles activate via command-driven workflow, not self-directed
- **F2.2 (Medium):** Parallel worktree agents — roles can run in parallel with isolated contexts
- **F2.3 (High):** Three-tier quality gates — Testing & QA role enforces Tier 1 (blocking), Tier 2 (threshold), Tier 3 (regression)
- **F2.4 (Medium):** Review loop caps — max 3 iterations between implementer and reviewer roles
- **F2.5 (Medium):** Implementer-reviewer pattern — Claude implements, Codex/Copilot reviews; deterministic checks for routine work
- **F2.6 (High):** Complexity tracking — all roles contribute to monitoring agent-generated code quality

### Domain Knowledge & Institutional Memory (Area 5)
- **F5.1 (Medium):** Three-tier memory — CLAUDE.md (hot), .claude/rules/ (warm), docs/ (cold) maps to construct strategy
- **F5.3 (High):** Machine-readable specs — role knowledge encoded as structured rules, not prose
- **F5.4 (Medium):** Path-scoped rules — role context loads based on active files, not global config
