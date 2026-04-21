# Testing Rules

Applies to: `spec/`

## Testing Mindset

- Never claim a behavior "can't be tested" or "needs manual testing" without first attempting it with the existing stack (RSpec, Capybara, Selenium CDP, FactoryBot, VCR, WebMock)
- If a test requires new infrastructure (helpers, shared contexts, CDP calls, VCR cassettes), build it — that's part of the work, not a reason to skip it
- Before declaring work done, self-review: "What gaps would a critical code reviewer flag here?"
- A passing test that only checks status codes is a false green — assert behavior, side effects, and content
- When touching a spec file, fix specs directly related to the current work and flag other gaps as separate issues

## Definition of Done

No implementation is complete until:

1. Model specs cover all validations, associations, scopes, callbacks, and public methods
2. Enumerable modules test every enum value and its behavior
3. Request specs assert response content, database side effects, authorization, and flash/redirects
4. Feature specs cover at least one browser-level scenario per controller action type
5. Error cases are tested: invalid params, duplicates, boundary values, concurrent operations
6. External HTTP calls use VCR cassettes (no live calls in tests)
7. The spec file follows the strict naming convention (see below)
8. A self-review pass has been completed before declaring done

## Framework

- RSpec with FactoryBot — never use fixtures
- Request specs for controllers — never use controller specs
- Capybara for feature specs (`:rack_test` by default; use Selenium driver for `js: true` / browser-based scenarios)
- VCR for any external HTTP call anywhere in the suite — configuration lives in `spec/support/vcr.rb` (create it if missing) with `cassette_library_dir` and WebMock hooks
- WebMock to prevent accidental live HTTP calls
- SimpleCov coverage: enforced in CI with branch coverage using a ratcheting baseline (currently 66%; long-term target 90%)
- Bullet for N+1 detection — `Bullet.raise = true` in test so specs fail immediately on N+1/unused eager loading

## Model Specs

Test **all** of the following for every model:

- **Factory validity** — `create(:model_name)` produces a persisted, valid instance
- **Associations** — every association exists and dependent behavior works (e.g., archiving cascades)
- **Validations** — every validation, including custom validators
- **Scopes** — every named scope returns expected records
- **Callbacks** — every callback's side effects
- **Public methods** — every public instance and class method
- **Enumerables** — every enum value, its predicate, and its behavior
- **Shared examples** — `it_behaves_like "archivable"`, `"loggable"`, etc. for included concerns

## Request Specs

Every request spec must test three authorization contexts:

1. **Authenticated and authorized** — action succeeds
2. **Not authenticated** — redirects to sign-in
3. **Authenticated but unauthorized** — HTML/admin controllers return `401 Unauthorized` (rendered via `ApplicationController#user_not_authorized`); API/JSON endpoints return the status the endpoint is implemented to return

Within the authorized context, assert all of the following:

- **Response content** — key content present in body (record name, JSON keys)
- **Database side effects** — record created/updated/archived with correct attributes
- **Flash messages** — correct success/error messages
- **Redirect targets** — correct redirect path after create/update/destroy
- **Error cases** — invalid params return errors, missing records return 404

## Feature Specs (Capybara/Selenium)

**Minimum coverage floor:**

- At least one feature spec per controller action type (create, edit/update, show, index, archive)
- At least one spec exercising each input type used in admin forms: `tom_select`, text field, textarea, boolean switch, datepicker
- Complex admin forms (multi-step, conditional fields, dynamic behavior) get deeper case-by-case coverage

**What feature specs must assert:**

- Form submission creates/updates the record with correct attributes
- Validation errors display in the browser
- Flash messages appear after actions
- Navigation and redirects work correctly
- JavaScript-dependent behavior (Stimulus controllers, Turbo frames) functions as expected

**Never deflect feature spec work.** Selenium supports CDP (`execute_cdp`), JavaScript execution, cookie manipulation, and header injection. Research capabilities before claiming a scenario can't be tested.

## API Specs (JWT Bearer Controllers)

Same depth as admin request specs, plus:

- **VCR cassettes** for any external API calls
- **Authentication edge cases** — expired token, missing token, malformed token
- **Rate limiting / pagination** — if applicable, test boundary behavior
- **Response schema validation** — assert JSON structure matches the expected contract, not just status codes

## Policy Specs

- Test both grant and deny for every action (`index?`, `show?`, `new?`, `create?`, `edit?`, `update?`, `destroy?`, `archive?`, `unarchive?`)
- Use `policy_setup` shared context
- See `docs/standards/testing.md` for structure

## Job Specs

- Test with `.perform_now` for synchronous assertions
- Assert all side effects: records created, downstream jobs enqueued, external calls made
- Use `freeze_time` for time-dependent logic
- Use `perform_enqueued_jobs` when jobs trigger other jobs

## Error and Edge Case Coverage

For every feature, test **all** of the following:

- **Invalid params** — missing required fields, bad formats, wrong types
- **Duplicate records** — uniqueness constraint violations
- **Boundary values** — empty strings, very long input, special characters, nil
- **Concurrent operations** — double-submit, race conditions where applicable

## Permission Strategy by Spec Type

| Spec Type | Permission Setup |
|-----------|-----------------|
| Policy specs | Real permission records via `policy_setup` shared context |
| Request specs | Stub Pundit (e.g. `allow_any_instance_of(Admin::FooController).to receive(:authorize)`) |
| Feature specs | Use `authorized_admin_setup` shared context (requires `let(:authorized_resource_name)`) |
| Component specs | No permission setup needed |
| Model specs | No permission setup needed |
| Job specs | No permission setup needed |

## Shared Contexts

- `policy_setup` — Creates user, system group, role, and permissions for policy specs
- `authorized_admin_setup` — Full admin auth setup for feature specs
- Create new shared contexts when a setup pattern repeats across 3+ spec files

## Naming Convention

Follow strict `describe` / `context` / `it` structure:

```ruby
describe "#method_name" do
  context "when valid params" do
    it "creates the record and sets attributes" do
      # ...
    end
  end

  context "when invalid params" do
    it "returns validation errors" do
      # ...
    end
  end

  context "when record already exists" do
    it "rejects the duplicate" do
      # ...
    end
  end
end
```

- `describe` — method or behavior under test
- `context` — specific scenario or state (`when`, `with`, `without`)
- `it` — single assertion or tightly related assertions about one outcome
- One `describe` per method or behavior
- Use `let` / `let!` for setup, not instance variables

## Test Data Setup

- **Lean factories** — use traits for state variations (`:inactive`, `:with_admin_permissions`, `:archived`)
- **`build` for unit tests, `create` for integration tests** — don't hit the database when you don't need to
- **`build_stubbed`** — use for read-only tests where persistence doesn't matter
- **Sequences** for all unique attributes
- **Faker** for realistic data
- Avoid creating unnecessary associated records — use traits to opt-in to expensive associations

## Test Suite Performance

Target: **under 15 minutes** for the full suite. Prescribe and use these efficiency measures:

- **Parallel execution** — use CI-level or job-level parallelism to split specs across cores/runners
- **Database cleaning** — use `config.use_transactional_fixtures` and DatabaseCleaner hooks as configured in `spec/rails_helper.rb`; keep strategies in sync
- **Lean factories** — traits instead of building full object graphs by default
- **`build` over `create`** — avoid database writes in unit tests
- **`build_stubbed`** — fastest option for read-only tests
- **Shared contexts** — extract repeated setup to avoid redundant record creation
- **`let` (lazy) over `let!` (eager)** — only use `let!` when the record must exist before the test runs
- **Profiling** — use `--profile` flag to identify slow specs and optimize them

## Anti-Patterns

- Never use fixtures — FactoryBot only
- Never use controller specs — request specs only
- Never test private methods directly — test through the public interface
- Never use `sleep` — use `freeze_time` or `travel_to` for time-dependent tests
- Never hard-code IDs or timestamps
- Never skip edge cases because "they're unlikely"
- Never say "needs manual testing" without proving the automated stack can't handle it
