import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/notes_provider.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart' show mediaImagesProvider;
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/full_screen_image_viewer.dart';
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:cineverse/core/config/region_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';

class MovieDetailsScreen extends ConsumerWidget {
  const MovieDetailsScreen({
    super.key,
    required this.movieId,
    this.isTv = false,
    this.heroTag,
  });

  final int movieId;
  final bool isTv;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<MovieDetails> movieDetails = ref.watch(
      movieDetailsProvider(GetMovieDetailsParams(movieId: movieId, isTv: isTv)),
    );

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      body: movieDetails.when(
        skipLoadingOnReload: !movieDetails.hasError,
        loading: () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerEffect.poster(width: double.infinity, height: 220),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerEffect.textLine(width: 200, height: 28),
                    const SizedBox(height: 12),
                    ShimmerEffect.textLine(width: 150, height: 16),
                    const SizedBox(height: 24),
                    ShimmerEffect.textLine(width: double.infinity, height: 100),
                    const SizedBox(height: 24),
                    ShimmerEffect.textLine(width: 100, height: 20),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ShimmerEffect.poster(width: 100, height: 150),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        error: (Object error, StackTrace stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.movie_creation_outlined,
                    size: 56,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load movie details',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(movieDetailsProvider(
                      GetMovieDetailsParams(movieId: movieId, isTv: isTv),
                    )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cinemaAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (MovieDetails details) =>
            _MovieDetailsView(details: details, isTv: isTv, heroTag: heroTag),
      ),
    );
  }
}

class _MovieDetailsView extends ConsumerStatefulWidget {
  const _MovieDetailsView({
    required this.details,
    required this.isTv,
    this.heroTag,
  });

  final MovieDetails details;
  final bool isTv;
  final String? heroTag;

  @override
  ConsumerState<_MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends ConsumerState<_MovieDetailsView> {
  Timer? _slideshowTimer;
  List<String> _slideshowImages = [];
  int _currentImageIndex = 0;
  bool _isNextImageReady = false;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  void _startSlideshow() {
    ref.read(mediaImagesProvider((id: widget.details.id, isTv: widget.isTv)).future).then((images) {
      if (mounted) {
        setState(() {
          _slideshowImages = images.backdrops.isNotEmpty ? images.backdrops : images.posters;
          _preloadNextImage();
        });
      }
    });

    _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_slideshowImages.length > 1 && _isNextImageReady && mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _slideshowImages.length;
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
      if (mounted) {
        setState(() {
          _isNextImageReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? backdropUrl = _slideshowImages.isNotEmpty
        ? _slideshowImages[_currentImageIndex]
        : (widget.details.backdropPath ?? widget.details.posterPath);

    final String? releaseYear = _extractYear(widget.details.releaseDate);
    final int? scorePercent = _catalogScorePercent(widget.details.catalogScore);
    final List<MovieRating> externalRatings = widget.details.externalRatings;
    final List<MovieCredit> featuredCrew = _getFeaturedCrew(widget.details.crew);
    final MovieWatchAvailability? watchAvailability = widget.details.watchAvailability;
    final bool hasWatchAvailability = watchAvailability?.hasProviders ?? false;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.cinemaGradient,
        ),
      ),
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            toolbarHeight: 56,
            backgroundColor: AppColors.cinemaGradientTop,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            title: SizedBox(
              height: 24,
              child: SvgPicture.asset(
                'assets/logos/logo.svg',
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                semanticsLabel: AppConstants.appName,
              ),
            ),
            centerTitle: false,
            actions: [
              _WatchlistButton(
                id: widget.details.id,
                title: widget.details.title,
                posterPath: widget.details.posterPath,
                releaseDate: widget.details.releaseDate,
                mediaType: widget.isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
                voteAverage: widget.details.catalogScore,
              ),
              _WatchedButton(
                details: widget.details,
                isTv: widget.isTv,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),

          // Backdrop + Poster
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  // Backdrop Slideshow
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 1000),
                      child: backdropUrl == null
                          ? const ColoredBox(
                              key: ValueKey('placeholder'),
                              color: AppColors.detailsBackdropPlaceholder,
                            )
                          : CachedNetworkImage(
                              key: ValueKey(backdropUrl),
                              imageUrl: backdropUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const ColoredBox(
                                color: AppColors.detailsBackdropPlaceholder,
                              ),
                              errorWidget: (context, url, error) =>
                                  const ColoredBox(
                                    color: AppColors.detailsBackdropPlaceholder,
                                  ),
                            ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.5),
                            AppColors.cinemaBackground,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Poster + Title row
                  Positioned(
                    left: 16,
                    bottom: 0,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Hero(
                          tag: widget.heroTag ?? 'movie-poster-${widget.details.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.detailsPosterShadow,
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 100,
                                height: 150,
                                child: widget.details.posterPath == null
                                    ? const ColoredBox(
                                        color: AppColors.detailsPosterSurface,
                                        child: Center(
                                          child: Icon(
                                            Icons.movie_outlined,
                                            size: 36,
                                          ),
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: widget.details.posterPath!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const ShimmerEffect(
                                              width: 100,
                                              height: 150,
                                              borderRadius: 12,
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const ColoredBox(
                                              color: AppColors
                                                  .detailsPosterSurface,
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 36,
                                                ),
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

          // Title + Year
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.details.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (releaseYear != null)
                      TextSpan(
                        text: ' ($releaseYear)',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // User Score + Play Trailer
          if (scorePercent != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _UserScoreIndicator(percent: scorePercent),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'User Score',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.details.voteCount != null)
                          Text(
                            '${_formatNumber(widget.details.voteCount!)} votes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: widget.details.trailerYouTubeKey == null
                          ? null
                          : () => _showTrailer(
                              context,
                              widget.details.trailerYouTubeKey!,
                            ),
                      iconAlignment: IconAlignment.start,
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: widget.details.trailerYouTubeKey == null
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white,
                        size: 24,
                      ),
                      label: Text(
                        'Play Trailer',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: widget.details.trailerYouTubeKey == null
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (externalRatings.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _ExternalRatingsRow(ratings: externalRatings),
              ),
            ),

          // Meta info line
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.detailsCard.withValues(alpha: 0.6),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Text(
                  _buildMetaLine(widget.details),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),

          // Tagline
          if (widget.details.tagline != null && widget.details.tagline!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text(
                  widget.details.tagline!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ),

          // Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.details.overview ?? 'Overview unavailable for this title.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Where to Watch
          if (hasWatchAvailability)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Consumer(
                  builder: (context, ref, _) {
                    final regionCode =
                        ref.watch(preferredRegionCodeProvider).toLowerCase();
                    final mediaTypePath = widget.isTv ? 'tv-show' : 'movie';
                    final slug = _slugify(widget.details.title);
                    final directLink =
                        'https://www.justwatch.com/$regionCode/$mediaTypePath/$slug';

                    return _WatchAvailabilitySection(
                      availability: watchAvailability!,
                      customLink: directLink,
                    );
                  },
                ),
              ),
            ),

          // Featured Crew
          if (featuredCrew.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Featured Crew',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 170, // Smaller than top billed cast
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: featuredCrew.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final credit = featuredCrew[index];
                          return MediaPosterGridCard(
                            movie: MediaTitle(
                              id: credit.id,
                              title: credit.name,
                              posterPath: credit.imageUrl,
                              releaseDate: credit.role,
                              mediaType: GlobalMediaType.person,
                            ),
                            sectionTitle: 'Crew',
                            width: 80, // Smaller than 108
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.1),
                height: 1,
              ),
            ),
          ),

          // Top Billed Cast
          if (widget.details.cast.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top Billed Cast',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _FullCastCrewChip(
                            title: widget.details.title,
                            cast: widget.details.cast,
                            crew: widget.details.crew,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: math.min(widget.details.cast.length, 10),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final credit = widget.details.cast[index];
                          return MediaPosterGridCard(
                            movie: MediaTitle(
                              id: credit.id,
                              title: credit.name,
                              posterPath: credit.imageUrl,
                              releaseDate: credit.characterName ?? credit.role,
                              mediaType: GlobalMediaType.person,
                            ),
                            sectionTitle: 'Cast',
                            width: 108,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Images Section
          SliverToBoxAdapter(
            child: _ImagesCarousel(
              movieId: widget.details.id,
              isTv: widget.isTv,
            ),
          ),

          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.1),
                height: 1,
              ),
            ),
          ),

          // Recommendations
          if (widget.details.recommendations.isNotEmpty)
            SliverToBoxAdapter(
              child: _RecommendationsCarousel(
                movieId: widget.details.id,
                initialItems: widget.details.recommendations,
                isTv: widget.isTv,
              ),
            ),

          // Additional Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Divider(
                color: Colors.white.withValues(alpha: 0.1),
                height: 1,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.details.status != null)
                    _InfoRow(label: 'Status', value: widget.details.status!),
                  if (widget.details.originalLanguage != null)
                    _InfoRow(
                      label: 'Original Language',
                      value: _formatLanguage(widget.details.originalLanguage!),
                    ),
                  if (widget.details.budget != null && widget.details.budget! > 0)
                    _InfoRow(
                      label: 'Budget',
                      value: _formatCurrency(widget.details.budget!),
                    ),
                  if (widget.details.revenue != null && widget.details.revenue! > 0)
                    _InfoRow(
                      label: 'Revenue',
                      value: _formatCurrency(widget.details.revenue!),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _NotesSection(
              mediaId: widget.details.id,
              mediaType:
                  widget.isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
            ),
          ),
        ],
      ),
    );
  }

  void _showTrailer(BuildContext context, String videoKey) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        alignment: Alignment.topCenter,
        child: _TrailerPlayer(videoKey: videoKey),
      ),
    );
  }

  String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9\s-]'),
          '',
        ) // Remove non-alphanumeric except space and hyphen
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-'); // Remove duplicate hyphens
  }

  String? _extractYear(String? releaseDate) {
    if (releaseDate == null || releaseDate.length < 4) return null;
    return releaseDate.substring(0, 4);
  }

  int? _catalogScorePercent(double? catalogScore) {
    if (catalogScore == null || catalogScore.isNaN) {
      return null;
    }

    return (catalogScore * 10).round().clamp(0, 100);
  }

  String _buildMetaLine(MovieDetails details) {
    final List<String> parts = [];
    if (details.contentRating != null) {
      parts.add(details.contentRating!);
    }
    if (details.releaseDate != null) {
      parts.add('${details.releaseDate!} (US)');
    }
    if (details.runtimeMinutes != null && details.runtimeMinutes! > 0) {
      final int hours = details.runtimeMinutes! ~/ 60;
      final int minutes = details.runtimeMinutes! % 60;
      if (hours > 0 && minutes > 0) {
        parts.add('${hours}h ${minutes}m');
      } else if (hours > 0) {
        parts.add('${hours}h');
      } else {
        parts.add('${minutes}m');
      }
    }
    if (details.genres.isNotEmpty) {
      parts.add(details.genres.join(', '));
    }
    return parts.join(' • ');
  }

  List<MovieCredit> _getFeaturedCrew(List<MovieCredit> crew) {
    const Set<String> featuredRoles = {
      'Director',
      'Writer',
      'Screenplay',
      'Story',
    };
    final Map<String, ({int id, String name, String? imageUrl, List<String> roles})> crewMap = {};
    
    for (final credit in crew) {
      if (featuredRoles.contains(credit.role)) {
        final existing = crewMap[credit.name];
        if (existing == null) {
          crewMap[credit.name] = (
            id: credit.id,
            name: credit.name,
            imageUrl: credit.imageUrl,
            roles: [credit.role],
          );
        } else {
          existing.roles.add(credit.role);
        }
      }
    }

    return crewMap.values
        .take(4)
        .map((e) => MovieCredit(
              id: e.id,
              name: e.name,
              role: e.roles.join(', '),
              imageUrl: e.imageUrl,
            ))
        .toList(growable: false);
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }

  String _formatCurrency(int amount) {
    final String raw = amount.toString();
    final StringBuffer buffer = StringBuffer();
    int count = 0;
    for (int i = raw.length - 1; i >= 0; i--) {
      buffer.write(raw[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString().split('').reversed.join()}';
  }

  String _formatLanguage(String code) {
    const Map<String, String> languages = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'hi': 'Hindi',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ar': 'Arabic',
    };
    return languages[code] ?? code.toUpperCase();
  }
}

class _FullCastCrewChip extends StatelessWidget {
  const _FullCastCrewChip({
    required this.title,
    required this.cast,
    required this.crew,
  });

  final String title;
  final List<MovieCredit> cast;
  final List<MovieCredit> crew;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: () {
        context.pushNamed(
          AppRoute.fullCastCrew.name,
          extra: {'title': title, 'cast': cast, 'crew': crew},
        );
      },
      backgroundColor: AppColors.cinemaAccent.withValues(alpha: 0.1),
      side: const BorderSide(color: AppColors.cinemaAccent, width: 1),
      label: const Text(
        'Full Cast & Crew',
        style: TextStyle(color: AppColors.cinemaAccent, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ImagesCarousel extends ConsumerWidget {
  const _ImagesCarousel({required this.movieId, required this.isTv});

  final int movieId;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(mediaImagesProvider((id: movieId, isTv: isTv)));
    final ThemeData theme = Theme.of(context);

    return imagesAsync.when(
      data: (images) {
        final List<String> allImages = [
          ...images.backdrops,
          ...images.posters,
          ...images.logos,
        ];

        if (allImages.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
              child: Text(
                'Images',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allImages.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final String imageUrl = allImages[index];
                  final bool isLogo = images.logos.contains(imageUrl);
                  final bool isPoster = images.posters.contains(imageUrl);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            images: allImages,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: isPoster ? 100 : (isLogo ? 150 : 266),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.detailsPosterSurface,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Hero(
                        tag: imageUrl,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: isLogo ? BoxFit.contain : BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => _ImagesCarouselShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ExternalRatingsRow extends StatelessWidget {
  const _ExternalRatingsRow({required this.ratings});

  final List<MovieRating> ratings;

  @override
  Widget build(BuildContext context) {
    final MovieRating? rottenTomatoes = _ratingForSource(
      ratings,
      'Rotten Tomatoes',
    );
    final MovieRating? imdb = _ratingForSource(ratings, 'IMDb');
    final MovieRating? metacritic = _ratingForSource(ratings, 'Metacritic');
    final List<Widget> chips = <Widget>[];

    if (rottenTomatoes != null) {
      chips.add(
        _ExternalRatingChip(
          value: _normalizeExternalRatingValue(rottenTomatoes.value) ?? 'NA',
          sourceIcon: _TomatoIcon(),
          url: rottenTomatoes.url,
        ),
      );
    }

    if (imdb != null) {
      chips.add(
        _ExternalRatingChip(
          value: imdb.value,
          sourceIcon: _ImdbIcon(),
          url: imdb.url,
        ),
      );
    }

    if (metacritic != null) {
      chips.add(
        _ExternalRatingChip(
          value:
              _normalizeExternalRatingValue(metacritic.value) ??
              metacritic.value,
          sourceIcon: _MetacriticIcon(value: metacritic.value),
          url: metacritic.url,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: chips,
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

class _ExternalRatingChip extends StatelessWidget {
  const _ExternalRatingChip({
    required this.value,
    required this.sourceIcon,
    this.url,
  });

  final String value;
  final Widget sourceIcon;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.detailsCard.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: url == null
            ? null
            : () async {
                final Uri uri = Uri.parse(url!);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint('Could not launch $url: $e');
                }
              },
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              sourceIcon,
              const SizedBox(width: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TomatoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/Rotten_Tomatoes.svg',
      height: 18,
      fit: BoxFit.contain,
    );
  }
}

class _MetacriticIcon extends StatelessWidget {
  const _MetacriticIcon({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/Metacritic_logo.svg',
      height: 16,
      fit: BoxFit.contain,
    );
  }
}

class _ImdbIcon extends StatelessWidget {
  const _ImdbIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logos/IMDB_Logo.svg',
      height: 14,
      fit: BoxFit.contain,
    );
  }
}

String? _normalizeExternalRatingValue(String rawValue) {
  final RegExp percentPattern = RegExp(r'(\d{1,3})\s*%');
  final Match? percentMatch = percentPattern.firstMatch(rawValue);
  if (percentMatch != null) {
    return '${percentMatch.group(1)}%';
  }

  // Check for 100-point scale first (e.g., Metacritic) to avoid partial matches with 10-point scale
  final RegExp hundredPointPattern = RegExp(r'(\d{1,3})\s*/\s*100');
  final Match? hundredPointMatch = hundredPointPattern.firstMatch(rawValue);
  if (hundredPointMatch != null) {
    return '${hundredPointMatch.group(1)}%';
  }

  // Check for 10-point scale (e.g., IMDb)
  // Ensure it's exactly /10 and not /100 by checking the boundary
  final RegExp tenPointPattern = RegExp(r'(\d+(?:\.\d+)?)\s*/\s*10(?!\d)');
  final Match? tenPointMatch = tenPointPattern.firstMatch(rawValue);
  if (tenPointMatch != null) {
    final double? parsedValue = double.tryParse(tenPointMatch.group(1)!);
    if (parsedValue != null) {
      return '${(parsedValue * 10).round()}%';
    }
  }

  return null;
}

class _WatchAvailabilitySection extends StatelessWidget {
  const _WatchAvailabilitySection({
    required this.availability,
    required this.customLink,
  });

  final MovieWatchAvailability availability;
  final String customLink;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where to Watch',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (availability.streaming.isNotEmpty)
          _WatchProviderRow(
            label: 'Stream',
            providers: availability.streaming,
            link: customLink,
          ),
        if (availability.free.isNotEmpty)
          _WatchProviderRow(
            label: 'Free',
            providers: availability.free,
            link: customLink,
          ),
        if (availability.rent.isNotEmpty)
          _WatchProviderRow(
            label: 'Rent',
            providers: availability.rent,
            link: customLink,
          ),
        if (availability.buy.isNotEmpty)
          _WatchProviderRow(
            label: 'Buy',
            providers: availability.buy,
            link: customLink,
          ),
        const SizedBox(height: 8),
        Text(
          'Availability data by JustWatch.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _WatchProviderRow extends StatelessWidget {
  const _WatchProviderRow({
    required this.label,
    required this.providers,
    this.link,
  });

  final String label;
  final List<MovieWatchProvider> providers;
  final String? link;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: providers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _WatchProviderCard(provider: providers[index], link: link),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchProviderCard extends StatelessWidget {
  const _WatchProviderCard({required this.provider, this.link});

  final MovieWatchProvider provider;
  final String? link;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: link == null
          ? null
          : () async {
              final Uri uri = Uri.parse(link!);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Could not launch $link: $e');
              }
            },
      child: Container(
        width: 86,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: AppColors.detailsCard.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: provider.logoPath == null
                  ? const Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white70,
                      size: 24,
                    )
                  : CachedNetworkImage(
                      imageUrl: provider.logoPath!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const ColoredBox(color: AppColors.detailsPosterSurface),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                provider.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserScoreIndicator extends StatelessWidget {
  const _UserScoreIndicator({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final Color ringColor = percent >= 70
        ? AppColors.cinemaScoreRing
        : percent >= 40
        ? Colors.amber
        : Colors.redAccent;

    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF081C22),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 3.0,
              backgroundColor: ringColor.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(ringColor),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$percent',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 8,
                  ),
                ),
                const TextSpan(
                  text: '%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsCarousel extends ConsumerStatefulWidget {
  const _RecommendationsCarousel({
    required this.movieId,
    required this.initialItems,
    required this.isTv,
  });

  final int movieId;
  final List<MovieRecommendation> initialItems;
  final bool isTv;

  @override
  ConsumerState<_RecommendationsCarousel> createState() =>
      _RecommendationsCarouselState();
}

class _RecommendationsCarouselState
    extends ConsumerState<_RecommendationsCarousel> {
  late List<MovieRecommendation> _items;
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _loading = false;
  bool _exhausted = false;

  @override
  void initState() {
    super.initState();
    _items = List<MovieRecommendation>.from(widget.initialItems);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (_loading || _exhausted) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 250) return;

    setState(() => _loading = true);
    try {
      final more = await ref
          .read(mediaRepositoryProvider)
          .fetchMovieRecommendations(
            widget.movieId,
            page: _page + 1,
            isTv: widget.isTv,
          );
      if (!mounted) return;
      if (more.isEmpty) {
        setState(() => _exhausted = true);
      } else {
        setState(() {
          _page++;
          _items.addAll(more);
        });
      }
    } catch (_) {
      // silently ignore transient errors
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recommendations',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length + (_loading ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return const SizedBox(
                    width: 108,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cinemaAccent,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                return MediaPosterGridCard(
                  movie: _items[index].toMediaTitle(),
                  sectionTitle: 'Recommendations',
                  width: 108,
                  isTvTitle: widget.isTv,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagesCarouselShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
          child: ShimmerEffect.textLine(width: 100, height: 24),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                ShimmerEffect.poster(width: 266, height: 150),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailerPlayer extends StatefulWidget {
  const _TrailerPlayer({required this.videoKey});

  final String videoKey;

  @override
  State<_TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<_TrailerPlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[TrailerPlayer] Initializing with key: ${widget.videoKey}');
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        isLive: false,
        forceHD: false,
      ),
    )..addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (mounted && _controller.value.isReady && !_isPlayerReady) {
      setState(() {
        _isPlayerReady = true;
      });
    }
    if (_controller.value.hasError) {
      debugPrint('[TrailerPlayer] Error: ${_controller.value.errorCode}');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Trailer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.cinemaScoreRing,
            onReady: () {
              debugPrint('[TrailerPlayer] Player is ready');
              _isPlayerReady = true;
            },
            onEnded: (data) {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _WatchlistButton extends ConsumerWidget {
  const _WatchlistButton({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    required this.mediaType,
    this.voteAverage,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final GlobalMediaType mediaType;
  final double? voteAverage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWatchlistAsync = ref.watch(isInWatchlistProvider(id));

    return isInWatchlistAsync.when(
      data: (isAdded) => IconButton(
        onPressed: () {
          final item = WatchlistItem(
            id: id,
            title: title,
            posterPath: posterPath,
            releaseDate: releaseDate,
            mediaType: mediaType,
            addedDate: DateTime.now(),
            voteAverage: voteAverage,
          );

          if (isAdded) {
            _showRemoveConfirmation(context, ref, item);
          } else {
            ref.read(watchlistProvider.notifier).toggleItem(item);
          }
        },
        icon: Icon(
          isAdded ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
          color: isAdded ? AppColors.cinemaAccent : Colors.white,
          size: 22,
        ),
      ),
      loading: () => const SizedBox(
        width: 48,
        height: 48,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
      error: (_, _) => IconButton(
        onPressed: null,
        icon: Icon(
          Icons.bookmark_add_outlined,
          color: Colors.white.withValues(alpha: 0.3),
          size: 22,
        ),
      ),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    WidgetRef ref,
    WatchlistItem item,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.detailsCard,
            title: const Text(
              'Remove from Watchlist?',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to remove "${item.title}" from your watchlist?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(watchlistProvider.notifier).toggleItem(item);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }
}

class _WatchedButton extends ConsumerWidget {
  const _WatchedButton({
    required this.details,
    required this.isTv,
  });

  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWatchedAsync = ref.watch(isWatchedProvider(details.id));
    final watchedItemAsync = ref.watch(watchedItemProvider(details.id));

    return isWatchedAsync.when(
      data: (isWatched) => IconButton(
        onPressed: () => _showWatchedDialog(
          context,
          ref,
          isWatched,
          watchedItemAsync.value,
        ),
        icon: Icon(
          isWatched
              ? Icons.check_circle_rounded
              : Icons.check_circle_outline_rounded,
          color: isWatched ? AppColors.cinemaAccent : Colors.white,
          size: 22,
        ),
      ),
      loading: () => const SizedBox(
        width: 48,
        height: 48,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showWatchedDialog(
    BuildContext context,
    WidgetRef ref,
    bool isWatched,
    WatchedItem? existingItem,
  ) {
    showDialog(
      context: context,
      builder: (context) => _WatchedDialog(
        details: details,
        isTv: isTv,
        existingItem: existingItem,
      ),
    );
  }
}

class _WatchedDialog extends StatefulWidget {
  const _WatchedDialog({
    required this.details,
    required this.isTv,
    this.existingItem,
  });

  final MovieDetails details;
  final bool isTv;
  final WatchedItem? existingItem;

  @override
  State<_WatchedDialog> createState() => _WatchedDialogState();
}

class _WatchedDialogState extends State<_WatchedDialog> {
  late int _rating;
  late DateTime _watchDate;
  late int _rewatchCount;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingItem?.rating ?? 5;
    _watchDate = widget.existingItem?.watchDate ?? DateTime.now();
    _rewatchCount = widget.existingItem?.rewatchCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return AlertDialog(
      backgroundColor: AppColors.detailsCard,
      title: Text(
        isEditing ? 'Edit Watched Info' : 'Mark as Watched',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: AppColors.cinemaAccent,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text(
            'Watch Date',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${_watchDate.year}-${_watchDate.month.toString().padLeft(2, '0')}-${_watchDate.day.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white70,
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _watchDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _watchDate = picked);
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Rewatch Count',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    _rewatchCount > 0
                        ? () => setState(() => _rewatchCount--)
                        : null,
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Colors.white70,
                ),
              ),
              Text(
                '$_rewatchCount',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              IconButton(
                onPressed: () => setState(() => _rewatchCount++),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (isEditing)
          Consumer(
            builder:
                (context, ref, _) => TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _removeWatched(context, ref);
                  },
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        Consumer(
          builder:
              (context, ref, _) => ElevatedButton(
                onPressed: () => _saveWatched(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cinemaAccent,
                  foregroundColor: Colors.black,
                ),
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
        ),
      ],
    );
  }

  void _saveWatched(BuildContext context, WidgetRef ref) {
    final item = WatchedItem(
      id: widget.details.id,
      title: widget.details.title,
      posterPath: widget.details.posterPath,
      mediaType: widget.isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
      watchDate: _watchDate,
      rating: _rating,
      rewatchCount: _rewatchCount,
      voteAverage: widget.details.catalogScore,
    );

    if (widget.existingItem != null) {
      ref.read(watchedItemsProvider.notifier).updateItem(item);
    } else {
      ref.read(watchedItemsProvider.notifier).addItem(item);
    }
    Navigator.pop(context);
  }

  void _removeWatched(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.detailsCard,
            title: const Text(
              'Remove from Watched?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to remove this from your watched list?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(watchedItemsProvider.notifier)
                      .removeItem(widget.details.id);
                  Navigator.pop(context); // close confirm dialog
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }
}

class _NotesSection extends ConsumerWidget {
  const _NotesSection({required this.mediaId, required this.mediaType});

  final int mediaId;
  final GlobalMediaType mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(mediaNotesProvider((id: mediaId, type: mediaType)));
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _NoteInput(mediaId: mediaId, mediaType: mediaType),
          const SizedBox(height: 20),
          notesAsync.when(
            skipLoadingOnReload: !notesAsync.hasError,
            data: (notes) {
              if (notes.isEmpty) {
                return const Center(
                  child: Text(
                    'No notes yet. Add your thoughts!',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _NoteItem(note: notes[index]),
              );
            },
            loading: () => Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShimmerEffect(
                    width: double.infinity,
                    height: 80,
                    borderRadius: 12,
                  ),
                ),
              ),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(mediaNotesProvider((id: mediaId, type: mediaType))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cinemaAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteInput extends ConsumerStatefulWidget {
  const _NoteInput({required this.mediaId, required this.mediaType});

  final int mediaId;
  final GlobalMediaType mediaType;

  @override
  ConsumerState<_NoteInput> createState() => _NoteInputState();
}

class _NoteInputState extends ConsumerState<_NoteInput> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(movieNotesActionsProvider).addNote(widget.mediaId, widget.mediaType, text);
      _controller.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add a note...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppColors.detailsCard.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cinemaAccent),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cinemaAccent),
                )
              : const Icon(Icons.send_rounded, color: AppColors.cinemaAccent),
        ),
      ],
    );
  }
}

class _NoteItem extends ConsumerWidget {
  const _NoteItem({required this.note});

  final MovieNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.detailsCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(note.createdAt),
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _confirmDelete(context, ref),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            note.text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        title: const Text('Delete Note?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this note?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              ref.read(movieNotesActionsProvider).deleteNote(note.movieId, note.mediaType, note.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
