import 'dart:math' as math;

import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/presentation/features/home/providers/watch_history_insights_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthlyWatchCount {
  const MonthlyWatchCount({
    required this.month,
    required this.label,
    required this.count,
  });

  final DateTime month;
  final String label;
  final int count;
}

class GenreDistributionDatum {
  const GenreDistributionDatum({required this.genre, required this.count});

  final String genre;
  final int count;
}

class MonthlyRatingTrend {
  const MonthlyRatingTrend({
    required this.month,
    required this.label,
    required this.averageRating,
    required this.samples,
  });

  final DateTime month;
  final String label;
  final double averageRating;
  final int samples;
}

class WatchHistoryAnalytics {
  const WatchHistoryAnalytics({
    required this.moviesPerMonth,
    required this.genreDistribution,
    required this.ratingTrends,
    required this.analyzedTitlesCount,
    required this.generatedAt,
  });

  final List<MonthlyWatchCount> moviesPerMonth;
  final List<GenreDistributionDatum> genreDistribution;
  final List<MonthlyRatingTrend> ratingTrends;
  final int analyzedTitlesCount;
  final DateTime generatedAt;
}

final watchHistoryAnalyticsProvider = FutureProvider<WatchHistoryAnalytics?>((
  ref,
) async {
  final List<WatchedItem> watchedItems = await ref.watch(
    watchedItemsProvider.future,
  );
  final List<WatchedItem> mediaItems = watchedItems
      .where(
        (WatchedItem item) =>
            item.mediaType == GlobalMediaType.movie ||
            item.mediaType == GlobalMediaType.tv,
      )
      .toList(growable: false);

  if (mediaItems.length < kMinimumWatchedItemsForInsights) {
    return null;
  }

  final MediaRepository repository = ref.watch(mediaRepositoryProvider);
  final List<_EnrichedWatchedItem> enriched = await _enrichWatchedItems(
    repository: repository,
    items: mediaItems.take(160).toList(growable: false),
  );
  if (enriched.isEmpty) {
    return null;
  }

  final List<MonthlyWatchCount> moviesPerMonth = _buildMoviesPerMonth(enriched);
  final List<GenreDistributionDatum> genreDistribution =
      _buildGenreDistribution(enriched);
  final List<MonthlyRatingTrend> ratingTrends = _buildRatingTrends(enriched);

  return WatchHistoryAnalytics(
    moviesPerMonth: moviesPerMonth,
    genreDistribution: genreDistribution,
    ratingTrends: ratingTrends,
    analyzedTitlesCount: enriched.length,
    generatedAt: DateTime.now(),
  );
});

List<MonthlyWatchCount> _buildMoviesPerMonth(List<_EnrichedWatchedItem> items) {
  final Map<String, int> monthCounts = <String, int>{};
  for (final _EnrichedWatchedItem item in items) {
    if (item.item.mediaType != GlobalMediaType.movie) continue;
    final DateTime d = item.item.watchDate;
    final String key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
    monthCounts[key] = (monthCounts[key] ?? 0) + 1;
  }

  final List<MapEntry<String, int>> entries = monthCounts.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final List<MapEntry<String, int>> lastEntries = entries.length <= 12
      ? entries
      : entries.sublist(entries.length - 12);

  return lastEntries
      .map((entry) {
        final List<String> parts = entry.key.split('-');
        final int year = int.parse(parts[0]);
        final int month = int.parse(parts[1]);
        final DateTime date = DateTime(year, month);
        return MonthlyWatchCount(
          month: date,
          label: _monthLabel(date),
          count: entry.value,
        );
      })
      .toList(growable: false);
}

List<GenreDistributionDatum> _buildGenreDistribution(
  List<_EnrichedWatchedItem> items,
) {
  final Map<String, int> genreCounts = <String, int>{};
  for (final _EnrichedWatchedItem item in items) {
    for (final String rawGenre in item.details.genres) {
      final String genre = rawGenre.trim();
      if (genre.isEmpty) continue;
      genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
    }
  }

  final List<MapEntry<String, int>> sorted = genreCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  if (sorted.length <= 6) {
    return sorted
        .map(
          (entry) =>
              GenreDistributionDatum(genre: entry.key, count: entry.value),
        )
        .toList(growable: false);
  }

  final List<GenreDistributionDatum> topSix = sorted
      .take(6)
      .map(
        (entry) => GenreDistributionDatum(genre: entry.key, count: entry.value),
      )
      .toList(growable: false);
  final int othersCount = sorted
      .skip(6)
      .fold(0, (int sum, MapEntry<String, int> entry) => sum + entry.value);
  return <GenreDistributionDatum>[
    ...topSix,
    GenreDistributionDatum(genre: 'Others', count: othersCount),
  ];
}

List<MonthlyRatingTrend> _buildRatingTrends(List<_EnrichedWatchedItem> items) {
  final Map<String, _RatingAccumulator> monthRatings =
      <String, _RatingAccumulator>{};
  for (final _EnrichedWatchedItem item in items) {
    final DateTime d = item.item.watchDate;
    final String key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
    final _RatingAccumulator accumulator =
        monthRatings[key] ?? const _RatingAccumulator();
    monthRatings[key] = accumulator.add(item.item.rating);
  }

  final List<MapEntry<String, _RatingAccumulator>> entries =
      monthRatings.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  final List<MapEntry<String, _RatingAccumulator>> lastEntries =
      entries.length <= 12 ? entries : entries.sublist(entries.length - 12);

  return lastEntries
      .map((entry) {
        final List<String> parts = entry.key.split('-');
        final int year = int.parse(parts[0]);
        final int month = int.parse(parts[1]);
        final DateTime date = DateTime(year, month);
        return MonthlyRatingTrend(
          month: date,
          label: _monthLabel(date),
          averageRating: entry.value.average,
          samples: entry.value.count,
        );
      })
      .toList(growable: false);
}

Future<List<_EnrichedWatchedItem>> _enrichWatchedItems({
  required MediaRepository repository,
  required List<WatchedItem> items,
}) async {
  const int batchSize = 6;
  final List<_EnrichedWatchedItem> enriched = <_EnrichedWatchedItem>[];

  for (int i = 0; i < items.length; i += batchSize) {
    final int end = math.min(i + batchSize, items.length);
    final List<WatchedItem> batch = items.sublist(i, end);
    final List<_EnrichedWatchedItem?> batchResults = await Future.wait(
      batch.map((_fetchSingleDetail(repository))),
    );
    for (final _EnrichedWatchedItem? result in batchResults) {
      if (result != null) {
        enriched.add(result);
      }
    }
  }

  return enriched;
}

Future<_EnrichedWatchedItem?> Function(WatchedItem) _fetchSingleDetail(
  MediaRepository repository,
) {
  return (WatchedItem item) async {
    try {
      final bool isTv = item.mediaType == GlobalMediaType.tv;
      final MovieDetails details = await repository.fetchMovieDetails(
        item.id,
        isTv: isTv,
      );
      return _EnrichedWatchedItem(item: item, details: details);
    } catch (_) {
      return null;
    }
  };
}

String _monthLabel(DateTime date) {
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
  return months[date.month - 1];
}

class _EnrichedWatchedItem {
  const _EnrichedWatchedItem({required this.item, required this.details});

  final WatchedItem item;
  final MovieDetails details;
}

class _RatingAccumulator {
  const _RatingAccumulator({this.sum = 0, this.count = 0});

  final int sum;
  final int count;

  _RatingAccumulator add(int rating) {
    return _RatingAccumulator(sum: sum + rating, count: count + 1);
  }

  double get average => count == 0 ? 0 : sum / count;
}
