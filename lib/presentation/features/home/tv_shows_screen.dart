import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvShowsScreen extends ConsumerWidget {
  const TvShowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool hasMovieApiAccess = ref.watch(
      appConfigProvider.select((config) => config.hasMovieApiAccess),
    );
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
      child: hasMovieApiAccess
          ? (isFiltering
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.cinemaAccent,
                    ),
                  )
                : tvShows.when(
                    skipLoadingOnReload: true,
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (Object error, StackTrace stackTrace) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Could not load TV shows. $error',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                    data: (List<MediaTitle> data) {
                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            'No TV shows available right now.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                        );
                      }

                      const double horizontalPadding = 16;
                      const double crossAxisSpacing = 10;
                      const double mainAxisSpacing = 16;
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
                                mainAxisExtent: 246,
                              ),
                          itemCount: data.length + 1,
                          itemBuilder: (context, index) {
                            if (index == data.length) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final MediaTitle show = data[index];
                            return Center(
                              child: MediaPosterGridCard(
                                movie: show,
                                sectionTitle: selectedFilter.label,
                                width: cardWidth,
                                isTvTitle: true,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.vpn_key_outlined,
                      size: 52,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Movie API configuration required',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add MOVIE_PROXY_BASE_URL for production, or TMDB_API_KEY for direct development access.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
