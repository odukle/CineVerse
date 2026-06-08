# Lumi Product Improvement and Feature Plan

Date: 2026-06-08

## Scope
This document identifies:
- current improvement areas based on the existing codebase
- potential new feature additions that fit the current product direction
- a staged implementation plan

This is a planning artifact only. No implementation work is included here.

## Current Product Surface
Based on the current repo, the app already includes:
- Explore, Movies, TV, Library, and Account tabs
- detailed movie and TV pages with trailers, awards, quotes, cast/crew, seasons, episodes, full plot, and watch providers
- person, collection, keyword, and company detail screens
- AI-backed "What should I watch tonight?" recommendations
- hidden gems discovery
- watch history analytics and shareable insights
- notes, reminders, and notifications
- search across titles and people
- Firebase-backed auth and backend services
- vector-search-backed recommendation infrastructure

That is already a broad v1/v1.5 feature set. The next work should focus on product quality, speed, consistency, and compounding retention features rather than adding random surface area.

## Improvement Areas

### 1. Recommendation Reliability and Speed
Problem:
- the recommendation flow is one of the product's signature features
- it has multiple moving parts: LLM planning, vector retrieval, backend fallback logic, and TMDB hydration
- latency and partial inconsistency are still likely the biggest trust risk in the app

Observed risk areas:
- model/provider variability
- different backend behaviors across vector stores
- slower sort/filter combinations and enrichment-dependent states
- fallback behavior that may confuse users when results differ between runs

Recommended work:
- standardize backend selection and telemetry for recommendation runs
- add request timing instrumentation for planning, retrieval, hydration, and final response
- cache normalized query plans for repeated prompts
- cache hydrated recommendation payloads for short-lived repeat requests
- define explicit quality thresholds for result count, diversity, and exclusion handling

Success criteria:
- median recommendation time reduced materially
- fallback usage rate visible in logs/metrics
- fewer “empty result” or low-confidence recommendation states

### 2. Data Freshness and Metadata Consistency
Problem:
- some screens depend on data that is incomplete or inconsistently available from TMDB list endpoints
- this is already visible in cases like revenue-based sorting, title logos, and provider resolution

Recommended work:
- define a clear policy for “list payload” fields vs “details hydration” fields
- centralize metadata enrichment triggers so they are predictable
- maintain a small local cache layer for expensive derived metadata
- build a regular TMDB sync/refresh pipeline for app-critical fields

Success criteria:
- fewer UI fallbacks to placeholder values
- lower need for per-screen special handling
- predictable field availability by screen type

### 3. UI Consistency and Interaction Rules
Problem:
- the app now has many feature surfaces built over time
- interaction semantics are not always consistent: chips, cards, sorting, section spacing, and subtitle behavior differ across screens

Recommended work:
- define a reusable interaction spec for:
  - tappable chips
  - informational chips
  - section headers
  - sort/filter surfaces
  - metadata subtitles on cards
- audit all reusable card components against that spec
- consolidate one-off UI behavior into shared helpers/components

Success criteria:
- fewer per-screen exceptions
- lower UI bug rate
- easier future feature delivery without regressions

### 4. Performance and Rendering Hygiene
Problem:
- the app has many image-heavy and animation-heavy surfaces
- several earlier issues already indicated scroll jank, layout overflows, and screen-specific rendering edge cases

Recommended work:
- benchmark hot screens in profile/release mode
- audit expensive rebuild paths on:
  - Explore
  - Movie details
  - Person details
  - Recommendation screen
  - Analytics screen
- add explicit constraints and virtualization checks for complex lists and grids
- reduce unnecessary image/metadata work inside builders

Success criteria:
- smoother tab switching
- fewer overflow/layout bugs
- lower frame build time on mid-range devices

### 5. Release Readiness and Operational Safety
Problem:
- the app has meaningful backend dependencies: Firebase, vector stores, Google auth, provider link resolution, awards scraping, recommendation backends
- operational drift will become a real problem once external users grow

Recommended work:
- define a release checklist for:
  - auth config validation
  - vector backend availability
  - recommendation endpoint health
  - watch-provider resolver health
  - TMDB proxy health
- add backend health diagnostics and graceful degraded states
- formalize secret/config ownership and environment parity

Success criteria:
- fewer release regressions
- quicker diagnosis when third-party dependencies fail

### 6. Search and Discovery Ranking Quality
Problem:
- search/discovery features are broad, but ranking logic is still mostly metadata-driven rather than explicitly personalized

Recommended work:
- refine ranking heuristics for:
  - people credits
  - hidden gems
  - curated rails
  - search result grouping
- introduce lightweight user preference signals from watch history and recommendation interactions
- add better “why surfaced” internal scoring diagnostics for testing

Success criteria:
- better perceived relevance
- less manual tweaking by screen

## Potential New Features

### A. Recommendation Feedback Loop
Why:
- this directly improves the strongest differentiator in the app

Feature idea:
- let users mark recommendation results as:
  - watched already
  - not interested
  - too mainstream
  - more like this
- store those signals locally and optionally sync them
- use them to refine future recommendation ranking

Complexity: Medium
Impact: High

### B. Personalized Release Calendar
Why:
- the app already has notification and release-awareness primitives
- a calendar view would convert passive tracking into a recurring habit

Feature idea:
- calendar/timeline for:
  - upcoming movie releases from user library
  - next TV episodes
  - digital/physical releases where available
- include reminder shortcuts and watch-provider shortcuts

Complexity: Medium
Impact: High

### C. Smart Collections / Dynamic Lists
Why:
- users already have library and notes primitives, but not enough automation around them

Feature idea:
- saved dynamic rules such as:
  - highly rated thrillers under 2 hours
  - upcoming watchlist releases this month
  - movies similar to titles I rated 4.5+
- render as auto-updating shelves

Complexity: Medium-High
Impact: High

### D. People and Studio Deep Discovery
Why:
- person/company screens already exist, but they can become much more navigable discovery hubs

Feature idea:
- for people:
  - better career arcs
  - collaborator networks
  - top commercial vs top critical titles
- for studios/companies:
  - branded collections
  - genre signatures
  - notable timelines

Complexity: Medium
Impact: Medium-High

### E. Recommendation Collections You Can Share
Why:
- the app already has strong poster-heavy visual surfaces and share mechanics

Feature idea:
- generate shareable recommendation boards such as:
  - “Tonight’s Picks”
  - “My hidden gems”
  - “Best comfort films”
- let users share an image card or deep link

Complexity: Medium
Impact: Medium-High

### F. Cross-Title Compare Mode
Why:
- useful for choice-heavy sessions where a user is deciding between 2–4 options

Feature idea:
- compare titles side by side on:
  - runtime
  - ratings
  - genres
  - awards
  - providers
  - tone/keywords

Complexity: Medium
Impact: Medium

### G. Library Health and Completion Insights
Why:
- builds retention from existing library/watch analytics

Feature idea:
- unfinished shows
- abandoned watchlists
- genres over-indexed in the library
- “watch next from your own library” suggestions

Complexity: Medium
Impact: Medium-High

### H. Offline Snapshot Mode
Why:
- useful for library-heavy usage and travel scenarios

Feature idea:
- cache lightweight details for saved titles
- allow offline browsing of:
  - watchlist
  - favourites
  - notes
  - recently opened details pages

Complexity: Medium-High
Impact: Medium

## Recommended Priorities

### Priority 1: Stabilize Core Experience
Do first:
1. recommendation reliability and timing instrumentation
2. metadata consistency policy
3. sort/filter UX consistency
4. render/performance audit on top 5 screens
5. release diagnostics and backend health checks

Reason:
- this improves the app where users already spend time
- it reduces future rework before more feature expansion

### Priority 2: Add Retention-Oriented Features
Do next:
1. recommendation feedback loop
2. personalized release calendar
3. library health / completion insights
4. shareable recommendation boards

Reason:
- these use existing infrastructure well
- they increase repeat usage without requiring entirely new product foundations

### Priority 3: Expand Deep Discovery
Do after stability work:
1. smart collections / dynamic lists
2. people/studio deep discovery
3. compare mode
4. offline snapshot mode

Reason:
- these are valuable, but they depend on stronger ranking consistency and cleaner data contracts

## Implementation Plan

### Phase 0: Planning and Instrumentation Foundation
Tasks:
- document data contracts for `MediaTitle`, `MovieDetails`, and list hydration behavior
- define metrics for recommendation latency and empty/fallback rates
- map current backend dependencies and failure points
- define UI interaction rules for chips, subtitles, and sort surfaces

Deliverables:
- engineering design note
- telemetry/event schema
- UI consistency checklist

Estimated effort:
- 3 to 5 days

### Phase 1: Core Stability Work
Tasks:
- add recommendation pipeline timing instrumentation
- add query-plan/result caching for recommendation flow
- audit all sort/filter sheets and card subtitle behaviors
- profile and optimize Explore, MovieDetails, PersonDetails, RecommendTonight, Analytics
- add degraded-state UX for backend failures

Deliverables:
- measurable latency baseline and post-change metrics
- reduced UI inconsistency issues
- fewer runtime regressions on heavy screens

Estimated effort:
- 1.5 to 2.5 weeks

### Phase 2: Data Quality and Discovery Quality
Tasks:
- formalize enrichment rules for list-vs-details fields
- add metadata caches for expensive or missing fields
- improve ranking heuristics for hidden gems, curated rails, and people credits
- create internal debugging tools for relevance checks

Deliverables:
- improved result consistency across screens
- less special-case UI logic
- more predictable discovery ranking

Estimated effort:
- 1 to 2 weeks

### Phase 3: Retention Features
Tasks:
- implement recommendation feedback capture
- implement release calendar and reminder shortcuts
- add watch-library insights and “watch next from library” suggestions
- create shareable recommendation boards

Deliverables:
- new retention surfaces backed by existing data
- better repeat-session value

Estimated effort:
- 2 to 3 weeks

### Phase 4: Advanced Discovery Features
Tasks:
- implement smart dynamic collections
- enrich people/company discovery pages
- add compare mode
- prototype offline snapshot mode

Deliverables:
- differentiated power-user features
- stronger discovery depth

Estimated effort:
- 2 to 4 weeks

## Recommended First Implementation Batch
If the goal is to maximize product quality with the least waste, the next concrete batch should be:

1. Recommendation pipeline instrumentation
2. Recommendation response/query-plan caching
3. Data enrichment policy for revenue/logos/providers/awards
4. UI consistency audit for reusable cards and sheets
5. Performance audit of Explore, Details, Person, RecommendTonight
6. Recommendation feedback capture model design

That sequence gives the best foundation before adding larger feature layers.

## Risks and Dependencies
- recommendation improvements depend on stable vector/backend provider behavior
- release quality depends on cleaner environment/config discipline
- advanced discovery features depend on more predictable metadata availability
- performance work may require simplifying some current visual effects in targeted places

## Suggested File/Work Breakdown When Implementation Starts
- `docs/`: design notes and telemetry/event specs
- `lib/presentation/features/movies/`: recommendation UX, discovery rails, sorting UX
- `lib/presentation/features/person/`: deeper credits/person discovery work
- `lib/presentation/features/home/`: retention widgets, release calendar entry points
- `lib/presentation/features/watchlist/`: feedback loop and library-driven suggestions
- `functions/` and backend infra: caching, diagnostics, health endpoints, recommendation metrics

## Summary
The app already has enough features to justify shifting from breadth-first work to quality-first work.

Best next move:
- improve recommendation reliability, ranking quality, and UI consistency first
- then build retention features on top of that foundation
- only after that expand into deeper discovery and power-user features
