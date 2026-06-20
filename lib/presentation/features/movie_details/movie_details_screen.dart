import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:dio/dio.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_awards_provider.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/movie_awards_helper.dart';
import 'package:cineverse/presentation/features/movie_details/full_plot_screen.dart';
import 'package:cineverse/presentation/features/home/providers/reminders_provider.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
import 'package:cineverse/presentation/widgets/trailer_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/core/config/region_preferences.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_reviews_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/notes_provider.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart'
    show mediaImagesProvider;
import 'package:cineverse/data/providers/data_providers.dart'
    show mediaRepositoryProvider;
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/full_screen_image_viewer.dart';
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/domain/entities/library_item.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/widgets/media_actions_dialogs.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:cineverse/presentation/widgets/animated_icon_action.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/quotes_carousel.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/full_cast_crew_chip.dart';
import 'package:cineverse/presentation/features/movie_details/widgets/movie_details_share_bottom_sheet.dart';

void _dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

class MovieDetailsScreen extends ConsumerWidget {
  const MovieDetailsScreen({
    super.key,
    required this.movieId,
    this.isTv = false,
    this.fromNotification = false,
    this.fromSmartLink = false,
    this.heroTag,
  });

  final int movieId;
  final bool isTv;
  final bool fromNotification;
  final bool fromSmartLink;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<MovieDetails> movieDetails = ref.watch(
      movieDetailsProvider(GetMovieDetailsParams(movieId: movieId, isTv: isTv)),
    );

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                      ShimmerEffect.textLine(
                        width: double.infinity,
                        height: 100,
                      ),
                      const SizedBox(height: 24),
                      ShimmerEffect.textLine(width: 100, height: 20),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) =>
                              ShimmerEffect.poster(width: 100, height: 150),
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
                      context.l10n.unableToLoadMovieDetails,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.errorGeneric(error.toString()),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.72,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(
                        movieDetailsProvider(
                          GetMovieDetailsParams(movieId: movieId, isTv: isTv),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cinemaAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          },
          data: (MovieDetails details) => _MovieDetailsView(
            details: details,
            isTv: isTv,
            fromNotification: fromNotification,
            fromSmartLink: fromSmartLink,
            heroTag: heroTag,
          ),
        ),
      ),
    );
  }
}

class _MovieDetailsView extends ConsumerStatefulWidget {
  const _MovieDetailsView({
    required this.details,
    required this.isTv,
    required this.fromNotification,
    required this.fromSmartLink,
    this.heroTag,
  });

  final MovieDetails details;
  final bool isTv;
  final bool fromNotification;
  final bool fromSmartLink;
  final String? heroTag;

  @override
  ConsumerState<_MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends ConsumerState<_MovieDetailsView> {
  final Dio _justWatchDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      sendTimeout: const Duration(seconds: 4),
      followRedirects: false,
      validateStatus: (int? status) => status != null && status < 500,
    ),
  );
  final Map<String, Future<String>> _justWatchLinkCache =
      <String, Future<String>>{};
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
    ref
        .read(
          mediaImagesProvider((
            id: widget.details.id,
            isTv: widget.isTv,
          )).future,
        )
        .then((images) {
          if (mounted) {
            setState(() {
              _slideshowImages = images.backdrops.isNotEmpty
                  ? images.backdrops
                  : images.posters;
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
    final List<MovieCredit> featuredCrew = _getFeaturedCrew(
      widget.details.crew,
    );
    final MovieWatchAvailability? watchAvailability =
        widget.details.watchAvailability;
    final bool hasWatchAvailability = watchAvailability?.hasProviders ?? false;

    final mediaType = widget.isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
    final watchedItemAsync = ref.watch(
      watchedItemProvider((id: widget.details.id, type: mediaType)),
    );
    final userRating = watchedItemAsync.value?.rating;

    final notesAsync = ref.watch(
      mediaNotesProvider((id: widget.details.id, type: mediaType)),
    );
    final latestNote = notesAsync.value?.lastOrNull?.text;
    final mediaImagesAsync = ref.watch(
      mediaImagesProvider((id: widget.details.id, isTv: widget.isTv)),
    );
    final String? titleLogoUrl =
        mediaImagesAsync.asData?.value.logos.firstOrNull;
    final bool isSvgTitleLogo =
        titleLogoUrl?.toLowerCase().endsWith('.svg') ?? false;

    return PopScope(
      canPop: !(widget.fromNotification || widget.fromSmartLink),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleBackNavigation();
      },
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            toolbarHeight: 56,
            backgroundColor: AppColors.cinemaGradientTop,
            elevation: 0,
            leading: IconButton(
              onPressed: _handleBackNavigation,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            title: SizedBox(
              height: 28,
              child: titleLogoUrl != null
                  ? (isSvgTitleLogo
                        ? SvgPicture.network(
                            titleLogoUrl,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            placeholderBuilder: (context) => SvgPicture.asset(
                              'assets/logos/logo.svg',
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              semanticsLabel: AppConstants.appName,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: titleLogoUrl,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            fadeInDuration: const Duration(milliseconds: 200),
                            errorWidget: (_, _, _) => SvgPicture.asset(
                              'assets/logos/logo.svg',
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              semanticsLabel: AppConstants.appName,
                            ),
                          ))
                  : SvgPicture.asset(
                      'assets/logos/logo.svg',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      semanticsLabel: AppConstants.appName,
                    ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => MovieDetailsShareBottomSheet.show(
                  context,
                  details: widget.details,
                  isTv: widget.isTv,
                  userRating: userRating,
                  userNote: latestNote,
                ),
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
                clipBehavior: Clip.hardEdge,
                children: [
                  // Backdrop Slideshow
                  Positioned.fill(
                    child: ClipRect(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1000),
                        layoutBuilder:
                            (
                              Widget? currentChild,
                              List<Widget> previousChildren,
                            ) {
                              return ClipRect(
                                child: Stack(
                                  fit: StackFit.expand,
                                  clipBehavior: Clip.hardEdge,
                                  children: <Widget>[
                                    ...previousChildren,
                                    // ignore: use_null_aware_elements
                                    if (currentChild case final child?) child,
                                  ],
                                ),
                              );
                            },
                        child: backdropUrl == null
                            ? ColoredBox(
                                key: const ValueKey('placeholder'),
                                color: AppColors.detailsBackdropPlaceholder,
                              )
                            : _MovieDetailsKenBurnsImage(
                                key: ValueKey(backdropUrl),
                                imageUrl: backdropUrl,
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
                            Colors.black.withValues(alpha: 0.42),
                            Colors.black.withValues(alpha: 0.72),
                            AppColors.cinemaBackground,
                          ],
                          stops: const <double>[0.0, 0.7, 0.9, 1.0],
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
                          tag:
                              widget.heroTag ??
                              'movie-poster-${widget.details.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.detailsPosterShadow,
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 100,
                                height: 150,
                                child: widget.details.posterPath == null
                                    ? ColoredBox(
                                        color: AppColors.detailsPosterSurface,
                                        child: const Center(
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
                                            ColoredBox(
                                              color: AppColors
                                                  .detailsPosterSurface,
                                              child: const Center(
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
                        const SizedBox(width: 16),
                        // Action Buttons beside poster
                        Expanded(
                          child: Container(
                            height: 150, // Match poster height
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _LibraryListButton(
                                    details: widget.details,
                                    isTv: widget.isTv,
                                  ),
                                  const SizedBox(width: 12),
                                  _LibraryFavouriteButton(
                                    details: widget.details,
                                    isTv: widget.isTv,
                                  ),
                                  const SizedBox(width: 12),
                                  _LibraryWatchlistButton(
                                    details: widget.details,
                                    isTv: widget.isTv,
                                  ),
                                  const SizedBox(width: 12),
                                  _WatchedButton(
                                    details: widget.details,
                                    isTv: widget.isTv,
                                  ),
                                  const SizedBox(width: 12),
                                  _GeneralReminderButton(
                                    details: widget.details,
                                    isTv: widget.isTv,
                                  ),
                                ],
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
                          context.l10n.userScore,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.details.voteCount != null)
                          Text(
                            '${_formatNumber(widget.details.voteCount!)} ${context.l10n.voteCount}',
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
                          : () => _showTrailer(context, widget.details),
                      iconAlignment: IconAlignment.start,
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: widget.details.trailerYouTubeKey == null
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white,
                        size: 24,
                      ),
                      label: Text(
                        context.l10n.playTrailer,
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

          if (externalRatings.isNotEmpty || userRating != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _ExternalRatingsRow(
                  ratings: externalRatings,
                  userRating: userRating,
                ),
              ),
            ),
          if (widget.details.hasSocialHandles)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _SocialLinksRow(details: widget.details),
              ),
            ),

          SliverToBoxAdapter(child: _AwardsSection(details: widget.details)),

          // Meta info line
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.detailsCard.withValues(alpha: 0.6),
                  border: const Border.symmetric(
                    horizontal: BorderSide(color: Colors.white10),
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
          SliverToBoxAdapter(
            child: _ContentAdvisoryCard(
              contentRating: widget.details.contentRating,
              contentRatingDescription: widget.details.contentRatingDescription,
              overview: widget.details.overview,
            ),
          ),

          // Current Season Section
          if (widget.isTv && widget.details.seasons.isNotEmpty)
            SliverToBoxAdapter(
              child: _CurrentSeasonSection(details: widget.details),
            ),

          // Tagline
          if (widget.details.tagline != null &&
              widget.details.tagline!.isNotEmpty)
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.overview,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if ((widget.details.imdbId ?? '').trim().isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => FullPlotScreen(
                                  imdbId: widget.details.imdbId!.trim(),
                                  fallbackTitle: widget.details.title,
                                  posterPath: widget.details.posterPath,
                                  releaseDate: widget.details.releaseDate,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.menu_book_rounded, size: 16),
                          label: Text(context.l10n.fullPlot),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.cinemaAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            textStyle: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if ((widget.details.imdbId ?? '').trim().isNotEmpty)
                    Text(
                      context.l10n.openCompletePlot,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    widget.details.overview ??
                        context.l10n.overviewUnavailable,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _KeywordsThemesSection(keywords: widget.details.keywords),
          ),

          SliverToBoxAdapter(
            child: _TrailersClipsSection(
              videos: widget.details.videos,
              movieTitle: widget.details.title,
              details: widget.details,
              isTv: widget.isTv,
            ),
          ),

          SliverToBoxAdapter(
            child: _ProductionCompaniesSection(
              companies: widget.details.productionCompanies,
            ),
          ),

          if (!widget.isTv &&
              widget.details.budget != null &&
              widget.details.budget! > 0 &&
              widget.details.revenue != null &&
              widget.details.revenue! > 0)
            SliverToBoxAdapter(
              child: _BoxOfficeSuccessCard(
                budget: widget.details.budget!,
                revenue: widget.details.revenue!,
              ),
            ),

          if (widget.isTv)
            SliverToBoxAdapter(
              child: _TvEpisodeTrackerCard(
                showId: widget.details.id,
                showTitle: widget.details.title,
                backdropPath:
                    widget.details.backdropPath ?? widget.details.posterPath,
                status: widget.details.status,
                lastEpisode: widget.details.lastEpisodeToAir,
                nextEpisode: widget.details.nextEpisodeToAir,
              ),
            ),

          if (!widget.isTv)
            SliverToBoxAdapter(
              child: _ReleaseAlertTimeline(
                movieId: widget.details.id,
                isTv: widget.isTv,
                title: widget.details.title,
                theatricalDate: widget.details.releaseDate,
                digitalDate: widget.details.digitalReleaseDate,
                physicalDate: widget.details.physicalReleaseDate,
              ),
            ),

          if (!widget.isTv && widget.details.belongsToCollection != null)
            SliverToBoxAdapter(
              child: _MovieCollectionSection(
                belongsToCollection: widget.details.belongsToCollection!,
              ),
            ),

          // Where to Watch
          if (hasWatchAvailability)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Consumer(
                  builder: (context, ref, _) {
                    final String resolverApiUrl = ref
                        .watch(appConfigProvider)
                        .watchProviderResolverApiUrl
                        .trim();
                    final String? canonicalLink = watchAvailability!.link;
                    final regionCode = ref
                        .watch(preferredRegionCodeProvider)
                        .toLowerCase();
                    final mediaTypePath = widget.isTv ? 'tv-show' : 'movie';
                    final Future<String> linkFuture = _resolveJustWatchLink(
                      regionCode: regionCode,
                      mediaTypePath: mediaTypePath,
                      title: widget.details.title,
                      releaseDate: widget.details.releaseDate,
                    );

                    return FutureBuilder<String>(
                      future: linkFuture,
                      builder: (context, snapshot) {
                        final String fallbackSlug = _slugify(
                          widget.details.title,
                        );
                        final String fallbackJustWatchLink =
                            'https://www.justwatch.com/$regionCode/$mediaTypePath/$fallbackSlug';
                        final String justWatchPageLink =
                            snapshot.data ?? fallbackJustWatchLink;
                        final String launchLink =
                            (canonicalLink != null && canonicalLink.isNotEmpty)
                            ? canonicalLink
                            : justWatchPageLink;
                        final String resolverSourceLink =
                            (canonicalLink != null && canonicalLink.isNotEmpty)
                            ? canonicalLink
                            : justWatchPageLink;
                        return _WatchAvailabilitySection(
                          availability: watchAvailability,
                          launchLink: launchLink,
                          resolverSourceLink: resolverSourceLink,
                          resolverApiUrl: resolverApiUrl,
                        );
                      },
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
                        context.l10n.crew,
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
                            sectionTitle: context.l10n.crew,
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
                            context.l10n.cast,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          FullCastCrewChip(
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
                            sectionTitle: context.l10n.cast,
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

          // Reviews
          SliverToBoxAdapter(
            child: _ReviewsSnippet(
              mediaId: widget.details.id,
              isTv: widget.isTv,
            ),
          ),

          if (widget.details.recommendations.isNotEmpty)
            SliverToBoxAdapter(
              child: _RecommendationsCarousel(
                movieId: widget.details.id,
                initialItems: widget.details.recommendations,
                isTv: widget.isTv,
              ),
            ),

          // Quotes Section
          SliverToBoxAdapter(
            child: QuotesCarousel(details: widget.details, isTv: widget.isTv),
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
                    _InfoRow(label: context.l10n.status, value: widget.details.status!),
                  if (widget.details.originalLanguage != null)
                    _InfoRow(
                      label: context.l10n.originalLanguage,
                      value: _formatLanguage(widget.details.originalLanguage!),
                    ),
                  if (widget.details.budget != null &&
                      widget.details.budget! > 0)
                    _InfoRow(
                      label: context.l10n.budget,
                      value: _formatCurrency(widget.details.budget!),
                    ),
                  if (widget.details.revenue != null &&
                      widget.details.revenue! > 0)
                    _InfoRow(
                      label: context.l10n.revenue,
                      value: _formatCurrency(widget.details.revenue!),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _NotesSection(
              mediaId: widget.details.id,
              mediaType: widget.isTv
                  ? GlobalMediaType.tv
                  : GlobalMediaType.movie,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBackNavigation() async {
    if (!mounted) {
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goNamed(AppRoute.explore.name);
  }

  void _showTrailer(BuildContext context, MovieDetails details) {
    final String? trailerKey = details.trailerYouTubeKey;
    if (trailerKey == null || trailerKey.isEmpty) {
      return;
    }

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => TrailerPlayerScreen(
          data: TrailerPlaybackData(
            videoKey: trailerKey,
            title: details.title,
            tagline: details.tagline,
            overview: details.overview,
            posterPath: details.posterPath,
            backdropPath: details.backdropPath,
            releaseDate: details.releaseDate,
            runtimeMinutes: details.runtimeMinutes,
            voteAverage: details.catalogScore,
            voteCount: details.voteCount,
            categoryLabel: widget.isTv ? context.l10n.tvShow : context.l10n.movie,
            sourceMediaId: details.id,
            isTv: widget.isTv,
            recommendations: details.recommendations,
          ),
        ),
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
        .replaceAll(RegExp(r'-+'), '-') // Remove duplicate hyphens
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<String> _resolveJustWatchLink({
    required String regionCode,
    required String mediaTypePath,
    required String title,
    required String? releaseDate,
  }) {
    final String cacheKey =
        '$regionCode|$mediaTypePath|$title|${releaseDate ?? ''}';
    return _justWatchLinkCache.putIfAbsent(
      cacheKey,
      () => _computeJustWatchLink(
        regionCode: regionCode,
        mediaTypePath: mediaTypePath,
        title: title,
        releaseDate: releaseDate,
      ),
    );
  }

  Future<String> _computeJustWatchLink({
    required String regionCode,
    required String mediaTypePath,
    required String title,
    required String? releaseDate,
  }) async {
    final String slug = _slugify(title);
    final String baseLink =
        'https://www.justwatch.com/$regionCode/$mediaTypePath/$slug';

    final bool baseExists = await _justWatchUrlExists(baseLink);
    if (baseExists) {
      return baseLink;
    }

    final String? releaseYear = _extractYear(releaseDate);
    if (releaseYear != null && releaseYear.isNotEmpty) {
      final String yearLink =
          'https://www.justwatch.com/$regionCode/$mediaTypePath/$slug-$releaseYear';
      final bool yearExists = await _justWatchUrlExists(yearLink);
      if (yearExists) {
        return yearLink;
      }
    }

    return baseLink;
  }

  Future<bool> _justWatchUrlExists(String url) async {
    try {
      final Response<void> headResponse = await _justWatchDio.head<void>(url);
      final int status = headResponse.statusCode ?? 0;
      if (status == 404) {
        return false;
      }
      if (status >= 200 && status < 400) {
        return true;
      }
      if (status == 405) {
        final Response<void> getResponse = await _justWatchDio.get<void>(url);
        final int getStatus = getResponse.statusCode ?? 0;
        return getStatus >= 200 && getStatus < 400;
      }
      return false;
    } on DioException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
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
      final countrySuffix = details.productionCountries.isNotEmpty
          ? details.productionCountries.first
          : 'US';
      parts.add('${details.releaseDate!} ($countrySuffix)');
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
    final Map<
      String,
      ({int id, String name, String? imageUrl, List<String> roles})
    >
    crewMap = {};

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
        .map(
          (e) => MovieCredit(
            id: e.id,
            name: e.name,
            role: e.roles.join(', '),
            imageUrl: e.imageUrl,
          ),
        )
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
    final Map<String, String> languages = {
      'en': context.l10n.english,
      'es': context.l10n.spanish,
      'fr': context.l10n.french,
      'de': context.l10n.german,
      'it': context.l10n.italian,
      'ja': context.l10n.japanese,
      'ko': context.l10n.korean,
      'zh': context.l10n.chinese,
      'hi': context.l10n.hindi,
      'pt': context.l10n.portuguese,
      'ru': context.l10n.russian,
      'ar': context.l10n.arabic,
    };
    return languages[code] ?? code.toUpperCase();
  }
}

class _ImagesCarousel extends ConsumerWidget {
  const _ImagesCarousel({required this.movieId, required this.isTv});

  final int movieId;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(
      mediaImagesProvider((id: movieId, isTv: isTv)),
    );
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
                context.l10n.images,
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
                      _dismissKeyboard();
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
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image,
                            color: Colors.white24,
                          ),
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
  const _ExternalRatingsRow({required this.ratings, this.userRating});

  final List<MovieRating> ratings;
  final int? userRating;

  @override
  Widget build(BuildContext context) {
    final MovieRating? rottenTomatoes = _ratingForSource(
      ratings,
      'Rotten Tomatoes',
    );
    final MovieRating? imdb = _ratingForSource(ratings, 'IMDb');
    final MovieRating? metacritic = _ratingForSource(ratings, 'Metacritic');
    final List<Widget> chips = <Widget>[];

    if ((userRating ?? 0) > 0) {
      chips.add(
        _ExternalRatingChip(
          value: '$userRating.0',
          sourceIcon: Icon(
            Icons.person_rounded,
            color: AppColors.cinemaAccent,
            size: 18,
          ),
          label: context.l10n.yours,
        ),
      );
    }

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

class _SocialLinksRow extends StatelessWidget {
  const _SocialLinksRow({required this.details});

  final MovieDetails details;

  @override
  Widget build(BuildContext context) {
    final List<_SocialLinkItem> links =
        <_SocialLinkItem>[
              _SocialLinkItem(
                label: context.l10n.instagram,
                icon: const FaIcon(FontAwesomeIcons.instagram),
                url: _socialProfileUrl('instagram', details.instagramId),
              ),
              _SocialLinkItem(
                label: context.l10n.twitterX,
                icon: const FaIcon(FontAwesomeIcons.xTwitter),
                url: _socialProfileUrl('x', details.twitterId),
              ),
              _SocialLinkItem(
                label: context.l10n.facebook,
                icon: const FaIcon(FontAwesomeIcons.facebook),
                url: _socialProfileUrl('facebook', details.facebookId),
              ),
              _SocialLinkItem(
                label: context.l10n.tikTok,
                icon: const FaIcon(FontAwesomeIcons.tiktok),
                url: _socialProfileUrl('tiktok', details.tiktokId),
              ),
              _SocialLinkItem(
                label: context.l10n.youtube,
                icon: const FaIcon(FontAwesomeIcons.youtube),
                url: _socialProfileUrl('youtube', details.youtubeId),
              ),
            ]
            .where((item) => item.url != null && item.url!.isNotEmpty)
            .toList(growable: false);

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: links
          .map(
            (link) => _SocialLinkChip(
              label: link.label,
              icon: link.icon,
              url: link.url!,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SocialLinkItem {
  const _SocialLinkItem({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final Widget icon;
  final String? url;
}

class _SocialLinkChip extends StatelessWidget {
  const _SocialLinkChip({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final Widget icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.detailsCard.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final Uri uri = Uri.parse(url);
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
            children: [
              IconTheme(
                data: IconThemeData(
                  size: 15.5,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
                child: icon,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _socialProfileUrl(String platform, String? rawId) {
  final String id = (rawId ?? '').trim();
  if (id.isEmpty) return null;
  switch (platform) {
    case 'instagram':
      return 'https://www.instagram.com/$id';
    case 'x':
      return 'https://x.com/$id';
    case 'facebook':
      return 'https://www.facebook.com/$id';
    case 'tiktok':
      final String handle = id.startsWith('@') ? id : '@$id';
      return 'https://www.tiktok.com/$handle';
    case 'youtube':
      if (id.startsWith('UC')) {
        return 'https://www.youtube.com/channel/$id';
      }
      final String handle = id.startsWith('@') ? id : '@$id';
      return 'https://www.youtube.com/$handle';
    case 'imdb':
      if (id.startsWith('tt')) {
        return 'https://www.imdb.com/title/$id/';
      }
      if (id.startsWith('nm')) {
        return 'https://www.imdb.com/name/$id/';
      }
      return null;
    default:
      return null;
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
    this.label,
  });

  final String value;
  final Widget sourceIcon;
  final String? url;
  final String? label;

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
              if (label != null) ...[
                Text(
                  label!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.cinemaAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
              ],
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
    required this.launchLink,
    required this.resolverSourceLink,
    this.resolverApiUrl,
  });

  final MovieWatchAvailability availability;
  final String launchLink;
  final String resolverSourceLink;
  final String? resolverApiUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.whereToWatch,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (availability.streaming.isNotEmpty)
          _WatchProviderRow(
            label: context.l10n.stream,
            providers: availability.streaming,
            launchLink: launchLink,
            resolverSourceLink: resolverSourceLink,
            resolverApiUrl: resolverApiUrl,
          ),
        if (availability.free.isNotEmpty)
          _WatchProviderRow(
            label: context.l10n.free,
            providers: availability.free,
            launchLink: launchLink,
            resolverSourceLink: resolverSourceLink,
            resolverApiUrl: resolverApiUrl,
          ),
        if (availability.rent.isNotEmpty)
          _WatchProviderRow(
            label: context.l10n.rent,
            providers: availability.rent,
            launchLink: launchLink,
            resolverSourceLink: resolverSourceLink,
            resolverApiUrl: resolverApiUrl,
          ),
        if (availability.buy.isNotEmpty)
          _WatchProviderRow(
            label: context.l10n.buy,
            providers: availability.buy,
            launchLink: launchLink,
            resolverSourceLink: resolverSourceLink,
            resolverApiUrl: resolverApiUrl,
          ),
        const SizedBox(height: 8),
        Text(
          context.l10n.availabilityDataByJustWatch,
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
    this.launchLink,
    this.resolverSourceLink,
    this.resolverApiUrl,
  });

  final String label;
  final List<MovieWatchProvider> providers;
  final String? launchLink;
  final String? resolverSourceLink;
  final String? resolverApiUrl;

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
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: providers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _WatchProviderCard(
                provider: providers[index],
                launchLink: launchLink,
                resolverSourceLink: resolverSourceLink,
                resolverApiUrl: resolverApiUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchProviderCard extends StatelessWidget {
  const _WatchProviderCard({
    required this.provider,
    this.launchLink,
    this.resolverSourceLink,
    this.resolverApiUrl,
  });

  final MovieWatchProvider provider;
  final String? launchLink;
  final String? resolverSourceLink;
  final String? resolverApiUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: launchLink == null
          ? null
          : () async {
              String targetLink = launchLink!;
              final String resolverUrl = (resolverApiUrl ?? '').trim();
              final String sourceUrl = (resolverSourceLink ?? '').trim();
              if (resolverUrl.isNotEmpty && sourceUrl.isNotEmpty) {
                final String? resolved = await _resolveProviderLinkWithDialog(
                  context: context,
                  resolverUrl: resolverUrl,
                  sourceUrl: sourceUrl,
                  providerName: provider.name,
                );
                if (resolved != null && resolved.isNotEmpty) {
                  targetLink = resolved;
                }
              }
              final Uri uri = Uri.parse(targetLink);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('Could not launch $targetLink: $e');
              }
            },
      child: Container(
        width: 78,
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: provider.logoPath == null
                  ? const Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white70,
                      size: 20,
                    )
                  : CachedNetworkImage(
                      imageUrl: provider.logoPath!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          ColoredBox(color: AppColors.detailsPosterSurface),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white70,
                        size: 20,
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
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
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

final Dio _watchProviderResolverDio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 6),
    sendTimeout: const Duration(seconds: 5),
    validateStatus: (int? status) => status != null && status < 500,
    headers: const <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ),
);

Future<String?> _resolveProviderLink({
  required String resolverUrl,
  required String sourceUrl,
  required String providerName,
}) async {
  try {
    final Response<Map<String, dynamic>> response =
        await _watchProviderResolverDio.post<Map<String, dynamic>>(
          resolverUrl,
          data: <String, dynamic>{
            'justwatchUrl': sourceUrl,
            'providerName': providerName,
          },
        );
    final Map<String, dynamic>? payload = response.data;
    final String resolved = (payload?['resolvedUrl'] as String? ?? '').trim();
    return resolved.isEmpty ? null : resolved;
  } catch (error) {
    debugPrint('Resolver call failed for $providerName: $error');
    return null;
  }
}

Future<String?> _resolveProviderLinkWithDialog({
  required BuildContext context,
  required String resolverUrl,
  required String sourceUrl,
  required String providerName,
}) async {
  DialogRoute<void>? dialogRoute;
  NavigatorState? dialogNavigator;
  bool finished = false;
  final Timer showTimer = Timer(const Duration(milliseconds: 180), () {
    if (finished || !context.mounted) return;
    dialogNavigator = Navigator.of(context, rootNavigator: true);
    dialogRoute = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.cinemaBackground.withValues(alpha: 0.62),
      builder: (_) => const _WatchProviderLinkLoadingDialog(),
    );
    dialogNavigator?.push(dialogRoute!);
  });

  try {
    return await _resolveProviderLink(
      resolverUrl: resolverUrl,
      sourceUrl: sourceUrl,
      providerName: providerName,
    );
  } finally {
    finished = true;
    showTimer.cancel();
    final DialogRoute<void>? route = dialogRoute;
    if (route != null && route.isActive) {
      dialogNavigator?.removeRoute(route);
    }
  }
}

class _WatchProviderLinkLoadingDialog extends StatefulWidget {
  const _WatchProviderLinkLoadingDialog();

  @override
  State<_WatchProviderLinkLoadingDialog> createState() =>
      _WatchProviderLinkLoadingDialogState();
}

class _WatchProviderLinkLoadingDialogState
    extends State<_WatchProviderLinkLoadingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 290,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.cinemaPanelTop.withValues(alpha: 0.97),
                AppColors.cinemaPanelMid.withValues(alpha: 0.97),
                AppColors.cinemaPanelBottom.withValues(alpha: 0.97),
              ],
            ),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.45),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.detailsCardShadow.withValues(alpha: 0.55),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double t = _controller.value;
                      final double pulse =
                          0.9 + (math.sin(t * 2 * math.pi) * 0.1);
                      return Transform.scale(scale: pulse, child: child);
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.cinemaAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.link_rounded,
                        color: AppColors.cinemaAccent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.fetchingWatchLink,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.findingBestProviderPage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 5,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return LinearProgressIndicator(
                        value: null,
                        color: AppColors.cinemaAccent.withValues(alpha: 0.92),
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieDetailsKenBurnsImage extends StatefulWidget {
  const _MovieDetailsKenBurnsImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  State<_MovieDetailsKenBurnsImage> createState() =>
      _MovieDetailsKenBurnsImageState();
}

class _MovieDetailsKenBurnsImageState extends State<_MovieDetailsKenBurnsImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _panAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _controller.forward();
  }

  void _initAnimations() {
    final int hash = widget.imageUrl.hashCode;
    final int direction = hash % 4;
    final bool zoomIn = hash.isEven;

    _scaleAnimation = Tween<double>(
      begin: zoomIn ? 1.06 : 1.16,
      end: zoomIn ? 1.16 : 1.06,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    Offset startOffset;
    Offset endOffset;
    switch (direction) {
      case 0:
        startOffset = const Offset(-0.02, -0.02);
        endOffset = const Offset(0.02, 0.02);
        break;
      case 1:
        startOffset = const Offset(0.02, -0.02);
        endOffset = const Offset(-0.02, 0.02);
        break;
      case 2:
        startOffset = const Offset(-0.02, 0.02);
        endOffset = const Offset(0.02, -0.02);
        break;
      case 3:
      default:
        startOffset = const Offset(0.02, 0.02);
        endOffset = const Offset(-0.02, -0.02);
        break;
    }

    _panAnimation = Tween<Offset>(
      begin: startOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(covariant _MovieDetailsKenBurnsImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _initAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SlideTransition(
        position: _panAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) =>
                ColoredBox(color: AppColors.detailsBackdropPlaceholder),
            errorWidget: (context, url, error) =>
                ColoredBox(color: AppColors.detailsBackdropPlaceholder),
          ),
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
              context.l10n.recommendations,
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
                  return SizedBox(
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
                  sectionTitle: context.l10n.recommendations,
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

class _WatchedButton extends ConsumerWidget {
  const _WatchedButton({required this.details, required this.isTv});

  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
    final isWatchedAsync = ref.watch(
      isWatchedProvider((id: details.id, type: mediaType)),
    );
    final watchedItemAsync = ref.watch(
      watchedItemProvider((id: details.id, type: mediaType)),
    );

    return isWatchedAsync.when(
      data: (isWatched) => _CircleActionButton(
        onPressed: () =>
            _showWatchedDialog(context, ref, isWatched, watchedItemAsync.value),
        icon: isWatched
            ? Icons.check_circle_rounded
            : Icons.check_circle_outline_rounded,
        iconColor: Colors.white,
        activeIconColor: AppColors.cinemaAccent,
        isActive: isWatched,
      ),
      loading: () => const _CircleActionShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showWatchedDialog(
    BuildContext context,
    WidgetRef ref,
    bool isWatched,
    WatchedItem? existingItem,
  ) {
    _dismissKeyboard();
    showAnimatedDialog(
      context: context,
      builder: (context) => WatchedDialog(
        details: details,
        isTv: isTv,
        existingItem: existingItem,
      ),
    );
  }
}

class _GeneralReminderButton extends ConsumerWidget {
  const _GeneralReminderButton({required this.details, required this.isTv});

  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<AppReminder> activeReminders = ref.watch(
      mediaRemindersProvider((mediaId: details.id, isTv: isTv)),
    );
    final bool hasActiveReminder = activeReminders.isNotEmpty;

    return _CircleActionButton(
      icon: hasActiveReminder
          ? Icons.notifications_active_rounded
          : Icons.notifications_none_rounded,
      iconColor: Colors.white,
      activeIconColor: AppColors.cinemaWarmGlow,
      isActive: hasActiveReminder,
      onPressed: () => _showReminderDialog(context, ref),
    );
  }

  Future<void> _showReminderDialog(BuildContext context, WidgetRef ref) async {
    if (ref
        .read(mediaRemindersProvider((mediaId: details.id, isTv: isTv)))
        .isNotEmpty) {
      await ref
          .read(remindersProvider.notifier)
          .dismissRemindersForMedia(mediaId: details.id, isTv: isTv);
      if (context.mounted) {
        ToastUtils.showToast(context, context.l10n.reminderRemoved);
      }
      return;
    }

    final GeneralReminderDialogResult? result =
        await showAnimatedDialog<GeneralReminderDialogResult>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const GeneralReminderDialog(),
        );

    if (result == null || !context.mounted) {
      return;
    }

    await ref
        .read(remindersProvider.notifier)
        .addReminder(
          AppReminder(
            id: buildGeneralMediaReminderId(mediaId: details.id, isTv: isTv),
            type: ReminderType.general,
            title: details.title,
            message: result.reminderText.trim().isEmpty
                ? context.l10n.reminderForTitle(details.title)
                : result.reminderText,
            notifyAt: result.notifyAt,
            createdAt: DateTime.now(),
            mediaId: details.id,
            isTv: isTv,
            backdropPath: details.backdropPath ?? details.posterPath,
          ),
        );

    if (context.mounted) {
      ToastUtils.showToast(context, context.l10n.reminderSaved);
    }
  }
}

class GeneralReminderDialogResult {
  const GeneralReminderDialogResult({
    required this.reminderText,
    required this.notifyAt,
  });

  final String reminderText;
  final DateTime notifyAt;
}

class GeneralReminderDialog extends StatefulWidget {
  const GeneralReminderDialog({super.key});

  @override
  State<GeneralReminderDialog> createState() => GeneralReminderDialogState();
}

class GeneralReminderDialogState extends State<GeneralReminderDialog> {
  late final TextEditingController _textController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      useRootNavigator: false,
      initialDate: _selectedDateTime,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) {
      return;
    }

    final TimeOfDay? time = await showTimePicker(
      context: context,
      useRootNavigator: false,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save() {
    final String reminderText = _textController.text.trim();
    if (!_selectedDateTime.isAfter(DateTime.now())) {
      ToastUtils.showToast(context, context.l10n.pleaseSelectFutureTime);
      return;
    }

    Navigator.of(context).pop(
      GeneralReminderDialogResult(
        reminderText: reminderText,
        notifyAt: _selectedDateTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: AppColors.detailsCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      title: Text(
        context.l10n.setReminder,
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: context.l10n.addBriefNoteHint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.cinemaAccent,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.notifyAt,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat(
                        'EEE, d MMM yyyy • hh:mm a',
                      ).format(_selectedDateTime),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.cinemaAccent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: Colors.white60),
          child: Text(
            context.l10n.cancel,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cinemaAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            context.l10n.save,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _NotesSection extends ConsumerWidget {
  const _NotesSection({required this.mediaId, required this.mediaType});

  final int mediaId;
  final GlobalMediaType mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(
      mediaNotesProvider((id: mediaId, type: mediaType)),
    );
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.notes,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _NoteInput(mediaId: mediaId, mediaType: mediaType),
          const SizedBox(height: 8),
          notesAsync.when(
            skipLoadingOnReload: !notesAsync.hasError,
            data: (notes) {
              if (notes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      context.l10n.noNotesYet,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: notes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: 280,
                    child: _NoteItem(
                      note: notes[index],
                      mediaId: mediaId,
                      mediaType: mediaType,
                    ),
                  ),
                ),
              );
            },
            loading: () => Column(
              children: List.generate(
                2,
                (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
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
                    context.l10n.errorGeneric(err.toString()),
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(
                      mediaNotesProvider((id: mediaId, type: mediaType)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cinemaAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(context.l10n.retry),
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

class _NoteItem extends ConsumerWidget {
  const _NoteItem({
    required this.note,
    required this.mediaId,
    required this.mediaType,
  });

  final MovieNote note;
  final int mediaId;
  final GlobalMediaType mediaType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');

    return InkWell(
      onTap: () {
        _dismissKeyboard();
        showAnimatedDialog(
          context: context,
          builder: (context) => AddNoteDialog(
            mediaId: mediaId,
            mediaType: mediaType,
            initialNote: note,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                note.text,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    _dismissKeyboard();
    showAnimatedDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: Text(
          context.l10n.deleteNoteConfirmationTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          context.l10n.areYouSureDeleteNote,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(movieNotesActionsProvider)
                  .deleteNote(note.movieId, note.mediaType, note.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(
              context.l10n.deleteNote,
              style: TextStyle(fontWeight: FontWeight.bold),
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
      await ref
          .read(movieNotesActionsProvider)
          .addNote(widget.mediaId, widget.mediaType, text);
      _controller.clear();
      if (mounted) {
        ToastUtils.showToast(context, context.l10n.noteAdded);
        FocusScope.of(context).unfocus();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget noteField = TextField(
      controller: _controller,
      onTapOutside: (_) => _dismissKeyboard(),
      maxLines: null,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: context.l10n.addNoteHint,
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
          borderSide: BorderSide(color: AppColors.cinemaAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );

    final Widget submitButton = SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: _isSubmitting ? null : _submit,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        icon: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.cinemaAccent,
                ),
              )
            : Icon(Icons.send_rounded, color: AppColors.cinemaAccent),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              noteField,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: submitButton),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: noteField),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: submitButton,
            ),
          ],
        );
      },
    );
  }
}

class _CurrentSeasonSection extends StatelessWidget {
  const _CurrentSeasonSection({required this.details});

  final MovieDetails details;

  @override
  Widget build(BuildContext context) {
    // Find current season: last one in the list that is not a special
    final currentSeason = details.seasons.lastWhere(
      (s) => s.seasonNumber > 0,
      orElse: () => details.seasons.first,
    );

    final dateStr = currentSeason.airDate?.substring(0, 4);

    final isEnded = details.status == 'Ended' || details.status == 'Canceled';
    final sectionLabel =
        isEnded ? context.l10n.lastSeason : context.l10n.currentSeason;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              _dismissKeyboard();
              context.pushNamed(
                AppRoute.seasonDetails.name,
                pathParameters: {
                  'tvId': details.id.toString(),
                  'seasonNumber': currentSeason.seasonNumber.toString(),
                },
                queryParameters: {'showTitle': details.title},
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.detailsCard.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 120,
                      child: currentSeason.posterPath != null
                          ? CachedNetworkImage(
                              imageUrl: currentSeason.posterPath!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.white10),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSeason.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (currentSeason.voteAverage != null &&
                                currentSeason.voteAverage! > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cinemaAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  context.l10n.seasonRating(
                                    '${(currentSeason.voteAverage! * 10).toInt()}',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '${dateStr ?? ''} • ${currentSeason.episodeCount} ${context.l10n.episodes}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (currentSeason.overview != null &&
                            currentSeason.overview!.isNotEmpty)
                          Text(
                            currentSeason.overview!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            context.l10n.noOverviewForSeason,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _dismissKeyboard();
              context.pushNamed(
                AppRoute.allSeasons.name,
                pathParameters: {'tvId': details.id.toString()},
                extra: {
                  'showTitle': details.title,
                  'seasons': details.seasons,
                  'tvId': details.id,
                },
              );
            },
            child: Text(
              context.l10n.viewAllSeasons,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryListButton extends ConsumerWidget {
  const _LibraryListButton({required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CircleActionButton(
      icon: Icons.list_rounded,
      onPressed: () => _showAddToListDialog(context, ref),
    );
  }

  void _showAddToListDialog(BuildContext context, WidgetRef ref) {
    _dismissKeyboard();
    showAnimatedDialog(
      context: context,
      builder: (context) => AddToListDialog(details: details, isTv: isTv),
    );
  }
}

class _LibraryFavouriteButton extends ConsumerWidget {
  const _LibraryFavouriteButton({required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;
    final isFav = ref.watch(
      isFavouriteProvider((id: details.id, type: mediaType)),
    );

    return _CircleActionButton(
      icon: isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
      iconColor: Colors.white,
      activeIconColor: AppColors.cinemaAccent,
      isActive: isFav,
      onPressed: () async {
        final item = FavouriteItem(
          id: details.id,
          title: details.title,
          posterPath: details.posterPath,
          releaseDate: details.releaseDate,
          mediaType: mediaType,
          addedDate: DateTime.now(),
          voteAverage: details.catalogScore,
        );
        await ref.read(favouritesProvider.notifier).toggleFavourite(item);
        if (context.mounted) {
          ToastUtils.showToast(
            context,
            isFav
                ? context.l10n.removedFromFavourites
                : context.l10n.addedToFavourites,
          );
        }
      },
    );
  }
}

class _LibraryWatchlistButton extends ConsumerWidget {
  const _LibraryWatchlistButton({required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWatchlistAsync = ref.watch(isInWatchlistProvider(details.id));

    return isInWatchlistAsync.when(
      data: (isAdded) => _CircleActionButton(
        icon: isAdded ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
        iconColor: Colors.white,
        activeIconColor: AppColors.cinemaAccent,
        isActive: isAdded,
        onPressed: () async {
          final item = WatchlistItem(
            id: details.id,
            title: details.title,
            posterPath: details.posterPath,
            releaseDate: details.releaseDate,
            mediaType: isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
            addedDate: DateTime.now(),
            voteAverage: details.catalogScore,
          );
          await ref.read(watchlistProvider.notifier).toggleItem(item);
          if (context.mounted) {
            ToastUtils.showToast(
              context,
              isAdded ? context.l10n.removedFromWatchlist : context.l10n.addedToWatchlist,
            );
          }
        },
      ),
      loading: () => const _CircleActionShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.activeIconColor,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color? activeIconColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = isActive
        ? (activeIconColor ?? AppColors.cinemaAccent)
        : iconColor;
    final Color surfaceColor = Color.alphaBlend(
      Colors.white.withValues(alpha: isActive ? 0.06 : 0.03),
      AppColors.detailsCard.withValues(alpha: 0.95),
    );
    final Color borderColor = isActive
        ? AppColors.cinemaAccent.withValues(alpha: 0.48)
        : Colors.white.withValues(alpha: 0.14);

    return Material(
      color: surfaceColor,
      shape: const CircleBorder(),
      shadowColor: AppColors.detailsCardShadow.withValues(alpha: 0.55),
      elevation: isActive ? 8 : 4,
      child: AnimatedIconAction(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: effectiveIconColor, size: 20),
          ),
        ),
      ),
    );
  }
}

class _CircleActionShimmer extends StatelessWidget {
  const _CircleActionShimmer();
  @override
  Widget build(BuildContext context) {
    return const ShimmerEffect(width: 40, height: 40, borderRadius: 20);
  }
}

class _ReviewsSnippet extends ConsumerWidget {
  const _ReviewsSnippet({required this.mediaId, required this.isTv});

  final int mediaId;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewsAsync = ref.watch(
      mediaReviewsProvider((id: mediaId, isTv: isTv)),
    );

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) return const SizedBox.shrink();

        final firstReview = reviews.first;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.userReviews,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _dismissKeyboard();
                      context.pushNamed(
                        AppRoute.allReviews.name,
                        queryParameters: {
                          'id': mediaId.toString(),
                          'isTv': isTv.toString(),
                        },
                      );
                    },
                    child: Text(
                      context.l10n.seeAllReviews(reviews.length),
                      style: TextStyle(color: AppColors.cinemaAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (firstReview.authorAvatarPath != null)
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: CachedNetworkImageProvider(
                              firstReview.authorAvatarPath!,
                            ),
                          )
                        else
                          const CircleAvatar(
                            radius: 14,
                            child: Icon(Icons.person, size: 16),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstReview.author,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                DateFormat.yMMMd().format(
                                  firstReview.createdAt,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (firstReview.authorRating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cinemaAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  firstReview.authorRating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      firstReview.content,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _AwardsSection extends ConsumerWidget {
  const _AwardsSection({required this.details});

  final MovieDetails details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String? imdbId = details.imdbId;

    // Use pre-fetched awards if available.
    if (details.awards != null) {
      final MovieAwards parsed = MovieAwards.parse(details.awards);
      if (!parsed.hasAwards) return const SizedBox.shrink();
      return _buildAwardsContent(context, theme, parsed);
    }

    // If awards info is not pre-fetched, but we have imdbId, load it lazily.
    if (imdbId != null && imdbId.isNotEmpty) {
      final awardsAsync = ref.watch(
        movieAwardsProvider(
          MovieAwardsRequest(movieId: details.id, imdbId: imdbId),
        ),
      );
      return awardsAsync.when(
        data: (MovieAwards parsed) {
          if (!parsed.hasAwards) return const SizedBox.shrink();
          return _buildAwardsContent(context, theme, parsed);
        },
        loading: () => const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _AwardsShimmer(),
        ),
        error: (_, _) => const SizedBox.shrink(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAwardsContent(
    BuildContext context,
    ThemeData theme,
    MovieAwards awards,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.detailsCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFD700), // Gold Color for trophy
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.awardsAndNominations,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    awards.displaySummary,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ActionChip(
              onPressed: () {
                _dismissKeyboard();
                context.pushNamed(
                  AppRoute.movieAwards.name,
                  extra: <String, dynamic>{
                    'awards': awards,
                    'movieTitle': details.title,
                  },
                );
              },
              backgroundColor: AppColors.cinemaAccent.withValues(alpha: 0.15),
              side: BorderSide(
                color: AppColors.cinemaAccent.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.viewAll,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.cinemaAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.cinemaAccent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AwardsShimmer extends StatelessWidget {
  const _AwardsShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.detailsCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const ShimmerEffect(width: 24, height: 24, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerEffect.textLine(width: 100, height: 10),
                const SizedBox(height: 6),
                ShimmerEffect.textLine(width: 150, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxOfficeSuccessCard extends StatelessWidget {
  const _BoxOfficeSuccessCard({required this.budget, required this.revenue});

  final int budget;
  final int revenue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int netProfit = revenue - budget;
    final double roi = budget > 0 ? (netProfit / budget) * 100 : 0.0;

    String statusText;
    Color statusColor;
    double progressValue; // 0.0 to 1.0

    if (roi >= 150) {
      statusText = context.l10n.blockbuster;
      statusColor = const Color(0xFF00E5FF); // Cyan
      progressValue = 1.0;
    } else if (roi >= 100) {
      statusText = context.l10n.hit;
      statusColor = const Color(0xFF00E676); // Neon Green
      progressValue = 0.8;
    } else if (roi >= 0) {
      statusText = context.l10n.breakEven;
      statusColor = const Color(0xFFFFD740); // Amber
      progressValue = 0.5;
    } else if (roi >= -50) {
      statusText = context.l10n.underperformer;
      statusColor = const Color(0xFFFF9100); // Orange
      progressValue = 0.3;
    } else {
      statusText = context.l10n.boxOfficeBomb;
      statusColor = const Color(0xFFFF1744); // Red
      progressValue = 0.1;
    }

    String formatCurrency(int amount) {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.detailsCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.boxOfficeFinancials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _FinancialItem(
                    label: context.l10n.budget,
                    value: formatCurrency(budget),
                  ),
                ),
                Expanded(
                  child: _FinancialItem(
                    label: context.l10n.revenue,
                    value: formatCurrency(revenue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FinancialItem(
                    label: context.l10n.netProfit,
                    value: formatCurrency(netProfit),
                    valueColor: netProfit >= 0
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF1744),
                  ),
                ),
                Expanded(
                  child: _FinancialItem(
                    label: context.l10n.roi,
                    value: '${roi.toStringAsFixed(1)}%',
                    valueColor: roi >= 0
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF1744),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.successMeter,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(progressValue * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    color: statusColor,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialItem extends StatelessWidget {
  const _FinancialItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TvEpisodeTrackerCard extends ConsumerStatefulWidget {
  const _TvEpisodeTrackerCard({
    required this.showId,
    required this.showTitle,
    this.backdropPath,
    required this.status,
    this.lastEpisode,
    this.nextEpisode,
  });

  final int showId;
  final String showTitle;
  final String? backdropPath;
  final String? status;
  final TvEpisode? lastEpisode;
  final TvEpisode? nextEpisode;

  @override
  ConsumerState<_TvEpisodeTrackerCard> createState() =>
      _TvEpisodeTrackerCardState();
}

class _TvEpisodeTrackerCardState extends ConsumerState<_TvEpisodeTrackerCard> {
  Timer? _timer;
  Duration? _timeRemaining;
  bool _isSettingEpisodeReminder = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _TvEpisodeTrackerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateTimeRemaining();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateTimeRemaining();
      }
    });
  }

  void _calculateTimeRemaining() {
    final DateTime? nextAirDate = _getNextAirDateTime();
    if (nextAirDate == null) {
      _timeRemaining = null;
      return;
    }
    final now = DateTime.now();
    final difference = nextAirDate.difference(now);
    if (difference.isNegative) {
      setState(() {
        _timeRemaining = Duration.zero;
      });
      _timer?.cancel();
    } else {
      setState(() {
        _timeRemaining = difference;
      });
    }
  }

  DateTime? _getNextAirDateTime() {
    final String? rawDate = widget.nextEpisode?.airDate;
    if (rawDate == null || rawDate.trim().isEmpty) {
      return null;
    }

    final DateTime? parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return null;
    }

    // TMDB episode air date is often date-only; assume end of day for reminders.
    if (!rawDate.contains('T')) {
      return DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
    }

    return parsed.toLocal();
  }

  Future<void> _setEpisodeAiringReminder() async {
    if (_isSettingEpisodeReminder) {
      return;
    }
    final DateTime? nextAirDate = _getNextAirDateTime();
    if (nextAirDate == null) {
      return;
    }

    final int maxHours = nextAirDate.difference(DateTime.now()).inHours;
    if (maxHours <= 0) {
      if (mounted) {
        ToastUtils.showToast(context, 'This episode is already due to air');
      }
      return;
    }

    _isSettingEpisodeReminder = true;
    try {
      String hoursInput = maxHours >= 6 ? '6' : '$maxHours';

      final int? hoursBefore = await showAnimatedDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                backgroundColor: AppColors.detailsCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                title: Text(
                  context.l10n.episodeReminder,
                  style: Theme.of(dialogContext).textTheme.titleMedium
                      ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.notifyHoursBeforeAiring,
                      style: Theme.of(dialogContext).textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: hoursInput,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (value) {
                        setDialogState(() {
                          hoursInput = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: context.l10n.hoursBeforeAirTime,
                        hintStyle: const TextStyle(color: Colors.white38),
                        helperText: context.l10n.chooseBetweenHours(maxHours),
                        helperStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.03),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.cinemaAccent,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                    ),
                    child: Text(
                      context.l10n.cancel,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final int? parsed = int.tryParse(hoursInput.trim());
                      if (parsed == null || parsed < 1 || parsed > maxHours) {
                        ToastUtils.showToast(
                          dialogContext,
                          context.l10n.enterNumberBetween(maxHours.toString()),
                        );
                        return;
                      }
                      Navigator.of(dialogContext).pop(parsed);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cinemaAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.l10n.set,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted || hoursBefore == null) {
        return;
      }

      final DateTime notifyAt = nextAirDate.subtract(
        Duration(hours: hoursBefore),
      );
      if (!notifyAt.isAfter(DateTime.now())) {
        if (mounted) {
          ToastUtils.showToast(
            context,
            context.l10n.selectedReminderTimePassed,
          );
        }
        return;
      }

      final TvEpisode episode = widget.nextEpisode!;
      await ref
          .read(remindersProvider.notifier)
          .addReminder(
            AppReminder(
              id: buildEpisodeReminderId(
                mediaId: widget.showId,
                seasonNumber: episode.seasonNumber,
                episodeNumber: episode.episodeNumber,
                airDate: nextAirDate,
              ),
              type: ReminderType.episodeAiring,
              title: widget.showTitle,
              message:
                  '${context.l10n.episodeCode(episode.seasonNumber.toString(), episode.episodeNumber.toString())}"${episode.name}" airs in $hoursBefore hour${hoursBefore == 1 ? '' : 's'}.',
              notifyAt: notifyAt,
              createdAt: DateTime.now(),
              mediaId: widget.showId,
              isTv: true,
              backdropPath: widget.backdropPath,
              seasonNumber: episode.seasonNumber,
              episodeNumber: episode.episodeNumber,
              airDate: nextAirDate,
            ),
          );

      if (mounted) {
        final String when = DateFormat(
          'EEE, d MMM • hh:mm a',
        ).format(notifyAt.toLocal());
        ToastUtils.showToast(
          context,
          context.l10n.episodeReminderSaved(when),
        );
      }
    } finally {
      _isSettingEpisodeReminder = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isActive =
        widget.status != null &&
        widget.status != 'Ended' &&
        widget.status != 'Canceled';

    final Color statusColor = isActive
        ? const Color(0xFF00E676)
        : Colors.white38;
    final String statusLabel = widget.status ?? context.l10n.unknown;
    final bool canSetEpisodeReminder =
        widget.nextEpisode != null &&
        _timeRemaining != null &&
        _timeRemaining! > Duration.zero;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.detailsCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.episodeTracker,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    if (canSetEpisodeReminder)
                      IconButton(
                        tooltip: context.l10n.tooltipSetAiringReminder,
                        onPressed: _setEpisodeAiringReminder,
                        icon: const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (isActive)
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isActive ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_timeRemaining != null && _timeRemaining! > Duration.zero) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cinemaAccent.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.cinemaAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.nextEpisodeCountdown,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CountdownUnit(
                          value: _timeRemaining!.inDays,
                          label: context.l10n.durationDays,
                        ),
                        _CountdownUnit(
                          value: _timeRemaining!.inHours % 24,
                          label: context.l10n.durationHours,
                        ),
                        _CountdownUnit(
                          value: _timeRemaining!.inMinutes % 60,
                          label: context.l10n.durationMinutes,
                        ),
                        _CountdownUnit(
                          value: _timeRemaining!.inSeconds % 60,
                          label: context.l10n.durationSeconds,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (widget.nextEpisode != null) ...[
              const SizedBox(height: 16),
              _EpisodeSubCard(
                title: context.l10n.nextEpisode,
                episode: widget.nextEpisode!,
                accentColor: AppColors.cinemaAccent,
              ),
            ],
            if (widget.lastEpisode != null) ...[
              const SizedBox(height: 16),
              _EpisodeSubCard(
                title: context.l10n.lastEpisodeToAir,
                episode: widget.lastEpisode!,
                accentColor: Colors.white54,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  const _CountdownUnit({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 1),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.cinemaAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeSubCard extends StatelessWidget {
  const _EpisodeSubCard({
    required this.title,
    required this.episode,
    required this.accentColor,
  });

  final String title;
  final TvEpisode episode;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String epCode = context.l10n.episodeCode(
      episode.seasonNumber.toString().padLeft(2, '0'),
      episode.episodeNumber.toString().padLeft(2, '0'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (episode.stillPath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 60,
                    child: CachedNetworkImage(
                      imageUrl: episode.stillPath!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.white10,
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white30,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white10,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 20,
                          color: Colors.white30,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$epCode• ${episode.name}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (episode.airDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        episode.airDate!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (episode.overview != null &&
                        episode.overview!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        episode.overview!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentAdvisoryCard extends StatelessWidget {
  const _ContentAdvisoryCard({
    required this.contentRating,
    this.contentRatingDescription,
    this.overview,
  });

  final String? contentRating;
  final String? contentRatingDescription;
  final String? overview;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String rating = contentRating?.trim() ?? 'NR';

    Color ratingBorderColor;
    Color ratingBgColor;
    if (const ['G', 'PG', 'TV-G', 'TV-Y', 'TV-Y7', 'TV-PG'].contains(rating)) {
      ratingBorderColor = const Color(0xFF00E676); // Green
      ratingBgColor = const Color(0xFF00E676).withValues(alpha: 0.1);
    } else if (const ['PG-13', 'TV-14', 'PG12'].contains(rating)) {
      ratingBorderColor = const Color(0xFFFFD740); // Yellow/Amber
      ratingBgColor = const Color(0xFFFFD740).withValues(alpha: 0.1);
    } else if (const [
      'R',
      'NC-17',
      'TV-MA',
      '18',
      'R15+',
      'R18+',
    ].contains(rating)) {
      ratingBorderColor = const Color(0xFFFF1744); // Red
      ratingBgColor = const Color(0xFFFF1744).withValues(alpha: 0.1);
    } else {
      ratingBorderColor = Colors.white38;
      ratingBgColor = Colors.white10;
    }

    final Set<String> tags = {};
    final String searchTarget =
        '${contentRatingDescription ?? ''} ${overview ?? ''}'.toLowerCase();

    if (searchTarget.contains('violence') ||
        searchTarget.contains('kill') ||
        searchTarget.contains('murder') ||
        searchTarget.contains('blood') ||
        searchTarget.contains('fight') ||
        searchTarget.contains('combat') ||
        searchTarget.contains('assassin') ||
        searchTarget.contains('death')) {
      tags.add(context.l10n.violence);
    }

    if (searchTarget.contains('sex') ||
        searchTarget.contains('nudity') ||
        searchTarget.contains('nude') ||
        searchTarget.contains('erotic') ||
        searchTarget.contains('sensual') ||
        searchTarget.contains('sexual')) {
      tags.add(context.l10n.sexAndNudity);
    }

    if (searchTarget.contains('language') ||
        searchTarget.contains('profanity') ||
        searchTarget.contains('swear') ||
        searchTarget.contains('vulgar') ||
        searchTarget.contains('crude')) {
      tags.add(context.l10n.foulLanguage);
    }

    if (searchTarget.contains('drugs') ||
        searchTarget.contains('alcohol') ||
        searchTarget.contains('smoke') ||
        searchTarget.contains('drinking') ||
        searchTarget.contains('cocaine') ||
        searchTarget.contains('substance') ||
        searchTarget.contains('heroin')) {
      tags.add(context.l10n.substances);
    }

    if (searchTarget.contains('horror') ||
        searchTarget.contains('scary') ||
        searchTarget.contains('ghost') ||
        searchTarget.contains('monster') ||
        searchTarget.contains('terrifying') ||
        searchTarget.contains('fear') ||
        searchTarget.contains('creepy') ||
        searchTarget.contains('frightening')) {
      tags.add(context.l10n.fearAndHorror);
    }

    if (tags.isEmpty) {
      if (rating == 'G' || rating == 'TV-G') {
        tags.add(context.l10n.familyFriendly);
      } else {
        tags.add(context.l10n.generalAudience);
      }
    }

    Color getTagColor(String tag) {
      switch (tag) {
        case final tag when tag == context.l10n.violence:
          return const Color(0xFFFF5252);
        case final tag when tag == context.l10n.sexAndNudity:
          return const Color(0xFFFF4081);
        case final tag when tag == context.l10n.foulLanguage:
          return const Color(0xFFFFAB40);
        case final tag when tag == context.l10n.substances:
          return const Color(0xFF64FFDA);
        case final tag when tag == context.l10n.fearAndHorror:
          return const Color(0xFF7C4DFF);
        default:
          return Colors.white70;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.detailsCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: 70,
              height: 48,
              decoration: BoxDecoration(
                color: ratingBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ratingBorderColor, width: 2),
              ),
              child: Text(
                rating,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.contentAdvisory,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (contentRatingDescription != null &&
                      contentRatingDescription!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      contentRatingDescription!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: tags.map((tag) {
                      final tagColor = getTagColor(tag);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: tagColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tagColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseAlertTimeline extends ConsumerStatefulWidget {
  const _ReleaseAlertTimeline({
    required this.movieId,
    required this.isTv,
    required this.title,
    this.theatricalDate,
    this.digitalDate,
    this.physicalDate,
  });

  final int movieId;
  final bool isTv;
  final String title;
  final String? theatricalDate;
  final String? digitalDate;
  final String? physicalDate;

  @override
  ConsumerState<_ReleaseAlertTimeline> createState() =>
      _ReleaseAlertTimelineState();
}

class _ReleaseAlertTimelineState extends ConsumerState<_ReleaseAlertTimeline> {
  Future<void> _toggleSubscription(bool value) async {
    try {
      final key = _releaseReminderId;
      final l10n = context.l10n;

      if (value) {
        final DateTime notifyAt = _resolveReleaseNotifyAt();
        final DateFormat formatter = DateFormat('MMM d, yyyy');
        await ref.read(remindersProvider.notifier).dismissReminder(key);
        await ref
            .read(remindersProvider.notifier)
            .addReminder(
              AppReminder(
                id: key,
                type: ReminderType.general,
                title: l10n.releaseAlertTitle(widget.title),
                message:
                    l10n.releaseAlertFullMessage(formatter.format(notifyAt)),
                notifyAt: notifyAt,
                createdAt: DateTime.now(),
                mediaId: widget.movieId,
                isTv: widget.isTv,
              ),
            );
      } else {
        await ref
            .read(remindersProvider.notifier)
            .dismissRemindersForMedia(
              mediaId: widget.movieId,
              isTv: widget.isTv,
            );
      }

      if (value && mounted) {
        _showSuccessDialog();
      }
    } catch (_) {}
  }

  String get _releaseReminderId =>
      buildReleaseReminderId(mediaId: widget.movieId, isTv: widget.isTv);

  DateTime _resolveReleaseNotifyAt() {
    final DateTime now = DateTime.now();
    final List<DateTime> candidates =
        <String?>[
              widget.theatricalDate,
              widget.digitalDate,
              widget.physicalDate,
            ]
            .map((value) => value == null ? null : DateTime.tryParse(value))
            .whereType<DateTime>()
            .map((date) => DateTime(date.year, date.month, date.day, 9))
            .where((date) => date.isAfter(now))
            .toList(growable: false)
          ..sort((a, b) => a.compareTo(b));

    if (candidates.isNotEmpty) {
      return candidates.first;
    }
    return now.add(const Duration(minutes: 1));
  }

  void _showSuccessDialog() {
    _dismissKeyboard();
    showAnimatedDialog(
      context: context,
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: AppColors.detailsCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF00E676),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.alertSet,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'We\'ll notify you as soon as "${widget.title}" is released digitally or on Blu-ray/DVD!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cinemaAccent,
              ),
              child: Text(
                context.l10n.awesome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    bool hasFutureRelease = false;
    final DateTime now = DateTime.now();

    DateTime? tDate = widget.theatricalDate != null
        ? DateTime.tryParse(widget.theatricalDate!)
        : null;
    DateTime? dDate = widget.digitalDate != null
        ? DateTime.tryParse(widget.digitalDate!)
        : null;
    DateTime? pDate = widget.physicalDate != null
        ? DateTime.tryParse(widget.physicalDate!)
        : null;

    if ((tDate != null && tDate.isAfter(now)) ||
        (dDate != null && dDate.isAfter(now)) ||
        (pDate != null && pDate.isAfter(now))) {
      hasFutureRelease = true;
    }

    String formatDate(String? dateStr) {
      if (dateStr == null) return 'TBA';
      final parsed = DateTime.tryParse(dateStr);
      if (parsed == null) return dateStr;
      return DateFormat('MMM d, yyyy').format(parsed);
    }

    bool isPast(DateTime? date) {
      if (date == null) return false;
      return date.isBefore(now);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.detailsCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.releaseTimeline,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasFutureRelease)
                  Row(
                    children: [
                      Text(
                        context.l10n.notifyMe,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: ref
                            .watch(
                              mediaRemindersProvider((
                                mediaId: widget.movieId,
                                isTv: widget.isTv,
                              )),
                            )
                            .isNotEmpty,
                        onChanged: _toggleSubscription,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeThumbColor: AppColors.cinemaAccent,
                        activeTrackColor: AppColors.cinemaAccent.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _TimelineItem(
              icon: Icons.movie_creation_outlined,
              title: context.l10n.theatricalRelease,
              date: formatDate(widget.theatricalDate),
              isCompleted: isPast(tDate),
              isLast: false,
            ),
            _TimelineItem(
              icon: Icons.play_circle_outline_rounded,
              title: context.l10n.digitalStreaming,
              date: formatDate(widget.digitalDate),
              isCompleted: isPast(dDate),
              isLast: false,
            ),
            _TimelineItem(
              icon: Icons.album_outlined,
              title: context.l10n.physicalRelease,
              date: formatDate(widget.physicalDate),
              isCompleted: isPast(pDate),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.date,
    required this.isCompleted,
    required this.isLast,
  });

  final IconData icon;
  final String title;
  final String date;
  final bool isCompleted;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = isCompleted ? const Color(0xFF00E676) : Colors.white38;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? color.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isCompleted ? color : Colors.white54,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isCompleted ? Colors.white : Colors.white70,
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? const Color(0xFF00E676)
                          : Colors.white38,
                    ),
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

class _MovieCollectionSection extends ConsumerWidget {
  const _MovieCollectionSection({required this.belongsToCollection});

  final MovieCollectionInfo belongsToCollection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(
      movieCollectionProvider(belongsToCollection.id),
    );
    final watchedItemsAsync = ref.watch(watchedItemsProvider);
    final theme = Theme.of(context);

    return collectionAsync.when(
      data: (parts) {
        if (parts.isEmpty) return const SizedBox.shrink();
        final watchedItems = watchedItemsAsync.value ?? const [];
        final watchedCount = parts
            .where(
              (part) => watchedItems.any(
                (w) => w.id == part.id && w.mediaType == GlobalMediaType.movie,
              ),
            )
            .length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.detailsCard.withValues(alpha: 0.6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.detailsCardShadow,
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.partOfCollection(belongsToCollection.name),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$watchedCount / ${parts.length} ${context.l10n.watched}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.cinemaAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: parts.isEmpty ? 0 : watchedCount / parts.length,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.cinemaAccent,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 175,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: parts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final part = parts[index];
                      final isWatched = watchedItems.any(
                        (w) =>
                            w.id == part.id &&
                            w.mediaType == GlobalMediaType.movie,
                      );

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _dismissKeyboard();
                          context.pushNamed(
                            AppRoute.movieDetails.name,
                            pathParameters: {'movieId': part.id.toString()},
                            queryParameters: {'isTv': 'false'},
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 135,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: part.posterPath != null
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              part.posterPath!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.white10,
                                  ),
                                  child: part.posterPath == null
                                      ? const Center(
                                          child: Icon(
                                            Icons.movie_outlined,
                                            color: Colors.white24,
                                          ),
                                        )
                                      : null,
                                ),
                                if (isWatched)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 90,
                              child: Text(
                                part.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ShimmerEffect(
          width: double.infinity,
          height: 180,
          borderRadius: 16,
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _KeywordsThemesSection extends StatelessWidget {
  const _KeywordsThemesSection({required this.keywords});

  final List<MovieKeyword> keywords;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.keywordsAndThemes,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.map((keyword) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _dismissKeyboard();
                  context.pushNamed(
                    AppRoute.keywordDetails.name,
                    pathParameters: {'keywordId': keyword.id.toString()},
                    queryParameters: {'keywordName': keyword.name},
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    keyword.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.87),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TrailersClipsSection extends StatefulWidget {
  const _TrailersClipsSection({
    required this.videos,
    required this.movieTitle,
    required this.details,
    required this.isTv,
  });

  final List<MovieVideo> videos;
  final String movieTitle;
  final MovieDetails details;
  final bool isTv;

  @override
  State<_TrailersClipsSection> createState() => _TrailersClipsSectionState();
}

class _TrailersClipsSectionState extends State<_TrailersClipsSection> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final cleanVideos = widget.videos
        .where((v) => v.site.toLowerCase() == 'youtube' && v.key.isNotEmpty)
        .toList();
    if (cleanVideos.isEmpty) return const SizedBox.shrink();

    final types = ['All', ...cleanVideos.map((e) => e.type).toSet()];
    final filteredVideos = _activeFilter == 'All'
        ? cleanVideos
        : cleanVideos.where((v) => v.type == _activeFilter).toList();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.videosAndBehindTheScenes,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (types.length > 2) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: types.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final type = types[index];
                  final isSelected = type == _activeFilter;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _activeFilter = type;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.cinemaAccent.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.cinemaAccent.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          type == 'All' ? context.l10n.all : type,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredVideos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final video = filteredVideos[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => TrailerPlayerScreen(
                          data: TrailerPlaybackData(
                            videoKey: video.key,
                            title: video.name,
                            tagline: widget.details.tagline,
                            overview: widget.details.overview,
                            posterPath: widget.details.posterPath,
                            backdropPath: widget.details.backdropPath,
                            releaseDate: widget.details.releaseDate,
                            runtimeMinutes: widget.details.runtimeMinutes,
                            voteAverage: widget.details.catalogScore,
                            voteCount: widget.details.voteCount,
                            categoryLabel: widget.isTv ? context.l10n.tvShow : context.l10n.movie,
                            sourceMediaId: widget.details.id,
                            isTv: widget.isTv,
                            recommendations: widget.details.recommendations,
                          ),
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                      'https://img.youtube.com/vi/${video.key}/hqdefault.jpg',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    video.type,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          video.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionCompaniesSection extends StatelessWidget {
  const _ProductionCompaniesSection({required this.companies});

  final List<ProductionCompany> companies;

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.productionStudios,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: companies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final company = companies[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _dismissKeyboard();
                    context.pushNamed(
                      AppRoute.companyDetails.name,
                      pathParameters: {'companyId': company.id.toString()},
                    );
                  },
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.detailsCard.withValues(alpha: 0.4),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: company.logoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: company.logoPath!,
                              fit: BoxFit.contain,
                              placeholder: (context, url) =>
                                  const SizedBox.shrink(),
                              errorWidget: (context, url, error) =>
                                  _StudioTextCard(name: company.name),
                            ),
                          )
                        : _StudioTextCard(name: company.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioTextCard extends StatelessWidget {
  const _StudioTextCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
