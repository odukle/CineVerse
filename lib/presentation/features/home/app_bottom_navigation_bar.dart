import 'package:cineverse/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum HomeTab { explore, movies, tvShows, watchlist, account }

extension _HomeTabRoute on HomeTab {

  IconData get icon {
    switch (this) {
      case HomeTab.explore:
        return Icons.explore_outlined;
      case HomeTab.movies:
        return Icons.movie_creation_outlined;
      case HomeTab.tvShows:
        return Icons.tv_outlined;
      case HomeTab.watchlist:
        return Icons.bookmark_outline_rounded;
      case HomeTab.account:
        return Icons.person_outline_rounded;
    }
  }

  IconData get selectedIcon {
    switch (this) {
      case HomeTab.explore:
        return Icons.explore_rounded;
      case HomeTab.movies:
        return Icons.movie_creation_rounded;
      case HomeTab.tvShows:
        return Icons.tv_rounded;
      case HomeTab.watchlist:
        return Icons.bookmark_rounded;
      case HomeTab.account:
        return Icons.person_rounded;
    }
  }

  String get label {
    switch (this) {
      case HomeTab.explore:
        return 'Explore';
      case HomeTab.movies:
        return 'Movies';
      case HomeTab.tvShows:
        return 'TV Shows';
      case HomeTab.watchlist:
        return 'Library';
      case HomeTab.account:
        return 'Account';
    }
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.currentTab,
    required this.onTabSelected,
    super.key,
  });

  static const List<HomeTab> _tabOrder = <HomeTab>[
    HomeTab.explore,
    HomeTab.movies,
    HomeTab.tvShows,
    HomeTab.watchlist,
    HomeTab.account,
  ];

  final HomeTab currentTab;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cinemaGradientBottom,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: SafeArea(
        top: false,
        child: Row(
          children: _tabOrder
              .map(
                (tab) => _BottomNavItem(tab: tab, selected: tab == currentTab),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.tab, required this.selected});

  final HomeTab tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: selected
            ? null
            : () => (context
                    .findAncestorWidgetOfExactType<AppBottomNavigationBar>()!)
                .onTabSelected(AppBottomNavigationBar._tabOrder.indexOf(tab)),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 20 : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.cinemaSelected.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: selected ? 1.15 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Icon(
                    selected ? tab.selectedIcon : tab.icon,
                    color: selected ? AppColors.cinemaAccent : Colors.white70,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? AppColors.cinemaAccent : Colors.white70,
                ),
                child: Text(tab.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
