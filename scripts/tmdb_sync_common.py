#!/usr/bin/env python3
from __future__ import annotations

import csv
import datetime as dt
import gzip
import json
import logging
import random
import sqlite3
import sys
import time
from pathlib import Path
from typing import Any, Dict, Iterable, Iterator, List, Optional

import requests

LOGGER = logging.getLogger("tmdb_sync")
CONFIG_PATH = Path("config/api_keys.json")
DEFAULT_EXPORT_BASE = "https://files.tmdb.org/p/exports"

MOVIE_HEADERS = [
    "id",
    "title",
    "vote_average",
    "vote_count",
    "status",
    "release_date",
    "revenue",
    "runtime",
    "adult",
    "backdrop_path",
    "budget",
    "homepage",
    "imdb_id",
    "original_language",
    "original_title",
    "overview",
    "popularity",
    "poster_path",
    "tagline",
    "genres",
    "production_companies",
    "production_countries",
    "spoken_languages",
    "keywords",
]

TV_HEADERS = [
    "id",
    "name",
    "vote_average",
    "vote_count",
    "status",
    "first_air_date",
    "last_air_date",
    "number_of_seasons",
    "number_of_episodes",
    "episode_run_time",
    "adult",
    "backdrop_path",
    "homepage",
    "in_production",
    "languages",
    "origin_country",
    "original_language",
    "original_name",
    "overview",
    "popularity",
    "poster_path",
    "tagline",
    "genres",
    "production_companies",
    "production_countries",
    "spoken_languages",
    "keywords",
    "type",
]


def configure_logging(level_name: str = "INFO") -> None:
    level = getattr(logging, level_name.upper(), logging.INFO)
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def load_config() -> dict:
    if not CONFIG_PATH.exists():
        return {}
    try:
        return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {}


def today_utc() -> dt.date:
    return dt.datetime.now(dt.timezone.utc).date()


def parse_date(text: str) -> dt.date:
    return dt.datetime.strptime(text, "%Y-%m-%d").date()


def date_range(start: dt.date, end: dt.date) -> Iterator[dt.date]:
    cur = start
    while cur <= end:
        yield cur
        cur = cur + dt.timedelta(days=1)


def latest_date_from_csv(
    *,
    csv_path: Path,
    date_columns: List[str],
) -> Optional[dt.date]:
    if not csv_path.exists():
        return None
    csv.field_size_limit(sys.maxsize)
    latest: Optional[dt.date] = None
    with csv_path.open("r", encoding="utf-8", errors="replace", newline="") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            for col in date_columns:
                raw = clean(row.get(col))
                if not raw or len(raw) < 10:
                    continue
                text = raw[:10]
                try:
                    d = parse_date(text)
                except Exception:
                    continue
                if latest is None or d > latest:
                    latest = d
    return latest


class TMDBClient:
    def __init__(
        self,
        *,
        base_url: str,
        api_key: str = "",
        bearer_token: str = "",
        max_rps: float = 15.0,
        timeout_seconds: float = 25.0,
        retries: int = 6,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key.strip()
        self.bearer_token = bearer_token.strip()
        self.max_rps = max(0.1, float(max_rps))
        self.timeout_seconds = timeout_seconds
        self.retries = max(1, retries)
        self._last_request_started = 0.0

    def get_json(self, path: str, *, params: Optional[dict] = None) -> Optional[dict]:
        url = f"{self.base_url}/{path.lstrip('/')}"
        req_params = dict(params or {})
        headers = {"Accept": "application/json"}
        if self.bearer_token:
            headers["Authorization"] = f"Bearer {self.bearer_token}"
        elif self.api_key:
            req_params.setdefault("api_key", self.api_key)

        for attempt in range(1, self.retries + 1):
            self._throttle()
            try:
                response = requests.get(
                    url,
                    params=req_params,
                    headers=headers,
                    timeout=self.timeout_seconds,
                )
            except requests.RequestException as error:
                if attempt >= self.retries:
                    raise RuntimeError(f"Request failed for {url}: {error}") from error
                delay = self._retry_delay(attempt)
                LOGGER.warning(
                    "Request error for %s (attempt %s/%s): %s. Retrying in %.1fs",
                    url,
                    attempt,
                    self.retries,
                    error,
                    delay,
                )
                time.sleep(delay)
                continue

            if response.status_code in (401, 403):
                raise RuntimeError(
                    f"Auth failure for {url}: HTTP {response.status_code}. "
                    "Set TMDB_BEARER_TOKEN or TMDB_API_KEY (unless your proxy handles auth)."
                )
            if response.status_code == 404:
                return None
            if response.status_code == 429:
                retry_after = self._retry_after(response)
                delay = retry_after if retry_after is not None else self._retry_delay(attempt)
                LOGGER.warning(
                    "Rate limited (429) for %s. Waiting %.1fs (attempt %s/%s).",
                    url,
                    delay,
                    attempt,
                    self.retries,
                )
                if attempt >= self.retries:
                    raise RuntimeError(f"Rate limited repeatedly for {url}")
                time.sleep(delay)
                continue
            if response.status_code >= 500:
                if attempt >= self.retries:
                    raise RuntimeError(
                        f"Server error for {url}: HTTP {response.status_code} {response.text[:300]}"
                    )
                delay = self._retry_delay(attempt)
                LOGGER.warning(
                    "Server error for %s (HTTP %s). Retrying in %.1fs (attempt %s/%s).",
                    url,
                    response.status_code,
                    delay,
                    attempt,
                    self.retries,
                )
                time.sleep(delay)
                continue
            if response.status_code >= 400:
                raise RuntimeError(
                    f"Client error for {url}: HTTP {response.status_code} {response.text[:300]}"
                )

            try:
                return response.json()
            except Exception as error:
                if attempt >= self.retries:
                    raise RuntimeError(
                        f"Invalid JSON response from {url}: {error}"
                    ) from error
                delay = self._retry_delay(attempt)
                LOGGER.warning(
                    "Invalid JSON for %s. Retrying in %.1fs (attempt %s/%s).",
                    url,
                    delay,
                    attempt,
                    self.retries,
                )
                time.sleep(delay)

        return None

    def _throttle(self) -> None:
        min_interval = 1.0 / self.max_rps
        now = time.monotonic()
        elapsed = now - self._last_request_started
        if elapsed < min_interval:
            time.sleep(min_interval - elapsed)
        self._last_request_started = time.monotonic()

    @staticmethod
    def _retry_delay(attempt: int) -> float:
        return min(60.0, (2 ** (attempt - 1)) + random.uniform(0.0, 0.5))

    @staticmethod
    def _retry_after(response: requests.Response) -> Optional[float]:
        raw = response.headers.get("Retry-After", "").strip()
        if not raw:
            return None
        try:
            return float(raw)
        except ValueError:
            return None


def fetch_tmdb_export_ids(
    *,
    media_type: str,
    export_base_url: str = DEFAULT_EXPORT_BASE,
    lookback_days: int = 21,
    cache_dir: Path,
) -> List[int]:
    if media_type not in {"movie", "tv_series"}:
        raise ValueError("media_type must be 'movie' or 'tv_series'")

    cache_dir.mkdir(parents=True, exist_ok=True)
    today = today_utc()
    for offset in range(0, max(1, lookback_days)):
        day = today - dt.timedelta(days=offset)
        file_name = f"{media_type}_ids_{day:%m_%d_%Y}.json.gz"
        local = cache_dir / file_name
        if not local.exists():
            url = f"{export_base_url.rstrip('/')}/{file_name}"
            LOGGER.info("Trying export: %s", url)
            response = requests.get(url, timeout=60)
            if response.status_code == 404:
                continue
            response.raise_for_status()
            local.write_bytes(response.content)
            LOGGER.info("Downloaded export to %s (%.1f MB)", local, local.stat().st_size / (1024 * 1024))

        ids = _parse_export_ids(local)
        if ids:
            LOGGER.info(
                "Loaded %s ids from export %s",
                len(ids),
                local.name,
            )
            return ids
    raise RuntimeError(
        f"Could not find a valid {media_type} export in last {lookback_days} day(s)."
    )


def _parse_export_ids(path: Path) -> List[int]:
    ids: List[int] = []
    seen: set[int] = set()
    with gzip.open(path, "rt", encoding="utf-8", errors="replace") as handle:
        for line in handle:
            line = line.strip()
            if not line:
                continue
            try:
                payload = json.loads(line)
            except Exception:
                continue
            raw_id = payload.get("id")
            if not isinstance(raw_id, int):
                continue
            if raw_id <= 0 or raw_id in seen:
                continue
            seen.add(raw_id)
            ids.append(raw_id)
    return ids


def maybe_bool(value: Any) -> str:
    if value is True:
        return "True"
    if value is False:
        return "False"
    return ""


def clean(value: Any) -> str:
    if value is None:
        return ""
    return str(value).strip()


def csv_list(values: Any, *, key: Optional[str] = None) -> str:
    if not isinstance(values, list):
        return ""
    out: List[str] = []
    seen: set[str] = set()
    for item in values:
        if key is None:
            raw = clean(item)
        elif isinstance(item, dict):
            raw = clean(item.get(key))
        else:
            raw = ""
        if not raw:
            continue
        lowered = raw.lower()
        if lowered in seen:
            continue
        seen.add(lowered)
        out.append(raw)
    return ", ".join(out)


def movie_row_from_details(details: dict) -> dict:
    keywords = []
    k = details.get("keywords")
    if isinstance(k, dict) and isinstance(k.get("keywords"), list):
        keywords = k.get("keywords", [])
    elif isinstance(k, list):
        keywords = k
    return {
        "id": str(details.get("id", "")),
        "title": clean(details.get("title")),
        "vote_average": clean(details.get("vote_average")),
        "vote_count": clean(details.get("vote_count")),
        "status": clean(details.get("status")),
        "release_date": clean(details.get("release_date")),
        "revenue": clean(details.get("revenue")),
        "runtime": clean(details.get("runtime")),
        "adult": maybe_bool(details.get("adult")),
        "backdrop_path": clean(details.get("backdrop_path")),
        "budget": clean(details.get("budget")),
        "homepage": clean(details.get("homepage")),
        "imdb_id": clean(details.get("imdb_id")),
        "original_language": clean(details.get("original_language")),
        "original_title": clean(details.get("original_title")),
        "overview": clean(details.get("overview")),
        "popularity": clean(details.get("popularity")),
        "poster_path": clean(details.get("poster_path")),
        "tagline": clean(details.get("tagline")),
        "genres": csv_list(details.get("genres"), key="name"),
        "production_companies": csv_list(details.get("production_companies"), key="name"),
        "production_countries": csv_list(details.get("production_countries"), key="name"),
        "spoken_languages": csv_list(details.get("spoken_languages"), key="english_name"),
        "keywords": csv_list(keywords, key="name"),
    }


def tv_row_from_details(details: dict) -> dict:
    keywords = []
    k = details.get("keywords")
    if isinstance(k, dict):
        keywords = k.get("results") or k.get("keywords") or []
    elif isinstance(k, list):
        keywords = k
    run_times = details.get("episode_run_time") if isinstance(details.get("episode_run_time"), list) else []
    runtime_text = ", ".join(str(x) for x in run_times if str(x).strip())
    return {
        "id": str(details.get("id", "")),
        "name": clean(details.get("name")),
        "vote_average": clean(details.get("vote_average")),
        "vote_count": clean(details.get("vote_count")),
        "status": clean(details.get("status")),
        "first_air_date": clean(details.get("first_air_date")),
        "last_air_date": clean(details.get("last_air_date")),
        "number_of_seasons": clean(details.get("number_of_seasons")),
        "number_of_episodes": clean(details.get("number_of_episodes")),
        "episode_run_time": runtime_text,
        "adult": maybe_bool(details.get("adult")),
        "backdrop_path": clean(details.get("backdrop_path")),
        "homepage": clean(details.get("homepage")),
        "in_production": maybe_bool(details.get("in_production")),
        "languages": csv_list(details.get("languages")),
        "origin_country": csv_list(details.get("origin_country")),
        "original_language": clean(details.get("original_language")),
        "original_name": clean(details.get("original_name")),
        "overview": clean(details.get("overview")),
        "popularity": clean(details.get("popularity")),
        "poster_path": clean(details.get("poster_path")),
        "tagline": clean(details.get("tagline")),
        "genres": csv_list(details.get("genres"), key="name"),
        "production_companies": csv_list(details.get("production_companies"), key="name"),
        "production_countries": csv_list(details.get("production_countries"), key="name"),
        "spoken_languages": csv_list(details.get("spoken_languages"), key="english_name"),
        "keywords": csv_list(keywords, key="name"),
        "type": clean(details.get("type")),
    }


def ensure_sqlite_table(conn: sqlite3.Connection, table_name: str) -> None:
    conn.execute(
        f"""
        CREATE TABLE IF NOT EXISTS {table_name} (
          id INTEGER PRIMARY KEY,
          row_json TEXT NOT NULL
        )
        """
    )
    conn.commit()


def load_csv_to_sqlite(
    *,
    csv_path: Path,
    headers: List[str],
    conn: sqlite3.Connection,
    table_name: str,
    log_every: int = 100000,
) -> set[int]:
    existing_ids: set[int] = set()
    if not csv_path.exists():
        return existing_ids
    csv.field_size_limit(sys.maxsize)
    with csv_path.open("r", encoding="utf-8", errors="replace", newline="") as handle:
        reader = csv.DictReader(handle)
        batch: List[tuple[int, str]] = []
        for index, row in enumerate(reader, start=1):
            raw_id = clean(row.get("id"))
            try:
                row_id = int(float(raw_id))
            except Exception:
                continue
            canonical = {h: clean(row.get(h)) for h in headers}
            batch.append((row_id, json.dumps(canonical, ensure_ascii=False)))
            existing_ids.add(row_id)
            if len(batch) >= 2000:
                conn.executemany(
                    f"INSERT OR REPLACE INTO {table_name} (id, row_json) VALUES (?, ?)",
                    batch,
                )
                conn.commit()
                batch = []
            if log_every > 0 and index % log_every == 0:
                LOGGER.info("Loaded %s existing rows from %s", index, csv_path)
        if batch:
            conn.executemany(
                f"INSERT OR REPLACE INTO {table_name} (id, row_json) VALUES (?, ?)",
                batch,
            )
            conn.commit()
    return existing_ids


def upsert_row_sqlite(
    *,
    conn: sqlite3.Connection,
    table_name: str,
    row_id: int,
    row: dict,
) -> None:
    conn.execute(
        f"INSERT OR REPLACE INTO {table_name} (id, row_json) VALUES (?, ?)",
        (int(row_id), json.dumps(row, ensure_ascii=False)),
    )


def export_sqlite_to_csv(
    *,
    conn: sqlite3.Connection,
    table_name: str,
    headers: List[str],
    output_csv: Path,
    log_every: int = 200000,
) -> int:
    output_csv.parent.mkdir(parents=True, exist_ok=True)
    count = 0
    with output_csv.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=headers, quoting=csv.QUOTE_MINIMAL)
        writer.writeheader()
        cursor = conn.execute(f"SELECT row_json FROM {table_name} ORDER BY id ASC")
        for count, (row_json,) in enumerate(cursor, start=1):
            row = json.loads(row_json)
            normalized = {h: clean(row.get(h)) for h in headers}
            writer.writerow(normalized)
            if log_every > 0 and count % log_every == 0:
                LOGGER.info("Exported %s rows to %s", count, output_csv)
    return count


def load_checkpoint(path: Path) -> dict:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def save_checkpoint(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def progress_line(
    *,
    processed: int,
    total: Optional[int],
    started_at: float,
    prefix: str = "Progress",
) -> str:
    elapsed = max(0.001, time.time() - started_at)
    rate = processed / elapsed
    if total and total > 0:
        pct = (processed / total) * 100
        remaining = max(0, total - processed)
        eta_seconds = int(remaining / max(0.0001, rate))
        return (
            f"{prefix}: {processed}/{total} ({pct:.2f}%) | "
            f"{rate:.2f} items/s | ETA {format_duration(eta_seconds)}"
        )
    return f"{prefix}: {processed} | {rate:.2f} items/s | elapsed {format_duration(int(elapsed))}"


def format_duration(seconds: int) -> str:
    h, rem = divmod(max(0, int(seconds)), 3600)
    m, s = divmod(rem, 60)
    if h > 0:
        return f"{h}h {m}m {s}s"
    if m > 0:
        return f"{m}m {s}s"
    return f"{s}s"
