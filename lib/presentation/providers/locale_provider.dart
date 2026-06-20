import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist the user's explicit app-language choice.
const String _appLanguageKey = 'app_language_mode';

/// Notifier that persists and exposes the app UI language.
///
/// `null` means "follow the system locale". Any non-null value overrides the
/// system locale for the app's UI (labels, buttons, empty states, etc.).
class AppLanguageNotifier extends Notifier<String?> {
  @override
  String? build() {
    _restorePersistedLanguage();
    return null;
  }

  Future<void> _restorePersistedLanguage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? persistedCode = preferences.getString(_appLanguageKey);
    if (ref.mounted && state != persistedCode) {
      state = persistedCode;
    }
  }

  Future<void> setLanguage(String? code) async {
    state = code;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (code == null || code.isEmpty) {
      await preferences.remove(_appLanguageKey);
      return;
    }
    await preferences.setString(_appLanguageKey, code);
  }
}

/// Provider that exposes the current app UI language selection.
final appLanguageProvider = NotifierProvider<AppLanguageNotifier, String?>(
  AppLanguageNotifier.new,
);

/// Provider that exposes the current app locale based on the user's app language selection.
/// If no language is selected (null), it returns null, letting the app fallback to the system locale.
final appLocaleProvider = Provider<Locale?>((ref) {
  final String? languageCode = ref.watch(appLanguageProvider);
  if (languageCode == null || languageCode.isEmpty) {
    return null;
  }
  return Locale(languageCode);
});
