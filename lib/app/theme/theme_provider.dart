import 'package:cineverse/app/theme/theme_palette.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeTypeProvider = NotifierProvider<AppThemeNotifier, AppThemeType>(
  () {
    return AppThemeNotifier();
  },
);

class AppThemeNotifier extends Notifier<AppThemeType> {
  static const _themeKey = 'selected_app_theme';

  @override
  AppThemeType build() {
    _loadTheme();
    return AppThemeType.forest;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      state = AppThemeType.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => AppThemeType.forest,
      );
    }
  }

  Future<void> setTheme(AppThemeType type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, type.name);
  }
}
