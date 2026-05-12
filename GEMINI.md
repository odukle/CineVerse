# CineVerse: Project Instructions

This document defines the foundational mandates, architecture, and workflows for the CineVerse project. All contributors must adhere to these standards.

## 1. Core Architecture

The project follows a **Clean Architecture** pattern, separated into three main layers:

- **Domain Layer (`lib/domain/`)**: Contains the business logic, entities, and repository interfaces. It is independent of any other layer.
- **Data Layer (`lib/data/`)**: Implements the repository interfaces and handles data sources (Remote via Dio/Retrofit, Local via Drift).
  - **DTOs (`lib/data/models/`)**: Use Data Transfer Objects for API and local storage.
  - **Mappers**: Every DTO must have a `toDomain()` method to convert it to a domain entity.
- **Presentation Layer (`lib/presentation/`)**: Contains the UI (Widgets) and State Management logic.
  - **Features (`lib/presentation/features/`)**: Organized by feature (e.g., home, movies, watchlist).

## 2. Technical Stack

- **Language**: Dart (SDK ^3.11.5)
- **Framework**: Flutter
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Routing**: [go_router](https://pub.dev/packages/go_router)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Local Database**: [Drift](https://drift.simonbinder.eu/) (SQLite)
- **Icons/Assets**: `flutter_svg`, `cached_network_image`.

## 3. Engineering Standards

### Naming & Style
- **File Naming**: Use `lowercase_with_underscores`.
- **Class Naming**: Use `UpperCamelCase`.
- **Variable/Method Naming**: Use `lowerCamelCase`.
- **Suffixes**:
  - Repositories: `MediaRepository` (interface), `MediaRepositoryImpl` (implementation).
  - Data Sources: `RemoteDataSource`, `LocalDataSource`.
  - Models: `TmdbMovieDto` (data layer), `MediaTitle` (domain layer).

### Code Conventions
- **Immutability**: Prefer `final` fields and immutable entities.
- **Manual Mapping**: DTOs use manual `fromJson` factories and `toDomain()` methods. Avoid excessive code generation for simple DTOs unless complexity warrants `freezed`.
- **Null Safety**: Rigorously use Dart null safety. Avoid `!`.

## 4. Workflows & Mandatory Rules

### TMDB Proxy Worker (CRITICAL)
If you add or modify TMDB endpoints:
1. **Allowlist Update**: Update `ALLOWED_STATIC_PATHS` or regex patterns in `infra/tmdb-proxy-worker/src/index.js`.
2. **Mandatory Deployment**: Run `npm run deploy` in `infra/tmdb-proxy-worker/` immediately.
3. **Verification**: A task is **NOT COMPLETE** until you verify the deployed endpoint (e.g., via `curl` or browser).

### Development Cycle
- **Research**: Map dependencies and understand the feature scope.
- **Strategy**: Define the UI components and data flow.
- **Implementation**: Follow Clean Architecture layers.
- **Validation**: Run tests and verify on a real device/emulator.

### Validation & Analysis (MANDATORY)
1. **Analysis**: After making ANY code change, you MUST run `mcp_dart_analyze_files` (or `dart analyze` via shell) on the project root.
2. **Resolution**: You MUST resolve all errors and warnings reported by the analyzer before finalizing your response. 
3. **Verification**: A task is only considered complete when the analyzer reports "No errors".

### Automated APK Delivery (NEW)
Whenever the user requests "send me the apk":
1. **Preparation**:
   - Ensure `config/api_keys.json` contains the correct values for Telegram delivery. API keys for the app should be provided via `--dart-define` at build time for security.
2. **Build**: 
   - **MANDATORY**: Always run `flutter clean` before a new build to ensure no cached configuration persists.
   - On WSL/Windows: Use `powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "flutter clean; flutter build apk --release --split-per-abi"`.
   - Note: Split APKs (`--split-per-abi`) are required to stay under the 50MB Telegram Bot API limit.
3. **Delivery**: 
   - Use the standardized script: `python3 scripts/send_apk.py build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.
   - The script automatically handles unique filenames and retrieves Telegram credentials from `config/api_keys.json`.

## 5. Subdirectory Instructions

- **Dart & Flutter Standards**: Detailed coding and architecture rules for the Dart codebase are located in [lib/GEMINI.md](./lib/GEMINI.md).

## 6. Directory Structure

```text
lib/
├── app/                # Global app config, routing, and theme
├── core/               # Shared utilities, constants, and network providers
├── data/               # Data layer (DTOs, Repository Impls, Data Sources)
├── domain/             # Domain layer (Entities, Repository Interfaces, Use Cases)
└── presentation/       # UI layer (Features, Widgets)
```

## 7. Testing

- **Unit Tests**: Mandatory for repositories and logic-heavy domain models.
- **Widget Tests**: Recommended for complex UI components.
- **Location**: All tests must reside in the `test/` directory, mirroring the `lib/` structure.
