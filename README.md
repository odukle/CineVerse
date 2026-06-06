# Lumi Cinema

Lumi Cinema is a Flutter app for discovering movies and shows, tracking personal watch history, exploring memorable quotes, and creating shareable quote cards.

## Features

- Browse curated movie and TV discovery rails
- Save titles to watchlist, favourites, lists, notes, and watched history
- Get AI-assisted recommendation prompts for "what should I watch tonight?"
- View personal watch analytics and genre trends
- Browse memorable quotes and scenes
- Create portrait and landscape quote cards for sharing

## Tech Stack

- Flutter
- Firebase Authentication
- Cloud Firestore
- Firebase Functions
- TMDB-backed content data

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or Xcode
- Firebase project configured for this app

### Run locally

```bash
flutter pub get
flutter run
```

## Firebase Notes

This repo includes client-side Firebase configuration files used by the mobile app. These are standard public client config values, not server secrets. Sensitive keys, service accounts, signing files, and deployment secrets are intentionally not tracked in Git.

Before using this app with your own backend setup, make sure to:

- configure your own Firebase project
- review Firestore security rules
- store server-side secrets outside the repository

## Support

- Support page: `docs/support/index.html`
- Privacy policy: `docs/support/privacy.html`

## Flutter Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Flutter codelabs](https://docs.flutter.dev/get-started/codelab)
