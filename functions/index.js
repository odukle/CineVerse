"use strict";

const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret, defineString } = require("firebase-functions/params");
const admin = require("firebase-admin");

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
      const prompt = String(request.body?.prompt || "").trim();
      const isTv = Boolean(request.body?.isTv);
      const topK = clampInt(request.body?.topK, 1, 20, 12);

      if (prompt.length < 4) {
        response.status(400).json({ error: "Prompt is too short." });
        return;
      }
      if (isTv) {
        response.status(400).json({
          error: "Tonight vector recommendations currently support movies only.",
        });
        return;
      }

      const user = await readFirebaseUser(request);
      const plan = await planPrompt(prompt);
      const queryTexts = buildQueryTexts(prompt, plan);
      const rawResults = await fetchCandidates(queryTexts, topK);
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
          stage: ranking.stage,
          relaxed: ranking.relaxed,
        },
        results: ranked,
      });
    } catch (error) {
      console.error("recommendTonight failed", error);
      if (error instanceof HttpError) {
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
      return normalizePlan(JSON.parse(stripJsonFence(content)), prompt);
    } catch (error) {
      lastError = error;
      console.warn(`Planner model failed: ${model}`, error);
    }
  }
  console.warn("All planner models failed; using fallback", lastError);
  return normalizePlan({}, prompt);
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
          "\"min_runtime\": int|null, \"max_runtime\": int|null, " +
          "\"min_vote_average\": number|null, \"min_vote_count\": int|null, " +
          "\"year_from\": int|null, \"year_to\": int|null, " +
          "\"keywords\": string[], \"similar_titles\": string[], \"avoid_titles\": string[], \"query_variants\": string[]}. " +
          "Respect exclusions and keep values practical for TMDB/Firestore search.",
      },
      {
        role: "user",
        content: `User wants movies. Request: "${prompt}". Return the JSON now.`,
      },
    ],
  };
  return openRouterFetch("/chat/completions", payload, {
    retries: 4,
    retryBaseDelayMs: 1500,
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
        retries: 4,
        retryBaseDelayMs: 1500,
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

  for (let attempt = 1; attempt <= retries; attempt += 1) {
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
  }
}

async function findNearestMovies(queryEmbedding, limit) {
  const collection = db.collection(indexCollection.value());
  const vectorQuery = collection
    .select(
      "id",
      "title",
      "genres",
      "originalLanguage",
      "runtimeMinutes",
      "releaseYear",
      "voteAverage",
      "voteCount",
      "popularity",
      "posterPath",
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

async function fetchCandidates(queryTexts, topK) {
  const limitPerVariant = Math.max(40, Math.min(140, topK * 10));
  const allRows = [];

  for (const queryText of queryTexts) {
    const queryEmbedding = await embedText(queryText);
    const rows = await findNearestMovies(queryEmbedding, limitPerVariant);
    allRows.push(...rows);
  }

  const byId = new Map();
  for (const row of allRows) {
    const id = Number(row.id || 0);
    if (!id) continue;
    const vectorSimilarity = 1 - Number(row.vectorDistance || 1);
    const existing = byId.get(id);
    if (!existing || vectorSimilarity > existing.vectorSimilarity) {
      byId.set(id, { ...row, vectorSimilarity });
    }
  }

  return [...byId.values()];
}

function rerankResults(rows, plan, topK) {
  const excluded = new Set((plan.exclude_genres || []).map(normalizeText));
  const included = new Set((plan.include_genres || []).map(normalizeText));
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
        const rowGenres = new Set((row.genres || []).map(normalizeText));
        if ([...excluded].some((genre) => rowGenres.has(genre))) return false;
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
  const rowGenres = new Set((row.genres || []).map(normalizeText));
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
  const base = [];
  base.push(prompt);
  if (plan.intent_summary) base.push(plan.intent_summary);
  if (plan.include_genres?.length) base.push(`Genres: ${plan.include_genres.join(", ")}`);
  if (plan.keywords?.length) base.push(`Keywords: ${plan.keywords.join(", ")}`);
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
  }

  return [...variants].slice(0, 6);
}

function normalizePlan(raw, fallbackPrompt) {
  return {
    intent_summary: stringValue(raw.intent_summary) || fallbackPrompt,
    original_language: languageCode(stringValue(raw.original_language)),
    include_genres: stringList(raw.include_genres),
    exclude_genres: stringList(raw.exclude_genres),
    min_runtime: intValue(raw.min_runtime),
    max_runtime: intValue(raw.max_runtime),
    min_vote_average: numberValue(raw.min_vote_average),
    min_vote_count: intValue(raw.min_vote_count),
    year_from: intValue(raw.year_from),
    year_to: intValue(raw.year_to),
    keywords: stringList(raw.keywords),
    similar_titles: stringList(raw.similar_titles),
    avoid_titles: stringList(raw.avoid_titles),
    query_variants: stringList(raw.query_variants),
  };
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
  constructor(statusCode, message) {
    super(message);
    this.name = "HttpError";
    this.statusCode = statusCode;
  }
}
