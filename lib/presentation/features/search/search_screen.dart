import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/search/providers/search_provider.dart';
import 'package:cineverse/presentation/features/search/providers/search_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final TabController _tabController;
  late final ScrollController _moviesScrollController;
  late final ScrollController _tvScrollController;
  late final ScrollController _personsScrollController;
  late final ScrollController _discoverScrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _tabController = TabController(length: 3, vsync: this);

    _moviesScrollController = ScrollController()
      ..addListener(
        () => _onScroll(_moviesScrollController, GlobalMediaType.movie),
      );
    _tvScrollController = ScrollController()
      ..addListener(() => _onScroll(_tvScrollController, GlobalMediaType.tv));
    _personsScrollController = ScrollController()
      ..addListener(
        () => _onScroll(_personsScrollController, GlobalMediaType.person),
      );
    _discoverScrollController = ScrollController()
      ..addListener(() => _onScroll(_discoverScrollController, null));

    _focusNode.requestFocus();

    // Clear search results on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(searchProvider.notifier).clear();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    _moviesScrollController.dispose();
    _tvScrollController.dispose();
    _personsScrollController.dispose();
    _discoverScrollController.dispose();
    // Reset search state when leaving the screen
    ref.read(searchProvider.notifier).clear();
    super.dispose();
  }

  void _onScroll(ScrollController controller, GlobalMediaType? type) {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 400) {
      ref.read(searchProvider.notifier).loadMore(type);
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
                    hintText: 'Search movies, TV shows...',
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        colors: AppColors.cinemaPanelGradient,
                      ),
                      border: Border.all(
                        color: AppColors.cinemaBorder.withValues(alpha: 0.28),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.cinemaGlow.withValues(alpha: 0.12),
                          blurRadius: 22,
                          spreadRadius: -12,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      dividerColor: Colors.transparent,
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 2),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      tabs: const [
                        Tab(text: 'MOVIES'),
                        Tab(text: 'TV SHOWS'),
                        Tab(text: 'PERSONS'),
                      ],
                    ),
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
          _discoverScrollController,
          null,
        );
      }

      return TabBarView(
        controller: _tabController,
        children: [
          _buildResults(
            searchState.movieResults,
            searchState.isLoadingMore,
            searchState.movieHasMore,
            _moviesScrollController,
            GlobalMediaType.movie,
          ),
          _buildResults(
            searchState.tvResults,
            searchState.isLoadingMore,
            searchState.tvHasMore,
            _tvScrollController,
            GlobalMediaType.tv,
          ),
          _buildResults(
            searchState.personResults,
            searchState.isLoadingMore,
            searchState.personHasMore,
            _personsScrollController,
            GlobalMediaType.person,
          ),
        ],
      );
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
                    ref.read(searchProvider.notifier).loadMore(type);
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
