# Getting Started

This guide walks you through setting up the Baseline development environment from scratch.

## Prerequisites

- **Ruby** — version per `.tool-versions` (currently `4.0.2`; use [mise](https://mise.jdx.dev/) to manage)
- **PostgreSQL** — version per `.tool-versions` (currently `18.3`)
- **Node.js** — version per `.tool-versions` (currently `25.9.0`)
- **Yarn** — version per `.tool-versions` (currently `4.13.0`)
- **1Password CLI** (optional) — used by `bin/setup-credentials` to fetch Rails credential keys automatically

Install mise to manage all runtime versions:

```bash
brew install mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc && source ~/.zshrc
mise install   # installs all runtimes from .tool-versions
```

## First-Time Setup

```bash
# 1. Clone the repo
git clone git@github.com:wrburgess/baseline.git
cd baseline

# 2. Install gems and JS packages
bundle install
yarn install

# 3. Fetch Rails credential keys (requires 1Password CLI + BASELINE_OP_ACCOUNT env var)
bin/setup-credentials

# 4. Create and migrate the database
bin/rails db:create db:migrate db:seed
```

If you don't have 1Password CLI, manually place the development key at
`config/credentials/development.key` — ask a team member for the value.

## Running the App

```bash
bin/dev    # starts web server, JS/CSS watchers, and GoodJob background processor
```

Visit [http://localhost:8000](http://localhost:8000).

## Running Tests

```bash
bundle exec rspec                          # full suite
bundle exec rspec spec/models/             # single directory
bundle exec rspec spec/models/user_spec.rb # single file
```

Run all quality checks before committing:

```bash
bundle exec rubocop -a       # lint + auto-correct
bundle exec rspec             # tests
bin/brakeman --no-pager -q    # security scan
bin/bundler-audit check       # dependency audit
```

## Where to Go Next

| Document | What It Covers |
|----------|----------------|
| [`docs/hc-guide.md`](hc-guide.md) | Development workflow, commands, PR review |
| [`CLAUDE.md`](../CLAUDE.md) | AI agent instructions and project conventions |
| [`AGENTS.md`](../AGENTS.md) | Universal agent guidelines |
| [`docs/standards/`](standards/) | Ruby, Rails, testing, and style conventions |
| [`docs/credentials_management.md`](credentials_management.md) | Managing per-environment secrets |
