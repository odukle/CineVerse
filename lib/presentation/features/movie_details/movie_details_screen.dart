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
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
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

class _MovieDetailsView extends StatelessWidget {
  const _MovieDetailsView({
    required this.details,
    required this.isTv,
    this.heroTag,
  });

  final MovieDetails details;
  final bool isTv;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? backdropUrl = details.backdropPath ?? details.posterPath;
    final String? releaseYear = _extractYear(details.releaseDate);
    final int? scorePercent = _catalogScorePercent(details.catalogScore);
    final List<MovieRating> externalRatings = details.externalRatings;
    final List<MovieCredit> featuredCrew = _getFeaturedCrew(details.crew);
    final MovieWatchAvailability? watchAvailability = details.watchAvailability;
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
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),

          // Backdrop + Poster
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  // Backdrop
                  Positioned.fill(
                    child: backdropUrl == null
                        ? const ColoredBox(
                            color: AppColors.detailsBackdropPlaceholder,
                          )
                        : CachedNetworkImage(
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
                          tag: heroTag ?? 'movie-poster-${details.id}',
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
                                child: details.posterPath == null
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
                                        imageUrl: details.posterPath!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const ColoredBox(
                                              color: AppColors
                                                  .detailsPosterSurface,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
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
                      text: details.title,
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
                        if (details.voteCount != null)
                          Text(
                            '${_formatNumber(details.voteCount!)} votes',
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
                      onPressed: details.trailerYouTubeKey == null
                          ? null
                          : () => _showTrailer(context, details.trailerYouTubeKey!),
                      iconAlignment: IconAlignment.start,
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: details.trailerYouTubeKey == null
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white,
                        size: 24,
                      ),
                      label: Text(
                        'Play Trailer',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: details.trailerYouTubeKey == null
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
                  _buildMetaLine(details),
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
          if (details.tagline != null && details.tagline!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text(
                  details.tagline!,
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
                    details.overview ?? 'Overview unavailable for this title.',
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
                child: _WatchAvailabilitySection(
                  availability: watchAvailability!,
                ),
              ),
            ),

          // Featured Crew
          if (featuredCrew.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: featuredCrew
                      .map((credit) => _CrewInlineChip(credit: credit))
                      .toList(growable: false),
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
          if (details.cast.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Top Billed Cast',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: math.min(details.cast.length, 10),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            _CastCard(credit: details.cast[index]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Text(
                        'Full Cast & Crew',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
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
          if (details.recommendations.isNotEmpty)
            SliverToBoxAdapter(
              child: _RecommendationsCarousel(
                movieId: details.id,
                initialItems: details.recommendations,
                isTv: isTv,
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
                  if (details.status != null)
                    _InfoRow(label: 'Status', value: details.status!),
                  if (details.originalLanguage != null)
                    _InfoRow(
                      label: 'Original Language',
                      value: _formatLanguage(details.originalLanguage!),
                    ),
                  if (details.budget != null && details.budget! > 0)
                    _InfoRow(
                      label: 'Budget',
                      value: _formatCurrency(details.budget!),
                    ),
                  if (details.revenue != null && details.revenue! > 0)
                    _InfoRow(
                      label: 'Revenue',
                      value: _formatCurrency(details.revenue!),
                    ),
                ],
              ),
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
    final Map<String, List<String>> nameToRoles = {};
    for (final credit in crew) {
      if (featuredRoles.contains(credit.role)) {
        nameToRoles.putIfAbsent(credit.name, () => []).add(credit.role);
      }
    }
    return nameToRoles.entries
        .take(4)
        .map((e) => MovieCredit(name: e.key, role: e.value.join(', ')))
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
          value: _normalizeExternalRatingValue(metacritic.value) ??
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
  const _WatchAvailabilitySection({required this.availability});

  final MovieWatchAvailability availability;

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
          _WatchProviderRow(label: 'Stream', providers: availability.streaming),
        if (availability.free.isNotEmpty)
          _WatchProviderRow(label: 'Free', providers: availability.free),
        if (availability.rent.isNotEmpty)
          _WatchProviderRow(label: 'Rent', providers: availability.rent),
        if (availability.buy.isNotEmpty)
          _WatchProviderRow(label: 'Buy', providers: availability.buy),
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
  const _WatchProviderRow({required this.label, required this.providers});

  final String label;
  final List<MovieWatchProvider> providers;

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
                  _WatchProviderCard(provider: providers[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchProviderCard extends StatelessWidget {
  const _WatchProviderCard({required this.provider});

  final MovieWatchProvider provider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
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

class _CastCard extends StatelessWidget {
  const _CastCard({required this.credit});

  final MovieCredit credit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.detailsCard,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: 120,
            child: credit.imageUrl == null
                ? const ColoredBox(
                    color: AppColors.detailsPosterSurface,
                    child: Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white54,
                        size: 36,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: credit.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const ColoredBox(
                      color: AppColors.detailsPosterSurface,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const ColoredBox(
                      color: AppColors.detailsPosterSurface,
                      child: Center(
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credit.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  credit.characterName ?? credit.role,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
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

class _CrewInlineChip extends StatelessWidget {
  const _CrewInlineChip({required this.credit});

  final MovieCredit credit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          credit.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          credit.role,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
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
            height: 200,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length + (_loading ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return const SizedBox(
                    width: 130,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _RecommendationCard(recommendation: _items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final MovieRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: () {
        final String heroTag =
            'movie-poster-${recommendation.id}-recommendation';
        context.pushNamed(
          AppRoute.movieDetails.name,
          pathParameters: <String, String>{
            'movieId': recommendation.id.toString(),
          },
          queryParameters: <String, String>{'heroTag': heroTag},
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'movie-poster-${recommendation.id}-recommendation',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 130,
                  height: 150,
                  child: recommendation.posterPath == null
                      ? const ColoredBox(
                          color: AppColors.detailsPosterSurface,
                          child: Center(
                            child: Icon(
                              Icons.movie_outlined,
                              color: Colors.white54,
                              size: 32,
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: recommendation.posterPath!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const ColoredBox(
                            color: AppColors.detailsPosterSurface,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) =>
                              const ColoredBox(
                                color: AppColors.detailsPosterSurface,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.title,
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
