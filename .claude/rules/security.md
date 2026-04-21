# Security Rules

Applies to: `app/`, `config/`, `lib/`

## Credentials

- Always prefer Rails per-environment credentials as the primary source for application secrets
- `ENV` is acceptable as a fallback when credentials are the primary source (e.g., `ENV["X"] || Rails.application.credentials.dig(:x)`)
- `ENV` is acceptable for platform/runtime vars (`DATABASE_URL`, `PORT`, `RAILS_ENV`, `REVIEW`) set by the deployment environment
- Never add a global `master.key` or `credentials.yml.enc` — per-environment only

## Scanning

- Never disable Brakeman or Bundler-Audit warnings without a documented justification comment (`# brakeman:disable Reason — Approved by [name] on [date]`)
- Never commit secrets, API keys, or tokens to the repository
