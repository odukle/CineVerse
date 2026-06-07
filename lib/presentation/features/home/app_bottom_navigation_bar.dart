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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.cinemaPanelTop.withValues(alpha: 0.96),
                AppColors.cinemaPanelMid.withValues(alpha: 0.94),
                AppColors.cinemaPanelBottom.withValues(alpha: 0.94),
              ],
            ),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.38),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.cinemaGlow.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: -12,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: Row(
              children: _tabOrder
                  .map(
                    (tab) =>
                        _BottomNavItem(tab: tab, selected: tab == currentTab),
                  )
                  .toList(growable: false),
            ),
          ),
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
            : () {
                (context
                        .findAncestorWidgetOfExactType<
                          AppBottomNavigationBar
                        >()!)
                    .onTabSelected(
                      AppBottomNavigationBar._tabOrder.indexOf(tab),
                    );
              },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 16 : 12,
                  vertical: selected ? 7 : 5,
                ),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: <Color>[
                            AppColors.cinemaGlow.withValues(alpha: 0.92),
                            AppColors.cinemaWarmGlow.withValues(alpha: 0.92),
                          ],
                        )
                      : null,
                  color: selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.cinemaGlow.withValues(alpha: 0.24),
                            blurRadius: 16,
                            spreadRadius: -6,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Transform.scale(
                  scale: selected ? 1.08 : 1.0,
                  child: Icon(
                    selected ? tab.selectedIcon : tab.icon,
                    color: selected ? Colors.white : Colors.white70,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? Colors.white : Colors.white70,
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
