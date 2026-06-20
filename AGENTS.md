# CineVerse / Lumi Cinema — Agent Guide

> This file is intended for AI coding agents. It describes the project architecture, build system, code conventions, and operational rules you must follow when working in this repository.

## 1. Project Overview

**CineVerse** (branded as **Lumi Cinema**) is a cross-platform Flutter mobile application for movie and TV discovery, personal tracking, and analysis. It combines:

- Curated discovery rails and collections powered by TMDb.
- A personal library (watchlist, favourites, custom lists, notes, watched history).
- AI-assisted recommendation prompts ("What should I watch tonight?").
- Watch analytics (genre trends, viewing patterns).
- Memorable quote exploration and cinematic quote-card creation for sharing.

The app targets Android and iOS. It is built with Flutter (Dart SDK ^3.11.5) and uses Firebase for authentication, cloud data, and backend functions.

## 2. Technology Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter (Dart) |
| State Management | `flutter_riverpod` |
| Routing | `go_router` |
| Networking | `dio` |
| Local Database | `drift` (SQLite) via `drift_flutter` |
| Image Caching | `cached_network_image` |
| Backend / Auth | Firebase Auth, Cloud Firestore, Firebase Functions |
| Movie Data Proxy | Cloudflare Worker (`infra/tmdb-proxy-worker/`) |
| AI / LLM | OpenRouter + Gemini (via Firebase Functions) |
| Vector Search | Firestore vector search, Qdrant, Zilliz |
| Localization | Flutter gen-l10n (ARB files in `lib/l10n/`) |

## 3. Repository Structure

```
├── android/                          # Android platform code
├── ios/                              # iOS platform code
├── lib/                              # Main Dart source
│   ├── app/                          # App entry, theme, routing
│   │   ├── app.dart                  # LumiApp (MaterialApp.router)
│   │   ├── router/                   # GoRouter configuration
│   │   └── theme/                    # AppTheme, ThemePalette, AppColors
│   ├── core/                         # Shared utilities, constants, network
│   │   ├── config/                   # AppConfig (env-based URLs)
│   │   ├── constants/              # AppConstants (TMDb paths, etc.)
│   │   ├── extensions/             # Dart extensions
│   │   ├── network/                # Dio provider
│   │   ├── notifications/          # Local notification service
│   │   ├── storage/                # Drift connection factory
│   │   └── utils/                  # Toast utilities, etc.
│   ├── data/                         # Data layer (DTOs, repositories, data sources)
│   │   ├── datasources/
│   │   │   ├── local/              # Drift local DB (AppDatabase, LocalDataSource)
│   │   │   └── remote/             # TMDb API client, RemoteDataSource
│   │   ├── models/                 # DTOs (e.g., TmdbMovieDto, TmdbMovieDetailsDto)
│   │   ├── repositories/           # Repository implementations (e.g., MediaRepositoryImpl)
│   │   └── services/               # Additional data services
│   ├── domain/                       # Domain layer (business logic, entities, use cases)
│   │   ├── entities/               # Domain entities (e.g., MovieDetails, WatchlistItem)
│   │   ├── repositories/           # Repository interfaces (abstract classes)
│   │   └── usecases/               # Use cases (e.g., GetMovieDetailsUseCase)
│   ├── l10n/                         # Localization ARB files + generated localizations
│   ├── presentation/                 # UI layer
│   │   ├── features/               # Feature-first screens (home, movies, watchlist, etc.)
│   │   ├── providers/              # Global/shared Riverpod providers
│   │   └── widgets/                # Shared reusable widgets
│   ├── firebase_options.dart         # Firebase platform options
│   └── main.dart                     # Entry point (Firebase init, ProviderScope)
├── test/                             # Unit and widget tests (mirrors lib/ structure)
├── integration_test/                 # Integration tests (e.g., Play Store screenshots)
├── functions/                        # Node.js Firebase Functions (recommendTonight, OMDB resolver)
├── functions_py/                     # Python Firebase Functions (watch provider resolver, awards)
├── infra/tmdb-proxy-worker/        # Cloudflare Worker proxying TMDb API
├── scripts/                          # Python/Shell build and data scripts
├── config/                           # API keys and build configuration (gitignored)
├── docs/                             # Documentation, support pages, marketing assets
├── assets/                           # Logos, sounds, images
├── pubspec.yaml                      # Flutter dependencies and app metadata
├── firebase.json                     # Firebase project configuration
├── firestore.rules                   # Firestore security rules
├── codemagic.yaml                    # CI/CD workflow for iOS TestFlight
└── analysis_options.yaml             # Dart analyzer / lint rules
```

## 4. Architecture

The project follows **Clean Architecture** with three layers:

1. **Domain (`lib/domain/`)**: Independent of frameworks. Contains entities, repository interfaces, and use cases.
2. **Data (`lib/data/`)**: Implements repository interfaces. Handles remote APIs (via Dio) and local storage (via Drift). DTOs live here and must expose a `toDomain()` method to map to domain entities.
3. **Presentation (`lib/presentation/`)**: UI (Widgets) and state management (Riverpod providers). Organized by feature.

**Key rules:**
- Do not put business logic in widgets.
- Prefer immutable data models (`final` fields).
- Use abstract repository classes so implementations can be swapped for testing.
- The app uses `go_router` for deep-linking and navigation.

## 5. Build and Run Commands

### Prerequisites
- Flutter SDK (stable)
- Android Studio or Xcode
- Firebase project configured (see `firebase.json`)
- `config/api_keys.json` and `config/app_client.public.json` for local builds (gitignored)

### Local Development
```bash
# Install dependencies
flutter pub get

# Run on a connected device / emulator
flutter run

# Run with environment config
flutter run --dart-define-from-file=config/app_client.public.json
```

### Code Generation
```bash
# Generate Drift database code, launcher icons, splash screen, and localizations
flutter pub run build_runner build
```

### Android Release Build
```bash
# Automated script (bumps version, strips dev plugins, builds AAB + APK)
bash scripts/build_android_release.sh
```

### iOS Release Build (TestFlight via Codemagic)
- Configured in `codemagic.yaml`.
- Requires App Store Connect integration and code signing profiles.

### Lint / Analyze
```bash
flutter analyze
```
> **Mandatory:** After any code change, run `flutter analyze` and resolve all errors and warnings before considering the task complete.

## 6. Testing

- **Unit Tests**: For repositories, use cases, and logic-heavy models. Located in `test/` and should mirror `lib/` structure.
- **Widget Tests**: For complex UI components.
- **Integration Tests**: In `integration_test/` (e.g., Play Store screenshot automation).

Run tests:
```bash
flutter test
```

## 7. Code Style Guidelines

- **File names**: `lowercase_with_underscores.dart`
- **Class names**: `UpperCamelCase`
- **Variables / methods**: `lowerCamelCase`
- **Constants**: `lowerCamelCase` (preferred) or `UPPER_SNAKE_CASE` for true constants
- **Imports order**: `dart:` → `package:` → relative. Sort alphabetically within each group.
- **Formatting**: Use `dart format`. Prefer lines around 80 characters.
- **Null safety**: Rigorously use Dart null safety. Avoid `!` operator.
- **Immutability**: Prefer `final` fields and immutable entities. Avoid `late` without initializers.
- **Documentation**: Use `///` doc comments for public APIs. Start with a single-sentence summary.

## 8. Backend & Cloud Functions

### Node.js Functions (`functions/`)
- `recommendTonight`: AI-powered movie recommendation using OpenRouter/Gemini LLMs, vector search (Firestore/Qdrant/Zilliz), and reranking.
- `resolveOmdbTitleDetails`: OMDB API proxy for IMDb ratings and plot details.
- Configured via `firebase.json` (default codebase).

### Python Functions (`functions_py/`)
- `resolveProviderLink`: Resolves streaming provider deep-links from JustWatch/TMDB URLs with Firestore caching.
- `resolveMovieAwards`: Scrapes TMDB awards pages and merges with OMDB data.
- `watchProviderCacheAdmin`: Admin endpoints for cache stats and cleanup.
- Configured via `firebase.json` (python codebase, runtime `python312`).

### TMDb Proxy Worker (`infra/tmdb-proxy-worker/`)
- A Cloudflare Worker that proxies TMDb API requests with an allowlist and CORS handling.
- **Critical rule**: If you add or modify TMDb endpoints, you must:
  1. Update `ALLOWED_STATIC_PATHS` or regex patterns in `infra/tmdb-proxy-worker/src/index.js`.
  2. Run `npm run deploy` in `infra/tmdb-proxy-worker/`.
  3. Verify the deployed endpoint (e.g., via `curl` or browser).

## 9. Security Considerations

- **Secrets**: API keys (TMDb, OMDB, OpenRouter, Gemini, Qdrant, Zilliz) are stored as Firebase Secrets or in `config/api_keys.json` (gitignored). Never commit secrets.
- **Firestore Rules**: `firestore.rules` enforces user isolation (`request.auth.uid == userId`) and restricts vector index writes to admin/backend.
- **Signing keys**: Android release signing (`android/key.properties`) and iOS certificates are local-only and gitignored.
- **App Check**: Firebase App Check is used for function invocations where applicable.

## 10. Deployment Processes

- **Android**: Use `scripts/build_android_release.sh` to produce AAB and APK artifacts in `release/`.
- **iOS**: Use Codemagic CI/CD (`codemagic.yaml`) to build and submit to TestFlight.
- **Firebase Functions**: Deploy via `firebase deploy --only functions` (Node.js) or `firebase deploy --only functions:python`.
- **Cloudflare Worker**: Deploy via `npm run deploy` in `infra/tmdb-proxy-worker/`.

## 11. Localization

- Source strings are in `lib/l10n/app_en.arb`.
- Generated files are in `lib/l10n/app_localizations*.dart`.
- Configured via `l10n.yaml` (template ARB: `app_en.arb`, output class: `AppLocalizations`).
- After modifying ARB files, run `flutter gen-l10n` or let the IDE regenerate.

## 12. Agent-Specific Notes

- **Do not** modify `lib/l10n/app_localizations*.dart` directly; edit the ARB files and regenerate.
- **Do not** modify `lib/data/datasources/local/app_database.g.dart` directly; run `build_runner` after changing `app_database.dart`.
- When adding a new TMDb endpoint, remember the **TMDB Proxy Worker** update and deployment rule.
- When adding Firebase Functions, update `firebase.json` if a new codebase or function is introduced.
- Always run `flutter analyze` after making changes and before finishing a task.
