import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AllSeasonsScreen extends StatelessWidget {
  const AllSeasonsScreen({
    super.key,
    required this.showTitle,
    required this.seasons,
    required this.tvId,
  });

  final String showTitle;
  final List<TvSeason> seasons;
  final int tvId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showTitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const Text(
              'All Seasons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: seasons.length,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white10,
          height: 32,
        ),
        itemBuilder: (context, index) {
          final season = seasons[index];
          return _SeasonListItem(
            tvId: tvId,
            showTitle: showTitle,
            season: season,
          );
        },
      ),
    );
  }
}

class _SeasonListItem extends StatelessWidget {
  const _SeasonListItem({
    required this.tvId,
    required this.showTitle,
    required this.season,
  });

  final int tvId;
  final String showTitle;
  final TvSeason season;

  @override
  Widget build(BuildContext context) {
    final year = season.airDate?.split('-').first ?? '';
    final formattedDate = season.airDate != null
        ? DateFormat('MMMM d, yyyy').format(DateTime.parse(season.airDate!))
        : null;

    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoute.seasonDetails.name,
          pathParameters: {
            'tvId': tvId.toString(),
            'seasonNumber': season.seasonNumber.toString(),
          },
          queryParameters: {
            'showTitle': showTitle,
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100,
                height: 150,
                child: season.posterPath != null
                    ? CachedNetworkImage(
                        imageUrl: season.posterPath!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerEffect(
                          width: 100,
                          height: 150,
                          borderRadius: 8,
                        ),
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
                    season.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (season.voteAverage != null && season.voteAverage! > 0)
                        _RatingChip(voteAverage: season.voteAverage!),
                      if (season.voteAverage != null && season.voteAverage! > 0)
                        const SizedBox(width: 8),
                      Text(
                        '$year • ${season.episodeCount} Episodes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (formattedDate != null)
                    Text(
                      '${season.name} of $showTitle premiered on $formattedDate.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  if (season.overview != null && season.overview!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      season.overview!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        color: const Color(0xFF032541), // Deep blue theme
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 10, color: AppColors.cinemaAccent),
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
