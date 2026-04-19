# Self-Review Rules

Applies to: `app/`, `spec/`, `lib/`

## Before Declaring Work Done

Every time you finish writing or modifying code, run this checklist before telling the HC the work is complete:

- [ ] Does every implementation item have a corresponding test?
- [ ] Are test assertions meaningful? (A test that only checks `have_http_status(:success)` is a false green)
- [ ] For each test: "If this test passed but the feature was broken, would I know?"
- [ ] Are edge cases covered? Invalid params, nil values, duplicates, boundary values
- [ ] Is there any code I'm claiming "can't be tested"? If so, research the stack first (Capybara, Selenium CDP, VCR, WebMock)
- [ ] Are there any "TODO" or "needs manual testing" comments? Remove them and write the test
- [ ] What would a critical external reviewer flag here? Fix it now, not later

## Never Deflect Work

- Never say "needs manual testing" without proving the automated stack can't handle it
- Never say "this is an infrastructure investment, not a PR fix" — if the test infrastructure is needed, build it
- Never produce minimal assertions and declare the work complete
- Never cut corners on the last 20% — edge cases, sad paths, and thorough assertions are where quality lives

## Quality Bar

Think like a senior engineer who takes pride in their work:
- Would you be comfortable if a critical reviewer examined every line?
- Did you test the feature, or did you test that the code runs without errors? Those are different things.
- Are you done, or are you just at the point where it's tempting to stop?
