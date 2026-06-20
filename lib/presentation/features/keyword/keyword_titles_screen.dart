import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum KeywordMediaType {
  all,
  movies,
  tvShows;

  const KeywordMediaType();

  String label(BuildContext context) => switch (this) {
    KeywordMediaType.all => context.l10n.all,
    KeywordMediaType.movies => context.l10n.toggleMovies,
    KeywordMediaType.tvShows => context.l10n.navTvShows,
  };
}

class KeywordTitlesState {
  const KeywordTitlesState({
    this.results = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.page = 1,
    this.hasMore = true,
    this.selectedType = KeywordMediaType.all,
    this.selectedSort = SortField.popularity,
    this.error,
  });

  final List<MediaTitle> results;
  final bool isLoading;
  final bool isLoadingMore;
  final int page;
  final bool hasMore;
  final KeywordMediaType selectedType;
  final SortField selectedSort;
  final String? error;

  KeywordTitlesState copyWith({
    List<MediaTitle>? results,
    bool? isLoading,
    bool? isLoadingMore,
    int? page,
    bool? hasMore,
    KeywordMediaType? selectedType,
    SortField? selectedSort,
    String? error,
  }) {
    return KeywordTitlesState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      selectedType: selectedType ?? this.selectedType,
      selectedSort: selectedSort ?? this.selectedSort,
      error: error,
    );
  }
}

class KeywordTitlesNotifier extends Notifier<KeywordTitlesState> {
  KeywordTitlesNotifier(this.keywordId);
  final int keywordId;

  @override
  KeywordTitlesState build() {
    Future.microtask(() => loadInitial());
    return const KeywordTitlesState();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      page: 1,
      results: const [],
      hasMore: true,
    );
    await _fetchData(1);
  }

  Future<void> _fetchData(int page) async {
    final repo = ref.read(mediaRepositoryProvider);
    final filter = MediaFilter(
      sortField: state.selectedSort,
      sortOrder: SortOrder.descending,
    );

    try {
      List<MediaTitle> fetchedResults = [];
      bool hasMoreResults = false;

      if (state.selectedType == KeywordMediaType.movies) {
        final movies = await repo.discoverMedia(
          isTv: false,
          filter: filter,
          page: page,
          withKeywords: keywordId.toString(),
        );
        fetchedResults = movies;
        hasMoreResults = movies.length >= 20;
      } else if (state.selectedType == KeywordMediaType.tvShows) {
        final tv = await repo.discoverMedia(
          isTv: true,
          filter: filter,
          page: page,
          withKeywords: keywordId.toString(),
        );
        fetchedResults = tv;
        hasMoreResults = tv.length >= 20;
      } else {
        // All
        final movies = await repo.discoverMedia(
          isTv: false,
          filter: filter,
          page: page,
          withKeywords: keywordId.toString(),
        );
        final tv = await repo.discoverMedia(
          isTv: true,
          filter: filter,
          page: page,
          withKeywords: keywordId.toString(),
        );

        final combined = [...movies, ...tv];
        _sortResults(combined, state.selectedSort);
        fetchedResults = combined;
        hasMoreResults = movies.length >= 20 || tv.length >= 20;
      }

      state = state.copyWith(
        results: page == 1
            ? fetchedResults
            : [...state.results, ...fetchedResults],
        page: page,
        isLoading: false,
        isLoadingMore: false,
        hasMore: hasMoreResults,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to load titles',
      );
    }
  }

  void _sortResults(List<MediaTitle> list, SortField sortField) {
    list.sort((a, b) {
      int comparison = 0;
      switch (sortField) {
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
      return -comparison;
    });
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    await _fetchData(state.page + 1);
  }

  void setMediaType(KeywordMediaType type) {
    if (type == state.selectedType) return;
    state = state.copyWith(selectedType: type);
    loadInitial();
  }

  void setSortField(SortField sortField) {
    if (sortField == state.selectedSort) return;
    state = state.copyWith(selectedSort: sortField);
    loadInitial();
  }
}

final keywordTitlesProvider =
    NotifierProvider.family<KeywordTitlesNotifier, KeywordTitlesState, int>(
      KeywordTitlesNotifier.new,
    );

class KeywordTitlesScreen extends ConsumerStatefulWidget {
  const KeywordTitlesScreen({
    super.key,
    required this.keywordId,
    required this.keywordName,
  });

  final int keywordId;
  final String keywordName;

  @override
  ConsumerState<KeywordTitlesScreen> createState() =>
      _KeywordTitlesScreenState();
}

class _KeywordTitlesScreenState extends ConsumerState<KeywordTitlesScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(keywordTitlesProvider(widget.keywordId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(keywordTitlesProvider(widget.keywordId));

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        title: Text(
          '#${widget.keywordName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cinemaGradientTop,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            context.pop();
          },
        ),
        actions: [
          PopupMenuButton<SortField>(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onSelected: (sortField) {
              HapticFeedback.selectionClick();
              ref
                  .read(keywordTitlesProvider(widget.keywordId).notifier)
                  .setSortField(sortField);
            },
            itemBuilder: (context) =>
                [
                      SortField.popularity,
                      SortField.voteAverage,
                      SortField.releaseDate,
                      SortField.voteCount,
                    ]
                    .map(
                      (f) => PopupMenuItem(
                        value: f,
                        child: Row(
                          children: [
                            if (state.selectedSort == f)
                              Icon(
                                Icons.check_rounded,
                                color: AppColors.cinemaAccent,
                                size: 18,
                              )
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Text(
                              f.label,
                              style: TextStyle(
                                color: state.selectedSort == f
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: state.selectedSort == f
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Media Type Filters
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: KeywordMediaType.values.length,
                itemBuilder: (context, index) {
                  final type = KeywordMediaType.values[index];
                  final isSelected = state.selectedType == type;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type.label(context)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          HapticFeedback.selectionClick();
                          ref
                              .read(
                                keywordTitlesProvider(
                                  widget.keywordId,
                                ).notifier,
                              )
                              .setMediaType(type);
                        }
                      },
                      backgroundColor: AppColors.cinemaSurface.withValues(
                        alpha: 0.5,
                      ),
                      selectedColor: AppColors.cinemaAccent,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(KeywordTitlesState state) {
    if (state.isLoading && state.results.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.cinemaAccent),
      );
    }

    if (state.error != null && state.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white30,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(keywordTitlesProvider(widget.keywordId).notifier)
                    .loadInitial(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cinemaAccent,
                ),
                child: Text(
                  context.l10n.retry,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final results = state.results;

    if (results.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noTitlesFoundForKeyword,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 15,
          ),
        ),
      );
    }

    const double crossAxisSpacing = 12;
    const double mainAxisSpacing = 16;
    const int crossAxisCount = 3;
    final double cardWidth =
        (MediaQuery.sizeOf(context).width - (16 * 2) - (crossAxisSpacing * 2)) /
        crossAxisCount;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final media = results[index];
              return MediaPosterGridCard(
                movie: media,
                sectionTitle: 'keyword_${widget.keywordId}',
                width: cardWidth,
                isTvTitle: media.mediaType == GlobalMediaType.tv,
              );
            }, childCount: results.length),
          ),
        ),
        if (state.isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.cinemaAccent),
              ),
            ),
          )
        else if (state.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(keywordTitlesProvider(widget.keywordId).notifier)
                        .loadMore();
                  },
                  child: Text(
                    context.l10n.loadMore,
                    style: TextStyle(color: AppColors.cinemaAccent),
                  ),
                ),
              ),
            ),
          )
        else if (results.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: Text(
                  context.l10n.noMoreTitlesFound,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
