import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/explore_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

_DiscoverSpotlightState? _discoverSpotlightState;

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  static const List<_MovieShelfData> _movieBaseSections = <_MovieShelfData>[
    _MovieShelfData(
      title: 'Trending',
      filters: <_ShelfFilterOption>[
        _ShelfFilterOption(label: 'Today', section: MovieSection.trendingDay),
        _ShelfFilterOption(
          label: 'This Week',
          section: MovieSection.trendingWeek,
        ),
      ],
      variant: _ShelfVariant.featured,
    ),
    _MovieShelfData(
      title: "What's Popular",
      filters: <_ShelfFilterOption>[
        _ShelfFilterOption(label: 'Popular', section: MovieSection.popular),
        _ShelfFilterOption(label: 'Top Rated', section: MovieSection.topRated),
        _ShelfFilterOption(
          label: 'In Theaters',
          section: MovieSection.nowPlaying,
        ),
        _ShelfFilterOption(
          label: 'Coming Soon',
          section: MovieSection.upcoming,
        ),
      ],
    ),
    _MovieShelfData(
      title: 'Now Playing',
      filters: <_ShelfFilterOption>[
        _ShelfFilterOption(
          label: 'In Theaters',
          section: MovieSection.nowPlaying,
        ),
        _ShelfFilterOption(
          label: 'Coming Soon',
          section: MovieSection.upcoming,
        ),
        _ShelfFilterOption(label: 'Top Rated', section: MovieSection.topRated),
      ],
    ),
  ];

  static const List<_MovieShelfData> _tvBaseSections = <_MovieShelfData>[
    _MovieShelfData(
      title: 'TV Trending',
      filters: <_ShelfFilterOption>[
        _ShelfFilterOption(label: 'Today', section: MovieSection.tvTrendingDay),
        _ShelfFilterOption(
          label: 'This Week',
          section: MovieSection.tvTrendingWeek,
        ),
      ],
      variant: _ShelfVariant.featured,
    ),
    _MovieShelfData(
      title: "What's Popular",
      filters: <_ShelfFilterOption>[
        _ShelfFilterOption(label: 'Popular', section: MovieSection.tvPopular),
        _ShelfFilterOption(
          label: 'Top Rated',
          section: MovieSection.tvTopRated,
        ),
        _ShelfFilterOption(
          label: 'On The Air',
          section: MovieSection.tvOnTheAir,
        ),
        _ShelfFilterOption(
          label: 'Airing Today',
          section: MovieSection.tvAiringToday,
        ),
      ],
    ),
    _MovieShelfData(
      title: 'On The Air',
      filters: <_ShelfFilterOption>[
        _ShelfFilterOption(
          label: 'On The Air',
          section: MovieSection.tvOnTheAir,
        ),
        _ShelfFilterOption(
          label: 'Airing Today',
          section: MovieSection.tvAiringToday,
        ),
        _ShelfFilterOption(
          label: 'Top Rated',
          section: MovieSection.tvTopRated,
        ),
      ],
    ),
  ];

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  static const int _genreShelfBatchSize = 3;

  final ScrollController _scrollController = ScrollController();
  int _visibleGenreCount = _genreShelfBatchSize;
  bool _isAppendingGenres = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final mediaType = ref.read(exploreMediaTypeProvider);
    final List<MovieGenre>? genres =
        (mediaType == ExploreMediaType.movie
                ? ref.read(movieGenresProvider)
                : ref.read(tvGenresProvider))
            .asData
            ?.value;

    if (genres == null || genres.isEmpty || _isAppendingGenres) {
      return;
    }

    final ScrollPosition position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) {
      return;
    }

    if (_visibleGenreCount >= genres.length) {
      return;
    }

    // Use a microtask to defer the state change if we're currently in a build phase,
    // though setState in a scroll listener is generally safe.
    Future.microtask(() {
      if (!mounted || _isAppendingGenres) return;

      setState(() {
        _isAppendingGenres = true;
        _visibleGenreCount = math.min(
          _visibleGenreCount + _genreShelfBatchSize,
          genres.length,
        );
      });

      // Allow for a small cooling period before next load trigger
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _isAppendingGenres = false;
        }
      });
    });
  }

  List<_MovieShelfData> _genreSections(List<MovieGenre> genres) {
    return genres
        .take(math.min(_visibleGenreCount, genres.length))
        .map(
          (MovieGenre genre) => _MovieShelfData(
            title: genre.name,
            filters: <_ShelfFilterOption>[
              _ShelfFilterOption(label: genre.name, genreId: genre.id),
            ],
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final mediaType = ref.watch(exploreMediaTypeProvider);
    final bool isTv = mediaType == ExploreMediaType.tv;

    final bool hasMovieApiAccess = ref.watch(
      appConfigProvider.select((config) => config.hasMovieApiAccess),
    );

    final AsyncValue<List<MovieGenre>> genresAsync = ref.watch(
      isTv ? tvGenresProvider : movieGenresProvider,
    );

    final List<_MovieShelfData> genreSections = _genreSections(
      genresAsync.asData?.value ?? const <MovieGenre>[],
    );
    final int totalGenres = genresAsync.asData?.value.length ?? 0;
    final bool hasMoreGenres = genreSections.length < totalGenres;

    final List<_MovieShelfData> baseSections = isTv
        ? ExploreScreen._tvBaseSections
        : ExploreScreen._movieBaseSections;

    if (!hasMovieApiAccess) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.vpn_key_outlined, size: 52, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Movie API configuration required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Add MOVIE_PROXY_BASE_URL for production, or TMDB_API_KEY for direct development access.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeInQuad,
      switchOutCurve: Curves.easeOutQuad,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            currentChild ?? const SizedBox.shrink(),
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isEntering = child.key == ValueKey(mediaType);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: isEntering
                  ? const Offset(0.04, 0)
                  : const Offset(-0.04, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: CustomScrollView(
        key: ValueKey(mediaType), // Force refresh when switching type
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent:
            1500, // Pre-build shelves in the background to eliminate stutter
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: _DiscoverSpotlightSection()),

          // Optimized combined shelf list (Base + Genres)
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              if (index < baseSections.length) {
                return _MovieShelfSection(section: baseSections[index]);
              }
              final int genreIndex = index - baseSections.length;
              return _MovieShelfSection(section: genreSections[genreIndex]);
            }, childCount: baseSections.length + genreSections.length),
          ),

          if (genresAsync.isLoading && genreSections.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          if (genresAsync.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Text(
                  'Failed to load genre shelves. ${genresAsync.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),

          if (hasMoreGenres)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Text(
                  'Keep scrolling to load more genres.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _ShelfVariant {
  static const String featured = 'featured';
  static const String normal = 'normal';
}

class _MovieShelfData {
  const _MovieShelfData({
    required this.title,
    required this.filters,
    this.variant = _ShelfVariant.normal,
  });

  final String title;
  final List<_ShelfFilterOption> filters;
  final String variant;
}

class _ShelfFilterOption {
  const _ShelfFilterOption({required this.label, this.section, this.genreId});

  final String label;
  final MovieSection? section;
  final int? genreId;

  bool matches(_ShelfFilterOption other) {
    if (section != null) return section == other.section;
    if (genreId != null) return genreId == other.genreId;
    return false;
  }
}

class _DiscoverSpotlightSection extends ConsumerStatefulWidget {
  const _DiscoverSpotlightSection();

  @override
  ConsumerState<_DiscoverSpotlightSection> createState() =>
      _DiscoverSpotlightSectionState();
}

class _DiscoverSpotlightSectionState
    extends ConsumerState<_DiscoverSpotlightSection>
    with SingleTickerProviderStateMixin {
  final math.Random _random = math.Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final AnimationController _diceController;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _diceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final mediaType = ref.watch(exploreMediaTypeProvider);
    final bool isTv = mediaType == ExploreMediaType.tv;

    final AsyncValue<List<MediaTitle>> moviesAsync = ref.watch(
      discoverPoolProvider,
    );

    return moviesAsync.when(
      loading: () => const SizedBox(
        height: 480,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (movies) {
        if (movies.isEmpty) return const SizedBox.shrink();

        // Initialize state if needed or if media type changed
        if (_discoverSpotlightState == null ||
            !movies.any(
              (m) => m.id == _discoverSpotlightState!.currentMovieId,
            )) {
          final List<int> ids = movies.map((m) => m.id).toList();
          ids.shuffle(_random);
          _discoverSpotlightState = _DiscoverSpotlightState(
            poolMovieIds: ids,
            currentMovieId: ids.first,
            remainingMovieIds: ids.sublist(1),
          );
        }

        final MediaTitle movie = movies.firstWhere(
          (m) => m.id == _discoverSpotlightState!.currentMovieId,
          orElse: () => movies.first,
        );

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          height: 480,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Poster background with glass effect
              Positioned.fill(
                child: Hero(
                  tag: 'discover-spotlight-${movie.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: movie.posterPath ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: AppColors.cinemaSurface,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black.withValues(alpha: 0.95),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cinemaAccent.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'FEATURED ${isTv ? 'SHOW' : 'PICK'}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movie.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingBadge.tmdb(
                          catalogScore: movie.voteAverage,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'User Score',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.pushNamed(
                              AppRoute.movieDetails.name,
                              pathParameters: {'movieId': movie.id.toString()},
                              queryParameters: {
                                'isTv': isTv.toString(),
                                'heroTag': 'discover-spotlight-${movie.id}',
                              },
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: RotationTransition(
                            turns: _diceController,
                            child: IconButton(
                              onPressed: () => _rollNextMovie(movies),
                              icon: const Icon(
                                Icons.casino_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _rollNextMovie(List<MediaTitle> movies) async {
    if (movies.isEmpty) {
      return;
    }

    final _DiscoverSpotlightState? spotlightState = _discoverSpotlightState;
    final List<int> poolMovieIds =
        spotlightState?.poolMovieIds ??
        movies.map((movie) => movie.id).toList(growable: false);
    List<int> remainingMovieIds = List<int>.from(
      spotlightState?.remainingMovieIds ?? const <int>[],
    );
    if (remainingMovieIds.isEmpty) {
      remainingMovieIds = _shuffleMovieIds(
        poolMovieIds,
        excludeMovieId: spotlightState?.currentMovieId,
      );
    }

    if (remainingMovieIds.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _discoverSpotlightState = _DiscoverSpotlightState(
        poolMovieIds: poolMovieIds,
        currentMovieId: remainingMovieIds.removeLast(),
        remainingMovieIds: remainingMovieIds,
      );
    });
    _diceController.forward(from: 0);
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/dice_shuffle.wav'));
  }

  List<int> _shuffleMovieIds(List<int> movieIds, {int? excludeMovieId}) {
    final List<int> shuffledMovieIds = movieIds
        .where((movieId) => movieId != excludeMovieId)
        .toList(growable: true);
    shuffledMovieIds.shuffle(_random);
    return shuffledMovieIds;
  }
}

class _DiscoverSpotlightState {
  const _DiscoverSpotlightState({
    required this.poolMovieIds,
    required this.currentMovieId,
    required this.remainingMovieIds,
  });

  final List<int> poolMovieIds;
  final int currentMovieId;
  final List<int> remainingMovieIds;
}

class _MovieShelfSection extends ConsumerStatefulWidget {
  const _MovieShelfSection({required this.section});

  final _MovieShelfData section;

  @override
  ConsumerState<_MovieShelfSection> createState() => _MovieShelfSectionState();
}

class _MovieShelfSectionState extends ConsumerState<_MovieShelfSection> {
  late _ShelfFilterOption _selectedFilter;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.section.filters.first;
  }

  @override
  void didUpdateWidget(_MovieShelfSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.section.title != oldWidget.section.title) {
      _selectedFilter = widget.section.filters.first;
      _isFilterExpanded = false;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
    });
  }

  void _selectFilter(_ShelfFilterOption option) {
    setState(() {
      _selectedFilter = option;
      _isFilterExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final mediaType = ref.watch(exploreMediaTypeProvider);
    final bool isTv = mediaType == ExploreMediaType.tv;

    final AsyncValue<List<MediaTitle>> movies = _selectedFilter.genreId != null
        ? ref.watch(
            genreSectionProvider((id: _selectedFilter.genreId!, isTv: isTv)),
          )
        : ref.watch(movieSectionProvider(_selectedFilter.section!));

    const double horizontalPadding = 16;
    const double itemSpacing = 12;
    const double shelfHeight = 246; // Poster(162) + Content

    // Use a more efficient way to get width
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - (itemSpacing * 2)) / 3;
    final double finalCardWidth = cardWidth.clamp(100.0, 108.0);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.section.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _SectionFilterPill(
                    label: _selectedFilter.label,
                    isExpanded: _isFilterExpanded,
                    isInteractive: widget.section.filters.length > 1,
                    onTap: _toggleExpanded,
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _isFilterExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.section.filters
                            .map(
                              (option) => _SectionFilterChoice(
                                label: option.label,
                                selected: option.matches(_selectedFilter),
                                onTap: () => _selectFilter(option),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            movies.when(
              skipLoadingOnReload: true,
              loading: () => const SizedBox(
                height: shelfHeight,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object error, StackTrace stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Failed to load ${widget.section.title.toLowerCase()}. $error',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              data: (List<MediaTitle> data) {
                if (data.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'No titles returned for this section.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: shelfHeight,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        final int? genreId = _selectedFilter.genreId;
                        if (genreId != null) {
                          loadNextGenrePages(ref, genreId, isTv: isTv);
                        } else {
                          loadNextPages(ref, _selectedFilter.section!);
                        }
                      }
                      return false;
                    },
                    child: ListView.separated(
                      cacheExtent:
                          500, // Pre-render slightly more items for smoothness
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      scrollDirection: Axis.horizontal,
                      addAutomaticKeepAlives: true, // Keep posters in memory
                      itemCount: data.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: itemSpacing),
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: _PosterMovieCard(
                            movie: data[index],
                            sectionTitle: widget.section.title,
                            width: finalCardWidth,
                            isTv: isTv,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionFilterPill extends StatelessWidget {
  const _SectionFilterPill({
    required this.label,
    required this.isExpanded,
    required this.onTap,
    this.isInteractive = true,
  });

  final String label;
  final bool isExpanded;
  final bool isInteractive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isInteractive ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isExpanded
              ? AppColors.cinemaAccent
              : AppColors.cinemaSurface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded
                ? Colors.transparent
                : AppColors.cinemaAccent.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isExpanded ? Colors.black : AppColors.cinemaPillText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isInteractive) ...[
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: isExpanded ? Colors.black : AppColors.cinemaAccent,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionFilterChoice extends StatelessWidget {
  const _SectionFilterChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.cinemaSurface.withValues(alpha: 0.5),
      selectedColor: AppColors.cinemaAccent,
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white.withValues(alpha: 0.7),
        fontSize: 12,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}

class _PosterMovieCard extends StatelessWidget {
  const _PosterMovieCard({
    required this.movie,
    required this.sectionTitle,
    required this.width,
    this.isTv = false,
  });

  final MediaTitle movie;
  final String sectionTitle;
  final double width;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const double posterHeight = 162;
    const double badgeSize = 34;
    const double badgeOffset = badgeSize / 2;
    const double titleGap = 16;

    // Use the TMDB score from the list API — no extra network call needed
    final Widget scoreBadge = RatingBadge.tmdb(
      catalogScore: movie.voteAverage,
      size: badgeSize,
    );

    final String heroTag = 'movie-poster-${movie.id}-$sectionTitle';

    return RepaintBoundary(
      child: SizedBox(
        width: width,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.pushNamed(
            AppRoute.movieDetails.name,
            pathParameters: <String, String>{'movieId': movie.id.toString()},
            queryParameters: <String, String>{
              'heroTag': heroTag,
              'isTv': isTv.toString(),
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox(
                        height: posterHeight,
                        width: width,
                        child: movie.posterPath == null
                            ? const ColoredBox(
                                color: AppColors.cinemaPlaceholder,
                                child: Center(
                                  child: Icon(Icons.movie_outlined),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: movie.posterPath!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const ColoredBox(
                                  color: AppColors.cinemaPlaceholder,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const ColoredBox(
                                      color: AppColors.cinemaPlaceholder,
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                        ),
                                      ),
                                    ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(left: 8, bottom: -badgeOffset, child: scoreBadge),
                ],
              ),
              SizedBox(height: titleGap),
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                movie.releaseDate ?? sectionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
