# Getting Started

This guide walks you through setting up the Optimus development environment from scratch after cloning the repository.

## Prerequisites

You need a Mac with [Homebrew](https://brew.sh/) installed. All other dependencies are managed by mise.

You also need access to the **"Application Development" vault** on `mpimediagroup.1password.com` in 1Password. This vault holds all credential items used by `bin/setup-credentials` and `bin/setup-mcp`.

## 1. Install mise

[mise](https://mise.jdx.dev/) manages Ruby, Node.js, PostgreSQL, and Yarn versions for the project.

```bash
brew install mise
```

Add mise to your shell (pick one):

```bash
# zsh
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc && source ~/.zshrc

# bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc && source ~/.bashrc
```

## 2. Install 1Password CLI

The 1Password CLI is used to fetch Rails credentials keys, Honeybadger CLI config, and (optionally) MCP server API keys.

```bash
brew install --cask 1password-cli
```

Then in the 1Password desktop app, go to **Settings > Developer > Integrate with 1Password CLI** and enable it. You need access to the "Application Development" vault on `mpimediagroup.1password.com`.

## 3. Install Honeybadger CLI

The Honeybadger CLI (`hb`) is used to manage error monitoring for the project. `bin/setup-credentials` configures it automatically.

```bash
brew install honeybadger-io/tap/honeybadger
```

Once installed, use `bin/hb` (the project-local wrapper) rather than `hb` directly — it automatically points to the project's `.honeybadger-cli.yaml`.

## 4. Start PostgreSQL

If you installed PostgreSQL via mise, start the server:

```bash
pg_ctl start
```

The app expects a `postgres` user with password `postgres` on localhost:5432. Create the role if it doesn't exist:

```bash
createuser -s postgres
psql -U postgres -c "ALTER USER postgres PASSWORD 'postgres';"
```

## 5. Run setup

```bash
bin/setup
```

This single command handles everything:

1. **Checks prerequisites** — Warns if mise or 1Password CLI are missing
2. **Installs runtimes** — Runs `mise install` (Ruby, Node.js, PostgreSQL, Yarn)
3. **Fetches credentials** — Runs `bin/setup-credentials` to get the development key from 1Password and configure the Honeybadger CLI
4. **Installs gems** — Runs `bundle install`
5. **Prepares database** — Runs `db:prepare` (creates, migrates, and seeds)
6. **Installs git hooks** — Configures `.githooks/` for branch protection
7. **Clears logs/tmp** — Removes old logs and temp files
8. **Starts dev server** — Launches `bin/dev`

Use `bin/setup --skip-server` to do everything except start the dev server.
Use `bin/setup --reset` to reset the database (`db:reset`) during setup.

### What gets seeded

`db:seed` creates the core records every environment needs:
- System user (default admin account)
- System permissions (standard CRUD and admin operations)
- Notification topics (default event topics)

### Git hooks

The setup installs hooks from the `.githooks/` directory:
- **pre-commit** — Branch protection checks
- **pre-merge-commit** — Prevents commits to main
- **pre-push** — Validates branch rules
- **pre-rebase** — Prevents rebase on main

## 6. Verify everything works

Run the full quality check suite:

```bash
bundle exec rubocop        # Linting
bundle exec rspec          # Tests
bin/brakeman --no-pager -q # Security scan
bin/bundler-audit check    # Dependency audit
```

All four must pass before any commit or push. This is enforced by CI.

Start the development server (if you used `--skip-server`):

```bash
bin/dev
```

This starts four processes (defined in `Procfile.development`):
- **Web** — Rails server on port 8000
- **JS** — esbuild watcher
- **CSS** — Sass watcher
- **Worker** — GoodJob background processor

Visit [http://localhost:8000](http://localhost:8000) to confirm the app is running.

## Claude Code Setup (Optional)

If you use [Claude Code](https://claude.com/claude-code), there are a few additional steps.

### MCP servers

The MCP configuration has been optimized to include only servers that provide unique value over CLI tools. See `docs/architecture/mcp-integration-audit.md` for the full rationale.

```bash
bin/setup-mcp            # Fetch Cloudflare + Honeybadger credentials from 1Password
bin/setup-mcp --dry-run  # Preview which credentials would be fetched
```

This writes `.mcp.json` with Cloudflare (Code Mode) and Honeybadger servers. For GitHub, Heroku, DigitalOcean, and AWS, use their respective CLI tools (`gh`, `heroku`, `doctl`, `aws`) which provide equivalent functionality with lower context overhead. Context7 is provided by the Claude Code plugin.

### Required plugins

Install the Context7 plugin for up-to-date library documentation:

```bash
claude plugin install context7@claude-plugins-official
```

This replaces the Context7 MCP server that was previously in `.mcp.json`. The plugin is superior because it auto-triggers on library/framework questions.

### Ruby LSP plugin (optional)

Install the Solargraph plugin for real-time code intelligence:

```bash
gem install solargraph
claude plugin marketplace add boostvolt/claude-code-lsps
claude plugin install solargraph@claude-code-lsps
```

Add to your shell profile:

```bash
echo 'export ENABLE_LSP_TOOL=1' >> ~/.zshrc && source ~/.zshrc
```

### Personal settings

The shared `.claude/settings.json` applies automatically. Create `.claude/settings.local.json` (gitignored) for personal preferences like extended Bash permissions or MCP server access.

## Creating a New Project from Optimus

When creating a new MPI project from this template, provision the following items in the **"Application Development" vault** on `mpimediagroup.1password.com`:

| Item Name | Fields |
|-----------|--------|
| `{AppName} Production Honeybadger` | `api_key`, `project_id` |
| `{AppName} Staging Honeybadger` | `api_key`, `project_id` |

The shared `Honeybadger Auth Token` item is already provisioned and works across all projects — no action needed.

After provisioning, update `HB_PRODUCTION_ITEM` in `bin/setup-credentials` to match the new item name (e.g., `"MyApp Production Honeybadger"`).

## Quick Reference

```bash
# Development
bin/dev                                # Start dev server (port 8000)
bin/rails console                      # Rails REPL
bin/rails db:migrate                   # Run pending migrations
bin/rails db:seed                      # Reload seed data

# Testing
bundle exec rspec                      # All tests
bundle exec rspec spec/models/         # Directory
bundle exec rspec spec/models/user_spec.rb      # Single file
bundle exec rspec spec/models/user_spec.rb:42   # Single line
CI=true bundle exec rspec              # With coverage report

# Quality checks (required before every commit)
bundle exec rubocop -a                 # Lint + auto-correct
bundle exec rspec                      # Tests
bin/brakeman --no-pager -q             # Security scan
bin/bundler-audit check                # Dependency audit

# Assets
yarn build                             # Build JS
yarn build:css                         # Build CSS

# Credentials
bin/setup-credentials                  # Fetch development key + configure Honeybadger CLI
bin/setup-credentials --all            # Fetch all environment keys + configure Honeybadger CLI
bin/rails credentials:edit --environment development
bin/rails credentials:show --environment development

# Honeybadger CLI
bin/hb deploy                          # Record a deployment
bin/hb notifications                   # Manage notification settings
bin/hb help                            # Full command reference

# Background jobs
bundle exec good_job start
```

## Admin Dashboards

Once running, these are available under `/admin/`:

| Path                  | Purpose                              |
|-----------------------|--------------------------------------|
| `/admin/blazer`       | SQL query builder                    |
| `/admin/good_job`     | Background job dashboard             |
| `/admin/maintenance_tasks` | Data maintenance scripts        |
| `/admin/pghero`       | Database performance monitoring      |
| `/admin/lookbook`     | ViewComponent previews (dev/staging) |

## Further Reading

- [Architecture Overview](architecture/overview.md)
- [HC Guide](hc-guide.md) — Development workflow for human contributors
- [Testing Standards](standards/testing.md) — RSpec conventions and patterns
- [Credentials Management](credentials_management.md) — Multi-environment secrets
- [System Permissions](system_permissions.md) — Authorization system
- [Notification System](notification_system.md) — Event-driven notifications
