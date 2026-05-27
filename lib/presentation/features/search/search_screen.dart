import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/search_collection.dart';
import 'package:cineverse/domain/entities/search_keyword.dart';
import 'package:cineverse/domain/entities/search_company.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/search/providers/search_provider.dart';
import 'package:cineverse/presentation/features/search/providers/search_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController()
      ..addListener(_onScroll);

    _focusNode.requestFocus();

    // Clear search results on launch, or trigger search if initialQuery is provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
          _controller.text = widget.initialQuery!;
          ref.read(searchProvider.notifier).updateQuery(widget.initialQuery!);
          ref.read(searchProvider.notifier).submitSearch(widget.initialQuery!);
        } else {
          ref.read(searchProvider.notifier).clear();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    // Reset search state when leaving the screen
    ref.read(searchProvider.notifier).clear();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final isDiscoverMode = !searchState.filter.isDefault;

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.cinemaGradientTop,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            context.pushNamed(AppRoute.globalFilter.name);
          },
          icon: const Icon(Icons.tune_rounded, size: 24, color: Colors.white),
        ),
        title: SizedBox(
          height: 28,
          child: SvgPicture.asset(
            'assets/logos/logo.svg',
            fit: BoxFit.contain,
            semanticsLabel: AppConstants.appName,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(searchProvider.notifier).submitSearch();
              _focusNode.unfocus();
            },
            icon: const Icon(
              Icons.search_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            (searchState.hasSearched && !isDiscoverMode) ? 120 : 64,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    ref.read(searchProvider.notifier).onQueryChanged(value);
                  },
                  onSubmitted: (_) {
                    ref.read(searchProvider.notifier).submitSearch();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search movies, TV shows, companies...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    suffixIcon: searchState.query.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _controller.clear();
                              ref.read(searchProvider.notifier).clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (searchState.hasSearched && !isDiscoverMode)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: SearchCategory.values.length,
                    itemBuilder: (context, index) {
                      final category = SearchCategory.values[index];
                      final isSelected = searchState.selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              HapticFeedback.selectionClick();
                              ref.read(searchProvider.notifier).setCategory(category);
                            }
                          },
                          backgroundColor: AppColors.cinemaSurface.withValues(alpha: 0.5),
                          selectedColor: AppColors.cinemaAccent,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
            ],
          ),
        ),
      ),
      body: SafeArea(child: _buildBody(searchState)),
    );
  }

  Widget _buildBody(SearchState searchState) {
    if (searchState.query.isEmpty && searchState.filter.isDefault) {
      return _buildHistory();
    }

    if (searchState.isLoading &&
        searchState.suggestions.isEmpty &&
        searchState.movieResults.isEmpty &&
        searchState.tvResults.isEmpty &&
        searchState.personResults.isEmpty &&
        searchState.collectionResults.isEmpty &&
        searchState.keywordResults.isEmpty &&
        searchState.companyResults.isEmpty &&
        searchState.results.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.cinemaAccent),
      );
    }

    if (searchState.error != null &&
        searchState.suggestions.isEmpty &&
        searchState.movieResults.isEmpty &&
        searchState.tvResults.isEmpty &&
        searchState.personResults.isEmpty &&
        searchState.collectionResults.isEmpty &&
        searchState.keywordResults.isEmpty &&
        searchState.companyResults.isEmpty &&
        searchState.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            searchState.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
          ),
        ),
      );
    }

    if (!searchState.hasSearched && searchState.suggestions.isNotEmpty) {
      return _buildSuggestions(searchState.suggestions);
    }

    if (searchState.hasSearched) {
      if (!searchState.filter.isDefault) {
        return _buildResults(
          searchState.results,
          searchState.isLoadingMore,
          searchState.hasMore,
          _scrollController,
          null,
        );
      }

      switch (searchState.selectedCategory) {
        case SearchCategory.movies:
          return _buildResults(
            searchState.movieResults,
            searchState.isLoadingMore,
            searchState.movieHasMore,
            _scrollController,
            GlobalMediaType.movie,
          );
        case SearchCategory.tvShows:
          return _buildResults(
            searchState.tvResults,
            searchState.isLoadingMore,
            searchState.tvHasMore,
            _scrollController,
            GlobalMediaType.tv,
          );
        case SearchCategory.persons:
          return _buildResults(
            searchState.personResults,
            searchState.isLoadingMore,
            searchState.personHasMore,
            _scrollController,
            GlobalMediaType.person,
          );
        case SearchCategory.collections:
          return _buildCollectionsResults(
            searchState.collectionResults,
            searchState.isLoadingMore,
            searchState.collectionHasMore,
            _scrollController,
          );
        case SearchCategory.keywords:
          return _buildKeywordsResults(
            searchState.keywordResults,
            searchState.isLoadingMore,
            searchState.keywordHasMore,
            _scrollController,
          );
        case SearchCategory.companies:
          return _buildCompaniesResults(
            searchState.companyResults,
            searchState.isLoadingMore,
            searchState.companyHasMore,
            _scrollController,
          );
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'Start typing to search',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    List<MediaTitle> results,
    bool isLoadingMore,
    bool hasMore,
    ScrollController controller,
    GlobalMediaType? type,
  ) {
    if (results.isEmpty && !isLoadingMore) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
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
      key: PageStorageKey(type?.name ?? 'discover'),
      controller: controller,
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
                sectionTitle: 'search',
                width: cardWidth,
                isTvTitle: media.mediaType == GlobalMediaType.tv,
              );
            }, childCount: results.length),
          ),
        ),
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.cinemaAccent),
              ),
            ),
          )
        else if (hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(searchProvider.notifier).loadMore();
                  },
                  child: Text(
                    'Load More',
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
                  'No more results found.',
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

  Widget _buildCollectionsResults(
    List<SearchCollection> results,
    bool isLoadingMore,
    bool hasMore,
    ScrollController controller,
  ) {
    if (results.isEmpty && !isLoadingMore) {
      return const Center(
        child: Text(
          'No collections found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('collections'),
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: results.length + (isLoadingMore || hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          if (isLoadingMore) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.cinemaAccent),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(searchProvider.notifier).loadMore();
                  },
                  child: Text(
                    'Load More',
                    style: TextStyle(color: AppColors.cinemaAccent),
                  ),
                ),
              ),
            );
          }
        }

        final collection = results[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.selectionClick();
              context.pushNamed(
                AppRoute.collectionDetails.name,
                pathParameters: {'collectionId': collection.id.toString()},
              );
            },
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.detailsCard,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    child: SizedBox(
                      width: 74,
                      height: 110,
                      child: collection.posterPath != null
                          ? CachedNetworkImage(
                              imageUrl: collection.posterPath!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: AppColors.cinemaPlaceholder,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.cinemaPlaceholder,
                                child: const Icon(Icons.movie_outlined, color: Colors.white30),
                              ),
                            )
                          : Container(
                              color: AppColors.cinemaPlaceholder,
                              child: const Icon(Icons.movie_outlined, color: Colors.white30),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            collection.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              collection.overview ?? 'No overview available.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeywordsResults(
    List<SearchKeyword> results,
    bool isLoadingMore,
    bool hasMore,
    ScrollController controller,
  ) {
    if (results.isEmpty && !isLoadingMore) {
      return const Center(
        child: Text(
          'No keywords found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('keywords'),
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: results.length + (isLoadingMore || hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          if (isLoadingMore) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.cinemaAccent),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(searchProvider.notifier).loadMore();
                  },
                  child: Text(
                    'Load More',
                    style: TextStyle(color: AppColors.cinemaAccent),
                  ),
                ),
              ),
            );
          }
        }

        final keyword = results[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.selectionClick();
              context.pushNamed(
                AppRoute.keywordDetails.name,
                pathParameters: {'keywordId': keyword.id.toString()},
                queryParameters: {'keywordName': keyword.name},
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tag_rounded, color: AppColors.cinemaAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      keyword.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white30, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompaniesResults(
    List<SearchCompany> results,
    bool isLoadingMore,
    bool hasMore,
    ScrollController controller,
  ) {
    if (results.isEmpty && !isLoadingMore) {
      return const Center(
        child: Text(
          'No companies found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('companies'),
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: results.length + (isLoadingMore || hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          if (isLoadingMore) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.cinemaAccent),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(searchProvider.notifier).loadMore();
                  },
                  child: Text(
                    'Load More',
                    style: TextStyle(color: AppColors.cinemaAccent),
                  ),
                ),
              ),
            );
          }
        }

        final company = results[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.selectionClick();
              context.pushNamed(
                AppRoute.companyDetails.name,
                pathParameters: {'companyId': company.id.toString()},
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.detailsCard,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: company.logoPath != null
                        ? CachedNetworkImage(
                            imageUrl: company.logoPath!,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.business_rounded,
                              color: Colors.black45,
                            ),
                          )
                        : const Icon(
                            Icons.business_rounded,
                            color: Colors.black45,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      company.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    final historyAsync = ref.watch(searchHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 16),
                Text(
                  'Start typing to search',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(searchHistoryProvider.notifier).clearAll();
                      ToastUtils.showToast(context, 'Search history cleared');
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: AppColors.cinemaAccent),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.white54),
                    title: Text(
                      entry.query,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white24),
                      onPressed: () {
                        ref
                            .read(searchHistoryProvider.notifier)
                            .removeEntry(entry.id);
                      },
                    ),
                    onTap: () {
                      _controller.text = entry.query;
                      ref
                          .read(searchProvider.notifier)
                          .submitSearch(entry.query);
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSuggestions(List<MediaTitle> suggestions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.posterPath != null
                ? CachedNetworkImage(
                    imageUrl: item.posterPath!,
                    width: 40,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _placeholderPoster(),
                    errorWidget: (_, _, _) => _placeholderPoster(),
                  )
                : _placeholderPoster(),
          ),
          title: Text(
            item.title,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            item.releaseDate ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          onTap: () {
            _focusNode.unfocus();
            final String routeName;
            final Map<String, String> params = {};
            final Map<String, String> queryParams = {};

            if (item.mediaType == GlobalMediaType.person) {
              routeName = AppRoute.personDetails.name;
              params['personId'] = item.id.toString();
            } else {
              routeName = AppRoute.movieDetails.name;
              params['movieId'] = item.id.toString();
              queryParams['isTv'] = (item.mediaType == GlobalMediaType.tv)
                  .toString();
            }

            // Save to history before navigating
            ref.read(searchHistoryProvider.notifier).addEntry(item.title);

            context.pushNamed(
              routeName,
              pathParameters: params,
              queryParameters: queryParams,
            );
          },
        );
      },
    );
  }

  Widget _placeholderPoster() {
    return Container(
      width: 40,
      height: 60,
      color: Colors.white.withValues(alpha: 0.1),
      child: Icon(
        Icons.movie,
        color: Colors.white.withValues(alpha: 0.3),
        size: 20,
      ),
    );
  }
}

