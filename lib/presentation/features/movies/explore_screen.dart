import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

_DiscoverSpotlightState? _discoverSpotlightState;

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  static const List<_MovieShelfData> _baseSections = <_MovieShelfData>[
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

    final List<MovieGenre>? genres = ref
        .read(movieGenresProvider)
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

    setState(() {
      _isAppendingGenres = true;
      _visibleGenreCount = math.min(
        _visibleGenreCount + _genreShelfBatchSize,
        genres.length,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _isAppendingGenres = false;
      _handleScroll();
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
    final bool hasMovieApiAccess = ref.watch(
      appConfigProvider.select((config) => config.hasMovieApiAccess),
    );
    final AsyncValue<List<MovieGenre>> genresAsync = ref.watch(
      movieGenresProvider,
    );
    final List<_MovieShelfData> genreSections = _genreSections(
      genresAsync.asData?.value ?? const <MovieGenre>[],
    );
    final int totalGenres = genresAsync.asData?.value.length ?? 0;
    final bool hasMoreGenres = genreSections.length < totalGenres;

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

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: _DiscoverSpotlightSection()),
        for (final _MovieShelfData section in ExploreScreen._baseSections)
          SliverToBoxAdapter(child: _MovieShelfSection(section: section)),
        for (final _MovieShelfData section in genreSections)
          SliverToBoxAdapter(child: _MovieShelfSection(section: section)),
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
      ],
    );
  }
}

enum _ShelfVariant { featured, compact }

class _MovieShelfData {
  const _MovieShelfData({
    required this.title,
    required this.filters,
    this.variant = _ShelfVariant.compact,
  });

  final String title;
  final List<_ShelfFilterOption> filters;
  final _ShelfVariant variant;
}

class _ShelfFilterOption {
  const _ShelfFilterOption({required this.label, this.section, this.genreId})
    : assert((section == null) != (genreId == null));

  final String label;
  final MovieSection? section;
  final int? genreId;

  bool matches(_ShelfFilterOption other) {
    return section == other.section && genreId == other.genreId;
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
      duration: const Duration(milliseconds: 720),
    );
    _diceAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.decelerate),
    );

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

    ref.read(mediaImagesProvider((id: movieId, isTv: false)).future).then((
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
        loading: () => const SizedBox(
          height: 360,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (Object error, StackTrace stackTrace) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Failed to load discover picks. $error',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
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

          final AsyncValue<MovieDetails> movieDetails = ref.watch(
            movieDetailsProvider(GetMovieDetailsParams(movieId: movie.id)),
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
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'One spotlight pick at a time. Roll the dice for another surprise.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
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
                      borderRadius: BorderRadius.circular(28),
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
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_logoUrl != null)
                                      CachedNetworkImage(
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
                                        scoreBadge,
                                        const SizedBox(width: 10),
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
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.cinemaSelected
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Center(
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

class _MovieShelfSectionState extends ConsumerState<_MovieShelfSection>
    with TickerProviderStateMixin {
  late _ShelfFilterOption _selectedFilter;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.section.filters.first;
  }

  void _toggleExpanded() {
    if (widget.section.filters.length < 2) {
      return;
    }

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
    final AsyncValue<List<MediaTitle>> movies = _selectedFilter.genreId != null
        ? ref.watch(genreSectionProvider(_selectedFilter.genreId!))
        : ref.watch(movieSectionProvider(_selectedFilter.section!));
    const double horizontalPadding = 16;
    const double itemSpacing = 10;
    const double shelfHeight = 246;
    final double availableCardWidth =
        (MediaQuery.sizeOf(context).width -
            (horizontalPadding * 2) -
            (itemSpacing * 2)) /
        3;
    final double cardWidth = availableCardWidth > 108
        ? 108
        : availableCardWidth;

    return Padding(
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
                        loadNextGenrePages(ref, genreId);
                      } else {
                        loadNextPages(ref, _selectedFilter.section!);
                      }
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: itemSpacing),
                    itemBuilder: (context, index) {
                      final MediaTitle movie = data[index];
                      if (widget.section.variant == _ShelfVariant.featured) {
                        return _PosterMovieCard(
                          movie: movie,
                          sectionTitle: widget.section.title,
                          width: cardWidth,
                        );
                      }

                      return _PosterMovieCard(
                        movie: movie,
                        sectionTitle: widget.section.title,
                        width: cardWidth,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionFilterPill extends StatelessWidget {
  const _SectionFilterPill({
    required this.label,
    required this.isExpanded,
    required this.isInteractive,
    required this.onTap,
  });

  final String label;
  final bool isExpanded;
  final bool isInteractive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isInteractive ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cinemaSurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.cinemaPillText,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isInteractive) ...[
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.cinemaAccent,
                  size: 18,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.cinemaSelected : AppColors.cinemaSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.cinemaSelected
                : AppColors.cinemaAccent.withValues(alpha: 0.22),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PosterMovieCard extends ConsumerWidget {
  const _PosterMovieCard({
    required this.movie,
    required this.sectionTitle,
    this.width = 104,
  });

  final MediaTitle movie;
  final String sectionTitle;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final double posterHeight = width * 1.42;
    final double badgeSize = width * 0.28;
    final double badgeOffset = badgeSize * 0.24;
    final double titleGap = badgeOffset + 5;
    final AsyncValue<MovieDetails> movieDetails = ref.watch(
      movieDetailsProvider(GetMovieDetailsParams(movieId: movie.id)),
    );
    final List<MovieRating> ratings =
        movieDetails.value?.externalRatings.take(2).toList(growable: false) ??
        const <MovieRating>[];
    final MovieRating? rottenTomatoesRating = _ratingForSource(
      ratings,
      'Rotten Tomatoes',
    );
    final MovieRating? imdbRating = _ratingForSource(ratings, 'IMDb');
    final String scoreLabel = rottenTomatoesRating == null
        ? 'NA'
        : _normalizeScore(rottenTomatoesRating.value) ?? 'NA';
    final Widget scoreBadge = rottenTomatoesRating == null
        ? RatingBadge.tmdb(
            catalogScore: movieDetails.value?.catalogScore,
            size: badgeSize,
          )
        : RatingBadge.rottenTomatoes(label: scoreLabel, size: badgeSize);

    final String heroTag = 'movie-poster-${movie.id}-$sectionTitle';

    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.pushNamed(
          AppRoute.movieDetails.name,
          pathParameters: <String, String>{'movieId': movie.id.toString()},
          queryParameters: <String, String>{'heroTag': heroTag},
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
                              child: Center(child: Icon(Icons.movie_outlined)),
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
                                      child: Icon(Icons.broken_image_outlined),
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
            if (imdbRating != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: _MiniRatingLine(label: 'IMDb ${imdbRating.value}'),
              ),
          ],
        ),
      ),
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

class _MiniRatingLine extends StatelessWidget {
  const _MiniRatingLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.78),
        fontSize: 10.5,
      ),
    );
  }
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
    return Container(
      width: 32,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFFF5C518),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: const Text(
        'IMDb',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 9,
          letterSpacing: -0.2,
          height: 1.1,
        ),
      ),
    );
  }
}
