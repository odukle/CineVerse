import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cineverse/core/notifications/local_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _remindersStorageKey = 'cineverse_reminders_v1';

enum ReminderType { episodeAiring, general }

class AppReminder {
  const AppReminder({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.notifyAt,
    required this.createdAt,
    this.mediaId,
    this.isTv,
    this.backdropPath,
    this.seasonNumber,
    this.episodeNumber,
    this.airDate,
  });

  final String id;
  final ReminderType type;
  final String title;
  final String message;
  final DateTime notifyAt;
  final DateTime createdAt;
  final int? mediaId;
  final bool? isTv;
  final String? backdropPath;
  final int? seasonNumber;
  final int? episodeNumber;
  final DateTime? airDate;

  bool get isOverdue => notifyAt.isBefore(DateTime.now());

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'notifyAt': notifyAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'mediaId': mediaId,
      'isTv': isTv,
      'backdropPath': backdropPath,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'airDate': airDate?.toIso8601String(),
    };
  }

  factory AppReminder.fromJson(Map<String, dynamic> json) {
    final ReminderType parsedType = ReminderType.values.firstWhere(
      (type) => type.name == json['type'],
      orElse: () => ReminderType.general,
    );
    return AppReminder(
      id: json['id'] as String,
      type: parsedType,
      title: json['title'] as String,
      message: json['message'] as String,
      notifyAt: DateTime.parse(json['notifyAt'] as String).toLocal(),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      mediaId: json['mediaId'] as int?,
      isTv: json['isTv'] as bool? ?? (parsedType == ReminderType.episodeAiring),
      backdropPath: json['backdropPath'] as String?,
      seasonNumber: json['seasonNumber'] as int?,
      episodeNumber: json['episodeNumber'] as int?,
      airDate: json['airDate'] == null
          ? null
          : DateTime.parse(json['airDate'] as String).toLocal(),
    );
  }
}

class RemindersNotifier extends AsyncNotifier<List<AppReminder>> {
  Timer? _lifecycleTimer;

  @override
  Future<List<AppReminder>> build() async {
    ref.onDispose(() {
      _lifecycleTimer?.cancel();
    });

    final List<AppReminder> loaded = await _load();
    await _syncScheduledNotifications(loaded);
    final List<AppReminder> reconciled = await _pruneTriggeredReminders(loaded);

    _lifecycleTimer?.cancel();
    _lifecycleTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshReminderLifecycle();
    });

    return reconciled;
  }

  Future<void> addReminder(AppReminder reminder) async {
    final List<AppReminder> current = state.asData?.value ?? <AppReminder>[];
    final List<AppReminder> updated = <AppReminder>[reminder, ...current]
      ..sort((a, b) => a.notifyAt.compareTo(b.notifyAt));
    state = AsyncData(updated);
    await _persist(updated);
    await LocalNotificationService.instance.scheduleReminder(
      reminderId: reminder.id,
      title: reminder.title,
      body: reminder.message,
      scheduledAt: reminder.notifyAt,
      mediaId: reminder.mediaId,
      isTv: reminder.isTv,
      backdropPath: reminder.backdropPath,
    );
  }

  Future<void> dismissReminder(String reminderId) async {
    final List<AppReminder> current = state.asData?.value ?? <AppReminder>[];
    AppReminder? removed;
    for (final reminder in current) {
      if (reminder.id == reminderId) {
        removed = reminder;
        break;
      }
    }
    final List<AppReminder> updated = current
        .where((reminder) => reminder.id != reminderId)
        .toList(growable: false);
    state = AsyncData(updated);
    await _persist(updated);
    if (removed != null) {
      await LocalNotificationService.instance.cancelReminder(removed.id);
    }
  }

  Future<List<AppReminder>> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_remindersStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return <AppReminder>[];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AppReminder.fromJson)
        .toList(growable: false)
      ..sort((a, b) => a.notifyAt.compareTo(b.notifyAt));
  }

  Future<void> _persist(List<AppReminder> reminders) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String payload = jsonEncode(
      reminders.map((reminder) => reminder.toJson()).toList(growable: false),
    );
    await prefs.setString(_remindersStorageKey, payload);
  }

  Future<void> _syncScheduledNotifications(List<AppReminder> reminders) async {
    final reminderTuples = reminders
        .map(
          (reminder) => (
            reminderId: reminder.id,
            title: reminder.title,
            body: reminder.message,
            scheduledAt: reminder.notifyAt,
            mediaId: reminder.mediaId,
            isTv: reminder.isTv,
            backdropPath: reminder.backdropPath,
          ),
        )
        .toList(growable: false);

    await LocalNotificationService.instance.syncScheduledReminders(
      reminders: reminderTuples,
    );
  }

  Future<void> _refreshReminderLifecycle() async {
    final List<AppReminder>? current = state.asData?.value;
    if (current == null || current.isEmpty) {
      return;
    }
    final List<AppReminder> updated = await _pruneTriggeredReminders(current);
    if (updated.length != current.length) {
      state = AsyncData(updated);
    }
  }

  Future<List<AppReminder>> _pruneTriggeredReminders(
    List<AppReminder> reminders,
  ) async {
    if (reminders.isEmpty) {
      return reminders;
    }
    final Set<String> pendingReminderIds =
        await LocalNotificationService.instance.pendingManagedReminderIds();
    final DateTime now = DateTime.now();

    final List<AppReminder> updated = reminders.where((reminder) {
      if (reminder.notifyAt.isAfter(now)) {
        return true;
      }
      return pendingReminderIds.contains(reminder.id);
    }).toList(growable: false)
      ..sort((a, b) => a.notifyAt.compareTo(b.notifyAt));

    if (updated.length != reminders.length) {
      await _persist(updated);
    }
    return updated;
  }
}

final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, List<AppReminder>>(
      RemindersNotifier.new,
    );

final remindersCountProvider = Provider<int>((ref) {
  return ref
      .watch(remindersProvider)
      .maybeWhen(data: (items) => items.length, orElse: () => 0);
});

String buildReminderId() {
  final int now = DateTime.now().microsecondsSinceEpoch;
  final int randomPart = Random().nextInt(1 << 20);
  return '$now-$randomPart';
}
