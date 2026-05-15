import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/app/theme/app_theme.dart';
import 'package:cineverse/app/theme/theme_palette.dart';
import 'package:cineverse/app/theme/theme_provider.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/presentation/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LumiApp extends ConsumerWidget {
  const LumiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncInitializationProvider);
    final router = ref.watch(appRouterProvider);
    final themeType = ref.watch(appThemeTypeProvider);
    
    // Update the global palette before building
    AppColors.palette = ThemePalette.fromType(themeType);

    return MaterialApp.router(
      key: ValueKey(themeType), // Force full rebuild when theme changes
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
