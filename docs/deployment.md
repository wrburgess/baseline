# Deployment

Baseline deploys via [Kamal 2](https://kamal-deploy.org/) to a DigitalOcean droplet at `https://baseline.kc.tennis`.

## Configuration

- Kamal config: [`config/deploy.yml`](../config/deploy.yml)
- Per-environment Rails credentials: `config/credentials/*.yml.enc` (encryption keys are gitignored — fetch via `bin/setup-credentials`)
- Production secrets injected at deploy time: `.kamal/secrets` (gitignored)

## Commands

```bash
bin/kamal setup        # first-time provisioning of the droplet
bin/kamal deploy       # build, push image, restart container
bin/kamal app logs -f  # tail production logs
bin/kamal app exec --interactive --reuse 'bin/rails console'
```

## Hello-world deploy

The initial deploy of Baseline (Issue #1, Phase 3) is documented in the implementation plan: [`docs/superpowers/plans/2026-04-19-issue-1-import-rebrand-deploy.md`](superpowers/plans/2026-04-19-issue-1-import-rebrand-deploy.md). Operational preconditions (droplet, registry, DNS, Postmark, Sentry) are in [Issue #14](https://github.com/wrburgess/baseline/issues/14).

## Future work

- Staging environment
- Deploy notifications
- Rollback runbook
