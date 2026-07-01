from __future__ import annotations

import html
import hashlib
import json
import os
import re
import time
import unicodedata
from typing import Iterable, Optional
from urllib.parse import parse_qs, urlparse

import requests
from firebase_admin import firestore, initialize_app
from firebase_functions import https_fn

_ALLOWED_HOST_SUFFIXES = (
    "justwatch.com",
    "www.justwatch.com",
    "themoviedb.org",
    "www.themoviedb.org",
)

_CACHE_COLLECTION = "watch_provider_link_cache"
_CACHE_HIT_TTL_SECONDS = 60 * 60 * 24 * 7  # 7 days
_CACHE_MISS_TTL_SECONDS = 60 * 60 * 12  # 12 hours
_CACHE_ADMIN_HEADER = "X-Cache-Admin-Key"
_CACHE_ADMIN_ENV = "WATCH_PROVIDER_CACHE_ADMIN_KEY"
_TMDB_PROXY_BASE_URL_ENV = "TMDB_PROXY_BASE_URL"
_TMDB_PROXY_BASE_URL_DEFAULT = "https://cineverse-tmdb-proxy.sodukle.workers.dev"
_OMDB_API_KEY_ENV = "OMDB_API_KEY"
_OMDB_BASE_URL = "https://www.omdbapi.com"
_OMDB_RESOLVER_URL = (
    "https://us-east4-cineverse-flutter-591.cloudfunctions.net/resolveOmdbTitleDetails"
)

_PROVIDER_ALIASES: dict[str, list[str]] = {
    "amazon prime video": ["prime video", "amazon prime video", "amazon video"],
    "apple tv+": ["apple tv+", "apple tv plus", "appletv+"],
    "disney plus": ["disney+", "disney plus"],
    "hbo max": ["hbo max", "max"],
    "paramount plus": ["paramount+", "paramount plus"],
    "youtube premium": ["youtube premium", "youtube movies"],
    "google play movies": ["google play", "google play movies"],
}

_TMDB_WATCH_SLUG_OVERRIDES: dict[str, str] = {
    # TMDB currently returns 502 for this title's details endpoints, so the
    # resolver cannot derive the JustWatch slug from TMDB metadata.
    "movie:1319765": "dhurandhar",
}

_firebase_app = initialize_app()
_firestore_client = firestore.client(_firebase_app)


@https_fn.on_request()
def resolveProviderLink(req: https_fn.Request) -> https_fn.Response:
    if req.method == "OPTIONS":
        return _json_response(204, {})
    if req.method != "POST":
        return _json_response(405, {"error": "Use POST."})

    payload = req.get_json(silent=True) or {}
    source_url = str(payload.get("justwatchUrl") or "").strip()
    provider_name = str(payload.get("providerName") or "").strip()
    preferred_region_code = _normalize_region_code(
        payload.get("preferredRegionCode") or payload.get("regionCode")
    )

    if not source_url or not provider_name:
        return _json_response(
            400,
            {"error": "justwatchUrl and providerName are required."},
        )
    if not _is_allowed_input_url(source_url):
        return _json_response(400, {"error": "Invalid source URL."})

    normalized_provider = _normalize_provider_name(provider_name)
    provider_aliases = _provider_aliases(normalized_provider)
    source_is_tmdb = _is_tmdb_url(source_url)
    effective_justwatch_url = _normalize_to_justwatch_url(source_url)
    if not effective_justwatch_url:
        return _json_response(
            400,
            {
                "error": (
                    "Could not derive a JustWatch page URL from input URL. "
                    "Send a JustWatch page URL or a TMDB /watch URL."
                ),
            },
        )

    cache_key = _build_cache_key(
        effective_justwatch_url,
        f"{normalized_provider}|{preferred_region_code or ''}",
    )

    cached = _read_cache_entry(cache_key)
    cached_miss_response: Optional[dict] = None
    if cached is not None:
        if cached.get("status") == "ok":
            resolved_url = str(cached.get("resolvedUrl") or "").strip()
            if resolved_url:
                return _json_response(
                    200,
                    {
                        "resolvedUrl": resolved_url,
                        "providerName": provider_name,
                        "source": "cache",
                    },
                )
        if cached.get("status") == "not_found":
            fallback_url = str(cached.get("justwatchUrl") or "").strip()
            if not fallback_url:
                fallback_url = effective_justwatch_url
            cached_miss_response = {
                "error": "No provider-specific URL found on JustWatch page.",
                "resolvedUrl": fallback_url,
                "providerName": provider_name,
                "source": "cache",
            }

    attempted_tmdb_fallback = False
    page_candidates = _justwatch_page_candidates(
        effective_justwatch_url,
        preferred_region_code,
    )
    if source_is_tmdb and source_url.strip() not in page_candidates:
        page_candidates.append(source_url.strip())

    fetch_errors: list[str] = []

    for candidate_url in page_candidates:
        if candidate_url == source_url.strip() and source_is_tmdb:
            attempted_tmdb_fallback = True
        try:
            response = requests.get(
                candidate_url,
                timeout=8,
                headers={
                    "User-Agent": (
                        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                        "(KHTML, like Gecko) Chrome/123.0 Safari/537.36"
                    ),
                    "Accept-Language": "en-US,en;q=0.9",
                },
            )
            response.raise_for_status()
            page_html = response.text
        except requests.RequestException as exc:
            fetch_errors.append(f"{candidate_url}: {exc}")
            continue

        resolved = _resolve_from_json_ld(page_html, provider_aliases)
        if resolved:
            if _is_cacheable_provider_url(resolved):
                _write_cache_entry(
                    cache_key=cache_key,
                    justwatch_url=effective_justwatch_url,
                    normalized_provider=normalized_provider,
                    status="ok",
                    resolved_url=resolved,
                    source="jsonld",
                )
            return _json_response(
                200,
                {
                    "resolvedUrl": resolved,
                    "providerName": provider_name,
                    "source": "jsonld",
                },
            )

        resolved = _resolve_from_embedded_state(page_html, provider_aliases)
        if resolved:
            if _is_cacheable_provider_url(resolved):
                _write_cache_entry(
                    cache_key=cache_key,
                    justwatch_url=effective_justwatch_url,
                    normalized_provider=normalized_provider,
                    status="ok",
                    resolved_url=resolved,
                    source="embedded-offers",
                )
            return _json_response(
                200,
                {
                    "resolvedUrl": resolved,
                    "providerName": provider_name,
                    "source": "embedded-offers",
                },
            )

    _write_cache_entry(
        cache_key=cache_key,
        justwatch_url=_resolver_fallback_url(
            page_candidates,
            effective_justwatch_url,
        ),
        normalized_provider=normalized_provider,
        status="not_found",
        resolved_url="",
        source="none",
    )
    return _json_response(
        404,
        {
            "error": (
                "No provider-specific URL found on watch pages."
                if attempted_tmdb_fallback
                else "No provider-specific URL found on JustWatch page."
            ),
            "resolvedUrl": _resolver_fallback_url(
                page_candidates,
                effective_justwatch_url,
            ),
            "providerName": provider_name,
            "attemptedTmdbFallback": attempted_tmdb_fallback,
        },
    )


@https_fn.on_request()
def watchProviderCacheAdmin(req: https_fn.Request) -> https_fn.Response:
    if req.method == "OPTIONS":
        return _json_response(204, {})
    if req.method not in {"GET", "POST"}:
        return _json_response(405, {"error": "Use GET or POST."})

    configured_key = os.getenv(_CACHE_ADMIN_ENV, "").strip()
    if configured_key:
        supplied_key = str(req.headers.get(_CACHE_ADMIN_HEADER) or "").strip()
        if supplied_key != configured_key:
            return _json_response(401, {"error": "Unauthorized."})

    payload = req.get_json(silent=True) or {}
    action = str(
        req.args.get("action")
        or payload.get("action")
        or ("stats" if req.method == "GET" else "")
    ).strip().lower()

    if action == "stats":
        response = _cache_stats_payload()
        response["authRequired"] = bool(configured_key)
        return _json_response(200, response)
    if action == "cleanup":
        if req.method != "POST":
            return _json_response(405, {"error": "cleanup requires POST."})
        requested_limit = payload.get("limit", 250)
        limit = 250
        try:
            limit = int(requested_limit)
        except (TypeError, ValueError):
            limit = 250
        limit = max(1, min(limit, 1000))
        dry_run = bool(payload.get("dryRun", False))
        result = _cleanup_expired_cache(limit=limit, dry_run=dry_run)
        result["authRequired"] = bool(configured_key)
        return _json_response(200, result)
    return _json_response(400, {"error": "Unknown action. Use stats or cleanup."})


@https_fn.on_request()
def resolveMovieAwards(req: https_fn.Request) -> https_fn.Response:
    if req.method == "OPTIONS":
        return _json_response(204, {})
    if req.method != "POST":
        return _json_response(405, {"error": "Use POST."})

    payload = req.get_json(silent=True) or {}
    movie_id = str(payload.get("movieId") or "").strip()
    imdb_id = str(payload.get("imdbId") or "").strip()
    language = str(payload.get("language") or "en-US").strip() or "en-US"

    if not movie_id.isdigit():
        return _json_response(400, {"error": "movieId is required (numeric)."})

    tmdb_result = _scrape_tmdb_awards(movie_id=movie_id, language=language)
    omdb_result = _fetch_omdb_awards(imdb_id=imdb_id)

    if (
        tmdb_result is not None
        and tmdb_result.get("awardsText")
        and omdb_result is not None
        and omdb_result.get("awardsText")
    ):
        merged = _merge_award_sources(
            tmdb_result=tmdb_result,
            omdb_result=omdb_result,
        )
        return _json_response(
            200,
            {
                "source": "omdb_totals_tmdb_details",
                "awardsText": merged["awardsText"],
                "totalWins": merged.get("totalWins", 0),
                "totalNominations": merged.get("totalNominations", 0),
                "detailLines": merged.get("detailLines", []),
                "detailItems": merged.get("detailItems", []),
            },
        )

    if tmdb_result is not None and tmdb_result.get("awardsText"):
        return _json_response(
            200,
            {
                "source": "tmdb_scrape",
                "awardsText": tmdb_result["awardsText"],
                "totalWins": tmdb_result.get("totalWins", 0),
                "totalNominations": tmdb_result.get("totalNominations", 0),
                "detailLines": tmdb_result.get("detailLines", []),
                "detailItems": tmdb_result.get("detailItems", []),
            },
        )

    if omdb_result is not None and omdb_result.get("awardsText"):
        return _json_response(
            200,
            {
                "source": "omdb_fallback",
                "awardsText": omdb_result["awardsText"],
                "totalWins": omdb_result.get("totalWins", 0),
                "totalNominations": omdb_result.get("totalNominations", 0),
                "detailLines": omdb_result.get("detailLines", []),
                "detailItems": [],
            },
        )

    return _json_response(
        200,
        {
            "source": "none",
            "awardsText": "",
            "totalWins": 0,
            "totalNominations": 0,
            "detailLines": [],
            "detailItems": [],
        },
    )


def _build_cache_key(justwatch_url: str, normalized_provider: str) -> str:
    digest = hashlib.sha256(
        f"{justwatch_url.strip()}|{normalized_provider.strip()}".encode("utf-8"),
    ).hexdigest()
    return digest


def _scrape_tmdb_awards(*, movie_id: str, language: str) -> Optional[dict]:
    url = f"https://www.themoviedb.org/movie/{movie_id}/awards"
    if language:
        url = f"{url}?language={language}"

    try:
        response = requests.get(
            url,
            timeout=12,
            headers={
                "User-Agent": (
                    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                    "(KHTML, like Gecko) Chrome/123.0 Safari/537.36"
                ),
                "Accept-Language": "en-US,en;q=0.9",
            },
        )
        if response.status_code >= 400:
            return None
        page_html = response.text
    except requests.RequestException:
        return None

    wins, nominations = _extract_award_counts(page_html)
    detail_items = _extract_award_detail_items(page_html, max_items=50)
    if wins == 0 and nominations == 0 and detail_items:
        wins, nominations = _derive_award_counts_from_items(detail_items)
    detail_lines = [str(item.get("text") or "").strip() for item in detail_items]
    detail_lines = [line for line in detail_lines if line]

    if wins == 0 and nominations == 0 and not detail_lines:
        return None

    summary_parts: list[str] = []
    if wins > 0:
        summary_parts.append(f"{wins} {'win' if wins == 1 else 'wins'}")
    if nominations > 0:
        summary_parts.append(
            f"{nominations} {'nomination' if nominations == 1 else 'nominations'}"
        )
    summary = " & ".join(summary_parts).strip()

    lines: list[str] = []
    if summary:
        lines.append(summary)
    lines.extend(detail_lines)

    awards_text = ". ".join(line.strip().rstrip(".") for line in lines if line.strip())
    if awards_text:
        awards_text = f"{awards_text}."

    return {
        "awardsText": awards_text,
        "totalWins": wins,
        "totalNominations": nominations,
        "detailLines": detail_lines,
        "detailItems": detail_items,
    }


def _merge_award_sources(*, tmdb_result: dict, omdb_result: dict) -> dict:
    total_wins = int(omdb_result.get("totalWins") or 0)
    total_nominations = int(omdb_result.get("totalNominations") or 0)
    detail_lines = [
        str(line).strip()
        for line in (tmdb_result.get("detailLines") or [])
        if str(line).strip()
    ]
    detail_items = list(tmdb_result.get("detailItems") or [])

    awards_lines: list[str] = []
    omdb_awards_text = str(omdb_result.get("awardsText") or "").strip()
    if omdb_awards_text:
        awards_lines.extend(
            part.strip()
            for part in omdb_awards_text.split(".")
            if part.strip() and part.strip().lower() != "n/a"
        )

    seen = {line.lower() for line in awards_lines}
    for line in detail_lines:
        key = line.lower()
        if key in seen:
            continue
        seen.add(key)
        awards_lines.append(line)

    awards_text = ". ".join(
        line.strip().rstrip(".")
        for line in awards_lines
        if line.strip()
    )
    if awards_text:
        awards_text = f"{awards_text}."

    return {
        "awardsText": awards_text,
        "totalWins": total_wins,
        "totalNominations": total_nominations,
        "detailLines": detail_lines,
        "detailItems": detail_items,
    }


def _derive_award_counts_from_items(
    detail_items: list[dict[str, str]],
) -> tuple[int, int]:
    wins = 0
    nominations = 0
    for item in detail_items:
        text = str(item.get("text") or "").strip().lower()
        if not text:
            continue
        if text.startswith("winner:"):
            wins += 1
        elif text.startswith("nominee:") or text.startswith("nominated:"):
            nominations += 1
    return wins, nominations


def _extract_award_counts(page_html: str) -> tuple[int, int]:
    compact_html = re.sub(r"\s+", " ", html.unescape(page_html))
    wins = 0
    nominations = 0

    meta_match = re.search(
        r"has received\s+(\d+)\s+nominations?\s+and\s+(\d+)\s+wins?",
        compact_html,
        flags=re.IGNORECASE,
    )
    if meta_match:
        nominations = int(meta_match.group(1))
        wins = int(meta_match.group(2))
        return wins, nominations

    heading_patterns = (
        r"(\d+)\s+Nominations?\s*[,|/•-]?\s*(\d+)\s+Wins?",
        r"(\d+)\s+Wins?\s*[,|/•-]?\s*(\d+)\s+Nominations?",
    )
    for pattern in heading_patterns:
        heading_match = re.search(pattern, compact_html, flags=re.IGNORECASE)
        if heading_match:
            first = int(heading_match.group(1))
            second = int(heading_match.group(2))
            if "wins" in pattern.lower() and pattern.lower().startswith(r"(\d+)\s+wins"):
                wins = first
                nominations = second
            else:
                nominations = first
                wins = second
            return wins, nominations

    return wins, nominations


def _extract_award_detail_items(
    page_html: str, *, max_items: int
) -> list[dict[str, str]]:
    normalized_html = html.unescape(page_html)
    compact = re.sub(r"\s+", " ", normalized_html)
    award_logo_map = _extract_award_logo_map(compact)

    pattern = re.compile(
        r'href="/award/(\d+)[^"]*/ceremony/[^"]+"[^>]*>([^<]+)</a>.*?'
        r'<span[^>]*>\s*(Winner|Nominee)\s*</span>\s*'
        r'<a[^>]*href="/award/(\d+)[^"]*/category/[^"]+"[^>]*>([^<]+)</a>',
        flags=re.IGNORECASE,
    )

    items: list[dict[str, str]] = []
    seen: set[str] = set()

    for match in pattern.finditer(compact):
        award_id = str(match.group(1) or match.group(4) or "").strip()
        ceremony = re.sub(r"\s+", " ", match.group(2)).strip()
        status = re.sub(r"\s+", " ", match.group(3)).strip().title()
        category = re.sub(r"\s+", " ", match.group(5)).strip()
        if not ceremony or not status or not category:
            continue
        line = f"{status}: {category} ({ceremony})"
        key = line.lower()
        if key in seen:
            continue
        seen.add(key)
        logo = award_logo_map.get(award_id, {})
        item: dict[str, str] = {"text": line}
        logo_url = str(logo.get("logoUrl") or "").strip()
        award_name = str(logo.get("awardName") or "").strip()
        if logo_url:
            item["logoUrl"] = logo_url
        if award_name:
            item["awardName"] = award_name
        items.append(item)
        if len(items) >= max_items:
            break

    return items


def _extract_award_logo_map(compact_html: str) -> dict[str, dict[str, str]]:
    logo_map: dict[str, dict[str, str]] = {}
    pattern = re.compile(
        r'href="/award/(\d+)[^"]*"\s+title="([^"]+)"[^>]*>.*?'
        r'<img[^>]+src="([^"]+)"',
        flags=re.IGNORECASE,
    )
    for match in pattern.finditer(compact_html):
        award_id = str(match.group(1) or "").strip()
        award_name = re.sub(r"\s+", " ", str(match.group(2) or "").strip())
        logo_url = str(match.group(3) or "").strip()
        if not award_id or not logo_url:
            continue
        if logo_url.startswith("/"):
            logo_url = f"https://www.themoviedb.org{logo_url}"
        logo_map[award_id] = {
            "awardName": award_name,
            "logoUrl": logo_url,
        }
    return logo_map


def _fetch_omdb_awards(*, imdb_id: str) -> Optional[dict]:
    if not imdb_id:
        return None

    resolver_result = _fetch_omdb_awards_via_resolver(imdb_id=imdb_id)
    if resolver_result is not None and resolver_result.get("awardsText"):
        return resolver_result

    omdb_api_key = os.getenv(_OMDB_API_KEY_ENV, "").strip()
    if not omdb_api_key:
        return None

    try:
        response = requests.get(
            _OMDB_BASE_URL,
            timeout=10,
            params={"apikey": omdb_api_key, "i": imdb_id},
            headers={"Accept": "application/json"},
        )
        if response.status_code >= 400:
            return None
        payload = response.json()
    except Exception:
        return None

    if str(payload.get("Response") or "").strip().lower() == "false":
        return None

    awards = str(payload.get("Awards") or "").strip()
    if not awards or awards.lower() == "n/a":
        return None

    wins = _extract_numeric_awards(awards, r"(\d+)\s+wins?")
    nominations = _extract_numeric_awards(awards, r"(\d+)\s+nominations?")
    detail_lines = [
        part.strip()
        for part in awards.split(".")
        if part.strip() and part.strip().lower() != "n/a"
    ]
    return {
        "awardsText": awards,
        "totalWins": wins,
        "totalNominations": nominations,
        "detailLines": detail_lines,
    }


def _fetch_omdb_awards_via_resolver(*, imdb_id: str) -> Optional[dict]:
    try:
        response = requests.get(
            _OMDB_RESOLVER_URL,
            timeout=12,
            params={"imdbId": imdb_id, "mode": "details"},
            headers={"Accept": "application/json"},
        )
        if response.status_code >= 400:
            return None
        payload = response.json()
    except Exception:
        return None

    data = payload.get("data") if isinstance(payload, dict) else None
    if not isinstance(data, dict):
        return None
    if str(data.get("Response") or "").strip().lower() == "false":
        return None

    awards = str(data.get("Awards") or "").strip()
    if not awards or awards.lower() == "n/a":
        return None

    wins = _extract_numeric_awards(awards, r"(\d+)\s+wins?")
    nominations = _extract_numeric_awards(awards, r"(\d+)\s+nominations?")
    detail_lines = [
        part.strip()
        for part in awards.split(".")
        if part.strip() and part.strip().lower() != "n/a"
    ]
    return {
        "awardsText": awards,
        "totalWins": wins,
        "totalNominations": nominations,
        "detailLines": detail_lines,
    }


def _extract_numeric_awards(text: str, pattern: str) -> int:
    total = 0
    for match in re.finditer(pattern, text, flags=re.IGNORECASE):
        total += int(match.group(1))
    return total


def _read_cache_entry(cache_key: str) -> Optional[dict]:
    now = int(time.time())
    try:
        snapshot = (
            _firestore_client.collection(_CACHE_COLLECTION).document(cache_key).get()
        )
    except Exception:
        return None

    if not snapshot.exists:
        return None

    data = snapshot.to_dict() or {}
    expires_at = int(data.get("expiresAt") or 0)
    if expires_at <= now:
        try:
            snapshot.reference.delete()
        except Exception:
            pass
        return None
    return data


def _write_cache_entry(
    *,
    cache_key: str,
    justwatch_url: str,
    normalized_provider: str,
    status: str,
    resolved_url: str,
    source: str,
) -> None:
    now = int(time.time())
    ttl_seconds = _CACHE_HIT_TTL_SECONDS if status == "ok" else _CACHE_MISS_TTL_SECONDS
    payload = {
        "justwatchUrl": justwatch_url,
        "provider": normalized_provider,
        "status": status,
        "resolvedUrl": resolved_url,
        "source": source,
        "updatedAt": now,
        "expiresAt": now + ttl_seconds,
    }
    try:
        _firestore_client.collection(_CACHE_COLLECTION).document(cache_key).set(payload)
    except Exception:
        # Cache failures should never block primary resolution.
        return


def _cache_stats_payload() -> dict:
    now = int(time.time())
    collection = _firestore_client.collection(_CACHE_COLLECTION)
    total = _count_query(collection)
    active_docs = _stream_dicts(collection.where("expiresAt", ">", now))
    active = len(active_docs)
    expired = _count_query(collection.where("expiresAt", "<=", now))
    active_ok = sum(1 for doc in active_docs if str(doc.get("status") or "") == "ok")
    active_not_found = sum(
        1 for doc in active_docs if str(doc.get("status") or "") == "not_found"
    )
    return {
        "collection": _CACHE_COLLECTION,
        "now": now,
        "ttlSeconds": {
            "hit": _CACHE_HIT_TTL_SECONDS,
            "miss": _CACHE_MISS_TTL_SECONDS,
        },
        "counts": {
            "total": total,
            "active": active,
            "expired": expired,
            "active_ok": active_ok,
            "active_not_found": active_not_found,
        },
    }


def _cleanup_expired_cache(*, limit: int, dry_run: bool) -> dict:
    now = int(time.time())
    query = (
        _firestore_client.collection(_CACHE_COLLECTION)
        .where("expiresAt", "<=", now)
        .limit(limit)
    )
    docs = list(query.stream())
    deleted = 0
    if not dry_run and docs:
        batch = _firestore_client.batch()
        for doc in docs:
            batch.delete(doc.reference)
            deleted += 1
        batch.commit()

    remaining_expired = _count_query(
        _firestore_client.collection(_CACHE_COLLECTION).where("expiresAt", "<=", now),
    )
    return {
        "collection": _CACHE_COLLECTION,
        "now": now,
        "dryRun": dry_run,
        "limit": limit,
        "matched": len(docs),
        "deleted": 0 if dry_run else deleted,
        "hasMoreExpired": remaining_expired > 0,
        "remainingExpired": remaining_expired,
    }


def _count_query(query_or_collection) -> int:
    count = 0
    try:
        for _ in query_or_collection.stream():
            count += 1
    except Exception:
        return 0
    return count


def _stream_dicts(query_or_collection) -> list[dict]:
    docs: list[dict] = []
    try:
        for snap in query_or_collection.stream():
            docs.append(snap.to_dict() or {})
    except Exception:
        return []
    return docs


def _is_allowed_justwatch_url(value: str) -> bool:
    try:
        parsed = urlparse(value)
    except Exception:
        return False
    if parsed.scheme not in {"https", "http"}:
        return False
    host = (parsed.netloc or "").lower()
    return any(host == suffix or host.endswith(f".{suffix}") for suffix in _ALLOWED_HOST_SUFFIXES)


def _is_allowed_input_url(value: str) -> bool:
    return _is_allowed_justwatch_url(value)


def _normalize_to_justwatch_url(source_url: str) -> Optional[str]:
    if _is_justwatch_url(source_url):
        return source_url.strip()
    if _is_tmdb_url(source_url):
        return _derive_justwatch_url_from_tmdb_watch_link(source_url)
    return None


def _justwatch_page_candidates(
    justwatch_url: str,
    preferred_region_code: Optional[str] = None,
) -> list[str]:
    primary = str(justwatch_url or "").strip()
    candidates: list[str] = []
    if primary:
        candidates.append(primary)

    preferred_fallback = _replace_justwatch_region(
        primary,
        preferred_region_code or "",
    )
    if preferred_fallback and preferred_fallback not in candidates:
        candidates.append(preferred_fallback)

    us_fallback = _replace_justwatch_region(primary, "us")
    if us_fallback and us_fallback not in candidates:
        candidates.append(us_fallback)

    return candidates


def _resolver_fallback_url(
    page_candidates: list[str],
    default_url: str,
) -> str:
    for candidate in reversed(page_candidates):
        if _is_justwatch_url(candidate):
            return candidate
    return default_url


def _replace_justwatch_region(justwatch_url: str, region_code: str) -> Optional[str]:
    try:
        parsed = urlparse(justwatch_url)
    except Exception:
        return None
    if not _is_justwatch_url(justwatch_url):
        return None

    path_parts = [part for part in (parsed.path or "").split("/") if part]
    if len(path_parts) < 3:
        return None
    if not re.fullmatch(r"[a-z]{2}", path_parts[0].lower()):
        return None

    path_parts[0] = region_code.lower()
    query = f"?{parsed.query}" if parsed.query else ""
    return f"{parsed.scheme}://{parsed.netloc}/{'/'.join(path_parts)}{query}"


def _normalize_region_code(value: object) -> Optional[str]:
    region_code = str(value or "").strip().lower()
    if not re.fullmatch(r"[a-z]{2}", region_code):
        return None
    return region_code


def _is_justwatch_url(value: str) -> bool:
    try:
        host = (urlparse(value).netloc or "").lower()
    except Exception:
        return False
    return host == "justwatch.com" or host.endswith(".justwatch.com")


def _is_tmdb_url(value: str) -> bool:
    try:
        host = (urlparse(value).netloc or "").lower()
    except Exception:
        return False
    return host == "themoviedb.org" or host.endswith(".themoviedb.org")


def _derive_justwatch_url_from_tmdb_watch_link(tmdb_watch_url: str) -> Optional[str]:
    try:
        parsed = urlparse(tmdb_watch_url)
    except Exception:
        return None

    match = re.match(r"^/(movie|tv)/(\d+)(?:-([^/]+))?/watch/?$", parsed.path or "")
    if not match:
        return None

    media_kind = match.group(1)
    media_id = match.group(2)
    path_slug = str(match.group(3) or "").strip()
    if not path_slug:
        path_slug = _TMDB_WATCH_SLUG_OVERRIDES.get(f"{media_kind}:{media_id}", "")
    media_type_paths = _justwatch_media_type_paths(media_kind)

    query = parse_qs(parsed.query)
    country_code = _tmdb_locale_to_country(query)
    preferred_language = _tmdb_preferred_language(query)
    preferred_locale = _tmdb_preferred_locale(query)
    title_candidates = _title_candidates_from_slug(path_slug)
    release_year = _release_year_from_slug(path_slug)
    if not title_candidates:
        title_candidates, release_year = _tmdb_title_candidates_and_year(
            media_kind=media_kind,
            media_id=media_id,
            preferred_language=preferred_language,
            preferred_locale=preferred_locale,
        )
    if not title_candidates:
        return None

    fallback_url: Optional[str] = None
    for title in title_candidates:
        slug = _slugify(title)
        if not slug:
            continue
        for media_type_path in media_type_paths:
            base_url = f"https://www.justwatch.com/{country_code}/{media_type_path}/{slug}"
            if fallback_url is None:
                fallback_url = base_url
            candidate_years = _candidate_release_years(release_year=release_year, slug=slug)
            for candidate_year in candidate_years:
                if not candidate_year:
                    continue
                with_year = f"{base_url}-{candidate_year}"
                if _url_exists(with_year):
                    return with_year
            if _url_exists(base_url):
                return base_url
    return fallback_url


def _tmdb_title_candidates_and_year(
    *,
    media_kind: str,
    media_id: str,
    preferred_language: Optional[str] = None,
    preferred_locale: Optional[str] = None,
) -> tuple[list[str], Optional[str]]:
    proxy_base = os.getenv(_TMDB_PROXY_BASE_URL_ENV, _TMDB_PROXY_BASE_URL_DEFAULT).rstrip("/")
    endpoint = f"{proxy_base}/{media_kind}/{media_id}"
    params = {"language": preferred_locale} if preferred_locale else None
    try:
        response = requests.get(
            endpoint,
            timeout=8,
            params=params,
            headers={"Accept": "application/json"},
        )
        response.raise_for_status()
        payload = response.json()
    except Exception:
        if preferred_locale:
            try:
                response = requests.get(
                    endpoint,
                    timeout=8,
                    headers={"Accept": "application/json"},
                )
                response.raise_for_status()
                payload = response.json()
            except Exception:
                return [], None
        else:
            return [], None

    if media_kind == "movie":
        primary_title = str(payload.get("title") or "").strip()
        original_title = str(payload.get("original_title") or "").strip()
        date_value = str(payload.get("release_date") or "").strip()
    else:
        primary_title = str(payload.get("name") or "").strip()
        original_title = str(payload.get("original_name") or "").strip()
        date_value = str(payload.get("first_air_date") or "").strip()

    translation_titles = _tmdb_translation_titles(
        media_kind=media_kind,
        media_id=media_id,
        preferred_language=preferred_language,
    )

    candidates: list[str] = []
    seen: set[str] = set()
    for raw in [primary_title, original_title, *translation_titles]:
        title = str(raw or "").strip()
        if not title:
            continue
        key = title.lower()
        if key in seen:
            continue
        seen.add(key)
        candidates.append(title)

    year_match = re.match(r"^(\d{4})", date_value)
    return candidates, (year_match.group(1) if year_match else None)


def _title_candidates_from_slug(slug: str) -> list[str]:
    cleaned = re.sub(r"-+", "-", str(slug or "").strip().strip("-").lower())
    if not cleaned:
        return []

    candidates = [cleaned.replace("-", " ")]
    without_year = re.sub(r"-(19|20)\d{2}$", "", cleaned).strip("-")
    if without_year and without_year != cleaned:
        candidates.append(without_year.replace("-", " "))
    return candidates


def _release_year_from_slug(slug: str) -> Optional[str]:
    match = re.search(r"-(19|20)\d{2}$", str(slug or "").strip().lower())
    if not match:
        return None
    return match.group(0).strip("-")


def _candidate_release_years(*, release_year: Optional[str], slug: str) -> list[str]:
    years: list[str] = []
    if release_year:
        years.append(release_year)
    slug_year_match = re.search(r"-(19|20)\d{2}$", slug)
    if slug_year_match:
        slug_year = slug_year_match.group(0).strip("-")
        if slug_year not in years:
            years.append(slug_year)
    return years


def _tmdb_translation_titles(
    *,
    media_kind: str,
    media_id: str,
    preferred_language: Optional[str] = None,
) -> list[str]:
    proxy_base = os.getenv(_TMDB_PROXY_BASE_URL_ENV, _TMDB_PROXY_BASE_URL_DEFAULT).rstrip("/")
    endpoint = f"{proxy_base}/{media_kind}/{media_id}/translations"
    try:
        response = requests.get(
            endpoint,
            timeout=8,
            headers={"Accept": "application/json"},
        )
        response.raise_for_status()
        payload = response.json()
    except Exception:
        return []

    translations = payload.get("translations")
    if not isinstance(translations, list):
        return []

    preferred: list[str] = []
    others: list[str] = []

    for item in translations:
        if not isinstance(item, dict):
            continue
        data = item.get("data")
        if not isinstance(data, dict):
            continue
        title = str(data.get("title") or data.get("name") or "").strip()
        if not title:
            continue
        lang = str(item.get("iso_639_1") or "").strip().lower()
        if preferred_language and lang == preferred_language.lower():
            preferred.append(title)
        else:
            others.append(title)

    return preferred + others


def _tmdb_locale_to_country(query: dict[str, list[str]]) -> str:
    locale = str((query.get("locale") or [""])[0]).strip()
    language = str((query.get("language") or [""])[0]).strip()

    if len(locale) == 2:
        return locale.lower()
    if locale and "-" in locale:
        suffix = locale.rsplit("-", 1)[-1]
        if len(suffix) == 2 and suffix.isalpha():
            return suffix.lower()

    if language and "-" in language:
        suffix = language.rsplit("-", 1)[-1]
        if len(suffix) == 2 and suffix.isalpha():
            return suffix.lower()

    return "us"


def _tmdb_preferred_language(query: dict[str, list[str]]) -> Optional[str]:
    language = str((query.get("language") or [""])[0]).strip().lower()
    locale = str((query.get("locale") or [""])[0]).strip().lower()

    if len(language) == 2 and language.isalpha():
        return language
    if language and "-" in language:
        prefix = language.split("-", 1)[0]
        if len(prefix) == 2 and prefix.isalpha():
            return prefix
    if locale and "-" in locale:
        prefix = locale.split("-", 1)[0]
        if len(prefix) == 2 and prefix.isalpha():
            return prefix
    return None


def _tmdb_preferred_locale(query: dict[str, list[str]]) -> Optional[str]:
    locale = str((query.get("locale") or [""])[0]).strip()
    language = str((query.get("language") or [""])[0]).strip()

    if locale and "-" in locale:
        return locale
    if language and "-" in language:
        return language
    return None


def _justwatch_media_type_paths(media_kind: str) -> list[str]:
    if media_kind == "movie":
        return ["movie", "film", "Film"]
    return ["tv-show", "show", "serie", "Serie"]


def _slugify(text: str) -> str:
    normalized = unicodedata.normalize("NFKD", text)
    ascii_text = normalized.encode("ascii", "ignore").decode("ascii")
    cleaned = (
        ascii_text.lower()
        .strip()
        .replace("&", " and ")
        .replace("'", "")
        .replace(":", " ")
        .replace(".", " ")
        .replace("/", " ")
        .replace("_", " ")
        .replace("+", " ")
        .replace("(", " ")
        .replace(")", " ")
    )
    cleaned = re.sub(r"[^a-z0-9\s-]", " ", cleaned)
    cleaned = re.sub(r"\s+", "-", cleaned)
    cleaned = re.sub(r"-+", "-", cleaned)
    return cleaned.strip("-")


def _url_exists(url: str) -> bool:
    try:
        head = requests.head(
            url,
            timeout=5,
            allow_redirects=True,
            headers={"User-Agent": "Mozilla/5.0"},
        )
        if 200 <= head.status_code < 400:
            return True
        if head.status_code == 405:
            get = requests.get(
                url,
                timeout=6,
                allow_redirects=True,
                headers={"User-Agent": "Mozilla/5.0"},
            )
            return 200 <= get.status_code < 400
        return False
    except Exception:
        return False


def _is_cacheable_provider_url(url: str) -> bool:
    try:
        parsed = urlparse(url.strip())
    except Exception:
        return False
    host = (parsed.netloc or "").strip().lower()
    if not host:
        return False
    blocked_hosts = {
        "justwatch.com",
        "www.justwatch.com",
        "themoviedb.org",
        "www.themoviedb.org",
    }
    return host not in blocked_hosts


def _resolve_from_json_ld(page_html: str, provider_aliases: set[str]) -> Optional[str]:
    for script_body in _extract_ld_json_scripts(page_html):
        try:
            parsed = json.loads(html.unescape(script_body))
        except json.JSONDecodeError:
            continue
        for node in _iter_json_nodes(parsed):
            potential_actions = node.get("potentialAction")
            if isinstance(potential_actions, dict):
                potential_actions = [potential_actions]
            if not isinstance(potential_actions, list):
                continue
            for action in potential_actions:
                if not isinstance(action, dict):
                    continue
                offer = action.get("expectsAcceptanceOf")
                if not isinstance(offer, dict):
                    continue
                offered_by = offer.get("offeredBy")
                provider = ""
                if isinstance(offered_by, dict):
                    provider = str(offered_by.get("name") or "")
                if not provider:
                    continue
                if _normalize_provider_name(provider) not in provider_aliases:
                    continue
                target = action.get("target")
                if isinstance(target, dict):
                    url = str(target.get("urlTemplate") or target.get("url") or "").strip()
                else:
                    url = str(target or "").strip()
                if url:
                    return html.unescape(url)
    return None


def _resolve_from_embedded_state(page_html: str, provider_aliases: set[str]) -> Optional[str]:
    normalized_html = html.unescape(page_html)
    # Scan in local windows to avoid full JSON parse of huge blobs.
    for alias in provider_aliases:
        pattern = re.compile(rf'"clearName":"{re.escape(alias)}"', re.IGNORECASE)
        for match in pattern.finditer(normalized_html):
            start = max(0, match.start() - 2500)
            end = min(len(normalized_html), match.end() + 4500)
            window = normalized_html[start:end]
            url_match = re.search(r'"standardWebURL":"(https:[^"]+)"', window)
            if url_match:
                return _decode_js_string(url_match.group(1))
    return None


def _extract_ld_json_scripts(page_html: str) -> Iterable[str]:
    pattern = re.compile(
        r'<script[^>]+type=["\']application/ld\+json["\'][^>]*>(.*?)</script>',
        flags=re.IGNORECASE | re.DOTALL,
    )
    for match in pattern.finditer(page_html):
        yield match.group(1).strip()


def _iter_json_nodes(value: object) -> Iterable[dict]:
    if isinstance(value, dict):
        yield value
        for nested in value.values():
            yield from _iter_json_nodes(nested)
    elif isinstance(value, list):
        for item in value:
            yield from _iter_json_nodes(item)


def _normalize_provider_name(value: str) -> str:
    return re.sub(r"[^a-z0-9+]+", " ", value.lower()).strip()


def _provider_aliases(normalized_provider: str) -> set[str]:
    aliases: set[str] = {normalized_provider}
    for canonical, variants in _PROVIDER_ALIASES.items():
        canonical_norm = _normalize_provider_name(canonical)
        variants_norm = {_normalize_provider_name(v) for v in variants}
        if normalized_provider == canonical_norm or normalized_provider in variants_norm:
            aliases.add(canonical_norm)
            aliases.update(variants_norm)
    return aliases


def _decode_js_string(value: str) -> str:
    return (
        value.replace("\\u002F", "/")
        .replace("\\/", "/")
        .replace("\\u003D", "=")
        .replace("\\u0026", "&")
    )


def _json_response(status: int, payload: dict) -> https_fn.Response:
    return https_fn.Response(
        response=json.dumps(payload, ensure_ascii=False),
        status=status,
        mimetype="application/json",
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": (
                "Content-Type, Authorization, X-Cache-Admin-Key"
            ),
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        },
    )
