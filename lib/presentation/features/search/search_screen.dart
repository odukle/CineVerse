import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/search/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

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
    _scrollController = ScrollController()..addListener(_onScroll);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
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
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
        ),
      ),
      body: SafeArea(child: _buildBody(searchState)),
    );
  }

  Widget _buildBody(SearchState searchState) {
    if (searchState.isLoading &&
        searchState.suggestions.isEmpty &&
        searchState.results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cinemaAccent),
      );
    }

    if (searchState.error != null &&
        searchState.suggestions.isEmpty &&
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
      return _buildResults(
        searchState.results,
        searchState.isLoadingMore,
        searchState.hasMore,
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
                ? Image.network(
                    item.posterPath!,
                    width: 40,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholderPoster(),
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
            _controller.text = item.title;
            ref.read(searchProvider.notifier).submitSearch(item.title);
            _focusNode.unfocus();
          },
        );
      },
    );
  }

  Widget _buildResults(
    List<MediaTitle> results,
    bool isLoadingMore,
    bool hasMore,
  ) {
    if (results.isEmpty && !hasMore) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
        ),
      );
    }

    const double crossAxisSpacing = 10;
    const double mainAxisSpacing = 0;
    const int crossAxisCount = 3;
    final double availableCardWidth =
        (MediaQuery.sizeOf(context).width - (16 * 2) - (crossAxisSpacing * 2)) /
        crossAxisCount;
    final double cardWidth = availableCardWidth > 108
        ? 108
        : availableCardWidth;

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
              mainAxisExtent: 220,
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 32),
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
                  child: const Text(
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
