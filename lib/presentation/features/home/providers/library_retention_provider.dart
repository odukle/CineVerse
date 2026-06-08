import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/library_item.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int kRetentionLookaheadDays = 180;
const int kStaleWatchlistDays = 45;
const int kWatchNextSuggestionCount = 3;

enum ReleaseCalendarEntryKind { movieRelease, episodeAiring }

class ReleaseCalendarEntry {
  const ReleaseCalendarEntry({
    required this.mediaId,
    required this.title,
    required this.isTv,
    required this.kind,
    required this.date,
    required this.subtitle,
    required this.sourceLabels,
    this.posterPath,
    this.backdropPath,
    this.seasonNumber,
    this.episodeNumber,
  });

  final int mediaId;
  final String title;
  final bool isTv;
  final ReleaseCalendarEntryKind kind;
  final DateTime date;
  final String subtitle;
  final List<String> sourceLabels;
  final String? posterPath;
  final String? backdropPath;
  final int? seasonNumber;
  final int? episodeNumber;
}

class WatchNextSuggestion {
  const WatchNextSuggestion({
    required this.mediaId,
    required this.title,
    required this.isTv,
    required this.reason,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
  });

  final int mediaId;
  final String title;
  final bool isTv;
  final String reason;
  final String? posterPath;
  final String? releaseDate;
  final double? voteAverage;
}

class LibraryHealthSnapshot {
  const LibraryHealthSnapshot({
    required this.staleWatchlistCount,
    required this.upcomingCount,
    required this.trackedTitlesCount,
    required this.trackedTvCount,
    required this.watchNextSuggestions,
  });

  final int staleWatchlistCount;
  final int upcomingCount;
  final int trackedTitlesCount;
  final int trackedTvCount;
  final List<WatchNextSuggestion> watchNextSuggestions;
}

class LibraryRetentionBundle {
  const LibraryRetentionBundle({
    required this.upcomingEntries,
    required this.health,
  });

  final List<ReleaseCalendarEntry> upcomingEntries;
  final LibraryHealthSnapshot health;
}

class _TrackedLibraryItem {
  _TrackedLibraryItem({
    required this.id,
    required this.title,
    required this.mediaType,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final int id;
  final String title;
  final GlobalMediaType mediaType;
  final String? posterPath;
  final String? releaseDate;
  final double? voteAverage;
  DateTime addedAt;
  final Set<String> sourceLabels = <String>{};

  bool get isTv => mediaType == GlobalMediaType.tv;
}

final libraryRetentionBundleProvider =
    FutureProvider.autoDispose<LibraryRetentionBundle>((ref) async {
      final List<WatchlistItem> watchlist = await ref.watch(
        watchlistProvider.future,
      );
      final List<WatchedItem> watched = await ref.watch(
        watchedItemsProvider.future,
      );
      final List<FavouriteItem> favourites = await ref.watch(
        favouritesProvider.future,
      );
      final List<NamedList> namedLists = await ref.watch(
        namedListsProvider.future,
      );

      final Map<String, _TrackedLibraryItem> tracked =
          <String, _TrackedLibraryItem>{};

      void upsert({
        required int id,
        required String title,
        required GlobalMediaType mediaType,
        String? posterPath,
        String? releaseDate,
        double? voteAverage,
        required DateTime addedAt,
        required String sourceLabel,
      }) {
        final String key = '${mediaType.name}:$id';
        final _TrackedLibraryItem item =
            tracked[key] ??
            _TrackedLibraryItem(
              id: id,
              title: title,
              mediaType: mediaType,
              posterPath: posterPath,
              releaseDate: releaseDate,
              voteAverage: voteAverage,
              addedAt: addedAt,
            );
        if (addedAt.isAfter(item.addedAt)) {
          item.addedAt = addedAt;
        }
        item.sourceLabels.add(sourceLabel);
        tracked[key] = item;
      }

      for (final WatchlistItem item in watchlist) {
        upsert(
          id: item.id,
          title: item.title,
          mediaType: item.mediaType,
          posterPath: item.posterPath,
          releaseDate: item.releaseDate,
          voteAverage: item.voteAverage,
          addedAt: item.addedDate,
          sourceLabel: 'Watchlist',
        );
      }
      for (final FavouriteItem item in favourites) {
        upsert(
          id: item.id,
          title: item.title,
          mediaType: item.mediaType,
          posterPath: item.posterPath,
          releaseDate: item.releaseDate,
          voteAverage: item.voteAverage,
          addedAt: item.addedDate,
          sourceLabel: 'Favourites',
        );
      }
      for (final NamedList list in namedLists) {
        for (final NamedListItem item in list.items) {
          upsert(
            id: item.mediaId,
            title: item.title,
            mediaType: item.mediaType,
            posterPath: item.posterPath,
            releaseDate: item.releaseDate,
            voteAverage: item.voteAverage,
            addedAt: item.addedDate,
            sourceLabel: 'Lists',
          );
        }
      }
      for (final WatchedItem item in watched) {
        upsert(
          id: item.id,
          title: item.title,
          mediaType: item.mediaType,
          posterPath: item.posterPath,
          voteAverage: item.voteAverage,
          addedAt: item.watchDate,
          sourceLabel: 'Watched',
        );
      }

      final DateTime now = DateTime.now();
      final DateTime lookAhead = now.add(
        const Duration(days: kRetentionLookaheadDays),
      );
      final Set<String> watchedKeys = watched
          .map((WatchedItem item) => '${item.mediaType.name}:${item.id}')
          .toSet();
      final List<_TrackedLibraryItem> trackedItems = tracked.values.toList(
        growable: false,
      );

      final List<ReleaseCalendarEntry> upcoming = <ReleaseCalendarEntry>[];

      for (final _TrackedLibraryItem item in trackedItems) {
        final DateTime? releaseDate = _tryParseDate(item.releaseDate);
        if (!item.isTv &&
            releaseDate != null &&
            !releaseDate.isBefore(now) &&
            !releaseDate.isAfter(lookAhead)) {
          upcoming.add(
            ReleaseCalendarEntry(
              mediaId: item.id,
              title: item.title,
              isTv: false,
              kind: ReleaseCalendarEntryKind.movieRelease,
              date: releaseDate,
              subtitle: 'Movie release',
              sourceLabels: item.sourceLabels.toList()..sort(),
              posterPath: item.posterPath,
            ),
          );
        }
      }

      final mediaRepository = ref.watch(mediaRepositoryProvider);
      final List<_TrackedLibraryItem> trackedTv = trackedItems
          .where((_TrackedLibraryItem item) => item.isTv)
          .toList(growable: false);
      final List<MovieDetails?> tvDetails = await Future.wait<MovieDetails?>(
        trackedTv.map((_TrackedLibraryItem item) async {
          try {
            return await mediaRepository.fetchMovieDetails(item.id, isTv: true);
          } catch (_) {
            return null;
          }
        }),
      );

      for (int i = 0; i < trackedTv.length; i++) {
        final _TrackedLibraryItem item = trackedTv[i];
        final MovieDetails? details = tvDetails[i];
        final TvEpisode? nextEpisode = details?.nextEpisodeToAir;
        final DateTime? airDate = _tryParseDate(nextEpisode?.airDate);
        if (details == null ||
            nextEpisode == null ||
            airDate == null ||
            airDate.isBefore(now) ||
            airDate.isAfter(lookAhead)) {
          continue;
        }
        upcoming.add(
          ReleaseCalendarEntry(
            mediaId: item.id,
            title: item.title,
            isTv: true,
            kind: ReleaseCalendarEntryKind.episodeAiring,
            date: airDate,
            subtitle:
                'Episode S${nextEpisode.seasonNumber} • E${nextEpisode.episodeNumber}',
            sourceLabels: item.sourceLabels.toList()..sort(),
            posterPath: item.posterPath ?? details.posterPath,
            backdropPath: details.backdropPath,
            seasonNumber: nextEpisode.seasonNumber,
            episodeNumber: nextEpisode.episodeNumber,
          ),
        );
      }

      upcoming.sort(
        (ReleaseCalendarEntry a, ReleaseCalendarEntry b) =>
            a.date.compareTo(b.date),
      );

      final List<_TrackedLibraryItem> unwatched = trackedItems
          .where(
            (_TrackedLibraryItem item) =>
                !watchedKeys.contains('${item.mediaType.name}:${item.id}'),
          )
          .toList();
      unwatched.sort((_TrackedLibraryItem a, _TrackedLibraryItem b) {
        final double scoreA = _watchNextScore(a, now);
        final double scoreB = _watchNextScore(b, now);
        return scoreB.compareTo(scoreA);
      });

      final List<WatchNextSuggestion> suggestions = unwatched
          .take(kWatchNextSuggestionCount)
          .map(
            (_TrackedLibraryItem item) => WatchNextSuggestion(
              mediaId: item.id,
              title: item.title,
              isTv: item.isTv,
              reason: _watchNextReason(item, now),
              posterPath: item.posterPath,
              releaseDate: item.releaseDate,
              voteAverage: item.voteAverage,
            ),
          )
          .toList(growable: false);

      final int staleWatchlistCount = watchlist.where((WatchlistItem item) {
        return now.difference(item.addedDate).inDays >= kStaleWatchlistDays &&
            !watchedKeys.contains('${item.mediaType.name}:${item.id}');
      }).length;

      return LibraryRetentionBundle(
        upcomingEntries: upcoming,
        health: LibraryHealthSnapshot(
          staleWatchlistCount: staleWatchlistCount,
          upcomingCount: upcoming.length,
          trackedTitlesCount: trackedItems.length,
          trackedTvCount: trackedTv.length,
          watchNextSuggestions: suggestions,
        ),
      );
    });

DateTime? _tryParseDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  try {
    final DateTime parsed = DateTime.parse(value);
    return DateTime(parsed.year, parsed.month, parsed.day);
  } catch (_) {
    return null;
  }
}

double _watchNextScore(_TrackedLibraryItem item, DateTime now) {
  final double sourceScore =
      (item.sourceLabels.contains('Watchlist') ? 40 : 0) +
      (item.sourceLabels.contains('Favourites') ? 22 : 0) +
      (item.sourceLabels.contains('Lists') ? 16 : 0);
  final double voteScore = (item.voteAverage ?? 0) * 4.5;
  final int ageDays = now.difference(item.addedAt).inDays.clamp(0, 3650);
  final double freshnessScore = (365 - ageDays.clamp(0, 365)) / 14;
  final DateTime? releaseDate = _tryParseDate(item.releaseDate);
  final double releaseScore = releaseDate == null
      ? 0
      : (releaseDate.isAfter(now) ? 8 : 4);
  return sourceScore + voteScore + freshnessScore + releaseScore;
}

String _watchNextReason(_TrackedLibraryItem item, DateTime now) {
  if (item.sourceLabels.contains('Watchlist')) {
    final int age = now.difference(item.addedAt).inDays;
    if (age >= kStaleWatchlistDays) {
      return 'Sitting in your watchlist for $age days';
    }
    return 'Already on your watchlist';
  }
  if (item.sourceLabels.contains('Favourites')) {
    return 'You favourited this but have not marked it watched yet';
  }
  if (item.sourceLabels.contains('Lists')) {
    return 'Saved in one of your lists and ready to watch';
  }
  return 'Matches titles you already track';
}
