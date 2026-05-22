import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/rating_badge.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/widgets/media_actions_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MediaPosterGridCard extends ConsumerStatefulWidget {
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
  ConsumerState<MediaPosterGridCard> createState() => _MediaPosterGridCardState();
}

class _MediaPosterGridCardState extends ConsumerState<MediaPosterGridCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double posterHeight = widget.width * 1.42;
    final double badgeSize = widget.width * 0.20;
    final double badgeOffset = badgeSize * 0.0;
    final double titleGap = badgeOffset + 5;

    final bool isPerson = widget.movie.mediaType == GlobalMediaType.person;
    final String heroTag = 'media-poster-${widget.movie.id}-${widget.sectionTitle}';

    final mediaType =
        widget.movie.mediaType ??
        (widget.isTvTitle ? GlobalMediaType.tv : GlobalMediaType.movie);
    final bool isWatched = isPerson
        ? false
        : ref.watch(isWatchedProvider((id: widget.movie.id, type: mediaType))).value ??
              false;
    final bool isInWatchlist = isPerson
        ? false
        : ref.watch(isInWatchlistProvider(widget.movie.id)).value ?? false;

    final Widget scoreBadge = isPerson
        ? const SizedBox.shrink()
        : RatingBadge.tmdb(catalogScore: widget.movie.voteAverage, size: badgeSize);

    // Check if we are currently sorting by a specific field to show it below the title
    final currentSort = ref.watch(genreSortProvider);
    final SortField activeField = currentSort.sortField;
    final bool isDefaultSort = currentSort.isDefault;

    // Determine what to display as the primary subtitle
    String? subtitleText;

    if (!isDefaultSort) {
      switch (activeField) {
        case SortField.revenue:
          int? effectiveRevenue = widget.movie.revenue;
          if (effectiveRevenue == null && !widget.isTvTitle && !isPerson) {
            effectiveRevenue = ref.watch(mediaRevenueProvider(widget.movie.id)).value;
          }
          if (effectiveRevenue != null && effectiveRevenue > 0) {
            subtitleText = _formatRevenue(effectiveRevenue);
          }
          break;
        case SortField.popularity:
          subtitleText = '${widget.movie.popularity.toStringAsFixed(1)} Popularity';
          break;
        case SortField.voteAverage:
          if (widget.movie.voteAverage != null && widget.movie.voteAverage! > 0) {
            subtitleText = '${widget.movie.voteAverage!.toStringAsFixed(1)} Rating';
          }
          break;
        case SortField.voteCount:
          subtitleText = '${_formatCount(widget.movie.voteCount)} Votes';
          break;
        case SortField.releaseDate:
          subtitleText = widget.movie.releaseDate;
          break;
      }
    }

    // Fallback if the specific attribute is not available or we are not in a specific sort
    subtitleText ??=
        widget.movie.subtitle ??
        widget.movie.releaseDate ??
        (widget.sectionTitle == 'search' ? '' : widget.sectionTitle);

    return SizedBox(
      width: widget.width,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          if (isPerson) {
            context.pushNamed(
              AppRoute.personDetails.name,
              pathParameters: <String, String>{'personId': widget.movie.id.toString()},
              queryParameters: <String, String>{'heroTag': heroTag},
            );
          } else {
            final bool effectiveIsTv =
                widget.movie.mediaType == GlobalMediaType.tv ||
                (widget.movie.mediaType == null && widget.isTvTitle);
            context.pushNamed(
              AppRoute.movieDetails.name,
              pathParameters: <String, String>{'movieId': widget.movie.id.toString()},
              queryParameters: <String, String>{
                'isTv': effectiveIsTv.toString(),
                'heroTag': heroTag,
              },
            );
          }
        },
        onLongPress: isPerson
            ? null
            : () => _showMediaActionsMenu(context),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
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
                          width: widget.width,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (widget.movie.posterPath == null)
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
                                  imageUrl: widget.movie.posterPath!,
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
                      left: 6,
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
                  if (!isPerson)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final watchlistItem = WatchlistItem(
                              id: widget.movie.id,
                              title: widget.movie.title,
                              posterPath: widget.movie.posterPath,
                              releaseDate: widget.movie.releaseDate,
                              mediaType: mediaType,
                              addedDate: DateTime.now(),
                              voteAverage: widget.movie.voteAverage,
                            );
                            ref.read(watchlistProvider.notifier).toggleItem(watchlistItem);
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Ink(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isInWatchlist
                                  ? AppColors.cinemaAccent.withValues(alpha: 0.8)
                                  : Colors.black.withValues(alpha: 0.46),
                              border: Border.all(
                                color: isInWatchlist
                                    ? AppColors.cinemaAccent
                                    : Colors.white.withValues(alpha: 0.24),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              isInWatchlist
                                  ? Icons.bookmark_added_rounded
                                  : Icons.bookmark_add_outlined,
                              color: isInWatchlist ? Colors.black : Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: titleGap),
              Text(
                widget.movie.title,
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

  void _showMediaActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          MediaActionsBottomSheet(movie: widget.movie, isTv: widget.isTvTitle),
    );
  }
}
