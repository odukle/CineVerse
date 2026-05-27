import 'dart:async';

import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/search_collection.dart';
import 'package:cineverse/domain/entities/search_keyword.dart';
import 'package:cineverse/domain/entities/search_company.dart';
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

enum SearchCategory {
  movies('Movies'),
  tvShows('TV Shows'),
  persons('Persons'),
  collections('Collections'),
  keywords('Keywords'),
  companies('Companies');

  const SearchCategory(this.label);
  final String label;
}

class SearchState {
  const SearchState({
    this.query = '',
    this.suggestions = const [],
    this.results = const [],
    this.movieResults = const [],
    this.tvResults = const [],
    this.personResults = const [],
    this.collectionResults = const [],
    this.keywordResults = const [],
    this.companyResults = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasSearched = false,
    this.currentPage = 1,
    this.moviePage = 1,
    this.tvPage = 1,
    this.personPage = 1,
    this.collectionPage = 1,
    this.keywordPage = 1,
    this.companyPage = 1,
    this.hasMore = false,
    this.movieHasMore = false,
    this.tvHasMore = false,
    this.personHasMore = false,
    this.collectionHasMore = false,
    this.keywordHasMore = false,
    this.companyHasMore = false,
    this.error,
    this.filter = const GlobalMediaFilter(),
    this.selectedCategory = SearchCategory.movies,
  });

  final String query;
  final List<MediaTitle> suggestions;
  final List<MediaTitle> results;
  final List<MediaTitle> movieResults;
  final List<MediaTitle> tvResults;
  final List<MediaTitle> personResults;
  final List<SearchCollection> collectionResults;
  final List<SearchKeyword> keywordResults;
  final List<SearchCompany> companyResults;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasSearched;
  final int currentPage;
  final int moviePage;
  final int tvPage;
  final int personPage;
  final int collectionPage;
  final int keywordPage;
  final int companyPage;
  final bool hasMore;
  final bool movieHasMore;
  final bool tvHasMore;
  final bool personHasMore;
  final bool collectionHasMore;
  final bool keywordHasMore;
  final bool companyHasMore;
  final String? error;
  final GlobalMediaFilter filter;
  final SearchCategory selectedCategory;

  SearchState copyWith({
    String? query,
    List<MediaTitle>? suggestions,
    List<MediaTitle>? results,
    List<MediaTitle>? movieResults,
    List<MediaTitle>? tvResults,
    List<MediaTitle>? personResults,
    List<SearchCollection>? collectionResults,
    List<SearchKeyword>? keywordResults,
    List<SearchCompany>? companyResults,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasSearched,
    int? currentPage,
    int? moviePage,
    int? tvPage,
    int? personPage,
    int? collectionPage,
    int? keywordPage,
    int? companyPage,
    bool? hasMore,
    bool? movieHasMore,
    bool? tvHasMore,
    bool? personHasMore,
    bool? collectionHasMore,
    bool? keywordHasMore,
    bool? companyHasMore,
    String? error,
    GlobalMediaFilter? filter,
    SearchCategory? selectedCategory,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      movieResults: movieResults ?? this.movieResults,
      tvResults: tvResults ?? this.tvResults,
      personResults: personResults ?? this.personResults,
      collectionResults: collectionResults ?? this.collectionResults,
      keywordResults: keywordResults ?? this.keywordResults,
      companyResults: companyResults ?? this.companyResults,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasSearched: hasSearched ?? this.hasSearched,
      currentPage: currentPage ?? this.currentPage,
      moviePage: moviePage ?? this.moviePage,
      tvPage: tvPage ?? this.tvPage,
      personPage: personPage ?? this.personPage,
      collectionPage: collectionPage ?? this.collectionPage,
      keywordPage: keywordPage ?? this.keywordPage,
      companyPage: companyPage ?? this.companyPage,
      hasMore: hasMore ?? this.hasMore,
      movieHasMore: movieHasMore ?? this.movieHasMore,
      tvHasMore: tvHasMore ?? this.tvHasMore,
      personHasMore: personHasMore ?? this.personHasMore,
      collectionHasMore: collectionHasMore ?? this.collectionHasMore,
      keywordHasMore: keywordHasMore ?? this.keywordHasMore,
      companyHasMore: companyHasMore ?? this.companyHasMore,
      error: error,
      filter: filter ?? this.filter,
      selectedCategory: selectedCategory ?? this.selectedCategory,
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
      results: const [],
      movieResults: const [],
      tvResults: const [],
      personResults: const [],
      collectionResults: const [],
      keywordResults: const [],
      companyResults: const [],
      currentPage: 1,
      moviePage: 1,
      tvPage: 1,
      personPage: 1,
      collectionPage: 1,
      keywordPage: 1,
      companyPage: 1,
      hasMore: false,
      movieHasMore: false,
      tvHasMore: false,
      personHasMore: false,
      collectionHasMore: false,
      keywordHasMore: false,
      companyHasMore: false,
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
        await _fetchCategoryResults(state.selectedCategory, 1);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
      );
    }
  }

  Future<void> _fetchCategoryResults(SearchCategory category, int page) async {
    final repo = ref.read(mediaRepositoryProvider);
    final query = state.query;

    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      switch (category) {
        case SearchCategory.movies:
          final results = await repo.searchMovies(query, page: page);
          state = state.copyWith(
            movieResults: page == 1 ? results : [...state.movieResults, ...results],
            moviePage: page,
            movieHasMore: results.length >= 20,
            isLoading: false,
          );
          break;
        case SearchCategory.tvShows:
          final results = await repo.searchTvShows(query, page: page);
          state = state.copyWith(
            tvResults: page == 1 ? results : [...state.tvResults, ...results],
            tvPage: page,
            tvHasMore: results.length >= 20,
            isLoading: false,
          );
          break;
        case SearchCategory.persons:
          final results = await repo.searchPersons(query, page: page);
          state = state.copyWith(
            personResults: page == 1 ? results : [...state.personResults, ...results],
            personPage: page,
            personHasMore: results.length >= 20,
            isLoading: false,
          );
          break;
        case SearchCategory.collections:
          final results = await repo.searchCollections(query, page: page);
          state = state.copyWith(
            collectionResults: page == 1 ? results : [...state.collectionResults, ...results],
            collectionPage: page,
            collectionHasMore: results.length >= 20,
            isLoading: false,
          );
          break;
        case SearchCategory.keywords:
          final results = await repo.searchKeywords(query, page: page);
          state = state.copyWith(
            keywordResults: page == 1 ? results : [...state.keywordResults, ...results],
            keywordPage: page,
            keywordHasMore: results.length >= 20,
            isLoading: false,
          );
          break;
        case SearchCategory.companies:
          final results = await repo.searchCompanies(query, page: page);
          state = state.copyWith(
            companyResults: page == 1 ? results : [...state.companyResults, ...results],
            companyPage: page,
            companyHasMore: results.length >= 20,
            isLoading: false,
          );
          break;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed. Please try again.',
      );
    }
  }

  void setCategory(SearchCategory category) {
    if (category == state.selectedCategory) return;
    state = state.copyWith(selectedCategory: category);

    if (state.query.isNotEmpty && !state.isLoading) {
      bool hasNoResults = false;
      switch (category) {
        case SearchCategory.movies:
          hasNoResults = state.movieResults.isEmpty;
          break;
        case SearchCategory.tvShows:
          hasNoResults = state.tvResults.isEmpty;
          break;
        case SearchCategory.persons:
          hasNoResults = state.personResults.isEmpty;
          break;
        case SearchCategory.collections:
          hasNoResults = state.collectionResults.isEmpty;
          break;
        case SearchCategory.keywords:
          hasNoResults = state.keywordResults.isEmpty;
          break;
        case SearchCategory.companies:
          hasNoResults = state.companyResults.isEmpty;
          break;
      }

      if (hasNoResults) {
        _fetchCategoryResults(category, 1);
      }
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

    if (state.isLoadingMore) return;

    final SearchCategory category = state.selectedCategory;
    bool canLoadMore = false;
    int nextPage = 1;

    switch (category) {
      case SearchCategory.movies:
        canLoadMore = state.movieHasMore;
        nextPage = state.moviePage + 1;
        break;
      case SearchCategory.tvShows:
        canLoadMore = state.tvHasMore;
        nextPage = state.tvPage + 1;
        break;
      case SearchCategory.persons:
        canLoadMore = state.personHasMore;
        nextPage = state.personPage + 1;
        break;
      case SearchCategory.collections:
        canLoadMore = state.collectionHasMore;
        nextPage = state.collectionPage + 1;
        break;
      case SearchCategory.keywords:
        canLoadMore = state.keywordHasMore;
        nextPage = state.keywordPage + 1;
        break;
      case SearchCategory.companies:
        canLoadMore = state.companyHasMore;
        nextPage = state.companyPage + 1;
        break;
    }

    if (!canLoadMore) return;

    state = state.copyWith(isLoadingMore: true);
    await _fetchCategoryResults(category, nextPage);
    state = state.copyWith(isLoadingMore: false);
  }

  void updateFilter(GlobalMediaFilter filter) {
    state = state.copyWith(filter: filter);
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
