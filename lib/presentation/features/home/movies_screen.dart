import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoviesScreen extends ConsumerWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final MediaFilterOption selectedFilter = ref.watch(selectedMovieFilterProvider);
    final AsyncValue<List<MediaTitle>> movies = ref.watch(
      movieSectionProvider(selectedFilter.section),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.cinemaGradient,
        ),
      ),
      child: movies.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Could not load movies. $error',
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
                'No movies available right now.',
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

                final MediaTitle movie = data[index];
                return Center(
                  child: MediaPosterGridCard(
                    movie: movie,
                    sectionTitle: selectedFilter.label,
                    width: cardWidth,
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
