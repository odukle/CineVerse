import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
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
    final double badgeSize = width * 0.20;
    final double badgeOffset = badgeSize * 0.0;
    final double titleGap = badgeOffset + 5;

    final bool isPerson = movie.mediaType == GlobalMediaType.person;
    final String heroTag = 'media-poster-${movie.id}-$sectionTitle';

    final bool isWatched =
        ref.watch(isWatchedProvider(movie.id)).value ?? false;

    final Widget scoreBadge = isPerson
        ? const SizedBox.shrink()
        : RatingBadge.tmdb(catalogScore: movie.voteAverage, size: badgeSize);

    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isPerson) {
            context.pushNamed(
              AppRoute.personDetails.name,
              pathParameters: <String, String>{'personId': movie.id.toString()},
              queryParameters: <String, String>{'heroTag': heroTag},
            );
          } else {
            context.pushNamed(
              AppRoute.movieDetails.name,
              pathParameters: <String, String>{'movieId': movie.id.toString()},
              queryParameters: <String, String>{
                'isTv': '$isTvTitle',
                'heroTag': heroTag,
              },
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: posterHeight,
                      width: width,
                      child: movie.posterPath == null
                          ? ColoredBox(
                              color: AppColors.cinemaPlaceholder,
                              child: Center(
                                child: Icon(
                                  isPerson
                                      ? Icons.person_outline_rounded
                                      : Icons.movie_outlined,
                                ),
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
                              errorWidget: (context, url, error) => ColoredBox(
                                color: AppColors.cinemaPlaceholder,
                                child: Center(
                                  child: Icon(
                                    isPerson
                                        ? Icons.person_off_rounded
                                        : Icons.broken_image_outlined,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Positioned(left: 0, bottom: -badgeOffset, child: scoreBadge),
                if (isWatched)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.cinemaAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.black,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: titleGap),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              movie.releaseDate ??
                  (sectionTitle == 'watchlist' ? '' : sectionTitle),
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
