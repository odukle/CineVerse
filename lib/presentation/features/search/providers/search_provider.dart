import 'dart:async';

import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/usecases/search_multi_use_case.dart';
import 'package:cineverse/domain/usecases/discover_media_use_case.dart';
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
    this.results = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasSearched = false,
    this.currentPage = 1,
    this.hasMore = false,
    this.error,
    this.filter = const GlobalMediaFilter(),
  });

  final String query;
  final List<MediaTitle> suggestions;
  final List<MediaTitle> results;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasSearched;
  final int currentPage;
  final bool hasMore;
  final String? error;
  final GlobalMediaFilter filter;

  SearchState copyWith({
    String? query,
    List<MediaTitle>? suggestions,
    List<MediaTitle>? results,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasSearched,
    int? currentPage,
    bool? hasMore,
    String? error,
    GlobalMediaFilter? filter,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasSearched: hasSearched ?? this.hasSearched,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
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
      currentPage: 1,
      hasMore: false,
    );

    try {
      final List<MediaTitle> results;
      if (isDiscoverMode) {
        results = await _performDiscover(1, query);
      } else {
        final useCase = ref.read(searchMultiUseCaseProvider);
        results = await useCase(
          SearchMultiParams(query: query, page: 1),
        );
      }

      state = state.copyWith(
        results: results,
        suggestions: const [],
        isLoading: false,
        hasMore: results.length >= 20,
      );
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

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final List<MediaTitle> newResults;

      if (!state.filter.isDefault) {
        newResults = await _performDiscover(nextPage, state.query);
      } else {
        final useCase = ref.read(searchMultiUseCaseProvider);
        newResults = await useCase(
          SearchMultiParams(query: state.query, page: nextPage),
        );
      }

      if (newResults.isEmpty) {
        state = state.copyWith(isLoadingMore: false, hasMore: false);
      } else {
        state = state.copyWith(
          results: [...state.results, ...newResults],
          currentPage: nextPage,
          isLoadingMore: false,
          hasMore: newResults.length >= 20,
        );
      }
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
