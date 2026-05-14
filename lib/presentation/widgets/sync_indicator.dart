import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/providers/auth_provider.dart';
import 'package:cineverse/presentation/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final user = authState.value;

    if (user == null) {
      return IconButton(
        onPressed: () => context.push('/account'),
        icon: const Icon(Icons.cloud_off_rounded, color: Colors.white38),
        tooltip: 'Sign in to sync with cloud',
      );
    }

    switch (syncStatus) {
      case SyncStatus.syncing:
        return const Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
        );
      case SyncStatus.error:
        return IconButton(
          onPressed: () => ref.read(syncServiceProvider).syncAllToRemote(),
          icon: const Icon(Icons.sync_problem_rounded, color: Colors.redAccent),
          tooltip: 'Sync failed. Tap to retry.',
        );
      case SyncStatus.idle:
        return IconButton(
          onPressed: () => ref.read(syncServiceProvider).syncAllToRemote(),
          icon: Icon(Icons.cloud_done_rounded, color: AppColors.cinemaAccent),
          tooltip: 'Library synced with cloud',
        );
    }
  }
}
