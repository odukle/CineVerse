import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MediaPosterGridCard extends ConsumerWidget {
  const MediaPosterGridCard({
    super.key,
    required this.movie,
    required this.sectionTitle,
    required this.width,
    this.isTvTitle = false,
  });

  final MediaTitle movie;
  final String sectionTitle;
  final double width;
  final bool isTvTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final double posterHeight = width * 1.42;
    final double badgeSize = width * 0.34;
    final double badgeOffset = badgeSize * 0.24;
    final double titleGap = badgeOffset + 5;
    final AsyncValue<MovieDetails> movieDetails = ref.watch(
      movieDetailsProvider(
        GetMovieDetailsParams(movieId: movie.id, isTv: isTvTitle),
      ),
    );
    final List<MovieRating> ratings =
        movieDetails.value?.externalRatings.take(2).toList(growable: false) ??
        const <MovieRating>[];
    final MovieRating? rottenTomatoesRating = _ratingForSource(
      ratings,
      'Rotten Tomatoes',
    );
    final MovieRating? imdbRating = _ratingForSource(ratings, 'IMDb');
    final bool isRatingLoading = movieDetails.isLoading && movieDetails.value == null;
    final String scoreLabel = rottenTomatoesRating == null
        ? 'NA'
        : _normalizeScore(rottenTomatoesRating.value) ?? 'NA';
    final Widget scoreBadge = isRatingLoading
        ? RatingBadge.loading(size: badgeSize)
        : rottenTomatoesRating == null
        ? RatingBadge.tmdb(
            catalogScore: movieDetails.value?.catalogScore,
            size: badgeSize,
          )
        : RatingBadge.rottenTomatoes(label: scoreLabel, size: badgeSize);

    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final String heroTag = 'movie-poster-${movie.id}-$sectionTitle';
          context.pushNamed(
            AppRoute.movieDetails.name,
            pathParameters: <String, String>{'movieId': movie.id.toString()},
            queryParameters: <String, String>{
              'isTv': '$isTvTitle',
              'heroTag': heroTag,
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: 'movie-poster-${movie.id}-$sectionTitle',
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
