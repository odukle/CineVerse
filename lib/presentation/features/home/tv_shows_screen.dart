import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/home/widgets/filter_chips_list.dart';
import 'package:cineverse/presentation/features/home/widgets/media_grid.dart';
import 'package:cineverse/presentation/features/movies/providers/filter_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvShowsScreen extends ConsumerWidget {
  const TvShowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(tvGenresProvider);
    final isFiltered = ref.watch(isTvFilteredProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.cinemaGradient,
        ),
      ),
      child: isFiltered
          ? Column(
              children: [
                const FilterChipsList(isTv: true),
                const Expanded(child: MediaGrid(isTv: true)),
              ],
            )
          : genresAsync.when(
              data: (genres) {
                final allGenres = genres;
                return DefaultTabController(
                  length: allGenres.length + 1,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        indicatorColor: AppColors.cinemaAccent,
                        labelColor: AppColors.cinemaAccent,
                        unselectedLabelColor: Colors.white54,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          const Tab(text: 'Popular'),
                          ...allGenres.map((g) => Tab(
                              text: genres.length > 5
                                  ? g.name
                                  : g.name.toUpperCase())),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            const MediaGrid(isTv: true),
                            ...allGenres.map(
                                (g) => MediaGrid(isTv: true, genreId: g.id)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => Center(
                  child:
                      CircularProgressIndicator(color: AppColors.cinemaAccent)),
              error: (error, _) =>
                  Center(child: Text('Error loading genres: $error')),
            ),
    );
  }
}
