# Baseline Testing Standards

## Test Framework

- RSpec with FactoryBot (never fixtures)
- Shoulda-matchers for validations and associations
- Capybara for feature/system tests
- WebMock to prevent accidental external HTTP calls
- VCR for recording HTTP cassettes
- SimpleCov for test coverage enforcement
- Bullet for N+1 query detection (logs in test, alerts in development)

## N+1 Query Detection (Bullet)

Bullet is configured to **log warnings in the test environment** when N+1 queries are detected. Each test starts and stops a Bullet request cycle (configured in `rails_helper.rb`).

- In test: N+1 warnings are logged to `log/bullet.log` and the Rails logger
- In development: Bullet shows browser alerts, console warnings, and a page footer
- **Goal:** Once existing N+1 queries are resolved, enable `Bullet.raise = true` in `config/environments/test.rb` to fail tests on new N+1 queries

**When Bullet detects a N+1 in tests:**
1. Add `includes`, `eager_load`, or `preload` to the query causing the N+1
2. If the N+1 is intentional (e.g., testing individual record loading), add to `Bullet.add_safelist` in an initializer
3. Never disable Bullet globally to work around a detection
4. New code must not introduce N+1 queries — agents should check `log/bullet.log` after running specs

**Development mode features:**
- Browser alert popup on N+1 detection
- Console log message with the offending query
- Footer added to every page showing Bullet status
- Log file at `log/bullet.log`

## Test Coverage Requirements

SimpleCov only runs in CI environments (when the `CI` environment variable is set). It enforces minimum coverage thresholds with a ratchet-up approach:

- **CI-only enforcement** — SimpleCov is not loaded during normal local test runs; set `CI=true` explicitly to enable it locally
- **Coverage drop refused** — coverage cannot decrease between CI runs, enforcing a one-way ratchet toward the 90% target
- **Branch coverage enabled** — both branches of conditionals must be tested
- **Target: 90% line coverage** — raise the `minimum_coverage` in `spec/spec_helper.rb` as coverage improves

To generate coverage reports locally, run `CI=true bundle exec rspec`. Reports are written to `coverage/index.html`. The `coverage/` directory is gitignored.

If CI fails due to a coverage drop, add tests for the uncovered code before pushing. Periodically raise `minimum_coverage` in `spec/spec_helper.rb` as the codebase approaches the 90% target.

## Spec Types and When to Use

| Type | Directory | Purpose |
|------|-----------|---------|
| Model | `spec/models/` | Validations, associations, scopes, instance methods |
| Request | `spec/requests/admin/` | Controller actions, HTTP responses, redirects |
| Policy | `spec/policies/admin/` | Pundit authorization for each permission |
| Job | `spec/jobs/` | Background job behavior and side effects |
| Component | `spec/components/` | ViewComponent rendering and DOM output |
| Feature | `spec/features/` | End-to-end UI flows with Capybara |
| Module | `spec/modules/` | Enumerable modules (e.g., `OrderStatuses`) |

**Use request specs for controllers, not controller specs.**

## Model Spec Structure

```ruby
RSpec.describe ModelName, type: :model do
  # Shared examples for concerns
  it_behaves_like "archivable"
  it_behaves_like "loggable"

  describe "factory" do
    it "creates a valid instance" do
      instance = create(:model_name)
      expect(instance).to be_persisted
    end
  end

  describe "associations" do
    # Use shoulda-matchers
  end

  describe "validations" do
    # Use shoulda-matchers
  end

  describe "scopes" do
    # Test each scope returns expected records
  end

  describe "ransackable" do
    # Test .ransackable_attributes and .ransackable_associations
  end

  describe "instance methods" do
    # Test each method with various states
  end
end
```

## Request Spec Structure

Every request spec must test three contexts:

```ruby
RSpec.describe Admin::ResourceController, type: :request do
  let(:user) { create(:user, confirmed_at: Time.current) }

  context "when authenticated and authorized" do
    before do
      login_as(user, scope: :user)
      allow_any_instance_of(described_class).to receive(:authorize).and_return(true)
    end

    # Test CRUD operations, redirects, flash messages
  end

  context "when not authenticated" do
    # Test redirect to sign-in
  end

  context "when authenticated but unauthorized" do
    before do
      login_as(user, scope: :user)
      allow_any_instance_of(described_class).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      allow_any_instance_of(ApplicationController).to receive(:user_not_authorized) do |controller, _exception|
        controller.render(plain: "unauthorized", status: :unauthorized)
      end
    end

    # Test 401 responses
  end
end
```

## Policy Spec Structure

```ruby
RSpec.describe Admin::ModelPolicy, type: :policy do
  include_context 'policy_setup'

  describe '#index?' do
    it 'allows access if user has index permission' do
      expect(policy.index?).to be_truthy
    end

    it 'denies access if user does not have index permission' do
      system_role.system_permissions.delete(sp_index)
      expect(policy.index?).to be_falsey
    end
  end

  # Repeat for: show?, new?, create?, edit?, update?, destroy?, archive?, unarchive?
end
```

## Job Spec Patterns

```ruby
RSpec.describe SomeJob, type: :job do
  describe "#perform" do
    it "creates expected records" do
      expect {
        described_class.perform_now(args)
      }.to change(Model, :count).by(1)
    end

    it "enqueues downstream jobs" do
      expect {
        described_class.perform_now(args)
      }.to have_enqueued_job(DownstreamJob)
    end
  end
end
```

- Use `.perform_now` for synchronous testing
- Use `perform_enqueued_jobs` when jobs trigger other jobs
- Use `freeze_time` for time-dependent logic

## Component Spec Patterns

```ruby
RSpec.describe Admin::SomeComponent, type: :component do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it "renders expected content" do
    render_inline(described_class.new(args))
    expect(page).to have_css(".expected-class")
    expect(page).to have_text("Expected text")
  end
end
```

## Factory Conventions

- One factory file per model in `spec/factories/`
- Use `sequence` for unique attributes
- Use `Faker` for realistic data
- Use `association` for required belongs_to
- Use `trait` for state variations (e.g., `:inactive`, `:distributed`, `:daily`)

```ruby
FactoryBot.define do
  factory :model_name do
    sequence(:name) { |n| "Name #{n}" }
    description { Faker::Lorem.sentence }
    association :parent_model
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
```

## Permission Strategy by Spec Type

Each spec type handles Pundit authorization differently. Permissions are tested
thoroughly in policy specs; all other spec types bypass or stub the permission
system so they can focus on their own concerns.

| Spec Type | Permission Strategy | Why |
|---|---|---|
| **Policy specs** | Real permission records via `policy_setup` | Tests permission behavior directly |
| **Request specs** | Stub Pundit: `allow_any_instance_of(...).to receive(:authorize).and_return(true)` | Tests HTTP behavior, not permissions |
| **Component specs** | No permission setup — just `create(:user)` + `sign_in` | Tests rendered output, not permissions |
| **Feature specs** | Real records via `authorized_admin_setup` shared context | Capybara can't share stubs; uses shared context to avoid inline duplication |
| **Model specs** | No permission setup needed | No authorization layer involved |
| **Job specs** | No permission setup needed | No authorization layer involved |

Never build the full permission hierarchy (user + group + role + permissions) in
request, component, model, or job specs. If a new spec type needs authorization,
use the appropriate strategy from the table above.

## Shared Contexts

Use shared contexts from `spec/support/shared_contexts/`:

| Context | Use In | What It Sets Up |
|---------|--------|-----------------|
| `policy_setup` | Policy specs | User with full permission hierarchy, auto-resolves policy class |
| `authorized_admin_setup` | Feature specs | Fully-authorized user with all admin permissions for a given resource |

### Using `authorized_admin_setup`

```ruby
RSpec.describe "Admin System Groups CRUD", type: :feature do
  include_context "authorized_admin_setup"
  let(:authorized_resource_name) { "SystemGroup" }

  # Tests go here — user is logged in with all permissions for SystemGroup
end
```

## Shared Examples

Use shared examples from `spec/support/shared_examples/`:

- `archivable` — Tests archive/unarchive, scopes, state checks
- `loggable` — Tests audit log creation via async job
- `has_distribution_method` — Tests distribution method validations
- `has_distribution_frequency` — Tests frequency validations and predicates

## Testing Conventions

- Use `let` for data definition (lazy), `before` for setup/side effects
- Use `build` for unit tests, `create` for integration tests
- Use `.reload` after mutations to verify persistence
- Use `contain_exactly` for collection assertions (order-independent)
- Use `freeze_time` or `travel_to` for time-dependent tests
- Test flash messages: `expect(flash[:success]).to be_present`
- Test redirects: `expect(response).to have_http_status(:redirect)`
- Minimize mocks — use real objects when possible

## Migration Safety

`strong_migrations` automatically checks new migrations for unsafe operations. Common blocked patterns:

- Adding a column with a default value on a large table (use a two-step process instead)
- Removing a column without `safety_assured` (verify no code references remain)
- Renaming a table or column (use a new table/column + backfill instead)
- Adding a non-concurrent index (use `algorithm: :concurrently` in production)

When a migration is blocked, follow the safe alternative in the error message. Use `safety_assured { }` only after confirming the operation is safe for existing production data.

## HC Review Checklist for Tests

When reviewing tests written by an agent, verify:

- [ ] All three auth contexts tested in request specs (authed+authorized, not authed, authed+unauthorized)
- [ ] Policy specs test both grant and deny for each permission
- [ ] Shared examples used for concerns (archivable, loggable)
- [ ] Factory creates a valid instance (factory test exists)
- [ ] Edge cases covered (nil values, empty collections, boundary conditions)
- [ ] No hard-coded IDs or timestamps
- [ ] Time-dependent tests use `freeze_time` or `travel_to`
- [ ] Jobs tested with `perform_now`, not just enqueue assertions
