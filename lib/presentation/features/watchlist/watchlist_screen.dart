import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.cinemaBackground),
      child: watchlistAsync.when(
        skipLoadingOnReload: !watchlistAsync.hasError,
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your watchlist is empty',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          const double crossAxisSpacing = 10;
          const double mainAxisSpacing = 0;
          const int crossAxisCount = 3;
          final double availableCardWidth =
              (MediaQuery.sizeOf(context).width -
                  (16 * 2) -
                  (crossAxisSpacing * 2)) /
              crossAxisCount;
          final double cardWidth = availableCardWidth > 108
              ? 108
              : availableCardWidth;

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Watchlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                    mainAxisExtent: 220,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = items[index];
                    // Map WatchlistItem to MediaTitle
                    final media = MediaTitle(
                      id: item.id,
                      title: item.title,
                      posterPath: item.posterPath,
                      releaseDate: item.releaseDate,
                      mediaType: item.mediaType,
                      voteAverage: item.voteAverage,
                    );
                    return MediaPosterGridCard(
                      movie: media,
                      sectionTitle: 'watchlist',
                      width: cardWidth,
                      isTvTitle: item.mediaType == GlobalMediaType.tv,
                    );
                  }, childCount: items.length),
                ),
              ),
            ],
          );
        },
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 0,
            mainAxisExtent: 220,
          ),
          itemCount: 9,
          itemBuilder: (context, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerEffect.poster(width: double.infinity, height: 153),
              const SizedBox(height: 12),
              ShimmerEffect.textLine(width: 80, height: 12),
              const SizedBox(height: 6),
              ShimmerEffect.textLine(width: 40, height: 10),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error loading watchlist: $error',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(watchlistProvider),
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
    );
  }
}
