# CineVerse TMDb Proxy Worker

This Cloudflare Worker proxies the small subset of TMDb endpoints used by the app so production devices do not need to resolve TMDb directly.

## Endpoints

- `GET /health`
- `GET /trending/movie/day`
- `GET /trending/movie/week`
- `GET /movie/popular`
- `GET /movie/top_rated`
- `GET /movie/now_playing`
- `GET /movie/upcoming`
- `GET /tv/popular`
- `GET /tv/top_rated`
- `GET /tv/on_the_air`
- `GET /tv/airing_today`
- `GET /discover/movie`
- `GET /movie/:id`

All incoming query parameters are forwarded except `api_key`. The Worker injects `TMDB_API_KEY` from its secret configuration.

## Setup

1. `cd infra/tmdb-proxy-worker`
2. `npm install`
3. `npx wrangler secret put TMDB_API_KEY`
4. `npm run deploy`

Set `MOVIE_PROXY_BASE_URL` in the Flutter app to the deployed Worker URL, for example:

```json
{
  "MOVIE_PROXY_BASE_URL": "https://cineverse-tmdb-proxy.your-subdomain.workers.dev",
  "TMDB_API_KEY": "",
  "OMDB_API_KEY": "your_omdb_api_key"
}
```

## Notes

- Keep `TMDB_API_KEY` empty on the client when using the proxy in production.
- The Worker caches list responses for 10 minutes and movie details for 1 hour.
- If you later front the Worker with a custom domain, point `MOVIE_PROXY_BASE_URL` to that domain instead of the raw `workers.dev` URL.
