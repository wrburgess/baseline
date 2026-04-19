Execute the implementation plan for GitHub issue #$ARGUMENTS.

This is **Stage 3** of the MPI Development Lifecycle (see `docs/standards/development-lifecycle.md`).

## Steps

1. **Read the issue, plan, and agent strategy** using `gh issue view $ARGUMENTS --comments`
2. **Check current branch** — if on `main`, create the feature branch specified in the plan
3. **Execute each task** in the planned order:
   - Write or modify code following patterns in `docs/architecture/overview.md` and `CLAUDE.md`
   - Write or update specs following the testing strategy defined in the plan and `.claude/rules/testing.md`
   - Read existing code in the relevant area before writing — discover patterns from the codebase
   - Use `authorize` in all admin controller actions
   - Use tom-select for admin form selects, floating_label_form for other inputs
   - Include `Loggable` concern for audit trails on new models
   - Follow the enumerable pattern for new status/type constants (see `app/modules/` for examples)
4. **Run quality checks**:
   ```bash
   bundle exec rubocop -a
   bundle exec rspec
   bin/brakeman --no-pager -q
   bin/bundler-audit check
   ```
   Fix any failures before proceeding.
5. **Self-review before PR** — apply `.claude/rules/self-review.md` checklist and fix anything that fails:
   - [ ] Every item in the plan is implemented
   - [ ] Every test scenario from the plan's testing strategy is covered
   - [ ] Model specs: all validations, associations, scopes, callbacks, public methods, enums
   - [ ] Request specs: response content, DB side effects, authorization (3 contexts), flash/redirects
   - [ ] Feature specs: at least one per controller action type, covering input types
   - [ ] Edge cases: invalid params, duplicates, boundary values
   - [ ] "What would a critical external reviewer flag here?" — read every test and ask: "If this test passed but the feature was broken, would I know?"
   - [ ] No "TODO" or "needs manual testing" comments — if something seems untestable, research the stack (Capybara, Selenium CDP, VCR) before claiming it
   - [ ] All four checks pass (`bundle exec rubocop -a`, `bundle exec rspec`, `bin/brakeman --no-pager -q`, `bin/bundler-audit check`)
6. **Commit with detailed message** following the format in `CLAUDE.md`
7. **Push and create PR**:
   - Push branch with `git push -u origin <branch>`
   - Create PR with `gh pr create` using the format in `CLAUDE.md`
   - Link to the issue with `Closes #$ARGUMENTS`
8. **Post implementation notes on the PR** as a comment documenting what was done, decisions made during implementation, and anything the reviewer should pay attention to
9. **Post a brief update on the issue** linking to the PR (e.g., "Implementation PR: #NNN")

## Next Step

After PR is created, HC runs `/verify $ARGUMENTS` for Stage 4 self-review against the plan.

## Quality Gates

Do NOT create the PR until:
- [ ] `bundle exec rubocop -a` passes with no offenses
- [ ] `bundle exec rspec` passes with no failures
- [ ] `bin/brakeman --no-pager -q` passes with no new warnings
- [ ] `bin/bundler-audit check` passes with no vulnerabilities
- [ ] All planned tasks are complete
- [ ] Self-review checklist (step 5) is complete
- [ ] Commit message follows CLAUDE.md format
- [ ] PR description includes Summary, Changes, Technical Approach, Testing, and Checklist sections

## Attribution

Include `— Claude Code (Opus 4.6)` (or current model) at the bottom of any GitHub comments.
