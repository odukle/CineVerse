const ALLOWED_STATIC_PATHS = new Set([
  "/genre/movie/list",
  "/genre/tv/list",
  "/discover/movie",
  "/discover/tv",
  "/trending/movie/day",
  "/trending/movie/week",
  "/trending/tv/day",
  "/trending/tv/week",
  "/trending/person/day",
  "/trending/person/week",
  "/person/popular",
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
  "/search/keyword",
  "/search/collection",
  "/search/company",
]);

const TMDB_MOVIE_DETAILS_PATTERN = /^\/movie\/\d+$/;
const TMDB_MOVIE_TRANSLATIONS_PATTERN = /^\/movie\/\d+\/translations$/;
const TMDB_MOVIE_WATCH_PROVIDERS_PATTERN = /^\/movie\/\d+\/watch\/providers$/;
const TMDB_MOVIE_RECOMMENDATIONS_PATTERN = /^\/movie\/\d+\/recommendations$/;
const TMDB_MOVIE_REVIEWS_PATTERN = /^\/movie\/\d+\/reviews$/;
const TMDB_TV_DETAILS_PATTERN = /^\/tv\/\d+$/;
const TMDB_TV_TRANSLATIONS_PATTERN = /^\/tv\/\d+\/translations$/;
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
const TMDB_PERSON_TAGGED_IMAGES_PATTERN = /^\/person\/\d+\/tagged_images$/;
const TMDB_PERSON_DETAILS_PATTERN = /^\/person\/\d+$/;
const TMDB_PERSON_COMBINED_CREDITS_PATTERN = /^\/person\/\d+\/combined_credits$/;
const TMDB_PERSON_TV_CREDITS_PATTERN = /^\/person\/\d+\/tv_credits$/;
const TMDB_PERSON_MOVIE_CREDITS_PATTERN = /^\/person\/\d+\/movie_credits$/;
const TMDB_COLLECTION_PATTERN = /^\/collection\/\d+$/;
const TMDB_COMPANY_DETAILS_PATTERN = /^\/company\/\d+$/;
const SHARE_MOVIE_LINK_PATTERN = /^\/movies\/\d+$/;
const SHARE_LIST_LINK_PATTERN = /^\/lists\/[^/]+$/;
const ANDROID_APP_LINKS = [
  "D9:A1:EF:03:2A:02:3E:15:3F:6F:38:86:64:39:E9:4C:A0:1A:4F:F9:C2:3A:A7:47:87:3C:86:B4:11:A3:67:9D",
  "65:C2:66:D7:FA:FF:6C:18:CE:73:22:94:FF:0E:84:17:31:25:F2:6C:73:6D:0C:46:BB:59:DA:B7:1E:32:92:A7",
  "5A:D1:30:A1:6B:FA:D3:BF:E8:50:8A:7E:56:69:1E:6D:AE:24:8A:85:D7:6C:57:40:B9:9B:8F:95:19:4D:00:09",
];
const IOS_APP_LINKS = {
  appIDs: ["88KX9RVUCK.com.odukle.cineverse"],
  paths: ["/movies/*", "/lists/*"],
};
const DEFAULT_TMDB_BASE_URL = "https://api.themoviedb.org/3";


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

    if (!env.TMDB_API_KEY && !env.TMDB_BEARER_TOKEN) {
      return jsonResponse(
        {
          error:
            "Neither TMDB_API_KEY nor TMDB_BEARER_TOKEN is configured in the Worker.",
        },
        500,
      );
    }

    const url = new URL(request.url);

    if (url.pathname === "/.well-known/assetlinks.json") {
      return jsonResponse(
        ANDROID_APP_LINKS.map((fingerprint) => ({
          relation: ["delegate_permission/common.handle_all_urls"],
          target: {
            namespace: "android_app",
            package_name: "com.odukle.cineverse",
            sha256_cert_fingerprints: [fingerprint],
          },
        })),
        200,
        {
          "Cache-Control": "public, max-age=3600",
          "Content-Type": "application/json; charset=utf-8",
        },
      );
    }

    if (
      url.pathname === "/.well-known/apple-app-site-association" ||
      url.pathname === "/apple-app-site-association"
    ) {
      return jsonResponse(
        {
          applinks: {
            apps: [],
            details: [
              {
                appIDs: IOS_APP_LINKS.appIDs,
                paths: IOS_APP_LINKS.paths,
              },
            ],
          },
        },
        200,
        {
          "Cache-Control": "public, max-age=3600",
          "Content-Type": "application/json; charset=utf-8",
        },
      );
    }

    if (url.pathname === "/health") {
      return jsonResponse({ ok: true }, 200, {
        "Cache-Control": "no-store",
      });
    }

    if (SHARE_MOVIE_LINK_PATTERN.test(url.pathname)) {
      return htmlResponse(buildSharePage(url), 200, {
        "Cache-Control": "public, max-age=300",
      });
    }

    if (SHARE_LIST_LINK_PATTERN.test(url.pathname)) {
      return htmlResponse(buildListSharePage(url), 200, {
        "Cache-Control": "public, max-age=300",
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
    let upstreamResponse;
    try {
      upstreamResponse = await fetch(upstreamUrl, {
        method: "GET",
        headers: buildUpstreamHeaders(env),
      });
    } catch (error) {
      return jsonResponse(
        {
          error: "Upstream TMDB fetch failed.",
          detail: error instanceof Error ? error.message : String(error),
          upstreamUrl,
        },
        502,
        { "Cache-Control": "no-store" },
      );
    }

    if (upstreamResponse.status >= 500) {
      const fallbackResponse = await fetchFallbackDetailsResponse(url, env);
      if (fallbackResponse?.ok) {
        fallbackResponse.headers.set("Access-Control-Allow-Origin", "*");
        fallbackResponse.headers.set("Access-Control-Allow-Methods", "GET, OPTIONS");
        fallbackResponse.headers.set("Access-Control-Allow-Headers", "Content-Type");
        fallbackResponse.headers.set(
          "Cache-Control",
          `public, max-age=${cacheTtlSeconds(url.pathname)}`,
        );
        fallbackResponse.headers.set("X-Lumi-Fallback", "base-details");
        ctx.waitUntil(cache.put(cacheKey, fallbackResponse.clone()));
        return fallbackResponse;
      }

      let detail = "";
      try {
        detail = await upstreamResponse.text();
      } catch (_) {
        detail = "";
      }
      return jsonResponse(
        {
          error: "TMDB upstream returned a server error.",
          status: upstreamResponse.status,
          upstreamUrl,
          detail: detail.slice(0, 500),
        },
        502,
        { "Cache-Control": "no-store" },
      );
    }

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

function buildUpstreamHeaders(env) {
  const headers = {
    Accept: "application/json",
    "User-Agent": "Lumi-TMDB-Proxy/1.0",
  };

  if (typeof env.TMDB_BEARER_TOKEN === "string" && env.TMDB_BEARER_TOKEN.trim()) {
    headers.Authorization = `Bearer ${env.TMDB_BEARER_TOKEN.trim()}`;
  }

  return headers;
}

async function fetchFallbackDetailsResponse(requestUrl, env) {
  const isDetailsRoute =
    TMDB_MOVIE_DETAILS_PATTERN.test(requestUrl.pathname) ||
    TMDB_TV_DETAILS_PATTERN.test(requestUrl.pathname);
  if (!isDetailsRoute || !requestUrl.searchParams.has("append_to_response")) {
    return null;
  }

  const fallbackUrl = new URL(requestUrl.toString());
  fallbackUrl.searchParams.delete("append_to_response");

  const fallbackResponse = await fetch(buildUpstreamUrl(fallbackUrl, env), {
    method: "GET",
    headers: buildUpstreamHeaders(env),
  });
  if (fallbackResponse.ok) {
    return new Response(fallbackResponse.body, fallbackResponse);
  }

  fallbackUrl.searchParams.delete("language");
  fallbackUrl.searchParams.delete("region");
  const languageNeutralResponse = await fetch(buildUpstreamUrl(fallbackUrl, env), {
    method: "GET",
    headers: buildUpstreamHeaders(env),
  });
  if (languageNeutralResponse.ok) {
    return new Response(languageNeutralResponse.body, languageNeutralResponse);
  }

  return null;
}

function buildUpstreamUrl(requestUrl, env) {
  const baseUrl =
    typeof env.TMDB_BASE_URL === "string" && env.TMDB_BASE_URL.trim().length > 0
      ? env.TMDB_BASE_URL.trim().replace(/\/+$/, "")
      : DEFAULT_TMDB_BASE_URL;
  const upstreamUrl = new URL(`${baseUrl}${requestUrl.pathname}`);

  for (const [key, value] of requestUrl.searchParams.entries()) {
    if (key.toLowerCase() === "api_key") {
      continue;
    }

    upstreamUrl.searchParams.append(key, value);
  }

  if (
    (!env.TMDB_BEARER_TOKEN || !String(env.TMDB_BEARER_TOKEN).trim()) &&
    env.TMDB_API_KEY
  ) {
    upstreamUrl.searchParams.set("api_key", env.TMDB_API_KEY);
  }
  return upstreamUrl.toString();
}

function cacheTtlSeconds(pathname) {
  return TMDB_MOVIE_DETAILS_PATTERN.test(pathname) ||
    TMDB_MOVIE_TRANSLATIONS_PATTERN.test(pathname) ||
    TMDB_MOVIE_WATCH_PROVIDERS_PATTERN.test(pathname) ||
    TMDB_MOVIE_RECOMMENDATIONS_PATTERN.test(pathname) ||
    TMDB_MOVIE_REVIEWS_PATTERN.test(pathname) ||
    TMDB_TV_DETAILS_PATTERN.test(pathname) ||
    TMDB_TV_TRANSLATIONS_PATTERN.test(pathname) ||
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
    TMDB_PERSON_TAGGED_IMAGES_PATTERN.test(pathname) ||
    TMDB_PERSON_DETAILS_PATTERN.test(pathname) ||
    TMDB_PERSON_COMBINED_CREDITS_PATTERN.test(pathname) ||
    TMDB_COLLECTION_PATTERN.test(pathname) ||
    TMDB_COMPANY_DETAILS_PATTERN.test(pathname)
    ? 3600
    : 600;
}

function isAllowedPath(pathname) {
  return (
    ALLOWED_STATIC_PATHS.has(pathname) ||
    TMDB_MOVIE_DETAILS_PATTERN.test(pathname) ||
    TMDB_MOVIE_TRANSLATIONS_PATTERN.test(pathname) ||
    TMDB_MOVIE_WATCH_PROVIDERS_PATTERN.test(pathname) ||
    TMDB_MOVIE_RECOMMENDATIONS_PATTERN.test(pathname) ||
    TMDB_MOVIE_REVIEWS_PATTERN.test(pathname) ||
    TMDB_TV_DETAILS_PATTERN.test(pathname) ||
    TMDB_TV_TRANSLATIONS_PATTERN.test(pathname) ||
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
    TMDB_PERSON_TAGGED_IMAGES_PATTERN.test(pathname) ||
    TMDB_PERSON_DETAILS_PATTERN.test(pathname) ||
    TMDB_PERSON_COMBINED_CREDITS_PATTERN.test(pathname) ||
    TMDB_PERSON_TV_CREDITS_PATTERN.test(pathname) ||
    TMDB_PERSON_MOVIE_CREDITS_PATTERN.test(pathname) ||
    TMDB_COLLECTION_PATTERN.test(pathname) ||
    TMDB_COMPANY_DETAILS_PATTERN.test(pathname)
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

function htmlResponse(html, status = 200, extraHeaders = {}) {
  return new Response(html, {
    status,
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      ...extraHeaders,
    },
  });
}

function buildSharePage(url) {
  const mediaId = url.pathname.split("/").pop();
  const isTv = url.searchParams.get("isTv") === "true";
  const encodedTitle = url.searchParams.get("title") || "Lumi pick";
  const title = escapeHtml(encodedTitle);
  const tmdbUrl = `https://www.themoviedb.org/${isTv ? "tv" : "movie"}/${mediaId}`;
  const playStoreUrl =
    "https://play.google.com/store/apps/details?id=com.odukle.cineverse";
  const appStoreUrl = "https://apps.apple.com/app/id6775792556";

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${title} • Lumi</title>
    <meta name="description" content="Open ${title} in Lumi." />
    <style>
      :root {
        color-scheme: dark;
      }
      body {
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        background:
          radial-gradient(circle at top, rgba(111, 168, 255, 0.18), transparent 38%),
          linear-gradient(180deg, #0d1118, #07090d 60%);
        color: #f5f7fb;
        font: 16px/1.5 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      .shell {
        width: min(92vw, 460px);
        padding: 28px;
        border-radius: 28px;
        background: rgba(14, 18, 28, 0.88);
        border: 1px solid rgba(255,255,255,0.10);
        box-shadow: 0 24px 80px rgba(0,0,0,0.38);
      }
      .eyebrow {
        display: inline-flex;
        padding: 6px 10px;
        border-radius: 999px;
        background: rgba(255,255,255,0.06);
        color: rgba(255,255,255,0.78);
        font-size: 12px;
        letter-spacing: 0.02em;
      }
      h1 {
        margin: 14px 0 8px;
        font-size: 28px;
        line-height: 1.08;
      }
      p {
        margin: 0 0 18px;
        color: rgba(255,255,255,0.74);
      }
      .actions {
        display: grid;
        gap: 12px;
      }
      a.button {
        display: inline-flex;
        justify-content: center;
        align-items: center;
        min-height: 48px;
        padding: 0 16px;
        border-radius: 16px;
        text-decoration: none;
        font-weight: 700;
      }
      a.primary {
        background: linear-gradient(135deg, #80d8ff, #7c9dff);
        color: #08111c;
      }
      a.secondary {
        background: rgba(255,255,255,0.06);
        color: #f5f7fb;
        border: 1px solid rgba(255,255,255,0.10);
      }
      .stores {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
      }
      @media (max-width: 460px) {
        .stores {
          grid-template-columns: 1fr;
        }
      }
    </style>
  </head>
  <body>
    <main class="shell">
      <div class="eyebrow">${isTv ? "TV Show" : "Movie"} • Shared from Lumi</div>
      <h1>${title}</h1>
      <p>This shared Lumi link is clickable in messaging apps. If Lumi is installed and app links are supported, your device can open it directly in the app.</p>
      <div class="actions">
        <a class="button primary" href="${tmdbUrl}">View on TMDB</a>
        <div class="stores">
          <a class="button secondary" href="${playStoreUrl}">Get Lumi on Android</a>
          <a class="button secondary" href="${appStoreUrl}">Get Lumi on iPhone</a>
        </div>
      </div>
    </main>
  </body>
</html>`;
}

function buildListSharePage(url) {
  const shareId = url.pathname.split("/").pop();
  const encodedName = url.searchParams.get("name") || "Shared Lumi list";
  const name = escapeHtml(encodedName);
  const playStoreUrl =
    "https://play.google.com/store/apps/details?id=com.odukle.cineverse";
  const appStoreUrl = "https://apps.apple.com/app/id6775792556";

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${name} • Lumi</title>
    <meta name="description" content="Import ${name} into Lumi." />
    <style>
      :root {
        color-scheme: dark;
      }
      body {
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        background:
          radial-gradient(circle at top, rgba(111, 168, 255, 0.18), transparent 38%),
          linear-gradient(180deg, #0d1118, #07090d 60%);
        color: #f5f7fb;
        font: 16px/1.5 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      }
      .shell {
        width: min(92vw, 460px);
        padding: 28px;
        border-radius: 28px;
        background: rgba(14, 18, 28, 0.88);
        border: 1px solid rgba(255,255,255,0.10);
        box-shadow: 0 24px 80px rgba(0,0,0,0.38);
      }
      .eyebrow {
        display: inline-flex;
        padding: 6px 10px;
        border-radius: 999px;
        background: rgba(255,255,255,0.06);
        color: rgba(255,255,255,0.78);
        font-size: 12px;
        letter-spacing: 0.02em;
      }
      h1 {
        margin: 14px 0 8px;
        font-size: 28px;
        line-height: 1.08;
      }
      p {
        margin: 0 0 18px;
        color: rgba(255,255,255,0.74);
      }
      .actions {
        display: grid;
        gap: 12px;
      }
      a.button {
        display: inline-flex;
        justify-content: center;
        align-items: center;
        min-height: 48px;
        padding: 0 16px;
        border-radius: 16px;
        text-decoration: none;
        font-weight: 700;
      }
      a.primary {
        background: linear-gradient(135deg, #80d8ff, #7c9dff);
        color: #08111c;
      }
      a.secondary {
        background: rgba(255,255,255,0.06);
        color: #f5f7fb;
        border: 1px solid rgba(255,255,255,0.10);
      }
      .stores {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
      }
      @media (max-width: 460px) {
        .stores {
          grid-template-columns: 1fr;
        }
      }
    </style>
  </head>
  <body>
    <main class="shell">
      <div class="eyebrow">Shared from Lumi</div>
      <h1>${name}</h1>
      <p>If Lumi is installed and your device supports app links, this link can open the app directly and let you import the shared list.</p>
      <div class="actions">
        <a class="button primary" href="https://cineverse-tmdb-proxy.sodukle.workers.dev/lists/${shareId}?name=${encodeURIComponent(
          encodedName,
        )}">Open shared list</a>
        <div class="stores">
          <a class="button secondary" href="${playStoreUrl}">Get Lumi on Android</a>
          <a class="button secondary" href="${appStoreUrl}">Get Lumi on iPhone</a>
        </div>
      </div>
    </main>
  </body>
</html>`;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}
