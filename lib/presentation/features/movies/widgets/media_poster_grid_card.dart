import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/widgets/media_actions_dialogs.dart';
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

    final mediaType =
        movie.mediaType ??
        (isTvTitle ? GlobalMediaType.tv : GlobalMediaType.movie);
    final bool isWatched = isPerson
        ? false
        : ref.watch(isWatchedProvider((id: movie.id, type: mediaType))).value ??
              false;

    final Widget scoreBadge = isPerson
        ? const SizedBox.shrink()
        : RatingBadge.tmdb(catalogScore: movie.voteAverage, size: badgeSize);

    // Check if we are currently sorting by a specific field to show it below the title
    final currentSort = ref.watch(genreSortProvider);
    final SortField activeField = currentSort.sortField;
    final bool isDefaultSort = currentSort.isDefault;

    // Determine what to display as the primary subtitle
    String? subtitleText;

    if (!isDefaultSort) {
      switch (activeField) {
        case SortField.revenue:
          int? effectiveRevenue = movie.revenue;
          if (effectiveRevenue == null && !isTvTitle && !isPerson) {
            effectiveRevenue = ref.watch(mediaRevenueProvider(movie.id)).value;
          }
          if (effectiveRevenue != null && effectiveRevenue > 0) {
            subtitleText = _formatRevenue(effectiveRevenue);
          }
          break;
        case SortField.popularity:
          subtitleText = '${movie.popularity.toStringAsFixed(1)} Popularity';
          break;
        case SortField.voteAverage:
          if (movie.voteAverage != null && movie.voteAverage! > 0) {
            subtitleText = '${movie.voteAverage!.toStringAsFixed(1)} Rating';
          }
          break;
        case SortField.voteCount:
          subtitleText = '${_formatCount(movie.voteCount)} Votes';
          break;
        case SortField.releaseDate:
          subtitleText = movie.releaseDate;
          break;
      }
    }

    // Fallback if the specific attribute is not available or we are not in a specific sort
    subtitleText ??=
        movie.subtitle ??
        movie.releaseDate ??
        (sectionTitle == 'search' ? '' : sectionTitle);

    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isPerson) {
            context.pushNamed(
              AppRoute.personDetails.name,
              pathParameters: <String, String>{'personId': movie.id.toString()},
              queryParameters: <String, String>{'heroTag': heroTag},
            );
          } else {
            final bool effectiveIsTv =
                movie.mediaType == GlobalMediaType.tv ||
                (movie.mediaType == null && isTvTitle);
            context.pushNamed(
              AppRoute.movieDetails.name,
              pathParameters: <String, String>{'movieId': movie.id.toString()},
              queryParameters: <String, String>{
                'isTv': effectiveIsTv.toString(),
                'heroTag': heroTag,
              },
            );
          }
        },
        onLongPress: isPerson
            ? null
            : () => _showMediaActionsMenu(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: heroTag,
                  child: Container(
                    padding: const EdgeInsets.all(1.2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          AppColors.cinemaGlow.withValues(alpha: 0.5),
                          Colors.white.withValues(alpha: 0.12),
                          AppColors.cinemaWarmGlow.withValues(alpha: 0.46),
                        ],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.cinemaGlow.withValues(alpha: 0.16),
                          blurRadius: 20,
                          spreadRadius: -10,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        height: posterHeight,
                        width: width,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (movie.posterPath == null)
                              ColoredBox(
                                color: AppColors.cinemaPlaceholder,
                                child: Center(
                                  child: Icon(
                                    isPerson
                                        ? Icons.person_outline_rounded
                                        : Icons.movie_outlined,
                                  ),
                                ),
                              )
                            else
                              CachedNetworkImage(
                                imageUrl: movie.posterPath!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => ColoredBox(
                                  color: AppColors.cinemaPlaceholder,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    ColoredBox(
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
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                      decoration: BoxDecoration(
                        color: AppColors.cinemaAccent,
                        shape: BoxShape.circle,
                        boxShadow: const [
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
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.68),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRevenue(int amount) {
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$$amount';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '$count';
    }
  }

  void _showMediaActionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          MediaActionsBottomSheet(movie: movie, isTv: isTvTitle),
    );
  }
}
