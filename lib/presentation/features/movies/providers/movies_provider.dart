import 'package:cineverse/core/config/region_preferences.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/media_images.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/usecases/get_movie_section_use_case.dart';
import 'package:cineverse/domain/usecases/discover_media_use_case.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/explore_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaFilterOption {
  const MediaFilterOption({required this.label, required this.section});
  final String label;
  final MovieSection section;
}

final movieFilterOptions = Provider<List<MediaFilterOption>>((ref) => const [
  MediaFilterOption(label: 'Popular', section: MovieSection.popular),
  MediaFilterOption(label: 'Top Rated', section: MovieSection.topRated),
  MediaFilterOption(label: 'In Theaters', section: MovieSection.nowPlaying),
  MediaFilterOption(label: 'Coming Soon', section: MovieSection.upcoming),
  MediaFilterOption(label: 'Filtered', section: MovieSection.discover),
]);

final tvFilterOptions = Provider<List<MediaFilterOption>>((ref) => const [
  MediaFilterOption(label: 'Popular', section: MovieSection.tvPopular),
  MediaFilterOption(label: 'Top Rated', section: MovieSection.tvTopRated),
  MediaFilterOption(label: 'On The Air', section: MovieSection.tvOnTheAir),
  MediaFilterOption(label: 'Airing Today', section: MovieSection.tvAiringToday),
  MediaFilterOption(label: 'Filtered', section: MovieSection.tvDiscover),
]);

final selectedMovieFilterProvider = NotifierProvider<SelectedMovieFilter, MediaFilterOption>(SelectedMovieFilter.new);

class SelectedMovieFilter extends Notifier<MediaFilterOption> {
  @override
  MediaFilterOption build() => ref.watch(movieFilterOptions).first;
  void setFilter(MediaFilterOption option) => state = option;
}

final selectedTvFilterProvider = NotifierProvider<SelectedTvFilter, MediaFilterOption>(SelectedTvFilter.new);

class SelectedTvFilter extends Notifier<MediaFilterOption> {
  @override
  MediaFilterOption build() => ref.watch(tvFilterOptions).first;
  void setFilter(MediaFilterOption option) => state = option;
}

final getMovieSectionUseCaseProvider = Provider<GetMovieSectionUseCase>((ref) {
  return GetMovieSectionUseCase(ref.watch(mediaRepositoryProvider));
});

typedef _SectionCacheKey = ({String regionCode, MovieSection section});
typedef _GenreCacheKey = ({String regionCode, int genreId, bool isTv});

final Map<_SectionCacheKey, List<MediaTitle>> _movieSectionCache = {};
final Map<_SectionCacheKey, int> _loadedPagesCache = {};
final Map<_SectionCacheKey, bool> _fetchingCache = {};
final Map<_SectionCacheKey, int> _targetPages = {};
final Map<_GenreCacheKey, List<MediaTitle>> _genreSectionCache = {};
final Map<_GenreCacheKey, int> _genreLoadedPagesCache = {};
final Map<_GenreCacheKey, bool> _genreFetchingCache = {};
final Map<_GenreCacheKey, int> _genreTargetPages = {};

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
  final _SectionCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    section: section,
  );
  if (_fetchingCache[cacheKey] == true) {
    return;
  }
  _targetPages[cacheKey] = _getTargetPage(cacheKey) + 2;
  ref.invalidate(movieSectionProvider(section));
}

void loadNextGenrePages(WidgetRef ref, int genreId, {bool isTv = false}) {
  final _GenreCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    genreId: genreId,
    isTv: isTv,
  );
  if (_genreFetchingCache[cacheKey] == true) {
    return;
  }
  _genreTargetPages[cacheKey] = _getGenreTargetPage(cacheKey) + 2;
  ref.invalidate(genreSectionProvider((id: genreId, isTv: isTv)));
}

void resetMovieSection(WidgetRef ref, MovieSection section) {
  final _SectionCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    section: section,
  );
  _movieSectionCache.remove(cacheKey);
  _loadedPagesCache.remove(cacheKey);
  _targetPages[cacheKey] = 2;
  ref.invalidate(movieSectionProvider(section));
}

final movieSectionProvider =
    FutureProvider.family<List<MediaTitle>, MovieSection>((ref, section) async {
      final String regionCode = ref.watch(preferredRegionCodeProvider);
      
      // Watch filters if we are in discover mode to trigger re-runs
      if (section == MovieSection.discover) {
        ref.watch(movieFilterProvider);
      } else if (section == MovieSection.tvDiscover) {
        ref.watch(tvFilterProvider);
      }

      final _SectionCacheKey cacheKey = (
        regionCode: regionCode,
        section: section,
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
              pageResults = await discoverUseCase(DiscoverMediaParams(
                isTv: false,
                filter: filter,
                page: i,
              ));
            } else if (section == MovieSection.tvDiscover) {
              final filter = ref.watch(tvFilterProvider);
              pageResults = await discoverUseCase(DiscoverMediaParams(
                isTv: true,
                filter: filter,
                page: i,
              ));
            } else {
              pageResults = await useCase(section, page: i);
            }
            results.addAll(pageResults);
            _loadedPagesCache[cacheKey] = i;
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
    FutureProvider.family<List<MediaTitle>, ({int id, bool isTv})>((ref, params) async {
      final String regionCode = ref.watch(preferredRegionCodeProvider);
      final _GenreCacheKey cacheKey = (
        regionCode: regionCode,
        genreId: params.id,
        isTv: params.isTv,
      );
      final int targetPage = _getGenreTargetPage(cacheKey);

      final repository = ref.watch(mediaRepositoryProvider);
      final List<MediaTitle> results = List<MediaTitle>.from(
        _genreSectionCache[cacheKey] ?? const <MediaTitle>[],
      );

      int startPage = (_genreLoadedPagesCache[cacheKey] ?? 0) + 1;

      if (startPage <= targetPage) {
        _genreFetchingCache[cacheKey] = true;
        for (int i = startPage; i <= targetPage; i++) {
          try {
            final List<MediaTitle> pageResults = params.isTv 
                ? await repository.fetchTvShowsForGenre(params.id, page: i)
                : await repository.fetchMoviesForGenre(params.id, page: i);
            results.addAll(pageResults);
            _genreLoadedPagesCache[cacheKey] = i;
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
  final section = mediaType == ExploreMediaType.movie ? MovieSection.discover : MovieSection.tvDiscover;
  
  final AsyncValue<List<MediaTitle>> discoverState = ref.watch(
    movieSectionProvider(section),
  );
  final List<MediaTitle> discoverMovies = discoverState.value ?? [];

  final Set<int> seenMovieIds = <int>{};
  final List<MediaTitle> discoverPool = <MediaTitle>[];

  for (final MediaTitle movie in discoverMovies) {
    if (seenMovieIds.add(movie.id)) {
      discoverPool.add(movie);
    }
  }

  return discoverPool;
});

final moviesProvider = Provider<AsyncValue<List<MediaTitle>>>((ref) {
  final mediaType = ref.watch(exploreMediaTypeProvider);
  final section = mediaType == ExploreMediaType.movie ? MovieSection.discover : MovieSection.tvDiscover;
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
