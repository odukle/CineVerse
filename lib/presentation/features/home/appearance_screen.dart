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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose your vibe',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          _ThemeOption(
            type: AppThemeType.lumi,
            name: 'Lumi Cinema',
            description: 'The classic midnight purple experience.',
            isSelected: currentTheme == AppThemeType.lumi,
            palette: ThemePalette.lumi,
            onSelect: () => ref.read(appThemeTypeProvider.notifier).setTheme(AppThemeType.lumi),
          ),
          const SizedBox(height: 16),
          _ThemeOption(
            type: AppThemeType.midnight,
            name: 'Midnight Black',
            description: 'Pitch black tones for OLED screens.',
            isSelected: currentTheme == AppThemeType.midnight,
            palette: ThemePalette.midnight,
            onSelect: () => ref.read(appThemeTypeProvider.notifier).setTheme(AppThemeType.midnight),
          ),
          const SizedBox(height: 16),
          _ThemeOption(
            type: AppThemeType.oceanic,
            name: 'Oceanic Deep',
            description: 'Calming teal and cyan hues.',
            isSelected: currentTheme == AppThemeType.oceanic,
            palette: ThemePalette.oceanic,
            onSelect: () => ref.read(appThemeTypeProvider.notifier).setTheme(AppThemeType.oceanic),
          ),
          const SizedBox(height: 16),
          _ThemeOption(
            type: AppThemeType.forest,
            name: 'Royal Forest',
            description: 'Sophisticated emerald and gold accents.',
            isSelected: currentTheme == AppThemeType.forest,
            palette: ThemePalette.forest,
            onSelect: () => ref.read(appThemeTypeProvider.notifier).setTheme(AppThemeType.forest),
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
          color: isSelected 
              ? palette.accent.withValues(alpha: 0.15) 
              : AppColors.cinemaSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? palette.accent : Colors.white10,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: palette.accent.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ] : [],
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
                      )
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
