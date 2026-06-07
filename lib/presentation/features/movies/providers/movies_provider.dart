import 'dart:math' as math;

import 'package:cineverse/core/config/region_preferences.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_mood.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/usecases/get_movie_section_use_case.dart';
import 'package:cineverse/domain/usecases/discover_media_use_case.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/explore_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/hidden_titles_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaFilterOption {
  const MediaFilterOption({required this.label, required this.section});
  final String label;
  final MovieSection section;
}

final movieFilterOptions = Provider<List<MediaFilterOption>>(
  (ref) => const [
    MediaFilterOption(label: 'Popular', section: MovieSection.popular),
    MediaFilterOption(label: 'Top Rated', section: MovieSection.topRated),
    MediaFilterOption(label: 'In Theaters', section: MovieSection.nowPlaying),
    MediaFilterOption(label: 'Coming Soon', section: MovieSection.upcoming),
    MediaFilterOption(label: 'Filtered', section: MovieSection.discover),
  ],
);

final tvFilterOptions = Provider<List<MediaFilterOption>>(
  (ref) => const [
    MediaFilterOption(label: 'Popular', section: MovieSection.tvPopular),
    MediaFilterOption(label: 'Top Rated', section: MovieSection.tvTopRated),
    MediaFilterOption(label: 'On The Air', section: MovieSection.tvOnTheAir),
    MediaFilterOption(
      label: 'Airing Today',
      section: MovieSection.tvAiringToday,
    ),
    MediaFilterOption(label: 'Filtered', section: MovieSection.tvDiscover),
  ],
);

final selectedMovieFilterProvider =
    NotifierProvider<SelectedMovieFilter, MediaFilterOption>(
      SelectedMovieFilter.new,
    );

class SelectedMovieFilter extends Notifier<MediaFilterOption> {
  @override
  MediaFilterOption build() => ref.watch(movieFilterOptions).first;
  void setFilter(MediaFilterOption option) => state = option;
}

final selectedTvFilterProvider =
    NotifierProvider<SelectedTvFilter, MediaFilterOption>(SelectedTvFilter.new);

class SelectedTvFilter extends Notifier<MediaFilterOption> {
  @override
  MediaFilterOption build() => ref.watch(tvFilterOptions).first;
  void setFilter(MediaFilterOption option) => state = option;
}

class SelectedMovieGenreId extends Notifier<int?> {
  @override
  int? build() => null;
  void setGenre(int? id) => state = id;
}

final selectedMovieGenreIdProvider =
    NotifierProvider<SelectedMovieGenreId, int?>(SelectedMovieGenreId.new);

class SelectedTvGenreId extends Notifier<int?> {
  @override
  int? build() => null;
  void setGenre(int? id) => state = id;
}

final selectedTvGenreIdProvider = NotifierProvider<SelectedTvGenreId, int?>(
  SelectedTvGenreId.new,
);

class GenreSortNotifier extends Notifier<MediaFilter> {
  @override
  MediaFilter build() => const MediaFilter();

  void updateSort(SortField field, SortOrder order) {
    state = state.copyWith(sortField: field, sortOrder: order);
  }
}

final genreSortProvider = NotifierProvider<GenreSortNotifier, MediaFilter>(
  GenreSortNotifier.new,
);

final getMovieSectionUseCaseProvider = Provider<GetMovieSectionUseCase>((ref) {
  return GetMovieSectionUseCase(ref.watch(mediaRepositoryProvider));
});

typedef _SectionCacheKey = ({
  String regionCode,
  MovieSection section,
  SortField sortField,
  SortOrder sortOrder,
});
typedef _GenreCacheKey = ({
  String regionCode,
  int genreId,
  bool isTv,
  SortField sortField,
  SortOrder sortOrder,
});

final Map<_SectionCacheKey, List<MediaTitle>> _movieSectionCache = {};
final Map<_SectionCacheKey, int> _loadedPagesCache = {};
final Map<_SectionCacheKey, bool> _fetchingCache = {};
final Map<_SectionCacheKey, int> _targetPages = {};
final Map<_SectionCacheKey, bool> _exhaustedCache = {};
final Map<_GenreCacheKey, List<MediaTitle>> _genreSectionCache = {};
final Map<_GenreCacheKey, int> _genreLoadedPagesCache = {};
final Map<_GenreCacheKey, bool> _genreFetchingCache = {};
final Map<_GenreCacheKey, int> _genreTargetPages = {};
final Map<_GenreCacheKey, bool> _genreExhaustedCache = {};

int _getTargetPage(_SectionCacheKey cacheKey) {
  // Boost the initial variety for discover sections (spotlight)
  if (cacheKey.section == MovieSection.discover ||
      cacheKey.section == MovieSection.tvDiscover) {
    return _targetPages[cacheKey] ?? 1;
  }
  return _targetPages[cacheKey] ?? 2;
}

int _getGenreTargetPage(_GenreCacheKey cacheKey) =>
    _genreTargetPages[cacheKey] ?? 2;

_SectionCacheKey _buildSectionCacheKey({
  required String regionCode,
  required MovieSection section,
  required MediaFilter sortFilter,
}) => (
  regionCode: regionCode,
  section: section,
  sortField: sortFilter.sortField,
  sortOrder: sortFilter.sortOrder,
);

_GenreCacheKey _buildGenreCacheKey({
  required String regionCode,
  required int genreId,
  required bool isTv,
  required MediaFilter sortFilter,
}) => (
  regionCode: regionCode,
  genreId: genreId,
  isTv: isTv,
  sortField: sortFilter.sortField,
  sortOrder: sortFilter.sortOrder,
);

int _ratingSortMinVotes({
  required bool isTv,
  required MediaFilter sortFilter,
  required int baseMinVotes,
}) {
  if (sortFilter.sortField != SortField.voteAverage) {
    return baseMinVotes;
  }
  final int ratingGuardrail = isTv ? 60 : 120;
  return math.max(
    baseMinVotes,
    math.max(sortFilter.minUserVotes, ratingGuardrail),
  );
}

bool _needsSortGuardrail(MediaFilter sortFilter) =>
    sortFilter.sortField == SortField.voteAverage;

List<MediaTitle> _applySortGuardrails(
  List<MediaTitle> results, {
  required bool isTv,
  required MediaFilter sortFilter,
}) {
  switch (sortFilter.sortField) {
    case SortField.voteAverage:
      final int minVotes = _ratingSortMinVotes(
        isTv: isTv,
        sortFilter: sortFilter,
        baseMinVotes: 0,
      );
      return results
          .where((movie) => movie.voteCount >= minVotes)
          .toList(growable: false);
    case SortField.popularity:
    case SortField.voteCount:
    case SortField.releaseDate:
    case SortField.revenue:
      return results;
  }
}

final movieGenresProvider = FutureProvider<List<MovieGenre>>((ref) async {
  return ref.watch(mediaRepositoryProvider).fetchMovieGenres();
});

final tvGenresProvider = FutureProvider<List<MovieGenre>>((ref) async {
  return ref.watch(mediaRepositoryProvider).fetchTvGenres();
});

/// Call this to request the next 2 pages for a specific section.
/// After updating the target, it invalidates only that section's provider.
void loadNextPages(WidgetRef ref, MovieSection section) {
  final sortFilter = ref.read(genreSortProvider);
  final _SectionCacheKey cacheKey = _buildSectionCacheKey(
    regionCode: ref.read(preferredRegionCodeProvider),
    section: section,
    sortFilter: sortFilter,
  );
  if (_fetchingCache[cacheKey] == true || _exhaustedCache[cacheKey] == true) {
    return;
  }
  _targetPages[cacheKey] = _getTargetPage(cacheKey) + 2;
  ref.invalidate(movieSectionProvider(section));
}

void loadNextExplorePages(WidgetRef ref, MovieSection section) {
  final _SectionCacheKey cacheKey = _buildSectionCacheKey(
    regionCode: ref.read(preferredRegionCodeProvider),
    section: section,
    sortFilter: const MediaFilter(),
  );
  if (_fetchingCache[cacheKey] == true || _exhaustedCache[cacheKey] == true) {
    return;
  }
  _targetPages[cacheKey] = _getTargetPage(cacheKey) + 2;
  ref.invalidate(exploreMovieSectionProvider(section));
}

final movieSectionExhaustedProvider = Provider.family<bool, MovieSection>((
  ref,
  section,
) {
  final regionCode = ref.watch(preferredRegionCodeProvider);
  final sortFilter = ref.watch(genreSortProvider);
  return _exhaustedCache[_buildSectionCacheKey(
        regionCode: regionCode,
        section: section,
        sortFilter: sortFilter,
      )] ??
      false;
});

final exploreMovieSectionExhaustedProvider =
    Provider.family<bool, MovieSection>((ref, section) {
      final regionCode = ref.watch(preferredRegionCodeProvider);
      return _exhaustedCache[_buildSectionCacheKey(
            regionCode: regionCode,
            section: section,
            sortFilter: const MediaFilter(),
          )] ??
          false;
    });

void loadNextGenrePages(WidgetRef ref, int genreId, {bool isTv = false}) {
  final sortFilter = ref.read(genreSortProvider);
  final _GenreCacheKey cacheKey = _buildGenreCacheKey(
    regionCode: ref.read(preferredRegionCodeProvider),
    genreId: genreId,
    isTv: isTv,
    sortFilter: sortFilter,
  );
  if (_genreFetchingCache[cacheKey] == true ||
      _genreExhaustedCache[cacheKey] == true) {
    return;
  }
  _genreTargetPages[cacheKey] = _getGenreTargetPage(cacheKey) + 2;
  ref.invalidate(genreSectionProvider((id: genreId, isTv: isTv)));
}

void loadNextExploreGenrePages(
  WidgetRef ref,
  int genreId, {
  bool isTv = false,
}) {
  final _GenreCacheKey cacheKey = _buildGenreCacheKey(
    regionCode: ref.read(preferredRegionCodeProvider),
    genreId: genreId,
    isTv: isTv,
    sortFilter: const MediaFilter(),
  );
  if (_genreFetchingCache[cacheKey] == true ||
      _genreExhaustedCache[cacheKey] == true) {
    return;
  }
  _genreTargetPages[cacheKey] = _getGenreTargetPage(cacheKey) + 2;
  ref.invalidate(exploreGenreSectionProvider((id: genreId, isTv: isTv)));
}

void resetGenreSection(WidgetRef ref, int genreId, {bool isTv = false}) {
  final sortFilter = ref.read(genreSortProvider);
  final _GenreCacheKey cacheKey = _buildGenreCacheKey(
    regionCode: ref.read(preferredRegionCodeProvider),
    genreId: genreId,
    isTv: isTv,
    sortFilter: sortFilter,
  );
  _genreSectionCache.remove(cacheKey);
  _genreLoadedPagesCache.remove(cacheKey);
  _genreExhaustedCache.remove(cacheKey);
  _genreTargetPages[cacheKey] = 2;
  ref.invalidate(genreSectionProvider((id: genreId, isTv: isTv)));
}

final genreSectionExhaustedProvider =
    Provider.family<bool, ({int id, bool isTv})>((ref, params) {
      final regionCode = ref.watch(preferredRegionCodeProvider);
      final sortFilter = ref.watch(genreSortProvider);
      return _genreExhaustedCache[_buildGenreCacheKey(
            regionCode: regionCode,
            genreId: params.id,
            isTv: params.isTv,
            sortFilter: sortFilter,
          )] ??
          false;
    });

final exploreGenreSectionExhaustedProvider =
    Provider.family<bool, ({int id, bool isTv})>((ref, params) {
      final regionCode = ref.watch(preferredRegionCodeProvider);
      return _genreExhaustedCache[_buildGenreCacheKey(
            regionCode: regionCode,
            genreId: params.id,
            isTv: params.isTv,
            sortFilter: const MediaFilter(),
          )] ??
          false;
    });

void resetMovieSection(WidgetRef ref, MovieSection section) {
  final sortFilter = ref.read(genreSortProvider);
  final _SectionCacheKey cacheKey = _buildSectionCacheKey(
    regionCode: ref.read(preferredRegionCodeProvider),
    section: section,
    sortFilter: sortFilter,
  );
  _movieSectionCache.remove(cacheKey);
  _loadedPagesCache.remove(cacheKey);
  _exhaustedCache.remove(cacheKey);
  _targetPages[cacheKey] = 2;
  ref.invalidate(movieSectionProvider(section));
}

Future<List<MediaTitle>> _fetchMovieSection(
  Ref ref,
  MovieSection section, {
  required MediaFilter sortFilter,
}) async {
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
  });

  final String regionCode = ref.watch(preferredRegionCodeProvider);

  // Watch filters if we are in discover mode to trigger re-runs
  if (section == MovieSection.discover) {
    ref.watch(movieFilterProvider);
  } else if (section == MovieSection.tvDiscover) {
    ref.watch(tvFilterProvider);
  }

  final _SectionCacheKey cacheKey = _buildSectionCacheKey(
    regionCode: regionCode,
    section: section,
    sortFilter: sortFilter,
  );

  final int targetPage = _getTargetPage(cacheKey);

  final GetMovieSectionUseCase useCase = ref.watch(
    getMovieSectionUseCaseProvider,
  );
  final repository = ref.watch(mediaRepositoryProvider);
  final discoverUseCase = DiscoverMediaUseCase(repository);
  final movieDiscoverFilter = section == MovieSection.discover
      ? ref.read(movieFilterProvider)
      : null;
  final tvDiscoverFilter = section == MovieSection.tvDiscover
      ? ref.read(tvFilterProvider)
      : null;

  final List<MediaTitle> results = List<MediaTitle>.from(
    _movieSectionCache[cacheKey] ?? const <MediaTitle>[],
  );

  int startPage = (_loadedPagesCache[cacheKey] ?? 0) + 1;
  final bool isTvSection = section.name.startsWith('tv');
  final int maxPage = _needsSortGuardrail(sortFilter)
      ? targetPage + 6
      : targetPage;

  if (startPage <= maxPage) {
    _fetchingCache[cacheKey] = true;
    for (int i = startPage; i <= maxPage; i++) {
      if (disposed) {
        break;
      }
      try {
        final List<MediaTitle> pageResults;
        if (section == MovieSection.discover) {
          final filter = movieDiscoverFilter!;
          // Merge global sort into discover filter
          final effectiveFilter = filter.copyWith(
            sortField: sortFilter.sortField,
            sortOrder: sortFilter.sortOrder,
            minUserVotes: _ratingSortMinVotes(
              isTv: false,
              sortFilter: sortFilter,
              baseMinVotes: filter.minUserVotes,
            ),
          );
          pageResults = await discoverUseCase(
            DiscoverMediaParams(isTv: false, filter: effectiveFilter, page: i),
          );
        } else if (section == MovieSection.tvDiscover) {
          final filter = tvDiscoverFilter!;
          // Merge global sort into discover filter
          final effectiveFilter = filter.copyWith(
            sortField: sortFilter.sortField,
            sortOrder: sortFilter.sortOrder,
            minUserVotes: _ratingSortMinVotes(
              isTv: true,
              sortFilter: sortFilter,
              baseMinVotes: filter.minUserVotes,
            ),
          );
          pageResults = await discoverUseCase(
            DiscoverMediaParams(isTv: true, filter: effectiveFilter, page: i),
          );
        } else if (!sortFilter.isDefault ||
            section == MovieSection.nowPlaying ||
            section == MovieSection.upcoming ||
            section == MovieSection.tvOnTheAir ||
            section == MovieSection.tvAiringToday) {
          // For non-default sort OR specific date-sensitive sections, use discover with strict filters
          final bool isTv = section.name.startsWith('tv');

          DateTime? fromDate;
          DateTime? toDate;
          Set<int> releaseTypes = {};
          int minVotes = 0;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          if (section == MovieSection.nowPlaying ||
              section == MovieSection.tvOnTheAir) {
            fromDate = today.subtract(const Duration(days: 30));
            toDate = today;
            releaseTypes = {2, 3};
          } else if (section == MovieSection.upcoming ||
              section == MovieSection.tvAiringToday) {
            // Strictly from tomorrow onwards to avoid "already released" movies
            fromDate = today.add(const Duration(days: 1));
            toDate = today.add(const Duration(days: 90));
            releaseTypes = {2, 3};
          } else if (section == MovieSection.topRated ||
              section == MovieSection.tvTopRated) {
            minVotes = isTv ? 150 : 300; // TMDB threshold for top rated
          }

          minVotes = _ratingSortMinVotes(
            isTv: isTv,
            sortFilter: sortFilter,
            baseMinVotes: minVotes,
          );

          pageResults = await discoverUseCase(
            DiscoverMediaParams(
              isTv: isTv,
              filter: MediaFilter(
                sortField: sortFilter.sortField,
                sortOrder: sortFilter.sortOrder,
                releaseDateFrom: fromDate,
                releaseDateTo: toDate,
                releaseTypes: releaseTypes,
                minUserVotes: minVotes,
              ),
              page: i,
            ),
          );
        } else {
          pageResults = await useCase(section, page: i);
        }
        final List<MediaTitle> acceptedPageResults = _applySortGuardrails(
          pageResults,
          isTv: isTvSection,
          sortFilter: sortFilter,
        );
        results.addAll(acceptedPageResults);
        _loadedPagesCache[cacheKey] = i;
        if (pageResults.isEmpty || pageResults.length < 20) {
          _exhaustedCache[cacheKey] = true;
          break;
        }
        if (i >= targetPage && !_needsSortGuardrail(sortFilter)) {
          break;
        }
        if (i >= targetPage &&
            _needsSortGuardrail(sortFilter) &&
            results.length >= targetPage * 20) {
          break;
        }
      } catch (error, stackTrace) {
        debugPrint('[movieSectionProvider:${section.name}:$i] $error');
        debugPrintStack(stackTrace: stackTrace);
        if (i == 1 && results.isEmpty) {
          _fetchingCache[cacheKey] = false;
          rethrow;
        }
        break;
      }
    }
    _fetchingCache[cacheKey] = false;
  }

  final List<MediaTitle> uniqueResults = <MediaTitle>[];
  final Set<int> seenMovieIds = <int>{};
  for (final MediaTitle movie in results) {
    if (seenMovieIds.add(movie.id)) {
      uniqueResults.add(movie);
    }
  }

  _movieSectionCache[cacheKey] = uniqueResults;
  return uniqueResults;
}

final movieSectionProvider =
    FutureProvider.family<List<MediaTitle>, MovieSection>((ref, section) async {
      final sortFilter = ref.watch(genreSortProvider);
      return _fetchMovieSection(ref, section, sortFilter: sortFilter);
    });

final exploreMovieSectionProvider =
    FutureProvider.family<List<MediaTitle>, MovieSection>((ref, section) async {
      return _fetchMovieSection(ref, section, sortFilter: const MediaFilter());
    });

final genreSectionProvider =
    FutureProvider.family<List<MediaTitle>, ({int id, bool isTv})>((
      ref,
      params,
    ) async {
      final sortFilter = ref.watch(genreSortProvider);
      return _fetchGenreSection(ref, params, sortFilter: sortFilter);
    });

Future<List<MediaTitle>> _fetchGenreSection(
  Ref ref,
  ({int id, bool isTv}) params, {
  required MediaFilter sortFilter,
}) async {
  final String regionCode = ref.watch(preferredRegionCodeProvider);

  final _GenreCacheKey cacheKey = _buildGenreCacheKey(
    regionCode: regionCode,
    genreId: params.id,
    isTv: params.isTv,
    sortFilter: sortFilter,
  );
  final int targetPage = _getGenreTargetPage(cacheKey);

  final repository = ref.watch(mediaRepositoryProvider);
  final discoverUseCase = DiscoverMediaUseCase(repository);

  final List<MediaTitle> results = List<MediaTitle>.from(
    _genreSectionCache[cacheKey] ?? const <MediaTitle>[],
  );

  int startPage = (_genreLoadedPagesCache[cacheKey] ?? 0) + 1;
  final int maxPage = _needsSortGuardrail(sortFilter)
      ? targetPage + 6
      : targetPage;

  if (startPage <= maxPage) {
    _genreFetchingCache[cacheKey] = true;
    for (int i = startPage; i <= maxPage; i++) {
      try {
        final List<MediaTitle> pageResults = await discoverUseCase(
          DiscoverMediaParams(
            isTv: params.isTv,
            filter: MediaFilter(
              sortField: sortFilter.sortField,
              sortOrder: sortFilter.sortOrder,
              minUserVotes: _ratingSortMinVotes(
                isTv: params.isTv,
                sortFilter: sortFilter,
                baseMinVotes: 0,
              ),
              genres: {params.id},
            ),
            page: i,
          ),
        );
        final List<MediaTitle> acceptedPageResults = _applySortGuardrails(
          pageResults,
          isTv: params.isTv,
          sortFilter: sortFilter,
        );
        results.addAll(acceptedPageResults);
        _genreLoadedPagesCache[cacheKey] = i;
        if (pageResults.isEmpty || pageResults.length < 20) {
          _genreExhaustedCache[cacheKey] = true;
          break;
        }
        if (i >= targetPage && !_needsSortGuardrail(sortFilter)) {
          break;
        }
        if (i >= targetPage &&
            _needsSortGuardrail(sortFilter) &&
            results.length >= targetPage * 20) {
          break;
        }
      } catch (error, stackTrace) {
        debugPrint('[genreSectionProvider:${params.id}:$i] $error');
        debugPrintStack(stackTrace: stackTrace);
        if (i == 1 && results.isEmpty) {
          _genreFetchingCache[cacheKey] = false;
          rethrow;
        }
        break;
      }
    }
    _genreFetchingCache[cacheKey] = false;
  }

  final List<MediaTitle> uniqueResults = <MediaTitle>[];
  final Set<int> seenMovieIds = <int>{};
  for (final MediaTitle movie in results) {
    if (seenMovieIds.add(movie.id)) {
      uniqueResults.add(movie);
    }
  }

  _genreSectionCache[cacheKey] = uniqueResults;
  return uniqueResults;
}

final exploreGenreSectionProvider =
    FutureProvider.family<List<MediaTitle>, ({int id, bool isTv})>((
      ref,
      params,
    ) async {
      return _fetchGenreSection(ref, params, sortFilter: const MediaFilter());
    });

final discoverPoolProvider = FutureProvider<List<MediaTitle>>((ref) async {
  final mediaType = ref.watch(exploreMediaTypeProvider);
  final section = mediaType == ExploreMediaType.movie
      ? MovieSection.discover
      : MovieSection.tvDiscover;

  final AsyncValue<List<MediaTitle>> discoverState = ref.watch(
    exploreMovieSectionProvider(section),
  );

  final List<MediaTitle> discoverMovies;
  if (discoverState.hasValue) {
    discoverMovies = discoverState.value!;
  } else {
    discoverMovies = await ref.watch(
      exploreMovieSectionProvider(section).future,
    );
  }

  // Watch hidden titles to dynamically filter the spotlight pool
  final hiddenTitlesAsync = ref.watch(hiddenTitlesProvider);
  final Set<int> hiddenIds =
      hiddenTitlesAsync.value
          ?.where((t) => t.isTv == (mediaType == ExploreMediaType.tv))
          .map((t) => t.id)
          .toSet() ??
      <int>{};

  final Set<int> seenMovieIds = <int>{};
  final List<MediaTitle> discoverPool = <MediaTitle>[];

  for (final MediaTitle movie in discoverMovies) {
    if (hiddenIds.contains(movie.id)) {
      continue;
    }
    if (seenMovieIds.add(movie.id)) {
      discoverPool.add(movie);
    }
  }

  return discoverPool;
});

typedef _MoodCacheKey = ({
  String regionCode,
  MovieMood mood,
  bool isTv,
  SortField sortField,
  SortOrder sortOrder,
});
typedef _HiddenGemsCacheKey = ({String regionCode});
typedef _CuratedTonightCacheKey = ({String regionCode, bool isTv, int dayKey});

final Map<_MoodCacheKey, List<MediaTitle>> _moodSectionCache = {};
final Map<_MoodCacheKey, int> _moodLoadedPagesCache = {};
final Map<_MoodCacheKey, bool> _moodFetchingCache = {};
final Map<_MoodCacheKey, int> _moodTargetPages = {};
final Map<_MoodCacheKey, bool> _moodExhaustedCache = {};
final Map<_HiddenGemsCacheKey, List<MediaTitle>> _hiddenGemsCache = {};
final Map<_HiddenGemsCacheKey, int> _hiddenGemsLoadedPagesCache = {};
final Map<_HiddenGemsCacheKey, bool> _hiddenGemsFetchingCache = {};
final Map<_HiddenGemsCacheKey, int> _hiddenGemsTargetPages = {};
final Map<_HiddenGemsCacheKey, bool> _hiddenGemsExhaustedCache = {};
final Map<_CuratedTonightCacheKey, CuratedTonightRailData>
_curatedTonightCache = {};

class CuratedTonightProfile {
  const CuratedTonightProfile({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.movieGenres,
    required this.tvGenres,
    required this.runtime,
    required this.scoreRange,
    required this.minUserVotes,
    this.minGenreMatches = 2,
    this.excludedMovieGenres = const <int>{},
    this.excludedTvGenres = const <int>{},
  });

  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final Set<int> movieGenres;
  final Set<int> tvGenres;
  final RangeValues runtime;
  final RangeValues scoreRange;
  final int minUserVotes;
  final int minGenreMatches;
  final Set<int> excludedMovieGenres;
  final Set<int> excludedTvGenres;
}

class CuratedTonightRailData {
  const CuratedTonightRailData({
    required this.profile,
    required this.dayKey,
    required this.isTv,
    required this.titles,
  });

  final CuratedTonightProfile profile;
  final int dayKey;
  final bool isTv;
  final List<MediaTitle> titles;
}

const List<CuratedTonightProfile>
_curatedTonightProfiles = <CuratedTonightProfile>[
  CuratedTonightProfile(
    id: 'neo_noir_nights',
    title: 'Neo-noir Nights',
    description:
        'Rain-soaked tension, morally gray leads, and atmospheric city stories.',
    tags: <String>['Crime', 'Thriller', 'Atmospheric'],
    movieGenres: <int>{80, 53, 18},
    tvGenres: <int>{80, 9648, 18},
    runtime: RangeValues(88, 160),
    scoreRange: RangeValues(6.4, 10.0),
    minUserVotes: 140,
    minGenreMatches: 2,
    excludedMovieGenres: <int>{10749, 10751, 16, 10402},
    excludedTvGenres: <int>{10749, 10751, 10762, 10764, 10766, 10767, 10402},
  ),
  CuratedTonightProfile(
    id: 'pulse_pounding',
    title: 'Pulse-Pounding Rush',
    description:
        'High-stakes chases, escalating danger, and no-time-to-breathe pacing.',
    tags: <String>['Action', 'Suspense', 'Fast-paced'],
    movieGenres: <int>{28, 53, 12},
    tvGenres: <int>{10759, 80, 9648},
    runtime: RangeValues(82, 145),
    scoreRange: RangeValues(6.0, 10.0),
    minUserVotes: 180,
    minGenreMatches: 2,
    excludedMovieGenres: <int>{10749, 10751, 16, 99},
    excludedTvGenres: <int>{10749, 10751, 10762, 10764, 10766, 10767},
  ),
  CuratedTonightProfile(
    id: 'feel_good_escape',
    title: 'Feel-Good Escape',
    description:
        'Warm stories, uplifting arcs, and comforting picks for a relaxed night.',
    tags: <String>['Feel-good', 'Heartwarming', 'Comfort'],
    movieGenres: <int>{35, 10749, 10751},
    tvGenres: <int>{35, 10751, 10766},
    runtime: RangeValues(78, 145),
    scoreRange: RangeValues(6.1, 10.0),
    minUserVotes: 90,
    minGenreMatches: 2,
    excludedMovieGenres: <int>{27, 80, 53, 9648, 10752},
    excludedTvGenres: <int>{27, 80, 9648, 10752, 10765},
  ),
  CuratedTonightProfile(
    id: 'mind_benders',
    title: 'Mind-Benders',
    description:
        'Reality-warping concepts, twisty plotting, and big-idea storytelling.',
    tags: <String>['Sci-fi', 'Mystery', 'Twists'],
    movieGenres: <int>{878, 9648, 53},
    tvGenres: <int>{10765, 9648, 18},
    runtime: RangeValues(90, 170),
    scoreRange: RangeValues(6.3, 10.0),
    minUserVotes: 120,
    minGenreMatches: 2,
    excludedMovieGenres: <int>{10749, 10751, 16, 10402},
    excludedTvGenres: <int>{10749, 10751, 10762, 10764, 10766, 10767},
  ),
  CuratedTonightProfile(
    id: 'epic_worlds',
    title: 'Epic Worlds',
    description: 'Big-universe adventures, mythic stakes, and cinematic scale.',
    tags: <String>['Epic', 'Adventure', 'Fantasy'],
    movieGenres: <int>{14, 12, 28},
    tvGenres: <int>{10765, 10759, 18},
    runtime: RangeValues(95, 190),
    scoreRange: RangeValues(6.1, 10.0),
    minUserVotes: 160,
    minGenreMatches: 2,
    excludedMovieGenres: <int>{99, 10770},
    excludedTvGenres: <int>{99, 10764, 10767, 10762, 10766},
  ),
  CuratedTonightProfile(
    id: 'human_stories',
    title: 'Human Stories',
    description:
        'Character-first dramas with emotional pull and memorable performances.',
    tags: <String>['Drama', 'Character-led', 'Emotional'],
    movieGenres: <int>{18, 10749},
    tvGenres: <int>{18, 10766},
    runtime: RangeValues(85, 165),
    scoreRange: RangeValues(6.5, 10.0),
    minUserVotes: 100,
    minGenreMatches: 1,
    excludedMovieGenres: <int>{27, 878, 14},
    excludedTvGenres: <int>{27, 10765, 10759},
  ),
  CuratedTonightProfile(
    id: 'dark_detective',
    title: 'Dark Detective Files',
    description: 'Cold clues, layered suspects, and slow-burn investigations.',
    tags: <String>['Detective', 'Mystery', 'Crime'],
    movieGenres: <int>{80, 9648, 53},
    tvGenres: <int>{80, 9648, 18},
    runtime: RangeValues(88, 165),
    scoreRange: RangeValues(6.3, 10.0),
    minUserVotes: 110,
    minGenreMatches: 2,
    excludedMovieGenres: <int>{10749, 10751, 16, 35, 10402},
    excludedTvGenres: <int>{10749, 10751, 10762, 10764, 10766, 10767, 35},
  ),
];

int _calendarDayKey(DateTime now) {
  final DateTime localDay = DateTime(now.year, now.month, now.day);
  return localDay.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
}

CuratedTonightProfile _profileForDay(int dayKey) {
  final int index = dayKey % _curatedTonightProfiles.length;
  return _curatedTonightProfiles[index];
}

List<MediaTitle> _seededShuffle(List<MediaTitle> input, int seed) {
  final List<MediaTitle> shuffled = List<MediaTitle>.from(input);
  final math.Random random = math.Random(seed);
  for (int i = shuffled.length - 1; i > 0; i--) {
    final int j = random.nextInt(i + 1);
    final MediaTitle temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }
  return shuffled;
}

int _genreOverlapCount(Set<int> targetGenres, List<int> mediaGenres) {
  if (targetGenres.isEmpty || mediaGenres.isEmpty) {
    return 0;
  }
  return mediaGenres.where(targetGenres.contains).length;
}

double _curatedThemeScore(
  MediaTitle media,
  CuratedTonightProfile profile, {
  required bool isTv,
}) {
  final Set<int> targetGenres = isTv ? profile.tvGenres : profile.movieGenres;
  final int overlap = _genreOverlapCount(targetGenres, media.genreIds);
  final double overlapRatio = targetGenres.isEmpty
      ? 0
      : overlap / targetGenres.length;
  final double voteAverage = media.voteAverage ?? 0.0;
  final double voteConfidence = math.min(
    1.0,
    math.log(media.voteCount + 1) / math.log(2000),
  );
  final double popularityComponent = math.min(1.0, media.popularity / 120.0);
  return (overlap * 3.5) +
      (overlapRatio * 3.0) +
      (voteAverage * 0.65) +
      (voteConfidence * 2.2) +
      (popularityComponent * 0.9);
}

bool _passesCuratedGuardrails(
  MediaTitle media,
  CuratedTonightProfile profile, {
  required bool isTv,
}) {
  final Set<int> targetGenres = isTv ? profile.tvGenres : profile.movieGenres;
  final Set<int> excludedGenres = isTv
      ? profile.excludedTvGenres
      : profile.excludedMovieGenres;
  final int overlap = _genreOverlapCount(targetGenres, media.genreIds);
  final int requiredMatches = math.min(
    profile.minGenreMatches,
    math.max(1, targetGenres.length),
  );
  if (overlap < requiredMatches) {
    return false;
  }
  final bool hasExcluded = media.genreIds.any(excludedGenres.contains);
  if (hasExcluded) {
    return false;
  }
  final double voteAverage = media.voteAverage ?? 0.0;
  if (voteAverage < (profile.scoreRange.start - 0.2)) {
    return false;
  }
  final int minVotesForGuardrail = math.max(30, profile.minUserVotes ~/ 2);
  if (media.voteCount < minVotesForGuardrail) {
    return false;
  }
  return true;
}

List<MediaTitle> _rankCuratedCandidates(
  List<MediaTitle> candidates,
  CuratedTonightProfile profile, {
  required bool isTv,
}) {
  final List<MediaTitle> filtered = candidates
      .where((media) => _passesCuratedGuardrails(media, profile, isTv: isTv))
      .toList(growable: false);
  final List<MediaTitle> ranked = List<MediaTitle>.from(filtered);
  ranked.sort(
    (a, b) => _curatedThemeScore(
      b,
      profile,
      isTv: isTv,
    ).compareTo(_curatedThemeScore(a, profile, isTv: isTv)),
  );
  return ranked;
}

final curatedTonightDayKeyProvider = StreamProvider<int>((ref) async* {
  int? lastKey;
  while (true) {
    final int nextKey = _calendarDayKey(DateTime.now());
    if (nextKey != lastKey) {
      lastKey = nextKey;
      yield nextKey;
    }
    await Future<void>.delayed(const Duration(minutes: 20));
  }
});

int _getMoodTargetPage(_MoodCacheKey cacheKey) =>
    _moodTargetPages[cacheKey] ?? 2;
int _getHiddenGemsTargetPage(_HiddenGemsCacheKey cacheKey) =>
    _hiddenGemsTargetPages[cacheKey] ?? 1;

void loadNextMoodPages(WidgetRef ref, MovieMood mood, {bool isTv = false}) {
  final sortFilter = ref.read(genreSortProvider);
  final _MoodCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    mood: mood,
    isTv: isTv,
    sortField: sortFilter.sortField,
    sortOrder: sortFilter.sortOrder,
  );
  if (_moodFetchingCache[cacheKey] == true ||
      _moodExhaustedCache[cacheKey] == true) {
    return;
  }
  _moodTargetPages[cacheKey] = _getMoodTargetPage(cacheKey) + 2;
  ref.invalidate(moodSectionProvider((mood: mood, isTv: isTv)));
}

final moodSectionExhaustedProvider =
    Provider.family<bool, ({MovieMood mood, bool isTv})>((ref, params) {
      final regionCode = ref.watch(preferredRegionCodeProvider);
      final sortFilter = ref.watch(genreSortProvider);
      return _moodExhaustedCache[(
            regionCode: regionCode,
            mood: params.mood,
            isTv: params.isTv,
            sortField: sortFilter.sortField,
            sortOrder: sortFilter.sortOrder,
          )] ??
          false;
    });

final moodSectionProvider =
    FutureProvider.family<List<MediaTitle>, ({MovieMood mood, bool isTv})>((
      ref,
      params,
    ) async {
      final String regionCode = ref.watch(preferredRegionCodeProvider);
      final sortFilter = ref.watch(genreSortProvider);

      final _MoodCacheKey cacheKey = (
        regionCode: regionCode,
        mood: params.mood,
        isTv: params.isTv,
        sortField: sortFilter.sortField,
        sortOrder: sortFilter.sortOrder,
      );
      final int targetPage = _getMoodTargetPage(cacheKey);

      final repository = ref.watch(mediaRepositoryProvider);
      final discoverUseCase = DiscoverMediaUseCase(repository);

      final List<MediaTitle> results = List<MediaTitle>.from(
        _moodSectionCache[cacheKey] ?? const <MediaTitle>[],
      );

      int startPage = (_moodLoadedPagesCache[cacheKey] ?? 0) + 1;

      if (startPage <= targetPage) {
        _moodFetchingCache[cacheKey] = true;
        for (int i = startPage; i <= targetPage; i++) {
          try {
            final List<MediaTitle> pageResults = await discoverUseCase(
              DiscoverMediaParams(
                isTv: params.isTv,
                filter: MediaFilter(
                  sortField: sortFilter.sortField,
                  sortOrder: sortFilter.sortOrder,
                  mood: params.mood,
                  userScore: const RangeValues(5.5, 10.0),
                  minUserVotes: 10,
                  includeNotRated: false,
                ),

                page: i,
              ),
            );
            results.addAll(pageResults);
            _moodLoadedPagesCache[cacheKey] = i;
            if (pageResults.isEmpty || pageResults.length < 20) {
              _moodExhaustedCache[cacheKey] = true;
              break;
            }
          } catch (error, stackTrace) {
            debugPrint('[moodSectionProvider:${params.mood.name}:$i] $error');
            debugPrintStack(stackTrace: stackTrace);
            if (i == 1 && results.isEmpty) {
              _moodFetchingCache[cacheKey] = false;
              rethrow;
            }
            break;
          }
        }
        _moodFetchingCache[cacheKey] = false;
      }

      final List<MediaTitle> uniqueResults = <MediaTitle>[];
      final Set<int> seenMovieIds = <int>{};
      for (final MediaTitle movie in results) {
        if (seenMovieIds.add(movie.id)) {
          uniqueResults.add(movie);
        }
      }

      _moodSectionCache[cacheKey] = uniqueResults;
      return uniqueResults;
    });

void loadNextHiddenGemsPages(WidgetRef ref) {
  final _HiddenGemsCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
  );
  if (_hiddenGemsFetchingCache[cacheKey] == true ||
      _hiddenGemsExhaustedCache[cacheKey] == true) {
    return;
  }
  // Grow one page at a time so users see progressively available genres faster.
  _hiddenGemsTargetPages[cacheKey] = _getHiddenGemsTargetPage(cacheKey) + 1;
  ref.invalidate(hiddenGemsSectionProvider);
}

final hiddenGemsSectionExhaustedProvider = Provider<bool>((ref) {
  final _HiddenGemsCacheKey cacheKey = (
    regionCode: ref.watch(preferredRegionCodeProvider),
  );
  return _hiddenGemsExhaustedCache[cacheKey] ?? false;
});

final hiddenGemsSectionProvider = FutureProvider<List<MediaTitle>>((ref) async {
  final _HiddenGemsCacheKey cacheKey = (
    regionCode: ref.watch(preferredRegionCodeProvider),
  );
  final repository = ref.watch(mediaRepositoryProvider);
  final discoverUseCase = DiscoverMediaUseCase(repository);
  final int targetPage = _getHiddenGemsTargetPage(cacheKey);

  final List<MediaTitle> results = List<MediaTitle>.from(
    _hiddenGemsCache[cacheKey] ?? const <MediaTitle>[],
  );
  int startPage = (_hiddenGemsLoadedPagesCache[cacheKey] ?? 0) + 1;

  if (startPage <= targetPage) {
    _hiddenGemsFetchingCache[cacheKey] = true;
    for (int page = startPage; page <= targetPage; page++) {
      final List<MediaTitle> pageResults = await discoverUseCase(
        DiscoverMediaParams(
          isTv: false,
          filter: const MediaFilter(
            sortField: SortField.popularity,
            sortOrder: SortOrder.ascending,
            userScore: RangeValues(7.01, 10.0),
            minUserVotes: 120,
            includeNotRated: false,
          ),
          page: page,
        ),
      );

      results.addAll(pageResults);
      _hiddenGemsLoadedPagesCache[cacheKey] = page;
      if (pageResults.isEmpty || pageResults.length < 20) {
        _hiddenGemsExhaustedCache[cacheKey] = true;
        break;
      }
    }
    _hiddenGemsFetchingCache[cacheKey] = false;
  }

  final List<MediaTitle> uniqueResults = <MediaTitle>[];
  final Set<int> seenMovieIds = <int>{};
  for (final MediaTitle movie in results) {
    if (seenMovieIds.add(movie.id)) {
      uniqueResults.add(movie);
    }
  }

  _hiddenGemsCache[cacheKey] = uniqueResults;
  return uniqueResults;
});

final curatedTonightRailProvider = FutureProvider<CuratedTonightRailData>((
  ref,
) async {
  final String regionCode = ref.watch(preferredRegionCodeProvider);
  final bool isTv = ref.watch(exploreMediaTypeProvider) == ExploreMediaType.tv;
  final int dayKey =
      ref.watch(curatedTonightDayKeyProvider).value ??
      _calendarDayKey(DateTime.now());

  final _CuratedTonightCacheKey cacheKey = (
    regionCode: regionCode,
    isTv: isTv,
    dayKey: dayKey,
  );
  final CuratedTonightRailData? cached = _curatedTonightCache[cacheKey];
  if (cached != null) {
    return cached;
  }

  // Keep only current and yesterday to avoid cache growth over long sessions.
  _curatedTonightCache.removeWhere((key, value) => key.dayKey < dayKey - 1);

  final repository = ref.watch(mediaRepositoryProvider);
  final discoverUseCase = DiscoverMediaUseCase(repository);
  final CuratedTonightProfile profile = _profileForDay(dayKey);
  final Set<int> genreIds = isTv ? profile.tvGenres : profile.movieGenres;

  final List<MediaTitle> fetched = <MediaTitle>[];
  for (int page = 1; page <= 3; page++) {
    final List<MediaTitle> pageResults = await discoverUseCase(
      DiscoverMediaParams(
        isTv: isTv,
        filter: MediaFilter(
          sortField: SortField.voteAverage,
          sortOrder: SortOrder.descending,
          userScore: profile.scoreRange,
          minUserVotes: profile.minUserVotes,
          includeNotRated: false,
          genres: genreIds,
          runtime: profile.runtime,
        ),
        page: page,
      ),
    );
    fetched.addAll(pageResults);
    if (pageResults.isEmpty || pageResults.length < 20) {
      break;
    }
  }

  final List<MediaTitle> unique = <MediaTitle>[];
  final Set<int> seenIds = <int>{};
  for (final MediaTitle media in fetched) {
    if (seenIds.add(media.id)) {
      unique.add(media);
    }
  }

  final int seed = dayKey + profile.id.hashCode + (isTv ? 1009 : 0);
  List<MediaTitle> source = _rankCuratedCandidates(unique, profile, isTv: isTv);
  if (source.length < 24) {
    final List<MediaTitle> relaxedFallback = await discoverUseCase(
      DiscoverMediaParams(
        isTv: isTv,
        filter: MediaFilter(
          sortField: SortField.popularity,
          sortOrder: SortOrder.descending,
          userScore: const RangeValues(5.5, 10.0),
          minUserVotes: 60,
          includeNotRated: false,
          genres: genreIds,
        ),
        page: 1,
      ),
    );
    final List<MediaTitle> merged = <MediaTitle>[...source];
    for (final MediaTitle media in relaxedFallback) {
      if (seenIds.add(media.id)) {
        merged.add(media);
      }
    }
    source = _rankCuratedCandidates(merged, profile, isTv: isTv);
  }

  final List<MediaTitle> topThematicPool = source
      .take(120)
      .toList(growable: false);
  final List<MediaTitle> shuffled = _seededShuffle(topThematicPool, seed);
  final List<MediaTitle> curated = shuffled.take(30).toList(growable: false);

  final CuratedTonightRailData result = CuratedTonightRailData(
    profile: profile,
    dayKey: dayKey,
    isTv: isTv,
    titles: curated,
  );
  _curatedTonightCache[cacheKey] = result;
  return result;
});

final moviesProvider = Provider<AsyncValue<List<MediaTitle>>>((ref) {
  final mediaType = ref.watch(exploreMediaTypeProvider);
  final section = mediaType == ExploreMediaType.movie
      ? MovieSection.discover
      : MovieSection.tvDiscover;
  return ref.watch(exploreMovieSectionProvider(section));
});

final mediaImagesProvider =
    FutureProvider.family<MediaImages, ({int id, bool isTv})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(mediaRepositoryProvider);
      return repository.fetchMediaImages(params.id, isTv: params.isTv);
    });

final mediaTaglinesProvider =
    FutureProvider.family<List<String>, ({int id, bool isTv})>((
      ref,
      params,
    ) async {
      final apiClient = ref.watch(tmdbApiClientProvider);
      return apiClient.fetchMediaTaglines(params.id, isTv: params.isTv);
    });

final tvSeasonImagesProvider =
    FutureProvider.family<MediaImages, ({int tvId, int seasonNumber})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(mediaRepositoryProvider);
      return repository.fetchTvSeasonImages(params.tvId, params.seasonNumber);
    });

final personImagesProvider = FutureProvider.family<MediaImages, int>((
  ref,
  personId,
) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return repository.fetchPersonImages(personId);
});

final mediaRevenueProvider = FutureProvider.family<int?, int>((
  ref,
  movieId,
) async {
  final repository = ref.watch(mediaRepositoryProvider);
  final details = await repository.fetchMovieDetails(movieId);
  return details.revenue;
});
