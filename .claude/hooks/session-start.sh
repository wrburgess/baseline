#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web (remote sandbox).
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo "[session-start] repo: $(pwd)"

# --- mise ---------------------------------------------------------------
# Install mise if missing, then use it to provision Ruby/Node from
# .mise.toml / .tool-versions / .ruby-version / .nvmrc.
export MISE_INSTALL_PATH="${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}"
export PATH="$HOME/.local/bin:$PATH"

if ! command -v mise >/dev/null 2>&1; then
  echo "[session-start] installing mise"
  curl -fsSL https://mise.run | sh
fi

if command -v mise >/dev/null 2>&1; then
  # Trust repo's mise config so mise install won't prompt.
  for f in .mise.toml mise.toml .tool-versions; do
    [ -f "$f" ] && mise trust "$f" >/dev/null 2>&1 || true
  done

  if [ -f .mise.toml ] || [ -f mise.toml ] || [ -f .tool-versions ] || [ -f .ruby-version ] || [ -f .nvmrc ]; then
    echo "[session-start] mise install"
    mise install
  fi

  # Shim mise-managed tools onto PATH for the rest of this script.
  eval "$(mise env -s bash 2>/dev/null || true)"

  # Persist mise activation for the session.
  if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$CLAUDE_ENV_FILE"
    echo 'eval "$(mise activate bash)"' >> "$CLAUDE_ENV_FILE"
  fi
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
