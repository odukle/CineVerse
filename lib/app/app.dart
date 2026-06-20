import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/app/theme/app_theme.dart';
import 'package:cineverse/app/theme/theme_palette.dart';
import 'package:cineverse/app/theme/theme_provider.dart';
import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/core/notifications/local_notification_service.dart';
import 'package:cineverse/presentation/providers/locale_provider.dart';
import 'package:cineverse/presentation/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cineverse/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LumiApp extends ConsumerWidget {
  const LumiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncInitializationProvider);
    final router = ref.watch(appRouterProvider);
    final themeType = ref.watch(appThemeTypeProvider);
    final appLocale = ref.watch(appLocaleProvider);

    LocalNotificationService.instance.setNotificationTapHandler((target) async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        router.goNamed(AppRoute.explore.name);
        await Future<void>.delayed(const Duration(milliseconds: 140));
        router.pushNamed(
          AppRoute.movieDetails.name,
          pathParameters: <String, String>{'movieId': '${target.mediaId}'},
          queryParameters: <String, String>{
            'isTv': '${target.isTv}',
            'fromNotification': 'true',
          },
        );
      });
    });

    // Update the global palette before building
    AppColors.palette = ThemePalette.fromType(themeType);

    return MaterialApp.router(
      key: ValueKey('${themeType.name}_${appLocale?.languageCode ?? "system"}'), // Force rebuild on theme/locale change
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      locale: appLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
