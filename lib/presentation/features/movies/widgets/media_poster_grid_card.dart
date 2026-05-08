import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/media_title.dart';
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

    final Widget scoreBadge = RatingBadge.tmdb(
      catalogScore: movie.voteAverage,
      size: badgeSize,
    );

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
          ],
        ),
      ),
    );
  }
}
