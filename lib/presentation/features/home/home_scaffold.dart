import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
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
    final Widget? leadingContent = isMoviesOrTv
        ? _ChromeActionButton(
            tooltip: 'Sort titles',
            icon: Icons.sort_rounded,
            onTap: () =>
                _showSortSheet(context, ref, currentTab == HomeTab.tvShows),
          )
        : isExplore
        ? const FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ExploreMediaTypeToggle(),
          )
        : isLibrary
        ? const SyncIndicator()
        : null;
    final double leadingWidth = isExplore ? 170 : 150;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final bool? shouldPop = await showAnimatedDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.detailsCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            title: Text(
              'Exit App',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to exit Lumi?',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: Colors.white60),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.cinemaAccent,
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
            toolbarHeight: 68,
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            flexibleSpace: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.cinemaGradientTop.withValues(alpha: 0.92),
                      AppColors.cinemaBackground.withValues(alpha: 0.78),
                      AppColors.cinemaBackground.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            leadingWidth: leadingWidth,
            leading: leadingContent == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: leadingContent,
                    ),
                  ),
            title: SvgPicture.asset(
              'assets/logos/logo.svg',
              height: 24,
              fit: BoxFit.contain,
              semanticsLabel: AppConstants.appName,
            ),
            actions: [
              SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ChromeActionButton(
                      tooltip: 'Search',
                      icon: Icons.search_rounded,
                      onTap: () {
                        context.pushNamed(AppRoute.search.name);
                      },
                    ),
                    if (isMoviesOrTv) const SizedBox(width: 10),
                    if (isMoviesOrTv)
                      _ChromeActionButton(
                        tooltip: 'Filters',
                        icon: Icons.tune_rounded,
                        onTap: () {
                          context.pushNamed(
                            AppRoute.filter.name,
                            queryParameters: {
                              'isTv': (currentTab == HomeTab.tvShows)
                                  .toString(),
                            },
                          );
                        },
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final currentSort = ref.watch(genreSortProvider);
            final effectiveCurrentSort =
                isTv && currentSort.sortField == SortField.revenue
                ? currentSort.copyWith(sortField: SortField.popularity)
                : currentSort;
            final List<SortField> options = <SortField>[
              SortField.popularity,
              SortField.voteAverage,
              SortField.releaseDate,
              SortField.voteCount,
              if (!isTv) SortField.revenue,
            ];
            SortField selectedField = effectiveCurrentSort.sortField;
            SortOrder selectedOrder = effectiveCurrentSort.sortOrder;

            return StatefulBuilder(
              builder: (context, setModalState) {
                final bool isDescending = selectedOrder == SortOrder.descending;

                return SafeArea(
                  top: false,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.82,
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.cinemaPanelGradient,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      border: Border.all(
                        color: AppColors.cinemaBorder.withValues(alpha: 0.3),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sort By',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white.withValues(alpha: 0.04),
                              border: Border.all(
                                color: AppColors.cinemaBorder.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: SwitchListTile(
                              title: const Text(
                                'Descending Order',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              value: isDescending,
                              activeThumbColor: AppColors.cinemaAccent,
                              onChanged: (value) {
                                HapticFeedback.selectionClick();
                                setModalState(() {
                                  selectedOrder = value
                                      ? SortOrder.descending
                                      : SortOrder.ascending;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...options.map((field) {
                            final isSelected = selectedField == field;
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              tileColor: isSelected
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.transparent,
                              leading: Icon(
                                fieldIcon,
                                color: isSelected
                                    ? AppColors.cinemaAccent
                                    : Colors.white70,
                                size: 20,
                              ),
                              title: Text(
                                field.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.cinemaAccent
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      selectedOrder == SortOrder.descending
                                          ? Icons.arrow_downward_rounded
                                          : Icons.arrow_upward_rounded,
                                      color: AppColors.cinemaAccent,
                                      size: 18,
                                    )
                                  : null,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() {
                                  selectedField = field;
                                });
                              },
                            );
                          }),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(genreSortProvider.notifier)
                                    .updateSort(selectedField, selectedOrder);

                                final genreId = isTv
                                    ? ref.read(selectedTvGenreIdProvider)
                                    : ref.read(selectedMovieGenreIdProvider);
                                if (genreId != null) {
                                  resetGenreSection(ref, genreId, isTv: isTv);
                                } else {
                                  final section = isTv
                                      ? MovieSection.tvPopular
                                      : MovieSection.popular;
                                  resetMovieSection(ref, section);
                                }

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cinemaAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ChromeActionButton extends StatelessWidget {
  const _ChromeActionButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.24),
            ),
          ),
          child: Icon(icon, size: 22, color: Colors.white),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}
