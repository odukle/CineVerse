import 'package:cineverse/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum HomeTab { explore, movies, tvShows, account }

extension _HomeTabRoute on HomeTab {

  IconData get icon {
    switch (this) {
      case HomeTab.explore:
        return Icons.explore_rounded;
      case HomeTab.movies:
        return Icons.movie_creation_outlined;
      case HomeTab.tvShows:
        return Icons.tv_outlined;
      case HomeTab.account:
        return Icons.person_outline_rounded;
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
                (tab) => Expanded(
                  child: _BottomNavItem(tab: tab, selected: tab == currentTab),
                ),
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
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(
          color: Colors.white,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );

    return InkWell(
      onTap: selected
          ? null
          : () => (context.findAncestorWidgetOfExactType<AppBottomNavigationBar>()!)
              .onTabSelected(AppBottomNavigationBar._tabOrder.indexOf(tab)),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.cinemaSelected : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(tab.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 4),
            Text(tab.label, style: labelStyle),
          ],
        ),
      ),
    );
  }
}
