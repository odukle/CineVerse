import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/movies/providers/explore_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreMediaTypeToggle extends ConsumerWidget {
  const ExploreMediaTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = ref.watch(exploreMediaTypeProvider);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Container(
          height: 32,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.cinemaSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.cinemaAccent.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToggleOption(
                label: 'Movies',
                selected: mediaType == ExploreMediaType.movie,
                onTap: () => ref
                    .read(exploreMediaTypeProvider.notifier)
                    .setType(ExploreMediaType.movie),
              ),
              _ToggleOption(
                label: 'TV',
                selected: mediaType == ExploreMediaType.tv,
                onTap: () => ref
                    .read(exploreMediaTypeProvider.notifier)
                    .setType(ExploreMediaType.tv),
              ),
            ],
          ),
        ),
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
          color: selected ? AppColors.cinemaAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
