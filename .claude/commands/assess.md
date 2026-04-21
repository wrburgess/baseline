Review GitHub issue #$ARGUMENTS and prepare an assessment for the Human Contributor (HC).

This is **Stage 1** of the Baseline Development Lifecycle (see `docs/standards/development-lifecycle.md`).

## Steps

1. **Read the issue** using `gh issue view $ARGUMENTS --comments` — capture the title, description, labels, milestone, and any existing comments
2. **Check for duplicates and related work**:
   - Search for related issues: `gh issue list --search "<keywords from issue title>" --state all --limit 10`
   - Search for related PRs: `gh pr list --search "<keywords from issue title>" --state all --limit 10`
   - If duplicates or related work are found, note them in the assessment and ask the HC whether to proceed or consolidate
3. **Read architecture context**:
   - Start with `docs/architecture/overview.md` for system context
   - Read system-specific docs if the issue touches:
     - Authorization → `docs/system_permissions.md` + `docs/system_permissions_agent_guide.md`
     - Notifications → `docs/notification_system.md` + `docs/notification_system_agent_guide.md`
     - Deployment → `docs/deployment.md`
     - Assets/frontend → `docs/asset_pipeline.md`
4. **Explore the codebase** — read the files and systems that would be affected. Trace models, controllers, views, concerns, specs, and routes. Focus on understanding the current state.
5. **Check test coverage** for affected areas — look at existing specs to understand what's covered and what gaps a change might introduce
6. **Identify project-specific concerns**:
   - Does this need a migration? → Check `strong_migrations` constraints
   - Does this touch authorization? → Check Pundit policies and `SystemPermissions`
   - Does this add a model? → Consider `Archivable`, `Loggable`, `Notifiable` concerns
   - Does this add status/type values? → Follow the enumerable pattern
   - Does this touch admin views? → Check ViewComponent patterns, tom-select usage
7. **Research Rails ecosystem solutions** — before proposing custom implementations:
   - Check if Rails conventions already solve the problem (built-in ActiveRecord features, concerns, validations)
   - Search for established gems that address the need (check RubyGems, Ruby Toolbox, community recommendations)
   - Reference `.claude/rules/backend.md` for gem preferences
   - List what was considered in the assessment, even if rejected
8. **Identify unknowns** — list anything ambiguous or underspecified in the issue
9. **Ask clarifying questions** — if there are gaps in the requirements, ask the HC before proceeding (ask, don't guess)

## Complexity Criteria

- **Small** — 5 files or fewer, no migrations, no authorization changes, single subsystem
- **Medium** — 6-15 files, may include migration, touches 2-3 subsystems, single agent
- **Large** — 15+ files, multiple migrations, authorization changes, cross-cutting concerns → recommend `/orch` for parallel agents

**Compressed workflows** (HC decides, not AC): Trivial fixes (typos, config) may skip Plan; documentation-only changes may skip Assess and Plan. See lifecycle doc for details.

## Rules References

When assessing, consult these rules as relevant:
- `.claude/rules/backend.md` — Rails ecosystem, gem preferences, authorization patterns
- `.claude/rules/testing.md` — Testing coverage requirements (affects scope estimates)
- `.claude/rules/migrations.md` — Migration safety constraints (affects risk assessment)
- `.claude/rules/security.md` — Security scanning requirements

## Output Format

Post the assessment as a comment on the issue using `gh issue comment $ARGUMENTS --body "..."`.

Also display the assessment in the conversation so the HC can discuss before choosing an option.

Use this template for the GitHub comment:

```markdown
## Issue Assessment

### Summary
[What the issue is asking for in clear terms]

### Systems Affected
| System | Files/Areas | Impact |
|--------|-------------|--------|
| [e.g., Models] | [e.g., `app/models/foo.rb`] | [e.g., New model with associations] |

### Complexity: [Small | Medium | Large]
- [Key factors driving complexity]

### Related Issues/PRs
- [List any related work found, or "None found"]

### Project-Specific Considerations
- [Migration safety, authorization, concerns, patterns — or "None"]

### Open Questions
- [Anything ambiguous that needs HC input — or "None"]

### Risk Assessment
- [What could go wrong, what's the blast radius of this change]

### Implementation Options

#### Option A: [Name]
- **Approach:** [Description]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Risk:** [What could go wrong with this approach]
- **Estimated scope:** [files, specs, migrations]

#### Option B: [Name]
- **Approach:** [Description]
- **Pros:** [Benefits]
- **Cons:** [Drawbacks]
- **Risk:** [What could go wrong with this approach]
- **Estimated scope:** [files, specs, migrations]

### Recommendation
Option [X] because [rationale].

### Next Step
HC: Send this assessment to Reviewer for validation, then reply with your chosen option and run `/cplan $ARGUMENTS` to generate the implementation plan.

— Claude Code (Opus 4.6)
```

## Quality Standard

Before posting the assessment, self-review:
- Did I research the codebase or just guess based on the issue description?
- Are my options genuinely different approaches, or variations of the same thing?
- Did I identify risks that could waste time during implementation?
- Would a critical reviewer find gaps in my analysis?

## Attribution

Include `— Claude Code (Opus 4.6)` (or current model) at the bottom of the GitHub comment per CLAUDE.md agent attribution requirements.
