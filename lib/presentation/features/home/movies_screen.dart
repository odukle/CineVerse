import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/home/widgets/genre_chips.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoviesScreen extends ConsumerWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isFiltering = ref.watch(isFilteringProvider);
    final customFilter = ref.watch(movieFilterProvider);
    final selectedGenreId = ref.watch(selectedMovieGenreIdProvider);

    // Determine which data provider to use
    final AsyncValue<List<MediaTitle>> movies;
    final String sectionTitle;

    if (!customFilter.isDefault) {
      movies = ref.watch(movieSectionProvider(MovieSection.discover));
      sectionTitle = 'Filtered Results';
    } else if (selectedGenreId != null) {
      movies = ref.watch(genreSectionProvider((id: selectedGenreId, isTv: false)));
      sectionTitle = 'Genre Results';
    } else {
      movies = ref.watch(movieSectionProvider(MovieSection.popular));
      sectionTitle = 'Popular';
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.cinemaGradient,
        ),
      ),
      child: Column(
        children: [
          const GenreChips(isTv: false),
          Expanded(
            child: isFiltering
                ? _ShimmerGrid()
                : movies.when(
                    skipLoadingOnReload: !movies.hasError,
                    loading: () => _ShimmerGrid(),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Could not load movies. $error',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (!customFilter.isDefault) {
                                  ref.invalidate(movieSectionProvider(MovieSection.discover));
                                } else if (selectedGenreId != null) {
                                  ref.invalidate(genreSectionProvider((id: selectedGenreId, isTv: false)));
                                } else {
                                  ref.invalidate(movieSectionProvider(MovieSection.popular));
                                }
                              },
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
                    data: (data) {
                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            'No movies available for this selection.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                        );
                      }

                      const double horizontalPadding = 16;
                      const double crossAxisSpacing = 10;
                      const double mainAxisSpacing = 0;
                      const int crossAxisCount = 3;
                      final double availableCardWidth =
                          (MediaQuery.sizeOf(context).width -
                                  (horizontalPadding * 2) -
                                  (crossAxisSpacing * 2)) /
                              crossAxisCount;
                      final double cardWidth = availableCardWidth > 108
                          ? 108
                          : availableCardWidth;

                      return NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                            if (!customFilter.isDefault) {
                              loadNextPages(ref, MovieSection.discover);
                            } else if (selectedGenreId != null) {
                              loadNextGenrePages(ref, selectedGenreId, isTv: false);
                            } else {
                              loadNextPages(ref, MovieSection.popular);
                            }
                          }
                          return false;
                        },
                        child: GridView.builder(
                          cacheExtent: 1000,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: crossAxisSpacing,
                            mainAxisSpacing: mainAxisSpacing,
                            mainAxisExtent: 220,
                          ),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final movie = data[index];
                            return Center(
                              child: MediaPosterGridCard(
                                movie: movie,
                                sectionTitle: sectionTitle,
                                width: cardWidth,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
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
