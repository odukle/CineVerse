import 'package:cineverse/core/notifications/local_notification_service.dart';
import 'package:cineverse/data/datasources/local/app_database.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AutoReleaseNotificationScheduler {
  AutoReleaseNotificationScheduler({
    required AppDatabase database,
    required MediaRepository mediaRepository,
    LocalNotificationService? notificationService,
  }) : _database = database,
       _mediaRepository = mediaRepository,
       _notificationService =
           notificationService ?? LocalNotificationService.instance;

  static const Duration _tvLeadTime = Duration(hours: 1);
  static const int _movieMorningHour = 8;
  static const int _movieMorningMinute = 0;

  final AppDatabase _database;
  final MediaRepository _mediaRepository;
  final LocalNotificationService _notificationService;

  bool _isSyncing = false;

  Future<void> sync() async {
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;
    try {
      final _TrackedLibrary tracked = await _loadTrackedLibrary();
      final List<
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
      notifications =
          <
            ({
              String notificationKey,
              String title,
              String body,
              DateTime scheduledAt,
              int? mediaId,
              bool? isTv,
              String? backdropPath,
            })
          >[];

      for (final int tvId in tracked.tvIds) {
        final notification = await _buildTvNotification(tvId);
        if (notification != null) {
          notifications.add(notification);
        }
      }

      for (final _TrackedMovie movie in tracked.movies.values) {
        final notification = await _buildMovieNotification(movie);
        if (notification != null) {
          notifications.add(notification);
        }
      }

      await _notificationService.syncAutoReleaseNotifications(
        notifications: notifications,
      );
      if (kDebugMode) {
        debugPrint(
          '[AutoReleaseNotificationScheduler] synced ${notifications.length} auto-release notifications',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[AutoReleaseNotificationScheduler] sync failed: $error\n$stackTrace',
        );
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<
    ({
      String notificationKey,
      String title,
      String body,
      DateTime scheduledAt,
      int? mediaId,
      bool? isTv,
      String? backdropPath,
    })?
  >
  _buildTvNotification(int tvId) async {
    try {
      final MovieDetails details = await _mediaRepository.fetchMovieDetails(
        tvId,
        isTv: true,
      );
      final TvEpisode? episode = details.nextEpisodeToAir;
      if (episode == null) {
        return null;
      }
      final DateTime? airDate = _parseTmdbDate(
        episode.airDate,
        dateOnlyHour: 23,
        dateOnlyMinute: 59,
        dateOnlySecond: 59,
      );
      if (airDate == null) {
        return null;
      }
      final DateTime scheduledAt = airDate.subtract(_tvLeadTime);
      if (!scheduledAt.isAfter(DateTime.now())) {
        return null;
      }
      final String localAirTime = DateFormat(
        'EEE, d MMM • hh:mm a',
      ).format(airDate.toLocal());
      final String episodeLabel =
          'S${episode.seasonNumber}E${episode.episodeNumber}';
      return (
        notificationKey:
            'auto-tv-${details.id}-${episode.id}-${airDate.millisecondsSinceEpoch}',
        title: '${details.title} airs in 1 hour',
        body: '$episodeLabel "${episode.name}" airs at $localAirTime.',
        scheduledAt: scheduledAt,
        mediaId: details.id,
        isTv: true,
        backdropPath: details.backdropPath ?? details.posterPath,
      );
    } catch (_) {
      return null;
    }
  }

  Future<
    ({
      String notificationKey,
      String title,
      String body,
      DateTime scheduledAt,
      int? mediaId,
      bool? isTv,
      String? backdropPath,
    })?
  >
  _buildMovieNotification(_TrackedMovie movie) async {
    try {
      MovieDetails? details;
      try {
        details = await _mediaRepository.fetchMovieDetails(
          movie.id,
          isTv: false,
        );
      } catch (_) {}

      DateTime? releaseDate = _parseTmdbDate(movie.releaseDate);
      if (releaseDate == null ||
          releaseDate.isBefore(
            _todayStart().subtract(const Duration(days: 1)),
          )) {
        releaseDate = _parseMovieReleaseDate(details);
      }
      if (releaseDate == null) {
        return null;
      }

      final DateTime day = DateTime(
        releaseDate.year,
        releaseDate.month,
        releaseDate.day,
      );
      final DateTime today = _todayStart();
      if (day.isBefore(today)) {
        return null;
      }

      DateTime scheduledAt = DateTime(
        day.year,
        day.month,
        day.day,
        _movieMorningHour,
        _movieMorningMinute,
      );
      final DateTime now = DateTime.now();
      if (!scheduledAt.isAfter(now)) {
        if (day == today) {
          scheduledAt = now.add(const Duration(minutes: 1));
        } else {
          return null;
        }
      }

      final String title = details?.title ?? movie.title;
      final String localDate = DateFormat('EEE, d MMM').format(day);
      return (
        notificationKey:
            'auto-movie-${movie.id}-${day.year.toString().padLeft(4, '0')}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}',
        title: '$title releases today',
        body: 'A movie in your library is releasing on $localDate.',
        scheduledAt: scheduledAt,
        mediaId: movie.id,
        isTv: false,
        backdropPath: details?.backdropPath ?? details?.posterPath,
      );
    } catch (_) {
      return null;
    }
  }

  Future<_TrackedLibrary> _loadTrackedLibrary() async {
    final List<WatchlistItemsTableData> watchlistRows = await _database
        .select(_database.watchlistItemsTable)
        .get();
    final List<WatchedItemsTableData> watchedRows = await _database
        .select(_database.watchedItemsTable)
        .get();
    final List<FavouritesTableData> favouriteRows = await _database
        .select(_database.favouritesTable)
        .get();
    final List<NamedListItemsTableData> namedListRows = await _database
        .select(_database.namedListItemsTable)
        .get();

    final Set<int> tvIds = <int>{};
    final Map<int, _TrackedMovie> movies = <int, _TrackedMovie>{};

    void addMovie({
      required int id,
      required String title,
      String? releaseDate,
    }) {
      if (id <= 0) {
        return;
      }
      final _TrackedMovie? existing = movies[id];
      final String? chosenReleaseDate = _pickBetterReleaseDate(
        existing?.releaseDate,
        releaseDate,
      );
      movies[id] = _TrackedMovie(
        id: id,
        title: existing?.title ?? title,
        releaseDate: chosenReleaseDate,
      );
    }

    void addMedia({
      required int id,
      required String title,
      required GlobalMediaType mediaType,
      String? releaseDate,
    }) {
      if (mediaType == GlobalMediaType.tv) {
        tvIds.add(id);
      } else if (mediaType == GlobalMediaType.movie) {
        addMovie(id: id, title: title, releaseDate: releaseDate);
      }
    }

    for (final row in watchlistRows) {
      addMedia(
        id: row.id,
        title: row.title,
        mediaType: row.mediaType,
        releaseDate: row.releaseDate,
      );
    }
    for (final row in watchedRows) {
      addMedia(id: row.id, title: row.title, mediaType: row.mediaType);
    }
    for (final row in favouriteRows) {
      addMedia(
        id: row.id,
        title: row.title,
        mediaType: row.mediaType,
        releaseDate: row.releaseDate,
      );
    }
    for (final row in namedListRows) {
      addMedia(
        id: row.mediaId,
        title: row.title,
        mediaType: row.mediaType,
        releaseDate: row.releaseDate,
      );
    }

    return _TrackedLibrary(tvIds: tvIds, movies: movies);
  }

  String? _pickBetterReleaseDate(String? current, String? candidate) {
    if (candidate == null || candidate.trim().isEmpty) {
      return current;
    }
    if (current == null || current.trim().isEmpty) {
      return candidate;
    }
    final DateTime? currentDate = _parseTmdbDate(current);
    final DateTime? candidateDate = _parseTmdbDate(candidate);
    if (candidateDate == null) {
      return current;
    }
    if (currentDate == null) {
      return candidate;
    }
    return candidateDate.isBefore(currentDate) ? candidate : current;
  }

  DateTime? _parseMovieReleaseDate(MovieDetails? details) {
    if (details == null) {
      return null;
    }
    final List<DateTime> candidates = <DateTime?>[
      _parseTmdbDate(details.releaseDate),
      _parseTmdbDate(details.digitalReleaseDate),
      _parseTmdbDate(details.physicalReleaseDate),
    ].whereType<DateTime>().toList(growable: false);
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((a, b) => a.compareTo(b));
    return candidates.first;
  }

  DateTime? _parseTmdbDate(
    String? raw, {
    int dateOnlyHour = 0,
    int dateOnlyMinute = 0,
    int dateOnlySecond = 0,
  }) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final String value = raw.trim();
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return null;
    }
    if (!value.contains('T')) {
      return DateTime(
        parsed.year,
        parsed.month,
        parsed.day,
        dateOnlyHour,
        dateOnlyMinute,
        dateOnlySecond,
      );
    }
    return parsed.toLocal();
  }

  DateTime _todayStart() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

class _TrackedLibrary {
  const _TrackedLibrary({required this.tvIds, required this.movies});

  final Set<int> tvIds;
  final Map<int, _TrackedMovie> movies;
}

class _TrackedMovie {
  const _TrackedMovie({
    required this.id,
    required this.title,
    this.releaseDate,
  });

  final int id;
  final String title;
  final String? releaseDate;
}
