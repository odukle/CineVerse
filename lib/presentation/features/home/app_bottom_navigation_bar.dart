import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      decoration: BoxDecoration(
        // Gradient from panel-bottom into the dedicated bottomBar color so the
        // bar feels like a seamless dark extension of the background.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.cinemaPanelBottom,
            AppColors.cinemaBottomBar,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.cinemaBorder.withValues(alpha: 0.18),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _tabOrder
                  .map(
                    (tab) => _BottomNavItem(
                      tab: tab,
                      selected: tab == currentTab,
                      onTap: () => onTabSelected(
                        _tabOrder.indexOf(tab),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }
}

/// A pressable nav item driven by two independent [AnimationController]s:
///
/// * [_pressController] — handles the scale/opacity press-down feedback.
/// * [_selectController] — drives a single `t` (0→1) that interpolates
///   *every* selection visual (pill width, gradient alpha, glow, icon size,
///   icon color, label height, label opacity) in one go.  Using a single `t`
///   with [Curves.easeInOutCubic] (slow start → smooth) eliminates the
///   "pop" that occurs when multiple independent [AnimatedContainer] /
///   [AnimatedSize] widgets start simultaneously.
class _BottomNavItem extends StatefulWidget {
  const _BottomNavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final HomeTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem>
    with TickerProviderStateMixin {
  // ── Press feedback ────────────────────────────────────────────────────────
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  // ── Selection state ───────────────────────────────────────────────────────
  late final AnimationController _selectController;
  late final Animation<double> _selectAnim;

  @override
  void initState() {
    super.initState();

    // Press controller — quick compress & release.
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInOut,
      ),
    );
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.78).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );

    // Select controller — single source of truth for all pill/label visuals.
    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      // Start at the correct position without animating on first build.
      value: widget.selected ? 1.0 : 0.0,
    );
    // easeInOutCubic: gentle start → no abrupt pop when pill appears.
    _selectAnim = CurvedAnimation(
      parent: _selectController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(_BottomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _selectController.forward();
      } else {
        _selectController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final String label = _localizedLabel(context);

    return Expanded(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          // Rebuild whenever either controller ticks.
          animation: Listenable.merge([_pressController, _selectAnim]),
          builder: (context, _) {
            final double t = _selectAnim.value; // 0.0 → 1.0

            return Opacity(
              opacity: _opacityAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // ── Glowing pill ───────────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(
                        // Pill grows wider as t increases.
                        horizontal: 14.0 + (4.0 * t),
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: t > 0
                            ? LinearGradient(
                                colors: <Color>[
                                  AppColors.cinemaGlow.withValues(
                                    alpha: 0.22 * t,
                                  ),
                                  AppColors.cinemaWarmGlow.withValues(
                                    alpha: 0.18 * t,
                                  ),
                                ],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: t > 0
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.cinemaGlow.withValues(
                                    alpha: 0.18 * t,
                                  ),
                                  blurRadius: 14 * t,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        // Switch icon variant at the midpoint of the animation.
                        t > 0.5
                            ? widget.tab.selectedIcon
                            : widget.tab.icon,
                        // Lerp colour: white54 → cinemaAccent.
                        color: Color.lerp(
                          Colors.white54,
                          AppColors.cinemaAccent,
                          t,
                        ),
                        // Size: 21 → 24.
                        size: 21.0 + (3.0 * t),
                      ),
                    ),
                    // ── Label (height collapses via Align.heightFactor) ─
                    // ClipRect prevents the label overflowing during collapse.
                    ClipRect(
                      child: Align(
                        heightFactor: t,
                        child: Opacity(
                          opacity: t,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: AppColors.cinemaAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _localizedLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (widget.tab) {
      case HomeTab.explore:
        return l10n.navExplore;
      case HomeTab.movies:
        return l10n.navMovies;
      case HomeTab.tvShows:
        return l10n.navTvShows;
      case HomeTab.watchlist:
        return l10n.navLibrary;
      case HomeTab.account:
        return l10n.navAccount;
    }
  }
}
