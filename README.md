# Lumi Cinema

Lumi Cinema is a Flutter app for cinephiles who want better movie and TV discovery, richer personal tracking, and more expressive ways to save and share the moments they love.

It combines recommendation-driven browsing, personal library tools, watch analytics, memorable quote exploration, and cinematic quote-card creation in one experience.

## Highlights

- Discover movies and shows through curated rails and collections
- Organize a personal library with watchlist, favourites, lists, notes, and watched history
- Use AI-assisted prompts to answer the classic "what should I watch tonight?" question
- Explore watch analytics such as genre trends and viewing patterns
- Browse memorable quotes and scenes
- Create portrait and landscape quote cards designed for sharing

## Features

- Browse curated movie and TV discovery rails
- Save titles to watchlist, favourites, lists, notes, and watched history
- Get AI-assisted recommendation prompts for "what should I watch tonight?"
- View personal watch analytics and genre trends
- Browse memorable quotes and scenes
- Create portrait and landscape quote cards for sharing

## Built With

- Flutter
- Firebase Authentication
- Cloud Firestore
- Firebase Functions
- TMDB-backed content data

## Tech Stack

The app is built with Flutter and uses Firebase for authentication, data storage, and backend workflows.

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or Xcode
- Firebase project configured for this app

### Run Locally

```bash
flutter pub get
flutter run
```

You will also need to provide your own Firebase and platform configuration if you are setting up the project from scratch.

## Firebase Notes

Before using this app with your own backend setup, make sure to:

- configure your own Firebase project
- review Firestore security rules
- store server-side secrets outside the repository

## Support

- Support page: [docs/support/index.html](docs/support/index.html)
- Privacy policy: [docs/support/privacy.html](docs/support/privacy.html)

## Development Notes

- Android release signing is configured through local key files that are intentionally not tracked in Git
- Store listing assets and release-prep utilities are kept as local-only artifacts unless explicitly added

## Learn More

- [Flutter documentation](https://docs.flutter.dev/)
- [Flutter codelabs](https://docs.flutter.dev/get-started/codelab)
