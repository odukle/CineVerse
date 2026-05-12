---
trigger: model_decision
---

# Launch Debug Session

When the user requests to launch a debug session or start the app in debug mode, you MUST use the following command and then STOP. Do not perform any additional actions or research unless specifically asked.

```powershell
flutter run --debug `
  --dart-define=MOVIE_PROXY_BASE_URL="https://cineverse-tmdb-proxy.sodukle.workers.dev/" `
  --dart-define=OMDB_API_KEY="a7152ae"
```
