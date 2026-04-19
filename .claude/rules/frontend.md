# Frontend Rules

Applies to: `app/javascript/`, `app/views/`, `app/components/`, `app/assets/`

## Framework

- Hotwire only (Turbo + Stimulus) — never React, Vue, or other JS frameworks
- Stimulus controllers only — never inline JavaScript
- ViewComponent for reusable UI components (`app/components/`)

## Dual Asset Pipelines

Optimus has **two separate pipelines** — admin and public. They do not share runtime Stimulus controllers or entry points.

| Pipeline | JS Entry | CSS Entry | Layout | Route Prefix |
|----------|----------|-----------|--------|--------------|
| Admin | `app/javascript/admin/index.js` | `app/assets/stylesheets/admin.scss` | `admin.html.erb` | `/admin/` |
| Public | `app/javascript/public/index.js` | `app/assets/stylesheets/public.scss` | `devise.html.erb` / `application.html.erb` | `/` |

Build outputs: `app/assets/builds/` (gitignored) — `admin.js`, `admin.css`, `public.js`, `public.css`.

## JavaScript Structure

```
app/javascript/
├── controllers/application.js          # (optional) shared Stimulus helpers/base config
├── admin/
│   ├── index.js                        # Imports Turbo, Bootstrap, Stimulus, admin controllers
│   └── controllers/                    # Admin-only Stimulus controllers
└── public/
    ├── index.js                        # Imports Turbo, Stimulus, public controllers
    └── controllers/                    # Public-only Stimulus controllers
```

- Each pipeline creates its own independent Stimulus `Application` instance
- Admin imports Bootstrap JS; public does not

## Stylesheets

- Both pipelines import Bootstrap and Bootstrap Icons
- Admin additionally imports Tom Select CSS
- Custom styles are minimal and pipeline-specific

## Component / Route Separation

| Concern | Admin | Public | API |
|---------|-------|--------|-----|
| Components | `app/components/admin/` | `app/components/` (shared) | N/A |
| Views | `app/views/admin/` | `app/views/static/`, `app/views/devise/` | JSON |
| Pagination | Pagy | — | — |
| Search/Filter | Ransack | — | — |

## Anti-Patterns

- Never add CSS frameworks beyond Bootstrap 5.3
- Never add inline styles in ERB templates — use Bootstrap utility classes or pipeline-specific stylesheets (exception: mailer templates require inline CSS for email client compatibility)

## Build

- `esbuild.config.js` builds both bundles in parallel
- `bin/dev` — Rails server only
- `foreman start -f Procfile.development` — Full dev stack (web, js, css, worker)
