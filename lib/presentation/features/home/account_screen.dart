import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/l10n/app_localizations.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/data/services/sync_service.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
import 'package:cineverse/core/config/region_preferences.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_section.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/presentation/features/movies/providers/tonight_ai_consent_provider.dart';
import 'package:cineverse/presentation/features/home/providers/watch_history_insights_provider.dart';
import 'package:cineverse/presentation/features/home/providers/library_retention_provider.dart';
import 'package:cineverse/presentation/features/home/providers/reminders_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/movies_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/notes_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/providers/auth_provider.dart';
import 'package:cineverse/presentation/providers/locale_provider.dart';
import 'package:cineverse/presentation/providers/sync_provider.dart';
import 'package:cineverse/presentation/widgets/tab_content_reveal.dart';
import 'package:cineverse/domain/entities/user_entity.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  static final Uri _aiPrivacyUri = Uri.parse(
    'https://odukle.github.io/CineVerse/lumi/privacy.html',
  );

  void _invalidateLocalLibraryProviders(WidgetRef ref) {
    ref.invalidate(watchlistProvider);
    ref.invalidate(watchedItemsProvider);
    ref.invalidate(favouritesProvider);
    ref.invalidate(namedListsProvider);
    ref.invalidate(allNotesProvider);
  }

  Future<void> _showInfoSnackBar(BuildContext context, String message) async {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showErrorSnackBar(BuildContext context, Object error) async {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Future<void> _showAiConsentChoice(
    BuildContext context,
    WidgetRef ref,
    TonightAiConsentStatus currentStatus,
  ) async {
    final bool enabled = currentStatus == TonightAiConsentStatus.granted;
    final bool? allow = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: Text(
          context.l10n.aiRecommendationsPrivacy,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          enabled
              ? context.l10n.aiConsentGranted
              : context.l10n.aiConsentNotGranted,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: Text(
              context.l10n.close,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, !enabled),
            style: TextButton.styleFrom(
              foregroundColor: enabled
                  ? Colors.redAccent
                  : AppColors.cinemaSelected,
            ),
            child: Text(
              enabled ? context.l10n.disable : context.l10n.allow,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (allow == null) {
      return;
    }
    if (allow) {
      await ref.read(tonightAiConsentProvider.notifier).grant();
      if (!context.mounted) {
        return;
      }
      await _showInfoSnackBar(
        context,
        context.l10n.aiRecommendationsEnabled,
      );
      return;
    }
    await ref.read(tonightAiConsentProvider.notifier).decline();
    if (!context.mounted) {
      return;
    }
    await _showInfoSnackBar(
      context,
      context.l10n.aiRecommendationsDisabled,
    );
  }

  Future<void> _confirmAndDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool? confirm = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: Text(
          context.l10n.deleteAccount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          context.l10n.deleteAccountConfirmation,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(
              context.l10n.delete,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.accountDeletedSuccessfully)),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      await _showErrorSnackBar(context, error);
    }
  }

  Future<bool?> _promptIncludeLocalLibraryOnSignIn(BuildContext context) async {
    return showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: Text(
          context.l10n.useLocalLibraryForSync,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          context.l10n.localLibrarySyncDescription,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: Text(
              context.l10n.useCloudOnly,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.cinemaSelected,
            ),
            child: Text(
              context.l10n.includeLocalLibrary,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<_SignOutChoice?> _promptSignOutChoice(BuildContext context) async {
    return showAnimatedDialog<_SignOutChoice>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: Text(
          context.l10n.signOut,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          context.l10n.signOutChoiceDescription,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: Text(
              context.l10n.cancel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _SignOutChoice.signOutOnly),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: Text(
              context.l10n.keepLocalLibrary,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _SignOutChoice.signOutAndClearLocal),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(
              context.l10n.clearLocalLibrary,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignInResult(BuildContext context, WidgetRef ref) async {
    final SyncService syncService = ref.read(syncServiceProvider);
    final UserEntity? signedInUser = ref
        .read(authRepositoryProvider)
        .currentUser;
    syncService.updateUserId(signedInUser?.id);
    final bool hasLocalLibrary = await syncService.hasLocalLibraryContent();

    if (!context.mounted) {
      return;
    }

    if (!hasLocalLibrary) {
      await syncService.syncAllFromRemote();
      return;
    }

    final bool includeLocal =
        await _promptIncludeLocalLibraryOnSignIn(context) ?? false;

    if (includeLocal) {
      await syncService.syncAllFromRemote();
      await syncService.syncAllToRemote();
      if (!context.mounted) {
        return;
      }
      await _showInfoSnackBar(
        context,
        context.l10n.mergedLocalTitles,
      );
      return;
    }

    await syncService.clearLocalLibrary();
    _invalidateLocalLibraryProviders(ref);
    await syncService.syncAllFromRemote();
    if (!context.mounted) {
      return;
    }
    await _showInfoSnackBar(
      context,
      context.l10n.replacedLocalLibrary,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final userAsync = ref.watch(authStateProvider);
    final UserEntity? user = userAsync.value;
    final TonightAiConsentStatus aiConsentStatus =
        ref.watch(tonightAiConsentProvider).asData?.value ??
        TonightAiConsentStatus.unknown;
    final int remindersCount = ref.watch(remindersCountProvider);
    final AsyncValue<LibraryRetentionBundle> retentionAsync = ref.watch(
      libraryRetentionBundleProvider(context),
    );
    final int upcomingCount = retentionAsync.maybeWhen(
      data: (LibraryRetentionBundle value) => value.health.upcomingCount,
      orElse: () => 0,
    );

    return TabContentReveal(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
              border: Border.all(
                color: AppColors.cinemaBorder.withValues(alpha: 0.28),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.cinemaGlow.withValues(alpha: 0.12),
                  blurRadius: 22,
                  spreadRadius: -12,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.navAccount,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.yourProfileSyncStateRegionPreferences,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.profile,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.cinemaBorder.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        AppColors.cinemaGlow,
                        AppColors.cinemaWarmGlow,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: user?.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            user!.photoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? user?.email ?? context.l10n.guestViewer,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user == null
                            ? context.l10n.signInToSync
                            : context.l10n.signedInAndSyncing,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.4,
                        ),
                      ),
                      if (user == null) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  HapticFeedback.selectionClick();
                                  try {
                                    ref
                                        .read(syncServiceProvider)
                                        .suspendNextAutomaticPull();
                                    final UserEntity? user = await ref
                                        .read(authRepositoryProvider)
                                        .signInWithGoogle();
                                    ref
                                        .read(syncServiceProvider)
                                        .updateUserId(user?.id);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    await _handleSignInResult(context, ref);
                                  } catch (error) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    await _showErrorSnackBar(context, error);
                                  }
                                },
                                icon: const FaIcon(
                                  FontAwesomeIcons.google,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(l10n.signInWithGoogle),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDB4437),
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFDB4437),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                            ),
                            if (!kIsWeb)
                              SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    HapticFeedback.selectionClick();
                                    try {
                                      ref
                                          .read(syncServiceProvider)
                                          .suspendNextAutomaticPull();
                                      final UserEntity? user = await ref
                                          .read(authRepositoryProvider)
                                          .signInWithApple();
                                      ref
                                          .read(syncServiceProvider)
                                          .updateUserId(user?.id);
                                      if (!context.mounted) {
                                        return;
                                      }
                                      await _handleSignInResult(context, ref);
                                    } catch (error) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      await _showErrorSnackBar(context, error);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.apple_rounded,
                                    size: 18,
                                  ),
                                  label: Text(l10n.signInWithApple),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                HapticFeedback.selectionClick();
                                final _SignOutChoice? choice =
                                    await _promptSignOutChoice(context);
                                if (choice == null) {
                                  return;
                                }
                                final SyncService syncService = ref.read(
                                  syncServiceProvider,
                                );
                                await syncService.syncAllToRemote(
                                  allowEmptyLibraryOverwrite: false,
                                );
                                await ref
                                    .read(authRepositoryProvider)
                                    .signOut();
                                if (choice ==
                                    _SignOutChoice.signOutAndClearLocal) {
                                  await syncService.clearLocalLibrary();
                                  _invalidateLocalLibraryProviders(ref);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  await _showInfoSnackBar(
                                    context,
                                    context.l10n.signedOutAndCleared,
                                  );
                                }
                              },
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: Text(context.l10n.signOut),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                HapticFeedback.mediumImpact();
                                await _confirmAndDeleteAccount(context, ref);
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                              ),
                              label: Text(context.l10n.deleteAccount),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.withValues(
                                  alpha: 0.16,
                                ),
                                foregroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _RegionPreferenceCard(),
          const SizedBox(height: 14),
          const _AppLanguagePreferenceCard(),
          const SizedBox(height: 14),
          const _ContentLanguagePreferenceCard(),
          const SizedBox(height: 14),
          const _WatchHistoryInsightsCard(),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.event_note_rounded,
            title: l10n.releaseCalendar,
            subtitle: upcomingCount == 0
                ? l10n.releaseCalendarDescription
                : context.l10n.upcomingReleasesCount('$upcomingCount'),
            onTap: () => context.pushNamed(AppRoute.releaseCalendar.name),
          ),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.notifications_none_rounded,
            title: l10n.notifications,
            subtitle: remindersCount == 0
                ? context.l10n.controlPremiereAlerts
                : '$remindersCount reminder${remindersCount == 1 ? '' : 's'} scheduled.',
            onTap: () => context.pushNamed(AppRoute.notifications.name),
          ),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.palette_outlined,
            title: l10n.appearance,
            subtitle: l10n.appearanceSubtitle,
            onTap: () => context.pushNamed('appearance'),
          ),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.visibility_off_outlined,
            title: l10n.hiddenTitles,
            subtitle: l10n.manageHiddenTitlesDescription,
            onTap: () => context.pushNamed(AppRoute.hiddenTitles.name),
          ),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.privacy_tip_outlined,
            title: context.l10n.aiRecommendationsPrivacy,
            subtitle: aiConsentStatus == TonightAiConsentStatus.granted
                ? context.l10n.aiRecommendationsEnabledSubtitle
                : context.l10n.reviewAndManageConsent,
            onTap: () => _showAiConsentChoice(context, ref, aiConsentStatus),
            trailing: IconButton(
              tooltip: l10n.tooltipOpenPrivacyPolicy,
              onPressed: () => launchUrl(
                _aiPrivacyUri,
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(
                Icons.open_in_new_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _DeveloperFooter(),
        ],
      ),
    );
  }
}

enum _SignOutChoice { signOutOnly, signOutAndClearLocal }

class _DeveloperFooter extends StatelessWidget {
  const _DeveloperFooter();

  static final Uri _instagramUri = Uri.parse(
    'https://www.instagram.com/odukle',
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: <Widget>[
              Text(
                context.l10n.developedBy,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await launchUrl(
                      _instagramUri,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.cinemaBorder.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const FaIcon(
                          FontAwesomeIcons.instagram,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '@odukle',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            context.l10n.tmdbDisclaimer,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _RegionPreferenceCard extends ConsumerWidget {
  const _RegionPreferenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> selectedRegionAsync = ref.watch(
      selectedRegionCodeProvider,
    );
    final String? detectedRegionCode = ref.watch(detectedRegionCodeProvider);
    final String effectiveRegionCode = ref.watch(preferredRegionCodeProvider);
    final String? selectedRegionCode = selectedRegionAsync.asData?.value;
    final String regionLabel = localizedRegionLabel(
      context.l10n,
      effectiveRegionCode,
    );
    final String autoRegionCode = detectedRegionCode ?? effectiveRegionCode;
    final String autoRegionLabel = localizedRegionLabel(
      context.l10n,
      autoRegionCode,
    );

    return _AccountActionCard(
      icon: Icons.public_rounded,
      title: context.l10n.contentRegion,
      subtitle: selectedRegionCode == null
          ? context.l10n.regionAutoDetectedSubtitle(
              regionLabel,
              effectiveRegionCode,
            )
          : context.l10n.regionSelectedSubtitle(
              regionLabel,
              effectiveRegionCode,
            ),
      trailing: selectedRegionAsync.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: () => _showRegionPicker(
        context,
        ref,
        effectiveRegionCode,
        autoRegionCode,
        autoRegionLabel,
      ),
    );
  }

  Future<void> _showRegionPicker(
    BuildContext context,
    WidgetRef ref,
    String effectiveRegionCode,
    String autoRegionCode,
    String autoRegionLabel,
  ) {
    final theme = Theme.of(context);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              Text(
                context.l10n.selectRegion,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.selectRegionDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: theme.cardTheme.shape is RoundedRectangleBorder
                      ? (theme.cardTheme.shape as RoundedRectangleBorder).side
                      : BorderSide.none,
                ),
                tileColor: theme.cardTheme.color,
                title: Text(
                  context.l10n.useAutoDetectedRegion,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '$autoRegionLabel ($autoRegionCode)',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: effectiveRegionCode == autoRegionCode
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : null,
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await ref
                      .read(selectedRegionCodeProvider.notifier)
                      .setSelectedRegion(null);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 12),
              for (final RegionOption option in commonRegionOptions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: theme.cardTheme.shape is RoundedRectangleBorder
                          ? (theme.cardTheme.shape as RoundedRectangleBorder)
                                .side
                          : BorderSide.none,
                    ),
                    tileColor: theme.cardTheme.color,
                    title: Text(
                      localizedRegionLabel(context.l10n, option.code),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      option.code,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: effectiveRegionCode == option.code
                        ? const Icon(Icons.check_rounded, color: Colors.white)
                        : null,
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await ref
                          .read(selectedRegionCodeProvider.notifier)
                          .setSelectedRegion(option.code);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AppLanguageOption {
  const _AppLanguageOption({
    required this.code,
    required this.label,
    this.nativeLabel,
  });

  final String? code;
  final String label;
  final String? nativeLabel;

  String get displayLabel =>
      nativeLabel == null ? label : '$label · $nativeLabel';
}

class _AppLanguagePreferenceCard extends ConsumerWidget {
  const _AppLanguagePreferenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? selectedCode = ref.watch(appLanguageProvider);
    final AppLocalizations l10n = context.l10n;
    final List<_AppLanguageOption> options = _appLanguageOptions(l10n);
    final _AppLanguageOption selected = options.firstWhere(
      (option) => option.code == selectedCode,
      orElse: () => options.first,
    );

    return _AccountActionCard(
      icon: Icons.language_rounded,
      title: l10n.appLanguage,
      subtitle: selected.code == null
          ? l10n.appLanguageSystemSubtitle
          : l10n.appLanguageSelectedSubtitle(selected.displayLabel),
      onTap: () => _showAppLanguagePicker(context, ref, selected.code),
    );
  }

  List<_AppLanguageOption> _appLanguageOptions(AppLocalizations l10n) {
    const String systemDefaultEnglish = 'System default';
    final String systemDefaultTranslated = l10n.appLanguageSystemDefault;
    final String? systemDefaultNative =
        systemDefaultTranslated == systemDefaultEnglish
            ? null
            : systemDefaultTranslated;

    return <_AppLanguageOption>[
      _AppLanguageOption(
        code: null,
        label: systemDefaultEnglish,
        nativeLabel: systemDefaultNative,
      ),
      _AppLanguageOption(code: 'ar', label: 'Arabic', nativeLabel: 'العربية'),
      _AppLanguageOption(code: 'bn', label: 'Bengali', nativeLabel: 'বাংলা'),
      _AppLanguageOption(code: 'de', label: 'German', nativeLabel: 'Deutsch'),
      _AppLanguageOption(code: 'es', label: 'Spanish', nativeLabel: 'Español'),
      _AppLanguageOption(code: 'fr', label: 'French', nativeLabel: 'Français'),
      _AppLanguageOption(code: 'gu', label: 'Gujarati', nativeLabel: 'ગુજરાતી'),
      _AppLanguageOption(code: 'hi', label: 'Hindi', nativeLabel: 'हिन्दी'),
      _AppLanguageOption(code: 'it', label: 'Italian', nativeLabel: 'Italiano'),
      _AppLanguageOption(code: 'ja', label: 'Japanese', nativeLabel: '日本語'),
      _AppLanguageOption(code: 'kn', label: 'Kannada', nativeLabel: 'ಕನ್ನಡ'),
      _AppLanguageOption(code: 'ko', label: 'Korean', nativeLabel: '한국어'),
      _AppLanguageOption(code: 'ml', label: 'Malayalam', nativeLabel: 'മലയാളം'),
      _AppLanguageOption(code: 'mr', label: 'Marathi', nativeLabel: 'मराठी'),
      _AppLanguageOption(code: 'pa', label: 'Punjabi', nativeLabel: 'ਪੰਜਾਬੀ'),
      _AppLanguageOption(code: 'pt', label: 'Portuguese', nativeLabel: 'Português'),
      _AppLanguageOption(code: 'ru', label: 'Russian', nativeLabel: 'Русский'),
      _AppLanguageOption(code: 'ta', label: 'Tamil', nativeLabel: 'தமிழ்'),
      _AppLanguageOption(code: 'te', label: 'Telugu', nativeLabel: 'తెలుగు'),
      _AppLanguageOption(code: 'zh', label: 'Chinese', nativeLabel: '中文'),
    ];
  }

  Future<void> _showAppLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    String? selectedCode,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String? pendingCode = selectedCode;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final AppLocalizations l10n = context.l10n;
            final List<_AppLanguageOption> options = _appLanguageOptions(l10n);
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appLanguage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.55,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final bool isSelected = option.code == pendingCode;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: Theme.of(context).cardTheme.shape
                                        is RoundedRectangleBorder
                                    ? (Theme.of(context).cardTheme.shape
                                            as RoundedRectangleBorder)
                                        .side
                                    : BorderSide.none,
                              ),
                              tileColor: Theme.of(context).cardTheme.color,
                              title: Text(
                                option.displayLabel,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white)
                                  : null,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => pendingCode = option.code);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(appLanguageProvider.notifier)
                              .setLanguage(pendingCode);
                          Navigator.pop(context);
                        },
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContentLanguagePreferenceCard extends ConsumerWidget {
  const _ContentLanguagePreferenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ContentLanguageOption selected = selectedContentLanguageOption(
      context.l10n,
      ref.watch(contentLanguageProvider),
    );

    return _AccountActionCard(
      icon: Icons.translate_rounded,
      title: context.l10n.contentLanguage,
      subtitle: selected.code == null
          ? context.l10n.contentLanguageAllSubtitle
          : context.l10n.contentLanguageSelectedSubtitle(selected.displayLabel),
      onTap: () => _showContentLanguagePicker(context, ref, selected.code),
    );
  }

  Future<void> _showContentLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    String? selectedCode,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String? pendingCode = selectedCode;
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final List<ContentLanguageOption> visibleOptions =
                contentLanguageOptions(context.l10n)
                    .where((option) {
                      if (query.trim().isEmpty) {
                        return true;
                      }
                      final String normalizedQuery = query.trim().toLowerCase();
                      return option.label.toLowerCase().contains(
                            normalizedQuery,
                          ) ||
                          (option.nativeLabel?.toLowerCase().contains(
                                normalizedQuery,
                              ) ??
                              false);
                    })
                    .toList(growable: false);
            return SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                height: MediaQuery.of(context).size.height * 0.9,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.cinemaPanelGradient,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  border: Border.all(
                    color: AppColors.cinemaBorder.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.contentLanguage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.languageSettingExplanation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        setModalState(() {
                          query = value;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchHint,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppColors.cinemaBorder.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppColors.cinemaBorder.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: AppColors.cinemaAccent.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: visibleOptions
                            .map((option) {
                              final bool isSelected =
                                  pendingCode == option.code;
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                tileColor: isSelected
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                leading: Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? AppColors.cinemaAccent
                                      : Colors.white54,
                                  size: 20,
                                ),
                                title: Text(
                                  option.displayLabel,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.cinemaAccent
                                        : Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setModalState(() {
                                    pendingCode = option.code;
                                  });
                                },
                              );
                            })
                            .toList(growable: false),
                      ),
                    ),
                    if (pendingCode != null) ...<Widget>[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.cinemaBorder.withValues(
                              alpha: 0.24,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: AppColors.cinemaAccent.withValues(
                                alpha: 0.9,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.l10n.tmdbLanguageMetadataNote,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.76),
                                  fontSize: 12.5,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(contentLanguageProvider.notifier)
                              .setLanguage(pendingCode);
                          resetMovieSection(ref, MovieSection.popular);
                          resetMovieSection(ref, MovieSection.tvPopular);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cinemaAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          context.l10n.apply,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _WatchHistoryInsightsCard extends ConsumerWidget {
  const _WatchHistoryInsightsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<WatchHistoryInsights?> insightsAsync = ref.watch(
      watchHistoryInsightsProvider,
    );
    final AsyncValue<List<WatchedItem>> watchedItemsAsync = ref.watch(
      watchedItemsProvider,
    );
    final int analyzedCount = watchedItemsAsync.maybeWhen(
      data: (items) => items
          .where(
            (item) =>
                item.mediaType == GlobalMediaType.movie ||
                item.mediaType == GlobalMediaType.tv,
          )
          .length,
      orElse: () => 0,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.selectionClick();
          context.pushNamed(AppRoute.watchAnalytics.name);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.26),
            ),
          ),
          child: insightsAsync.when(
            loading: () => Row(
              children: <Widget>[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.analyzingWatchHistory,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                ),
              ],
            ),
            error: (Object error, StackTrace _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        context.l10n.watchInsights,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ref.invalidate(watchHistoryInsightsProvider);
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                      ),
                      tooltip: context.l10n.tooltipRefreshInsights,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.couldNotAnalyzeWatchHistory,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.74),
                  ),
                ),
              ],
            ),
            data: (WatchHistoryInsights? insights) {
              if (insights == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            context.l10n.watchInsights,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            ref.invalidate(watchHistoryInsightsProvider);
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white70,
                          ),
                          tooltip: context.l10n.tooltipRefreshInsights,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      analyzedCount == 0
                          ? context.l10n.addAndRateMoreTitles(
                              '$kMinimumWatchedItemsForInsights',
                            )
                          : context.l10n.addMoreTitlesToUnlock(
                              '$analyzedCount',
                              '$kMinimumWatchedItemsForInsights',
                              '${kMinimumWatchedItemsForInsights - analyzedCount}',
                            ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.74),
                        height: 1.4,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          context.l10n.watchInsights,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref.invalidate(watchHistoryInsightsProvider);
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                        ),
                        tooltip: context.l10n.tooltipRefreshInsights,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.basedOnWatchedTitles(
                      '${insights.analyzedTitlesCount}',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.64),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.lastUpdated(
                      _formatInsightsTime(insights.generatedAt),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    insights.insightsText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.4,
                    ),
                  ),
                  if (insights.favoriteGenres.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: insights.favoriteGenres
                          .map(
                            (String genre) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              child: Text(
                                genre,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                  if (insights.averageRatingPerGenre.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    ...insights.averageRatingPerGenre.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${entry.genre}: ${entry.averageRating.toStringAsFixed(1)}/5 (${entry.watchedCount} titles)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.74),
                          ),
                        ),
                      );
                    }),
                  ],
                  if (insights.averageRuntimeMinutes > 0) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.preferredRuntimeLabel(
                        insights.averageRuntimeMinutes.toString(),
                        insights.preferredRuntimeLabel,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.74),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.watchAnalytics,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String _formatInsightsTime(DateTime dateTime) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final String hh = dateTime.hour.toString().padLeft(2, '0');
  final String mm = dateTime.minute.toString().padLeft(2, '0');
  return '$hh:$mm • ${dateTime.day} ${months[dateTime.month - 1]}';
}

class _AccountActionCard extends StatelessWidget {
  const _AccountActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap?.call();
              },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.26),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppColors.cinemaGlow.withValues(alpha: 0.88),
                      AppColors.cinemaWarmGlow.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white70,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
