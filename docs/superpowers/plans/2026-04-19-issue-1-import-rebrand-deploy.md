# Baseline Issue #1 — Import Optimus Template, Rebrand, and Hello-World Deploy

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap Baseline from the `aaa/optimus-base` Rails template by importing it verbatim, rebranding every MPI/Optimus reference to Baseline, and deploying a hello-world instance to `https://baseline.kc.tennis` on DigitalOcean via Kamal.

**Architecture:** Three-phase work with two hard checkpoints between phases. Phase 1 is a single verbatim-copy commit so the rebrand diff in Phase 2 is the only delta. Phase 2 is decomposed into small commits by concern (structural renames, retention-list scrubs, doc deletions, UI/docs rewrites) for traceable review; if the issue's "one rebrand commit" rule matters more than granular diffs, squash at the end. Phase 3 is deploy-only work gated on external preconditions (DNS, droplet, registry) that the HC must confirm before execution.

**Tech Stack:** Rails 8.1, Ruby 3.4.7, PostgreSQL, Hotwire, Bootstrap 5.3, ViewComponent, esbuild, GoodJob, Pundit, RSpec, Kamal 2, DigitalOcean Droplet, Let's Encrypt.

---

## Preconditions & Open Decisions

**The HC must settle these BEFORE executing any phase.** Each decision is load-bearing for specific tasks downstream.

### Phase 1 decisions

- [ ] **P1.D1 — Source directory location.** Template lives at `/Users/wrburgess/Projects/aaa/optimus-base/` (confirmed: no `.git` subdirectory, plain directory). Target: `/Users/wrburgess/Projects/aaa/baseline/` (confirmed: git repo on `main`, only `README.md`, `.gitignore`, and `docs/{project-notes.md,spec.md}` present).
- [ ] **P1.D2 — Branch strategy.** Execute on a new `feature/issue-1-import-rebrand-deploy` branch off `main`, merge to `main` via PR at the end. **Do NOT commit directly to `main`** during execution.

### Phase 2 decisions (must settle before starting Phase 2)

- [ ] **P2.D1 — CI workflow coupling.** `.github/workflows/ci.yml` currently references `mpimedia/mpi-application-workflows/.github/workflows/ci-rails.yml@f00663fa9e97a7dafa18b276a6e483094116b98e`. Options:
  - **(A)** Copy the ci-rails.yml reusable workflow into Baseline's own `.github/workflows/` so Baseline has no cross-org dependency. **Recommended.**
  - **(B)** Keep the `uses:` reference. Faster, but Baseline CI breaks if mpimedia/mpi-application-workflows is renamed/deleted, and leaks the coupling we're trying to remove.
  - **(C)** Replace with an inline CI job authored fresh (rubocop + rspec + brakeman + bundler-audit).

  **Action required:** HC picks one before Phase 2 Task 2B runs.

- [ ] **P2.D2 — Ambiguous docs.** The issue's "Retention list" names 13 rule/standard files to keep-but-scrub; the "Delete" list names 2 files + "cross-repo setup sections." The following documents are in **neither list** and contain heavy MPI/ecosystem refs. HC must choose per-file: **keep-and-scrub**, **delete**, or **rewrite from scratch**.

  | File | MPI refs | Recommendation |
  |---|---|---|
  | `docs/architecture/mpi-infrastructure.md` | 43 | **Delete** (explicitly in issue delete list) |
  | `docs/architecture/mcp-integration-audit.md` | 23 | **Delete** — MPI-ecosystem audit, not applicable |
  | `docs/architecture/agent-roles.md` | 21 | **Delete** — MPI-specific team roles |
  | `docs/architecture/agent-workflow.md` | 2 | **Keep-and-scrub** — generic multi-agent patterns |
  | `docs/deployment.md` | 5 | **Rewrite** — will be replaced by Kamal-based deploy doc in Phase 3 |
  | `docs/research/ai-best-practices.md` | 83 | **Delete** — ecosystem research doc |
  | `docs/research/codex-configuration.md` | 30 | **Delete** — ecosystem research doc |
  | `docs/hc-guide.md` | 8 | **Rewrite** — the Human Collaborator Guide is useful but is written for MPI. Simplify to a Baseline-flavored version. |
  | `docs/getting-started.md` | 5 | **Rewrite** — MPI onboarding; replace with a Baseline quickstart |
  | `docs/credentials_management.md` | 4 | **Keep-and-scrub** — pattern is generic, swap OP vault refs |
  | `docs/asset_pipeline.md` | 3 | **Keep-and-scrub** |
  | `docs/notifications_brief.md` | 1 | **Keep-and-scrub** |
  | `docs/notifications_outline.md` | 1 | **Keep-and-scrub** |
  | `docs/system_permissions_agent_guide.md` | 2 | **Keep-and-scrub** |
  | `docs/notification_system_agent_guide.md` | 1 | **Keep-and-scrub** |
  | `docs/standards/cross-repo-sync.md` | 12 | **Delete** (explicitly in issue delete list) |
  | `docs/standards/hc-review-checklist.md` | 0 direct refs | **Keep** as-is (sanity check during execution) |

- [ ] **P2.D3 — 1Password account & vault for Baseline credentials.** `bin/setup-credentials` and `bin/setup-mcp` hardcode `mpimediagroup.1password.com` and the "Application Development" vault. Options:
  - **(A)** Reuse the MPI 1Password account for Baseline. Simpler, but couples Baseline to MPI's 1Password tenant.
  - **(B)** Create a new 1Password account/vault for Baseline. Independent, but requires ops setup before these scripts work.
  - **(C)** Rewrite setup scripts to take `OP_ACCOUNT` and `OP_VAULT` as env vars with clear error if unset.

  **Recommended:** (C), with default values that work for the HC's personal 1Password. Action: HC picks one before Phase 2 Task 2F runs.

- [x] **P2.D4 — Error tracking: swap Honeybadger → Sentry. SETTLED via #14.**
  - Remove all Honeybadger integration from the template (`bin/setup-credentials` lines 79–133, `.mcp.json.example` Honeybadger block, `.gitignore` `/.honeybadger-cli.yaml` entry).
  - Add Sentry via Task 2O (new): `sentry-ruby` + `sentry-rails` gems, `config/initializers/sentry.rb`, DSN stored in per-environment credentials under `sentry.dsn`.
  - DSN value supplied by HC from #14 completion; populated into production credentials during Phase 3 Task 3B.

- [ ] **P2.D5 — Commit granularity.** This plan uses ~15 small commits across Phase 2 for review traceability. The issue says "Commit 2 — Rebrand Optimus → Baseline; strip MPI references" (single commit). If the single-commit rule is binding, execute with small commits and squash at phase end before merging. **Recommended: squash at end, preserve PR review comments via reviewable history during CR.**

### Phase 3 decisions (must settle before starting Phase 3)

- [ ] **P3.D1 — DNS.** `baseline.kc.tennis` A record must point at the DigitalOcean droplet's public IPv4. HC must confirm:
  - Domain `kc.tennis` is registered and HC controls DNS for it.
  - A record for `baseline.kc.tennis` is created and pointing at `<droplet_ip>`.
  - `dig +short baseline.kc.tennis` returns the droplet IP.
- [ ] **P3.D2 — DigitalOcean droplet.** A droplet exists, is reachable via SSH as `root` (or configured ssh user) from the HC's machine, has Docker installed (or Kamal will install it), has ports 80/443 open. HC confirms droplet IP.
- [ ] **P3.D3 — Container registry.** Kamal needs a registry to push images. Options:
  - **(A)** DigitalOcean Container Registry. Needs `doctl registry login` and `KAMAL_REGISTRY_PASSWORD` secret.
  - **(B)** GitHub Container Registry (ghcr.io). Needs `GHCR_PAT` secret.
  - **(C)** Docker Hub.

  **Recommended:** (A) if the HC is already on DO. Action: HC picks and provides registry hostname.

- [ ] **P3.D4 — Rails credentials strategy.** Template uses per-environment credentials (`config/credentials/{development,staging,production}.yml.enc` + `.key` files). The template's `config/credentials/*.key` files **MUST NOT** be copied in Phase 1 (excluded in rsync; see Phase 1 Task 1.2). In Phase 3 we regenerate `config/credentials/production.yml.enc` + `.key` for Baseline. Kamal's `.kamal/secrets` injects the key as `RAILS_MASTER_KEY` env var on the server.

  Confirm: HC accepts "regenerate all credentials for Baseline" (no migration of template secrets).

- [ ] **P3.D5 — Admin engines AC scope.** The issue's post-deploy verification requires "all six admin-mounted engines accessible" — but Lookbook and RailsDb are dev/staging-only per `app/views/admin/dashboard/index.html.erb:38`. In production, only 4 engines are accessible (Blazer, GoodJob, MaintenanceTasks, PgHero). Interpretation:
  - **(A)** Verify 4 engines in production + 6 engines on local dev boot. **Recommended.**
  - **(B)** Add staging/dev gating removal for Lookbook + RailsDb to meet the literal AC. **Not recommended — they aren't production-safe.**

  Action: HC confirms interpretation (A) before Phase 3 verification.

- [x] **P3.D6 — Production database: DigitalOcean Managed Postgres. SETTLED via #14.**
  - Managed Postgres cluster provisioned in #14; `DATABASE_URL` captured in 1Password.
  - Passed to the app container as an env var via `.kamal/secrets` (not via Rails credentials — it's an infra value, not a secret the app owns).
  - `config/database.yml` production block already reads `ENV["DATABASE_URL"]` — no code change needed.
  - Droplet IP added to the cluster's Trusted Sources allowlist.

- [x] **P3.D7 — Transactional email: Postmark. SETTLED via #14.**
  - Postmark server provisioned in #14; API token + verified sender domain captured in 1Password.
  - Stored in per-environment credentials under `postmark.api_token` and `postmark.sender_email`.
  - `config/environments/production.rb` configured with Postmark SMTP delivery method in Phase 3 Task 3C.

- [x] **P3.D8 — Error tracking wiring: Sentry DSN into production credentials. SETTLED via #14.**
  - DSN captured from #14; populated into production credentials during Phase 3 Task 3B (same pass that creates the credentials file).
  - Staging DSN (if different) deferred — not needed for hello-world.

---

## File inventory (discovery baseline)

Numbers below come from static grep against the template source at `/Users/wrburgess/Projects/aaa/optimus-base/`. Used throughout the plan to size tasks.

- **Total files with any `optimus|Optimus|mpi|Mpi|MPI` substring:** 75 files, 447 occurrences
- **Files with sibling-repo refs (`avails|sfa|garden|harvest`):** 14
- **Issue's explicit structural rename targets:** 11 file groups (see issue §Structural renames)
- **Issue's explicit retention list (keep-and-scrub):** 13 rules/commands/standards files + CLAUDE.md/AGENTS.md + architecture/overview.md + system_permissions/notification_system docs
- **Issue's explicit delete targets:** 2 named files + ".claude/projects.json cross-repo mappings" + "cross-repo setup sections"
- **Files NOT on either issue list but containing MPI refs:** 15 (covered by P2.D2 above)

**Files exempted from the grep AC (legitimate Optimus mentions, NOT scrub targets):**
- `docs/project-notes.md` — baseline-authored planning doc; lines 6 and 10 reference Optimus as **provenance** ("This project will utilize the Optimus template at `aaa/optimus-base` as its starting point"). Removing those references would gut the doc's meaning. Provenance is correct.
- `docs/spec.md` — baseline-authored design doc; lines 65–69 cite "Optimus conventions authoritative", "Optimus pattern" for concerns/enums. These are intentional design decisions documenting where the patterns came from.
- `docs/superpowers/plans/**` — implementation plans (this file and any future plan) that describe the scrub itself; they MUST mention `optimus`/`mpi` to talk about what to remove.

**False-positive sources also excluded from grep AC:**
- `.yarn/releases/yarn-4.13.0.cjs` — vendored yarn binary, 19 substring matches in minified JS
- `yarn.lock` — 2 matches, both `"optimus@workspace:."` — will regenerate from `package.json` rename
- Git history / commit messages — not matched by rg against tracked files

**Critical secret-file hygiene:** Template directory contains `config/credentials/{development,staging,production}.key` — these encryption keys are the template's secrets and **MUST NOT** be copied to Baseline. The `.yml.enc` files would also leak if copied (can be decrypted with the keys), so we exclude both from rsync.

---

## Checkpoint structure

**Checkpoint 1 (after Phase 1):** HC reviews `git diff HEAD~1 HEAD` as a tree listing. Confirms no `*.key` files copied, no `.env` files copied, no `.git` metadata copied. Single-line sanity: `git log --oneline -5`.

**Checkpoint 2 (after Phase 2):** HC reviews full rebrand PR (phase-2 commits). Runs all AC greps locally. Reviews retention-list diff side-by-side to confirm instructional content preserved.

**Checkpoint 3 (after Phase 3):** HC verifies `https://baseline.kc.tennis` loads, SSH into droplet confirms container running, admin engines accessible, `system_manager` role correctly scoped.

---

# Phase 1 — Verbatim Import

Single-commit bulk copy of the template into the Baseline repo, excluding secrets and build artifacts. Produces exactly one reviewable diff from current state.

---

### Task 1.1: Create feature branch

**Files:** None (git state only)

- [ ] **Step 1: Confirm current state is clean.**

  Run:
  ```bash
  cd /Users/wrburgess/Projects/aaa/baseline
  git status
  git branch --show-current
  ```
  Expected: `On branch main`, `nothing to commit, working tree clean`, `main`.

- [ ] **Step 2: Pull latest main.**

  Run:
  ```bash
  git pull --ff-only origin main
  ```
  Expected: `Already up to date.` or a fast-forward. If there's a divergence, STOP and ask HC.

- [ ] **Step 3: Create and switch to feature branch.**

  Run:
  ```bash
  git switch -c feature/issue-1-import-rebrand-deploy
  ```
  Expected: `Switched to a new branch 'feature/issue-1-import-rebrand-deploy'`.

---

### Task 1.2: Verbatim copy of optimus-base into baseline

**Files:**
- Source: `/Users/wrburgess/Projects/aaa/optimus-base/`
- Target: `/Users/wrburgess/Projects/aaa/baseline/`

- [ ] **Step 1: Dry-run rsync to preview the copy.**

  Run:
  ```bash
  rsync -av --dry-run \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='tmp/' \
    --exclude='log/' \
    --exclude='coverage/' \
    --exclude='storage/' \
    --exclude='public/assets/' \
    --exclude='.bundle/' \
    --exclude='vendor/bundle/' \
    --exclude='.env' \
    --exclude='.env.*' \
    --exclude='.DS_Store' \
    --exclude='.mcp.json' \
    --exclude='.honeybadger-cli.yaml' \
    --exclude='config/credentials/*.key' \
    --exclude='config/*.key' \
    --exclude='config/credentials/*.yml.enc' \
    --exclude='.claude/settings.local.json' \
    --exclude='.claude/projects.local.json' \
    --exclude='.claude/worktrees/' \
    --exclude='.byebug_history' \
    --exclude='spec/examples.txt' \
    /Users/wrburgess/Projects/aaa/optimus-base/ \
    /Users/wrburgess/Projects/aaa/baseline/
  ```

  Expected output: list of files to copy. Scan the list for any `*.key`, `*.yml.enc`, `.env`, `master.key`, `.mcp.json` (not `.example`), `.honeybadger-cli.yaml`. There should be **none**. If any appear, STOP and fix the exclude list.

- [ ] **Step 2: Execute the real rsync.**

  Run the same command **without** `--dry-run`:
  ```bash
  rsync -av \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='tmp/' \
    --exclude='log/' \
    --exclude='coverage/' \
    --exclude='storage/' \
    --exclude='public/assets/' \
    --exclude='.bundle/' \
    --exclude='vendor/bundle/' \
    --exclude='.env' \
    --exclude='.env.*' \
    --exclude='.DS_Store' \
    --exclude='.mcp.json' \
    --exclude='.honeybadger-cli.yaml' \
    --exclude='config/credentials/*.key' \
    --exclude='config/*.key' \
    --exclude='config/credentials/*.yml.enc' \
    --exclude='.claude/settings.local.json' \
    --exclude='.claude/projects.local.json' \
    --exclude='.claude/worktrees/' \
    --exclude='.byebug_history' \
    --exclude='spec/examples.txt' \
    /Users/wrburgess/Projects/aaa/optimus-base/ \
    /Users/wrburgess/Projects/aaa/baseline/
  ```

  Expected: rsync prints each file it copies and a final `sent ...`/`received ...` summary.

  **Note on existing docs:** Baseline already has `docs/project-notes.md` and `docs/spec.md`. Optimus-base does not have files with these names (confirmed during discovery), so they will coexist without overwrite. Baseline's existing `README.md` **will be overwritten** by the template's `README.md` — this is intentional (Phase 2 rewrites it properly).

---

### Task 1.3: Verify exclusions (secret hygiene check)

**Files:** None (verification only)

- [ ] **Step 1: Confirm no encryption keys were copied.**

  Run:
  ```bash
  find /Users/wrburgess/Projects/aaa/baseline -name '*.key' -not -path '*/.git/*'
  find /Users/wrburgess/Projects/aaa/baseline/config/credentials -name '*.yml.enc' 2>/dev/null
  find /Users/wrburgess/Projects/aaa/baseline -name '.env*' -not -path '*/.git/*'
  find /Users/wrburgess/Projects/aaa/baseline -name '.mcp.json' -not -path '*/.git/*'
  find /Users/wrburgess/Projects/aaa/baseline -name '.honeybadger-cli.yaml' -not -path '*/.git/*'
  find /Users/wrburgess/Projects/aaa/baseline -name 'master.key' -not -path '*/.git/*'
  ```
  Expected: all five commands return **empty**. If any output appears, STOP — delete the leaked file, amend the rsync exclusions, and re-run Task 1.2.

- [ ] **Step 2: Confirm `.mcp.json.example` and `.gitignore` WERE copied.**

  Run:
  ```bash
  ls -la /Users/wrburgess/Projects/aaa/baseline/.mcp.json.example \
        /Users/wrburgess/Projects/aaa/baseline/.gitignore
  ```
  Expected: both files exist.

- [ ] **Step 3: Confirm key structural files are present.**

  Run:
  ```bash
  ls /Users/wrburgess/Projects/aaa/baseline/config/application.rb \
     /Users/wrburgess/Projects/aaa/baseline/config/deploy.yml \
     /Users/wrburgess/Projects/aaa/baseline/Dockerfile \
     /Users/wrburgess/Projects/aaa/baseline/package.json \
     /Users/wrburgess/Projects/aaa/baseline/Gemfile \
     /Users/wrburgess/Projects/aaa/baseline/CLAUDE.md \
     /Users/wrburgess/Projects/aaa/baseline/AGENTS.md
  ```
  Expected: all files exist.

- [ ] **Step 4: Confirm the baseline `docs/spec.md` and `docs/project-notes.md` were preserved.**

  Run:
  ```bash
  ls /Users/wrburgess/Projects/aaa/baseline/docs/spec.md \
     /Users/wrburgess/Projects/aaa/baseline/docs/project-notes.md
  ```
  Expected: both files exist (rsync did not overwrite or delete them).

---

### Task 1.4: Stage and commit verbatim import

**Files:** All new files from Task 1.2

- [ ] **Step 1: Stage everything.**

  Run:
  ```bash
  cd /Users/wrburgess/Projects/aaa/baseline
  git add -A
  ```

- [ ] **Step 2: Sanity-check staged files include no secrets.**

  Run:
  ```bash
  git diff --cached --name-only | grep -E '(\.key$|\.yml\.enc$|\.env|master\.key|\.mcp\.json$|honeybadger-cli\.yaml$)' || echo "OK: no secret files staged"
  ```
  Expected: `OK: no secret files staged`. If files are listed, STOP and `git restore --staged <file>` then delete from disk.

- [ ] **Step 3: Commit with verbatim-import message.**

  Run:
  ```bash
  git commit -m "$(cat <<'EOF'
Import Optimus template verbatim

Bulk copy of aaa/optimus-base template contents into Baseline.
No edits — this is a clean import so the rebrand diff in the
follow-up commit is the only delta.

Excluded: .git, node_modules, tmp, log, coverage, storage,
public/assets, .bundle, vendor/bundle, .env*, .DS_Store,
.mcp.json, .honeybadger-cli.yaml, config/credentials/*.{key,yml.enc},
config/*.key, .claude/{settings.local.json,projects.local.json,worktrees},
.byebug_history, spec/examples.txt.

Refs #1

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
  ```
  Expected: commit succeeds with file-count summary.

- [ ] **Step 4: Push branch.**

  Run:
  ```bash
  git push -u origin feature/issue-1-import-rebrand-deploy
  ```
  Expected: new branch pushed.

---

## **CHECKPOINT 1** — HC reviews verbatim import

**HC action required before proceeding to Phase 2:**

- Run `git diff --stat HEAD~1 HEAD | tail -1` and sanity-check file count (~hundreds).
- Run `git show --stat HEAD | head -20` to see summary.
- Confirm no secret files appear in `git show --name-only HEAD`.
- Confirm `git log --oneline -2` shows the verbatim-import commit atop the prior "Admin nav + four polish enhancements..." commit.

**If OK:** give explicit go-ahead for Phase 2.
**If NOT OK:** `git reset --hard HEAD~1` to undo the import; fix and redo Task 1.2+.

---

# Phase 2 — Rebrand Optimus → Baseline + Strip MPI

Decomposes the rebrand into logical commits. Every task: edit files, run targeted verification, commit. Individual commits to be squashed at phase end per P2.D5.

---

### Task 2A: Rails module rename

**Files:**
- Modify: `config/application.rb:21`
- Modify: `config/database.yml:11,19`

- [ ] **Step 1: Rename Rails module in application.rb.**

  Edit `/Users/wrburgess/Projects/aaa/baseline/config/application.rb`:
  - Change `module Optimus` → `module Baseline`

  After edit, line 21 must read:
  ```ruby
  module Baseline
  ```

- [ ] **Step 2: Rename database names in database.yml.**

  Edit `/Users/wrburgess/Projects/aaa/baseline/config/database.yml`:
  - Line 11: `database: <%= ENV.fetch("POSTGRES_DB_DEVELOPMENT", "optimus_development") %>` → `database: <%= ENV.fetch("POSTGRES_DB_DEVELOPMENT", "baseline_development") %>`
  - Line 19: `database: <%= ENV.fetch("POSTGRES_DB_TEST", "optimus_test") %>` → `database: <%= ENV.fetch("POSTGRES_DB_TEST", "baseline_test") %>`

- [ ] **Step 3: Run zeitwerk check.**

  Run:
  ```bash
  cd /Users/wrburgess/Projects/aaa/baseline
  bin/rails zeitwerk:check
  ```
  Expected: `All is good!` (or similar zero-error output). If it fails, search for `Optimus::` references:
  ```bash
  rg '\bOptimus::' app lib spec
  ```
  and rename each to `Baseline::`.

- [ ] **Step 4: Commit module rename.**

  Run:
  ```bash
  git add config/application.rb config/database.yml
  git commit -m "Rebrand Rails module Optimus → Baseline; db names optimus_* → baseline_*

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2B: Deploy config, Dockerfile, package, workflows

**Files:**
- Modify: `config/deploy.yml:2,5,48,65`
- Modify: `Dockerfile:5,6`
- Modify: `package.json:12,13`
- Modify: `.github/workflows/ci.yml` (per P2.D1 decision)
- Modify: `.github/workflows/check_indexes.yml`, `update-gems.yml`, `update-packages.yml`, `copilot-setup-steps.yml` (rename refs)

**Depends on:** P2.D1 decision (CI coupling).

- [ ] **Step 1: Scrub deploy.yml structural names.**

  Edit `/Users/wrburgess/Projects/aaa/baseline/config/deploy.yml`:
  - Line 2: `service: optimus` → `service: baseline`
  - Line 5: `image: optimus` → `image: baseline`
  - Line 48: `# Use optimus-db for a db accessory server on same machine via local kamal docker network.` → `# Use baseline-db for a db accessory server on same machine via local kamal docker network.`
  - Line 65: `- "optimus_storage:/rails/storage"` → `- "baseline_storage:/rails/storage"`

  **DO NOT** change `servers.web[0]` (still `192.168.0.1` placeholder) or `registry.server` (`localhost:5555` placeholder). These are rewritten in Phase 3.

- [ ] **Step 2: Scrub Dockerfile comments.**

  Edit `/Users/wrburgess/Projects/aaa/baseline/Dockerfile`:
  - Line 5: `# docker build -t optimus .` → `# docker build -t baseline .`
  - Line 6: `# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name optimus optimus` → `# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/credentials/production.key> --name baseline baseline`

  (Also correcting the `master.key` reference since template uses per-env keys.)

- [ ] **Step 3: Scrub package.json.**

  Edit `/Users/wrburgess/Projects/aaa/baseline/package.json`:
  - Line 12: `"name": "optimus",` → `"name": "baseline",`
  - Line 13: `"repository": "git@github.com:mpimedia/optimus.git",` → `"repository": "git@github.com:wrburgess/baseline.git",`

- [ ] **Step 4: Regenerate yarn.lock.**

  Run:
  ```bash
  yarn install
  ```
  Expected: `yarn.lock` updated with `"baseline@workspace:."` replacing `"optimus@workspace:."`. If yarn not installed, `corepack enable && corepack prepare yarn@4.13.0 --activate` first.

  Verify:
  ```bash
  rg -n 'optimus' yarn.lock || echo "OK: no optimus refs in yarn.lock"
  ```
  Expected: `OK: no optimus refs in yarn.lock`.

- [ ] **Step 5: Handle CI workflow per P2.D1 decision.**

  **If P2.D1 = (A) Copy ci-rails.yml into Baseline (recommended):**
  - Fetch the pinned file from GitHub:
    ```bash
    mkdir -p .github/workflows/_shared
    curl -fL -o .github/workflows/_shared/ci-rails.yml \
      https://raw.githubusercontent.com/mpimedia/mpi-application-workflows/f00663fa9e97a7dafa18b276a6e483094116b98e/.github/workflows/ci-rails.yml
    ```
  - Read `.github/workflows/_shared/ci-rails.yml` and scrub any `mpi`/`optimus` references inside.
  - Rewrite `.github/workflows/ci.yml` to:
    ```yaml
    name: CI

    on:
      push:
        branches:
          - "**"
      workflow_dispatch:

    jobs:
      ci:
        uses: ./.github/workflows/_shared/ci-rails.yml
        secrets: inherit
    ```

  **If P2.D1 = (B) Keep the `uses:` reference:** no change to ci.yml. Note the coupling in the PR description.

  **If P2.D1 = (C) Inline CI job:** rewrite `ci.yml` from scratch based on what the upstream job does (rubocop, rspec, brakeman, bundler-audit). HC to review in CR.

- [ ] **Step 6: Scrub other workflow files for mpi/optimus refs.**

  For each of `.github/workflows/{check_indexes.yml,update-gems.yml,update-packages.yml,copilot-setup-steps.yml}`:
  - Read the file.
  - Replace any `mpi`/`optimus`/`mpimedia` substring with `baseline`/`wrburgess` as appropriate.
  - Replace any `uses: mpimedia/...` references per P2.D1 approach.

- [ ] **Step 7: Verify workflow-level grep is clean.**

  Run:
  ```bash
  rg -i 'mpi|optimus' .github/
  ```
  Expected: zero matches (or only matches inside `_shared/ci-rails.yml` if the upstream SHA is still in a comment — acceptable if called out).

- [ ] **Step 8: Commit.**

  Run:
  ```bash
  git add config/deploy.yml Dockerfile package.json yarn.lock .github/
  git commit -m "Rebrand deploy/docker/package + adapt CI workflows

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2C: Admin UI (brand, dashboard, layouts, manifest)

**Files:**
- Modify: `app/components/admin/brand/component.rb:2`
- Modify: `app/components/admin/nav_bar/component.html.erb` (1 ref)
- Modify: `app/views/admin/dashboard/index.html.erb:31,33,34`
- Modify: `app/views/layouts/{admin,application,devise,vc_preview}.html.erb` (1–2 refs each)
- Modify: `app/views/pwa/manifest.json.erb:2,19`
- Modify: `config/routes/external_urls.rb:1–3`
- Modify: `spec/components/admin/brand/component_spec.rb` (5 refs)
- Modify: `spec/components/admin/nav_bar/component_spec.rb` (1 ref)

- [ ] **Step 1: Rebrand `app/components/admin/brand/component.rb`.**

  Edit line 2: `brand_name: "Optimus Admin"` → `brand_name: "Baseline Admin"`.

- [ ] **Step 2: Rebrand `config/routes/external_urls.rb`.**

  Replace entire contents with:
  ```ruby
  direct(:production_site) { "https://baseline.kc.tennis" }
  direct(:staging_site) { "https://baseline-staging.kc.tennis" }
  direct(:development_site) { "http://localhost:8000" }
  ```

  **Note:** The staging host `baseline-staging.kc.tennis` is aspirational — Phase 3 deploys production only. Flag in CR if staging won't exist.

- [ ] **Step 3: Rebrand `app/views/admin/dashboard/index.html.erb`.**

  Edit line 31: GitHub URL `'https://github.com/mpimedia/optimus/projects'` → `'https://github.com/wrburgess/baseline/projects'`.
  Edit line 33: `'Optimus (Production)'` and `'https://optimus.wrburgess.com'` → `'Baseline (Production)'` and `'https://baseline.kc.tennis'`.
  Edit line 34: `'Optimus (Staging)'` and `'https://optimus-staging.wrburgess.com'` → `'Baseline (Staging)'` and `'https://baseline-staging.kc.tennis'`.

- [ ] **Step 4: Rebrand `app/views/pwa/manifest.json.erb`.**

  Replace entire contents with:
  ```erb
  {
    "name": "Baseline",
    "icons": [
      {
        "src": "/icon.png",
        "type": "image/png",
        "sizes": "512x512"
      },
      {
        "src": "/icon.png",
        "type": "image/png",
        "sizes": "512x512",
        "purpose": "maskable"
      }
    ],
    "start_url": "/",
    "display": "standalone",
    "scope": "/",
    "description": "Baseline.",
    "theme_color": "red",
    "background_color": "red"
  }
  ```

- [ ] **Step 5: Rebrand layout files.**

  For each of `app/views/layouts/{admin,application,devise,vc_preview}.html.erb` and `app/components/admin/nav_bar/component.html.erb`:
  - Open the file, find every `Optimus`/`optimus`/`MPI`/`Mpi`/`mpi` occurrence.
  - Replace with the corresponding Baseline term — usually in a `<title>` tag, brand helper call, or comment.

  After editing each file, verify with:
  ```bash
  rg -in 'optimus|mpi' <file>
  ```
  Expected: no matches.

- [ ] **Step 6: Rebrand spec files.**

  For `spec/components/admin/brand/component_spec.rb` (5 refs) and `spec/components/admin/nav_bar/component_spec.rb` (1 ref):
  - Find every `"Optimus"` / `"Optimus Admin"` string literal.
  - Replace with `"Baseline"` / `"Baseline Admin"`.

- [ ] **Step 7: Run the component specs.**

  Run:
  ```bash
  bundle exec rspec spec/components/admin/brand spec/components/admin/nav_bar
  ```
  Expected: all green. If not, debug the rename.

- [ ] **Step 8: Commit.**

  Run:
  ```bash
  git add app/components/admin/brand app/components/admin/nav_bar \
          app/views/admin/dashboard app/views/layouts app/views/pwa \
          config/routes/external_urls.rb \
          spec/components/admin
  git commit -m "Rebrand admin UI, routes, manifest, layouts, brand specs

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2D: Setup scripts and MCP config

**Files:**
- Modify: `bin/setup-credentials` (5 refs, 1Password account, Honeybadger integration)
- Modify: `bin/setup-mcp` (3 refs + references to deleted doc)
- Modify: `bin/setup-copilot-mcp` (2 refs)
- Modify: `.mcp.json.example` (4 Honeybadger project IDs + sibling-repo refs)
- Modify: `.gitignore` (remove `.honeybadger-cli.yaml` line per P2.D4 settled)
- Modify: `context7.json` (1 ref)

**Depends on:** P2.D3 (1Password), P2.D4 (Honeybadger).

- [ ] **Step 1: Scrub `bin/setup-credentials` per P2.D3.**

  **If P2.D3 = (A) Reuse MPI 1Password:** change only string `"Optimus X Key"` → `"Baseline X Key"` (3 occurrences on line 38 via `item_name=...$(capitalize...)`). Confirm the 1Password items `Baseline Development Key`, `Baseline Staging Key`, `Baseline Production Key` exist before running this script; they don't exist yet — create them out-of-band.

  **If P2.D3 = (B) New 1Password account:** change `OP_ACCOUNT="mpimediagroup.1password.com"` on line 20 to the new Baseline account, and rename item names as in (A).

  **If P2.D3 = (C) env vars (recommended):** replace lines 20–21 with:
  ```bash
  OP_ACCOUNT="${BASELINE_OP_ACCOUNT:?Set BASELINE_OP_ACCOUNT env var (e.g. my.1password.com)}"
  OP_VAULT="${BASELINE_OP_VAULT:-Application Development}"
  ```
  And rename `"Optimus $(capitalize "$env") Key"` → `"Baseline $(capitalize "$env") Key"` on line 38.

  Also update line 13 (docblock comment) to match the new behavior.

- [ ] **Step 2: Remove all Honeybadger integration (per P2.D4 — Sentry replaces it in Task 2D2).**

  - Delete lines 79–133 from `bin/setup-credentials` (the whole Honeybadger CLI configuration block).
  - Remove `/.honeybadger-cli.yaml` from `.gitignore` (line 59–60).
  - Any `.honeybadger.yml` / `config/honeybadger.yml` file: delete if present.
  - Grep check after:
    ```bash
    rg -i 'honeybadger' .
    ```
    Expected: zero matches (or note any left in vendored binaries — none expected).

- [ ] **Step 3: Scrub `bin/setup-mcp`.**

  - Line 14 comment block: `# MCP Server Profile (Optimized — see docs/architecture/mcp-integration-audit.md):` and lines 14–17 referencing MCP profile rationale → replace with `# MCP Server Profile: Cloudflare (Code Mode)`.
  - Line 31: same `OP_ACCOUNT` change as Step 1.
  - Lines 54–55: reference to `docs/architecture/mcp-integration-audit.md` — delete.
  - Lines 60–62: dry-run credential list — remove Honeybadger line.
  - Lines 80–81: the `op read` calls — remove Honeybadger line.
  - Line 87–88: substitution lines — remove Honeybadger substitution.
  - Comment lines 16–17 ("error tracking across MPI projects") — delete.

- [ ] **Step 4: Scrub `bin/setup-copilot-mcp`.**

  Read the file and apply same pattern: `OP_ACCOUNT` change, any mpimedia/optimus strings to Baseline equivalents.

- [ ] **Step 5: Scrub `.mcp.json.example`.**

  Replace file contents with:
  ```json
  {
    "mcpServers": {
      "cloudflare": {
        "type": "http",
        "url": "https://mcp.cloudflare.com/mcp",
        "headers": {
          "Authorization": "Bearer ${CLOUDFLARE_API_TOKEN}"
        }
      }
    }
  }
  ```

- [ ] **Step 6: Scrub `context7.json`.**

  Open the file, locate the single `optimus`/`mpi` reference, replace with Baseline equivalent.

- [ ] **Step 7: Commit.**

  Run:
  ```bash
  git add bin/setup-credentials bin/setup-mcp bin/setup-copilot-mcp \
          .mcp.json.example .gitignore context7.json
  git commit -m "Rebrand setup scripts and MCP config; remove Honeybadger

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2D2: Sentry integration (replaces removed Honeybadger)

**Files:**
- Modify: `Gemfile`
- Modify: `Gemfile.lock`
- Create: `config/initializers/sentry.rb`

- [ ] **Step 1: Add sentry gems to Gemfile.**

  Edit `/Users/wrburgess/Projects/aaa/baseline/Gemfile`. Add at the top level (not in a `group :production do` block, so it's available everywhere — the initializer's `enabled_environments` controls when events actually fire):
  ```ruby
  gem "sentry-ruby", "~> 5.24"
  gem "sentry-rails", "~> 5.24"
  ```

- [ ] **Step 2: Install gems.**

  Run:
  ```bash
  bundle install
  ```
  Expected: `sentry-ruby` and `sentry-rails` installed, `Gemfile.lock` updated.

- [ ] **Step 3: Create `config/initializers/sentry.rb`.**

  Write:
  ```ruby
  Sentry.init do |config|
    config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = 0.0
    config.profiles_sample_rate = 0.0
    config.enabled_environments = %w[production staging]
    config.environment = Rails.env
    config.release = ENV["KAMAL_VERSION"]
  end
  ```

  Notes:
  - DSN comes from per-env credentials (populated for production in Phase 3 Task 3B). If nil, Sentry SDK no-ops — safe to ship before DSN exists.
  - `enabled_environments` excludes `development` and `test`, so local/test runs never ship events.
  - `KAMAL_VERSION` is set by Kamal to the deployed git SHA.

- [ ] **Step 4: Boot check.**

  Run:
  ```bash
  bin/rails runner 'puts "boot OK; Sentry defined: #{defined?(Sentry)}"'
  ```
  Expected: `boot OK; Sentry defined: constant`. Anything else means the initializer errored.

- [ ] **Step 5: Run specs.**

  Run:
  ```bash
  bundle exec rspec
  ```
  Expected: all green (Sentry no-ops in test env per `enabled_environments`).

- [ ] **Step 6: Commit.**

  Run:
  ```bash
  git add Gemfile Gemfile.lock config/initializers/sentry.rb
  git commit -m "Add Sentry error tracking; DSN loaded from per-env credentials

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2E: Retention-list — .claude rules, commands, root-level AI docs

**Files (retention list, scrub-only):**
- Modify: `CLAUDE.md` (5 refs)
- Modify: `AGENTS.md` (11 refs)
- Modify: `.github/copilot-instructions.md` (12 refs)
- Modify: `.claude/rules/backend.md` (1 ref)
- Modify: `.claude/rules/frontend.md` (1 ref)
- Modify: `.claude/rules/testing.md` (no refs per grep; verify and no-op if clean)
- Modify: `.claude/rules/security.md` (no refs; no-op likely)
- Modify: `.claude/rules/migrations.md` (no refs; no-op likely)
- Modify: `.claude/rules/self-review.md` (no refs; no-op likely)
- Modify: `.claude/commands/{assess,compare,cplan,db-health,explore,final,impl,rtr,verify}.md` (varying refs)

**Rule:** Scrub MPI/Optimus refs only. **Do not rewrite instructional content.** If you're tempted to "improve" rule wording beyond the rebrand, STOP — file a follow-up issue.

- [ ] **Step 1: Scrub `CLAUDE.md`.**

  - Line 3: `Optimus is the Ruby on Rails template and reference implementation for the MPI Media application suite. Conventions originate here and flow to all MPI apps.` → `Baseline is a Ruby on Rails application template. Conventions defined here are the authoritative source for development discipline.`
  - **Delete** lines 5–9 (the entire `## MPI Media` section describing MPI Media business context). This is MPI-ecosystem-specific, not Baseline content.
  - Line 60: `Ask about MPI business context when it affects the work — what the app does, who uses it, why a feature matters, how apps relate to each other` → `Ask about Baseline business context when it affects the work — what the app does, who uses it, why a feature matters.`
  - Line 99: If P2.D2 deletes `docs/architecture/mcp-integration-audit.md`, replace `See @docs/architecture/mcp-integration-audit.md.` with `See MCP setup scripts in \`bin/setup-mcp\`.` or remove the bullet.

- [ ] **Step 2: Scrub `AGENTS.md`.**

  - Line 1–3: header and project blurb — change `Optimus` → `Baseline`, remove "for the MPI Media application ecosystem" wording.
  - Line 7: same change.
  - **Delete** lines 9–21 (the entire `## MPI Application Ecosystem` table — all sibling repos).
  - Line 129–130: if P2.D2 deletes `docs/architecture/agent-workflow.md`, remove the cross-link. If keep-and-scrub, leave as-is.
  - Line 150–156 (Documentation section): update paths if any referenced doc is deleted per P2.D2.

- [ ] **Step 3: Scrub `.github/copilot-instructions.md`.**

  Open file; find each MPI/Optimus/sibling-repo reference; rebrand each in place. **Do not** restructure sections.

- [ ] **Step 4: Scrub `.claude/rules/*.md`.**

  For each of `.claude/rules/{backend,frontend,testing,security,migrations,self-review}.md`:
  - Open file.
  - Find any `mpi`/`optimus`/`mpimedia` ref (grep to confirm match count; may be zero for some).
  - Rebrand in place. Preserve all rule text verbatim.

- [ ] **Step 5: Scrub `.claude/commands/*.md`.**

  For each `.claude/commands/*.md` file:
  - Open file.
  - Find MPI/Optimus references; rebrand in place.
  - Preserve command logic.

  **Note:** `.claude/commands/compare.md` has 5 refs — likely discusses cross-repo comparison. If the command is inherently cross-repo-coupled and not applicable to Baseline alone, flag in CR whether to keep or delete.

- [ ] **Step 6: Verify retention-list files pass grep.**

  Run:
  ```bash
  rg -i '\b(mpi|optimus|mpimedia)\b' CLAUDE.md AGENTS.md .github/copilot-instructions.md .claude/rules .claude/commands
  ```
  Expected: zero matches.

- [ ] **Step 7: Commit.**

  Run:
  ```bash
  git add CLAUDE.md AGENTS.md .github/copilot-instructions.md .claude/rules .claude/commands
  git commit -m "Scrub MPI/Optimus refs from retention-list rules and AI agent instructions

Content preserved per issue #1 retention rule; only brand/ecosystem
identifiers updated.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2F: Retention-list — docs/standards/ and docs/architecture/overview.md

**Files:**
- Modify: `docs/standards/{anti-patterns,caching,code-review,design,development-lifecycle,documentation,hotwire-patterns,memory-management,query-patterns,style,testing}.md` (1–2 refs each)
- Modify: `docs/architecture/overview.md` (3 refs)
- Modify: `docs/system_permissions.md` (2 refs)
- Modify: `docs/system_permissions_agent_guide.md` (2 refs)
- Modify: `docs/notification_system.md` (1 ref)

- [ ] **Step 1: For each file in the above list, scrub in place.**

  Standard approach per file:
  - Open.
  - Find every MPI/Optimus/sibling-repo ref.
  - Replace with Baseline equivalent.
  - Preserve all instructional content.

  Specific notes:
  - `docs/standards/design.md`, `docs/standards/style.md`, etc.: likely one-line references like "in Optimus, we..."
  - `docs/architecture/overview.md`: likely contains the architecture narrative; rebrand only.
  - `docs/system_permissions.md`: policy doc; rebrand only.

- [ ] **Step 2: Verify grep.**

  Run:
  ```bash
  rg -i '\b(mpi|optimus|mpimedia)\b' docs/standards docs/architecture/overview.md docs/system_permissions.md docs/system_permissions_agent_guide.md docs/notification_system.md
  ```
  Expected: zero matches.

- [ ] **Step 3: Commit.**

  Run:
  ```bash
  git add docs/standards docs/architecture/overview.md docs/system_permissions.md docs/system_permissions_agent_guide.md docs/notification_system.md
  git commit -m "Scrub MPI/Optimus refs from retention-list standards and architecture docs

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2G: Delete — issue-specified delete list

**Files:**
- Delete: `docs/architecture/mpi-infrastructure.md`
- Delete: `docs/standards/cross-repo-sync.md`

- [ ] **Step 1: Delete the two files.**

  Run:
  ```bash
  rm docs/architecture/mpi-infrastructure.md
  rm docs/standards/cross-repo-sync.md
  ```

- [ ] **Step 2: Verify no dangling refs inside retained files.**

  Run:
  ```bash
  rg 'mpi-infrastructure|cross-repo-sync' .
  ```
  Expected: zero matches. If any (e.g., CLAUDE.md's `@docs/...` reference), edit to remove the broken link.

- [ ] **Step 3: Commit.**

  Run:
  ```bash
  git add -A
  git commit -m "Delete MPI-ecosystem-specific docs per issue #1

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2H: Delete/rewrite — ambiguous docs per P2.D2

**Depends on:** P2.D2 decisions for each file.

- [ ] **Step 1: Execute delete decisions.**

  For every file in P2.D2 table marked **Delete**, run:
  ```bash
  rm <filepath>
  ```
  Specifically (assuming P2.D2 recommendations are accepted):
  ```bash
  rm docs/architecture/mcp-integration-audit.md
  rm docs/architecture/agent-roles.md
  rm docs/research/ai-best-practices.md
  rm docs/research/codex-configuration.md
  rmdir docs/research 2>/dev/null  # cleanup if empty
  ```

- [ ] **Step 2: Scrub keep-and-scrub files.**

  Apply the same scrub approach (open, find MPI/Optimus refs, replace) to:
  - `docs/architecture/agent-workflow.md`
  - `docs/credentials_management.md`
  - `docs/asset_pipeline.md`
  - `docs/notifications_brief.md`
  - `docs/notifications_outline.md`
  - `docs/notification_system_agent_guide.md`

- [ ] **Step 3: Rewrite files marked Rewrite.**

  **`docs/hc-guide.md`** — rewrite from scratch as a short Baseline-specific HC guide. Approach:
  - Delete the existing file.
  - Create a new `docs/hc-guide.md` with sections: "About Baseline", "Development Workflow", "Commands", "What to Review", "Environment Setup". Keep it brief (<200 lines). Model on the structure of the original but strip MPI ecosystem context.

  **`docs/getting-started.md`** — rewrite as a Baseline quickstart.
  - Delete existing.
  - Create new with: prerequisites, setup, running the app, running tests.

  **`docs/deployment.md`** — replace contents with Kamal-flavored Baseline deploy overview. Can be a 1-section stub for now pointing at `config/deploy.yml` and `.kamal/` — Phase 3 produces the full content.

- [ ] **Step 4: Remove dangling `@docs/...` references.**

  Any retained files that still link to deleted docs need those links removed:
  ```bash
  rg '@docs/architecture/(mcp-integration-audit|agent-roles|mpi-infrastructure)|@docs/research/' .
  ```
  Fix every match (remove the link or point at an alternative doc).

- [ ] **Step 5: Commit.**

  Run:
  ```bash
  git add -A
  git commit -m "Delete MPI-ecosystem docs; scrub retained; rewrite hc-guide and getting-started for Baseline

Per P2.D2 decisions.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2I: `.claude/projects.json` and `.claude/settings.local.json`

**Files:**
- Modify: `.claude/projects.json` (35 refs — 10 sibling-repo entries)
- Modify: `.claude/settings.local.json` (5 MPI refs + 8 optimus refs) — **but note** this file is in `.gitignore` (line 49–50), so it WAS NOT copied in Phase 1. Skip this file.

- [ ] **Step 1: Rewrite `.claude/projects.json`.**

  The existing file lists 10 MPI-ecosystem projects under a top-level `"mpi_projects"` key. Replace entirely with:
  ```json
  {
    "projects": {
      "baseline": {
        "name": "Baseline",
        "description": "Rails application template",
        "github_url": "https://github.com/wrburgess/baseline",
        "github_org": "wrburgess",
        "github_repo": "baseline",
        "role": "template"
      }
    }
  }
  ```

- [ ] **Step 2: Verify no consumer of `mpi_projects` key remains.**

  Run:
  ```bash
  rg 'mpi_projects' .
  ```
  Expected: zero matches. If any, update to reference `projects` instead.

- [ ] **Step 3: Commit.**

  Run:
  ```bash
  git add .claude/projects.json
  git commit -m "Rewrite .claude/projects.json for Baseline-only registry

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2J: README.md rewrite

**Files:**
- Modify: `README.md` (14 refs — entire file is MPI ecosystem orientation)

- [ ] **Step 1: Replace `README.md` contents.**

  Write new contents:
  ```markdown
  # Baseline

  A Ruby on Rails application template.

  ## Getting Started

  - See [docs/getting-started.md](docs/getting-started.md) for setup instructions.
  - See [docs/hc-guide.md](docs/hc-guide.md) for development workflow and conventions.

  ## Credentials

  - See [docs/credentials_management.md](docs/credentials_management.md).

  ## System Permissions

  - See [docs/system_permissions.md](docs/system_permissions.md).

  ## Notification System

  - See [docs/notification_system.md](docs/notification_system.md).

  ## Deployment

  - See [docs/deployment.md](docs/deployment.md).
  ```

  Length: ~25 lines. Keep simple; expand later.

- [ ] **Step 2: Commit.**

  Run:
  ```bash
  git add README.md
  git commit -m "Rewrite README for Baseline

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 2K: Miscellaneous remaining refs

Files that may still contain optimus/mpi refs not covered above. Sweep explicitly.

- [ ] **Step 1: Catch any stragglers.**

  Run:
  ```bash
  rg -l 'optimus|mpi|Optimus|MPI|Mpi' \
    --glob '!.yarn/releases/**' \
    --glob '!yarn.lock' \
    --glob '!.git/**' \
    --glob '!log/**' \
    --glob '!tmp/**' \
    --glob '!coverage/**' \
    --glob '!node_modules/**'
  ```
  Expected: ideally zero matches. Any file listed needs a manual pass.

- [ ] **Step 2: For each straggler file, open and scrub.**

  Expected candidates (low-ref-count files not covered by prior tasks): hunt and fix each.

- [ ] **Step 3: If any remaining file is `.yarn/releases/yarn-4.13.0.cjs`, `yarn.lock`, LICENSE, or CHANGELOG, leave as-is.**

  Add a note in the commit message justifying: `.yarn/releases/yarn-4.13.0.cjs` is a vendored yarn binary (substring-level false positives in minified JS).

- [ ] **Step 4: Commit if any files were changed.**

  Run:
  ```bash
  git add -A
  git commit -m "Scrub remaining stragglers; note vendored yarn binary false positives

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>" || echo "nothing to commit"
  ```

---

### Task 2L: Database + Zeitwerk + Asset smoke tests

**Files:** None (verification only)

- [ ] **Step 1: Install gems.**

  Run:
  ```bash
  bundle install
  ```
  Expected: success.

- [ ] **Step 2: Install yarn packages.**

  Run:
  ```bash
  yarn install
  ```
  Expected: success.

- [ ] **Step 3: Create databases.**

  Run:
  ```bash
  bin/rails db:create
  ```
  Expected: `Created database 'baseline_development'` and `Created database 'baseline_test'` (or "already exists" messages on re-run). If `optimus_*` database names appear, STOP — re-check `config/database.yml`.

- [ ] **Step 4: Run migrations.**

  Run:
  ```bash
  bin/rails db:migrate
  bin/rails db:migrate RAILS_ENV=test
  ```
  Expected: all migrations run cleanly.

- [ ] **Step 5: Zeitwerk check.**

  Run:
  ```bash
  bin/rails zeitwerk:check
  ```
  Expected: `All is good!`.

- [ ] **Step 6: Asset precompile smoke test.**

  Run:
  ```bash
  SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
  ```
  Expected: admin + public pipelines both compile successfully.

- [ ] **Step 7: If anything above fails, fix the root cause.**

  Common failure modes:
  - Zeitwerk check fails → stray `Optimus::` const remaining → grep and rename.
  - DB create fails → wrong db name in `config/database.yml`.
  - Assets fail → stale cache; `rm -rf tmp/cache public/assets && retry`.

  Do **not** move forward until all six pass.

- [ ] **Step 8: No commit needed (verification-only task).**

---

### Task 2M: Full test + lint + security suite

**Files:** None (verification only)

- [ ] **Step 1: Run RSpec.**

  Run:
  ```bash
  bundle exec rspec
  ```
  Expected: all green (on the empty-template specs shipped with Optimus). Fix any reds by investigating — likely more stragglers.

- [ ] **Step 2: Run Rubocop.**

  Run:
  ```bash
  bundle exec rubocop -a
  ```
  Expected: zero offenses. Auto-correct picks up most.

- [ ] **Step 3: Run Brakeman.**

  Run:
  ```bash
  bin/brakeman --no-pager -q
  ```
  Expected: no warnings.

- [ ] **Step 4: Run bundler-audit.**

  Run:
  ```bash
  bin/bundler-audit check --update
  ```
  Expected: no insecure gems.

- [ ] **Step 5: Commit if rubocop auto-corrected anything.**

  Run:
  ```bash
  git add -A
  git status
  git commit -m "Rubocop auto-corrections post-rebrand

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>" || echo "nothing to commit"
  ```

---

### Task 2N: Final grep AC verification

**Files:** None (verification only)

Executes the issue's Acceptance Criteria greps. Must all pass before proceeding to Phase 3.

**Exemption note:** All greps below exempt three legitimate-mention paths: `docs/project-notes.md`, `docs/spec.md`, and `docs/superpowers/**`. See "Files exempted from the grep AC" in the inventory section above for rationale.

- [ ] **Step 1: Primary grep — optimus/mpi word-boundary.**

  Run:
  ```bash
  git ls-files \
    | grep -vE '^(\.yarn/releases/|yarn\.lock$|docs/project-notes\.md$|docs/spec\.md$|docs/superpowers/)' \
    | xargs rg -i '\b(mpi|optimus)\b'
  ```
  Expected: zero matches. If the `yarn.lock` still has `"optimus@workspace:."`, Task 2B Step 4's yarn install didn't rerun — redo it.

- [ ] **Step 2: Substring grep (broader than AC, catches `optimus_development` etc.).**

  Run:
  ```bash
  git ls-files \
    | grep -vE '^(\.yarn/releases/|yarn\.lock$|docs/project-notes\.md$|docs/spec\.md$|docs/superpowers/)' \
    | xargs rg -i '(mpi|optimus|mpimedia)'
  ```
  Expected: zero matches. This is stricter than the issue's AC and catches substring bugs (e.g., `optimus_storage` had we missed it).

- [ ] **Step 3: Sibling-repo grep.**

  Run:
  ```bash
  git ls-files \
    | grep -vE '^(docs/project-notes\.md$|docs/spec\.md$|docs/superpowers/)' \
    | xargs rg -i '\b(avails|sfa|garden|harvest)\b'
  ```
  Expected: zero matches. If `garden`/`harvest` appears in a legitimate non-repo context (English words), verify and leave; note in PR.

- [ ] **Step 4: `mpi_projects` key grep.**

  Run:
  ```bash
  git ls-files \
    | grep -vE '^(docs/project-notes\.md$|docs/spec\.md$|docs/superpowers/)' \
    | xargs rg 'mpi_projects'
  ```
  Expected: zero matches.

- [ ] **Step 5: Confirm no `mpimedia` org refs.**

  Run:
  ```bash
  git ls-files \
    | grep -vE '^(docs/project-notes\.md$|docs/spec\.md$|docs/superpowers/)' \
    | xargs rg -i 'mpimedia'
  ```
  Expected: zero matches.

- [ ] **Step 6: No commit — this is AC verification.**

  If all four greps are clean, Phase 2 is complete.

---

## **CHECKPOINT 2** — HC reviews rebrand

**HC action required before proceeding to Phase 3:**

1. Push the branch: `git push`.
2. Open a draft PR: `gh pr create --draft --title "Issue #1: Import Optimus template + rebrand to Baseline"`.
3. Review the diff in GitHub UI. Confirm:
   - No secret files in the diff.
   - Retention-list files' instructional content preserved (compare to original on `aaa/optimus-base`).
   - Deleted docs are genuinely MPI-specific.
   - CI on the draft PR is green.
4. Run all Task 2N greps locally once more.
5. If all good, decide on P2.D5 (squash the Phase 2 commits or preserve history).

**If OK:** give explicit go-ahead for Phase 3.
**If NOT OK:** either fix in-place (preferred) or `git reset` to a known-good commit and redo.

---

# Phase 3 — Kamal Hello-World Deploy

Deploys a Baseline container to the DigitalOcean droplet at `baseline.kc.tennis` with Let's Encrypt TLS. Requires P3.D1–P3.D5 settled and verified.

---

### Task 3A: Precondition verification

**Files:** None (verification only)

- [ ] **Step 1: DNS.**

  Run:
  ```bash
  dig +short baseline.kc.tennis
  ```
  Expected: a single IPv4 address matching the DO droplet's public IP.

- [ ] **Step 2: Droplet SSH reachability.**

  Run (replace `<droplet_ip>` with actual):
  ```bash
  ssh -o StrictHostKeyChecking=accept-new root@<droplet_ip> 'uname -a'
  ```
  Expected: kernel info output. If authentication fails, fix ssh keys and retry.

- [ ] **Step 3: Ports 80/443 open on droplet.**

  Run:
  ```bash
  ssh root@<droplet_ip> 'ss -tnlp | grep -E ":(80|443)"'
  ```
  Expected: nothing running on 80/443 yet (Kamal will bring up traefik). If something IS running (old deploy, nginx, etc.), resolve before proceeding.

- [ ] **Step 4: Container registry access.**

  Per P3.D3 decision:
  - **DO registry:** `doctl registry login` from local; confirm `doctl registry get` returns a registry.
  - **ghcr.io:** `echo $GHCR_PAT | docker login ghcr.io -u wrburgess --password-stdin`.
  - **Docker Hub:** `docker login`.

  No errors means access works.

- [ ] **Step 5: HC confirmation.**

  Pause and ask HC: "Are P3.D1 (DNS), P3.D2 (droplet), P3.D3 (registry) all set? Please confirm droplet IP and registry hostname."

  **Do not proceed until HC confirms with actual values.**

---

### Task 3B: Generate production credentials (Sentry DSN + Postmark token)

**Files:**
- Create: `config/credentials/production.yml.enc` (encrypted hash with Sentry + Postmark values)
- Create: `config/credentials/production.key` (gitignored)

**Depends on:** #14 complete — HC must have Sentry DSN and Postmark API token + verified sender email recorded in 1Password before this task runs.

- [ ] **Step 1: Remove any stale production credentials from Phase 1 exclusion miss.**

  Run:
  ```bash
  ls config/credentials/production.* 2>&1 || echo "OK: no stale production credentials"
  ```
  Expected: `OK: no stale production credentials`. If files exist, STOP — they are the template's secrets; delete immediately and re-verify Phase 1 exclusions.

- [ ] **Step 2: Retrieve values from 1Password.**

  Pull the values interactively so they're in your terminal history (you'll paste them in Step 3 and the shell history is acceptable for this short window — clear after):
  ```bash
  op read "op://Baseline/Baseline Sentry DSN/credential" --account=<your_account>
  op read "op://Baseline/Baseline Postmark Server Token/credential" --account=<your_account>
  ```
  Record the `sender_email` too (the verified Postmark sender like `noreply@baseline.kc.tennis`).

- [ ] **Step 3: Generate and populate production credentials.**

  Set your preferred editor and run:
  ```bash
  EDITOR="${EDITOR:-vi}" bin/rails credentials:edit --environment production
  ```

  In the editor, replace the contents with:
  ```yaml
  sentry:
    dsn: <PASTE_SENTRY_DSN_FROM_STEP_2>

  postmark:
    api_token: <PASTE_POSTMARK_SERVER_TOKEN_FROM_STEP_2>
    sender_email: noreply@baseline.kc.tennis  # or your verified Postmark sender address
  ```

  Save and exit. Rails encrypts the file with the newly-generated `config/credentials/production.key`.

- [ ] **Step 4: Verify credentials decrypt correctly.**

  Run:
  ```bash
  bin/rails credentials:show --environment production
  ```
  Expected: shows the decrypted YAML with `sentry.dsn` and `postmark.api_token` + `sender_email`.

- [ ] **Step 5: Verify the key is gitignored, encrypted file is tracked.**

  Run:
  ```bash
  git status --porcelain config/credentials/
  ```
  Expected:
  ```
  ?? config/credentials/production.yml.enc    # new, untracked
  ```
  (production.key must NOT appear — `.gitignore` entry `/config/credentials/*.key` covers it.)

  If `production.key` DOES appear, STOP — inspect `.gitignore` and fix before proceeding.

- [ ] **Step 6: Stage and commit only the encrypted file.**

  Run:
  ```bash
  git add config/credentials/production.yml.enc
  git commit -m "Add production credentials with Sentry DSN + Postmark token

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

- [ ] **Step 7: Save the key value to 1Password.**

  Read the key:
  ```bash
  cat config/credentials/production.key
  ```
  Expected: a 32-char hex string.

  **HC action:** store this value in 1Password as "Baseline Production Rails Master Key". This value will be injected as `RAILS_MASTER_KEY` via `.kamal/secrets` so the running container can decrypt `production.yml.enc`.

- [ ] **Step 8: Clear terminal history of the raw DSN/token.**

  Optional but recommended:
  ```bash
  history -c && history -w  # zsh: this clears current session's history
  ```

---

### Task 3C: Configure Kamal deploy.yml for DigitalOcean

**Files:**
- Modify: `config/deploy.yml` (servers, registry, proxy sections)
- Create: `.kamal/secrets` (local, gitignored, holds secret env refs)

- [ ] **Step 1: Verify `.kamal/secrets` is gitignored.**

  Run:
  ```bash
  grep -n '.kamal/secrets' .gitignore || echo "NOT IGNORED"
  ```
  If `NOT IGNORED`, append `/.kamal/secrets` to `.gitignore`, stage and commit. Per Kamal 2 default, the template may not gitignore this — verify explicitly.

- [ ] **Step 2: Edit `config/deploy.yml` — servers.**

  Replace line 10 (`- 192.168.0.1`) with the actual droplet IP from P3.D2.

- [ ] **Step 3: Edit `config/deploy.yml` — registry.**

  Uncomment and fill `registry:` block. Per P3.D3 = DO (example):
  ```yaml
  registry:
    server: registry.digitalocean.com
    username:
      - KAMAL_REGISTRY_USERNAME
    password:
      - KAMAL_REGISTRY_PASSWORD
  ```

  Update `image:` on line 5 to include registry namespace: `image: <do_registry_name>/baseline`.

- [ ] **Step 4: Edit `config/deploy.yml` — proxy (TLS).**

  Uncomment and configure lines 23–25:
  ```yaml
  proxy:
    ssl: true
    host: baseline.kc.tennis
  ```

- [ ] **Step 5: Edit `config/deploy.yml` — volumes verification.**

  Line 65 should already read `- "baseline_storage:/rails/storage"` (done in Task 2B).

- [ ] **Step 6: Add production.rb SSL + SMTP config.**

  Edit `config/environments/production.rb`:

  a) **SSL:** Confirm `config.assume_ssl = true` and `config.force_ssl = true` are set (Rails 8.1 templates default these on). Uncomment if needed.

  b) **Postmark SMTP:** Add (or replace existing mailer config):
  ```ruby
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: "baseline.kc.tennis", protocol: "https" }
  config.action_mailer.smtp_settings = {
    address:              "smtp.postmarkapp.com",
    port:                 587,
    user_name:            Rails.application.credentials.dig(:postmark, :api_token),
    password:             Rails.application.credentials.dig(:postmark, :api_token),
    authentication:       :plain,
    enable_starttls_auto: true
  }
  ActionMailer::Base.default from: Rails.application.credentials.dig(:postmark, :sender_email)
  ```

  Postmark uses the Server API Token as both SMTP username and password — not a typo.

- [ ] **Step 7: Add DATABASE_URL to deploy.yml env.secret.**

  Edit `config/deploy.yml` `env.secret:` list so it reads:
  ```yaml
  env:
    secret:
      - RAILS_MASTER_KEY
      - DATABASE_URL
  ```
  This makes Kamal inject `DATABASE_URL` from `.kamal/secrets` into the running container as an env var, which `config/database.yml` production block reads.

- [ ] **Step 8: Create `.kamal/secrets`.**

  Pull values from 1Password into environment variables in your shell, then create the secrets file:
  ```bash
  # Put these in your current shell from 1Password (or export in ~/.zshrc)
  export DB_URL=$(op read "op://Baseline/Baseline Production DATABASE_URL/credential" --account=<your_account>)
  ```

  Create `.kamal/secrets` with:
  ```bash
  KAMAL_REGISTRY_USERNAME=$(doctl registry token | jq -r .access_token)
  KAMAL_REGISTRY_PASSWORD=$(doctl registry token | jq -r .access_token)
  RAILS_MASTER_KEY=$(cat config/credentials/production.key)
  DATABASE_URL=$DB_URL
  ```

  Notes:
  - DO registry: the token is used for both username and password (Kamal 2 pattern).
  - Adjust for ghcr.io or Docker Hub per P3.D3.
  - Do NOT hardcode the actual `DATABASE_URL` string in this file — pull from 1Password at deploy time via env var expansion.

  Run:
  ```bash
  chmod 600 .kamal/secrets
  ```

- [ ] **Step 9: Verify `.kamal/secrets` is gitignored.**

  Run:
  ```bash
  git check-ignore .kamal/secrets && echo "OK: gitignored" || echo "NOT IGNORED"
  ```
  Expected: `OK: gitignored`. If `NOT IGNORED`, append `/.kamal/secrets` to `.gitignore`, stage, commit.

- [ ] **Step 10: Commit deploy + production config.**

  Run:
  ```bash
  git add config/deploy.yml config/environments/production.rb .gitignore
  git commit -m "Configure Kamal deploy for DO + Postmark SMTP + DATABASE_URL injection

- deploy.yml: real droplet IP, DO registry, Let's Encrypt via proxy.ssl
- production.rb: Postmark SMTP via credentials.postmark.api_token
- env.secret includes DATABASE_URL for the managed Postgres connection

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

---

### Task 3D: First deploy

**Files:** None (deployment only)

- [ ] **Step 1: Kamal setup (first run only).**

  Run:
  ```bash
  bin/kamal setup
  ```
  Expected: builds Baseline image, pushes to registry, SSH into droplet, installs Docker (if missing), provisions traefik proxy, starts the container.

  This command can take 5–15 minutes on first run. Monitor output.

- [ ] **Step 2: Verify container running on droplet.**

  Run:
  ```bash
  ssh root@<droplet_ip> 'docker ps --filter name=baseline'
  ```
  Expected: a running container named `baseline-web-<hash>`.

- [ ] **Step 3: Verify site responds.**

  Run:
  ```bash
  curl -I https://baseline.kc.tennis
  ```
  Expected: `HTTP/2 200` (or `302` redirect to a login page). If `525` or `SSL handshake failed`, Let's Encrypt may still be provisioning — wait 2 minutes and retry. If `Connection refused`, check port 443 + traefik logs:
  ```bash
  ssh root@<droplet_ip> 'docker logs kamal-proxy'
  ```

- [ ] **Step 4: Open site in browser.**

  Visit `https://baseline.kc.tennis` in a browser. Confirm TLS is valid (Let's Encrypt issued), default Rails page loads (likely a Devise login or Rails welcome).

- [ ] **Step 5: No commit yet — state is remote only.**

---

### Task 3E: Seed `system_manager` role and verify admin access

**Files:**
- Possibly modify: `db/seeds.rb` or add a maintenance task (depends on what the template ships).

- [ ] **Step 1: Inspect template seeds.**

  Read:
  ```bash
  cat db/seeds.rb
  ls db/seeds/ 2>/dev/null
  ```
  Expected: seeds file exists and creates a `system_manager` role. If not, add a seed block:
  ```ruby
  # Ensure baseline system_manager exists for initial admin access
  user = User.find_or_create_by!(email: "wrburgess@gmail.com") do |u|
    u.password = SecureRandom.hex(16)  # HC resets via Devise password reset flow
  end

  role = SystemRole.find_or_create_by!(name: "system_manager")
  # Grant role to user via existing join model (verify join table name/API from app/models)
  ```

  **Do not invent the join API** — read `app/models/system_role.rb`, `app/models/system_group.rb`, `app/models/user.rb` to learn the actual assignment pattern, then code accordingly.

- [ ] **Step 2: Seed production.**

  Run:
  ```bash
  bin/kamal app exec 'bin/rails db:seed'
  ```
  Expected: seed runs without error. If the seed errors because `system_manager` or the user join API isn't quite right, adjust `db/seeds.rb`, commit, redeploy (`bin/kamal deploy`), and retry.

- [ ] **Step 3: Reset the HC user's password via Devise.**

  Since `db/seeds.rb` sets a random password, trigger Devise's reset flow (Postmark SMTP is configured in Task 3C Step 6):
  - Visit `https://baseline.kc.tennis/users/password/new` in a browser.
  - Enter `wrburgess@gmail.com`.
  - Postmark delivers the reset email to your inbox (check Postmark's Activity panel if it doesn't arrive within ~1 min — the sandbox may still be restricting recipients).
  - Click the link and set a password.

  **Fallback:** If the Postmark sender domain is still in sandbox / hasn't finished DNS verification, pull the reset URL directly from container logs:
  ```bash
  bin/kamal app logs | grep -A2 'password_resets'
  ```
  Copy the link and paste into your browser.

- [ ] **Step 4: Log in and verify admin engines.**

  Browse to `https://baseline.kc.tennis/admin`. Confirm:
  - Login succeeds with `wrburgess@gmail.com`.
  - Admin dashboard renders.
  - Per P3.D5 (interpretation A): click each of the 4 production-visible engines and confirm they load:
    - Blazer (`/admin/blazer`)
    - GoodJob (`/admin/good_job`)
    - Maintenance Tasks (`/admin/maintenance_tasks`)
    - PgHero (`/admin/pg_hero`)

- [ ] **Step 5: Verify role assignment from console.**

  Run:
  ```bash
  bin/kamal app exec --interactive --reuse 'bin/rails runner "puts User.find_by(email: %(wrburgess@gmail.com)).system_manager?"'
  ```
  Expected: `true`.

- [ ] **Step 6: Verify no other user has system_manager role.**

  Run:
  ```bash
  bin/kamal app exec --interactive --reuse 'bin/rails runner "puts User.where.not(email: %(wrburgess@gmail.com)).select { |u| u.system_manager? }.map(&:email)"'
  ```
  Expected: empty array (or empty output).

- [ ] **Step 7: Commit any seeds/production config changes.**

  Run:
  ```bash
  git add -A
  git status
  git commit -m "Seed system_manager role for wrburgess@gmail.com

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>" || echo "nothing to commit"
  ```

---

### Task 3F: Dev-mode engines smoke test (per P3.D5 interpretation A)

**Files:** None (local verification only)

- [ ] **Step 1: Boot locally.**

  Run:
  ```bash
  bin/dev
  ```
  Expected: dev server up at `http://localhost:3000` (or whatever port the Procfile sets).

- [ ] **Step 2: Log in and verify all 6 engines render in dev.**

  Browse to `http://localhost:3000/admin`, log in, confirm 6 engines load: Blazer, GoodJob, MaintenanceTasks, PgHero, Lookbook, RailsDb.

- [ ] **Step 3: Stop local server.**

  Ctrl-C out of `bin/dev`.

---

### Task 3G: Final Phase 3 commit sweep + push

**Files:** None (git only)

- [ ] **Step 1: Status check.**

  Run:
  ```bash
  git status
  ```
  Expected: clean.

- [ ] **Step 2: Push.**

  Run:
  ```bash
  git push
  ```

- [ ] **Step 3: Update PR description with Phase 3 results.**

  Run:
  ```bash
  gh pr view --web
  ```
  Add a comment or update description noting:
  - Kamal deploy succeeded.
  - `https://baseline.kc.tennis` live with valid TLS.
  - Admin engines verified in production.
  - system_manager role seeded correctly.

---

## **CHECKPOINT 3** — Final review and merge

**HC action:**

1. Full walk-through of the deployed site.
2. Final re-run of all Task 2N greps on the PR branch HEAD.
3. Confirm CI green.
4. Per P2.D5, squash Phase 2 commits into one (if desired) via:
   ```bash
   git rebase -i origin/main
   ```
   And mark all Phase 2 commits as `squash` under a single `Rebrand Optimus → Baseline; strip MPI references` message. Force-push.
5. Merge the PR.
6. Tag: `git tag v0.1.0-baseline-bootstrap && git push --tags`.
7. Close Issue #1.

---

## Post-merge followups (file as separate issues)

- **Future — Full Kamal deploy pipeline:** staging environment, deploy notifications, rollback runbooks.
- **Future — CI secrets setup** for GitHub Actions (if workflows require any).
- **Future — Sentry source maps** for JavaScript error decoding (requires esbuild source map upload at build time).
- **Future — Staging environment** with separate Postmark sender domain + separate Sentry project/environment.
- **Future — Re-evaluate lightly-edited docs** (e.g., `docs/architecture/agent-workflow.md`) for Baseline-specific clarity.

(Postmark SMTP and Sentry error tracking are in-scope for this issue via #14 — no longer followups.)

---

## Appendix A — Exclusion list one-liner reference

```bash
EXCLUDES=(
  --exclude='.git/'
  --exclude='node_modules/'
  --exclude='tmp/'
  --exclude='log/'
  --exclude='coverage/'
  --exclude='storage/'
  --exclude='public/assets/'
  --exclude='.bundle/'
  --exclude='vendor/bundle/'
  --exclude='.env'
  --exclude='.env.*'
  --exclude='.DS_Store'
  --exclude='.mcp.json'
  --exclude='.honeybadger-cli.yaml'
  --exclude='config/credentials/*.key'
  --exclude='config/*.key'
  --exclude='config/credentials/*.yml.enc'
  --exclude='.claude/settings.local.json'
  --exclude='.claude/projects.local.json'
  --exclude='.claude/worktrees/'
  --exclude='.byebug_history'
  --exclude='spec/examples.txt'
)
```

## Appendix B — Grep AC one-liner reference

All greps exempt: `.yarn/releases/`, `yarn.lock`, `docs/project-notes.md`, `docs/spec.md`, `docs/superpowers/`.

```bash
EXEMPT='^(\.yarn/releases/|yarn\.lock$|docs/project-notes\.md$|docs/spec\.md$|docs/superpowers/)'

# Primary (per issue AC)
git ls-files | grep -vE "$EXEMPT" | xargs rg -i '\b(mpi|optimus)\b'

# Substring-strict (catches `optimus_development` etc.)
git ls-files | grep -vE "$EXEMPT" | xargs rg -i '(mpi|optimus|mpimedia)'

# Sibling repos
git ls-files | grep -vE "$EXEMPT" | xargs rg -i '\b(avails|sfa|garden|harvest)\b'

# Legacy key refs
git ls-files | grep -vE "$EXEMPT" | xargs rg 'mpi_projects'
```

All four must return zero matches before Phase 2 completes.
