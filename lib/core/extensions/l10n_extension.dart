import 'package:flutter/widgets.dart';
import 'package:cineverse/l10n/app_localizations.dart';

/// Convenience extension to access [AppLocalizations] from any [BuildContext].
///
/// Usage:
/// ```dart
/// final l10n = context.l10n;
/// Text(l10n.navExplore);
/// ```
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
