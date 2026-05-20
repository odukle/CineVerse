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
    return _targetPages[cacheKey] ?? 5;
  }
  return _targetPages[cacheKey] ?? 2;
}

int _getGenreTargetPage(_GenreCacheKey cacheKey) =>
    _genreTargetPages[cacheKey] ?? 2;

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
  final _SectionCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    section: section,
    sortField: sortFilter.sortField,
    sortOrder: sortFilter.sortOrder,
  );
  if (_fetchingCache[cacheKey] == true || _exhaustedCache[cacheKey] == true) {
    return;
  }
  _targetPages[cacheKey] = _getTargetPage(cacheKey) + 2;
  ref.invalidate(movieSectionProvider(section));
}

final movieSectionExhaustedProvider = Provider.family<bool, MovieSection>((
  ref,
  section,
) {
  final regionCode = ref.watch(preferredRegionCodeProvider);
  final sortFilter = ref.watch(genreSortProvider);
  return _exhaustedCache[(
        regionCode: regionCode,
        section: section,
        sortField: sortFilter.sortField,
        sortOrder: sortFilter.sortOrder,
      )] ??
      false;
});

void loadNextGenrePages(WidgetRef ref, int genreId, {bool isTv = false}) {
  final sortFilter = ref.read(genreSortProvider);
  final _GenreCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    genreId: genreId,
    isTv: isTv,
    sortField: sortFilter.sortField,
    sortOrder: sortFilter.sortOrder,
  );
  if (_genreFetchingCache[cacheKey] == true ||
      _genreExhaustedCache[cacheKey] == true) {
    return;
  }
  _genreTargetPages[cacheKey] = _getGenreTargetPage(cacheKey) + 2;
  ref.invalidate(genreSectionProvider((id: genreId, isTv: isTv)));
}

void resetGenreSection(WidgetRef ref, int genreId, {bool isTv = false}) {
  final sortFilter = ref.read(genreSortProvider);
  final _GenreCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    genreId: genreId,
    isTv: isTv,
    sortField: sortFilter.sortField,
    sortOrder: sortFilter.sortOrder,
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
      return _genreExhaustedCache[(
            regionCode: regionCode,
            genreId: params.id,
            isTv: params.isTv,
            sortField: sortFilter.sortField,
            sortOrder: sortFilter.sortOrder,
          )] ??
          false;
    });

void resetMovieSection(WidgetRef ref, MovieSection section) {
  final sortFilter = ref.read(genreSortProvider);
  final _SectionCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    section: section,
    sortField: sortFilter.sortField,
    sortOrder: sortFilter.sortOrder,
  );
  _movieSectionCache.remove(cacheKey);
  _loadedPagesCache.remove(cacheKey);
  _exhaustedCache.remove(cacheKey);
  _targetPages[cacheKey] = 2;
  ref.invalidate(movieSectionProvider(section));
}

final movieSectionProvider = FutureProvider.family<List<MediaTitle>, MovieSection>((
  ref,
  section,
) async {
  final String regionCode = ref.watch(preferredRegionCodeProvider);
  final sortFilter = ref.watch(genreSortProvider);

  // Watch filters if we are in discover mode to trigger re-runs
  if (section == MovieSection.discover) {
    ref.watch(movieFilterProvider);
  } else if (section == MovieSection.tvDiscover) {
    ref.watch(tvFilterProvider);
  }

  final _SectionCacheKey cacheKey = (
    regionCode: regionCode,
    section: section,
    sortField: sortFilter.sortField,
    sortOrder: sortFilter.sortOrder,
  );

  final int targetPage = _getTargetPage(cacheKey);

  final GetMovieSectionUseCase useCase = ref.watch(
    getMovieSectionUseCaseProvider,
  );
  final repository = ref.watch(mediaRepositoryProvider);
  final discoverUseCase = DiscoverMediaUseCase(repository);

  final List<MediaTitle> results = List<MediaTitle>.from(
    _movieSectionCache[cacheKey] ?? const <MediaTitle>[],
  );

  int startPage = (_loadedPagesCache[cacheKey] ?? 0) + 1;

  if (startPage <= targetPage) {
    _fetchingCache[cacheKey] = true;
    for (int i = startPage; i <= targetPage; i++) {
      try {
        final List<MediaTitle> pageResults;
        if (section == MovieSection.discover) {
          final filter = ref.watch(movieFilterProvider);
          // Merge global sort into discover filter
          final effectiveFilter = filter.copyWith(
            sortField: sortFilter.sortField,
            sortOrder: sortFilter.sortOrder,
          );
          pageResults = await discoverUseCase(
            DiscoverMediaParams(isTv: false, filter: effectiveFilter, page: i),
          );
        } else if (section == MovieSection.tvDiscover) {
          final filter = ref.watch(tvFilterProvider);
          // Merge global sort into discover filter
          final effectiveFilter = filter.copyWith(
            sortField: sortFilter.sortField,
            sortOrder: sortFilter.sortOrder,
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
        results.addAll(pageResults);
        _loadedPagesCache[cacheKey] = i;
        if (pageResults.isEmpty || pageResults.length < 20) {
          _exhaustedCache[cacheKey] = true;
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
});

final genreSectionProvider =
    FutureProvider.family<List<MediaTitle>, ({int id, bool isTv})>((
      ref,
      params,
    ) async {
      final String regionCode = ref.watch(preferredRegionCodeProvider);
      final sortFilter = ref.watch(genreSortProvider);

      final _GenreCacheKey cacheKey = (
        regionCode: regionCode,
        genreId: params.id,
        isTv: params.isTv,
        sortField: sortFilter.sortField,
        sortOrder: sortFilter.sortOrder,
      );
      final int targetPage = _getGenreTargetPage(cacheKey);

      final repository = ref.watch(mediaRepositoryProvider);
      final discoverUseCase = DiscoverMediaUseCase(repository);

      final List<MediaTitle> results = List<MediaTitle>.from(
        _genreSectionCache[cacheKey] ?? const <MediaTitle>[],
      );

      int startPage = (_genreLoadedPagesCache[cacheKey] ?? 0) + 1;

      if (startPage <= targetPage) {
        _genreFetchingCache[cacheKey] = true;
        for (int i = startPage; i <= targetPage; i++) {
          try {
            final List<MediaTitle> pageResults = await discoverUseCase(
              DiscoverMediaParams(
                isTv: params.isTv,
                filter: MediaFilter(
                  sortField: sortFilter.sortField,
                  sortOrder: sortFilter.sortOrder,
                  genres: {params.id},
                ),
                page: i,
              ),
            );
            results.addAll(pageResults);
            _genreLoadedPagesCache[cacheKey] = i;
            if (pageResults.isEmpty || pageResults.length < 20) {
              _genreExhaustedCache[cacheKey] = true;
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
    });

final discoverPoolProvider = FutureProvider<List<MediaTitle>>((ref) async {
  final mediaType = ref.watch(exploreMediaTypeProvider);
  final section = mediaType == ExploreMediaType.movie
      ? MovieSection.discover
      : MovieSection.tvDiscover;

  final AsyncValue<List<MediaTitle>> discoverState = ref.watch(
    movieSectionProvider(section),
  );

  final List<MediaTitle> discoverMovies;
  if (discoverState.hasValue) {
    discoverMovies = discoverState.value!;
  } else {
    discoverMovies = await ref.watch(movieSectionProvider(section).future);
  }

  final Set<int> seenMovieIds = <int>{};
  final List<MediaTitle> discoverPool = <MediaTitle>[];

  for (final MediaTitle movie in discoverMovies) {
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

int _getMoodTargetPage(_MoodCacheKey cacheKey) =>
    _moodTargetPages[cacheKey] ?? 2;
int _getHiddenGemsTargetPage(_HiddenGemsCacheKey cacheKey) =>
    _hiddenGemsTargetPages[cacheKey] ?? 2;

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
  _hiddenGemsTargetPages[cacheKey] = _getHiddenGemsTargetPage(cacheKey) + 2;
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

final moviesProvider = Provider<AsyncValue<List<MediaTitle>>>((ref) {
  final mediaType = ref.watch(exploreMediaTypeProvider);
  final section = mediaType == ExploreMediaType.movie
      ? MovieSection.discover
      : MovieSection.tvDiscover;
  return ref.watch(movieSectionProvider(section));
});

final mediaImagesProvider =
    FutureProvider.family<MediaImages, ({int id, bool isTv})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(mediaRepositoryProvider);
      return repository.fetchMediaImages(params.id, isTv: params.isTv);
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
