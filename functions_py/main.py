from __future__ import annotations

import html
import hashlib
import json
import os
import re
import time
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

_PROVIDER_ALIASES: dict[str, list[str]] = {
    "amazon prime video": ["prime video", "amazon prime video", "amazon video"],
    "apple tv+": ["apple tv+", "apple tv plus", "appletv+"],
    "disney plus": ["disney+", "disney plus"],
    "hbo max": ["hbo max", "max"],
    "paramount plus": ["paramount+", "paramount plus"],
    "youtube premium": ["youtube premium", "youtube movies"],
    "google play movies": ["google play", "google play movies"],
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

    if not source_url or not provider_name:
        return _json_response(
            400,
            {"error": "justwatchUrl and providerName are required."},
        )
    if not _is_allowed_input_url(source_url):
        return _json_response(400, {"error": "Invalid source URL."})

    normalized_provider = _normalize_provider_name(provider_name)
    provider_aliases = _provider_aliases(normalized_provider)
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

    cache_key = _build_cache_key(effective_justwatch_url, normalized_provider)

    cached = _read_cache_entry(cache_key)
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
            return _json_response(
                404,
                {
                    "error": "No provider-specific URL found on JustWatch page.",
                    "resolvedUrl": fallback_url,
                    "providerName": provider_name,
                    "source": "cache",
                },
            )

    try:
        response = requests.get(
            effective_justwatch_url,
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
        return _json_response(
            502,
            {"error": f"Failed to fetch JustWatch page: {exc}"},
        )

    resolved = _resolve_from_json_ld(page_html, provider_aliases)
    if resolved:
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
        justwatch_url=effective_justwatch_url,
        normalized_provider=normalized_provider,
        status="not_found",
        resolved_url="",
        source="none",
    )
    return _json_response(
        404,
        {
            "error": "No provider-specific URL found on JustWatch page.",
            "resolvedUrl": effective_justwatch_url,
            "providerName": provider_name,
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


def _build_cache_key(justwatch_url: str, normalized_provider: str) -> str:
    digest = hashlib.sha256(
        f"{justwatch_url.strip()}|{normalized_provider.strip()}".encode("utf-8"),
    ).hexdigest()
    return digest


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

    match = re.match(r"^/(movie|tv)/(\d+)(?:-[^/]+)?/watch/?$", parsed.path or "")
    if not match:
        return None

    media_kind = match.group(1)
    media_id = match.group(2)
    media_type_path = "movie" if media_kind == "movie" else "tv-show"

    query = parse_qs(parsed.query)
    country_code = _tmdb_locale_to_country(query)
    title, release_year = _tmdb_title_and_year(
        media_kind=media_kind,
        media_id=media_id,
    )
    if not title:
        return None

    slug = _slugify(title)
    if not slug:
        return None

    base_url = f"https://www.justwatch.com/{country_code}/{media_type_path}/{slug}"
    if release_year:
        with_year = f"{base_url}-{release_year}"
        if _url_exists(with_year):
            return with_year
    if _url_exists(base_url):
        return base_url
    return base_url


def _tmdb_title_and_year(*, media_kind: str, media_id: str) -> tuple[Optional[str], Optional[str]]:
    proxy_base = os.getenv(_TMDB_PROXY_BASE_URL_ENV, _TMDB_PROXY_BASE_URL_DEFAULT).rstrip("/")
    endpoint = f"{proxy_base}/{media_kind}/{media_id}"
    try:
        response = requests.get(
            endpoint,
            timeout=8,
            headers={"Accept": "application/json"},
        )
        response.raise_for_status()
        payload = response.json()
    except Exception:
        return None, None

    if media_kind == "movie":
        title = str(payload.get("title") or payload.get("original_title") or "").strip()
        date_value = str(payload.get("release_date") or "").strip()
    else:
        title = str(payload.get("name") or payload.get("original_name") or "").strip()
        date_value = str(payload.get("first_air_date") or "").strip()
    year_match = re.match(r"^(\d{4})", date_value)
    return (title or None, year_match.group(1) if year_match else None)


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


def _slugify(text: str) -> str:
    cleaned = (
        text.lower()
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


def _resolve_from_json_ld(page_html: str, provider_aliases: set[str]) -> Optional[str]:
    for script_body in _extract_ld_json_scripts(page_html):
        try:
            parsed = json.loads(html.unescape(script_body))
        except json.JSONDecodeError:
            continue
        for node in _iter_json_nodes(parsed):
            potential_actions = node.get("potentialAction")
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
    elif isinstance(value, list):
        for item in value:
            if isinstance(item, dict):
                yield item


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
