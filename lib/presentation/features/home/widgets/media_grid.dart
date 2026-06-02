import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaGrid extends ConsumerWidget {
  const MediaGrid({required this.isTv, this.genreId, super.key});

  final bool isTv;
  final int? genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final customFilter = ref.watch(
      isTv ? tvFilterProvider : movieFilterProvider,
    );

    // Determine which data provider to use
    final provider = !customFilter.isDefault
        ? movieSectionProvider(
            isTv ? MovieSection.tvDiscover : MovieSection.discover,
          )
        : genreId != null
        ? genreSectionProvider((id: genreId!, isTv: isTv))
        : movieSectionProvider(
            isTv ? MovieSection.tvPopular : MovieSection.popular,
          );

    final mediaAsync = ref.watch(provider);

    final String sectionTitle = !customFilter.isDefault
        ? 'Filtered Results'
        : genreId != null
        ? 'Genre Results'
        : 'Popular';

    return mediaAsync.when(
      loading: () => const _ShimmerGrid(),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load content. $error',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(provider),
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
              'No content available for this selection.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          );
        }

        const double horizontalPadding = 16;
        const double crossAxisSpacing = 12;
        const double mainAxisSpacing = 16;
        const int crossAxisCount = 3;
        final double cardWidth =
            (MediaQuery.sizeOf(context).width -
                (horizontalPadding * 2) -
                (crossAxisSpacing * 2)) /
            crossAxisCount;

        final bool isFetchingMore = mediaAsync.isLoading && data.isNotEmpty;

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              if (!customFilter.isDefault) {
                loadNextPages(
                  ref,
                  isTv ? MovieSection.tvDiscover : MovieSection.discover,
                );
              } else if (genreId != null) {
                loadNextGenrePages(ref, genreId!, isTv: isTv);
              } else {
                loadNextPages(
                  ref,
                  isTv ? MovieSection.tvPopular : MovieSection.popular,
                );
              }
            }
            return false;
          },
          child: CustomScrollView(
            cacheExtent: 1000,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = data[index];
                    return Center(
                      child: MediaPosterGridCard(
                        movie: item,
                        sectionTitle: sectionTitle,
                        width: cardWidth,
                        isTvTitle: isTv,
                      ),
                    );
                  }, childCount: data.length),
                ),
              ),
              if (isFetchingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cinemaAccent,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
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
