import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/presentation/features/home/app_bottom_navigation_bar.dart';
import 'package:cineverse/presentation/features/home/widgets/explore_media_type_toggle.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cineverse/app/router/app_router.dart' show AppRoute;
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:go_router/go_router.dart';

import 'package:cineverse/presentation/widgets/sync_indicator.dart';

class HomeScaffold extends ConsumerWidget {
  const HomeScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeTab currentTab = HomeTab.values[navigationShell.currentIndex];
    final bool isMoviesOrTv =
        currentTab == HomeTab.movies || currentTab == HomeTab.tvShows;

    final bool isExplore = currentTab == HomeTab.explore;
    final bool isLibrary = currentTab == HomeTab.watchlist;
    const double appBarSideWidth = 150;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.detailsCard,
            title: const Text(
              'Exit App',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to exit CineVerse?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Exit',
                  style: TextStyle(color: AppColors.cinemaAccent),
                ),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          // Properly request the platform to exit the application
          await SystemNavigator.pop();
        }
      },
      child: BackgroundGradient(
        child: Scaffold(
          backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: Colors.transparent,
          elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: appBarSideWidth,
        leading: Row(
          children: [
            if (isMoviesOrTv)
              IconButton(
                onPressed: () => _showSortSheet(context, ref, currentTab == HomeTab.tvShows),
                icon: const Icon(
                  Icons.sort_rounded,
                  size: 24,
                  color: Colors.white,
                ),
                tooltip: 'Sort titles',
              ),
            if (isExplore)
              const ExploreMediaTypeToggle(),
            if (isLibrary)
              const SyncIndicator(),
          ],
        ),
        title: SvgPicture.asset(
          'assets/logos/logo.svg',
          height: 26,
          fit: BoxFit.contain,
          semanticsLabel: AppConstants.appName,
        ),
        actions: [
          SizedBox(
            width: appBarSideWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    context.pushNamed(AppRoute.search.name);
                  },
                  icon: const Icon(
                    Icons.search_rounded,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                if (isMoviesOrTv)
                  IconButton(
                    onPressed: () {
                      context.pushNamed(
                        AppRoute.filter.name,
                        queryParameters: {
                          'isTv': (currentTab == HomeTab.tvShows).toString(),
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.tune_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(top: false, child: navigationShell),
      bottomNavigationBar: AppBottomNavigationBar(
        currentTab: currentTab,
        onTabSelected: (index) => navigationShell.goBranch(index),
      ),
    ),
  ),
);
  }

  void _showSortSheet(BuildContext context, WidgetRef ref, bool isTv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cinemaSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final currentSort = ref.watch(genreSortProvider);
            final bool isDescending = currentSort.sortOrder == SortOrder.descending;
            final List<SortField> options = [
              SortField.popularity,
              SortField.voteAverage,
              SortField.releaseDate,
              SortField.revenue,
              SortField.voteCount,
            ];

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text(
                      'Descending Order',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    value: isDescending,
                    activeThumbColor: AppColors.cinemaAccent,
                    onChanged: (value) {
                      final newOrder = value ? SortOrder.descending : SortOrder.ascending;
                      ref.read(genreSortProvider.notifier).updateSort(currentSort.sortField, newOrder);
                      
                      // Refresh data
                      final genreId = isTv 
                          ? ref.read(selectedTvGenreIdProvider)
                          : ref.read(selectedMovieGenreIdProvider);
                      if (genreId != null) {
                        resetGenreSection(ref, genreId, isTv: isTv);
                      } else {
                        final section = isTv ? MovieSection.tvPopular : MovieSection.popular;
                        resetMovieSection(ref, section);
                      }
                    },
                  ),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 4),
                  ...options.map((field) {
                    final isSelected = currentSort.sortField == field;
                    IconData fieldIcon;
                    switch (field) {
                      case SortField.popularity:
                        fieldIcon = Icons.trending_up_rounded;
                        break;
                      case SortField.voteAverage:
                        fieldIcon = Icons.star_rounded;
                        break;
                      case SortField.releaseDate:
                        fieldIcon = Icons.calendar_today_rounded;
                        break;
                      case SortField.revenue:
                        fieldIcon = Icons.attach_money_rounded;
                        break;
                      case SortField.voteCount:
                        fieldIcon = Icons.people_rounded;
                        break;
                    }

                    return ListTile(
                      leading: Icon(
                        fieldIcon,
                        color:
                            isSelected ? AppColors.cinemaAccent : Colors.white70,
                        size: 20,
                      ),
                      title: Text(
                        field.label,
                        style: TextStyle(
                          color:
                              isSelected ? AppColors.cinemaAccent : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                currentSort.sortOrder == SortOrder.descending
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: AppColors.cinemaAccent,
                                size: 18,
                              )
                              : null,
                      onTap: () {
                        // Use current switch state for the new field
                        ref
                            .read(genreSortProvider.notifier)
                            .updateSort(field, currentSort.sortOrder);

                        // Reset current genre/section to trigger re-fetch with new sort
                        final genreId =
                            isTv
                                ? ref.read(selectedTvGenreIdProvider)
                                : ref.read(selectedMovieGenreIdProvider);

                        if (genreId != null) {
                          resetGenreSection(ref, genreId, isTv: isTv);
                        } else {
                          final section =
                              isTv
                                  ? MovieSection.tvPopular
                                  : MovieSection.popular;
                          resetMovieSection(ref, section);
                        }

                        Navigator.pop(context);
                      },
                    );
                  }),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      );
  }
}
