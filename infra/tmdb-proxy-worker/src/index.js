const ALLOWED_STATIC_PATHS = new Set([
  "/genre/movie/list",
  "/genre/tv/list",
  "/discover/movie",
  "/discover/tv",
  "/trending/movie/day",
  "/trending/movie/week",
  "/trending/tv/day",
  "/trending/tv/week",
  "/movie/popular",
  "/movie/top_rated",
  "/movie/now_playing",
  "/movie/upcoming",
  "/tv/popular",
  "/tv/top_rated",
  "/tv/on_the_air",
  "/tv/airing_today",
  "/search/multi",
  "/search/person",
  "/search/movie",
  "/search/tv",
]);

const TMDB_MOVIE_DETAILS_PATTERN = /^\/movie\/\d+$/;
const TMDB_MOVIE_WATCH_PROVIDERS_PATTERN = /^\/movie\/\d+\/watch\/providers$/;
const TMDB_MOVIE_RECOMMENDATIONS_PATTERN = /^\/movie\/\d+\/recommendations$/;
const TMDB_MOVIE_REVIEWS_PATTERN = /^\/movie\/\d+\/reviews$/;
const TMDB_TV_DETAILS_PATTERN = /^\/tv\/\d+$/;
const TMDB_TV_WATCH_PROVIDERS_PATTERN = /^\/tv\/\d+\/watch\/providers$/;
const TMDB_TV_RECOMMENDATIONS_PATTERN = /^\/tv\/\d+\/recommendations$/;
const TMDB_TV_REVIEWS_PATTERN = /^\/tv\/\d+\/reviews$/;
const TMDB_MOVIE_IMAGES_PATTERN = /^\/movie\/\d+\/images$/;
const TMDB_TV_IMAGES_PATTERN = /^\/tv\/\d+\/images$/;
const TMDB_TV_SEASON_PATTERN = /^\/tv\/\d+\/season\/\d+$/;
const TMDB_TV_EPISODE_PATTERN = /^\/tv\/\d+\/season\/\d+\/episode\/\d+$/;
const TMDB_TV_EPISODE_CREDITS_PATTERN = /^\/tv\/\d+\/season\/\d+\/episode\/\d+\/credits$/;
const TMDB_TV_EPISODE_IMAGES_PATTERN = /^\/tv\/\d+\/season\/\d+\/episode\/\d+\/images$/;
const TMDB_PERSON_IMAGES_PATTERN = /^\/person\/\d+\/images$/;
const TMDB_PERSON_DETAILS_PATTERN = /^\/person\/\d+$/;
const TMDB_PERSON_COMBINED_CREDITS_PATTERN = /^\/person\/\d+\/combined_credits$/;
const TMDB_PERSON_TV_CREDITS_PATTERN = /^\/person\/\d+\/tv_credits$/;
const TMDB_PERSON_MOVIE_CREDITS_PATTERN = /^\/person\/\d+\/movie_credits$/;

export default {
  async fetch(request, env, ctx) {
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(),
      });
    }

    if (request.method !== "GET") {
      return jsonResponse({ error: "Method not allowed" }, 405, {
        Allow: "GET, OPTIONS",
      });
    }

    if (!env.TMDB_API_KEY) {
      return jsonResponse(
        { error: "TMDB_API_KEY secret is not configured in the Worker." },
        500,
      );
    }

    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return jsonResponse({ ok: true }, 200, {
        "Cache-Control": "no-store",
      });
    }

    if (!isAllowedPath(url.pathname)) {
      return jsonResponse({ error: "Unsupported proxy route." }, 404);
    }

    const cache = caches.default;
    const cacheKey = new Request(url.toString(), request);
    const cachedResponse = await cache.match(cacheKey);

    if (cachedResponse) {
      return withCors(cachedResponse);
    }

    const upstreamUrl = buildUpstreamUrl(url, env);
    const upstreamResponse = await fetch(upstreamUrl, {
      method: "GET",
      headers: {
        Accept: "application/json",
      },
      cf: {
        cacheTtl: cacheTtlSeconds(url.pathname),
        cacheEverything: true,
      },
    });

    const response = new Response(upstreamResponse.body, upstreamResponse);
    response.headers.set("Access-Control-Allow-Origin", "*");
    response.headers.set("Access-Control-Allow-Methods", "GET, OPTIONS");
    response.headers.set("Access-Control-Allow-Headers", "Content-Type");
    response.headers.set(
      "Cache-Control",
      `public, max-age=${cacheTtlSeconds(url.pathname)}`,
    );

    if (upstreamResponse.ok) {
      ctx.waitUntil(cache.put(cacheKey, response.clone()));
    }

    return response;
  },
};

function buildUpstreamUrl(requestUrl, env) {
  const upstreamUrl = new URL(`${env.TMDB_BASE_URL}${requestUrl.pathname}`);

  for (const [key, value] of requestUrl.searchParams.entries()) {
    if (key.toLowerCase() === "api_key") {
      continue;
    }

    upstreamUrl.searchParams.append(key, value);
  }

  upstreamUrl.searchParams.set("api_key", env.TMDB_API_KEY);
  return upstreamUrl.toString();
}

function cacheTtlSeconds(pathname) {
  return TMDB_MOVIE_DETAILS_PATTERN.test(pathname) ||
    TMDB_MOVIE_WATCH_PROVIDERS_PATTERN.test(pathname) ||
    TMDB_MOVIE_RECOMMENDATIONS_PATTERN.test(pathname) ||
    TMDB_MOVIE_REVIEWS_PATTERN.test(pathname) ||
    TMDB_TV_DETAILS_PATTERN.test(pathname) ||
    TMDB_TV_WATCH_PROVIDERS_PATTERN.test(pathname) ||
    TMDB_TV_RECOMMENDATIONS_PATTERN.test(pathname) ||
    TMDB_TV_REVIEWS_PATTERN.test(pathname) ||
    TMDB_TV_SEASON_PATTERN.test(pathname) ||
    TMDB_TV_EPISODE_PATTERN.test(pathname) ||
    TMDB_TV_EPISODE_CREDITS_PATTERN.test(pathname) ||
    TMDB_TV_EPISODE_IMAGES_PATTERN.test(pathname) ||
    TMDB_MOVIE_IMAGES_PATTERN.test(pathname) ||
    TMDB_TV_IMAGES_PATTERN.test(pathname) ||
    TMDB_PERSON_IMAGES_PATTERN.test(pathname) ||
    TMDB_PERSON_DETAILS_PATTERN.test(pathname) ||
    TMDB_PERSON_COMBINED_CREDITS_PATTERN.test(pathname)
    ? 3600
    : 600;
}

function isAllowedPath(pathname) {
  return (
    ALLOWED_STATIC_PATHS.has(pathname) ||
    TMDB_MOVIE_DETAILS_PATTERN.test(pathname) ||
    TMDB_MOVIE_WATCH_PROVIDERS_PATTERN.test(pathname) ||
    TMDB_MOVIE_RECOMMENDATIONS_PATTERN.test(pathname) ||
    TMDB_MOVIE_REVIEWS_PATTERN.test(pathname) ||
    TMDB_TV_DETAILS_PATTERN.test(pathname) ||
    TMDB_TV_WATCH_PROVIDERS_PATTERN.test(pathname) ||
    TMDB_TV_RECOMMENDATIONS_PATTERN.test(pathname) ||
    TMDB_TV_REVIEWS_PATTERN.test(pathname) ||
    TMDB_TV_SEASON_PATTERN.test(pathname) ||
    TMDB_TV_EPISODE_PATTERN.test(pathname) ||
    TMDB_TV_EPISODE_CREDITS_PATTERN.test(pathname) ||
    TMDB_TV_EPISODE_IMAGES_PATTERN.test(pathname) ||
    TMDB_MOVIE_IMAGES_PATTERN.test(pathname) ||
    TMDB_TV_IMAGES_PATTERN.test(pathname) ||
    TMDB_PERSON_IMAGES_PATTERN.test(pathname) ||
    TMDB_PERSON_DETAILS_PATTERN.test(pathname) ||
    TMDB_PERSON_COMBINED_CREDITS_PATTERN.test(pathname) ||
    TMDB_PERSON_TV_CREDITS_PATTERN.test(pathname) ||
    TMDB_PERSON_MOVIE_CREDITS_PATTERN.test(pathname)
  );
}

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  };
}

function jsonResponse(payload, status, extraHeaders = {}) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(),
      ...extraHeaders,
    },
  });
}

function withCors(response) {
  const headers = new Headers(response.headers);
  const cors = corsHeaders();
  for (const [key, value] of Object.entries(cors)) {
    headers.set(key, value);
  }

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
