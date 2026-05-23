"use strict";

const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret, defineString } = require("firebase-functions/params");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

const db = admin.firestore();
const openRouterApiKey = defineSecret("OPENROUTER_API_KEY");
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
const indexCollection = defineString("TONIGHT_VECTOR_COLLECTION", {
  default: "tmdb_movie_vectors_v1",
});
const vectorBackend = defineString("TONIGHT_VECTOR_BACKEND", {
  default: "firestore",
});
const qdrantUrl = defineString("QDRANT_URL", {
  default: "",
});
const qdrantCollection = defineString("QDRANT_COLLECTION", {
  default: "tmdb_movie_vectors_v1",
});
const qdrantApiKey = defineString("QDRANT_API_KEY", {
  default: "",
});
const qdrantTimeoutMs = defineString("QDRANT_TIMEOUT_MS", {
  default: "12000",
});
const MAX_PROMPT_CHARS = 420;
const RATE_LIMIT_COLLECTION = "_recommendTonightRateLimits";
const RATE_LIMITS = {
  anonymous: { perMinute: 8, perDay: 120, cooldownSeconds: 45 },
  appCheckVerified: { perMinute: 16, perDay: 300, cooldownSeconds: 30 },
  user: { perMinute: 20, perDay: 450, cooldownSeconds: 20 },
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

exports.recommendTonight = onRequest(
  {
    region: "us-central1",
    cors: true,
    secrets: [openRouterApiKey],
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

      const plan = await planPrompt(prompt);
      const queryTexts = buildQueryTexts(prompt, plan);
      const candidateLookup = await fetchCandidates(queryTexts, topK);
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
          vectorBackendRequested: normalizeBackendMode(vectorBackend.value()),
          vectorBackendResolved: candidateLookup.backend,
          vectorBackendStats: candidateLookup.stats,
          stage: ranking.stage,
          relaxed: ranking.relaxed,
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
  const models = [
    chatModel.value(),
    ...String(chatFallbackModels.value() || "")
      .split(",")
      .map((model) => model.trim())
      .filter(Boolean),
  ];
  const tried = new Set();
  const uniqueModels = models.filter((model) => {
    if (tried.has(model)) return false;
    tried.add(model);
    return true;
  });

  let lastError = null;
  for (const model of uniqueModels) {
    try {
      const json = await callPlannerModel(model, prompt);
      const content = String(json?.choices?.[0]?.message?.content || "{}").trim();
      return augmentPlanWithPromptExclusions(
        normalizePlan(JSON.parse(stripJsonFence(content)), prompt),
        prompt
      );
    } catch (error) {
      lastError = error;
      console.warn(`Planner model failed: ${model}`, error);
    }
  }
  console.warn("All planner models failed; using fallback", lastError);
  return augmentPlanWithPromptExclusions(normalizePlan({}, prompt), prompt);
}

async function callPlannerModel(model, prompt) {
  const payload = {
    model,
    temperature: 0.2,
    response_format: { type: "json_object" },
    messages: [
      {
        role: "system",
        content:
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
          "Use canonical TMDB genre names such as 'Science Fiction' (not 'sci-fi').",
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

async function findNearestMoviesQdrant(queryEmbedding, limit) {
  const baseUrl = String(qdrantUrl.value() || "").trim().replace(/\/+$/, "");
  const collectionName = String(qdrantCollection.value() || "").trim();
  if (!baseUrl) {
    throw new Error("QDRANT_URL is empty.");
  }
  if (!collectionName) {
    throw new Error("QDRANT_COLLECTION is empty.");
  }

  const url = `${baseUrl}/collections/${encodeURIComponent(
    collectionName
  )}/points/query`;
  const timeout = parsePositiveInt(qdrantTimeoutMs.value(), 12000);
  const apiKey = String(qdrantApiKey.value() || "").trim();
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeout);
  try {
    const result = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        ...(apiKey ? { "api-key": apiKey } : {}),
      },
      body: JSON.stringify({
        query: queryEmbedding,
        limit,
        with_payload: true,
        with_vector: false,
      }),
      signal: controller.signal,
    });
    const json = await result.json().catch(() => ({}));
    if (!result.ok) {
      throw new Error(
        `Qdrant query failed (${result.status}): ${JSON.stringify(json)}`
      );
    }

    const rawPoints = Array.isArray(json?.result?.points)
      ? json.result.points
      : Array.isArray(json?.result)
      ? json.result
      : [];

    return rawPoints.map((point) => {
      const payload = point?.payload || {};
      const vectorSimilarityRaw = Number(point?.score || 0);
      const vectorSimilarity = Number.isFinite(vectorSimilarityRaw)
        ? Math.max(0, Math.min(1, vectorSimilarityRaw))
        : 0;
      return {
        docId: String(point?.id ?? payload.id ?? ""),
        ...payload,
        vectorSimilarity,
        vectorDistance: Number((1 - vectorSimilarity).toFixed(6)),
      };
    });
  } finally {
    clearTimeout(timer);
  }
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

async function fetchCandidatesFromQdrant(queryTexts, topK) {
  const limitPerVariant = Math.max(30, Math.min(100, topK * 8));
  const settled = await Promise.allSettled(
    queryTexts.map(async (queryText) => {
      const queryEmbedding = await embedText(queryText);
      return findNearestMoviesQdrant(queryEmbedding, limitPerVariant);
    })
  );
  return mergeCandidateRowsFromVariants(settled);
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

async function fetchCandidates(queryTexts, topK) {
  const backendMode = normalizeBackendMode(vectorBackend.value());
  if (backendMode === "firestore") {
    return {
      rows: await fetchCandidatesFromFirestore(queryTexts, topK),
      backend: "firestore",
      stats: { firestore: "ok", qdrant: "skipped" },
    };
  }

  if (backendMode === "qdrant") {
    return {
      rows: await fetchCandidatesFromQdrant(queryTexts, topK),
      backend: "qdrant",
      stats: { firestore: "skipped", qdrant: "ok" },
    };
  }

  const [qdrantResult, firestoreResult] = await Promise.allSettled([
    fetchCandidatesFromQdrant(queryTexts, topK),
    fetchCandidatesFromFirestore(queryTexts, topK),
  ]);

  const merged = [];
  const stats = {};
  if (qdrantResult.status === "fulfilled") {
    merged.push(...qdrantResult.value);
    stats.qdrant = `ok:${qdrantResult.value.length}`;
  } else {
    console.warn("Qdrant candidate lookup failed in dual mode", qdrantResult.reason);
    stats.qdrant = "failed";
  }
  if (firestoreResult.status === "fulfilled") {
    merged.push(...firestoreResult.value);
    stats.firestore = `ok:${firestoreResult.value.length}`;
  } else {
    console.warn(
      "Firestore candidate lookup failed in dual mode",
      firestoreResult.reason
    );
    stats.firestore = "failed";
  }

  if (merged.length === 0) {
    throw new Error("Both Qdrant and Firestore candidate lookups failed.");
  }

  const deduped = mergeCandidateRowsFromVariants([{ status: "fulfilled", value: merged }]);
  return {
    rows: deduped,
    backend: "dual",
    stats,
  };
}

function rerankResults(rows, plan, topK) {
  const excluded = new Set((plan.exclude_genres || []).map(canonicalizeGenre).filter(Boolean));
  const exclusionTokens = buildExclusionTokenSet(plan);
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

function normalizeBackendMode(value) {
  const normalized = String(value || "").trim().toLowerCase();
  if (normalized === "qdrant") return "qdrant";
  if (normalized === "dual") return "dual";
  return "firestore";
}

function parsePositiveInt(value, fallback) {
  const parsed = Number.parseInt(String(value ?? ""), 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
}

function normalizePromptInput(value) {
  return String(value || "").replace(/\s+/g, " ").trim();
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
