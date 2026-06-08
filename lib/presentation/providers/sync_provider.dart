import 'dart:async';

import 'package:cineverse/core/notifications/auto_release_notification_scheduler.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/data/services/sync_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cineverse/presentation/providers/auth_provider.dart';

import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';

enum SyncStatus { idle, syncing, error }

class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => SyncStatus.idle;

  void setStatus(SyncStatus status) {
    state = status;
  }
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatus>(
  SyncStatusNotifier.new,
);

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    ref.watch(firestoreProvider),
    ref.watch(appDatabaseProvider),
    onStatusChanged: (status) {
      ref.read(syncStatusProvider.notifier).setStatus(status);

      // If sync just finished successfully, refresh the library UI
      if (status == SyncStatus.idle) {
        ref.invalidate(watchlistProvider);
        ref.invalidate(watchedItemsProvider);
        ref.invalidate(favouritesProvider);
        ref.invalidate(namedListsProvider);
      }
    },
  );

  ref.listen(authStateProvider, (previous, next) {
    final user = next.value;
    service.updateUserId(user?.id);
    if (user != null && previous?.value?.id != user.id) {
      if (service.consumeSuspendedAutomaticPull()) {
        return;
      }
      service.syncAllFromRemote();
    }
  });

  return service;
});

final autoReleaseNotificationSchedulerProvider =
    Provider<AutoReleaseNotificationScheduler>((ref) {
      return AutoReleaseNotificationScheduler(
        database: ref.watch(appDatabaseProvider),
        mediaRepository: ref.watch(mediaRepositoryProvider),
      );
    });

final autoReleaseNotificationsInitializationProvider = Provider<void>((ref) {
  final AutoReleaseNotificationScheduler scheduler = ref.watch(
    autoReleaseNotificationSchedulerProvider,
  );

  void triggerSync() {
    unawaited(scheduler.sync());
  }

  triggerSync();

  final Timer timer = Timer.periodic(const Duration(minutes: 30), (_) {
    triggerSync();
  });
  ref.onDispose(timer.cancel);

  ref.listen<SyncStatus>(syncStatusProvider, (previous, next) {
    if (previous != SyncStatus.idle && next == SyncStatus.idle) {
      triggerSync();
    }
  });
});

// A simple provider to keep the sync service alive and listening to auth state
final syncInitializationProvider = Provider<void>((ref) {
  ref.watch(syncServiceProvider);
  ref.watch(autoReleaseNotificationsInitializationProvider);
});
