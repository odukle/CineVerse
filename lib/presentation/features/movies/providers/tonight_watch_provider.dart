import 'dart:math' as math;

import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/domain/usecases/discover_media_use_case.dart';
import 'package:cineverse/presentation/features/movies/models/tonight_watch_models.dart';
import 'package:cineverse/presentation/features/movies/providers/tonight_kaggle_engine_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tonightWatchRecommendationProvider = FutureProvider.autoDispose
    .family<TonightWatchResult, TonightWatchRequest>((ref, request) async {
      final MediaRepository repository = ref.watch(mediaRepositoryProvider);
      final TonightKaggleEngine kaggleEngine = await ref.watch(
        tonightKaggleEngineProvider.future,
      );
      final discoverUseCase = DiscoverMediaUseCase(repository);

      final List<MediaTitle> candidates = await _loadCandidates(
        discoverUseCase: discoverUseCase,
        repository: repository,
        kaggleEngine: kaggleEngine,
        request: request,
      );

      if (candidates.isEmpty) {
        final String typeLabel = request.isTv ? 'shows' : 'movies';
        throw StateError(
          'No $typeLabel matched that exact mix of time, mood, and language yet.',
        );
      }

      final List<MediaTitle> shortlist = candidates.take(6).toList();
      final List<_ScoredTonightPick> scoredPicks = <_ScoredTonightPick>[];

      for (final MediaTitle candidate in shortlist) {
        try {
          final MovieDetails details = await repository.fetchMovieDetails(
            candidate.id,
            isTv: request.isTv,
          );
          scoredPicks.add(
            _ScoredTonightPick(
              title: candidate,
              details: details,
              score: _scoreCandidate(
                title: candidate,
                details: details,
                request: request,
              ),
            ),
          );
        } catch (_) {
          // Skip detail failures so one bad title does not block the flow.
        }
      }

      if (scoredPicks.isEmpty) {
        throw StateError(
          'We found matches, but could not load the final pick right now.',
        );
      }

      scoredPicks.sort((a, b) => b.score.compareTo(a.score));
      final _ScoredTonightPick bestPick = _chooseBestPick(scoredPicks);

      return TonightWatchResult(
        title: bestPick.title,
        details: bestPick.details,
        explanation: _buildExplanation(
          request: request,
          title: bestPick.title,
          details: bestPick.details,
        ),
      );
    });

_ScoredTonightPick _chooseBestPick(List<_ScoredTonightPick> scoredPicks) {
  if (scoredPicks.length == 1) {
    return scoredPicks.first;
  }

  final double topScore = scoredPicks.first.score;
  final List<_ScoredTonightPick> topBand = scoredPicks
      .where((pick) => (topScore - pick.score) <= 3.0)
      .take(3)
      .toList(growable: false);

  if (topBand.length <= 1) {
    return scoredPicks.first;
  }

  final math.Random random = math.Random();
  return topBand[random.nextInt(topBand.length)];
}

Future<List<MediaTitle>> _loadCandidates({
  required DiscoverMediaUseCase discoverUseCase,
  required MediaRepository repository,
  required TonightKaggleEngine kaggleEngine,
  required TonightWatchRequest request,
}) async {
  final List<MediaTitle> kaggleFirst = await kaggleEngine.findCandidates(
    request: request,
  );
  if (kaggleFirst.isNotEmpty) {
    return kaggleFirst;
  }

  final List<MediaTitle> seedFirst = await _seedFallbackCandidates(
    repository: repository,
    request: request,
  );
  if (seedFirst.isNotEmpty) {
    return seedFirst;
  }

  final List<({MediaFilter filter, int minDesired})> filterPlan =
      <({MediaFilter filter, int minDesired})>[
        (
          filter: _buildFilter(
            request: request,
            minVotes: request.isTv ? 45 : 120,
            extraRuntimePadding: 0,
          ),
          minDesired: 3,
        ),
        (
          filter: _buildFilter(
            request: request,
            minVotes: request.isTv ? 25 : 70,
            extraRuntimePadding: 12,
          ),
          minDesired: 3,
        ),
        (
          filter: _buildFilter(
            request: request,
            minVotes: 10,
            extraRuntimePadding: 24,
          ),
          minDesired: 2,
        ),
        (
          filter: _buildFilter(
            request: request,
            minVotes: request.isTv ? 20 : 50,
            extraRuntimePadding: 24,
          ),
          minDesired: 3,
        ),
        (
          filter: _buildFilter(
            request: request,
            minVotes: 10,
            extraRuntimePadding: 32,
          ),
          minDesired: 2,
        ),
        (
          filter: _buildFilter(
            request: request,
            minVotes: 8,
            extraRuntimePadding: 38,
          ),
          minDesired: 1,
        ),
      ];

  for (final ({MediaFilter filter, int minDesired}) step in filterPlan) {
    final List<MediaTitle> collected = <MediaTitle>[];

    for (int page = 1; page <= 2; page++) {
      final List<MediaTitle> pageResults = await discoverUseCase(
        DiscoverMediaParams(
          isTv: request.isTv,
          filter: step.filter,
          page: page,
        ),
      );
      collected.addAll(pageResults);

      if (pageResults.length < 20) {
        break;
      }
    }

    final List<MediaTitle> unique = _uniqueTitles(collected);
    if (unique.length >= step.minDesired) {
      unique.sort((a, b) => _roughScore(b).compareTo(_roughScore(a)));
      return unique;
    }
  }

  return const <MediaTitle>[];
}

MediaFilter _buildFilter({
  required TonightWatchRequest request,
  required int minVotes,
  required int extraRuntimePadding,
}) {
  final int minRuntime = math.max(
    0,
    request.timeOption.minMinutes - extraRuntimePadding,
  );
  final int maxRuntime = request.timeOption.maxMinutes + extraRuntimePadding;
  const RangeValues scoreRange = RangeValues(6.0, 10.0);

  return MediaFilter(
    sortField: SortField.popularity,
    sortOrder: SortOrder.descending,
    originalLanguageCode: request.language.code,
    runtime: RangeValues(minRuntime.toDouble(), maxRuntime.toDouble()),
    mood: request.mood,
    userScore: scoreRange,
    minUserVotes: minVotes,
    includeNotRated: false,
  );
}

Future<List<MediaTitle>> _seedFallbackCandidates({
  required MediaRepository repository,
  required TonightWatchRequest request,
}) async {
  final List<int> seedIds = request.isTv
      ? request.mood.tvSeeds
      : request.mood.movieSeeds;
  if (seedIds.isEmpty) {
    return const <MediaTitle>[];
  }

  final List<MediaTitle> fallback = <MediaTitle>[];
  final int minRuntime = math.max(0, request.timeOption.minMinutes - 38);
  final int maxRuntime = request.timeOption.maxMinutes + 38;

  for (final int id in seedIds) {
    try {
      final MovieDetails details = await repository.fetchMovieDetails(
        id,
        isTv: request.isTv,
      );

      final String? originalLanguage = details.originalLanguage?.toLowerCase();
      if (originalLanguage != request.language.code) {
        continue;
      }

      final int runtimeMinutes =
          details.runtimeMinutes ??
          ((request.timeOption.minMinutes + request.timeOption.maxMinutes) ~/
              2);
      if (runtimeMinutes < minRuntime || runtimeMinutes > maxRuntime) {
        continue;
      }

      final double score = details.catalogScore ?? 0;
      if (score > 0 && score < 5.8) {
        continue;
      }
      final int votes = details.voteCount ?? 0;
      if (votes > 0 && votes < 8) {
        continue;
      }

      fallback.add(
        MediaTitle(
          id: details.id,
          title: details.title,
          posterPath: details.posterPath,
          releaseDate: details.releaseDate,
          voteAverage: details.catalogScore,
          voteCount: details.voteCount ?? 0,
          popularity: 0,
        ),
      );
    } catch (_) {
      // Skip problematic seeds.
    }
  }

  if (fallback.isEmpty) {
    return const <MediaTitle>[];
  }

  fallback.sort((a, b) => _roughScore(b).compareTo(_roughScore(a)));
  return fallback;
}

List<MediaTitle> _uniqueTitles(List<MediaTitle> titles) {
  final Set<int> seenIds = <int>{};
  final List<MediaTitle> unique = <MediaTitle>[];
  for (final MediaTitle title in titles) {
    if (seenIds.add(title.id)) {
      unique.add(title);
    }
  }
  return unique;
}

double _roughScore(MediaTitle title) {
  final double rating = title.voteAverage ?? 0;
  final double popularityBoost = math.min(title.popularity, 250) / 25;
  final double voteBoost = math.min(title.voteCount, 5000) / 500;
  return (rating * 10) + popularityBoost + voteBoost;
}

double _scoreCandidate({
  required MediaTitle title,
  required MovieDetails details,
  required TonightWatchRequest request,
}) {
  final double rating = details.catalogScore ?? title.voteAverage ?? 0;
  final double popularityBoost = math.min(title.popularity, 300) / 20;
  final double voteBoost =
      math.min((details.voteCount ?? title.voteCount).toDouble(), 8000) / 700;

  final int runtime =
      details.runtimeMinutes ??
      ((request.timeOption.minMinutes + request.timeOption.maxMinutes) ~/ 2);
  final double targetMidpoint =
      (request.timeOption.minMinutes + request.timeOption.maxMinutes) / 2;
  final double runtimeDistance = (runtime - targetMidpoint).abs();
  final double runtimeBoost = math.max(0, 18 - (runtimeDistance * 0.22));

  final bool matchesLanguage =
      details.originalLanguage?.toLowerCase() == request.language.code;
  final double languageBoost = matchesLanguage ? 12 : 0;

  final double artworkBoost =
      (details.backdropPath != null || details.posterPath != null) ? 3 : 0;

  return (rating * 11) +
      popularityBoost +
      voteBoost +
      runtimeBoost +
      languageBoost +
      artworkBoost;
}

String _buildExplanation({
  required TonightWatchRequest request,
  required MediaTitle title,
  required MovieDetails details,
}) {
  final List<String> parts = <String>[];
  final String typeLabel = request.isTv ? 'show' : 'movie';

  final int? runtime = details.runtimeMinutes;
  if (runtime != null) {
    parts.add(
      'It fits your ${request.timeOption.label(request.isTv).toLowerCase()} window at about $runtime minutes.',
    );
  } else {
    parts.add(
      'It lines up with the ${request.timeOption.label(request.isTv).toLowerCase()} time window you picked.',
    );
  }

  parts.add(
    'Its ${request.mood.label.toLowerCase()} energy makes it a strong late-night $typeLabel.',
  );

  if (details.originalLanguage?.toLowerCase() == request.language.code) {
    parts.add(
      'It is also a native ${request.language.label} pick, not a loose match.',
    );
  }

  if (details.genres.isNotEmpty) {
    final String genres = details.genres.take(2).join(' and ');
    parts.add(
      'The $genres blend keeps the vibe focused without feeling generic.',
    );
  }

  final double? score = details.catalogScore ?? title.voteAverage;
  if (score != null && score > 0) {
    parts.add(
      'It also brings a solid ${score.toStringAsFixed(1)}/10 audience score.',
    );
  }

  return parts.join(' ');
}

class _ScoredTonightPick {
  const _ScoredTonightPick({
    required this.title,
    required this.details,
    required this.score,
  });

  final MediaTitle title;
  final MovieDetails details;
  final double score;
}
