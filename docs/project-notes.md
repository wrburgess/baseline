# Baseline Development

## Notes

- This is a reboot of the Courtview project at `aaa/courtview`. Courtview is historical reference, not a dependency — schema is derived from requirements, not ported.
- This project will utilize the Optimus template at `aaa/optimus-base` as its starting point. MPI/Optimus references are scrubbed in Phase 0.
- This project is a personal and public project locally at `aaa/baseline` and on the `wrburgess/baseline` GitHub repo. "Public" means the source code is open; the deployed app is **always behind authentication** — no unauthenticated surfaces.
- Deployed at `baseline.kc.tennis`.
- Full spec: [`docs/spec.md`](./spec.md).

## Getting Started

- [x] Set up a project for the GitHub repo named "Baseline Setup" ([Project #2](https://github.com/users/wrburgess/projects/2))
- [x] Assign all project issues to that project going forward
- [x] Create [Issue #1](https://github.com/wrburgess/baseline/issues/1) — "Import Optimus template and scrub all MPI/Optimus references" (Phase 0)

### Requirements

**Users & roles**
- **Captain** (primary user) — logs in, scouts opponents, enters match data for teams they captain, views player profiles.
- **Admin** — manages player dedup, grade imports, team lineages, all data hygiene. In v0 this is typically you, the project owner.
- **Player viewer** (future, schema-ready, not built in v0) — authenticated player viewing their own data.

**Functional (v0)**
- Captain dashboard showing active teams with next/recent match + CTAs.
- Scouting matrix: full roster × roster, dual singles/doubles sections, format-aware per league, tri-level support.
- Player profile: current ratings (with freshness), ratings history, match history split singles/doubles, frequent opponents/partners.
- Pairwise H2H page with per-pair captain-private markdown notes.
- Team profile with lineage history + roster + team-match history.
- Team-vs-team page, default mode = lineage-vs-lineage with season filter.
- Match import pipeline: upload TennisLink screenshot → Claude Sonnet vision → preview + player resolution → commit → H2H cache refresh.
- Roster import pipeline: upload TennisLink team roster screenshot → extract players + captain → commit.
- Quarterly grade re-import pipeline: upload Tennis Record / WTN player pages → append new `grades` rows.
- Admin CRUD for all data hygiene.
- Multi-captain data contribution — any captain can upload imports for teams they captain.
- No duplicate TeamMatch uploads — unique `(played_on, home_team_id, away_team_id)`.

**Non-functional**
- Mobile-first responsive; works well on a 375px-wide phone in a dim gym.
- Tables only. Zero charts. Blazer for ad-hoc visual needs.
- Dark mode from v0.
- Scouting matrix renders in < 300ms at realistic data volume (Phase 11 target).

### Tools

- Ruby (4.0+)
- PostgreSQL (18+)
- Ruby on Rails (8.1+)
- Propshaft for asset pipeline
- esbuild for JavaScript bundling
- Hotwire (Turbo + Stimulus)
- Stimulus controllers for targeted interactivity
- ViewComponents over partials
- Bootstrap 5+ (Sass-themed) for styling
- Bootstrap Icons for iconography
- Devise for authentication; Pundit for authorization; built-in `system_permissions` for roles
- GoodJob (Postgres-backed) for background jobs
- Active Storage for screenshot uploads
- Claude Sonnet 4.6 via Anthropic API for vision-based import parsing
- Blazer for ad-hoc analytics
- RSpec + Capybara + FactoryBot + shoulda-matchers + timecop + VCR + WebMock
- Pagy (pagination), Ransack (filter/search), Simple Form, Tom Select, pg_trgm (fuzzy search)
- GitHub for source code, Projects & Issues for PM, Actions for CI
- Kamal for deployment
- DigitalOcean for hosting; `baseline.kc.tennis` domain

### Constraints

- **Weekend/evening development cadence.** No sprint deadlines. Ship pressure is low; quality pressure is high.
- **Single-developer project** (you). Codebase must be legible to Claude Code for future iteration.
- **Public repo from day one.** All code is open source from Phase 0; design pressure stays up.
- **Authenticated-only surfaces.** No unauthenticated pages, no SEO, no indexability, no public scraping concerns.
- **Personal-scale data.** ~15-20 leagues per session, ~150-200 teams, ~1500-2400 team-player bindings, ~500-1000 unique players, ~80-200 match nights per session. Postgres on a single VPS handles this comfortably.
- **Low-volume LLM usage.** ~$5-20/mo in vision API costs at import volumes.
- **Tables only.** No charts, no sparklines, no timelines, no visualizations. Information density + scannability are the design goals.
- **No mocked scraping.** Data arrives via captain screenshots + admin manual entry — no deterministic TennisLink parsers, no site-HTML scraping.
- **Design-first.** Wireframes (no style) before schema hardening; tokens + ViewComponents before feature build-out.

### Short-term goals (through v0 ship)

- Get Phase 0 shipped: `baseline.kc.tennis` serves a "Hello World" Rails app with TLS and CI, zero app code yet.
- Phase 1 schema derived from spec + one seed league + a few seed players to sanity-check.
- Phase 2–3: wireframes + tokens + ViewComponents, all pages designed without style, then themed (light + dark).
- Phase 4: admin CRUD for every data-hygiene task.
- Phase 5: roster import pipeline — first real player/team data enters via TennisLink screenshots.
- Phase 6: dashboard + profile work; **dogfood milestone** — I can log in and scout (with limited match data).
- Phases 7–9: matrix + match imports + H2H + team surfaces.
- Phases 10–11: manual-entry fallback + polish.
- **v0 ready-to-invite-a-captain** by end of Phase 11.

### Long-term goals (post-v0)

- Invite 2-3 KC captains to contribute match data; observe real multi-captain usage.
- Tennis Record + WTN quarterly grade re-imports running on cadence.
- `player_viewer` role with self-service player profile visibility.
- Line-position analytics ("at line 1, this player wins X%").
- Shared-partner / transitive analysis ("Alice partnered with Bob; how does Alice look vs Bob's opponents?").
- Bulk league-import (whole league in one pass) if captain onboarding becomes the bottleneck.
- Open-source the tool as a generic USTA-league scouting base for captains anywhere.

### Maintenance concerns

- **Quarterly grade re-ingestion.** Operational task. Not automated; manual admin action via the `player_ratings` import kind.
- **Multi-captain data quality.** Admin reviews flagged imports. Dedup prevents duplicates at the TeamMatch level.
- **Kamal / DigitalOcean ops.** Managed Postgres backups (~$1-2/mo). SSL renewal via Kamal. OS patches routine.
- **Claude vision API dependency.** Monitored; manual entry fallback exists if API is down.
- **Team lineage setup.** ~1-2 hours per session, manual. Acceptable given ~15-20 leagues per session.
- **Courtview is decommissioned.** No sync drift concern.

### Initial designs

- Mobile views required across desktop, tablet, and phone. Phone (375px) is the design anchor.
- Single-page scrolling preferred over multi-page navigation; modals + tooltips for second-level reference data.
- White space + contrast for eye scanning.
- Bootstrap 5's responsive grid drives the base layout; `data-bs-theme` handles dark mode natively.

### Full designs

- Elaborate style or cuteness not a plus. Serious, data-dense, scannable.
- Wireframes first (Phase 2, no style); visual tokens + ViewComponents (Phase 3) come after IA is settled.
- Dark mode ships in v0 (Phase 3), not deferred.

### Development plan

11 phases + Phase 0 = 12 phases total. See `docs/spec.md` §7 for each phase's scope and the `Baseline Setup` GitHub project for per-phase issues with acceptance criteria.

- Phase 0: Foundation (template scrub + Kamal deploy) — ready to build
- Phase 1: Schema + models + factories
- Phase 2: Wireframes (all pages, no style)
- Phase 3: Design tokens + ViewComponents (light + dark)
- Phase 4: Admin CRUD (data hygiene surfaces)
- Phase 5: Imports pipeline + roster imports
- Phase 6: Captain dashboard + player profile — **dogfood milestone**
- Phase 7: Scouting matrix
- Phase 8: Match imports + H2H cache refresh
- Phase 9: H2H + team profile + team-vs-team
- Phase 10: Manual match entry fallback
- Phase 11: Polish — **ready-to-invite milestone**

### Expectations

- **Conceptual design before stylistic design.** Phase 2 wireframes are grayscale, typography-only, Bootstrap grid only. No custom CSS, no color, no dark mode until Phase 3.
- **Per-page discipline.** Every v0 page's design brief answers: (a) what's the 10-second-answer above the fold, (b) what's the scan pattern, (c) what is NOT on this page, (d) how does the mobile layout differ from desktop.
- **Real data feeds design iteration.** Once Phase 5 imports work, wireframe iteration moves from placeholder data to real Kansas City rosters/players.
- **Schema is derived, not ported.** Fresh data model based on requirements + USTA domain realities (flights, sub-flights, tri-level, combo formats, post-season levels).
- **No pre-emptive features.** v0 ships the smallest viable scouting tool. v1 ideas stay in the deferred list.
- **Two ship milestones:** dogfood (end of Phase 6), invite-a-captain (end of Phase 11).

### Approach

- **Hybrid design workflow.** Claude Design canvas for rapid IA exploration per page; Claude Code for implementation into Rails views tested against real data on a phone.
- **Wireframe-first, style-second.** Sign off on information architecture before tokens exist.
- **Imports-first data.** Don't hand-seed data beyond the minimum; the import pipeline IS the data entry mechanism, so it gets built before most feature surfaces that consume data.
- **Admin before public.** Data hygiene UI lands before public surfaces (so admin can fix issues the moment they appear).
- **Deploy early.** `baseline.kc.tennis` serving before any app code — forces real-prod concerns (TLS, secrets, deploy pipeline, backups) to be solved while scope is tiny.
- **Tables only, every page.** No visualization temptations. If the data is important, it's in a table or it's a piece of text on a card.

### Start with goal-oriented approach

**What is the reason a person is using this app?**

A KC-area USTA league captain opens Baseline when they need to prepare for an upcoming match or understand a player they're going to face. The single job-to-be-done is: **"Pull up the context I need to make a lineup decision or understand an opponent, fast, on my phone, in a dim gym, with limited time."**

Three concrete triggers:
1. **Scouting triggered** — "we play team X next week, who's likely to show up and what do we know?"
2. **Individual triggered** — "I saw player Y play yesterday, who are they, how good are they?"
3. **Data-entry triggered** — "the match night is over, let me record what happened so future scouting works."

**What are the needs this person has for looking at each page?**

| Page | What they're asking |
|---|---|
| Dashboard | "What am I captaining right now? What's next up? Do I have data gaps?" |
| Scouting matrix | "Our roster vs theirs — who's played whom, and how did it go?" |
| Player profile | "Current rating, recent form, history at a glance. Do I know this person?" |
| Pairwise H2H | "Direct head-to-head with rating deltas then and now, plus any scouting notes we've written." |
| Team profile | "Who's on this team, what lineage, what's their record, what's their history across sessions?" |
| Team-vs-team | "Our lineage vs theirs — all-time record, per-session breakdown, scorecards." |
| Match import | "Here's a TennisLink screenshot from last night. Turn it into data with minimum fuss." |
| Search | "I remember the first name, nothing else. Help me get to a profile." |

**What does the person NOT need?**

- **On the dashboard:** roster approval, league standings, notifications feed, pending tasks, analytics widgets, charts of recent activity.
- **On the scouting matrix:** scores (drill into H2H for those), ratings (drill into profile), lineup suggestions, predictions, algorithmic strength rankings.
- **On the player profile:** charts, sparklines, shared-partner graphs, win-probability estimates, ratings-trend forecasts, social features, messaging.
- **On the pairwise H2H:** aggregate stats across other opponents (that's the profile's job), opposing-team context (that's team profile/team-vs-team).
- **On the team profile:** individual match-line details (drill into scorecards), standings, playoff bracket graphics, per-player detail (drill into profiles).
- **On the team-vs-team page:** lineup optimization, predicted outcomes, match-day strategy.
- **On imports:** cropping tools, OCR tuning, parsing-accuracy metrics, automated scraping, batch upload beyond one match-night.
- **Anywhere:** fancy animations, decorative imagery, marketing language, onboarding walkthroughs, gamification, social sharing, ratings or leaderboards of captains or teams.

---

*Project notes synthesized from the April 2026 grill session. See `docs/spec.md` for the authoritative spec.*
