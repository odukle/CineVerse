# App Language Localization Plan

## Goal

Add user-selectable app UI language support to Lumi without changing content-language filtering. App UI language and content language must remain separate settings.

## Current State

- The app already has `intl` in `pubspec.yaml`.
- The app already has a persisted content-language mode in:
  - `lib/presentation/features/movies/providers/movies_provider.dart`
  - `lib/presentation/features/home/account_screen.dart`
- App UI strings are still largely hardcoded across screens, dialogs, toasts, and widgets.
- `MaterialApp.router` in `lib/app/app.dart` does not currently define:
  - `locale`
  - `supportedLocales`
  - `localizationsDelegates`

## Recommended Scope

Implement this in phases instead of trying to localize the entire app in one pass.

### Phase 1

Ship the localization infrastructure plus user-selectable app language support for a limited set of core UI surfaces.

Initial supported app languages:

- English
- Hindi
- Malayalam
- Tamil

Reason:

- These are meaningful for the likely user base.
- They keep translation volume manageable.
- They are enough to validate layout, persistence, and locale switching.

### Phase 2

Expand localization coverage to the rest of the product after Phase 1 is stable.

## Architecture Recommendation

Use Flutter's built-in localization system, not a custom string map.

### Why

- It is the standard Flutter path.
- It supports code generation and typed access.
- It handles locale resolution cleanly.
- It scales better for pluralization and future languages.

## Implementation Plan

### 1. Add localization infrastructure

Update `pubspec.yaml`:

- add `flutter_localizations` under `dependencies`
- enable Flutter localization generation

Add ARB-based localization resources:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_hi.arb`
- `lib/l10n/app_ml.arb`
- `lib/l10n/app_ta.arb`

Add localization config if needed:

- `l10n.yaml`

Update `lib/app/app.dart`:

- wire `locale`
- wire `supportedLocales`
- wire `localizationsDelegates`

### 2. Add persisted app-language setting

Create a dedicated provider, separate from content language:

- `lib/presentation/providers/app_locale_provider.dart`

Responsibilities:

- store selected locale code in `SharedPreferences`
- restore persisted locale on app startup
- expose selected `Locale?`
- support `system default` as an option

Recommended options:

- System Default
- English
- Hindi
- Malayalam
- Tamil

### 3. Add App Language picker to Account screen

Update:

- `lib/presentation/features/home/account_screen.dart`

Add a new settings card:

- title: `App Language`
- subtitle: current selected language
- bottom sheet picker similar to the existing content-language picker

Important:

- Keep `App Language` and `Content Language` as separate cards
- Add a short description to avoid confusion

Suggested descriptions:

- `App Language`: changes buttons, labels, dialogs, and UI text
- `Content Language`: filters titles by original language where supported

### 4. Localize core shared strings first

Move the highest-visibility repeated UI strings into localization first.

Priority groups:

- bottom navigation labels
- account screen labels
- library labels
- common dialog actions
- common buttons
- common empty states
- sync/error/loading messages used in shared surfaces

Examples:

- Explore
- Movies
- TV Shows
- Library
- Account
- Cancel
- Apply
- Save
- Delete
- Rename
- Share
- Remove
- Retry
- Sign in with Google
- Sign in with Apple
- App Language
- Content Language
- Watchlist
- Favourites
- Watched
- Notes
- Lists
- No content available

### 5. Localize shared widgets and shared dialogs

Target shared surfaces before feature-specific screens.

Likely files:

- `lib/presentation/widgets/media_actions_dialogs.dart`
- `lib/presentation/widgets/sync_indicator.dart`
- `lib/presentation/widgets/app_back_button.dart`
- reusable chips, empty states, common buttons

This yields broad coverage quickly with fewer edits.

### 6. Localize top-level screens

After shared widgets, localize the main entry screens:

- Explore
- Movies
- TV Shows
- Library
- Account
- Search

This gives the user an immediately visible app-language change even if deeper screens are still partly English.

### 7. Handle locale-sensitive formatting

Audit all `DateFormat` usage and make sure the active app locale is applied consistently.

Files already using `intl` include:

- release calendar
- notes screens
- person details
- movie details related screens

Requirement:

- if app language changes, visible date formatting should follow the selected locale where practical

### 8. QA for overflow and layout regressions

This is the highest-risk part after the string migration.

Primary QA focus:

- buttons
- chips
- alert dialogs
- bottom sheets
- headers
- empty states
- account cards
- library cards
- iPhone narrow width
- iPad width
- Android small screens

Languages to validate first:

- English
- Hindi
- Malayalam
- Tamil

## Files Likely To Change

### New files

- `lib/l10n/app_en.arb`
- `lib/l10n/app_hi.arb`
- `lib/l10n/app_ml.arb`
- `lib/l10n/app_ta.arb`
- `lib/presentation/providers/app_locale_provider.dart`
- `l10n.yaml`

### Existing files, likely first wave

- `pubspec.yaml`
- `lib/app/app.dart`
- `lib/presentation/features/home/account_screen.dart`
- `lib/presentation/features/watchlist/watchlist_screen.dart`
- `lib/presentation/widgets/media_actions_dialogs.dart`
- `lib/presentation/widgets/sync_indicator.dart`
- `lib/app/router/app_router.dart`

### Existing files, later waves

- `lib/presentation/features/movies/explore_screen.dart`
- `lib/presentation/features/home/movies_screen.dart`
- `lib/presentation/features/home/tv_shows_screen.dart`
- `lib/presentation/features/search/search_screen.dart`
- `lib/presentation/features/movie_details/movie_details_screen.dart`
- additional feature screens as coverage expands

## Risks

### 1. Large string surface area

The app has many hardcoded strings. Full coverage will take time even though the infrastructure itself is straightforward.

### 2. Inconsistent translation coverage

If only part of the UI is migrated initially, the app will show mixed-language UI. That is acceptable in Phase 1 if called out explicitly, but should not be the final state.

### 3. Layout overflow

Malayalam and Tamil strings can be noticeably longer in some controls. Dialogs and chips are the most likely breakpoints.

### 4. Confusion with content language

Users may assume app language also changes TMDB result language or filtering behavior. The UI copy needs to clearly separate the two settings.

## Recommended Delivery Strategy

### Milestone 1

Infrastructure + picker + persistence + top navigation/account/library/shared dialogs localized

### Milestone 2

Search and discovery/localized empty states/loading states

### Milestone 3

Movie details, person details, notes, release calendar, remaining screens

## Acceptance Criteria For Phase 1

- user can choose app language from Account screen
- selection persists across relaunch
- switching app language updates UI immediately
- app language does not alter content-language mode
- main navigation and account/library flows are localized
- core dialogs and shared actions are localized
- no major overflow issues in the supported languages

## Suggested Next Step

Start with Phase 1 only. Do not attempt full-app localization in the first pass.
