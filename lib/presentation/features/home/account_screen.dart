import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/config/region_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Text(
            'Account',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: theme.cardTheme.shape is RoundedRectangleBorder
                  ? Border.fromBorderSide(
                      (theme.cardTheme.shape as RoundedRectangleBorder).side,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.cinemaSelected,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
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
                        'Guest Viewer',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to sync your watchlist, ratings, and preferences across devices.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _RegionPreferenceCard(),
          const SizedBox(height: 14),
          const _AccountActionCard(
            icon: Icons.bookmark_border_rounded,
            title: 'Watchlist',
            subtitle: 'Save titles you want to revisit later.',
          ),
          const SizedBox(height: 14),
          const _AccountActionCard(
            icon: Icons.download_outlined,
            title: 'Downloads',
            subtitle: 'Track the titles you keep offline for travel.',
          ),
          const SizedBox(height: 14),
          const _AccountActionCard(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Control premiere alerts and release reminders.',
          ),
          const SizedBox(height: 14),
          _AccountActionCard(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Choose your theme and customize the app look.',
            onTap: () => context.pushNamed('appearance'),
          ),
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
    final String effectiveRegionCode = ref.watch(preferredRegionCodeProvider);
    final String? selectedRegionCode = selectedRegionAsync.asData?.value;
    final String regionLabel = regionLabelForCode(effectiveRegionCode);

    return _AccountActionCard(
      icon: Icons.public_rounded,
      title: 'Content Region',
      subtitle: selectedRegionCode == null
          ? 'Default region: $regionLabel ($effectiveRegionCode). Select a region to localize supported movie queries and watch-provider lookups.'
          : 'Selected region: $regionLabel ($effectiveRegionCode). Supported movie queries and watch-provider lookups will reuse this automatically next time.',
      trailing: selectedRegionAsync.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: () => _showRegionPicker(context, ref, effectiveRegionCode),
    );
  }

  Future<void> _showRegionPicker(
    BuildContext context,
    WidgetRef ref,
    String effectiveRegionCode,
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
                  'Use Default (US)',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Matches the app default when no region is selected.',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: effectiveRegionCode == 'US'
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : null,
                onTap: () async {
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
                          ? (theme.cardTheme.shape as RoundedRectangleBorder).side
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: theme.cardTheme.shape is RoundedRectangleBorder
                ? Border.fromBorderSide(
                    (theme.cardTheme.shape as RoundedRectangleBorder).side,
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cinemaSurface,
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
