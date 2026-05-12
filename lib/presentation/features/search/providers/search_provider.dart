import 'dart:async';

import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/usecases/search_multi_use_case.dart';
import 'package:cineverse/domain/usecases/discover_media_use_case.dart';
import 'package:cineverse/presentation/features/search/providers/search_history_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchMultiUseCaseProvider = Provider<SearchMultiUseCase>((ref) {
  return SearchMultiUseCase(ref.watch(mediaRepositoryProvider));
});

final discoverMediaUseCaseProvider = Provider<DiscoverMediaUseCase>((ref) {
  return DiscoverMediaUseCase(ref.watch(mediaRepositoryProvider));
});

class SearchState {
  const SearchState({
    this.query = '',
    this.suggestions = const [],
    this.results = const [], // Keep for backward compatibility or mixed results
    this.movieResults = const [],
    this.tvResults = const [],
    this.personResults = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasSearched = false,
    this.currentPage = 1,
    this.moviePage = 1,
    this.tvPage = 1,
    this.personPage = 1,
    this.hasMore = false,
    this.movieHasMore = false,
    this.tvHasMore = false,
    this.personHasMore = false,
    this.error,
    this.filter = const GlobalMediaFilter(),
  });

  final String query;
  final List<MediaTitle> suggestions;
  final List<MediaTitle> results;
  final List<MediaTitle> movieResults;
  final List<MediaTitle> tvResults;
  final List<MediaTitle> personResults;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasSearched;
  final int currentPage;
  final int moviePage;
  final int tvPage;
  final int personPage;
  final bool hasMore;
  final bool movieHasMore;
  final bool tvHasMore;
  final bool personHasMore;
  final String? error;
  final GlobalMediaFilter filter;

  SearchState copyWith({
    String? query,
    List<MediaTitle>? suggestions,
    List<MediaTitle>? results,
    List<MediaTitle>? movieResults,
    List<MediaTitle>? tvResults,
    List<MediaTitle>? personResults,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasSearched,
    int? currentPage,
    int? moviePage,
    int? tvPage,
    int? personPage,
    bool? hasMore,
    bool? movieHasMore,
    bool? tvHasMore,
    bool? personHasMore,
    String? error,
    GlobalMediaFilter? filter,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      movieResults: movieResults ?? this.movieResults,
      tvResults: tvResults ?? this.tvResults,
      personResults: personResults ?? this.personResults,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasSearched: hasSearched ?? this.hasSearched,
      currentPage: currentPage ?? this.currentPage,
      moviePage: moviePage ?? this.moviePage,
      tvPage: tvPage ?? this.tvPage,
      personPage: personPage ?? this.personPage,
      hasMore: hasMore ?? this.hasMore,
      movieHasMore: movieHasMore ?? this.movieHasMore,
      tvHasMore: tvHasMore ?? this.tvHasMore,
      personHasMore: personHasMore ?? this.personHasMore,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchState();
  }

  void onQueryChanged(String query) {
    if (query == state.query) return;

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      // If we have active filters, don't clear the whole state, just the query
      if (!state.filter.isDefault) {
        state = state.copyWith(query: query, suggestions: const []);
        return;
      }
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query);
    });
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  Future<void> _fetchSuggestions(String query) async {
    // We only fetch suggestions for keyword search
    try {
      final useCase = ref.read(searchMultiUseCaseProvider);
      final results = await useCase(SearchMultiParams(query: query, page: 1));
      state = state.copyWith(
        suggestions: results.take(8).toList(growable: false),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load suggestions',
      );
    }
  }

  Future<void> submitSearch([String? overrideQuery]) async {
    final query = overrideQuery ?? state.query;
    final isDiscoverMode = !state.filter.isDefault;

    if (query.isEmpty && !isDiscoverMode) return;

    _debounceTimer?.cancel();
    state = state.copyWith(
      query: query,
      isLoading: true,
      hasSearched: true,
      error: null,
      results: [],
      movieResults: [],
      tvResults: [],
      personResults: [],
      currentPage: 1,
      moviePage: 1,
      tvPage: 1,
      personPage: 1,
      hasMore: false,
      movieHasMore: false,
      tvHasMore: false,
      personHasMore: false,
    );

    if (query.isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).addEntry(query);
    }

    try {
      if (isDiscoverMode) {
        final results = await _performDiscover(1, query);
        state = state.copyWith(
          results: results,
          isLoading: false,
          hasMore: results.length >= 20,
        );
      } else {
        final repo = ref.read(mediaRepositoryProvider);
        
        final results = await Future.wait([
          repo.searchMovies(query, page: 1),
          repo.searchTvShows(query, page: 1),
          repo.searchPersons(query, page: 1),
        ]);

        state = state.copyWith(
          movieResults: results[0],
          tvResults: results[1],
          personResults: results[2],
          suggestions: const [],
          isLoading: false,
          movieHasMore: results[0].length >= 20,
          tvHasMore: results[1].length >= 20,
          personHasMore: results[2].length >= 20,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
      );
    }
  }

  Future<List<MediaTitle>> _performDiscover(int page, [String? query]) async {
    final discoverUseCase = ref.read(discoverMediaUseCaseProvider);
    final filter = state.filter.toMediaFilter();
    final searchQuery = query ?? state.query;

    if (state.filter.mediaType == GlobalMediaType.movie) {
      return await discoverUseCase(DiscoverMediaParams(
        isTv: false,
        filter: filter,
        query: searchQuery,
        page: page,
      ));
    } else if (state.filter.mediaType == GlobalMediaType.tv) {
      return await discoverUseCase(DiscoverMediaParams(
        isTv: true,
        filter: filter,
        query: searchQuery,
        page: page,
      ));
    } else {
      // Both
      final movieResults = await discoverUseCase(DiscoverMediaParams(
        isTv: false,
        filter: filter,
        query: searchQuery,
        page: page,
      ));
      final tvResults = await discoverUseCase(DiscoverMediaParams(
        isTv: true,
        filter: filter,
        query: searchQuery,
        page: page,
      ));

      final combined = [...movieResults, ...tvResults];
      // Sort combined results based on the filter's sort field
      combined.sort((a, b) {
        int comparison = 0;
        switch (state.filter.sortField) {
          case SortField.popularity:
            comparison = a.popularity.compareTo(b.popularity);
            break;
          case SortField.voteAverage:
            comparison = (a.voteAverage ?? 0).compareTo(b.voteAverage ?? 0);
            break;
          case SortField.voteCount:
            comparison = a.voteCount.compareTo(b.voteCount);
            break;
          case SortField.releaseDate:
            final dateA = DateTime.tryParse(a.releaseDate ?? '') ?? DateTime(0);
            final dateB = DateTime.tryParse(b.releaseDate ?? '') ?? DateTime(0);
            comparison = dateA.compareTo(dateB);
            break;
          default:
            comparison = 0;
        }
        return state.filter.sortOrder == SortOrder.descending
            ? -comparison
            : comparison;
      });

      return combined;
    }
  }

  Future<void> loadMore([GlobalMediaType? type]) async {
    final isDiscoverMode = !state.filter.isDefault;
    
    if (isDiscoverMode) {
      if (state.isLoadingMore || !state.hasMore) return;
      state = state.copyWith(isLoadingMore: true);
      try {
        final nextPage = state.currentPage + 1;
        final newResults = await _performDiscover(nextPage, state.query);
        state = state.copyWith(
          results: [...state.results, ...newResults],
          currentPage: nextPage,
          isLoadingMore: false,
          hasMore: newResults.length >= 20,
        );
      } catch (e) {
        state = state.copyWith(isLoadingMore: false);
      }
      return;
    }

    // Tabbed mode
    if (type == null) return;

    final bool canLoadMore;
    final int nextPage;
    switch (type) {
      case GlobalMediaType.movie:
        canLoadMore = state.movieHasMore;
        nextPage = state.moviePage + 1;
        break;
      case GlobalMediaType.tv:
        canLoadMore = state.tvHasMore;
        nextPage = state.tvPage + 1;
        break;
      case GlobalMediaType.person:
        canLoadMore = state.personHasMore;
        nextPage = state.personPage + 1;
        break;
      default:
        return;
    }

    if (state.isLoadingMore || !canLoadMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(mediaRepositoryProvider);
      final List<MediaTitle> newResults;
      
      switch (type) {
        case GlobalMediaType.movie:
          newResults = await repo.searchMovies(state.query, page: nextPage);
          state = state.copyWith(
            movieResults: [...state.movieResults, ...newResults],
            moviePage: nextPage,
            movieHasMore: newResults.length >= 20,
          );
          break;
        case GlobalMediaType.tv:
          newResults = await repo.searchTvShows(state.query, page: nextPage);
          state = state.copyWith(
            tvResults: [...state.tvResults, ...newResults],
            tvPage: nextPage,
            tvHasMore: newResults.length >= 20,
          );
          break;
        case GlobalMediaType.person:
          newResults = await repo.searchPersons(state.query, page: nextPage);
          state = state.copyWith(
            personResults: [...state.personResults, ...newResults],
            personPage: nextPage,
            personHasMore: newResults.length >= 20,
          );
          break;
        default:
          newResults = [];
      }
      
      state = state.copyWith(isLoadingMore: false);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void updateFilter(GlobalMediaFilter filter) {
    state = state.copyWith(filter: filter);
    // If we have a searched state or a query, or it's discover mode, trigger search immediately
    if (state.hasSearched || !filter.isDefault) {
      submitSearch();
    }
  }

  Future<List<MediaTitle>> searchPersons(String query) async {
    if (query.length < 2) return [];
    try {
      final repository = ref.read(mediaRepositoryProvider);
      return await repository.searchPersons(query, page: 1);
    } catch (e) {
      return [];
    }
  }

  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
