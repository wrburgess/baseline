# Credentials Management

## Per-Environment Credentials

Baseline uses per-environment encrypted credentials — each environment has its own encrypted file and its own key:

| Environment | Encrypted File | Key File |
|-------------|---------------|----------|
| Development | `config/credentials/development.yml.enc` | `config/credentials/development.key` |
| Staging | `config/credentials/staging.yml.enc` | `config/credentials/staging.key` |
| Production | `config/credentials/production.yml.enc` | `config/credentials/production.key` |

The `.yml.enc` files are checked into git. The `.key` files are gitignored and must never be committed.

## Why Per-Environment (Not a Global `master.key`)

Rails supports a global `config/credentials.yml.enc` decrypted by a single `master.key`, but we use per-environment files because:

- **Access isolation** — The development key cannot decrypt production secrets. Only team members who need production access receive the production key.
- **Reduced blast radius** — A leaked development key does not compromise production.
- **No merging confusion** — Rails does not merge global and per-environment files. When a per-environment file exists, the global file is completely ignored. Using only per-environment files eliminates this foot-gun.

## Setting Up Keys

### Automated (1Password CLI)

```bash
bin/setup-credentials          # Fetches development key only
bin/setup-credentials --all    # Fetches development, staging, and production keys
```

Requires the [1Password CLI](https://developer.1password.com/docs/cli/) with CLI integration enabled (1Password app > Settings > Developer > Integrate with 1Password CLI).

### Manual

Ask a team member for the key, or retrieve it from the "Application Development" vault in 1Password:

The 1Password account is configured via the `BASELINE_OP_ACCOUNT` env var (see `bin/setup-credentials`). Keys are stored under the "Application Development" vault in the configured account.

| 1Password Item | Field |
|---------------|-------|
| Baseline Development Key | `credential` |
| Baseline Staging Key | `credential` |
| Baseline Production Key | `credential` |

Place the key value in the corresponding file (e.g., `config/credentials/development.key`).

## Editing Credentials

```bash
bin/rails credentials:edit --environment development
```

This opens the decrypted YAML in your editor. Save and close to re-encrypt. The command also creates the key file if it doesn't exist yet.

## Viewing Credentials

```bash
bin/rails credentials:show --environment development
```

## Deployment

Staging and production deployments receive their key via the `RAILS_MASTER_KEY` environment variable. Despite the name, this variable decrypts whichever per-environment file matches `Rails.env`. Kamal reads this from `config/credentials/production.key` via `.kamal/secrets`. Ensure the key file is present locally before deploying — fetch it with `bin/setup-credentials --all`.

## Adding a New Secret

1. Edit the credentials file for each environment that needs the secret
2. Reference it in code via `Rails.application.credentials.dig(:section, :key)`
3. Commit the updated `.yml.enc` files (the key files don't change)

## Reference

- [Rails Security Guide — Environment Credentials](https://guides.rubyonrails.org/security.html#environment-credentials)
