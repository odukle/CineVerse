import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/app/theme/theme_palette.dart';
import 'package:cineverse/app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeTypeProvider);

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Appearance',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF112142),
                    Color(0xFF231043),
                    Color(0xFF3A1657),
                  ],
                ),
                border: Border.all(
                  color: AppColors.cinemaBorder.withValues(alpha: 0.28),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your vibe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Swap the app between cinematic personalities without changing any behavior.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ThemeOption(
              type: AppThemeType.lumi,
              name: 'Lumi Cinema',
              description: 'The bold neon-cinema signature.',
              isSelected: currentTheme == AppThemeType.lumi,
              palette: ThemePalette.lumi,
              onSelect: () => ref
                  .read(appThemeTypeProvider.notifier)
                  .setTheme(AppThemeType.lumi),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              type: AppThemeType.midnight,
              name: 'Midnight Black',
              description: 'Noir blues and a sharper dark-room mood.',
              isSelected: currentTheme == AppThemeType.midnight,
              palette: ThemePalette.midnight,
              onSelect: () => ref
                  .read(appThemeTypeProvider.notifier)
                  .setTheme(AppThemeType.midnight),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              type: AppThemeType.oceanic,
              name: 'Oceanic Deep',
              description: 'Cool currents with polished cyan highlights.',
              isSelected: currentTheme == AppThemeType.oceanic,
              palette: ThemePalette.oceanic,
              onSelect: () => ref
                  .read(appThemeTypeProvider.notifier)
                  .setTheme(AppThemeType.oceanic),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              type: AppThemeType.forest,
              name: 'Royal Forest',
              description: 'Emerald luxury with warm gilded accents.',
              isSelected: currentTheme == AppThemeType.forest,
              palette: ThemePalette.forest,
              onSelect: () => ref
                  .read(appThemeTypeProvider.notifier)
                  .setTheme(AppThemeType.forest),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final AppThemeType type;
  final String name;
  final String description;
  final bool isSelected;
  final ThemePalette palette;
  final VoidCallback onSelect;

  const _ThemeOption({
    required this.type,
    required this.name,
    required this.description,
    required this.isSelected,
    required this.palette,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? <Color>[
                    palette.gradientTop.withValues(alpha: 0.92),
                    palette.background.withValues(alpha: 0.96),
                    palette.gradientBottom.withValues(alpha: 0.92),
                  ]
                : <Color>[
                    AppColors.cinemaPanelTop.withValues(alpha: 0.86),
                    AppColors.cinemaPanelMid.withValues(alpha: 0.86),
                    AppColors.cinemaPanelBottom.withValues(alpha: 0.9),
                  ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected ? palette.accent : AppColors.cinemaBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: palette.accent.withValues(alpha: 0.22),
                    blurRadius: 24,
                    spreadRadius: -10,
                    offset: const Offset(0, 16),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Preview Circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [palette.gradientTop, palette.background],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: palette.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: palette.accent.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: palette.accent)
            else
              const Icon(Icons.circle_outlined, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
