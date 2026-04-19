# Optimus

A Ruby on Rails application template and reference implementation for the MPI Media ecosystem.

## Getting Started

- **New to the project?** Start with the [Human Collaborator Guide](docs/hc-guide.md) — covers your role, the development workflow, commands, what to review, and environment setup.

## Cross-Repository Context Setup (Optional)

This repository is part of a multi-repo ecosystem (avails, sfa, garden, harvest, optimus). To enable Claude Code to seamlessly reference and work with code across all related repositories:

1. Create `.claude/projects.local.json` in the project root (this file is gitignored):

```json
{
  "local_paths": {
    "avails": "/path/to/your/avails_server",
    "sfa": "/path/to/your/wpa_film_library",
    "garden": "/path/to/your/garden",
    "harvest": "/path/to/your/harvest",
    "optimus": "/path/to/your/optimus"
  }
}
```

2. Replace each path with your actual local directory paths

**Benefits:**
- Claude Code can reference patterns from other repos (e.g., "how does avails handle authorization?")
- Enable cross-repo code replication and consistency
- Faster file access compared to fetching from GitHub

**Note:** This is optional. If you don't create this file, Claude Code can still work using the GitHub URLs defined in `.claude/projects.json`.

## 1Password CLI Setup

MCP servers and other tools require API keys that are stored in the shared **Application Development** vault on 1Password. Secrets are loaded into your shell via `op read` at startup — no plaintext credentials on disk.

### Prerequisites

1. Install 1Password CLI: `brew install --cask 1password-cli`
2. Enable CLI integration in the 1Password app: **Settings > Developer > Integrate with 1Password CLI**
3. Enable biometric unlock: **Settings > Developer > Biometric unlock for 1Password CLI**
4. Verify access: `op vault list --account=mpimediagroup.1password.com`

### Environment Variables

Add the following to your `~/.zshrc` (already included in the team [dotfiles](https://github.com/wrburgess/dotfiles)):

```bash
if command -v op &>/dev/null; then
  export CONTEXT7_API_KEY=$(op read "op://Application Development/Context7 API Key/credential" --account=mpimediagroup.1password.com 2>/dev/null)
  export GITHUB_COPILOT_MCP_TOKEN=$(op read "op://Application Development/GitHub Copilot MCP Token/credential" --account=mpimediagroup.1password.com 2>/dev/null)
  export HEROKU_API_KEY=$(op read "op://Application Development/Heroku API Key/credential" --account=mpimediagroup.1password.com 2>/dev/null)
  export AWS_ACCESS_KEY_ID=$(op read "op://Application Development/AWS MCP Credentials/Access Key ID" --account=mpimediagroup.1password.com 2>/dev/null)
  export AWS_SECRET_ACCESS_KEY=$(op read "op://Application Development/AWS MCP Credentials/Secret Access Key" --account=mpimediagroup.1password.com 2>/dev/null)
  export AWS_REGION=$(op read "op://Application Development/AWS MCP Credentials/Region" --account=mpimediagroup.1password.com 2>/dev/null)
  export HONEYBADGER_API_KEY=$(op read "op://Application Development/Honeybadger API Key/credential" --account=mpimediagroup.1password.com 2>/dev/null)
  export CLOUDFLARE_TUNNEL_TOKEN=$(op read "op://Application Development/Cloudflare Tunnel Token/credential" --account=mpimediagroup.1password.com 2>/dev/null)
fi
```

After adding, run `source ~/.zshrc` to load the secrets.

## MCP Server Setup

MCP servers provide Claude Code with access to external tools (GitHub, Heroku, AWS, Honeybadger, etc.). The configuration uses `${ENV_VAR}` references so no plaintext secrets are stored in the repo.

### Setup

1. Complete the **1Password CLI Setup** above
2. Copy the example config: `cp .mcp.json.example .mcp.json`
3. The `.mcp.json` file is gitignored — your local copy references env vars loaded by 1Password CLI

**Note:** Due to a [known Claude Code issue](https://github.com/anthropics/claude-code/issues/6204), `${ENV_VAR}` expansion in HTTP headers may not work. If the Context7 or GitHub MCP servers fail to authenticate, replace `${CONTEXT7_API_KEY}` and `${GITHUB_COPILOT_MCP_TOKEN}` in your local `.mcp.json` with the actual values from 1Password.

### Available MCP Servers

| Server | Type | Purpose |
|--------|------|---------|
| context7 | HTTP | Documentation context for Claude Code |
| github | HTTP | GitHub Copilot MCP for repo access |
| heroku | CLI | Heroku app management |
| awslabs-aws-api-mcp-server | CLI | AWS services (read-only) |
| honeybadger | CLI | Error monitoring (SFA, Avails, Garden, Harvest) |

## Credentials

- See the [Credentials Management](docs/credentials_management.md) document

## Dependency Management

- See the [Dependency Management](docs/dependency_management.md) document

## System Permissions

- See the [System Permissions](docs/system_permissions.md) document for the authorization system

## Notification System

- See the [Notification System](docs/notification_system.md) document
