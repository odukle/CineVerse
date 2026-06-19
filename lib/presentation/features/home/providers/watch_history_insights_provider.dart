import 'dart:math' as math;

import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int kMinimumWatchedItemsForInsights = 15;

class GenreRatingInsight {
  const GenreRatingInsight({
    required this.genre,
    required this.averageRating,
    required this.watchedCount,
  });

  final String genre;
  final double averageRating;
  final int watchedCount;
}

class WatchHistoryInsights {
  const WatchHistoryInsights({
    required this.favoriteGenres,
    required this.averageRatingPerGenre,
    required this.preferredRuntimeLabel,
    required this.averageRuntimeMinutes,
    required this.insightsText,
    required this.analyzedTitlesCount,
    required this.generatedAt,
  });

  final List<String> favoriteGenres;
  final List<GenreRatingInsight> averageRatingPerGenre;
  final String preferredRuntimeLabel;
  final int averageRuntimeMinutes;
  final String insightsText;
  final int analyzedTitlesCount;
  final DateTime generatedAt;
}

final watchHistoryInsightsProvider = FutureProvider<WatchHistoryInsights?>((
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

  final repository = ref.watch(mediaRepositoryProvider);
  final List<_EnrichedWatchedItem> enriched = await _enrichWatchedItems(
    repository: repository,
    items: mediaItems.take(120).toList(growable: false),
  );
  if (enriched.isEmpty) {
    return null;
  }

  final Map<String, int> genreCounts = <String, int>{};
  final Map<String, _GenreRatingAccumulator> genreRatings =
      <String, _GenreRatingAccumulator>{};
  final List<int> runtimes = <int>[];

  for (final _EnrichedWatchedItem item in enriched) {
    final MovieDetails details = item.details;
    final int rating = item.item.rating;

    if (details.runtimeMinutes != null && details.runtimeMinutes! > 0) {
      runtimes.add(details.runtimeMinutes!);
    }

    for (final String genre in details.genres) {
      final String normalized = genre.trim();
      if (normalized.isEmpty) continue;

      genreCounts[normalized] = (genreCounts[normalized] ?? 0) + 1;
      if (rating > 0) {
        final _GenreRatingAccumulator accumulator =
            genreRatings[normalized] ?? const _GenreRatingAccumulator();
        genreRatings[normalized] = accumulator.add(rating);
      }
    }
  }

  final List<MapEntry<String, int>> favoriteGenres =
      genreCounts.entries.toList(growable: false)..sort((a, b) {
        final int countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        return a.key.compareTo(b.key);
      });

  final List<String> topFavoriteGenres = favoriteGenres
      .take(3)
      .map((MapEntry<String, int> e) => e.key)
      .toList(growable: false);

  final List<GenreRatingInsight> averageRatingPerGenre =
      genreRatings.entries
          .map((entry) {
            final _GenreRatingAccumulator stats = entry.value;
            return GenreRatingInsight(
              genre: entry.key,
              averageRating: stats.average,
              watchedCount: stats.count,
            );
          })
          .toList(growable: false)
        ..sort((a, b) {
          final int ratingCompare = b.averageRating.compareTo(a.averageRating);
          if (ratingCompare != 0) return ratingCompare;
          return b.watchedCount.compareTo(a.watchedCount);
        });

  final int averageRuntimeMinutes = runtimes.isEmpty
      ? 0
      : (runtimes.reduce((a, b) => a + b) / runtimes.length).round();
  final String preferredRuntimeLabel = _runtimeLabel(averageRuntimeMinutes);

  final String topGenresText = topFavoriteGenres.isEmpty
      ? 'a mix of genres'
      : topFavoriteGenres.join(', ');
  final GenreRatingInsight? topRatedGenre = averageRatingPerGenre.isEmpty
      ? null
      : averageRatingPerGenre.first;

  final String insightsText =
      'You mostly watch $topGenresText. '
      '${topRatedGenre == null ? '' : 'Your highest personal ratings are for ${topRatedGenre.genre} (${topRatedGenre.averageRating.toStringAsFixed(1)}/5). '}'
      '${averageRuntimeMinutes > 0 ? 'You usually finish titles around $averageRuntimeMinutes minutes, which suggests a $preferredRuntimeLabel preference.' : 'Keep watching more titles to unlock runtime preference insights.'}';

  return WatchHistoryInsights(
    favoriteGenres: topFavoriteGenres,
    averageRatingPerGenre: averageRatingPerGenre
        .take(5)
        .toList(growable: false),
    preferredRuntimeLabel: preferredRuntimeLabel,
    averageRuntimeMinutes: averageRuntimeMinutes,
    insightsText: insightsText,
    analyzedTitlesCount: enriched.length,
    generatedAt: DateTime.now(),
  );
});

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

String _runtimeLabel(int averageRuntimeMinutes) {
  if (averageRuntimeMinutes <= 0) return 'balanced';
  if (averageRuntimeMinutes <= 95) return 'short and snappy';
  if (averageRuntimeMinutes <= 125) return 'feature-length sweet spot';
  if (averageRuntimeMinutes <= 155) return 'long-form storytelling';
  return 'epic runtime';
}

class _EnrichedWatchedItem {
  const _EnrichedWatchedItem({required this.item, required this.details});

  final WatchedItem item;
  final MovieDetails details;
}

class _GenreRatingAccumulator {
  const _GenreRatingAccumulator({this.sum = 0, this.count = 0});

  final int sum;
  final int count;

  _GenreRatingAccumulator add(int rating) {
    return _GenreRatingAccumulator(sum: sum + rating, count: count + 1);
  }

  double get average => count == 0 ? 0 : sum / count;
}
