# Research Documentation

This directory contains vetted research on AI agent workflows, best practices, and anti-patterns sourced from credible, independent references.

## Contents

| Document | Purpose |
|----------|---------|
| [ai-best-practices.md](ai-best-practices.md) | Vetted source registry — sources, assessments, findings, traceability matrix |
| [codex-configuration.md](codex-configuration.md) | Codex CLI configuration audit, Codex vs Claude Code comparison, review role optimization |

## Re-scan Schedule

**Cadence:** Every 2 weeks

Research is re-scanned on a 2-week cadence to keep pace with rapidly evolving AI tooling. Each scan:

1. Searches for new credible sources across all 5 research areas
2. Re-validates existing sources for staleness or superseded findings
3. Updates confidence levels based on new corroborating (or contradicting) evidence
4. Commits updates and creates a PR for HC review

**Scheduling mechanism:** Primary mechanism is a scheduled GitHub Actions workflow invoking `claude -p`. Desktop Cowork scheduled tasks supplement for individual developer cadences. Manual execution via `claude -p` with the research re-scan prompt as fallback. A dedicated `/rescan` skill is planned but not yet implemented.

## Quality Gate Rubric

### Recency Cutoff

Sources must be from 2024 or later. AI tooling changes fast — stale advice is dangerous.

### Evidence Level

Claims must cite data, benchmarks, or concrete production examples. "This felt productive" is not evidence.

### Cross-Source Corroboration

High-confidence findings require 2+ independent sources. Single-source claims are flagged with lower confidence.

### Source Composition

Majority of sources must be independent (non-vendor). First-party docs (Anthropic, OpenAI) establish platform capabilities; independent sources validate effectiveness claims.

### Confidence Tiers

| Tier | Criteria |
|------|----------|
| **High** | Multiple independent sources with evidence, cross-corroborated |
| **Medium** | Single credible source with evidence, or multiple sources without hard data |
| **Low** | Single source, limited evidence, or vendor-only claim |

### Validation Checklist (per source)

- [ ] Does the author have verifiable professional experience?
- [ ] Is the methodology described and reproducible?
- [ ] Are claims backed by data, benchmarks, or concrete examples?
- [ ] Does it address real production workflows (not toy examples)?
- [ ] Is the content current (2024 or later)?
- [ ] Does the author acknowledge limitations and tradeoffs?
