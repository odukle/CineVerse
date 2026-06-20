import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/presentation/features/movies/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreMediaTypeToggle extends ConsumerWidget {
  const ExploreMediaTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = ref.watch(exploreMediaTypeProvider);

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cinemaBorder.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(
            label: context.l10n.toggleMovies,
            selected: mediaType == ExploreMediaType.movie,
            onTap: () {
              if (mediaType != ExploreMediaType.movie) {
                HapticFeedback.selectionClick();
              }
              ref
                  .read(exploreMediaTypeProvider.notifier)
                  .setType(ExploreMediaType.movie);
            },
          ),
          _ToggleOption(
            label: context.l10n.toggleTv,
            selected: mediaType == ExploreMediaType.tv,
            onTap: () {
              if (mediaType != ExploreMediaType.tv) {
                HapticFeedback.selectionClick();
              }
              ref
                  .read(exploreMediaTypeProvider.notifier)
                  .setType(ExploreMediaType.tv);
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: <Color>[
                    AppColors.cinemaGlow,
                    AppColors.cinemaWarmGlow,
                  ],
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.cinemaGlow.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: -8,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
