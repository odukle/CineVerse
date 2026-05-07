Build a modern cross-platform mobile application called **“Lumi”** using **Flutter (Dart)** — a personal movie & TV tracking, discovery, and analysis platform that combines watchlist management, viewing history, intelligent recommendations, and deep film insights.

---

## 🎯 Core Product Vision

This app should not feel like a basic tracker. It should act as a **personal cinema intelligence system** that:

- Learns user taste over time
- Helps users decide what to watch instantly
- Provides deep insights into movies and personal viewing behavior
- Combines productivity (tracking) with delight (discovery + analysis)

---

## 🧱 Tech Stack (MANDATORY)

### Frontend

- Framework: Flutter (latest stable)
- Language: Dart
- Architecture: Clean Architecture + Feature-first structure
- State Management: Riverpod (preferred) or Bloc
- Routing: GoRouter
- UI: Material 3 (custom cinematic dark theme)

### Backend

- Firebase:
  - Authentication (Email/Password + Google Sign-In)
  - Firestore (database)
  - Cloud Functions (for logic & notifications)
  - Firebase Storage (for voice notes)

### Local Storage

- Hive or Drift (for offline-first caching)

### Networking

- Dio (preferred) or http package

### Media

- Video player: better_player or chewie (for trailers)
- Image caching: cached_network_image

---

## 🌐 Approved APIs

1. Primary Movie Data:

- TMDb API (v3)
  - Movie and series metadata
  - Posters/artwork, cast, crew, genres, runtime, release metadata

- Use TMDb as the primary catalog and discovery source

2. Ratings:

- TMDb metadata as the primary catalog source
- OMDb API (free tier) for:
  - IMDb rating
  - Rotten Tomatoes score
  - Metacritic score

3. Trailers:
   - YouTube Data API (free tier)

4. Streaming Availability:

- Defer until a region-compatible provider is approved for India
- Do not depend on the previous watch-provider integration

---

## 🔐 Authentication

- Firebase Auth:
  - Email/password
  - Google Sign-In

---

## 🧩 Core Features

### 1. Watchlist + Watched Log

- Add/remove titles
- Mark as watched
- Store:
  - Rating (1–5 stars)
  - Review
  - Rewatch count
  - Watch date

---

### 2. Movie Details Page

Display:

- Poster + backdrop
- Title, year, runtime
- Genres
- Synopsis
- Cast & crew
- Ratings:
  - IMDb
  - Rotten Tomatoes
  - Metacritic

- Trailer (YouTube embed/player)
- Streaming availability (India)

---

### 3. Smart Notes System

- Text notes
- Voice notes (store in Firebase Storage)
- Timestamp-based notes
- Tagging system:
  - Cinematography
  - Plot
  - Acting

- AI-generated summary of notes

---

### 4. Scene Bookmarking

- Save timestamps
- Add comments to scenes
- Timeline markers UI

---

### 5. Mood-Based Discovery (IMPORTANT USP)

Allow users to select moods instead of genres:

- Mind-bending
- Feel-good
- Dark & disturbing
- Rainy day
- Fast-paced

Map moods → genres + keywords internally

---

### 6. “What Should I Watch Tonight?” Engine

Inputs:

- Time available
- Mood
- Language
- Streaming availability

Output:

- ONE strong recommendation
- With explanation:
  - “Because you liked X and Y”

---

### 7. Personal Taste Profiling

Track:

- Genres watched
- Ratings per genre
- Runtime preference
- Favorite actors/directors

Generate insights like:

- “You prefer slow-burn thrillers”
- “You rate shorter films higher”

---

### 8. Visual Analytics Dashboard

Include:

- Watch heatmap (calendar style)
- Genre distribution chart
- Rating trends
- Most watched actors/directors
- Yearly summaries

---

### 9. Hidden Gems Engine

- Filter:
  - High rating
  - Low popularity

- Suggest underrated content

---

### 10. Social Features (Focused)

- Find users with similar taste
- Compare ratings
- Private groups:
  - Shared watchlists
  - Group recommendations

---

### 11. Streaming Availability (India-focused)

- Platforms:
  - Netflix
  - Prime Video
  - Disney+ Hotstar

- Notify when a watchlist item becomes available

---

### 12. Deep Dive Mode

Expandable section:

- Director patterns
- Cinematography insights
- Similar films
- Trivia clusters

---

### 13. AI “Explain This Movie”

After watching:

- Explain ending
- Symbolism
- Hidden meanings

---

### 14. Smart Reminders

- Resume unfinished movies
- New season alerts
- Trilogy continuation suggestions

---

### 15. Gamification

- Watch streaks
- Achievements:
  - “Indie Explorer”
  - “Thriller Addict”

---

### 16. Trailer-based Discovery (Reels-style)

- Vertical scrolling UI
- Auto-play trailers
- Swipe to explore

---

## 🧠 Logic / Intelligence Layer

- Content-based recommendation engine
- Mood mapping system
- Taste profiling algorithm
- Future scope: collaborative filtering

---

## 📦 Offline Support

- Cache:
  - Watchlist
  - Recent titles

- Sync with Firestore when online

---

## 🎨 UI/UX Requirements

- Dark cinematic theme
- Poster-first design
- Smooth animations
- Minimal clutter
- Fast navigation

---

## ⚡ Performance Requirements

- Lazy loading lists
- Pagination
- Efficient image caching
- No UI thread blocking

---

## 🔒 Security

- Secure API keys
- Firebase rules for user isolation

---

## 🚀 MVP Scope (Phase 1)

- Authentication
- Watchlist + Watched
- Movie details (TMDb + OMDb)
- Ratings
- Notes
- Basic recommendations

---

## 🌱 Phase 2+

- AI insights
- Social features
- Scene bookmarking
- Analytics dashboard
- Mood engine

---

## 🧪 Bonus Features

- Export watch history (CSV)
- Share movie cards
- Home screen widget

---

## 📌 Important Constraints

- Use TMDb as the primary metadata provider for discovery and details
- Keep the integration modular so TMDb can be swapped later if licensing or availability changes
- Maintain modular, scalable architecture
- Avoid over-engineering MVP

---

## 🎯 Final Goal

The app should feel like:
👉 Netflix-level discovery + personal diary + AI assistant for films

NOT just a movie database viewer.

---
