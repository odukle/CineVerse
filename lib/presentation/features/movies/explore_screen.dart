import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/explore_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: List.generate(3, (index) => const _ShelfShimmer()),
                ),
              ),
            ),

          if (genresAsync.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Failed to load genre shelves. ${genresAsync.error}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(isTv ? tvGenresProvider : movieGenresProvider),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.cinemaAccent,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ],
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
            )
          else if (!genresAsync.isLoading && totalGenres > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Text(
                  'No more genres to load.',
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

  late AnimationController _diceController;
  late Animation<double> _diceAnimation;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _slideshowTimer;
  List<String> _slideshowImages = [];
  String? _logoUrl;
  int _currentImageIndex = 0;
  bool _isNextImageReady = false;
  int? _lastMovieId;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _diceAnimation = Tween<double>(begin: 0, end: 1.5).animate(
      CurvedAnimation(
        parent: _diceController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.86,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.86,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_diceController);

    // Lazy load additional discover pages in the background after everything is loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          loadNextPages(ref, MovieSection.discover);
          // Fetch another batch a few seconds later for even more variety
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              loadNextPages(ref, MovieSection.discover);
            }
          });
        }
      });
    });
  }

  void _startSlideshow(int movieId) {
    _slideshowTimer?.cancel();
    _currentImageIndex = 0;
    _slideshowImages = [];
    _logoUrl = null;
    _isNextImageReady = false;

    final mediaType = ref.watch(exploreMediaTypeProvider);
    final bool isTv = mediaType == ExploreMediaType.tv;

    ref.read(mediaImagesProvider((id: movieId, isTv: isTv)).future).then((
      images,
    ) {
      if (mounted && _lastMovieId == movieId) {
        setState(() {
          // Prefer backdrops for the slideshow, fallback to posters if none
          _slideshowImages = images.backdrops.isNotEmpty
              ? images.backdrops
              : images.posters;
          _logoUrl = images.logos.isNotEmpty ? images.logos.first : null;
          _preloadNextImage();
        });
      }
    });

    _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_slideshowImages.length > 1 && _isNextImageReady && mounted) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % _slideshowImages.length;
          _isNextImageReady = false;
          _preloadNextImage();
        });
      }
    });
  }

  void _preloadNextImage() {
    if (_slideshowImages.isEmpty || !mounted) return;
    final int nextIndex = (_currentImageIndex + 1) % _slideshowImages.length;
    final String imageUrl = _slideshowImages[nextIndex];

    precacheImage(CachedNetworkImageProvider(imageUrl), context).then((_) {
      if (mounted && _lastMovieId != null) {
        setState(() {
          _isNextImageReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _audioPlayer.dispose();
    _diceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<MediaTitle>> discoverPool = ref.watch(
      discoverPoolProvider,
    );
    discoverPool.whenData(_queueDiscoverPoolSync);
    final _DiscoverSpotlightState? spotlightState = _discoverSpotlightState;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      child: discoverPool.when(
        skipLoadingOnReload: !discoverPool.hasError,
        loading: () => Container(
          height: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.detailsCard.withValues(alpha: 0.2),
          ),
          child: Stack(
            children: [
              const ShimmerEffect(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShimmerEffect.textLine(width: 150, height: 24),
                    const SizedBox(height: 8),
                    ShimmerEffect.textLine(width: 100, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        error: (Object error, StackTrace stackTrace) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Failed to load discover picks. $error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => ref.invalidate(discoverPoolProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.cinemaAccent,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ),
        ),
        data: (List<MediaTitle> movies) {
          if (movies.isEmpty) {
            return Text(
              'No discover picks available right now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
              ),
            );
          }

          final MediaTitle movie =
              _currentMovie(movies, spotlightState) ?? movies.first;

          if (_lastMovieId != movie.id) {
            _lastMovieId = movie.id;
            // Use post frame callback to avoid calling setState during build if needed,
            // though _startSlideshow calls setState in its .then() which is fine.
            // But we need to call it now to initialize the first poster if any.
            Future.microtask(() => _startSlideshow(movie.id));
          }

          final String? currentSlideshowUrl = _slideshowImages.isNotEmpty
              ? _slideshowImages[_currentImageIndex]
              : movie.posterPath;

          final mediaType = ref.watch(exploreMediaTypeProvider);
          final bool isTv = mediaType == ExploreMediaType.tv;

          final AsyncValue<MovieDetails> movieDetails = ref.watch(
            movieDetailsProvider(
              GetMovieDetailsParams(movieId: movie.id, isTv: isTv),
            ),
          );
          final List<MovieRating> ratings =
              movieDetails.value?.externalRatings
                  .take(2)
                  .toList(growable: false) ??
              const <MovieRating>[];
          final MovieRating? rottenTomatoesRating = _ratingForSource(
            ratings,
            'Rotten Tomatoes',
          );
          final MovieRating? imdbRating = _ratingForSource(ratings, 'IMDb');
          final bool isRatingLoading =
              movieDetails.isLoading && movieDetails.value == null;
          final String scoreLabel = rottenTomatoesRating == null
              ? 'NA'
              : _normalizeScore(rottenTomatoesRating.value) ?? 'NA';
          const double spotlightBadgeSize = 30;
          final Widget scoreBadge = isRatingLoading
              ? RatingBadge.loading(size: spotlightBadgeSize)
              : rottenTomatoesRating == null
              ? RatingBadge.tmdb(
                  catalogScore: movieDetails.value?.catalogScore,
                  size: spotlightBadgeSize,
                )
              : RatingBadge.rottenTomatoes(
                  label: scoreLabel,
                  size: spotlightBadgeSize,
                );
          final double posterWidth = MediaQuery.sizeOf(context).width - 32;
          final double posterHeight = posterWidth * 9 / 16;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Featured picks. Roll the dice for another surprise.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final Animation<double> fadeAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    final Animation<Offset> slideAnimation = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(fadeAnimation);

                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(movie.id),
                    width: posterWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => context.pushNamed(
                            AppRoute.movieDetails.name,
                            pathParameters: <String, String>{
                              'movieId': movie.id.toString(),
                            },
                            queryParameters: <String, String>{
                              'heroTag': 'movie-poster-${movie.id}-spotlight',
                              'isTv': isTv.toString(),
                            },
                          ),
                          child: Hero(
                            tag: 'movie-poster-${movie.id}-spotlight',
                            child: SizedBox(
                              width: posterWidth,
                              height: posterHeight,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      child: currentSlideshowUrl == null
                                          ? const ColoredBox(
                                              key: ValueKey('placeholder'),
                                              color:
                                                  AppColors.cinemaPlaceholder,
                                              child: Center(
                                                child: Icon(
                                                  Icons.movie_outlined,
                                                  size: 52,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : CachedNetworkImage(
                                              key: ValueKey<String>(
                                                currentSlideshowUrl,
                                              ),
                                              imageUrl: currentSlideshowUrl,
                                              fit: BoxFit.cover,
                                              width: posterWidth,
                                              height: posterHeight,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => const Center(
                                                    child: Icon(
                                                      Icons
                                                          .broken_image_outlined,
                                                      size: 52,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                            ),
                                    ),
                                  ),
                                  // Gradient overlay (bottom 20%)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    height: posterHeight * 0.2,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black,
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Tagline
                                  if (movieDetails.value?.tagline != null &&
                                      movieDetails.value!.tagline!.isNotEmpty)
                                    Positioned(
                                      bottom: 10,
                                      left: 20,
                                      right: 20,
                                      child: Text(
                                        movieDetails.value!.tagline!,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.2,
                                              shadows: [
                                                const Shadow(
                                                  color: Colors.black,
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_logoUrl != null)
                                      _logoUrl!.toLowerCase().endsWith('.svg')
                                          ? SvgPicture.network(
                                              _logoUrl!,
                                              height: 32,
                                              fit: BoxFit.contain,
                                              alignment: Alignment.centerLeft,
                                              placeholderBuilder: (context) =>
                                                  const SizedBox(height: 32),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: _logoUrl!,
                                              height: 32,
                                              fit: BoxFit.contain,
                                              alignment: Alignment.centerLeft,
                                            )
                                    else
                                      Text(
                                        movie.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (!isRatingLoading &&
                                            rottenTomatoesRating != null) ...[
                                          const _TomatoIcon(),
                                          const SizedBox(width: 6),
                                          Text(
                                            scoreLabel,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            width: 1,
                                            height: 10,
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ] else ...[
                                          scoreBadge,
                                          const SizedBox(width: 10),
                                        ],
                                        if (imdbRating != null) ...[
                                          const _ImdbIcon(),
                                          const SizedBox(width: 6),
                                          Text(
                                            imdbRating.value,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ] else
                                          Text(
                                            'IMDb NA',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.6),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _rollNextMovie(movies),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Ink(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.cinemaSelected
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.cinemaSelected
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Center(
                                      child: ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: RotationTransition(
                                          turns: _diceAnimation,
                                          child: const Icon(
                                            Icons.casino_outlined,
                                            color: AppColors.cinemaSelected,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  MediaTitle? _currentMovie(
    List<MediaTitle> movies,
    _DiscoverSpotlightState? spotlightState,
  ) {
    final int? currentMovieId = spotlightState?.currentMovieId;
    if (currentMovieId == null) {
      return null;
    }

    for (final MediaTitle movie in movies) {
      if (movie.id == currentMovieId) {
        return movie;
      }
    }

    return null;
  }

  void _queueDiscoverPoolSync(List<MediaTitle> movies) {
    final List<int> nextPoolMovieIds = movies
        .map((movie) => movie.id)
        .toList(growable: false);
    final _DiscoverSpotlightState? spotlightState = _discoverSpotlightState;

    if (listEquals(nextPoolMovieIds, spotlightState?.poolMovieIds)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _syncDiscoverPool(movies);
    });
  }

  void _syncDiscoverPool(List<MediaTitle> movies) {
    final List<int> poolMovieIds = movies
        .map((movie) => movie.id)
        .toList(growable: false);
    final _DiscoverSpotlightState? spotlightState = _discoverSpotlightState;
    final int? currentMovieId = spotlightState?.currentMovieId;

    if (listEquals(poolMovieIds, spotlightState?.poolMovieIds)) {
      return;
    }

    final bool canKeepCurrentMovie =
        currentMovieId != null && poolMovieIds.contains(currentMovieId);
    final int? nextCurrentMovieId = canKeepCurrentMovie ? currentMovieId : null;
    final List<int> nextRemainingMovieIds = _shuffleMovieIds(
      poolMovieIds,
      excludeMovieId: nextCurrentMovieId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _discoverSpotlightState = _DiscoverSpotlightState(
        poolMovieIds: poolMovieIds,
        currentMovieId:
            nextCurrentMovieId ??
            (nextRemainingMovieIds.isNotEmpty
                ? nextRemainingMovieIds.removeLast()
                : (poolMovieIds.isEmpty ? null : poolMovieIds.first)),
        remainingMovieIds: nextRemainingMovieIds,
      );
    });
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
  final int? currentMovieId;
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
    const double shelfHeight = 220; // Poster(162) + Content

    // Use a more efficient way to get width
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double cardWidth =
        (screenWidth - (horizontalPadding * 2) - (itemSpacing * 2)) / 3;
    final double finalCardWidth = cardWidth.clamp(100.0, 108.0);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (widget.section.filters.length > 1)
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
              skipLoadingOnReload: !movies.hasError,
              loading: () => const _ShelfShimmer(),
              error: (Object error, StackTrace stackTrace) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Failed to load ${widget.section.title.toLowerCase()}. $error',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        final int? genreId = _selectedFilter.genreId;
                        if (genreId != null) {
                          ref.invalidate(genreSectionProvider((id: genreId, isTv: isTv)));
                        } else {
                          ref.invalidate(movieSectionProvider(_selectedFilter.section!));
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.cinemaAccent,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  ],
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
                          child: MediaPosterGridCard(
                            movie: data[index],
                            sectionTitle: widget.section.title,
                            width: finalCardWidth,
                            isTvTitle: isTv,
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

class _ShelfShimmer extends StatelessWidget {
  const _ShelfShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerEffect.poster(width: 108, height: 153),
            const SizedBox(height: 12),
            ShimmerEffect.textLine(width: 80, height: 12),
            const SizedBox(height: 6),
            ShimmerEffect.textLine(width: 40, height: 10),
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
        borderRadius: BorderRadius.circular(16),
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

MovieRating? _ratingForSource(List<MovieRating> ratings, String source) {
  for (final MovieRating rating in ratings) {
    if (rating.source == source) {
      return rating;
    }
  }

  return null;
}

String? _normalizeScore(String rawValue) {
  final RegExp percentPattern = RegExp(r'(\d{1,3})\s*%');
  final Match? percentMatch = percentPattern.firstMatch(rawValue);
  if (percentMatch != null) {
    return '${percentMatch.group(1)}%';
  }

  final RegExp tenPointPattern = RegExp(r'(\d+(?:\.\d+)?)\s*/\s*10');
  final Match? tenPointMatch = tenPointPattern.firstMatch(rawValue);
  if (tenPointMatch != null) {
    final double? parsedValue = double.tryParse(tenPointMatch.group(1)!);
    if (parsedValue != null) {
      return '${(parsedValue * 10).round()}%';
    }
  }

  return null;
}

class _ImdbIcon extends StatelessWidget {
  const _ImdbIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/IMDB_Logo.svg',
      height: 13,
      fit: BoxFit.contain,
    );
  }
}

class _TomatoIcon extends StatelessWidget {
  const _TomatoIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/Rotten_Tomatoes.svg',
      height: 15,
      fit: BoxFit.contain,
    );
  }
}
