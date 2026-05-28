"use strict";

const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret, defineString } = require("firebase-functions/params");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

const db = admin.firestore();
const openRouterApiKey = defineSecret("OPENROUTER_API_KEY");
const geminiApiKey = defineSecret("GEMINI_API_KEY");
const omdbApiKey = defineSecret("OMDB_API_KEY");
const geminiChatModel = defineString("GEMINI_CHAT_MODEL", {
  default: "gemini-2.5-flash-lite",
});
const geminiChatFallbackModels = defineString("GEMINI_CHAT_FALLBACK_MODELS", {
  default: "gemini-2.0-flash,gemini-2.5-flash",
});
const chatModel = defineString("OPENROUTER_CHAT_MODEL", {
  default: "openrouter/free",
});
const chatFallbackModels = defineString("OPENROUTER_CHAT_FALLBACK_MODELS", {
  default:
    "deepseek/deepseek-v4-flash:free,qwen/qwen3-32b:free,mistralai/mistral-small-3.2-24b-instruct:free,meta-llama/llama-3.3-70b-instruct:free",
});
const embeddingModel = defineString("OPENROUTER_EMBEDDING_MODEL", {
  default: "nvidia/llama-nemotron-embed-vl-1b-v2:free",
});
const movieProxyBaseUrl = defineString("MOVIE_PROXY_BASE_URL", {
  default: "__unset__",
});
const tmdbApiKey = defineSecret("TMDB_API_KEY");
const indexCollection = defineString("TONIGHT_VECTOR_COLLECTION", {
  default: "tmdb_movie_vectors_v1",
});
const qdrantUrl = defineString("QDRANT_URL", {
  default: "",
});
const qdrantCollection = defineString("QDRANT_COLLECTION", {
  default: "tmdb_movie_vectors_v2",
});
const qdrantApiKey = defineSecret("QDRANT_API_KEY");
const qdrantTimeoutMs = defineString("QDRANT_TIMEOUT_MS", {
  default: "12000",
});
const qdrantFailoverToFirestore = defineString(
  "QDRANT_FAILOVER_TO_FIRESTORE",
  {
    default: "true",
  }
);
const vectorBackend = defineString("TONIGHT_VECTOR_BACKEND", {
  default: "zilliz",
});
const zillizEndpoint = defineString("ZILLIZ_ENDPOINT", {
  default: "",
});
const zillizCollection = defineString("ZILLIZ_COLLECTION", {
  default: "tmdb_movie_vectors_v3",
});
const zillizApiKey = defineSecret("ZILLIZ_API_KEY");
const zillizDbName = defineString("ZILLIZ_DB_NAME", {
  default: "default",
});
const zillizVectorField = defineString("ZILLIZ_VECTOR_FIELD", {
  default: "vector",
});
const zillizVectorDim = defineString("ZILLIZ_VECTOR_DIM", {
  default: "1024",
});
const zillizTimeoutMs = defineString("ZILLIZ_TIMEOUT_MS", {
  default: "12000",
});
const zillizFailoverToFirestore = defineString(
  "ZILLIZ_FAILOVER_TO_FIRESTORE",
  {
    default: "true",
  }
);
const TMDB_BASE_URL = "https://api.themoviedb.org/3";
const SEED_ENRICHMENT_TIMEOUT_MS = 4000;
const MAX_PROMPT_CHARS = 420;
const RATE_LIMIT_COLLECTION = "_recommendTonightRateLimits";
const RATE_LIMITS = {
  anonymous: { perMinute: 5, perDay: 120, cooldownSeconds: 45 },
  appCheckVerified: { perMinute: 8, perDay: 300, cooldownSeconds: 30 },
  user: { perMinute: 10, perDay: 450, cooldownSeconds: 20 },
};
const FRANCHISE_ALIASES = {
  marvel: [
    "marvel",
    "marvels",
    "mcu",
    "stan lee",
    "avengers",
    "x men",
    "xmen",
    "iron man",
    "captain america",
    "guardians of the galaxy",
    "doctor strange",
    "black panther",
    "thor",
    "hulk",
    "black widow",
    "spider man",
    "spiderman",
    "ant man",
    "deadpool",
    "wolverine",
    "fantastic four",
    "shang chi",
    "eternals",
  ],
  dc: [
    "dc",
    "dceu",
    "justice league",
    "batman",
    "superman",
    "wonder woman",
    "aquaman",
    "the flash",
    "flash",
    "shazam",
    "joker",
    "suicide squad",
    "injustice",
    "watchmen",
    "green lantern",
    "teen titans",
    "constantine",
  ],
};
const GENRE_CANONICAL_ALIASES = {
  "science fiction": [
    "science fiction",
    "sci fi",
    "sci-fi",
    "scifi",
    "sf",
    "sci fi fantasy",
    "sci-fi fantasy",
  ],
  fantasy: ["fantasy"],
  action: ["action", "action packed"],
  adventure: ["adventure"],
  animation: ["animation", "animated"],
  comedy: ["comedy", "funny", "humor", "humour", "rom com", "romcom"],
  crime: ["crime", "gangster", "heist"],
  documentary: ["documentary", "docu"],
  drama: ["drama", "dramatic"],
  family: ["family", "kids"],
  history: ["history", "historical"],
  horror: ["horror", "scary", "frightening", "supernatural horror"],
  music: ["music", "musical"],
  mystery: ["mystery", "detective", "whodunit"],
  romance: ["romance", "romantic", "love story"],
  thriller: ["thriller", "suspense", "suspenseful"],
  war: ["war", "military"],
  western: ["western"],
  "tv movie": ["tv movie", "television movie", "made for tv"],
};
const GENRE_ALIAS_TO_CANONICAL = buildGenreAliasToCanonicalMap();
const MOVIE_DOMAIN_HINTS = [
  "movie",
  "movies",
  "film",
  "films",
  "watch",
  "watch tonight",
  "recommend",
  "recommendation",
  "cinema",
  "plot",
  "story",
  "trailer",
  "actor",
  "actress",
  "director",
  "cast",
  "genre",
  "oscar",
  "imdb",
  "rotten tomatoes",
  "box office",
  "similar to",
  "like",
  "bollywood",
  "hollywood",
  "sequel",
  "prequel",
];
const OFF_TOPIC_HINTS = [
  "python",
  "javascript",
  "typescript",
  "java",
  "c++",
  "c#",
  "golang",
  "rust",
  "kotlin",
  "swift",
  "sql",
  "api",
  "sdk",
  "firebase",
  "flutter",
  "docker",
  "kubernetes",
  "linux",
  "bash",
  "terminal",
  "script",
  "code",
  "program",
  "algorithm",
  "debug",
  "compiler",
  "compile",
  "class",
  "function",
  "regex",
  "machine learning",
  "neural network",
  "resume",
  "cv",
];

exports.resolveOmdbTitleDetails = onRequest(
  {
    region: "us-east4",
    cors: true,
    secrets: [omdbApiKey],
    timeoutSeconds: 20,
    memory: "256MiB",
    invoker: "public",
  },
  async (request, response) => {
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "GET" && request.method !== "POST") {
      response.status(405).json({ error: "Use GET or POST." });
      return;
    }

    const payload = request.method === "POST" ? request.body || {} : {};
    const query = request.query || {};
    const imdbId = String(payload.imdbId || query.imdbId || "").trim();
    const mode = String(payload.mode || query.mode || "details")
      .trim()
      .toLowerCase();
    const plot = String(payload.plot || query.plot || "full")
      .trim()
      .toLowerCase();

    if (!imdbId) {
      response.status(400).json({ error: "imdbId is required." });
      return;
    }

    const apiKey = String(omdbApiKey.value() || "").trim();
    if (!apiKey) {
      response.status(500).json({ error: "OMDB secret is not configured." });
      return;
    }

    const params = new URLSearchParams({
      apikey: apiKey,
      i: imdbId,
    });
    if (mode === "details") {
      params.set("plot", plot === "short" ? "short" : "full");
    }

    try {
      const upstream = await fetch(`https://www.omdbapi.com/?${params.toString()}`, {
        method: "GET",
        headers: {
          Accept: "application/json",
          "User-Agent": "cineverse-omdb-resolver/1.0",
        },
      });
      const data = await upstream.json().catch(() => ({}));
      if (!upstream.ok) {
        response.status(upstream.status).json({
          error: `OMDb upstream failed (${upstream.status}).`,
        });
        return;
      }

      response.status(200).json({
        source: "omdb",
        mode,
        data,
      });
    } catch (error) {
      console.error("resolveOmdbTitleDetails failed", error);
      response.status(502).json({
        error:
          error instanceof Error
            ? error.message
            : "OMDb resolver failed.",
      });
    }
  }
);

exports.recommendTonight = onRequest(
  {
    region: "us-east4",
    cors: true,
    secrets: [openRouterApiKey, geminiApiKey, tmdbApiKey, qdrantApiKey, zillizApiKey],
    timeoutSeconds: 60,
    memory: "512MiB",
    invoker: "public",
  },
  async (request, response) => {
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).json({ error: "Use POST." });
      return;
    }

    try {
      const prompt = normalizePromptInput(request.body?.prompt);
      const isTv = Boolean(request.body?.isTv);
      const topK = clampInt(request.body?.topK, 1, 20, 12);

      if (prompt.length < 4) {
        response.status(400).json({ error: "Prompt is too short." });
        return;
      }
      if (prompt.length > MAX_PROMPT_CHARS) {
        response.status(400).json({
          error: `Prompt is too long. Keep it under ${MAX_PROMPT_CHARS} characters.`,
        });
        return;
      }
      if (isTv) {
        response.status(400).json({
          error: "Tonight vector recommendations currently support movies only.",
        });
        return;
      }

      const user = await readFirebaseUser(request);
      const appCheck = await readFirebaseAppCheck(request);
      const callerContext = buildCallerContext(request, user, appCheck);
      await enforceRateLimit(callerContext);

      let plan = await planPrompt(prompt);
      const seedEnrichment = await enrichPlanWithSeedMetadata({
        prompt,
        plan,
        timeoutMs: SEED_ENRICHMENT_TIMEOUT_MS,
      });
      plan = seedEnrichment.plan;
      const queryTexts = buildQueryTexts(prompt, plan);
      const candidateLookup = await fetchCandidates(queryTexts, topK, plan);
      const rawResults = candidateLookup.rows;
      const ranking = rerankResults(rawResults, plan, topK);
      const ranked = ranking.results;

      response.status(200).json({
        prompt,
        userId: user?.uid || null,
        interpretedIntent: plan.intent_summary || prompt,
        criteria: {
          language: plan.original_language || null,
          includeGenres: plan.include_genres || [],
          excludeGenres: plan.exclude_genres || [],
          maxRuntimeMinutes: plan.max_runtime || null,
          minRuntimeMinutes: plan.min_runtime || null,
          yearFrom: plan.year_from || null,
          yearTo: plan.year_to || null,
        },
        diagnostics: {
          strategy: "hybrid_vector_rerank_v2",
          queryVariantsUsed: queryTexts.length,
          candidateCount: rawResults.length,
          vectorBackendRequested: requestedVectorBackendLabel(),
          vectorBackendResolved: candidateLookup.backend,
          vectorBackendStats: candidateLookup.stats,
          stage: ranking.stage,
          relaxed: ranking.relaxed,
          seedEnrichment: seedEnrichment.diagnostics,
        },
        results: ranked,
      });
    } catch (error) {
      console.error("recommendTonight failed", error);
      if (error instanceof HttpError) {
        if (error.retryAfterSeconds) {
          response.set("Retry-After", String(error.retryAfterSeconds));
        }
        response.status(error.statusCode).json({ error: error.message });
        return;
      }
      response.status(500).json({
        error:
          error instanceof Error
            ? error.message
            : "Recommendation service failed.",
      });
    }
  }
);

async function readFirebaseUser(request) {
  const authorization = String(request.header("authorization") || "");
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    return null;
  }
  try {
    return await admin.auth().verifyIdToken(match[1]);
  } catch (error) {
    console.warn("Ignoring invalid Firebase auth token", error);
    return null;
  }
}

async function readFirebaseAppCheck(request) {
  const token = String(request.header("x-firebase-appcheck") || "").trim();
  if (!token) {
    return { provided: false, verified: false, appId: null };
  }
  try {
    const decoded = await admin.appCheck().verifyToken(token);
    return {
      provided: true,
      verified: true,
      appId: String(decoded.appId || ""),
    };
  } catch (error) {
    console.warn("Invalid Firebase App Check token", error);
    return { provided: true, verified: false, appId: null };
  }
}

function buildCallerContext(request, user, appCheck) {
  const ip = extractClientIp(request);
  const ua = String(request.header("user-agent") || "").slice(0, 180);
  const source = user?.uid
    ? `uid:${user.uid}`
    : ip
    ? `ip:${ip}`
    : `anon:${ua || "unknown"}`;
  const callerKey = shortHash(source);
  const tier = user?.uid
    ? "user"
    : appCheck?.verified
    ? "appCheckVerified"
    : "anonymous";
  return {
    userId: user?.uid || null,
    appCheckVerified: Boolean(appCheck?.verified),
    appId: appCheck?.appId || null,
    callerKey,
    tier,
  };
}

function extractClientIp(request) {
  const forwarded = String(request.header("x-forwarded-for") || "");
  if (forwarded) {
    const first = forwarded.split(",")[0]?.trim();
    if (first) return first;
  }
  const realIp = String(request.header("x-real-ip") || "").trim();
  if (realIp) return realIp;
  return "";
}

function shortHash(value) {
  return crypto.createHash("sha256").update(String(value)).digest("hex").slice(0, 32);
}

async function enforceRateLimit(caller) {
  const limits = RATE_LIMITS[caller.tier] || RATE_LIMITS.anonymous;
  const ref = db.collection(RATE_LIMIT_COLLECTION).doc(caller.callerKey);
  const nowMs = Date.now();
  const minuteMs = 60 * 1000;
  const dayMs = 24 * 60 * 60 * 1000;
  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = snap.exists ? snap.data() || {} : {};

    const cooldownUntilMs = Number(data.cooldownUntilMs || 0);
    if (cooldownUntilMs > nowMs) {
      const retryAfter = Math.ceil((cooldownUntilMs - nowMs) / 1000);
      return { blocked: true, retryAfter };
    }

    const minuteWindowStartMs = Number(data.minuteWindowStartMs || 0);
    const dayWindowStartMs = Number(data.dayWindowStartMs || 0);
    const minuteCount =
      nowMs - minuteWindowStartMs < minuteMs
        ? Number(data.minuteCount || 0)
        : 0;
    const dayCount =
      nowMs - dayWindowStartMs < dayMs ? Number(data.dayCount || 0) : 0;

    const nextMinuteCount = minuteCount + 1;
    const nextDayCount = dayCount + 1;
    const exceeded =
      nextMinuteCount > limits.perMinute || nextDayCount > limits.perDay;

    const nextMinuteWindowStartMs =
      minuteCount === 0 ? nowMs : minuteWindowStartMs;
    const nextDayWindowStartMs = dayCount === 0 ? nowMs : dayWindowStartMs;
    const nextCooldownMs = exceeded ? nowMs + limits.cooldownSeconds * 1000 : 0;

    tx.set(
      ref,
      {
        minuteWindowStartMs: nextMinuteWindowStartMs,
        dayWindowStartMs: nextDayWindowStartMs,
        minuteCount: nextMinuteCount,
        dayCount: nextDayCount,
        cooldownUntilMs: nextCooldownMs,
        lastSeenMs: nowMs,
        tier: caller.tier,
        userId: caller.userId || null,
        appCheckVerified: caller.appCheckVerified,
        appId: caller.appId || null,
      },
      { merge: true }
    );

    if (!exceeded) {
      return { blocked: false };
    }
    return { blocked: true, retryAfter: limits.cooldownSeconds };
  });

  if (result.blocked) {
    throw new HttpError(
      429,
      "Too many recommendation requests right now. Please wait a bit and try again.",
      { retryAfterSeconds: result.retryAfter || 20 }
    );
  }
}

async function planPrompt(prompt) {
  const dedupe = (values) => {
    const seen = new Set();
    return values.filter((value) => {
      const key = String(value || "").trim();
      if (!key || seen.has(key)) return false;
      seen.add(key);
      return true;
    });
  };
  const geminiModels = dedupe([
    geminiChatModel.value(),
    ...String(geminiChatFallbackModels.value() || "")
      .split(",")
      .map((model) => model.trim())
      .filter(Boolean),
  ]);
  const openRouterModels = dedupe([
    chatModel.value(),
    ...String(chatFallbackModels.value() || "")
      .split(",")
      .map((model) => model.trim())
      .filter(Boolean),
  ]);

  let lastGeminiError = null;
  if (isGeminiConfigured()) {
    for (const model of geminiModels) {
      try {
        const json = await callPlannerModelGemini(model, prompt);
        const content = extractGeminiText(json);
        return augmentPlanWithPromptExclusions(
          normalizePlan(JSON.parse(stripJsonFence(content)), prompt),
          prompt
        );
      } catch (error) {
        lastGeminiError = error;
        console.warn(`Gemini planner model failed: ${model}`, error);
      }
    }
  } else {
    console.warn("GEMINI_API_KEY is not configured; skipping Gemini planner.");
  }

  let lastOpenRouterError = null;
  for (const model of openRouterModels) {
    try {
      const json = await callPlannerModelOpenRouter(model, prompt);
      const content = String(json?.choices?.[0]?.message?.content || "{}").trim();
      return augmentPlanWithPromptExclusions(
        normalizePlan(JSON.parse(stripJsonFence(content)), prompt),
        prompt
      );
    } catch (error) {
      lastOpenRouterError = error;
      console.warn(`OpenRouter planner model failed: ${model}`, error);
    }
  }

  console.warn("All planner providers failed; using fallback", {
    geminiError: lastGeminiError,
    openRouterError: lastOpenRouterError,
  });
  return augmentPlanWithPromptExclusions(normalizePlan({}, prompt), prompt);
}

function plannerSystemInstruction() {
  return (
    "You are a movie recommendation query planner. Output only strict JSON. " +
    "Schema: {\"intent_summary\": string, \"original_language\": string|null, " +
    "\"include_genres\": string[], \"exclude_genres\": string[], " +
    "\"exclude_franchises\": string[], \"exclude_keywords\": string[], " +
    "\"min_runtime\": int|null, \"max_runtime\": int|null, " +
    "\"min_vote_average\": number|null, \"min_vote_count\": int|null, " +
    "\"year_from\": int|null, \"year_to\": int|null, " +
    "\"keywords\": string[], \"similar_titles\": string[], \"avoid_titles\": string[], \"query_variants\": string[]}. " +
    "Respect exclusions and keep values practical for TMDB/Firestore search. " +
    "When the user says 'not/without/avoid', always put those genres/franchises/titles in exclusion fields. " +
    "Use canonical TMDB genre names such as 'Science Fiction' (not 'sci-fi')."
  );
}

async function callPlannerModelGemini(model, prompt) {
  const payload = {
    systemInstruction: {
      role: "system",
      parts: [{ text: plannerSystemInstruction() }],
    },
    contents: [
      {
        role: "user",
        parts: [
          {
            text: `User wants movies. Request: "${prompt}". Return the JSON now.`,
          },
        ],
      },
    ],
    generationConfig: {
      temperature: 0.2,
      maxOutputTokens: 600,
      responseMimeType: "application/json",
    },
  };
  return geminiFetch(model, payload, {
    retries: 3,
    retryBaseDelayMs: 900,
    timeoutMs: 14000,
  });
}

function extractGeminiText(json) {
  const parts = json?.candidates?.[0]?.content?.parts;
  if (!Array.isArray(parts) || parts.length === 0) {
    throw new Error(
      `Gemini response did not include candidates content: ${JSON.stringify(json)}`
    );
  }
  const content = parts
    .map((part) => String(part?.text || "").trim())
    .filter(Boolean)
    .join("\n")
    .trim();
  if (!content) {
    throw new Error(`Gemini response text was empty: ${JSON.stringify(json)}`);
  }
  return content;
}

async function callPlannerModelOpenRouter(model, prompt) {
  const payload = {
    model,
    temperature: 0.2,
    response_format: { type: "json_object" },
    messages: [
      {
        role: "system",
        content: plannerSystemInstruction(),
      },
      {
        role: "user",
        content: `User wants movies. Request: "${prompt}". Return the JSON now.`,
      },
    ],
  };
  return openRouterFetch("/chat/completions", payload, {
    retries: 3,
    retryBaseDelayMs: 900,
    timeoutMs: 14000,
  });
}

async function geminiFetch(model, payload, options = {}) {
  const retries = Number.isFinite(options.retries) ? options.retries : 3;
  const retryBaseDelayMs = Number.isFinite(options.retryBaseDelayMs)
    ? options.retryBaseDelayMs
    : 1000;
  const timeoutMs = Number.isFinite(options.timeoutMs)
    ? options.timeoutMs
    : 18000;
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(
    model
  )}:generateContent`;

  for (let attempt = 1; attempt <= retries; attempt += 1) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const result = await fetch(endpoint, {
        method: "POST",
        headers: {
          "x-goog-api-key": geminiApiKey.value(),
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify(payload),
        signal: controller.signal,
      });

      const json = await result.json().catch(() => ({}));
      if (result.ok) {
        return json;
      }

      const shouldRetry = result.status === 429 || result.status >= 500;
      if (shouldRetry && attempt < retries) {
        const delayMs = retryBaseDelayMs * Math.pow(2, attempt - 1);
        console.warn(
          `Gemini ${model} failed (${result.status}) on attempt ${attempt}/${retries}. Retrying in ${delayMs}ms`,
          json
        );
        await sleep(delayMs);
        continue;
      }

      throw new HttpError(
        result.status,
        `Gemini ${model} failed (${result.status}): ${JSON.stringify(json)}`
      );
    } catch (error) {
      const timeoutOrNetworkError =
        error?.name === "AbortError" || error instanceof TypeError;
      if (timeoutOrNetworkError && attempt < retries) {
        const delayMs = retryBaseDelayMs * Math.pow(2, attempt - 1);
        console.warn(
          `Gemini ${model} network/timeout error on attempt ${attempt}/${retries}. Retrying in ${delayMs}ms`,
          error
        );
        await sleep(delayMs);
        continue;
      }
      throw error;
    } finally {
      clearTimeout(timeoutId);
    }
  }

  throw new Error(`Gemini ${model} exhausted retries.`);
}

function isGeminiConfigured() {
  const key = String(geminiApiKey.value() || "").trim();
  if (!key) return false;
  const normalized = key.toLowerCase();
  return !["__unconfigured__", "unset", "none", "null"].includes(normalized);
}

async function embedText(text) {
  let json;
  try {
    json = await openRouterFetch(
      "/embeddings",
      {
        model: embeddingModel.value(),
        input: text,
      },
      {
        retries: 3,
        retryBaseDelayMs: 800,
        timeoutMs: 12000,
      }
    );
  } catch (error) {
    if (error instanceof HttpError && error.statusCode === 429) {
      throw new HttpError(
        503,
        "OpenRouter is temporarily rate-limited. Please retry in a moment."
      );
    }
    throw error;
  }
  const embedding = json?.data?.[0]?.embedding;
  if (!Array.isArray(embedding) || embedding.length === 0) {
    throw new Error("OpenRouter embedding response did not include a vector.");
  }
  return embedding.map((value) => Number(value));
}

function adjustEmbeddingDimension(vector, targetDim) {
  if (!Array.isArray(vector)) return [];
  if (!Number.isFinite(targetDim) || targetDim <= 0) return vector;
  if (vector.length === targetDim) return vector;
  if (vector.length > targetDim) return vector.slice(0, targetDim);
  return vector.concat(Array(targetDim - vector.length).fill(0));
}

async function openRouterFetch(path, payload, options = {}) {
  const retries = Number.isFinite(options.retries) ? options.retries : 3;
  const retryBaseDelayMs = Number.isFinite(options.retryBaseDelayMs)
    ? options.retryBaseDelayMs
    : 1000;
  const timeoutMs = Number.isFinite(options.timeoutMs)
    ? options.timeoutMs
    : 18000;

  for (let attempt = 1; attempt <= retries; attempt += 1) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const result = await fetch(`https://openrouter.ai/api/v1${path}`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${openRouterApiKey.value()}`,
          "Content-Type": "application/json",
          Accept: "application/json",
          "HTTP-Referer": "https://cineverse.app",
          "X-Title": "CineVerse",
        },
        body: JSON.stringify(payload),
        signal: controller.signal,
      });

      const json = await result.json().catch(() => ({}));
      if (result.ok) {
        return json;
      }

      const shouldRetry = result.status === 429 || result.status >= 500;
      if (shouldRetry && attempt < retries) {
        const delayMs = retryBaseDelayMs * Math.pow(2, attempt - 1);
        console.warn(
          `OpenRouter ${path} failed (${result.status}) on attempt ${attempt}/${retries}. Retrying in ${delayMs}ms`,
          json
        );
        await sleep(delayMs);
        continue;
      }

      throw new HttpError(
        result.status,
        `OpenRouter ${path} failed (${result.status}): ${JSON.stringify(json)}`
      );
    } catch (error) {
      const timeoutOrNetworkError =
        error?.name === "AbortError" || error instanceof TypeError;
      if (timeoutOrNetworkError && attempt < retries) {
        const delayMs = retryBaseDelayMs * Math.pow(2, attempt - 1);
        console.warn(
          `OpenRouter ${path} network/timeout error on attempt ${attempt}/${retries}. Retrying in ${delayMs}ms`,
          error
        );
        await sleep(delayMs);
        continue;
      }
      throw error;
    } finally {
      clearTimeout(timeoutId);
    }
  }
}

async function findNearestMoviesFirestore(queryEmbedding, limit) {
  const collection = db.collection(indexCollection.value());
  const vectorQuery = collection
    .select(
      "id",
      "title",
      "originalTitle",
      "genres",
      "originalLanguage",
      "runtimeMinutes",
      "releaseYear",
      "voteAverage",
      "voteCount",
      "popularity",
      "posterPath",
      "tagline",
      "overview",
      "keywords",
      "vectorDistance"
    )
    .findNearest({
      vectorField: "embedding",
      queryVector: queryEmbedding,
      limit,
      distanceMeasure: "COSINE",
      distanceResultField: "vectorDistance",
    });

  const snapshot = await vectorQuery.get();
  return snapshot.docs.map((doc) => ({ docId: doc.id, ...doc.data() }));
}

async function findNearestMoviesQdrant(queryEmbedding, limit, options = {}) {
  const baseUrl = String(qdrantUrl.value() || "").trim().replace(/\/+$/, "");
  const collectionName = String(
    options.collectionName || qdrantCollection.value() || ""
  ).trim();
  if (!baseUrl) {
    throw new Error("QDRANT_URL is empty.");
  }
  if (!collectionName) {
    throw new Error("QDRANT_COLLECTION is empty.");
  }

  const queryEndpoint = `${baseUrl}/collections/${encodeURIComponent(
    collectionName
  )}/points/query`;
  const searchEndpoint = `${baseUrl}/collections/${encodeURIComponent(
    collectionName
  )}/points/search`;
  const timeout = parsePositiveInt(qdrantTimeoutMs.value(), 12000);
  const apiKey = String(qdrantApiKey.value() || "").trim();
  const headers = {
    "Content-Type": "application/json",
    Accept: "application/json",
    ...(apiKey ? { "api-key": apiKey } : {}),
  };

  const queryBody = {
    query: queryEmbedding,
    limit,
    with_payload: true,
    with_vector: false,
  };
  const searchBody = {
    vector: queryEmbedding,
    limit,
    with_payload: true,
    with_vector: false,
  };
  if (options.filter && typeof options.filter === "object") {
    queryBody.filter = options.filter;
    searchBody.filter = options.filter;
  }

  const runRequest = async (url, body) => {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeout);
    try {
      const result = await fetch(url, {
        method: "POST",
        headers,
        body: JSON.stringify(body),
        signal: controller.signal,
      });
      const json = await result.json().catch(() => ({}));
      return { result, json };
    } finally {
      clearTimeout(timer);
    }
  };

  let response = await runRequest(queryEndpoint, queryBody);
  if (
    !response.result.ok &&
    (response.result.status === 404 ||
      response.result.status === 400 ||
      response.result.status === 405)
  ) {
    response = await runRequest(searchEndpoint, searchBody);
  }

  if (!response.result.ok) {
    throw new Error(
      `Qdrant query failed (${response.result.status}): ${JSON.stringify(
        response.json
      )}`
    );
  }

  const rawPoints = Array.isArray(response.json?.result?.points)
    ? response.json.result.points
    : Array.isArray(response.json?.result)
    ? response.json.result
    : [];

  return rawPoints.map((point) => {
    const payload = point?.payload || {};
    const scoreRaw = Number(point?.score || 0);
    const score = Number.isFinite(scoreRaw) ? scoreRaw : 0;
    return {
      docId: String(point?.id ?? payload.id ?? ""),
      ...payload,
      vectorSimilarity: score,
      vectorDistance: Number((1 - score).toFixed(6)),
    };
  });
}

function buildQdrantFilter(plan) {
  const must = [{ key: "mediaType", match: { value: "movie" } }];
  const mustNot = [];

  const includeGenres = (plan.include_genres || [])
    .map(canonicalizeGenre)
    .filter(Boolean);
  if (includeGenres.length) {
    must.push({ key: "genres", match: { any: includeGenres } });
  }

  const excludeGenres = (plan.exclude_genres || [])
    .map(canonicalizeGenre)
    .filter(Boolean);
  if (excludeGenres.length) {
    mustNot.push({ key: "genres", match: { any: excludeGenres } });
  }

  const excludeFranchises = (plan.exclude_franchises || [])
    .map(normalizeText)
    .filter(Boolean);
  if (excludeFranchises.length) {
    mustNot.push({ key: "franchiseHints", match: { any: excludeFranchises } });
  }

  const minVoteCount = Number(plan.min_vote_count || 0);
  if (Number.isFinite(minVoteCount) && minVoteCount > 0) {
    must.push({ key: "voteCount", range: { gte: minVoteCount } });
  }

  const minVoteAverage = Number(plan.min_vote_average || 0);
  if (Number.isFinite(minVoteAverage) && minVoteAverage > 0) {
    must.push({ key: "voteAverage", range: { gte: minVoteAverage } });
  }

  const runtimeMin = Number(plan.min_runtime || 0);
  if (Number.isFinite(runtimeMin) && runtimeMin > 0) {
    must.push({ key: "runtimeMinutes", range: { gte: runtimeMin } });
  }
  const runtimeMax = Number(plan.max_runtime || 0);
  if (Number.isFinite(runtimeMax) && runtimeMax > 0) {
    must.push({ key: "runtimeMinutes", range: { lte: runtimeMax } });
  }

  const yearFrom = Number(plan.year_from || 0);
  if (Number.isFinite(yearFrom) && yearFrom > 0) {
    must.push({ key: "releaseYear", range: { gte: yearFrom } });
  }
  const yearTo = Number(plan.year_to || 0);
  if (Number.isFinite(yearTo) && yearTo > 0) {
    must.push({ key: "releaseYear", range: { lte: yearTo } });
  }

  return {
    ...(must.length ? { must } : {}),
    ...(mustNot.length ? { must_not: mustNot } : {}),
  };
}

function buildZillizFilterExpression(plan) {
  const filters = ['mediaType == "movie"'];
  const includeGenres = (plan.include_genres || [])
    .map(canonicalizeGenre)
    .filter(Boolean);
  if (includeGenres.length) {
    filters.push(
      `ARRAY_CONTAINS_ANY(genres, [${includeGenres
        .map((value) => `"${escapeMilvusString(value)}"`)
        .join(", ")}])`
    );
  }

  const excludeGenres = (plan.exclude_genres || [])
    .map(canonicalizeGenre)
    .filter(Boolean);
  if (excludeGenres.length) {
    filters.push(
      `NOT ARRAY_CONTAINS_ANY(genres, [${excludeGenres
        .map((value) => `"${escapeMilvusString(value)}"`)
        .join(", ")}])`
    );
  }

  const excludeFranchises = (plan.exclude_franchises || [])
    .map(normalizeText)
    .filter(Boolean);
  if (excludeFranchises.length) {
    filters.push(
      `NOT ARRAY_CONTAINS_ANY(franchiseHints, [${excludeFranchises
        .map((value) => `"${escapeMilvusString(value)}"`)
        .join(", ")}])`
    );
  }

  const minVoteCount = Number(plan.min_vote_count || 0);
  if (Number.isFinite(minVoteCount) && minVoteCount > 0) {
    filters.push(`voteCount >= ${Math.floor(minVoteCount)}`);
  }

  const minVoteAverage = Number(plan.min_vote_average || 0);
  if (Number.isFinite(minVoteAverage) && minVoteAverage > 0) {
    filters.push(`voteAverage >= ${Number(minVoteAverage)}`);
  }

  const runtimeMin = Number(plan.min_runtime || 0);
  if (Number.isFinite(runtimeMin) && runtimeMin > 0) {
    filters.push(`runtimeMinutes >= ${Math.floor(runtimeMin)}`);
  }

  const runtimeMax = Number(plan.max_runtime || 0);
  if (Number.isFinite(runtimeMax) && runtimeMax > 0) {
    filters.push(`runtimeMinutes <= ${Math.floor(runtimeMax)}`);
  }

  const yearFrom = Number(plan.year_from || 0);
  if (Number.isFinite(yearFrom) && yearFrom > 0) {
    filters.push(`releaseYear >= ${Math.floor(yearFrom)}`);
  }

  const yearTo = Number(plan.year_to || 0);
  if (Number.isFinite(yearTo) && yearTo > 0) {
    filters.push(`releaseYear <= ${Math.floor(yearTo)}`);
  }
  return filters.join(" && ");
}

async function findNearestMoviesZilliz(queryEmbedding, limit, options = {}) {
  const baseUrl = String(zillizEndpoint.value() || "")
    .trim()
    .replace(/\/+$/, "");
  const collectionName = String(
    options.collectionName || zillizCollection.value() || ""
  ).trim();
  const dbName = String(zillizDbName.value() || "default").trim() || "default";
  const vectorFieldName = String(
    options.vectorFieldName || zillizVectorField.value() || "vector"
  ).trim();
  const timeout = parsePositiveInt(zillizTimeoutMs.value(), 12000);
  const apiKey = String(zillizApiKey.value() || "").trim();

  if (!baseUrl) {
    throw new Error("ZILLIZ_ENDPOINT is empty.");
  }
  if (!collectionName) {
    throw new Error("ZILLIZ_COLLECTION is empty.");
  }
  if (!apiKey) {
    throw new Error("ZILLIZ_API_KEY is empty.");
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeout);
  try {
    const response = await fetch(`${baseUrl}/v2/vectordb/entities/search`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        dbName,
        collectionName,
        data: [queryEmbedding],
        annsField: vectorFieldName,
        limit,
        ...(options.filterExpression
          ? { filter: options.filterExpression }
          : {}),
        outputFields: [
          "id",
          "title",
          "originalTitle",
          "genres",
          "originalLanguage",
          "runtimeMinutes",
          "releaseYear",
          "voteAverage",
          "voteCount",
          "popularity",
          "posterPath",
          "tagline",
          "overview",
          "keywords",
          "franchiseHints",
        ],
      }),
      signal: controller.signal,
    });
    const json = await response.json().catch(() => ({}));
    if (!response.ok) {
      throw new Error(
        `Zilliz search failed (${response.status}): ${JSON.stringify(json)}`
      );
    }
    if (json && Number(json.code || 0) !== 0) {
      throw new Error(`Zilliz search returned error: ${JSON.stringify(json)}`);
    }
    const raw = Array.isArray(json?.data) ? json.data : [];
    const hits =
      raw.length > 0 && Array.isArray(raw[0])
        ? raw[0]
        : Array.isArray(raw)
        ? raw
        : [];
    return hits.map((hit) => {
      const entityRaw =
        hit?.entity && typeof hit.entity === "object" ? hit.entity : null;
      const entity =
        entityRaw && Object.keys(entityRaw).length > 0
          ? entityRaw
          : hit && typeof hit === "object"
          ? hit
          : {};
      const scoreRaw = Number(hit?.score ?? hit?.distance ?? 0);
      const score = Number.isFinite(scoreRaw) ? scoreRaw : 0;
      const normalizedScore = Math.max(-1, Math.min(1, score));
      return {
        docId: String(entity.id ?? hit?.id ?? ""),
        ...entity,
        id: Number(entity.id ?? hit?.id ?? 0),
        vectorSimilarity: normalizedScore,
        vectorDistance: Number((1 - normalizedScore).toFixed(6)),
      };
    });
  } finally {
    clearTimeout(timer);
  }
}

async function fetchCandidatesFromZilliz(queryTexts, topK, plan, options = {}) {
  const limitPerVariant = Math.max(30, Math.min(100, topK * 8));
  const startedAt = Date.now();
  const filterExpression = buildZillizFilterExpression(plan || {});
  const collectionName = String(options.collectionName || "").trim();
  const targetDim = parsePositiveInt(zillizVectorDim.value(), 1024);
  const queryWithFilter = async (filterValue) =>
    Promise.allSettled(
      queryTexts.map(async (queryText) => {
        const queryEmbeddingRaw = await embedText(queryText);
        const queryEmbedding = adjustEmbeddingDimension(
          queryEmbeddingRaw,
          targetDim
        );
        return findNearestMoviesZilliz(queryEmbedding, limitPerVariant, {
          filterExpression: filterValue,
          collectionName,
        });
      })
    );

  let settled = await queryWithFilter(filterExpression);
  let rows;
  let usedFilterFallback = false;
  try {
    rows = mergeCandidateRowsFromVariants(settled);
  } catch (error) {
    settled = await queryWithFilter("");
    rows = mergeCandidateRowsFromVariants(settled);
    usedFilterFallback = true;
  }

  return {
    rows,
    elapsedMs: Date.now() - startedAt,
    collection: collectionName || zillizCollection.value(),
    usedFilterFallback,
  };
}

async function fetchCandidatesFromFirestore(queryTexts, topK) {
  const limitPerVariant = Math.max(30, Math.min(100, topK * 8));
  const settled = await Promise.allSettled(
    queryTexts.map(async (queryText) => {
      const queryEmbedding = await embedText(queryText);
      return findNearestMoviesFirestore(queryEmbedding, limitPerVariant);
    })
  );
  return mergeCandidateRowsFromVariants(settled);
}

async function fetchCandidatesFromQdrant(queryTexts, topK, plan, options = {}) {
  const limitPerVariant = Math.max(30, Math.min(100, topK * 8));
  const startedAt = Date.now();
  const qdrantFilter = buildQdrantFilter(plan || {});
  const collectionName = String(options.collectionName || "").trim();
  const queryWithFilter = async (filterValue) =>
    Promise.allSettled(
      queryTexts.map(async (queryText) => {
        const queryEmbedding = await embedText(queryText);
        return findNearestMoviesQdrant(queryEmbedding, limitPerVariant, {
          filter: filterValue,
          collectionName,
        });
      })
    );

  let settled = await queryWithFilter(qdrantFilter);
  let rows;
  let usedFilterFallback = false;
  try {
    rows = mergeCandidateRowsFromVariants(settled);
  } catch (error) {
    if (qdrantFilter) {
      console.warn(
        "Qdrant filtered query produced no candidates; retrying without filter",
        error
      );
      settled = await queryWithFilter(null);
      rows = mergeCandidateRowsFromVariants(settled);
      usedFilterFallback = true;
    } else {
      throw error;
    }
  }

  return {
    rows,
    elapsedMs: Date.now() - startedAt,
    collection: collectionName || String(qdrantCollection.value() || "").trim(),
    usedFilterFallback,
  };
}

function mergeCandidateRowsFromVariants(settledResults) {
  const allRows = [];
  for (const result of settledResults) {
    if (result.status === "fulfilled") {
      allRows.push(...result.value);
    } else {
      console.warn("Variant lookup failed", result.reason);
    }
  }
  if (allRows.length === 0) {
    throw new Error("All vector variant lookups failed.");
  }

  const byId = new Map();
  for (const row of allRows) {
    const id = Number(row.id || 0);
    if (!id) continue;
    const vectorSimilarity = Number.isFinite(row.vectorSimilarity)
      ? Number(row.vectorSimilarity)
      : 1 - Number(row.vectorDistance || 1);
    const existing = byId.get(id);
    if (!existing || vectorSimilarity > existing.vectorSimilarity) {
      byId.set(id, { ...row, vectorSimilarity });
    }
  }

  return [...byId.values()];
}

async function fetchCandidates(queryTexts, topK, plan) {
  const backendPreference = resolveVectorBackendPreference();
  if (backendPreference === "firestore") {
    return {
      rows: await fetchCandidatesFromFirestore(queryTexts, topK),
      backend: "firestore",
      stats: {
        firestore: "ok",
        qdrant: "skipped",
        zilliz: "skipped",
      },
    };
  }

  if (backendPreference === "zilliz") {
    const zillizConfigured = isZillizConfigured();
    const qdrantConfigured = isQdrantConfigured();
    const firestoreFailoverEnabled = parseBooleanString(
      zillizFailoverToFirestore.value(),
      true
    );
    if (!zillizConfigured) {
      if (qdrantConfigured) {
        try {
          const qdrantResult = await fetchCandidatesFromQdrant(
            queryTexts,
            topK,
            plan
          );
          return {
            rows: qdrantResult.rows,
            backend: "zilliz_unconfigured_qdrant_failover",
            stats: {
              firestore: "skipped",
              qdrant: `ok:${qdrantResult.rows.length}`,
              zilliz: "unconfigured_failover",
              qdrantMs: qdrantResult.elapsedMs,
              qdrantCollection: qdrantResult.collection,
              qdrantFilterFallback: Boolean(qdrantResult.usedFilterFallback),
            },
          };
        } catch (qdrantError) {
          if (!firestoreFailoverEnabled) {
            throw qdrantError;
          }
          console.warn(
            "Zilliz unconfigured and Qdrant failed; falling back to Firestore",
            qdrantError
          );
          return {
            rows: await fetchCandidatesFromFirestore(queryTexts, topK),
            backend: "zilliz_unconfigured_qdrant_with_firestore_failover",
            stats: {
              firestore: "ok",
              qdrant: "failed_failover",
              zilliz: "unconfigured_failover",
            },
          };
        }
      }
      if (!firestoreFailoverEnabled) {
        throw new Error(
          "Zilliz is not configured (ZILLIZ_ENDPOINT/API_KEY missing) and Qdrant is unavailable."
        );
      }
      return {
        rows: await fetchCandidatesFromFirestore(queryTexts, topK),
        backend: "zilliz_unconfigured_firestore_failover",
        stats: {
          firestore: "ok",
          qdrant: "skipped",
          zilliz: "unconfigured_failover",
        },
      };
    }
    try {
      const primary = await fetchCandidatesFromZilliz(queryTexts, topK, plan);
      return {
        rows: primary.rows,
        backend: "zilliz",
        stats: {
          firestore: "skipped",
          qdrant: "skipped",
          zilliz: `ok:${primary.rows.length}`,
          zillizMs: primary.elapsedMs,
          zillizCollection: primary.collection,
          zillizFilterFallback: Boolean(primary.usedFilterFallback),
        },
      };
    } catch (error) {
      if (qdrantConfigured) {
        try {
          const qdrantResult = await fetchCandidatesFromQdrant(
            queryTexts,
            topK,
            plan
          );
          return {
            rows: qdrantResult.rows,
            backend: "zilliz_with_qdrant_failover",
            stats: {
              firestore: "skipped",
              qdrant: `ok:${qdrantResult.rows.length}`,
              zilliz: "failed_failover",
              qdrantMs: qdrantResult.elapsedMs,
              qdrantCollection: qdrantResult.collection,
              qdrantFilterFallback: Boolean(qdrantResult.usedFilterFallback),
            },
          };
        } catch (qdrantError) {
          if (!firestoreFailoverEnabled) {
            throw qdrantError;
          }
          console.warn(
            "Zilliz failed and Qdrant failed; falling back to Firestore",
            { zillizError: error, qdrantError }
          );
          return {
            rows: await fetchCandidatesFromFirestore(queryTexts, topK),
            backend: "zilliz_with_qdrant_with_firestore_failover",
            stats: {
              firestore: "ok",
              qdrant: "failed_failover",
              zilliz: "failed_failover",
            },
          };
        }
      }
      if (!firestoreFailoverEnabled) {
        throw error;
      }
      console.warn("Zilliz failed; falling back to Firestore", error);
      return {
        rows: await fetchCandidatesFromFirestore(queryTexts, topK),
        backend: "zilliz_with_firestore_failover",
        stats: {
          firestore: "ok",
          qdrant: "skipped",
          zilliz: "failed_failover",
        },
      };
    }
  }

  const qdrantConfigured = isQdrantConfigured();
  const zillizConfigured = isZillizConfigured();
  const firestoreFailoverEnabled = parseBooleanString(
    qdrantFailoverToFirestore.value(),
    true
  );

  if (!qdrantConfigured) {
    if (zillizConfigured) {
      try {
        const zillizResult = await fetchCandidatesFromZilliz(queryTexts, topK, plan);
        return {
          rows: zillizResult.rows,
          backend: "qdrant_unconfigured_zilliz_failover",
          stats: {
            firestore: "skipped",
            qdrant: "unconfigured_failover",
            zilliz: `ok:${zillizResult.rows.length}`,
            zillizMs: zillizResult.elapsedMs,
            zillizCollection: zillizResult.collection,
            zillizFilterFallback: Boolean(zillizResult.usedFilterFallback),
          },
        };
      } catch (zillizError) {
        if (!firestoreFailoverEnabled) {
          throw zillizError;
        }
        console.warn(
          "Qdrant unconfigured and Zilliz failed; falling back to Firestore",
          zillizError
        );
        return {
          rows: await fetchCandidatesFromFirestore(queryTexts, topK),
          backend: "qdrant_unconfigured_zilliz_with_firestore_failover",
          stats: {
            firestore: "ok",
            qdrant: "unconfigured_failover",
            zilliz: "failed_failover",
          },
        };
      }
    }

    if (!firestoreFailoverEnabled) {
      throw new Error(
        "Qdrant is not configured (QDRANT_URL missing) and Zilliz is unavailable."
      );
    }
    return {
      rows: await fetchCandidatesFromFirestore(queryTexts, topK),
      backend: "qdrant_unconfigured_firestore_failover",
      stats: {
        firestore: "ok",
        qdrant: "unconfigured_failover",
        zilliz: "unconfigured_failover",
      },
    };
  }

  try {
    const primary = await fetchCandidatesFromQdrant(queryTexts, topK, plan);
    return {
      rows: primary.rows,
      backend: "qdrant",
      stats: {
        firestore: "skipped",
        qdrant: `ok:${primary.rows.length}`,
        zilliz: "skipped",
        qdrantMs: primary.elapsedMs,
        qdrantCollection: primary.collection,
        qdrantFilterFallback: Boolean(primary.usedFilterFallback),
      },
    };
  } catch (qdrantError) {
    if (zillizConfigured) {
      try {
        const zillizResult = await fetchCandidatesFromZilliz(queryTexts, topK, plan);
        return {
          rows: zillizResult.rows,
          backend: "qdrant_with_zilliz_failover",
          stats: {
            firestore: "skipped",
            qdrant: "failed_failover",
            zilliz: `ok:${zillizResult.rows.length}`,
            zillizMs: zillizResult.elapsedMs,
            zillizCollection: zillizResult.collection,
            zillizFilterFallback: Boolean(zillizResult.usedFilterFallback),
          },
        };
      } catch (zillizError) {
        if (!firestoreFailoverEnabled) {
          throw zillizError;
        }
        console.warn(
          "Qdrant failed and Zilliz failed; falling back to Firestore",
          { qdrantError, zillizError }
        );
        return {
          rows: await fetchCandidatesFromFirestore(queryTexts, topK),
          backend: "qdrant_with_zilliz_with_firestore_failover",
          stats: {
            firestore: "ok",
            qdrant: "failed_failover",
            zilliz: "failed_failover",
          },
        };
      }
    }

    if (!firestoreFailoverEnabled) {
      throw qdrantError;
    }
    console.warn("Qdrant failed; falling back to Firestore", qdrantError);
    return {
      rows: await fetchCandidatesFromFirestore(queryTexts, topK),
      backend: "qdrant_with_firestore_failover",
      stats: {
        firestore: "ok",
        qdrant: "failed_failover",
        zilliz: "unconfigured_failover",
      },
    };
  }
}

function rerankResults(rows, plan, topK) {
  const excluded = new Set((plan.exclude_genres || []).map(canonicalizeGenre).filter(Boolean));
  const exclusionTokens = buildExclusionTokenSet(plan);
  const excludedSeedTitles = new Set(
    (plan.similar_titles || []).map(normalizeText).filter(Boolean)
  );
  const included = new Set((plan.include_genres || []).map(canonicalizeGenre).filter(Boolean));
  const language = plan.original_language || null;
  const keywords = new Set((plan.keywords || []).map(normalizeText));
  const minVoteAverage = Number(plan.min_vote_average || 0);
  const minVoteCount = Number(plan.min_vote_count || 0);
  const baseMinRuntime = Number(plan.min_runtime || 0);
  const baseMaxRuntime = Number(plan.max_runtime || 0);
  const baseYearFrom = Number(plan.year_from || 0);
  const baseYearTo = Number(plan.year_to || 0);

  const stages = [
    {
      name: "strict",
      languagePolicy: "strict",
      minRuntime: baseMinRuntime || null,
      maxRuntime: baseMaxRuntime || null,
      yearFrom: baseYearFrom || null,
      yearTo: baseYearTo || null,
      voteAverage: minVoteAverage || null,
      voteCount: minVoteCount || null,
    },
    {
      name: "language_relaxed",
      languagePolicy: "preferred",
      minRuntime: baseMinRuntime ? Math.max(40, baseMinRuntime - 20) : null,
      maxRuntime: baseMaxRuntime ? baseMaxRuntime + 20 : null,
      yearFrom: baseYearFrom ? baseYearFrom - 3 : null,
      yearTo: baseYearTo ? baseYearTo + 3 : null,
      voteAverage: minVoteAverage ? Math.max(0, minVoteAverage - 0.4) : null,
      voteCount: minVoteCount ? Math.floor(minVoteCount * 0.6) : null,
    },
    {
      name: "broad",
      languagePolicy: "off",
      minRuntime: null,
      maxRuntime: null,
      yearFrom: null,
      yearTo: null,
      voteAverage: minVoteAverage ? Math.max(0, minVoteAverage - 0.8) : null,
      voteCount: minVoteCount ? Math.floor(minVoteCount * 0.3) : null,
    },
  ];

  for (let i = 0; i < stages.length; i += 1) {
    const stage = stages[i];
    const ranked = rows
      .filter((row) => {
        const rowGenres = canonicalGenreSet(row.genres || []);
        if ([...excluded].some((genre) => rowGenres.has(genre))) return false;
        if (candidateMatchesExcludedSeedTitle(row, excludedSeedTitles)) return false;
        if (candidateViolatesExclusions(row, exclusionTokens)) return false;
        if (
          stage.languagePolicy === "strict" &&
          language &&
          row.originalLanguage !== language
        ) {
          return false;
        }
        if (stage.maxRuntime && row.runtimeMinutes > stage.maxRuntime) return false;
        if (stage.minRuntime && row.runtimeMinutes < stage.minRuntime) return false;
        if (stage.yearFrom && row.releaseYear < stage.yearFrom) return false;
        if (stage.yearTo && row.releaseYear > stage.yearTo) return false;
        if (stage.voteAverage && Number(row.voteAverage || 0) < stage.voteAverage) {
          return false;
        }
        if (stage.voteCount && Number(row.voteCount || 0) < stage.voteCount) {
          return false;
        }
        return true;
      })
      .map((row) => scoreRow(row, { included, keywords, language, stage }))
      .sort((a, b) => b.score - a.score);

    if (ranked.length >= Math.min(6, topK)) {
      return {
        results: ranked.slice(0, topK),
        stage: stage.name,
        relaxed: i > 0,
      };
    }
  }

  return {
    results: [],
    stage: "none",
    relaxed: false,
  };
}

function scoreRow(row, context) {
  const { included, keywords, language, stage } = context;
  const rowGenres = canonicalGenreSet(row.genres || []);
  const rowKeywords = new Set((row.keywords || []).map(normalizeText));
  const genreHits = [...included].filter((genre) => rowGenres.has(genre));
  const keywordHits = [...keywords].filter((kw) => rowKeywords.has(kw));
  const vectorSimilarity = Number.isFinite(row.vectorSimilarity)
    ? row.vectorSimilarity
    : 1 - Number(row.vectorDistance || 1);
  const quality = qualityScore(row);
  const genreScore =
    included.size > 0 ? genreHits.length / Math.max(1, included.size) : 0;
  const keywordScore =
    keywords.size > 0 ? keywordHits.length / Math.max(1, keywords.size) : 0;
  const languageScore =
    language && row.originalLanguage === language
      ? 1
      : stage.languagePolicy === "off"
      ? 0.45
      : 0;
  const score =
    vectorSimilarity * 0.58 +
    quality * 0.2 +
    genreScore * 0.12 +
    keywordScore * 0.06 +
    languageScore * 0.04;

  return {
    id: Number(row.id),
    title: row.title || "",
    releaseYear: row.releaseYear || null,
    originalLanguage: row.originalLanguage || null,
    runtimeMinutes: row.runtimeMinutes || null,
    genres: row.genres || [],
    voteAverage: row.voteAverage || null,
    voteCount: row.voteCount || 0,
    popularity: row.popularity || 0,
    posterPath: row.posterPath || null,
    score: Number(score.toFixed(5)),
    distance: Number(Number(row.vectorDistance || 0).toFixed(5)),
    reason: buildReason(row, genreHits, keywordHits, language, stage.name),
  };
}

function buildQueryTexts(prompt, plan) {
  const variants = new Set();
  const exclusionText = [
    ...(plan.exclude_franchises || []),
    ...(plan.exclude_keywords || []),
    ...(plan.avoid_titles || []),
  ].filter(Boolean);
  const base = [];
  base.push(prompt);
  if (plan.intent_summary) base.push(plan.intent_summary);
  if (plan.include_genres?.length) base.push(`Genres: ${plan.include_genres.join(", ")}`);
  if (plan.keywords?.length) base.push(`Keywords: ${plan.keywords.join(", ")}`);
  if (exclusionText.length) base.push(`Strictly exclude: ${exclusionText.join(", ")}`);
  if (plan.similar_titles?.length) base.push(`Similar to: ${plan.similar_titles.join(", ")}`);
  variants.add(base.join("\n"));

  for (const variant of plan.query_variants || []) {
    const text = String(variant || "").trim();
    if (!text) continue;
    variants.add(text);
    if (plan.similar_titles?.length) {
      variants.add(`${text}\nSimilar to: ${plan.similar_titles.join(", ")}`);
    }
  }

  for (const title of plan.similar_titles || []) {
    variants.add(`Movies similar to ${title}. ${prompt}`);
    if (variants.size >= 4) {
      break;
    }
  }

  return [...variants].slice(0, 4);
}

function normalizePlan(raw, fallbackPrompt) {
  const excludeFranchises = stringList(raw.exclude_franchises).map(normalizeText);
  const excludeKeywords = stringList(raw.exclude_keywords).map(normalizeText);
  const avoidTitles = stringList(raw.avoid_titles);
  return {
    intent_summary: stringValue(raw.intent_summary) || fallbackPrompt,
    original_language: languageCode(stringValue(raw.original_language)),
    include_genres: canonicalGenreList(raw.include_genres),
    exclude_genres: canonicalGenreList(raw.exclude_genres),
    exclude_franchises: excludeFranchises,
    exclude_keywords: excludeKeywords,
    min_runtime: intValue(raw.min_runtime),
    max_runtime: intValue(raw.max_runtime),
    min_vote_average: numberValue(raw.min_vote_average),
    min_vote_count: intValue(raw.min_vote_count),
    year_from: intValue(raw.year_from),
    year_to: intValue(raw.year_to),
    keywords: stringList(raw.keywords),
    similar_titles: stringList(raw.similar_titles),
    avoid_titles: avoidTitles,
    query_variants: stringList(raw.query_variants),
  };
}

async function enrichPlanWithSeedMetadata({ prompt, plan, timeoutMs }) {
  const seedTitles = extractSeedTitlesForEnrichment(prompt, plan).slice(0, 2);
  if (!seedTitles.length) {
    return {
      plan,
      diagnostics: {
        attempted: false,
        reason: "no_seed_titles",
      },
    };
  }

  if (!isTmdbLookupConfigured()) {
    return {
      plan,
      diagnostics: {
        attempted: false,
        reason: "tmdb_lookup_not_configured",
      },
    };
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const collectedGenres = new Set();
    const collectedKeywords = new Map();
    let resolvedSeedCount = 0;

    for (const seedTitle of seedTitles) {
      const metadata = await fetchTmdbSeedMetadata(seedTitle, {
        signal: controller.signal,
      });
      if (!metadata) {
        continue;
      }
      resolvedSeedCount += 1;
      for (const genre of metadata.genres) {
        const canonical = canonicalizeGenre(genre);
        if (canonical) {
          collectedGenres.add(canonical);
        }
      }
      for (const keyword of metadata.keywords) {
        const normalized = normalizeText(keyword);
        if (!normalized) continue;
        if (!collectedKeywords.has(normalized)) {
          collectedKeywords.set(normalized, keyword);
        }
      }
    }

    if (resolvedSeedCount === 0) {
      return {
        plan,
        diagnostics: {
          attempted: true,
          applied: false,
          timedOut: false,
          seedCount: seedTitles.length,
          resolvedSeedCount: 0,
        },
      };
    }

    const excludeGenres = new Set(
      (plan.exclude_genres || []).map(canonicalizeGenre).filter(Boolean)
    );
    const includeGenres = new Set(
      (plan.include_genres || []).map(canonicalizeGenre).filter(Boolean)
    );
    for (const genre of collectedGenres) {
      if (!excludeGenres.has(genre)) {
        includeGenres.add(genre);
      }
    }

    const excludeKeywords = new Set(
      (plan.exclude_keywords || []).map(normalizeText).filter(Boolean)
    );
    const mergedKeywords = new Map();
    for (const value of plan.keywords || []) {
      const normalized = normalizeText(value);
      if (!normalized || excludeKeywords.has(normalized)) continue;
      mergedKeywords.set(normalized, value);
    }
    for (const [normalized, rawValue] of collectedKeywords.entries()) {
      if (!excludeKeywords.has(normalized) && !mergedKeywords.has(normalized)) {
        mergedKeywords.set(normalized, rawValue);
      }
    }

    const enrichedPlan = {
      ...plan,
      include_genres: [...includeGenres],
      keywords: [...mergedKeywords.values()],
    };

    return {
      plan: enrichedPlan,
      diagnostics: {
        attempted: true,
        applied: true,
        timedOut: false,
        seedCount: seedTitles.length,
        resolvedSeedCount,
        addedGenres: Math.max(
          0,
          includeGenres.size - new Set(plan.include_genres || []).size
        ),
        addedKeywords: Math.max(
          0,
          mergedKeywords.size - new Set(plan.keywords || []).size
        ),
      },
    };
  } catch (error) {
    const timedOut = error?.name === "AbortError";
    console.warn("Seed-title enrichment skipped", {
      timedOut,
      error: error instanceof Error ? error.message : String(error),
    });
    return {
      plan,
      diagnostics: {
        attempted: true,
        applied: false,
        timedOut,
        seedCount: seedTitles.length,
      },
    };
  } finally {
    clearTimeout(timer);
  }
}

function extractSeedTitlesForEnrichment(prompt, plan) {
  const fromPlan = stringList(plan?.similar_titles);
  if (fromPlan.length) {
    return [...new Set(fromPlan)];
  }
  const inferred = [];
  const rawPrompt = String(prompt || "");
  const likeMatch = rawPrompt.match(
    /\b(?:like|similar to)\s+([^,.;!?]+?)(?:\b(?:but|without|not|except|excluding)\b|$)/i
  );
  if (likeMatch?.[1]) {
    const seed = likeMatch[1].trim().replace(/^["'“”]|["'“”]$/g, "");
    if (seed) inferred.push(seed);
  }
  return [...new Set(inferred)];
}

function isTmdbLookupConfigured() {
  const proxy = String(movieProxyBaseUrl.value() || "").trim().toLowerCase();
  if (proxy && !["__unset__", "unset", "none", "null"].includes(proxy)) {
    return true;
  }
  const key = String(tmdbApiKey.value() || "").trim().toLowerCase();
  return Boolean(key);
}

async function fetchTmdbSeedMetadata(seedTitle, { signal }) {
  const search = await tmdbLookup("/search/movie", {
    query: seedTitle,
    include_adult: "false",
    language: "en-US",
    page: "1",
  }, signal);

  const results = Array.isArray(search?.results) ? search.results : [];
  if (!results.length) {
    return null;
  }

  const normalizedSeed = normalizeText(seedTitle);
  let best = results[0];
  for (const item of results) {
    const title = normalizeText(item?.title || "");
    const originalTitle = normalizeText(item?.original_title || "");
    if (title && title === normalizedSeed) {
      best = item;
      break;
    }
    if (originalTitle && originalTitle === normalizedSeed) {
      best = item;
      break;
    }
  }

  const movieId = Number(best?.id || 0);
  if (!movieId) {
    return null;
  }

  const details = await tmdbLookup(
    `/movie/${movieId}`,
    { language: "en-US", append_to_response: "keywords" },
    signal
  );
  const genres = Array.isArray(details?.genres)
    ? details.genres
        .map((item) => String(item?.name || "").trim())
        .filter(Boolean)
    : [];
  const keywordItems = Array.isArray(details?.keywords?.keywords)
    ? details.keywords.keywords
    : Array.isArray(details?.keywords?.results)
    ? details.keywords.results
    : [];
  const keywords = keywordItems
    .map((item) => String(item?.name || "").trim())
    .filter(Boolean);

  return { genres, keywords };
}

async function tmdbLookup(path, queryParams = {}, signal) {
  const proxyRaw = String(movieProxyBaseUrl.value() || "").trim();
  const proxy = ["__unset__", "unset", "none", "null"].includes(
    proxyRaw.toLowerCase()
  )
    ? ""
    : proxyRaw.replace(/\/+$/, "");
  const apiKeyRaw = String(tmdbApiKey.value() || "").trim();
  const apiKey = apiKeyRaw;
  const url = new URL(
    `${proxy || TMDB_BASE_URL}${path.startsWith("/") ? path : `/${path}`}`
  );

  for (const [key, value] of Object.entries(queryParams || {})) {
    if (value == null || value === "") continue;
    url.searchParams.set(key, String(value));
  }
  if (!proxy && apiKey) {
    url.searchParams.set("api_key", apiKey);
  }

  const response = await fetch(url.toString(), {
    method: "GET",
    headers: { Accept: "application/json" },
    signal,
  });
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(
      `TMDB lookup failed (${response.status}): ${JSON.stringify(payload)}`
    );
  }
  return payload;
}

function augmentPlanWithPromptExclusions(plan, prompt) {
  const inferred = inferPromptExclusions(prompt);
  const mergedFranchises = new Set([...(plan.exclude_franchises || []), ...inferred.franchises]);
  const mergedKeywords = new Set([...(plan.exclude_keywords || []), ...inferred.keywords]);
  const mergedAvoidTitles = new Set([...(plan.avoid_titles || []), ...inferred.titles]);
  const mergedExcludeGenres = new Set([...(plan.exclude_genres || []), ...inferred.genres]);
  return {
    ...plan,
    exclude_genres: [...mergedExcludeGenres],
    exclude_franchises: [...mergedFranchises],
    exclude_keywords: [...mergedKeywords],
    avoid_titles: [...mergedAvoidTitles],
  };
}

function inferPromptExclusions(prompt) {
  const normalized = normalizeText(prompt);
  if (!normalized) {
    return { genres: [], franchises: [], keywords: [], titles: [] };
  }
  const hasNegation = /\b(not|without|excluding|except|avoid|no)\b/.test(normalized);
  if (!hasNegation) {
    return { genres: [], franchises: [], keywords: [], titles: [] };
  }

  const genres = [];
  for (const [alias, canonical] of Object.entries(GENRE_ALIAS_TO_CANONICAL)) {
    if (isNegatedMention(normalized, alias)) {
      genres.push(canonical);
    }
  }

  const franchises = [];
  const keywords = [];
  for (const [franchise, aliases] of Object.entries(FRANCHISE_ALIASES)) {
    if (aliases.some((alias) => containsPhrase(normalized, normalizeText(alias)))) {
      franchises.push(franchise);
      keywords.push(...aliases);
    }
  }
  return {
    genres: uniqueNormalizedStrings(genres),
    franchises: uniqueNormalizedStrings(franchises),
    keywords: uniqueNormalizedStrings(keywords),
    titles: [],
  };
}

function buildExclusionTokenSet(plan) {
  const tokens = new Set();
  const add = (value) => {
    const normalized = normalizeText(value);
    if (normalized) {
      tokens.add(normalized);
    }
  };

  for (const item of plan.exclude_keywords || []) add(item);
  for (const item of plan.avoid_titles || []) add(item);
  for (const genre of plan.exclude_genres || []) {
    const canonical = canonicalizeGenre(genre);
    if (!canonical) continue;
    add(canonical);
    for (const alias of GENRE_CANONICAL_ALIASES[canonical] || []) {
      add(alias);
    }
  }
  for (const franchise of plan.exclude_franchises || []) {
    const normalizedFranchise = normalizeText(franchise);
    if (!normalizedFranchise) continue;
    add(normalizedFranchise);
    for (const alias of FRANCHISE_ALIASES[normalizedFranchise] || []) {
      add(alias);
    }
  }
  return tokens;
}

function candidateViolatesExclusions(row, exclusionTokens) {
  if (!exclusionTokens || exclusionTokens.size === 0) {
    return false;
  }
  const rowText = normalizeText(
    [
      row.title || "",
      row.originalTitle || "",
      row.tagline || "",
      row.overview || "",
      ...(row.keywords || []),
      ...(row.genres || []),
    ].join(" ")
  );
  if (!rowText) {
    return false;
  }
  for (const token of exclusionTokens) {
    if (containsPhrase(rowText, token)) {
      return true;
    }
  }
  return false;
}

function candidateMatchesExcludedSeedTitle(row, excludedSeedTitles) {
  if (!excludedSeedTitles || excludedSeedTitles.size === 0) {
    return false;
  }
  const title = normalizeText(row.title || "");
  const originalTitle = normalizeText(row.originalTitle || "");
  if (title && excludedSeedTitles.has(title)) {
    return true;
  }
  if (originalTitle && excludedSeedTitles.has(originalTitle)) {
    return true;
  }
  return false;
}

function containsPhrase(haystack, needle) {
  if (!haystack || !needle) return false;
  if (haystack === needle) return true;
  return haystack.includes(` ${needle} `) || haystack.startsWith(`${needle} `) || haystack.endsWith(` ${needle}`);
}

function uniqueNormalizedStrings(values) {
  const seen = new Set();
  for (const value of values || []) {
    const normalized = normalizeText(value);
    if (!normalized) continue;
    seen.add(normalized);
  }
  return [...seen];
}

function buildGenreAliasToCanonicalMap() {
  const map = {};
  for (const [canonical, aliases] of Object.entries(GENRE_CANONICAL_ALIASES)) {
    const canonicalNormalized = normalizeText(canonical);
    if (!canonicalNormalized) continue;
    map[canonicalNormalized] = canonicalNormalized;
    for (const alias of aliases || []) {
      const normalized = normalizeText(alias);
      if (!normalized) continue;
      map[normalized] = canonicalNormalized;
    }
  }
  return map;
}

function canonicalizeGenre(value) {
  const normalized = normalizeText(value);
  if (!normalized) return "";
  return GENRE_ALIAS_TO_CANONICAL[normalized] || normalized;
}

function canonicalGenreSet(values) {
  const set = new Set();
  for (const value of values || []) {
    const canonical = canonicalizeGenre(value);
    if (canonical) {
      set.add(canonical);
    }
  }
  return set;
}

function canonicalGenreList(value) {
  const set = new Set();
  for (const raw of stringList(value)) {
    const canonical = canonicalizeGenre(raw);
    if (canonical) {
      set.add(canonical);
    }
  }
  return [...set];
}

function isNegatedMention(normalizedPrompt, term) {
  if (!normalizedPrompt || !term) return false;
  const escaped = escapeRegex(String(term).trim());
  if (!escaped) return false;
  const spaced = escaped.replace(/\s+/g, "\\s+");
  const pattern = new RegExp(
    `\\b(?:not|without|excluding|except|avoid|no)\\b(?:\\s+\\w+){0,6}\\s+${spaced}\\b`
  );
  return pattern.test(normalizedPrompt);
}

function escapeRegex(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function qualityScore(row) {
  const voteAverage = Number(row.voteAverage || 0);
  const voteCount = Number(row.voteCount || 0);
  const popularity = Number(row.popularity || 0);
  const rating = Math.min(1, voteAverage / 8.5);
  const confidence = Math.min(1, Math.log10(voteCount + 1) / 3);
  const popularityScore = Math.min(1, Math.log10(popularity + 1) / 2);
  return rating * 0.55 + confidence * 0.35 + popularityScore * 0.1;
}

function buildReason(row, genreHits, keywordHits, language, stageName) {
  const parts = [];
  if (genreHits.length) parts.push(`matches ${genreHits.join(", ")}`);
  if (keywordHits.length) parts.push(`keywords: ${keywordHits.join(", ")}`);
  if (language && row.originalLanguage === language) {
    parts.push(`original language is ${language}`);
  }
  if (stageName !== "strict") {
    parts.push(`expanded search (${stageName.replace("_", " ")})`);
  }
  if (row.runtimeMinutes) parts.push(`${row.runtimeMinutes} min`);
  if (row.voteAverage) {
    parts.push(`${Number(row.voteAverage).toFixed(1)}/10 from ${row.voteCount || 0} votes`);
  }
  return parts.length ? parts.join("; ") : "Strong vector match";
}

function stripJsonFence(value) {
  return value
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```$/i, "")
    .trim();
}

function normalizeText(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function parsePositiveInt(value, fallback) {
  const parsed = Number.parseInt(String(value ?? ""), 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
}

function parseBooleanString(value, fallback) {
  const normalized = String(value ?? "").trim().toLowerCase();
  if (!normalized) return fallback;
  if (["1", "true", "yes", "y", "on"].includes(normalized)) return true;
  if (["0", "false", "no", "n", "off"].includes(normalized)) return false;
  return fallback;
}

function isQdrantConfigured() {
  const value = String(qdrantUrl.value() || "").trim().toLowerCase();
  if (!value) return false;
  if (["__unconfigured__", "unset", "none", "null"].includes(value)) {
    return false;
  }
  return true;
}

function isZillizConfigured() {
  const endpoint = String(zillizEndpoint.value() || "").trim().toLowerCase();
  const apiKey = String(zillizApiKey.value() || "").trim();
  if (!endpoint || !apiKey) return false;
  if (["__unconfigured__", "unset", "none", "null"].includes(endpoint)) {
    return false;
  }
  return true;
}

function resolveVectorBackendPreference() {
  const configured = normalizeText(vectorBackend.value() || "zilliz");
  if (configured === "zilliz" || configured === "milvus") return "zilliz";
  if (configured === "firestore") return "firestore";
  return "qdrant";
}

function requestedVectorBackendLabel() {
  const preference = resolveVectorBackendPreference();
  if (preference === "zilliz") {
    return "zilliz_primary_with_qdrant_then_firestore_failover";
  }
  if (preference === "firestore") {
    return "firestore_only";
  }
  return "qdrant_primary_with_zilliz_then_firestore_failover";
}

function escapeMilvusString(value) {
  return String(value || "").replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function normalizePromptInput(value) {
  return String(value || "").replace(/\s+/g, " ").trim();
}

function isMovieRecommendationPrompt(prompt) {
  const raw = String(prompt || "").toLowerCase();
  const normalized = normalizeText(prompt);
  if (!normalized) return false;

  let movieSignals = 0;
  let offTopicSignals = 0;

  for (const hint of MOVIE_DOMAIN_HINTS) {
    const normalizedHint = normalizeText(hint);
    if (!normalizedHint) continue;
    if (containsPhrase(normalized, normalizedHint)) {
      movieSignals += 1;
    }
  }

  for (const alias of Object.keys(GENRE_ALIAS_TO_CANONICAL)) {
    if (!alias) continue;
    if (containsPhrase(normalized, alias)) {
      movieSignals += 1;
      break;
    }
  }

  if (/\b(19|20)\d{2}\b/.test(raw)) {
    movieSignals += 1;
  }

  for (const hint of OFF_TOPIC_HINTS) {
    const normalizedHint = normalizeText(hint);
    if (!normalizedHint) continue;
    if (containsPhrase(normalized, normalizedHint)) {
      offTopicSignals += 1;
    }
  }

  const explicitCodeTask = /\b(write|create|build|generate|implement|debug|fix|optimi[sz]e|explain)\b[\s\S]{0,60}\b(code|script|program|function|class|algorithm|sql|regex|api)\b/.test(
    raw
  );

  if (explicitCodeTask && movieSignals === 0) {
    return false;
  }
  if (offTopicSignals >= 2 && movieSignals === 0) {
    return false;
  }
  return true;
}

function languageCode(value) {
  const normalized = normalizeText(value);
  if (!normalized) return null;
  if (normalized.length === 2) return normalized;
  const aliases = {
    english: "en",
    hindi: "hi",
    tamil: "ta",
    telugu: "te",
    malayalam: "ml",
    kannada: "kn",
    korean: "ko",
    japanese: "ja",
    spanish: "es",
    french: "fr",
    german: "de",
    italian: "it",
  };
  return aliases[normalized] || null;
}

function stringValue(value) {
  return typeof value === "string" ? value.trim() : "";
}

function stringList(value) {
  return Array.isArray(value)
    ? value.map((item) => stringValue(item)).filter(Boolean)
    : [];
}

function intValue(value) {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) ? parsed : null;
}

function numberValue(value) {
  const parsed = Number.parseFloat(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function clampInt(value, min, max, fallback) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.max(min, Math.min(max, parsed));
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

class HttpError extends Error {
  constructor(statusCode, message, options = {}) {
    super(message);
    this.name = "HttpError";
    this.statusCode = statusCode;
    this.retryAfterSeconds = Number(options.retryAfterSeconds || 0) || null;
  }
}
