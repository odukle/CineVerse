import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/presentation/features/movie_details/providers/tv_details_providers.dart';
import 'package:cineverse/presentation/widgets/app_back_button.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SeasonDetailsScreen extends ConsumerWidget {
  const SeasonDetailsScreen({
    super.key,
    required this.tvId,
    required this.seasonNumber,
    required this.showTitle,
  });

  final int tvId;
  final int seasonNumber;
  final String showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonAsync = ref.watch(
      tvSeasonDetailsProvider((tvId: tvId, seasonNumber: seasonNumber)),
    );

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: const AppBackButton(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showTitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              seasonAsync.when(
                data: (season) => Text(
                  season.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                loading: () => const Text(
                  'Loading...',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                error: (_, _) => const Text(
                  'Error',
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
              ),
            ],
          ),
          actions: [
            seasonAsync.when(
              data: (season) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${season.episodes.length} Eps',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        body: seasonAsync.when(
          data: (season) => _SeasonDetailsView(tvId: tvId, season: season),
          loading: () => const _SeasonDetailsShimmer(),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load season details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(
                      tvSeasonDetailsProvider((
                        tvId: tvId,
                        seasonNumber: seasonNumber,
                      )),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cinemaAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeasonDetailsView extends StatelessWidget {
  const _SeasonDetailsView({required this.tvId, required this.season});

  final int tvId;
  final TvSeason season;

  @override
  Widget build(BuildContext context) {
    if (season.episodes.isEmpty) {
      return const Center(
        child: Text(
          'No episodes found for this season.',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: season.episodes.length,
      itemBuilder: (context, index) {
        return _EpisodeListItem(tvId: tvId, episode: season.episodes[index]);
      },
    );
  }
}

class _EpisodeListItem extends StatelessWidget {
  const _EpisodeListItem({required this.tvId, required this.episode});

  final int tvId;
  final TvEpisode episode;

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    if (episode.airDate != null && episode.airDate!.isNotEmpty) {
      try {
        final date = DateTime.parse(episode.airDate!);
        dateStr = DateFormat('MMMM d, yyyy').format(date);
      } catch (_) {
        dateStr = episode.airDate!;
      }
    }

    final String runtimeStr = _formatRuntime(episode.runtimeMinutes);

    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoute.episodeDetails.name,
          pathParameters: {
            'tvId': tvId.toString(),
            'seasonNumber': episode.seasonNumber.toString(),
            'episodeNumber': episode.episodeNumber.toString(),
          },
          queryParameters: {'showTitle': episode.name},
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Still Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 120,
                    height: 68, // 16:9 approx
                    color: Colors.white.withValues(alpha: 0.05),
                    child: episode.stillPath != null
                        ? CachedNetworkImage(
                            imageUrl: episode.stillPath!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const ShimmerEffect(
                              width: 120,
                              height: 68,
                              borderRadius: 8,
                            ),
                            errorWidget: (_, _, _) => const Center(
                              child: Icon(
                                Icons.movie_outlined,
                                color: Colors.white10,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.movie, color: Colors.white24),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Episode Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${episode.episodeNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              episode.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (episode.voteAverage != null &&
                              episode.voteAverage! > 0)
                            _RatingChip(voteAverage: episode.voteAverage!),
                          if (dateStr.isNotEmpty)
                            Text(
                              dateStr,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          if (runtimeStr.isNotEmpty)
                            Text(
                              '• $runtimeStr',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (episode.overview != null && episode.overview!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                episode.overview!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    }
    return '${remainingMinutes}m';
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.voteAverage});
  final double voteAverage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cinemaAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.cinemaAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 10, color: AppColors.cinemaAccent),
          const SizedBox(width: 4),
          Text(
            '${(voteAverage * 10).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonDetailsShimmer extends StatelessWidget {
  const _SeasonDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerEffect(width: 140, height: 80, borderRadius: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerEffect(width: 100, height: 16),
                        const SizedBox(height: 8),
                        const ShimmerEffect(width: 150, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const ShimmerEffect(width: double.infinity, height: 40),
            ],
          ),
        );
      },
    );
  }
}
