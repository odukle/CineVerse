import 'package:cineverse/core/config/region_preferences.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/usecases/get_movie_section_use_case.dart';
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
]);

final tvFilterOptions = Provider<List<MediaFilterOption>>((ref) => const [
  MediaFilterOption(label: 'Popular', section: MovieSection.tvPopular),
  MediaFilterOption(label: 'Top Rated', section: MovieSection.tvTopRated),
  MediaFilterOption(label: 'On The Air', section: MovieSection.tvOnTheAir),
  MediaFilterOption(label: 'Airing Today', section: MovieSection.tvAiringToday),
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
typedef _GenreCacheKey = ({String regionCode, int genreId});

final Map<_SectionCacheKey, List<MediaTitle>> _movieSectionCache = {};
final Map<_SectionCacheKey, int> _loadedPagesCache = {};
final Map<_SectionCacheKey, bool> _fetchingCache = {};
final Map<_SectionCacheKey, int> _targetPages = {};
final Map<_GenreCacheKey, List<MediaTitle>> _genreSectionCache = {};
final Map<_GenreCacheKey, int> _genreLoadedPagesCache = {};
final Map<_GenreCacheKey, bool> _genreFetchingCache = {};
final Map<_GenreCacheKey, int> _genreTargetPages = {};

int _getTargetPage(_SectionCacheKey cacheKey) => _targetPages[cacheKey] ?? 2;
int _getGenreTargetPage(_GenreCacheKey cacheKey) =>
    _genreTargetPages[cacheKey] ?? 2;

final movieGenresProvider = FutureProvider<List<MovieGenre>>((ref) async {
  return ref.watch(mediaRepositoryProvider).fetchMovieGenres();
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

void loadNextGenrePages(WidgetRef ref, int genreId) {
  final _GenreCacheKey cacheKey = (
    regionCode: ref.read(preferredRegionCodeProvider),
    genreId: genreId,
  );
  if (_genreFetchingCache[cacheKey] == true) {
    return;
  }
  _genreTargetPages[cacheKey] = _getGenreTargetPage(cacheKey) + 2;
  ref.invalidate(genreSectionProvider(genreId));
}

final movieSectionProvider =
    FutureProvider.family<List<MediaTitle>, MovieSection>((ref, section) async {
      final String regionCode = ref.watch(preferredRegionCodeProvider);
      final _SectionCacheKey cacheKey = (
        regionCode: regionCode,
        section: section,
      );
      final int targetPage = _getTargetPage(cacheKey);

      final GetMovieSectionUseCase useCase = ref.watch(
        getMovieSectionUseCaseProvider,
      );
      final List<MediaTitle> results = List<MediaTitle>.from(
        _movieSectionCache[cacheKey] ?? const <MediaTitle>[],
      );

      int startPage = (_loadedPagesCache[cacheKey] ?? 0) + 1;

      if (startPage <= targetPage) {
        _fetchingCache[cacheKey] = true;
        for (int i = startPage; i <= targetPage; i++) {
          try {
            final List<MediaTitle> pageResults = await useCase(section, page: i);
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
    FutureProvider.family<List<MediaTitle>, int>((ref, genreId) async {
      final String regionCode = ref.watch(preferredRegionCodeProvider);
      final _GenreCacheKey cacheKey = (
        regionCode: regionCode,
        genreId: genreId,
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
            final List<MediaTitle> pageResults = await repository
                .fetchMoviesForGenre(genreId, page: i);
            results.addAll(pageResults);
            _genreLoadedPagesCache[cacheKey] = i;
          } catch (error, stackTrace) {
            debugPrint('[genreSectionProvider:$genreId:$i] $error');
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
  final AsyncValue<List<MediaTitle>> discoverState = ref.watch(
    movieSectionProvider(MovieSection.discover),
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
  return ref.watch(movieSectionProvider(MovieSection.discover));
});

