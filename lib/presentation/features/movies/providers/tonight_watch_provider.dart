import 'dart:convert';
import 'dart:math' as math;
import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_genre.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/domain/usecases/discover_media_use_case.dart';
import 'package:cineverse/presentation/features/movies/models/tonight_watch_models.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ValueNotifier<TonightRecommendationProgressState>
todayRecommendationProgressNotifier =
    ValueNotifier<TonightRecommendationProgressState>(
      const TonightRecommendationProgressState.initial(),
    );
final ValueNotifier<List<String>> todayRecommendationPlanNotifier =
    ValueNotifier<List<String>>(<String>[]);

final tonightPromptRecommendationsProvider = FutureProvider.autoDispose
    .family<TonightPromptResult, TonightPromptRequest>((ref, request) async {
      final String prompt = request.prompt.trim();
      if (prompt.length < 4) {
        throw StateError(
          'Please describe what you want in a little more detail.',
        );
      }

      final MediaRepository repository = ref.watch(mediaRepositoryProvider);
      final DiscoverMediaUseCase discoverUseCase = DiscoverMediaUseCase(
        repository,
      );
      final AppConfig appConfig = ref.watch(appConfigProvider);
      _progressReset();
      _progressAdd('Setting up your request');

      if (appConfig.hasTonightRecommendationsApiUrl) {
        _progressAdd('Connecting to the recommendation engine');
        return _recommendWithFirebaseRecommendationService(
          request: request,
          repository: repository,
          appConfig: appConfig,
        );
      }

      if (!appConfig.hasOpenRouterApiKey) {
        throw StateError(
          'OPENROUTER_API_KEY is missing. Add it in your dart-define config.',
        );
      }

      _progressAdd('Understanding your taste and mood');
      final _PromptPlan plan = await _planPromptWithOpenRouter(
        prompt: prompt,
        isTv: request.isTv,
        apiKey: appConfig.openRouterApiKey,
      );
      todayRecommendationPlanNotifier.value = <String>[
        if (plan.includeGenres.isNotEmpty)
          'Include genres: ${plan.includeGenres.take(3).join(', ')}',
        if (plan.excludeGenres.isNotEmpty)
          'Exclude genres: ${plan.excludeGenres.take(3).join(', ')}',
        if ((plan.originalLanguage ?? '').isNotEmpty)
          'Language: ${plan.originalLanguage}',
        if (plan.keywords.isNotEmpty)
          'Keywords: ${plan.keywords.take(4).join(', ')}',
        if (plan.similarTitles.isNotEmpty)
          'Similar to: ${plan.similarTitles.take(2).join(', ')}',
      ];
      _progressAdd('Built your search plan');
      _progressAdd('Scanning TMDB for strong matches');

      final List<MovieGenre> genres = request.isTv
          ? await repository.fetchTvGenres()
          : await repository.fetchMovieGenres();
      final _GenreResolution genreResolution = _resolveGenres(
        genres: genres,
        includeNames: plan.includeGenres,
        excludeNames: plan.excludeGenres,
      );

      final List<MediaTitle> rawCandidates = await _collectCandidates(
        request: request,
        plan: plan,
        discoverUseCase: discoverUseCase,
        repository: repository,
        availableGenreIds: genreResolution.includedGenreIds,
      );

      if (rawCandidates.isEmpty) {
        final String mediaType = request.isTv ? 'shows' : 'movies';
        throw StateError(
          'Could not find enough TMDB $mediaType for that request.',
        );
      }

      final List<_ScoredTonightItem> scored = await _rankCandidates(
        request: request,
        plan: plan,
        repository: repository,
        rawCandidates: rawCandidates,
        excludedGenres: genreResolution.excludedGenreNames,
      );

      if (scored.isEmpty) {
        throw StateError(
          'We found candidates, but none survived the final quality filters.',
        );
      }

      final List<TonightRecommendationItem> recommendations = scored
          .take(12)
          .map(
            (_ScoredTonightItem item) => TonightRecommendationItem(
              title: item.title,
              details: item.details,
              matchReason: item.matchReason,
              score: item.score,
            ),
          )
          .toList(growable: false);

      return TonightPromptResult(
        interpretedIntent: plan.intentSummary.isNotEmpty
            ? plan.intentSummary
            : _fallbackIntentSummary(plan: plan, prompt: prompt),
        recommendations: recommendations,
        queryPlanChips: <String>[
          if (plan.includeGenres.isNotEmpty)
            'Include genres: ${plan.includeGenres.take(3).join(', ')}',
          if (plan.excludeGenres.isNotEmpty)
            'Exclude genres: ${plan.excludeGenres.take(3).join(', ')}',
          if ((plan.originalLanguage ?? '').isNotEmpty)
            'Language: ${plan.originalLanguage}',
          if (plan.keywords.isNotEmpty)
            'Keywords: ${plan.keywords.take(4).join(', ')}',
          if (plan.similarTitles.isNotEmpty)
            'Similar to: ${plan.similarTitles.take(2).join(', ')}',
        ],
      );
    });

Future<TonightPromptResult> _recommendWithFirebaseRecommendationService({
  required TonightPromptRequest request,
  required MediaRepository repository,
  required AppConfig appConfig,
}) async {
  final String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  final Dio recommendationDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 70),
      sendTimeout: const Duration(seconds: 15),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (idToken != null && idToken.isNotEmpty)
          'Authorization': 'Bearer $idToken',
      },
    ),
  );

  try {
    Response<Map<String, dynamic>>? response;
    const int maxAttempts = 4;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      _progressAdd('Building your personalized search ($attempt/$maxAttempts)');
      try {
        response = await recommendationDio.post<Map<String, dynamic>>(
          appConfig.tonightRecommendationsApiUrl.trim(),
          data: <String, dynamic>{
            'prompt': request.prompt,
            'isTv': request.isTv,
            'topK': 12,
          },
        );
        break;
      } on DioException catch (error) {
        final int? status = error.response?.statusCode;
        final bool timeoutLike =
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError;
        final bool retryable =
            timeoutLike || status == 429 || (status != null && status >= 500);
        if (!retryable || attempt >= maxAttempts) {
          rethrow;
        }
        final int backoffSeconds = attempt * 2;
        _progressAdd(
          'Network hiccup, trying again in ${backoffSeconds}s',
          isRetry: true,
        );
        await Future<void>.delayed(Duration(seconds: backoffSeconds));
      }
    }
    if (response == null) {
      throw StateError('Recommendation request failed before response.');
    }
    final Map<String, dynamic>? payload = response.data;
    final String? backendProgressMessage =
        _recommendationBackendProgressMessage(payload);
    if (backendProgressMessage != null) {
      _progressAdd(backendProgressMessage);
    }
    _progressAdd('Search plan is ready');
    todayRecommendationPlanNotifier.value =
        _recommendationServiceQueryPlanChips(payload);
    final List<dynamic> rawResults =
        payload?['results'] as List<dynamic>? ?? <dynamic>[];
    if (rawResults.isEmpty) {
      throw StateError(
        'The recommendation service returned no matches. Try a broader request.',
      );
    }
    _progressAdd('Collecting details for top matches');

    final List<dynamic> shortlist = rawResults.take(12).toList(growable: false);
    final List<TonightRecommendationItem> recommendations =
        <TonightRecommendationItem>[];
    for (int i = 0; i < shortlist.length; i++) {
      _progressAdd('Verifying pick ${i + 1}/${shortlist.length}');
      final TonightRecommendationItem? item =
          await _buildRecommendationServiceItem(
            raw: shortlist[i],
            repository: repository,
            isTv: request.isTv,
          );
      if (item != null) {
        recommendations.add(item);
      }
    }

    if (recommendations.isEmpty) {
      throw StateError(
        'The recommendation service returned matches, but TMDB details failed for every result. '
        'Check TMDB proxy/API access.',
      );
    }
    _progressAdd('Finalizing your watchlist for tonight');
    return TonightPromptResult(
      interpretedIntent: _recommendationServiceIntentSummary(
        payload,
        request.prompt,
      ),
      recommendations: recommendations,
      queryPlanChips: _recommendationServiceQueryPlanChips(payload),
    );
  } on DioException catch (error) {
    final dynamic responseData = error.response?.data;
    String serverMessage = '';
    if (responseData is Map<String, dynamic>) {
      serverMessage = _readString(responseData['error']);
    } else if (responseData is String) {
      serverMessage = responseData.trim();
    }
    final int? statusCode = error.response?.statusCode;
    throw StateError(
      serverMessage.isNotEmpty
          ? 'Recommendation service error'
                '${statusCode != null ? ' ($statusCode)' : ''}: $serverMessage'
          : 'Could not reach the recommendation service. Dio error: ${error.message}',
    );
  } on StateError {
    rethrow;
  } catch (_) {
    throw StateError('The recommendation service failed unexpectedly.');
  }
}

@immutable
class TonightRecommendationProgressState {
  const TonightRecommendationProgressState({required this.events});

  const TonightRecommendationProgressState.initial()
    : events = const <RecommendationProgressEvent>[];

  final List<RecommendationProgressEvent> events;

  String get currentMessage =>
      events.isEmpty ? 'Starting recommendation flow...' : events.last.message;
}

@immutable
class RecommendationProgressEvent {
  const RecommendationProgressEvent({
    required this.message,
    required this.timestamp,
    required this.isRetry,
  });

  final String message;
  final DateTime timestamp;
  final bool isRetry;
}

void _progressReset() {
  todayRecommendationProgressNotifier.value =
      const TonightRecommendationProgressState.initial();
  todayRecommendationPlanNotifier.value = <String>[];
}

void _progressAdd(String message, {bool isRetry = false}) {
  final List<RecommendationProgressEvent> next =
      List<RecommendationProgressEvent>.from(
        todayRecommendationProgressNotifier.value.events,
      )..add(
        RecommendationProgressEvent(
          message: message,
          timestamp: DateTime.now(),
          isRetry: isRetry,
        ),
      );
  if (next.length > 16) {
    next.removeRange(0, next.length - 16);
  }
  todayRecommendationProgressNotifier.value =
      TonightRecommendationProgressState(events: next);
}

Future<TonightRecommendationItem?> _buildRecommendationServiceItem({
  required dynamic raw,
  required MediaRepository repository,
  required bool isTv,
}) async {
  if (raw is! Map<String, dynamic>) {
    return null;
  }
  final int? id = _readInt(raw['id']);
  if (id == null || id <= 0) {
    return null;
  }
  try {
    final MovieDetails details = await repository.fetchMovieDetails(
      id,
      isTv: isTv,
    );
    final MediaTitle title = MediaTitle(
      id: details.id,
      title: details.title,
      posterPath: details.posterPath,
      releaseDate: details.releaseDate,
      voteAverage: details.catalogScore,
      voteCount: details.voteCount ?? 0,
    );
    return TonightRecommendationItem(
      title: title,
      details: details,
      matchReason: _readString(raw['reason']).isNotEmpty
          ? _readString(raw['reason'])
          : 'Matched by the Firebase recommendation index.',
      score: _readDouble(raw['score']) ?? 0,
    );
  } catch (error) {
    debugPrint('Failed to hydrate recommendation service result $id: $error');
    return null;
  }
}

String _recommendationServiceIntentSummary(
  Map<String, dynamic>? payload,
  String fallbackPrompt,
) {
  final String backendLabel = _recommendationBackendLabel(payload);
  final Map<String, dynamic> criteria =
      payload?['criteria'] as Map<String, dynamic>? ?? <String, dynamic>{};
  final List<String> chips = <String>[];
  final String language = _readString(criteria['language']);
  if (language.isNotEmpty) {
    chips.add('language $language');
  }
  final List<String> includeGenres = _readStringList(criteria['includeGenres']);
  if (includeGenres.isNotEmpty) {
    chips.add('genres ${includeGenres.join(', ')}');
  }
  final List<String> excludeGenres = _readStringList(criteria['excludeGenres']);
  if (excludeGenres.isNotEmpty) {
    chips.add('avoiding ${excludeGenres.join(', ')}');
  }
  final int? maxRuntime = _readInt(criteria['maxRuntimeMinutes']);
  if (maxRuntime != null) {
    chips.add('under $maxRuntime min');
  }
  if (chips.isEmpty) {
    return '$backendLabel for "$fallbackPrompt"';
  }
  return '$backendLabel using ${chips.join(' • ')}.';
}

List<String> _recommendationServiceQueryPlanChips(
  Map<String, dynamic>? payload,
) {
  final Map<String, dynamic> criteria =
      payload?['criteria'] as Map<String, dynamic>? ?? <String, dynamic>{};
  final Map<String, dynamic> diagnostics =
      payload?['diagnostics'] as Map<String, dynamic>? ?? <String, dynamic>{};

  final List<String> chips = <String>[];
  chips.add('Backend: ${_recommendationBackendChipLabel(payload)}');
  final String language = _readString(criteria['language']);
  final List<String> includeGenres = _readStringList(criteria['includeGenres']);
  final List<String> excludeGenres = _readStringList(criteria['excludeGenres']);
  final int? maxRuntime = _readInt(criteria['maxRuntimeMinutes']);
  final int? minRuntime = _readInt(criteria['minRuntimeMinutes']);
  final int? yearFrom = _readInt(criteria['yearFrom']);
  final int? yearTo = _readInt(criteria['yearTo']);

  if (includeGenres.isNotEmpty) {
    chips.add('Include genres: ${includeGenres.take(4).join(', ')}');
  }
  if (excludeGenres.isNotEmpty) {
    chips.add('Exclude genres: ${excludeGenres.take(4).join(', ')}');
  }
  if (language.isNotEmpty) {
    chips.add('Language: $language');
  }
  if (maxRuntime != null || minRuntime != null) {
    if (minRuntime != null && maxRuntime != null) {
      chips.add('Runtime: $minRuntime-$maxRuntime min');
    } else if (maxRuntime != null) {
      chips.add('Runtime <= $maxRuntime min');
    } else {
      chips.add('Runtime >= $minRuntime min');
    }
  }
  if (yearFrom != null || yearTo != null) {
    if (yearFrom != null && yearTo != null) {
      chips.add('Year: $yearFrom-$yearTo');
    } else if (yearFrom != null) {
      chips.add('Year >= $yearFrom');
    } else {
      chips.add('Year <= $yearTo');
    }
  }

  final int? queryVariantsUsed = _readInt(diagnostics['queryVariantsUsed']);
  final int? candidateCount = _readInt(diagnostics['candidateCount']);
  final String stage = _readString(diagnostics['stage']);
  final bool relaxed = diagnostics['relaxed'] == true;
  if (queryVariantsUsed != null) {
    chips.add('Query variants: $queryVariantsUsed');
  }
  if (candidateCount != null) {
    chips.add('Candidates: $candidateCount');
  }
  if (stage.isNotEmpty) {
    chips.add('Stage: $stage${relaxed ? ' (relaxed)' : ''}');
  }

  return chips;
}

String _recommendationBackendLabel(Map<String, dynamic>? payload) {
  final Map<String, dynamic>? diagnostics =
      payload?['diagnostics'] as Map<String, dynamic>?;
  final String resolved = _readString(
    diagnostics?['vectorBackendResolved'],
  ).toLowerCase();
  if (resolved.contains('zilliz')) {
    return 'Zilliz vector search';
  }
  if (resolved.contains('qdrant')) {
    return 'Qdrant vector search';
  }
  if (resolved.contains('firestore')) {
    return 'Firebase vector search';
  }
  return 'Recommendation vector search';
}

String _recommendationBackendChipLabel(Map<String, dynamic>? payload) {
  final Map<String, dynamic>? diagnostics =
      payload?['diagnostics'] as Map<String, dynamic>?;
  final String resolved = _readString(
    diagnostics?['vectorBackendResolved'],
  ).toLowerCase();
  if (resolved.contains('zilliz')) {
    return 'Zilliz';
  }
  if (resolved.contains('qdrant')) {
    return 'Qdrant';
  }
  if (resolved.contains('firestore')) {
    return 'Firebase';
  }
  return 'Unknown';
}

String? _recommendationBackendProgressMessage(Map<String, dynamic>? payload) {
  final Map<String, dynamic>? diagnostics =
      payload?['diagnostics'] as Map<String, dynamic>?;
  final String resolved = _readString(
    diagnostics?['vectorBackendResolved'],
  ).toLowerCase();
  final String requested = _readString(
    diagnostics?['vectorBackendRequested'],
  ).toLowerCase();

  if (resolved.contains('qdrant') && requested.contains('zilliz')) {
    return 'Zilliz took too long, switched to Qdrant to keep things moving';
  }
  if (resolved.contains('firestore') && requested.contains('zilliz')) {
    return 'Zilliz and Qdrant were unavailable, switched to Firebase fallback';
  }
  if (resolved.contains('firestore') && requested.contains('qdrant')) {
    return 'Qdrant was unavailable, switched to Firebase fallback';
  }
  return null;
}

Future<_PromptPlan> _planPromptWithOpenRouter({
  required String prompt,
  required bool isTv,
  required String apiKey,
}) async {
  const List<String> plannerModels = <String>[
    'openrouter/free',
    'deepseek/deepseek-v4-flash:free',
    'qwen/qwen3-32b:free',
    'mistralai/mistral-small-3.2-24b-instruct:free',
    'meta-llama/llama-3.3-70b-instruct:free',
  ];
  final Dio llmDio = Dio(
    BaseOptions(
      baseUrl: 'https://openrouter.ai/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 15),
      headers: <String, String>{
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final String mediaType = isTv ? 'TV shows' : 'movies';

  for (final String model in plannerModels) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'model': model,
      'temperature': 0.2,
      'response_format': <String, dynamic>{'type': 'json_object'},
      'messages': <Map<String, dynamic>>[
        <String, dynamic>{
          'role': 'system',
          'content':
              'You are a movie recommendation query planner. Output only strict JSON with no markdown. '
              'Schema: {"intent_summary": string, "original_language": string|null, '
              '"include_genres": string[], "exclude_genres": string[], '
              '"min_runtime": int|null, "max_runtime": int|null, '
              '"min_vote_average": number|null, "min_vote_count": int|null, '
              '"year_from": int|null, "year_to": int|null, '
              '"keywords": string[], "similar_titles": string[], "avoid_titles": string[]}. '
              'Keep values practical for TMDB search and respect exclusions. '
              'When user says not/without/avoid, always populate exclusion fields. '
              'Use canonical TMDB genre names (for example: Science Fiction, not sci-fi).',
        },
        <String, dynamic>{
          'role': 'user',
          'content':
              'User wants $mediaType. Request: "$prompt". Return the JSON now.',
        },
      ],
    };

    try {
      final Response<Map<String, dynamic>> response = await llmDio
          .post<Map<String, dynamic>>('/chat/completions', data: payload);
      final String content = _readOpenRouterContent(response.data);
      final Map<String, dynamic> json = _decodePossiblyWrappedJson(content);
      return _PromptPlan.fromJson(json);
    } on DioException catch (error) {
      debugPrint('Planner model failed ($model): ${error.message}');
      continue;
    } catch (error) {
      debugPrint('Planner model failed ($model): $error');
      continue;
    }
  }

  return _PromptPlan.fallback(prompt);
}

String _readOpenRouterContent(Map<String, dynamic>? payload) {
  final List<dynamic> choices =
      payload?['choices'] as List<dynamic>? ?? <dynamic>[];
  if (choices.isEmpty) {
    return '{}';
  }
  final Map<String, dynamic>? firstChoice =
      choices.first as Map<String, dynamic>?;
  final Map<String, dynamic>? message =
      firstChoice?['message'] as Map<String, dynamic>?;
  final String content = (message?['content'] as String? ?? '').trim();
  return content;
}

Map<String, dynamic> _decodePossiblyWrappedJson(String content) {
  String normalized = content.trim();
  if (normalized.startsWith('```')) {
    normalized = normalized
        .replaceAll('```json', '')
        .replaceAll('```JSON', '')
        .replaceAll('```', '')
        .trim();
  }
  if (normalized.isEmpty) {
    return <String, dynamic>{};
  }
  final Object decoded = jsonDecode(normalized);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  return <String, dynamic>{};
}

Future<List<MediaTitle>> _collectCandidates({
  required TonightPromptRequest request,
  required _PromptPlan plan,
  required DiscoverMediaUseCase discoverUseCase,
  required MediaRepository repository,
  required Set<int> availableGenreIds,
}) async {
  final List<MediaTitle> candidates = <MediaTitle>[];
  final Set<int> seenIds = <int>{};
  final bool regionalLanguage =
      (plan.originalLanguage ?? '').isNotEmpty && plan.originalLanguage != 'en';

  final List<_DiscoveryStep> steps = <_DiscoveryStep>[
    _DiscoveryStep(
      pages: 2,
      query: plan.keywords.isNotEmpty ? plan.keywords.first : null,
      filter: _buildFilter(
        plan: plan,
        availableGenreIds: availableGenreIds,
        originalLanguage: plan.originalLanguage,
        minVotes: regionalLanguage ? 8 : 40,
        runtimePadding: 10,
        minScore: plan.minVoteAverage ?? (regionalLanguage ? 5.2 : 5.8),
      ),
      stopIfAtLeast: 10,
    ),
    _DiscoveryStep(
      pages: 3,
      query: plan.queryHint,
      filter: _buildFilter(
        plan: plan,
        availableGenreIds: availableGenreIds,
        originalLanguage: plan.originalLanguage,
        minVotes: regionalLanguage ? 4 : 20,
        runtimePadding: 26,
        minScore: plan.minVoteAverage ?? 5.0,
      ),
      stopIfAtLeast: 20,
    ),
    _DiscoveryStep(
      pages: 3,
      query: plan.keywords.length > 1 ? plan.keywords[1] : null,
      filter: _buildFilter(
        plan: plan,
        availableGenreIds: availableGenreIds,
        originalLanguage: plan.originalLanguage,
        minVotes: 0,
        runtimePadding: 40,
        minScore: 0,
      ),
      stopIfAtLeast: 30,
    ),
  ];

  for (final _DiscoveryStep step in steps) {
    for (int page = 1; page <= step.pages; page++) {
      final List<MediaTitle> pageResults = await discoverUseCase(
        DiscoverMediaParams(
          isTv: request.isTv,
          filter: step.filter,
          query: step.query,
          page: page,
        ),
      );
      _appendUnique(candidates, pageResults, seenIds);
      if (pageResults.length < 20 || candidates.length >= 36) {
        break;
      }
    }
    if (candidates.length >= step.stopIfAtLeast) {
      break;
    }
  }

  if (candidates.length < 14) {
    final Iterable<String> titleSeeds = plan.similarTitles.take(3);
    for (final String seed in titleSeeds) {
      final List<MediaTitle> searchResults = request.isTv
          ? await repository.searchTvShows(seed, page: 1)
          : await repository.searchMovies(seed, page: 1);
      _appendUnique(candidates, searchResults.take(8), seenIds);

      if (candidates.length < 24) {
        for (final MediaTitle match in searchResults.take(2)) {
          try {
            final List<MovieRecommendation> recs = await repository
                .fetchMovieRecommendations(match.id, isTv: request.isTv);
            _appendUnique(
              candidates,
              recs.map((MovieRecommendation r) => r.toMediaTitle()),
              seenIds,
            );
          } catch (_) {
            // Best-effort enrichment.
          }
        }
      }
    }
  }

  if (candidates.length < 12) {
    for (final int seedId in plan.numericSeeds.take(3)) {
      try {
        final List<MovieRecommendation> recs = await repository
            .fetchMovieRecommendations(seedId, isTv: request.isTv);
        _appendUnique(
          candidates,
          recs.map((MovieRecommendation r) => r.toMediaTitle()),
          seenIds,
        );
      } catch (_) {
        // Best-effort enrichment.
      }
    }
  }

  candidates.sort((a, b) => _roughScore(b).compareTo(_roughScore(a)));
  return candidates;
}

MediaFilter _buildFilter({
  required _PromptPlan plan,
  required Set<int> availableGenreIds,
  required String? originalLanguage,
  required int minVotes,
  required int runtimePadding,
  required double minScore,
}) {
  final int minRuntime = math.max(0, (plan.minRuntime ?? 0) - runtimePadding);
  final int maxRuntime = (plan.maxRuntime ?? 220) + runtimePadding;

  final Set<int> clampedGenres = availableGenreIds;

  return MediaFilter(
    sortField: SortField.popularity,
    sortOrder: SortOrder.descending,
    originalLanguageCode: originalLanguage,
    genres: clampedGenres,
    runtime: RangeValues(minRuntime.toDouble(), maxRuntime.toDouble()),
    userScore: RangeValues(minScore, 10),
    releaseDateFrom: plan.yearFrom != null ? DateTime(plan.yearFrom!) : null,
    releaseDateTo: plan.yearTo != null ? DateTime(plan.yearTo!) : null,
    minUserVotes: minVotes > 0 ? math.max(minVotes, plan.minVoteCount ?? 0) : 0,
    includeNotRated: minVotes == 0,
  );
}

Future<List<_ScoredTonightItem>> _rankCandidates({
  required TonightPromptRequest request,
  required _PromptPlan plan,
  required MediaRepository repository,
  required List<MediaTitle> rawCandidates,
  required Set<String> excludedGenres,
}) async {
  final List<_ScoredTonightItem> scored = <_ScoredTonightItem>[];
  final Iterable<MediaTitle> shortlist = rawCandidates.take(24);

  for (final MediaTitle candidate in shortlist) {
    try {
      final MovieDetails details = await repository.fetchMovieDetails(
        candidate.id,
        isTv: request.isTv,
      );

      final Set<String> titleGenres = details.genres
          .map(_canonicalGenreToken)
          .where((String g) => g.isNotEmpty)
          .toSet();

      if (excludedGenres.isNotEmpty &&
          titleGenres.intersection(excludedGenres).isNotEmpty) {
        continue;
      }

      final String? language = details.originalLanguage?.toLowerCase();
      final bool languageMatch =
          plan.originalLanguage == null ||
          plan.originalLanguage!.isEmpty ||
          language == plan.originalLanguage;

      final int runtime = details.runtimeMinutes ?? 0;
      final bool runtimeRoughMatch = _runtimeMatches(runtime, plan);

      final double score = _computeScore(
        title: candidate,
        details: details,
        plan: plan,
        languageMatch: languageMatch,
        runtimeMatch: runtimeRoughMatch,
      );

      scored.add(
        _ScoredTonightItem(
          title: candidate,
          details: details,
          score: score,
          matchReason: _buildMatchReason(
            details: details,
            plan: plan,
            languageMatch: languageMatch,
            runtimeMatch: runtimeRoughMatch,
          ),
        ),
      );
    } catch (_) {
      // Skip broken details to keep flow resilient.
    }
  }

  scored.sort((a, b) => b.score.compareTo(a.score));
  return scored;
}

double _computeScore({
  required MediaTitle title,
  required MovieDetails details,
  required _PromptPlan plan,
  required bool languageMatch,
  required bool runtimeMatch,
}) {
  final double rating = details.catalogScore ?? title.voteAverage ?? 0;
  final double popularityBoost = math.min(title.popularity, 400) / 28;
  final double voteBoost =
      math.min((details.voteCount ?? title.voteCount).toDouble(), 7000) / 650;
  final double languageBoost = languageMatch ? 12 : -3;
  final double runtimeBoost = runtimeMatch ? 8 : -4;
  final bool hasArtwork =
      details.posterPath != null || details.backdropPath != null;
  final double artworkBoost = hasArtwork ? 2 : 0;
  return (rating * 11) +
      popularityBoost +
      voteBoost +
      languageBoost +
      runtimeBoost +
      artworkBoost;
}

bool _runtimeMatches(int runtime, _PromptPlan plan) {
  if (runtime <= 0) {
    return true;
  }
  final int minRuntime = plan.minRuntime ?? 0;
  final int maxRuntime = plan.maxRuntime ?? 260;
  return runtime >= (minRuntime - 20) && runtime <= (maxRuntime + 20);
}

String _buildMatchReason({
  required MovieDetails details,
  required _PromptPlan plan,
  required bool languageMatch,
  required bool runtimeMatch,
}) {
  final List<String> parts = <String>[];
  if (languageMatch &&
      plan.originalLanguage != null &&
      plan.originalLanguage!.isNotEmpty) {
    parts.add('Original language matches');
  }
  if (runtimeMatch && details.runtimeMinutes != null) {
    parts.add('Runtime fits (${details.runtimeMinutes} min)');
  }
  if (details.genres.isNotEmpty) {
    parts.add('Genre fit: ${details.genres.take(2).join(' + ')}');
  }
  final double? score = details.catalogScore;
  if (score != null && score > 0) {
    parts.add('Strong rating (${score.toStringAsFixed(1)}/10)');
  }
  return parts.isEmpty
      ? 'Good overall match for your request.'
      : parts.join(' • ');
}

String _fallbackIntentSummary({
  required _PromptPlan plan,
  required String prompt,
}) {
  if (plan.queryHint.isNotEmpty) {
    return plan.queryHint;
  }
  return prompt.trim();
}

void _appendUnique(
  List<MediaTitle> target,
  Iterable<MediaTitle> incoming,
  Set<int> seenIds,
) {
  for (final MediaTitle title in incoming) {
    if (seenIds.add(title.id)) {
      target.add(title);
    }
  }
}

double _roughScore(MediaTitle title) {
  final double rating = title.voteAverage ?? 0;
  final double popularityBoost = math.min(title.popularity, 300) / 25;
  final double voteBoost = math.min(title.voteCount, 6000) / 700;
  return (rating * 9) + popularityBoost + voteBoost;
}

class _DiscoveryStep {
  const _DiscoveryStep({
    required this.filter,
    required this.pages,
    required this.stopIfAtLeast,
    this.query,
  });

  final MediaFilter filter;
  final int pages;
  final int stopIfAtLeast;
  final String? query;
}

class _GenreResolution {
  const _GenreResolution({
    required this.includedGenreIds,
    required this.excludedGenreNames,
  });

  final Set<int> includedGenreIds;
  final Set<String> excludedGenreNames;
}

_GenreResolution _resolveGenres({
  required List<MovieGenre> genres,
  required List<String> includeNames,
  required List<String> excludeNames,
}) {
  final Map<String, int> index = <String, int>{};
  final Map<String, int> canonicalIndex = <String, int>{};
  for (final MovieGenre genre in genres) {
    final String normalized = _normalizeText(genre.name);
    final String canonical = _canonicalGenreToken(genre.name);
    if (normalized.isNotEmpty) {
      index[normalized] = genre.id;
    }
    if (canonical.isNotEmpty) {
      canonicalIndex[canonical] = genre.id;
    }
  }

  final Set<int> includedIds = <int>{};
  for (final String genreName in includeNames) {
    final String needle = _canonicalGenreToken(genreName);
    if (needle.isEmpty) {
      continue;
    }
    if (canonicalIndex.containsKey(needle)) {
      includedIds.add(canonicalIndex[needle]!);
      continue;
    }
    for (final MapEntry<String, int> entry in index.entries) {
      if (entry.key.contains(needle) || needle.contains(entry.key)) {
        includedIds.add(entry.value);
      }
    }
  }

  final Set<String> excludedNormalized = excludeNames
      .map(_canonicalGenreToken)
      .where((String value) => value.isNotEmpty)
      .toSet();

  return _GenreResolution(
    includedGenreIds: includedIds,
    excludedGenreNames: excludedNormalized,
  );
}

String _normalizeText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _canonicalGenreToken(String value) {
  final String normalized = _normalizeText(value);
  if (normalized.isEmpty) {
    return '';
  }
  return _genreAliasToCanonical[normalized] ?? normalized;
}

const Map<String, String> _genreAliasToCanonical = <String, String>{
  'science fiction': 'science fiction',
  'sci fi': 'science fiction',
  'sci-fi': 'science fiction',
  'scifi': 'science fiction',
  'sf': 'science fiction',
  'sci fi fantasy': 'science fiction',
  'sci-fi fantasy': 'science fiction',
  'rom com': 'comedy',
  'romcom': 'comedy',
  'romantic comedy': 'comedy',
  'romantic': 'romance',
  'love story': 'romance',
  'suspense': 'thriller',
  'suspenseful': 'thriller',
  'scary': 'horror',
  'animated': 'animation',
  'historical': 'history',
};

class _ScoredTonightItem {
  const _ScoredTonightItem({
    required this.title,
    required this.details,
    required this.score,
    required this.matchReason,
  });

  final MediaTitle title;
  final MovieDetails details;
  final double score;
  final String matchReason;
}

class _PromptPlan {
  const _PromptPlan({
    required this.intentSummary,
    required this.queryHint,
    required this.originalLanguage,
    required this.includeGenres,
    required this.excludeGenres,
    required this.keywords,
    required this.similarTitles,
    required this.numericSeeds,
    required this.minRuntime,
    required this.maxRuntime,
    required this.minVoteAverage,
    required this.minVoteCount,
    required this.yearFrom,
    required this.yearTo,
  });

  factory _PromptPlan.fromJson(Map<String, dynamic> json) {
    final List<String> keywords = _readStringList(json['keywords']);
    final List<String> similarTitles = _readStringList(json['similar_titles']);
    return _PromptPlan(
      intentSummary: _readString(json['intent_summary']),
      queryHint: _readString(json['query_hint']).isNotEmpty
          ? _readString(json['query_hint'])
          : _readString(json['intent_summary']),
      originalLanguage: _resolveLanguageCode(
        _readString(json['original_language']),
      ),
      includeGenres: _readStringList(json['include_genres']),
      excludeGenres: _readStringList(json['exclude_genres']),
      keywords: keywords,
      similarTitles: similarTitles,
      numericSeeds: _readNumericSeeds(similarTitles),
      minRuntime: _readInt(json['min_runtime']),
      maxRuntime: _readInt(json['max_runtime']),
      minVoteAverage: _readDouble(json['min_vote_average']),
      minVoteCount: _readInt(json['min_vote_count']),
      yearFrom: _readInt(json['year_from']),
      yearTo: _readInt(json['year_to']),
    );
  }

  factory _PromptPlan.fallback(String prompt) {
    final List<String> tokens = prompt
        .split(RegExp(r'[,.;]'))
        .map((String part) => part.trim())
        .where((String part) => part.length >= 4)
        .take(3)
        .toList(growable: false);
    return _PromptPlan(
      intentSummary: prompt,
      queryHint: prompt,
      originalLanguage: null,
      includeGenres: const <String>[],
      excludeGenres: const <String>[],
      keywords: tokens,
      similarTitles: const <String>[],
      numericSeeds: const <int>[],
      minRuntime: null,
      maxRuntime: null,
      minVoteAverage: null,
      minVoteCount: null,
      yearFrom: null,
      yearTo: null,
    );
  }

  final String intentSummary;
  final String queryHint;
  final String? originalLanguage;
  final List<String> includeGenres;
  final List<String> excludeGenres;
  final List<String> keywords;
  final List<String> similarTitles;
  final List<int> numericSeeds;
  final int? minRuntime;
  final int? maxRuntime;
  final double? minVoteAverage;
  final int? minVoteCount;
  final int? yearFrom;
  final int? yearTo;
}

String _readString(Object? value) {
  if (value is String) {
    return value.trim();
  }
  return '';
}

List<String> _readStringList(Object? value) {
  if (value is List<dynamic>) {
    return value
        .map((dynamic item) => item is String ? item.trim() : '')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }
  return const <String>[];
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

double? _readDouble(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

List<int> _readNumericSeeds(List<String> similarTitles) {
  final List<int> values = <int>[];
  for (final String title in similarTitles) {
    final int? maybeId = int.tryParse(title);
    if (maybeId != null && maybeId > 0) {
      values.add(maybeId);
    }
  }
  return values;
}

String? _resolveLanguageCode(String candidate) {
  final String normalized = candidate.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }
  if (normalized.length == 2) {
    return normalized;
  }

  const Map<String, String> aliases = <String, String>{
    'english': 'en',
    'hindi': 'hi',
    'tamil': 'ta',
    'telugu': 'te',
    'korean': 'ko',
    'japanese': 'ja',
    'spanish': 'es',
    'french': 'fr',
    'german': 'de',
  };
  return aliases[normalized];
}
