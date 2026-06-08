import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/data/services/sync_service.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
import 'package:cineverse/core/config/region_preferences.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/presentation/features/home/providers/watch_history_insights_provider.dart';
import 'package:cineverse/presentation/features/home/providers/library_retention_provider.dart';
import 'package:cineverse/presentation/features/home/providers/reminders_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/notes_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/providers/auth_provider.dart';
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
          'Delete Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This permanently deletes your Lumi account and synced cloud data. Local data on this device will remain unless you remove the app data separately.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
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
        const SnackBar(content: Text('Account deleted successfully.')),
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
          'Use local library for sync?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This device already has local library titles. Include them in your signed-in library, or replace local library data with your cloud library.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: const Text(
              'Use Cloud Only',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.cinemaSelected,
            ),
            child: const Text(
              'Include Local Library',
              style: TextStyle(fontWeight: FontWeight.bold),
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
          'Sign Out',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Choose whether to keep the local library on this device after signing out.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _SignOutChoice.signOutOnly),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text(
              'Keep Local Library',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _SignOutChoice.signOutAndClearLocal),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text(
              'Clear Local Library',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignInResult(BuildContext context, WidgetRef ref) async {
    final SyncService syncService = ref.read(syncServiceProvider);
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
        'Merged local titles into your signed-in library.',
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
      'Replaced local library data with your cloud library.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final userAsync = ref.watch(authStateProvider);
    final UserEntity? user = userAsync.value;
    final int remindersCount = ref.watch(remindersCountProvider);
    final AsyncValue<LibraryRetentionBundle> retentionAsync = ref.watch(
      libraryRetentionBundleProvider,
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
                  'Account',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your profile, sync state, region, and visual preferences all live here.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.76),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Profile',
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
                        user?.displayName ?? user?.email ?? 'Guest Viewer',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user == null
                            ? 'Sign in to sync your watchlist, ratings, and preferences.'
                            : 'Signed in and syncing to the cloud.',
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
                                    await ref
                                        .read(authRepositoryProvider)
                                        .signInWithGoogle();
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
                                label: const Text('Sign in with Google'),
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
                                      await ref
                                          .read(authRepositoryProvider)
                                          .signInWithApple();
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
                                  label: const Text('Sign in with Apple'),
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
                                await ref
                                    .read(authRepositoryProvider)
                                    .signOut();
                                if (choice ==
                                    _SignOutChoice.signOutAndClearLocal) {
                                  await ref
                                      .read(syncServiceProvider)
                                      .clearLocalLibrary();
                                  _invalidateLocalLibraryProviders(ref);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  await _showInfoSnackBar(
                                    context,
                                    'Signed out and cleared the local library on this device.',
                                  );
                                }
                              },
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text('Sign Out'),
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
                              label: const Text('Delete Account'),
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
          const _WatchHistoryInsightsCard(),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.event_note_rounded,
            title: 'Release Calendar',
            subtitle: upcomingCount == 0
                ? 'Track upcoming releases and get quick reminder shortcuts.'
                : '$upcomingCount upcoming release${upcomingCount == 1 ? '' : 's'} across your library.',
            onTap: () => context.pushNamed(AppRoute.releaseCalendar.name),
          ),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: remindersCount == 0
                ? 'Control premiere alerts and release reminders.'
                : '$remindersCount reminder${remindersCount == 1 ? '' : 's'} scheduled.',
            onTap: () => context.pushNamed(AppRoute.notifications.name),
          ),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Choose your theme and customize the app look.',
            onTap: () => context.pushNamed('appearance'),
          ),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.visibility_off_outlined,
            title: 'Hidden Titles',
            subtitle:
                'Manage the titles you have hidden from the Spotlight section.',
            onTap: () => context.pushNamed(AppRoute.hiddenTitles.name),
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
                'Developed by',
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
            'This product uses the TMDB API but is not endorsed or certified by TMDB.',
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
    final String regionLabel = regionLabelForCode(effectiveRegionCode);
    final String autoRegionCode = detectedRegionCode ?? effectiveRegionCode;
    final String autoRegionLabel = regionLabelForCode(autoRegionCode);

    return _AccountActionCard(
      icon: Icons.public_rounded,
      title: 'Content Region',
      subtitle: selectedRegionCode == null
          ? 'Auto-detected region: $regionLabel ($effectiveRegionCode). Select a region to override for localized movie queries and watch-provider lookups.'
          : 'Selected region: $regionLabel ($effectiveRegionCode). Supported movie queries and watch-provider lookups will reuse this automatically next time.',
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
                'Select Region',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Only TMDb endpoints that support region-aware queries will use this selection.',
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
                title: const Text(
                  'Use Auto-Detected Region',
                  style: TextStyle(color: Colors.white),
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
                      option.label,
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
                    'Analyzing your watch history...',
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
                        'Watch Insights',
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
                      tooltip: 'Refresh insights',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Could not analyze watch history right now.',
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
                            'Watch Insights',
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
                          tooltip: 'Refresh insights',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      analyzedCount == 0
                          ? 'Add and rate at least $kMinimumWatchedItemsForInsights watched titles to unlock personalized insights.'
                          : 'You have $analyzedCount/$kMinimumWatchedItemsForInsights watched titles analyzed. '
                                'Add ${kMinimumWatchedItemsForInsights - analyzedCount} more to generate insights.',
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
                          'Watch Insights',
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
                        tooltip: 'Refresh insights',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Based on ${insights.analyzedTitlesCount} watched titles',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.64),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last updated: ${_formatInsightsTime(insights.generatedAt)}',
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
                      'Preferred runtime: ~${insights.averageRuntimeMinutes} min (${insights.preferredRuntimeLabel})',
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
                        'Open full analytics',
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
