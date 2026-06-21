import 'dart:math';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/models/explore_models.dart';
import 'package:cineverse/presentation/features/movies/providers/explore_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _RecCacheKey = ({GlobalMediaType type, RecSource source});

final Map<_RecCacheKey, List<MediaTitle>> _libraryRecsCache = {};
final Map<_RecCacheKey, int> _libraryRecsLoadedPages = {};
final Map<_RecCacheKey, bool> _libraryRecsExhausted = {};
final Map<_RecCacheKey, int> _libraryRecsTargetPages = {};
final Map<_RecCacheKey, List<int>> _libraryRecsSampledIds = {};
/// Fingerprint of the sourceIds set used when the cache was last built.
/// If the library changes, the fingerprint changes and we clear the cache.
final Map<_RecCacheKey, String> _libraryRecsSourceFingerprint = {};

void loadNextLibraryRecsPage(WidgetRef ref, RecSource source) {
  final mediaType = ref.read(exploreMediaTypeProvider);
  final bool isTv = mediaType == ExploreMediaType.tv;
  final targetType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
  final _RecCacheKey key = (type: targetType, source: source);

  if (_libraryRecsExhausted[key] == true) return;

  _libraryRecsTargetPages[key] = (_libraryRecsTargetPages[key] ?? 1) + 1;
  ref.invalidate(libraryRecommendationsProvider(source));
}

void resetLibraryRecommendations(WidgetRef ref, RecSource source) {
  final mediaType = ref.read(exploreMediaTypeProvider);
  final bool isTv = mediaType == ExploreMediaType.tv;
  final targetType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
  final _RecCacheKey key = (type: targetType, source: source);

  _libraryRecsCache.remove(key);
  _libraryRecsLoadedPages.remove(key);
  _libraryRecsExhausted.remove(key);
  _libraryRecsTargetPages[key] = 1;
  _libraryRecsSampledIds.remove(key);
  _libraryRecsSourceFingerprint.remove(key);
  ref.invalidate(libraryRecommendationsProvider(source));
}

final libraryRecommendationsExhaustedProvider = Provider.family<bool, RecSource>((ref, source) {
  final mediaType = ref.watch(exploreMediaTypeProvider);
  final bool isTv = mediaType == ExploreMediaType.tv;
  final targetType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
  return _libraryRecsExhausted[(type: targetType, source: source)] ?? false;
});

final libraryRecommendationsProvider =
    FutureProvider.autoDispose.family<List<MediaTitle>, RecSource>((ref, source) async {
  final mediaType = ref.watch(exploreMediaTypeProvider);
  final bool isTv = mediaType == ExploreMediaType.tv;
  final targetType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
  final _RecCacheKey cacheKey = (type: targetType, source: source);

  // Watch providers to get library items
  final watchlistAsync = ref.watch(watchlistProvider);
  final watchedAsync = ref.watch(watchedItemsProvider);
  final favouritesAsync = ref.watch(favouritesProvider);
  final namedListsAsync = ref.watch(namedListsProvider);

  // If any are still loading for the first time, wait
  if (watchlistAsync.isLoading ||
      watchedAsync.isLoading ||
      favouritesAsync.isLoading ||
      namedListsAsync.isLoading) {
    return _libraryRecsCache[cacheKey] ?? const [];
  }

  final watchlist = watchlistAsync.value ?? [];
  final watched = watchedAsync.value ?? [];
  final favourites = favouritesAsync.value ?? [];
  final namedLists = namedListsAsync.value ?? [];

  final Set<int> sourceIds = {};

  if (source == RecSource.all || source == RecSource.watchlist) {
    for (final item in watchlist) {
      if (item.mediaType == targetType) sourceIds.add(item.id);
    }
  }
  if (source == RecSource.all || source == RecSource.watched) {
    for (final item in watched) {
      if (item.mediaType == targetType) sourceIds.add(item.id);
    }
  }
  if (source == RecSource.all || source == RecSource.favourites) {
    for (final item in favourites) {
      if (item.mediaType == targetType) sourceIds.add(item.id);
    }
  }
  if (source == RecSource.all || source == RecSource.lists) {
    for (final list in namedLists) {
      for (final item in list.items) {
        if (item.mediaType == targetType) sourceIds.add(item.mediaId);
      }
    }
  }

  if (sourceIds.isEmpty) {
    _libraryRecsCache[cacheKey] = [];
    _libraryRecsExhausted[cacheKey] = true;
    return const [];
  }

  // Build a fingerprint of the current source set. If the library changed
  // (item added or removed), the fingerprint won't match what was cached
  // so we clear the stale cache and start fresh.
  final String currentFingerprint =
      (sourceIds.toList()..sort()).join(',');
  if (_libraryRecsSourceFingerprint[cacheKey] != currentFingerprint) {
    _libraryRecsCache.remove(cacheKey);
    _libraryRecsLoadedPages.remove(cacheKey);
    _libraryRecsExhausted.remove(cacheKey);
    _libraryRecsTargetPages[cacheKey] = 1;
    _libraryRecsSampledIds.remove(cacheKey);
    _libraryRecsSourceFingerprint[cacheKey] = currentFingerprint;
  }

  final int targetPage = _libraryRecsTargetPages[cacheKey] ?? 1;
  int loadedPage = _libraryRecsLoadedPages[cacheKey] ?? 0;

  if (loadedPage >= targetPage) {
    return _libraryRecsCache[cacheKey] ?? [];
  }

  // Sample a subset of IDs if not already sampled for this session
  if (_libraryRecsSampledIds[cacheKey] == null ||
      _libraryRecsSampledIds[cacheKey]!.isEmpty) {
    final random = Random();
    final List<int> list = sourceIds.toList()..shuffle(random);
    _libraryRecsSampledIds[cacheKey] = list.take(5).toList();
  }
  final seeds = _libraryRecsSampledIds[cacheKey]!;

  final mediaRepo = ref.watch(mediaRepositoryProvider);
  final List<MediaTitle> results = List<MediaTitle>.from(
    _libraryRecsCache[cacheKey] ?? const <MediaTitle>[],
  );

  for (int p = loadedPage + 1; p <= targetPage; p++) {
    final Set<int> invalidSeedIds = <int>{};

    // Fetch recommendations for each sampled ID in parallel for the specific page
    final List<Future<List<MediaTitle>>> futures =
        seeds
            .map(
              (id) async {
                try {
                  final recs = await mediaRepo.fetchMovieRecommendations(
                    id,
                    isTv: isTv,
                    page: p,
                  );
                  return recs.map((r) => r.toMediaTitle()).toList();
                } catch (_) {
                  // Skip invalid/unavailable seed IDs (for example deleted TMDB titles)
                  // so one bad library item doesn't fail the entire recommendations rail.
                  invalidSeedIds.add(id);
                  return const <MediaTitle>[];
                }
              },
            )
            .toList();

    final List<List<MediaTitle>> resultsList = await Future.wait(futures);

    bool anyNewItemsOnThisPage = false;
    for (final pageResults in resultsList) {
      if (pageResults.isNotEmpty) anyNewItemsOnThisPage = true;
      for (final item in pageResults) {
        if (!sourceIds.contains(item.id)) {
          results.add(item);
        }
      }
    }

    _libraryRecsLoadedPages[cacheKey] = p;
    if (invalidSeedIds.isNotEmpty) {
      final List<int> filteredSeeds = _libraryRecsSampledIds[cacheKey]!
          .where((id) => !invalidSeedIds.contains(id))
          .toList();
      _libraryRecsSampledIds[cacheKey] = filteredSeeds;
    }
    if (!anyNewItemsOnThisPage) {
      _libraryRecsExhausted[cacheKey] = true;
      break;
    }
  }

  // De-duplicate results
  final Map<int, MediaTitle> uniqueRecommendations = {};
  for (final item in results) {
    uniqueRecommendations[item.id] = item;
  }

  final List<MediaTitle> finalResults = uniqueRecommendations.values.toList();
  _libraryRecsCache[cacheKey] = finalResults;

  return finalResults;
});
