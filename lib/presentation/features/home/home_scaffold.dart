import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/presentation/features/home/app_bottom_navigation_bar.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeScaffold extends ConsumerWidget {
  const HomeScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeTab currentTab = HomeTab.values[navigationShell.currentIndex];
    final bool isMoviesOrTv = currentTab == HomeTab.movies || currentTab == HomeTab.tvShows;

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: AppColors.cinemaGradientTop,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: isMoviesOrTv ? 140 : null,
        leading: isMoviesOrTv
            ? _AppBarFilterPill(tab: currentTab)
            : null,
        title: SizedBox(
          height: 28,
          child: SvgPicture.asset(
            'logo.svg',
            fit: BoxFit.contain,
            semanticsLabel: AppConstants.appName,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: navigationShell,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentTab: currentTab,
        onTabSelected: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}

class _AppBarFilterPill extends ConsumerStatefulWidget {
  const _AppBarFilterPill({required this.tab});
  final HomeTab tab;

  @override
  ConsumerState<_AppBarFilterPill> createState() => _AppBarFilterPillState();
}

class _AppBarFilterPillState extends ConsumerState<_AppBarFilterPill> {
  bool _isExpanded = false;


  @override
  Widget build(BuildContext context) {
    final filterOptions = widget.tab == HomeTab.movies
        ? ref.watch(movieFilterOptions)
        : ref.watch(tvFilterOptions);
    final selectedFilter = widget.tab == HomeTab.movies
        ? ref.watch(selectedMovieFilterProvider)
        : ref.watch(selectedTvFilterProvider);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: AppColors.cinemaSurface,
          ),
          child: PopupMenuButton<MediaFilterOption>(
            initialValue: selectedFilter,
            tooltip: 'Change category',
            onSelected: (option) {
              if (widget.tab == HomeTab.movies) {
                ref.read(selectedMovieFilterProvider.notifier).setFilter(option);
              } else {
                ref.read(selectedTvFilterProvider.notifier).setFilter(option);
              }
            },
            onOpened: () => setState(() => _isExpanded = true),
            onCanceled: () => setState(() => _isExpanded = false),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => filterOptions.map((option) {
              final bool isSelected = option.section == selectedFilter.section;
              return PopupMenuItem<MediaFilterOption>(
                value: option,
                child: Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected ? AppColors.cinemaAccent : Colors.white,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cinemaSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.cinemaAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedFilter.label,
                    style: const TextStyle(
                      color: AppColors.cinemaPillText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.cinemaAccent,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
