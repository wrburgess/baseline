# Baseline — Spec

**Codename:** Baseline
**Public URL:** `baseline.kc.tennis`
**Repo:** `wrburgess/baseline`
**Project:** [Baseline Setup](https://github.com/users/wrburgess/projects/2)

This spec is the output of an 18-question grill session (April 2026) that re-derived requirements from scratch. The predecessor work lives at `wrburgess/baseline-archive` and in the Courtview repo — treated here as historical reference, not dependency.

---

## 1. What This Is

Baseline is a tennis scouting and player-profile app for Kansas City–area USTA league captains. It answers three questions:

1. **Scouting matrix (job-to-be-done A):** "When our roster plays theirs, who has played whom, what happened, and when?"
2. **Player profile (job B):** "What do we know about this player — ratings over time, matches, partners, opponents?"
3. **Team profile & team-vs-team (job C):** "How has this team — and its lineage across sessions — done, and how have we done against them?"

It is **not** a lineup optimizer, a prediction model, a roster-management tool, or a public tennis reference site. Captains use it privately; all pages are behind authentication.

"Public" in this project means **authenticated non-admin** (future: a "player viewer" role). It does **not** mean scrapable or indexable on the open web. No unauthenticated surfaces exist.

---

## 2. Core Decisions (locked during the grill)

| # | Area | Resolution |
|---|------|------------|
| 1 | Primary user | Captain doing scouting + profile + team lookups; future "player viewer" role via `system_permissions` |
| 2 | Public = authenticated non-admin | Not scrapable/indexable; no unauthenticated surfaces in v0 |
| 3 | Page set | Dashboard, scouting matrix, player profile, pairwise H2H, team profile, team-vs-team, global search, match imports |
| 4 | Scouting primitive | Full roster × roster matrix (captain stacking invalidates "line-1 = strongest"); two matrices (singles top, doubles below), stacked |
| 5 | Format awareness | Scouting matrix renders per league format; doubles-only leagues hide the singles matrix |
| 6 | Tri-level | One `Team` per tri-level team; UI splits matrix into three court-sections by rating |
| 7 | Captain dashboard | `/` shows active-team cards with format, next match, recent match, "scout" + "enter match" CTAs |
| 8 | Match entry primitive | A "match night" (`TeamMatch`) is the unit; rating snapshots auto-populated from current `grades` at commit |
| 9 | Import pipeline | Claude Sonnet vision on TennisLink screenshots; unified `imports` table with `kind` enum (`team_roster` \| `match_night` \| `player_ratings` \| `league_schedule`) |
| 10 | Team lineage | Explicit `team_lineages` table; default team-vs-team view is lineage-vs-lineage |
| 11 | Post-season modeling | `TeamMatch.level` enum (`regular_season` \| `local_playoff` \| `district` \| `section` \| `national` \| `tournament`); no `Competition`/`Stage`/`TeamStageEntry` entities |
| 12 | Court position | `matches.court_number` integer, populated from import |
| 13 | WO/RET/DEF | Count in H2H tallies; badge in match list; "completed only" toggle available |
| 14 | Rating freshness | Info-icon + tooltip showing last observation date (no color coding) |
| 15 | Venue | Freeform string on `matches`; no `Venue` model in v0 |
| 16 | Design methodology | Wireframes first (no style), then tokens + ViewComponents; hybrid Claude Design canvas + Claude Code implementation |
| 17 | Dark mode | Ships with visual layer (Phase 3); Bootstrap's `data-bs-theme` native support |
| 18 | Icons | Bootstrap Icons (ships with Bootstrap 5) |
| 19 | Hosting | Kamal to DigitalOcean VPS from Phase 0; Postgres on same droplet at v0 scale |
| 20 | Domain | `baseline.kc.tennis` (subdomain of existing `kc.tennis`) |
| 21 | Courtview dependency | None. Schema derived from requirements. Courtview is historical reference only |
| 22 | Multi-captain contribution | First-class v0 requirement — Pundit scopes match uploads to teams the captain captains |
| 23 | Grade re-ingestion | Quarterly-recurring operational task (Tennis Record + WTN primary sources); `kind: player_ratings` in the imports pipeline |
| 24 | Flights | First-class entity with `parent_flight_id` self-reference for sub-flights; teams belong to leaf flight |
| 25 | Roster setup | Hybrid: manual league creation in admin + TennisLink team-page screenshot import for rosters |
| 26 | Subs | No sub concept. If a player is on the roster, they're on the roster. Rosters are ground truth |
| 27 | Duplicate matches | Rejected on import. `TeamMatch` unique on `(played_on, team_a_id, team_b_id)`; no merge flow in v0 |
| 28 | Auth | Devise + Pundit + built-in `system_permissions` + `system_roles` |
| 29 | UI stack | Bootstrap 5 (Sass-themed) + ViewComponent + Propshaft + esbuild; tables-only, zero charts |
| 30 | Score storage | Hybrid: `format` + `rules_format` + `outcome` + `winning_side` enums + structured `sets` JSONB + cached `score_display` string |
| 31 | Player dedup | `players` + `player_aliases` + pg_trgm fuzzy resolution + admin merge flow + needs-disambiguation queue |
| 32 | Analysis fidelity | Tables only. Blazer handles ad-hoc visual needs |
| 33 | Scheduled fixtures | First-class `scheduled_fixtures` table. Pre-season fixture list imported via `kind: league_schedule`. `team_matches.fixture_id` (nullable FK) links a played match to its fixture when imported. Dashboard "next match" reads from `scheduled_fixtures` |
| 34 | Search shell vs search implementation | Persistent nav shell from Phase 3; functional pg_trgm autocomplete in Phase 6; polish in Phase 11. |
| 35 | H2H notes visibility | Captain-collaborative — shared among all authenticated captains. Not per-user-private |
| 36 | Optimus conventions authoritative | Retained `.claude/rules/*.md` and `docs/standards/*.md` are the authoritative source for developer discipline (models, concerns, controllers, routes, forms, testing, migrations, security, self-review). `docs/spec.md` covers product + schema only. On conflict, the rules files win |
| 37 | Concerns on every model | Every data model includes `Archivable`, `Loggable`, and `Notifiable` (where applicable) per Optimus pattern |
| 38 | Route concerns on admin resources | Every admin `resources :foo` line includes `concerns: [:archivable, :collection_exportable, :member_exportable, :copyable]` unless justified otherwise during `/cplan` |
| 39 | Enum storage pattern | All enums managed via Optimus pattern — module in `app/modules/` + concern in `app/models/concerns/`. Reference: `app/modules/notification_distribution_methods.rb`. Inline string enums on a model are not acceptable |
| 40 | Asset pipeline separation | Two separate pipelines — admin (`admin.scss`, `app/javascript/admin/`, `admin.html.erb` layout) and public (`application.html.erb`). Separate Stimulus Application instances per AGENTS.md |
| 41 | Admin form conventions | Per AGENTS.md / `.claude/rules/backend.md`: `simple_form_for([:admin, instance])`, `tom_select` for selects (`wrapper: :tom_select_label_inset`), `floating_label_form` for text, `custom_boolean_switch` for booleans, `datepicker` for dates, two-column `row > col-12 col-lg-6` layout |
| 42 | Test-intent-per-change | Before any code is written or modified, the agent determines whether a test must be written (new coverage) or adjusted (existing coverage). Changes without an explicit test-intent determination are not acceptable. Applies from v0 onward, without exception |
| 43 | Pre-commit gates | `bundle exec rubocop -a && bundle exec rspec && bin/brakeman --no-pager -q && bin/bundler-audit check` — all four must pass before every commit, no exceptions |
| 44 | Admin-mounted engines | All six inherited from Optimus, gated by `system_manager?`: **Blazer** (ad-hoc SQL), **GoodJob** (job dashboard), **MaintenanceTasks** (human-triggered long-running ops), **PgHero** (Postgres insights), **Lookbook** (ViewComponent previews, dev/staging only), **RailsDb** (DB explorer, dev/staging only) |
| 45 | Import execution pattern | **Hybrid.** Captain-facing per-upload imports (screenshot → preview → commit) run as **GoodJob jobs** (`ParseImportJob`, `CommitImportJob`) for interactivity. Admin-facing bulk operations (e.g., quarterly grade re-import across 150-200 players) run as **`Maintenance::Task`s** at `/admin/maintenance_tasks` for observability + throttling + per-row error tracking. Both paths call a single shared `ClaudeVisionService` |
| 46 | Search render path | Global search autocomplete returns a **Turbo Frame wrapping ViewComponents** (no ERB partials). Stimulus controller on the input debounces + GETs to a search controller; response renders `Baseline::Ui::SearchResultsComponent` composing `PlayerResultComponent` + `TeamResultComponent` children inside a `<turbo-frame id="search_results">`. No JSON endpoint, no JWT plumbing, no client-side templating |
| 47 | Custom SystemOperations | Baseline extends Optimus's `SystemOperations` module with six custom operations: `merge` (player merge), `disambiguate` (resolve low-confidence player match), `commit` (transition import → committed), `reject` (transition import → failed), `enter_match_night` (manual match entry fallback), `link_fixture` (manual fixture attachment). Each becomes a granular SystemPermission row; policies reference them explicitly (e.g., `PlayerPolicy#merge?`). `policy_setup` shared context is extended to include all six |
| 48 | `system_manager` role scope | Seeded exclusively to `wrburgess@gmail.com` at install time. No one else receives it until explicitly promoted via console. Principle of least privilege — raw SQL / job retries / DB browser access is reserved for the project owner; plain admin role (with merge, disambiguation, lineage work) can be granted to trusted helpers without widening operator access |
| 49 | Per-phase permission sync | Every phase that adds a new controller (or adds a custom `SystemOperations` entry) includes an explicit acceptance-criterion checkbox: "Ran `Maintenance::EnsureModelSystemPermissionsTask` (or seeded manually); `SystemPermission` rows exist for every controller × operation combination; verified admin access to new controllers under `wrburgess@gmail.com`." Applies to Phases 1, 4, 5, 6, 7, 8, 9, 10, 11 |

---

## 3. Schema

### Core entities (fresh — not ported from Courtview)

**`organizations`** — USTA parent organization. Minimal.
**`sections`** — USTA sections (e.g., Missouri Valley). `belongs_to :organization`.
**`districts`** — USTA districts (e.g., Heart of America). `belongs_to :section`.
**`seasons`** — Spring, Summer, Fall. Simple name lookup.
**`years`** — Calendar year lookup.

### Competitive structure

**`leagues`**
```
name                   string                  # "HoA 18+ Men 3.5 Spring 2026"
district_id            bigint FK
season_id              bigint FK
year_id                bigint FK
age_level              string (enum)           # 18_plus | 40_plus | 55_plus | 65_plus | 70_plus
gender_type            string (enum)           # men | women | mixed
rating_range           string                  # "3.5" | "7.0_combo" | "tri_level_3.0_3.5_4.0"
singles_lines          integer                 # e.g., 2 (for 2S+3D); 0 for doubles-only
doubles_lines          integer                 # e.g., 3
game_format_type       string (enum)           # level | tri_level | mixed_doubles | combo_doubles | singles_only
ustaid                 string nullable         # USTA system id
trid                   string nullable         # TennisRecord league id
```

**`flights`**
```
league_id              bigint FK
name                   string                  # "Flight A", "Flight A.1"
parent_flight_id       bigint FK self nullable # for sub-flights
```

**`teams`**
```
flight_id              bigint FK               # leaf flight
team_lineage_id        bigint FK nullable
name                   string                  # "Corinthian Men's 3.5"
abbreviation           string nullable
```

**`team_lineages`**
```
name                   string                  # canonical name, e.g. "Corinthian Men's 3.5 Adult"
organization_id        bigint FK nullable      # the club if applicable
notes                  text
```

**`team_players`**
```
team_id                bigint FK
player_id              bigint FK
role                   string (enum)           # player | co_captain | captain
```

### Player identity & ratings

**Conventions applied to every model below:**
- Includes `Archivable` (soft delete via `archive!` / `unarchive!`), `Loggable` (audit trail into `data_logs`), and `Notifiable` (event hooks) where applicable
- Enumerated columns are backed by Optimus's enum pattern: module in `app/modules/` + concern in `app/models/concerns/` (reference: `app/modules/notification_distribution_methods.rb`). Inline string enums are not acceptable.
- Every admin resource route is declared with `concerns: [:archivable, :collection_exportable, :member_exportable, :copyable]` unless a specific concern is explicitly excluded during `/cplan`.

**`players`**
```
first_name             string
last_name              string
preferred_name         string nullable         # "Bob" for "Robert"
gender                 string (enum)           # required
birth_year             integer nullable
ustaid                 string nullable
trid                   string nullable
utrid                  string nullable
wtnid                  string nullable
user_id                bigint FK nullable      # future player-viewer role
```

**`player_aliases`**
```
player_id              bigint FK
alias_string           string
source                 string (enum)           # captain_entered | parser_observed | imported
confidence             float
```

**`grades`**
```
player_id              bigint FK
rating_system          string (enum)           # usta_ntrp | tennis_record | wtn_dynamic | wtn_singles | utr_dynamic | utr_singles | utr_doubles
value                  decimal                 # 3.5, 4.0, 7.32, etc.
rating_type            string (enum) nullable  # S | C | A | M (USTA only)
status                 string (enum) nullable  # active | appealed | dq | manual (USTA)
observed_on            date
rationale              string (enum) nullable  # self_rated | year_end_computer | early_start_bump | mid_year_bump | three_strike_dq | appeal_granted | appeal_denied | manual | unknown_legacy
previous_grade_id      bigint FK self nullable
source                 string (enum)           # manual | parser_tennisrecord | parser_wtn | parser_tennislink | imported
```

### Matches & participation

**`scheduled_fixtures`** (pre-season league fixture list — the schedule)
```
league_id              bigint FK
home_team_id           bigint FK
away_team_id           bigint FK
scheduled_on           date
start_time             time nullable
venue                  string nullable
status                 string (enum)           # scheduled | completed | postponed | cancelled | defaulted
team_match_id          bigint FK nullable      # populated when the match is played + imported
notes                  text

unique index on (league_id, scheduled_on, home_team_id, away_team_id)
```

**`team_matches`** (one per "match night")
```
league_id              bigint FK
home_team_id           bigint FK
away_team_id           bigint FK
played_on              date
level                  string (enum)           # regular_season | local_playoff | district | section | national | tournament
event_name             string nullable         # e.g. "HoA Districts 2026", "Plaza Open"
venue                  string nullable
home_score             integer                 # lines won (e.g., 3)
away_score             integer                 # lines won (e.g., 2)
fixture_id             bigint FK nullable      # linked to scheduled_fixtures.id if the match reconciles to a fixture
notes                  text

unique index on (played_on, home_team_id, away_team_id)  -- no duplicates
```

**`matches`** (one per line within a team match)
```
team_match_id          bigint FK nullable      # null for tournament matches outside league play
court_number           integer nullable        # line number 1..N
played_on              date
format                 string (enum)           # singles | doubles
rules_format           string (enum)           # best_of_3_standard | best_of_3_match_tb | fast4 | pro_set_8 | pro_set_10 | match_tb_10 | match_tb_7 | custom
outcome                string (enum)           # completed | retired | defaulted | walkover | timed
winning_side           string (enum) nullable  # home | away | null
sets                   jsonb                   # [{home, away, tb_home?, tb_away?}, ...]
score_display          string                  # e.g., "6-4 3-6 10-8"
notes                  text
```

**`match_participants`**
```
match_id               bigint FK
player_id              bigint FK
side                   string (enum)           # home | away
position               integer                 # 1 | 2 (null for singles)
partner_id             bigint FK nullable      # denormalized: other participant on same side
won                    boolean                 # derived at commit

# rating snapshots at time of match
usta_rating_at_match         decimal nullable
usta_rating_type_at_match    string nullable
tr_rating_at_match           decimal nullable
utr_dynamic_at_match         decimal nullable
utr_singles_at_match         decimal nullable
utr_doubles_at_match         decimal nullable
wtn_dynamic_at_match         decimal nullable
wtn_singles_at_match         decimal nullable
```

### H2H caching

**`head_to_head_caches`** (denormalized for scouting speed)
```
player_a_id            bigint FK   # always the lower ID
player_b_id            bigint FK
format                 string (enum)   # all | singles | doubles
wins_a                 integer
wins_b                 integer
last_played_on         date nullable
total_matches          integer
computed_at            datetime

unique index on (player_a_id, player_b_id, format)
```

**`head_to_head_notes`**
```
player_a_id            bigint FK   # enforced a_id < b_id
player_b_id            bigint FK
body                   text            # markdown
author_id              bigint FK       # users.id
```

### Imports pipeline

**`imports`** (unified for all three kinds)
```
user_id                bigint FK
screenshot             ActiveStorage attachment
kind                   string (enum)           # team_roster | match_night | player_ratings | league_schedule
source_type            string (enum)           # tennislink_team_page | tennislink_match_results | tennislink_schedule_page | tennisrecord_player_page | wtn_player_page
status                 string (enum)           # uploaded | parsing | needs_review | committed | failed
parsed_data            jsonb
context                jsonb                   # e.g. { league_id, team_id, player_id } for scoping
committed_at           datetime nullable
error_message          text nullable
```

### Auth (from the Optimus template; carried as-is)

- `users` — Devise
- `system_roles` / `system_permissions` / `system_role_permissions` — existing role model
- `roles` of note: `admin`, `captain`, (future) `player_viewer`

### Indexes of note

- pg_trgm on `players.first_name`, `players.last_name`, `players.preferred_name`, `player_aliases.alias_string`
- `team_matches (played_on, home_team_id, away_team_id)` UNIQUE
- `head_to_head_caches (player_a_id, player_b_id, format)` UNIQUE
- `match_participants (player_id)` for fast player-profile queries
- `match_participants (match_id)` for fast match rendering
- `flights (league_id, parent_flight_id)` for flight-tree traversal

---

## 4. Subsystems

### H2H cache refresh (GoodJob)

On every `Match` commit → enqueue `HeadToHeadCacheRefreshJob(player_a_id, player_b_id)` for every `(a, b)` pair among the match's participants. Job recomputes three cache rows (all / singles / doubles) via aggregation queries on `match_participants`. Idempotent. Unique constraint on `(a, b, format)` with canonical `a < b` ordering.

### Player resolution (used by all import kinds + admin)

When a name string needs to resolve to a Player:
1. Exact match on `ustaid` (if provided) → auto-link.
2. Exact match on `first_name + last_name` (case-insensitive) → single hit auto-proposes; multiple hits require disambiguation.
3. Exact match on `player_aliases.alias_string` → same.
4. pg_trgm fuzzy match (score ≥ 0.75) → top 5 candidates.
5. No match → captain creates new player manually from the preview screen.

Auto-creation of Players without captain confirmation is disallowed.

### Merge flow (admin-only)

`Admin::Players::MergeController` — select two players, transactionally re-points `match_participants`, `grades`, `player_aliases`, `team_players`, `head_to_head_notes` from `source` to `target`, creates an alias for the merged player's name, deletes the source record.

### Import pipeline (unified)

All three kinds share the same flow:

1. **Upload** (`/imports/new`) — captain picks `kind` + uploads screenshot + fills minimal context (e.g., which team for roster; which team for match night).
2. **Parse** — `ParseImportJob` calls Claude Sonnet 4.6 vision API with a kind-specific prompt and JSON schema; writes `parsed_data` + sets `status: needs_review`.
3. **Preview** (`/imports/:id`) — captain sees parsed data + player-resolution candidates per slot + inline editing.
4. **Commit** — validates no duplicates (TeamMatch uniqueness), writes the real records in a transaction, triggers downstream (e.g., H2H cache refresh for `match_night`).

Per-kind schemas:
- `team_roster`: extracts team name, league context (if discoverable), captain name, roster [{first_name, last_name, current_ntrp, position}]
- `match_night`: extracts team names, date, level, lines [{court_number, format, home_players, away_players, sets, outcome, winning_side, venue}]. **On commit, the pipeline looks for a matching `scheduled_fixtures` row (same `league_id + scheduled_on + home_team_id + away_team_id`); if found, sets `team_matches.fixture_id` and flips `scheduled_fixtures.status` to `completed`.** Matches with no fixture (e.g., tournaments) keep `fixture_id: null`.
- `player_ratings`: extracts external ratings (TR / WTN / USTA) observed at the page's current state; appends as new `grades` rows (never in-place update).
- `league_schedule`: extracts the full fixture list for a league in one upload — each row is `{scheduled_on, start_time, home_team, away_team, venue}`. Creates `scheduled_fixtures` rows with `status: scheduled`. Ideal source is a TennisLink league-schedule page (one screenshot per league, ~15-20 uploads per session).

### Global search (pg_trgm)

Top-nav global search across `players`, `teams`, `leagues`. Autocomplete shows Player + current NTRP + last-played-on OR Team + league + captain. Arrow-key navigation, Enter selects.

---

## 5. Pages (v0)

### Dashboard (`/` after login)

- **10-second answer:** "Here are the teams you're captaining right now, what's next for each."
- Global search bar. The **shell** (input in top nav) is persistent in all layouts from Phase 3 onward. **Functional pg_trgm autocomplete** lands in Phase 6 alongside the dashboard (captains need search to navigate at dogfood time). Polish in Phase 11.
- Active teams section — one card per team where `current_user` is `captain` or `co_captain` and the league is current.
- Past teams — collapsed by default.

Card content: team name · league name · format (e.g., "2S+3D") · roster size · **next match** (nearest future `scheduled_fixture` with `status: scheduled`) · **recent match** (most recent `scheduled_fixture.status: completed` or orphan `TeamMatch`, with "Enter match" CTA if fixture exists but not yet imported) · "Scout any team in this league" picker.

**Not on this page:** league standings, ranking tables, pending-roster-approval, notifications feed.

### Scouting matrix (`/scout/:our_team_id/vs/:their_team_id`)

- **10-second answer:** "Who on our side has played who on theirs, and how did it go?"
- Header: our team → vs → their team, with a "widen to league / narrow to flight" toggle.
- **Two stacked matrix sections** — singles on top, doubles below. Hide the singles matrix entirely for doubles-only leagues. For tri-level, split each matrix into three court-sections by rating.
- Cell content: W-L from my-player's POV · freshness dot (solid/half/hollow) · empty state = dash. Hover/long-press shows tooltip with last-played date. Click → pairwise H2H page. Row/column header click → player profile.

**Not on this page:** match scores (drill into H2H), player ratings (drill into profile), notes, lineup suggestions.

### Player profile (`/players/:id`)

- **10-second answer:** "Current NTRP, recent form, what we know about them at a glance."
- Header: name, preferred name, current NTRP (with freshness info-icon), external rating badges (TR, WTN, UTR) with freshness.
- Recent form strip — last 5 matches, one row per match, W/L indicator.
- Ratings history (table) — chronological, each rating system in columns.
- **Match history, split into singles and doubles sections** (not a tab, not merged). Each is Ransack-filterable, Pagy-paginated.
- Frequent opponents table (singles + doubles splits).
- Frequent partners table (doubles only).

**Not on this page:** charts, sparklines, shared-partner graphs, predictions, player-to-player comparison tooling (that's H2H's job).

### Pairwise H2H (`/head_to_heads/:a_id/:b_id`)

- **10-second answer:** "Record vs them, last played, rating deltas then→now."
- Header: both names, ratings side by side with freshness.
- Aggregate bar: "A leads 4–2" with format toggle (all / singles / doubles) AND "completed only" toggle.
- Context strip: first meeting, most recent, rating delta.
- **Two match lists, split singles and doubles** (same design philosophy as profile).
- Per-pair **captain-collaborative notes** (markdown) — shared among all authenticated captains, not user-private. Symmetric URL (`/a/b` and `/b/a` both resolve; canonical ordering uses lower ID for cache/notes).

### Team profile (`/teams/:id`)

- **10-second answer:** "Who's on this team, what lineage is it part of, and what's their record."
- Header: team name · league · format · captain · lineage name (linked).
- Lineage history — chronological list of teams in this lineage across sessions, newest first.
- Roster — sortable table with player name, current NTRP (freshness icon), match count on this team, W-L on this team.
- Team-match history — list of TeamMatches this team played, with score and link to scorecard.

**Not on this page:** individual match lines (those live on the scorecard drill-down or the opponent's team page), standings, playoff bracket rendering.

### Team-vs-team (`/team_vs_team/:a_lineage_id/:b_lineage_id`)

- **10-second answer:** "Our lineage vs their lineage, all time, with season filter."
- **Default mode: lineage-vs-lineage** (aggregate across all seasons both lineages have met).
- Season filter defaulted to "all seasons" (Mode 2); user can narrow to any specific season (Mode 1) from a dropdown.
- Aggregate record: "our lineage leads 6-4 across 3 sessions."
- Per-session breakdown: each TeamMatch rendered as a scorecard (court-by-court line results) with link into each line's Match record.
- Linked to the scouting matrix for the current session (if both lineages have active teams in the same league).

### Match imports

- `/imports/new` — upload form: pick `kind`, upload screenshot, fill minimal context.
- `/imports/:id` — preview/correct UI: parsed data + player-resolution per slot + inline edit + commit/reject buttons.
- `/imports` — history list: your uploads + status (admin sees all).

### Admin surfaces

Full-design, not default scaffolds. All admin forms use Optimus conventions (from AGENTS.md + `.claude/rules/backend.md`):
- `simple_form_for([:admin, instance])` with `tom_select` for selects (`wrapper: :tom_select_label_inset`), `floating_label_form` for text fields, `custom_boolean_switch` for booleans, `datepicker` for date inputs
- Two-column layout: `row > col-12 col-lg-6`
- Admin controllers inherit from `AdminController` (Devise + Pundit)
- Reference: `app/views/admin/system_groups/_form.html.erb` in the Optimus template

Admin uses its own asset pipeline (`admin.scss`, `app/javascript/admin/`, `admin.html.erb` layout) — separate from the public pipeline per AGENTS.md.


- `Admin::Players` — CRUD + merge + "needs disambiguation" queue
- `Admin::Grades` — timeline-style view, inline edit, bulk-import for quarterly refreshes
- `Admin::PlayerAliases` — view/add/remove
- `Admin::HeadToHeadNotes` — index (notes are edited on the H2H page)
- `Admin::Leagues` — CRUD including format + line counts
- `Admin::Flights` — nested under League; supports sub-flight creation
- `Admin::Teams` — lineage assignment with fuzzy-match suggestions; read-mostly since rosters come from imports
- `Admin::TeamLineages` — CRUD
- `Admin::TeamPlayers` — role assignment; read-mostly
- `Admin::ScheduledFixtures` — CRUD for manual edits (imports populate most rows); status transitions + re-linking a fixture to a team_match
- `Admin::Imports` — see all imports across captains; retry failed

---

## 6. Auth & Permissions

- **Devise** for authentication.
- **Pundit** for authorization.
- **Full Optimus permission tree** inherited as-is — `User → SystemGroupUser → SystemGroup → SystemGroupSystemRole → SystemRole → SystemRoleSystemPermission → SystemPermission(resource, operation)`. Six join/lookup tables; `access_authorized?` with per-request memoization. No modifications from Optimus's implementation.
- **Roles in Baseline:**
  - `system_manager` — full operator access + mounted engines (Blazer, GoodJob, MaintenanceTasks, PgHero, Lookbook, RailsDb). Seeded to `wrburgess@gmail.com` only.
  - `admin` — data hygiene operations (player merge, disambiguation, lineage, grade management, import review).
  - `captain` — upload imports for teams they captain; view all scouting surfaces.
  - `player_viewer` (future, schema-ready, not built in v0) — self-service player-profile visibility.
- **No unauthenticated surfaces** in v0. Every route requires login; Pundit enforces role checks.
- `Player.user_id` nullable FK so the `player_viewer` role can be introduced without migration pain.

### Extended `SystemOperations` (app/modules/system_operations.rb)

Baseline extends Optimus's operation set with six custom operations for domain-specific admin/captain actions:

| Operation | Scope | Purpose |
|---|---|---|
| `merge` | admin | Transactionally merge two Player records (re-points match_participants, grades, player_aliases, team_players, head_to_head_notes; creates alias from source name) |
| `disambiguate` | admin | Resolve a low-confidence player match flagged during import preview |
| `commit` | captain or admin | Transition an `Import` from `needs_review` → `committed` (writes real records in a transaction) |
| `reject` | captain or admin | Transition an `Import` to `failed` with a reason note |
| `enter_match_night` | captain or admin | Manual match-night entry (Phase 10 fallback), bypasses the screenshot-import path but reuses the same commit service |
| `link_fixture` | admin | Manually attach a played `TeamMatch` to a `ScheduledFixture` when auto-match at commit time didn't resolve the link |

Standard Optimus operations (`index`, `show`, `new`, `create`, `edit`, `update`, `destroy`, `archive`, `unarchive`, `copy`, `import`, `collection_export_xlsx`, `member_export_xlsx`) continue to apply unchanged.

### `policy_setup` shared context extension

`spec/support/shared_contexts/policy_setup.rb` is extended to seed the six custom operations alongside the 12 Optimus defaults, so every policy spec has full operation coverage available.

### Permission seeding on controller addition

Every phase that ships a new admin controller must run `Maintenance::EnsureModelSystemPermissionsTask` (or seed manually) to create `SystemPermission` rows for the controller × operation combinations, and assign them to the appropriate `SystemRole` (typically starts with the `system_manager` role, then gets granted to narrower roles as access rules are defined). Verification: logging in as `wrburgess@gmail.com`, every new admin controller's `index` responds 200.

### Multi-captain Pundit patterns

- `ImportPolicy#create?` — user is `admin` OR has `team_players.role ∈ {captain, co_captain}` on a team involved in the import's context.
- `ImportPolicy#index?` — admin sees all; captain sees their own uploads.
- `HeadToHeadNotePolicy#update?` — admin OR any captain (notes are captain-collaborative for now).
- `PlayerPolicy#*`, `GradePolicy#*`, `TeamLineagePolicy#*` — admin-only.
- `MatchPolicy#read?` — any authenticated user.

---

## 7. Build Sequence (v0 — 11 phases + Phase 0)

Each phase has a dedicated issue in the [`Baseline Setup`](https://github.com/users/wrburgess/projects/2) project with problem, proposed solution, locked decisions, acceptance criteria, and open questions. Reference phase issues from commits and PRs.

**Phase 0** — Import Optimus template + scrub MPI/Optimus references + deploy "Hello World" to `baseline.kc.tennis` via Kamal. CI green before any app code exists.

**Phase 1** — Schema foundation. Fresh Baseline schema derived from §3. Models, validations, factories. Seed a minimum of one league + a few players to exercise the schema. No Courtview migration (decommissioned).

**Phase 2** — Wireframes, all pages, no style. Hybrid Claude Design + Claude Code workflow. Per-page: 10-second-answer above the fold, scan pattern, anti-requirements, mobile vs desktop layout. Output: `docs/designs/*.md` IA specs + draft Rails views (unstyled HTML + Bootstrap grid only).

**Phase 3** — Design tokens + ViewComponent primitives. Semantic color (light + dark), type scale, spacing, radius, shadow. `Baseline::Ui::*` ViewComponents. Apply tokens to Phase 2 draft views. Dark mode shipped.

**Phase 4** — Admin CRUD, styled. Leagues, Flights, Players, Grades, PlayerAliases, Team Lineages, Teams, TeamPlayers, Merge flow, Disambiguation queue. Pundit policies per resource.

**Phase 5** — Imports pipeline foundation + all three pre-match kinds. Active Storage, Claude vision service, `imports` table, preview/commit scaffolding. Ships three kinds while infrastructure is fresh: `team_roster`, `player_ratings`, and `league_schedule`. First real data lands in prod via imports — rosters populate teams, ratings populate grades, schedules populate fixtures.

**Phase 6** — Captain dashboard + player profile + functional global search. `/` with active-team cards reading from `scheduled_fixtures`; `/players/:id` with full profile; pg_trgm autocomplete in the persistent nav search shell. Dogfood milestone: log in, search for a player, scout my active teams.

**Phase 7** — Scouting matrix. `/scout/:ours/vs/:theirs` with dual singles/doubles matrices, format-aware, tri-level court split, toggle to widen from flight to league.

**Phase 8** — Match imports + fixture linking + H2H cache refresh. `kind: match_night` workflow. On commit, reconcile each TeamMatch against `scheduled_fixtures` (same league + date + teams) — link the fixture, flip status to `completed`. `HeadToHeadCacheRefreshJob` enqueued per participant pair. Matches flow in via TennisLink screenshots.

**Phase 9** — Pairwise H2H + team profile + team-vs-team. `/head_to_heads/:a/:b`, `/teams/:id`, `/team_vs_team/:a/:b` (lineage-vs-lineage default, season filter for Mode 1). Team-match scorecard rendering.

**Phase 10** — Manual match entry fallback. `/match_nights/new` reusing the import preview form but initialized blank.

**Phase 11** — Polish. Empty states (zero matches, never played, archived), Pagy everywhere, search perf, Pundit coverage tests, critical-path system specs, performance budget (matrix renders < 300ms at production data volume).

### Milestones

- **End of Phase 6** = "v0 ready to dogfood myself" (dashboard + profile work against real data).
- **End of Phase 11** = "v0 ready to invite another captain."

---

## 8. Testing Posture

**Testing discipline is inherited wholesale from `.claude/rules/testing.md` and `docs/standards/testing.md` (retained from the Optimus template in Phase 0).** The "Definition of Done" in those rules applies to Baseline without modification. Framework: RSpec + FactoryBot + Capybara (Selenium for `js: true`) + shoulda-matchers + timecop + VCR + WebMock + Bullet + SimpleCov.

### Test-intent-per-change (Baseline-specific addition)

**Before any code is written or modified, the agent determines:**
1. Does a new test need to be written to cover the change?
2. Does an existing test need to be adjusted to reflect new behavior?
3. Does this change remove behavior that currently has coverage (and therefore coverage should be removed too)?

The agent states the test intent explicitly in `/cplan` output or in the PR description for smaller changes. Code changes that arrive without an explicit test-intent determination are rejected during self-review.

This rule extends (does not replace) the Optimus "Definition of Done" — Optimus says "tests must be written to protect the change"; Baseline adds "tests must be *considered* before the change is written." Applies from v0 onward, without exception.

### Definition of Done (from Optimus, mandatory)

- Model specs cover all validations, associations, scopes, callbacks, public methods, enumerables
- Request specs for every controller action, 3 auth contexts (authenticated + authorized, unauthenticated, authenticated + unauthorized) × full assertions (response content, DB side effects, flash, redirect, error cases)
- Feature specs cover every controller action type (create / edit / show / index / archive) + every admin form input type (`tom_select`, text, textarea, boolean switch, datepicker)
- Policy specs test both grant and deny for every action (index?, show?, new?, create?, edit?, update?, destroy?, archive?, unarchive?)
- External HTTP via VCR; never live calls in tests
- Shared examples applied: `it_behaves_like "archivable"`, `"loggable"`, etc., on models that include those concerns
- SimpleCov coverage enforced in CI with branch coverage using a ratcheting baseline (starts at 66% per Optimus, long-term target 90%)
- Bullet `raise = true` in test — specs fail on N+1 or unused eager loading

### Pre-commit gates

All four must pass before every commit, no exceptions:

```
bundle exec rubocop -a
bundle exec rspec
bin/brakeman --no-pager -q
bin/bundler-audit check
```

### Anti-patterns (from `.claude/rules/testing.md`)

- Never use fixtures — FactoryBot only
- Never use controller specs — request specs only
- Never test private methods directly — test through the public interface
- Never use `sleep` — use `freeze_time` or `travel_to` for time-dependent tests
- Never hard-code IDs or timestamps
- Never skip edge cases because "they're unlikely"
- Never say "needs manual testing" without proving the automated stack can't handle it

---

## 9. Maintenance Concerns

- **Quarterly grade re-imports.** Tennis Record + WTN primary sources. USTA/NTRP changes are rare (appeals, DQs, new entries). Operational task, not one-shot. `kind: player_ratings` workflow handles it.
- **Multi-captain data quality.** Upload dedup (TeamMatch uniqueness) prevents duplicates. Admin reviews flagged imports. No merge flow in v0 — rejected uploads are rejected.
- **Kamal / VPS ops.** DigitalOcean managed backups. Minimal burden.
- **Claude vision API dependency.** Manual match entry fallback (Phase 10) keeps the tool functional if the API is down.
- **Team lineage setup.** Manual admin step per new team; ~1-2 hours per session. Acceptable given volume (~15-20 leagues per session in KC).

---

## 10. Deferred / Open Questions

Intentionally not resolved. Revisit post-v0 or as real-use data dictates.

- **Bracket rendering for tournaments.** v0 treats tournaments as loose Matches with `event_name + level: tournament`. First-class bracket modeling is v2+ if ever.
- **Line-position strength signals.** Captain stacking invalidates the naive "line 1 = strongest" signal. A better analysis (e.g., "at line 1, this player's winning percentage is X") is post-v0.
- **Shared-partner analysis.** "Alice has partnered with Bob; Bob has played Carol; what does Alice-vs-Carol look like transitively?" — deferred.
- **Notification triggers.** None in v0. Candidates post-v0: notify captain when a merge proposal needs review; notify when an import has errors.
- **Roster-import automation.** Phase 5 covers single-team uploads. Bulk "whole league in one pass" import is post-v0.
- **Player-viewer role UI.** Schema ready (`player.user_id`), policies stubbed. Actual page restrictions and player-self-service flows are post-v0.

---

*This spec is the output of an 18-question grill session using Claude Opus 4.7. Changes post-lockin need a new grill, not a silent edit.*
