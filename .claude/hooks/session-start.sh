#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web (remote sandbox).
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo "[session-start] repo: $(pwd)"

# --- Ruby ---------------------------------------------------------------
# Install the Ruby version from .ruby-version via rbenv (if both present).
if [ -f .ruby-version ] && command -v rbenv >/dev/null 2>&1; then
  RUBY_VERSION_FILE="$(tr -d '[:space:]' < .ruby-version)"
  echo "[session-start] ensuring ruby $RUBY_VERSION_FILE via rbenv"
  rbenv install -s "$RUBY_VERSION_FILE" || echo "[session-start] rbenv install failed; continuing with system ruby"
  rbenv rehash || true
fi

# --- Node ---------------------------------------------------------------
# Install the Node version from .nvmrc via nvm (if both present).
if [ -f .nvmrc ] && [ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
  echo "[session-start] ensuring node $(cat .nvmrc) via nvm"
  nvm install
fi

# --- Ruby gems ----------------------------------------------------------
if [ -f Gemfile ]; then
  echo "[session-start] bundle install"
  gem install bundler --conservative >/dev/null
  bundle config set --local path 'vendor/bundle'
  bundle install --jobs=4 --retry=3
fi

# --- JS deps ------------------------------------------------------------
if [ -f package-lock.json ]; then
  echo "[session-start] npm install"
  npm install --no-audit --no-fund
elif [ -f yarn.lock ]; then
  echo "[session-start] yarn install"
  corepack enable >/dev/null 2>&1 || true
  yarn install --frozen-lockfile || yarn install
elif [ -f pnpm-lock.yaml ]; then
  echo "[session-start] pnpm install"
  corepack enable >/dev/null 2>&1 || true
  pnpm install --frozen-lockfile || pnpm install
elif [ -f package.json ]; then
  echo "[session-start] npm install (no lockfile)"
  npm install --no-audit --no-fund
fi

echo "[session-start] done"
