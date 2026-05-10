import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvShowsScreen extends ConsumerWidget {
  const TvShowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final MediaFilterOption selectedFilter = ref.watch(
      selectedTvFilterProvider,
    );
    final bool isFiltering = ref.watch(isFilteringProvider);
    final AsyncValue<List<MediaTitle>> tvShows = ref.watch(
      movieSectionProvider(selectedFilter.section),
    );

    ref.listen(movieSectionProvider(selectedFilter.section), (previous, next) {
      if (!next.isLoading) {
        ref.read(isFilteringProvider.notifier).setState(false);
      }
    });

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.cinemaGradient,
        ),
      ),
      child: isFiltering
          ? _ShimmerGrid()
          : tvShows.when(
              skipLoadingOnReload: !tvShows.hasError,
              loading: () => _ShimmerGrid(),
              error: (Object error, StackTrace stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load TV shows. $error',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(moviesProvider),
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
              data: (List<MediaTitle> data) {
                if (data.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tv_off_rounded,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No TV shows available right now.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

                final bool isExhausted = ref.watch(
                  movieSectionExhaustedProvider(selectedFilter.section),
                );

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      loadNextPages(ref, selectedFilter.section);
                    }
                    return false;
                  },
                  child: GridView.builder(
                    cacheExtent: 1000,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: crossAxisSpacing,
                          mainAxisSpacing: mainAxisSpacing,
                          mainAxisExtent: 220,
                        ),
                    itemCount: data.length + 1,
                    itemBuilder: (context, index) {
                      if (index == data.length) {
                        if (isExhausted) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'No more TV shows to load.',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(
                              color: AppColors.cinemaAccent,
                            ),
                          ),
                        );
                      }

                      final MediaTitle movie = data[index];
                      return Center(
                        child: MediaPosterGridCard(
                          movie: movie,
                          sectionTitle: selectedFilter.label,
                          width: cardWidth,
                          isTvTitle: true,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 0,
        mainAxisExtent: 220,
      ),
      itemCount: 12,
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
    );
  }
}
