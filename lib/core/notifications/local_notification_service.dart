import 'dart:convert';
import 'dart:io';

import 'package:cineverse/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationNavigationTarget {
  const NotificationNavigationTarget({
    required this.mediaId,
    required this.isTv,
  });

  final int mediaId;
  final bool isTv;
}

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const String _channelId = 'cineverse_reminders';
  static const String _channelName = 'Lumi Reminders';
  static const String _channelDescription =
      'Episode airing and custom reminder notifications';
  static const String _reminderPayloadKind = 'cineverse_reminder';
  static const String _autoReleasePayloadKind = 'cineverse_auto_release';
  static const Set<String> _managedPayloadKinds = <String>{
    _reminderPayloadKind,
    _autoReleasePayloadKind,
  };

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Dio _dio = Dio();
  bool _isInitialized = false;
  NotificationNavigationTarget? _pendingNavigationTarget;
  Future<void> Function(NotificationNavigationTarget target)?
  _notificationTapHandler;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
          macOS: iosSettings,
          linux: linuxSettings,
        );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _handleNotificationTapPayload(response.payload);
      },
    );
    final NotificationAppLaunchDetails? launchDetails = await _plugin
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      await _handleNotificationTapPayload(
        launchDetails?.notificationResponse?.payload,
      );
    }
    await _configureLocalTimezone();
    await _requestPlatformPermissions();
    _isInitialized = true;
  }

  void setNotificationTapHandler(
    Future<void> Function(NotificationNavigationTarget target) handler,
  ) {
    _notificationTapHandler = handler;
    final NotificationNavigationTarget? pending = _pendingNavigationTarget;
    if (pending != null) {
      _pendingNavigationTarget = null;
      Future<void>(() => handler(pending));
    }
  }

  Future<void> scheduleReminder({
    required String reminderId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    int? mediaId,
    bool? isTv,
    String? backdropPath,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (!scheduledAt.isAfter(DateTime.now())) {
      return;
    }

    final int notificationId = _notificationIdFromReminderId(reminderId);
    final DateTime localScheduledAt = scheduledAt.toLocal();
    final tz.TZDateTime triggerAt = tz.TZDateTime.from(
      localScheduledAt,
      tz.local,
    );
    final NotificationDetails notificationDetails = await _notificationDetails(
      title: title,
      body: body,
      backdropPath: backdropPath,
    );
    final String payload = _buildPayload(
      kind: _reminderPayloadKind,
      notificationKey: reminderId,
      mediaId: mediaId,
      isTv: isTv,
    );
    await _scheduleNotification(
      notificationId: notificationId,
      title: title,
      body: body,
      triggerAt: triggerAt,
      notificationDetails: notificationDetails,
      payload: payload,
    );

    if (kDebugMode) {
      final bool scheduled = await _isScheduled(notificationId);
      debugPrint(
        '[LocalNotificationService] reminderId=$reminderId '
        'localScheduledAt=$localScheduledAt tzLocal=${tz.local.name} '
        'scheduled=$scheduled',
      );
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    if (!_isInitialized) {
      await initialize();
    }
    final int notificationId = _notificationIdFromReminderId(reminderId);
    await _plugin.cancel(id: notificationId);
  }

  Future<void> syncAutoReleaseNotifications({
    required List<
      ({
        String notificationKey,
        String title,
        String body,
        DateTime scheduledAt,
        int? mediaId,
        bool? isTv,
        String? backdropPath,
      })
    >
    notifications,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final DateTime now = DateTime.now();
    final Map<
      int,
      ({
        String notificationKey,
        String title,
        String body,
        DateTime scheduledAt,
        int? mediaId,
        bool? isTv,
        String? backdropPath,
      })
    >
    byNotificationId =
        <
          int,
          ({
            String notificationKey,
            String title,
            String body,
            DateTime scheduledAt,
            int? mediaId,
            bool? isTv,
            String? backdropPath,
          })
        >{};

    for (final notification in notifications) {
      if (!notification.scheduledAt.isAfter(now)) {
        continue;
      }
      final int id = _notificationIdFromKey(notification.notificationKey);
      byNotificationId[id] = notification;
    }

    final List<PendingNotificationRequest> pending = await _plugin
        .pendingNotificationRequests();
    for (final request in pending) {
      final String payload = request.payload ?? '';
      if (!_isManagedNotificationPayload(
        payload,
        expectedKind: _autoReleasePayloadKind,
      )) {
        continue;
      }
      if (!byNotificationId.containsKey(request.id)) {
        await _plugin.cancel(id: request.id);
      }
    }

    for (final entry in byNotificationId.entries) {
      final notification = entry.value;
      final DateTime localScheduledAt = notification.scheduledAt.toLocal();
      final tz.TZDateTime triggerAt = tz.TZDateTime.from(
        localScheduledAt,
        tz.local,
      );
      final NotificationDetails details = await _notificationDetails(
        title: notification.title,
        body: notification.body,
        backdropPath: notification.backdropPath,
      );
      final String payload = _buildPayload(
        kind: _autoReleasePayloadKind,
        notificationKey: notification.notificationKey,
        mediaId: notification.mediaId,
        isTv: notification.isTv,
      );
      await _scheduleNotification(
        notificationId: entry.key,
        title: notification.title,
        body: notification.body,
        triggerAt: triggerAt,
        notificationDetails: details,
        payload: payload,
      );
    }
  }

  Future<void> syncScheduledReminders({
    required List<
      ({
        String reminderId,
        String title,
        String body,
        DateTime scheduledAt,
        int? mediaId,
        bool? isTv,
        String? backdropPath,
      })
    >
    reminders,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final DateTime now = DateTime.now();
    final Map<
      int,
      ({
        String reminderId,
        String title,
        String body,
        DateTime scheduledAt,
        int? mediaId,
        bool? isTv,
        String? backdropPath,
      })
    >
    byNotificationId =
        <
          int,
          ({
            String reminderId,
            String title,
            String body,
            DateTime scheduledAt,
            int? mediaId,
            bool? isTv,
            String? backdropPath,
          })
        >{};

    for (final reminder in reminders) {
      if (!reminder.scheduledAt.isAfter(now)) {
        continue;
      }
      final int id = _notificationIdFromReminderId(reminder.reminderId);
      byNotificationId[id] = reminder;
    }

    final List<PendingNotificationRequest> pending = await _plugin
        .pendingNotificationRequests();
    for (final request in pending) {
      final String payload = request.payload ?? '';
      if (!_isManagedNotificationPayload(
        payload,
        expectedKind: _reminderPayloadKind,
      )) {
        continue;
      }
      if (!byNotificationId.containsKey(request.id)) {
        await _plugin.cancel(id: request.id);
      }
    }

    for (final entry in byNotificationId.entries) {
      final reminder = entry.value;
      await scheduleReminder(
        reminderId: reminder.reminderId,
        title: reminder.title,
        body: reminder.body,
        scheduledAt: reminder.scheduledAt,
        mediaId: reminder.mediaId,
        isTv: reminder.isTv,
        backdropPath: reminder.backdropPath,
      );
    }
  }

  Future<NotificationDetails> _notificationDetails({
    required String title,
    required String body,
    String? backdropPath,
  }) async {
    final String? backdropFile = await _cachedBackdropFilePath(backdropPath);
    final StyleInformation? styleInformation = backdropFile == null
        ? null
        : BigPictureStyleInformation(
            FilePathAndroidBitmap(backdropFile),
            contentTitle: title,
            summaryText: body,
          );
    final AndroidNotificationDetails android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      ticker: 'Lumi Reminder',
      styleInformation: styleInformation,
    );
    const DarwinNotificationDetails ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: android, iOS: ios, macOS: ios);
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    try {
      final TimezoneInfo timezoneInfo =
          await FlutterTimezone.getLocalTimezone();
      final String normalized = _normalizedTimezoneId(timezoneInfo.identifier);
      tz.setLocalLocation(tz.getLocation(normalized));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Timezone setup failed, defaulting to UTC: $error');
      }
      for (final String fallback in <String>['Etc/UTC', 'GMT', 'Zulu']) {
        try {
          tz.setLocalLocation(tz.getLocation(fallback));
          return;
        } catch (_) {}
      }
    }
  }

  String _normalizedTimezoneId(String identifier) {
    final String value = identifier.trim();
    if (value == 'Asia/Calcutta') {
      return 'Asia/Kolkata';
    }
    if (value == 'UTC') {
      return 'Etc/UTC';
    }
    return value;
  }

  Future<void> _requestPlatformPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final bool? notificationsGranted = await androidPlugin
        ?.requestNotificationsPermission();
    final bool? exactGranted = await androidPlugin
        ?.requestExactAlarmsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final MacOSFlutterLocalNotificationsPlugin? macosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode && androidPlugin != null) {
      final bool? notificationsEnabled = await androidPlugin
          .areNotificationsEnabled();
      final bool? canExact = await androidPlugin
          .canScheduleExactNotifications();
      debugPrint(
        '[LocalNotificationService] '
        'requestNotificationsPermission=$notificationsGranted '
        'requestExactAlarmsPermission=$exactGranted '
        'areNotificationsEnabled=$notificationsEnabled '
        'canScheduleExactNotifications=$canExact',
      );
    }
  }

  Future<AndroidScheduleMode> _preferredAndroidScheduleMode() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final bool? canExact = await androidPlugin?.canScheduleExactNotifications();
    if (canExact == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<bool> _isScheduled(int id) async {
    final List<PendingNotificationRequest> pending = await _plugin
        .pendingNotificationRequests();
    return pending.any((request) => request.id == id);
  }

  Future<Set<String>> pendingManagedReminderIds() async {
    if (!_isInitialized) {
      await initialize();
    }
    final List<PendingNotificationRequest> pending = await _plugin
        .pendingNotificationRequests();
    final Set<String> ids = <String>{};
    for (final request in pending) {
      final Map<String, dynamic>? map = _decodePayloadMap(
        request.payload,
        expectedKind: _reminderPayloadKind,
      );
      if (map == null) {
        continue;
      }
      final String? reminderId = map['reminderId'] as String?;
      if (reminderId != null && reminderId.isNotEmpty) {
        ids.add(reminderId);
      }
    }
    return ids;
  }

  Future<void> _handleNotificationTapPayload(String? payload) async {
    final NotificationNavigationTarget? target = _parseNavigationTarget(
      payload,
    );
    if (target == null) {
      return;
    }
    final handler = _notificationTapHandler;
    if (handler == null) {
      _pendingNavigationTarget = target;
      return;
    }
    await handler(target);
  }

  String _buildPayload({
    required String kind,
    required String notificationKey,
    int? mediaId,
    bool? isTv,
  }) {
    return jsonEncode(<String, Object?>{
      'kind': kind,
      'reminderId': notificationKey,
      'mediaId': mediaId,
      'isTv': isTv,
    });
  }

  bool _isManagedNotificationPayload(String payload, {String? expectedKind}) {
    return _decodePayloadMap(payload, expectedKind: expectedKind) != null;
  }

  NotificationNavigationTarget? _parseNavigationTarget(String? payload) {
    final Map<String, dynamic>? decoded = _decodePayloadMap(payload);
    if (decoded == null) {
      return null;
    }
    final dynamic mediaIdRaw = decoded['mediaId'];
    final int? mediaId = mediaIdRaw is int
        ? mediaIdRaw
        : int.tryParse('$mediaIdRaw');
    if (mediaId == null || mediaId <= 0) {
      return null;
    }
    return NotificationNavigationTarget(
      mediaId: mediaId,
      isTv: decoded['isTv'] == true,
    );
  }

  Map<String, dynamic>? _decodePayloadMap(
    String? payload, {
    String? expectedKind,
  }) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final String? kind = decoded['kind'] as String?;
      if (kind == null || !_managedPayloadKinds.contains(kind)) {
        return null;
      }
      if (expectedKind != null && kind != expectedKind) {
        return null;
      }
      return decoded;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _cachedBackdropFilePath(String? backdropPath) async {
    final String? normalizedUrl = _normalizedBackdropUrl(backdropPath);
    if (normalizedUrl == null) {
      return null;
    }
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'notif_backdrop_${normalizedUrl.hashCode}.jpg';
      final File file = File(p.join(tempDir.path, fileName));
      if (!await file.exists() || (await file.length()) == 0) {
        final Response<List<int>> response = await _dio.get<List<int>>(
          normalizedUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        final List<int>? bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          return null;
        }
        await file.writeAsBytes(bytes, flush: true);
      }
      return file.path;
    } catch (_) {
      return null;
    }
  }

  String? _normalizedBackdropUrl(String? backdropPath) {
    final String? raw = backdropPath?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    if (!raw.startsWith('/')) {
      return null;
    }
    return '${AppConstants.tmdbImageBaseUrl}/w780$raw';
  }

  int _notificationIdFromReminderId(String reminderId) {
    return _notificationIdFromKey(reminderId);
  }

  Future<void> _scheduleNotification({
    required int notificationId,
    required String title,
    required String body,
    required tz.TZDateTime triggerAt,
    required NotificationDetails notificationDetails,
    required String payload,
  }) async {
    final AndroidScheduleMode scheduleMode =
        await _preferredAndroidScheduleMode();
    await _plugin.cancel(id: notificationId);
    try {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: triggerAt,
        notificationDetails: notificationDetails,
        payload: payload,
        androidScheduleMode: scheduleMode,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: triggerAt,
        notificationDetails: notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  int _notificationIdFromKey(String key) {
    // Stable 31-bit FNV-1a hash from key.
    int hash = 0x811C9DC5;
    for (int i = 0; i < key.length; i++) {
      hash ^= key.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
