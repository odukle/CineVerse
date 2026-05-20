import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/movies/models/tonight_watch_models.dart';
import 'package:cineverse/presentation/features/movies/providers/tonight_watch_provider.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class WhatShouldIWatchTonightScreen extends ConsumerStatefulWidget {
  const WhatShouldIWatchTonightScreen({super.key, required this.isTv});

  final bool isTv;

  @override
  ConsumerState<WhatShouldIWatchTonightScreen> createState() =>
      _WhatShouldIWatchTonightScreenState();
}

class _WhatShouldIWatchTonightScreenState
    extends ConsumerState<WhatShouldIWatchTonightScreen> {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  final SpeechToText _speech = SpeechToText();
  TonightPromptRequest? _submittedRequest;
  int _requestNonce = 0;
  bool _isListening = false;
  bool _speechAvailable = false;
  String? _speechError;

  @override
  void dispose() {
    _speech.stop();
    _promptController.dispose();
    _promptFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<TonightPromptResult>? recommendations =
        _submittedRequest == null
        ? null
        : ref.watch(tonightPromptRecommendationsProvider(_submittedRequest!));

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _ChromeButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'What should I watch tonight?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _PromptPanel(
                  isTv: widget.isTv,
                  controller: _promptController,
                  focusNode: _promptFocusNode,
                  onSubmit: _runSearch,
                  onExampleTap: _useExamplePrompt,
                  isListening: _isListening,
                  speechAvailable: _speechAvailable,
                  speechError: _speechError,
                  onMicTap: _toggleVoiceInput,
                ),
                const SizedBox(height: 20),
                _buildResultState(recommendations),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultState(AsyncValue<TonightPromptResult>? recommendations) {
    if (recommendations == null) {
      return _EmptyState(isTv: widget.isTv);
    }
    return recommendations.when(
      loading: () => _LoadingState(request: _submittedRequest!),
      error: (Object error, StackTrace _) => _ErrorState(
        message: error.toString().replaceFirst('Bad state: ', ''),
        onRetry: _runSearch,
      ),
      data: (TonightPromptResult result) =>
          _ResultList(isTv: widget.isTv, result: result),
    );
  }

  void _runSearch() {
    final String prompt = _promptController.text.trim();
    if (prompt.length < 4) {
      _promptFocusNode.requestFocus();
      return;
    }

    final TonightPromptRequest request = TonightPromptRequest(
      isTv: widget.isTv,
      prompt: prompt,
      requestNonce: ++_requestNonce,
    );
    ref.invalidate(tonightPromptRecommendationsProvider(request));
    setState(() {
      _submittedRequest = request;
    });
  }

  void _useExamplePrompt(String prompt) {
    _promptController.text = prompt;
    _runSearch();
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _speech.stop();
      if (!mounted) {
        return;
      }
      setState(() {
        _isListening = false;
      });
      return;
    }

    setState(() {
      _speechError = null;
    });

    final bool available = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _speechError = error.errorMsg;
          _isListening = false;
        });
      },
    );

    if (!mounted) {
      return;
    }
    if (!available) {
      setState(() {
        _speechAvailable = false;
        _speechError = 'Speech recognition is not available on this device.';
      });
      return;
    }

    setState(() {
      _speechAvailable = true;
      _isListening = true;
    });

    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
      ),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
  }

  void _onSpeechStatus(String status) {
    if (!mounted) {
      return;
    }
    final bool listening = status == 'listening';
    if (!listening && _isListening) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) {
      return;
    }
    setState(() {
      _promptController.text = result.recognizedWords;
      _promptController.selection = TextSelection.fromPosition(
        TextPosition(offset: _promptController.text.length),
      );
    });
  }
}

class _PromptPanel extends StatelessWidget {
  const _PromptPanel({
    required this.isTv,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onExampleTap,
    required this.isListening,
    required this.speechAvailable,
    required this.speechError,
    required this.onMicTap,
  });

  final bool isTv;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final ValueChanged<String> onExampleTap;
  final bool isListening;
  final bool speechAvailable;
  final String? speechError;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isTv
                ? 'Describe your ideal show night'
                : 'Describe your ideal movie night',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use natural language. Mention what you want, what to avoid, and optional language/runtime hints.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: 4,
                  minLines: 3,
                  textInputAction: TextInputAction.search,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Example: Something like Interstellar, but not sci-fi.',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.42),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xFF78DDFF),
                        width: 1.4,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                width: 48,
                child: IconButton.filled(
                  onPressed: onMicTap,
                  style: IconButton.styleFrom(
                    backgroundColor: isListening
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF3A425A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isListening
                ? 'Listening... tap mic again to stop.'
                : speechError != null
                ? 'Voice input error: $speechError'
                : speechAvailable
                ? 'Tap mic to dictate your request.'
                : 'Tap mic to enable voice input.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: speechError != null
                  ? const Color(0xFFFF8A80)
                  : Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tonightPromptExamples
                .map(
                  (String example) => InkWell(
                    onTap: () => onExampleTap(example),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        example,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(
                isTv ? 'Find Shows' : 'Find Movies',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E6BFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.isTv, required this.result});

  final bool isTv;
  final TonightPromptResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> queryPlanChips = result.queryPlanChips ?? <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            result.interpretedIntent,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              height: 1.4,
            ),
          ),
        ),
        if (queryPlanChips.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'AI query plan',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: queryPlanChips
                      .map((String chip) => _MiniBadge(label: chip))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        ...result.recommendations.map(
          (TonightRecommendationItem item) =>
              _RecommendationCard(isTv: isTv, item: item),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.isTv, required this.item});

  final bool isTv;
  final TonightRecommendationItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String heroTag =
        'tonight-llm-${isTv ? 'tv' : 'movie'}-${item.title.id}';
    final String? poster = item.details.posterPath ?? item.title.posterPath;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 104,
                child: poster == null
                    ? Container(
                        color: AppColors.cinemaPlaceholder,
                        child: const Icon(
                          Icons.movie_creation_outlined,
                          color: Colors.white,
                        ),
                      )
                    : CachedNetworkImage(imageUrl: poster, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _MiniBadge(
                      label:
                          '${(item.details.catalogScore ?? item.title.voteAverage ?? 0).toStringAsFixed(1)}/10',
                    ),
                    if (item.details.runtimeMinutes != null)
                      _MiniBadge(label: '${item.details.runtimeMinutes} min'),
                    if (item.details.originalLanguage != null)
                      _MiniBadge(
                        label: item.details.originalLanguage!.toUpperCase(),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.matchReason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      AppRoute.movieDetails.name,
                      pathParameters: <String, String>{
                        'movieId': item.title.id.toString(),
                      },
                      queryParameters: <String, String>{
                        'isTv': isTv.toString(),
                        'heroTag': heroTag,
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isTv});

  final bool isTv;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        isTv
            ? 'Describe what show you are in the mood for, and we will return a ranked list.'
            : 'Describe what movie you are in the mood for, and we will return a ranked list.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.78),
          height: 1.45,
        ),
      ),
    );
  }
}

class _LoadingState extends ConsumerWidget {
  const _LoadingState({required this.request});

  final TonightPromptRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _GeneratingQueryHeader(),
          const SizedBox(height: 12),
          ValueListenableBuilder<TonightRecommendationProgressState>(
            valueListenable: todayRecommendationProgressNotifier,
            builder: (context, liveState, _) {
              final bool hasPlan =
                  todayRecommendationPlanNotifier.value.isNotEmpty;
              final double progress = _loadingProgressValue(
                liveState,
                hasPlan: hasPlan,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _friendlyProgressMessage(
                                  liveState.currentMessage,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _AnimatedStageBar(progress: progress),
                        const SizedBox(height: 6),
                        Text(
                          '${(progress * 100).round()}% complete',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.68),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (liveState.events.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      'Live progress',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...liveState.events.reversed.take(5).map((event) {
                      final String hh = event.timestamp.hour.toString().padLeft(
                        2,
                        '0',
                      );
                      final String mm = event.timestamp.minute
                          .toString()
                          .padLeft(2, '0');
                      final String ss = event.timestamp.second
                          .toString()
                          .padLeft(2, '0');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              event.isRetry
                                  ? Icons.sync_problem_rounded
                                  : Icons.bolt_rounded,
                              size: 15,
                              color: event.isRetry
                                  ? const Color(0xFFFFD58A)
                                  : const Color(0xFF9FE7FF),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '[$hh:$mm:$ss] ${_friendlyProgressMessage(event.message)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: event.isRetry
                                      ? const Color(0xFFFFD58A)
                                      : Colors.white.withValues(alpha: 0.78),
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              );
            },
          ),
          ValueListenableBuilder<List<String>>(
            valueListenable: todayRecommendationPlanNotifier,
            builder: (context, planChips, _) {
              if (planChips.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 14),
                  Text(
                    'AI query plan',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: planChips
                        .map((String chip) => _MiniBadge(label: chip))
                        .toList(growable: false),
                  ),
                ],
              );
            },
          ),
          if (_buildPromptCriteriaPreview(
                request,
              ).toDisplayChips().isNotEmpty &&
              todayRecommendationPlanNotifier.value.isEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              'Parsing your request',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildPromptCriteriaPreview(request)
                  .toDisplayChips()
                  .map((String chip) => _MiniBadge(label: chip))
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

String _friendlyProgressMessage(String message) {
  final String lower = message.toLowerCase();
  if (lower.contains('setting up your request')) {
    return 'Warming up your movie search';
  }
  if (lower.contains('connecting to the recommendation engine')) {
    return 'Connecting to the recommendation engine';
  }
  if (lower.contains('understanding your taste')) {
    return 'Understanding what you are in the mood for';
  }
  if (lower.contains('building your personalized search')) {
    return 'Building a custom search from your request';
  }
  if (lower.contains('network hiccup')) {
    return 'Tiny network hiccup, trying again';
  }
  if (lower.contains('search plan is ready') ||
      lower.contains('built your search plan')) {
    return 'Plan locked: genre, style, language, and runtime';
  }
  if (lower.contains('scanning tmdb')) {
    return 'Scanning TMDB for strong matches';
  }
  if (lower.contains('collecting details')) {
    return 'Collecting posters, ratings, and runtime for top picks';
  }
  if (lower.contains('verifying pick')) {
    final RegExp matchExpr = RegExp(r'(\d+)\s*/\s*(\d+)');
    final Match? match = matchExpr.firstMatch(lower);
    if (match != null) {
      return 'Shortlisting picks (${match.group(1)}/${match.group(2)})';
    }
    return 'Shortlisting the best picks';
  }
  if (lower.contains('finalizing')) {
    return 'Final polish on your recommendations';
  }
  if (lower.contains('retry')) {
    return 'Retrying after a temporary issue';
  }
  return message;
}

double _loadingProgressValue(
  TonightRecommendationProgressState state, {
  required bool hasPlan,
}) {
  if (state.events.isEmpty) {
    return hasPlan ? 0.42 : 0.08;
  }
  final String message = state.currentMessage.toLowerCase();
  if (message.contains('finalizing')) {
    return 0.96;
  }
  if (message.contains('verifying pick')) {
    final RegExp matchExpr = RegExp(r'(\d+)\s*/\s*(\d+)');
    final Match? match = matchExpr.firstMatch(message);
    if (match != null) {
      final int current = int.tryParse(match.group(1) ?? '') ?? 1;
      final int total = int.tryParse(match.group(2) ?? '') ?? 12;
      return (0.62 + (current / total) * 0.3).clamp(0.62, 0.92);
    }
    return 0.76;
  }
  if (message.contains('collecting details')) {
    return 0.6;
  }
  if (message.contains('search plan is ready') || hasPlan) {
    return 0.48;
  }
  if (message.contains('building your personalized search') ||
      message.contains('understanding your taste')) {
    return 0.3;
  }
  if (message.contains('connecting')) {
    return 0.18;
  }
  return 0.1;
}

class _AnimatedStageBar extends StatelessWidget {
  const _AnimatedStageBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return FractionallySizedBox(
              widthFactor: value,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF82F7FF), Color(0xFF44E59A)],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GeneratingQueryHeader extends StatefulWidget {
  const _GeneratingQueryHeader();

  @override
  State<_GeneratingQueryHeader> createState() => _GeneratingQueryHeaderState();
}

class _GeneratingQueryHeaderState extends State<_GeneratingQueryHeader> {
  Timer? _timer;
  int _dots = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 420), (_) {
      if (!mounted) return;
      setState(() {
        _dots = (_dots + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String dots = '.' * _dots;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: <Color>[Color(0x336E6BFF), Color(0x3328D7A1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF9FE7FF),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Finding your perfect watch$dots',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptCriteriaPreview {
  const _PromptCriteriaPreview({
    required this.intentPhrases,
    required this.includeGenres,
    required this.excludeGenres,
    required this.language,
    required this.maxRuntimeMinutes,
    required this.minRuntimeMinutes,
    required this.yearFrom,
    required this.yearTo,
    required this.keywords,
    required this.similarTo,
  });

  final List<String> intentPhrases;
  final List<String> includeGenres;
  final List<String> excludeGenres;
  final String? language;
  final int? maxRuntimeMinutes;
  final int? minRuntimeMinutes;
  final int? yearFrom;
  final int? yearTo;
  final List<String> keywords;
  final List<String> similarTo;

  List<String> toDisplayChips() {
    final List<String> chips = <String>[];
    chips.addAll(intentPhrases.take(2).map((String p) => 'Intent: $p'));
    chips.addAll(includeGenres.take(3).map((String g) => 'Genre: $g'));
    chips.addAll(excludeGenres.take(2).map((String g) => 'Avoid: $g'));
    if (language != null) {
      chips.add('Language: $language');
    }
    if (maxRuntimeMinutes != null) {
      chips.add('Runtime <= $maxRuntimeMinutes min');
    } else if (minRuntimeMinutes != null) {
      chips.add('Runtime >= $minRuntimeMinutes min');
    }
    if (yearFrom != null || yearTo != null) {
      if (yearFrom != null && yearTo != null) {
        chips.add('Year: $yearFrom-$yearTo');
      } else if (yearFrom != null) {
        chips.add('After $yearFrom');
      } else {
        chips.add('Before $yearTo');
      }
    }
    chips.addAll(similarTo.take(2).map((String s) => 'Like: $s'));
    chips.addAll(keywords.take(2).map((String k) => 'Signal: $k'));
    return chips;
  }
}

_PromptCriteriaPreview _buildPromptCriteriaPreview(
  TonightPromptRequest request,
) {
  final String prompt = request.prompt.trim();
  final String lower = prompt.toLowerCase();

  const Map<String, List<String>> genreAliases = <String, List<String>>{
    'Action': <String>['action'],
    'Adventure': <String>['adventure'],
    'Animation': <String>['animation', 'animated'],
    'Comedy': <String>['comedy', 'funny'],
    'Crime': <String>['crime', 'gangster'],
    'Documentary': <String>['documentary', 'docu'],
    'Drama': <String>['drama'],
    'Family': <String>['family', 'kids'],
    'Fantasy': <String>['fantasy'],
    'History': <String>['history', 'historical'],
    'Horror': <String>['horror', 'scary'],
    'Music': <String>['music', 'musical'],
    'Mystery': <String>['mystery'],
    'Romance': <String>['romance', 'romantic'],
    'Sci-Fi': <String>['sci-fi', 'sci fi', 'science fiction'],
    'Thriller': <String>['thriller', 'suspense'],
    'War': <String>['war'],
    'Western': <String>['western'],
  };

  const Map<String, List<String>> languages = <String, List<String>>{
    'Hindi': <String>['hindi'],
    'English': <String>['english'],
    'Tamil': <String>['tamil'],
    'Telugu': <String>['telugu'],
    'Malayalam': <String>['malayalam'],
    'Kannada': <String>['kannada'],
    'Korean': <String>['korean'],
    'Japanese': <String>['japanese'],
    'Spanish': <String>['spanish'],
    'French': <String>['french'],
    'German': <String>['german'],
    'Italian': <String>['italian'],
  };

  final Set<String> includeGenres = <String>{};
  final Set<String> excludeGenres = <String>{};
  for (final MapEntry<String, List<String>> entry in genreAliases.entries) {
    for (final String alias in entry.value) {
      if (!lower.contains(alias)) {
        continue;
      }
      if (_isNegated(lower, alias)) {
        excludeGenres.add(entry.key);
      } else {
        includeGenres.add(entry.key);
      }
      break;
    }
  }

  String? language;
  for (final MapEntry<String, List<String>> entry in languages.entries) {
    if (entry.value.any(lower.contains)) {
      language = entry.key;
      break;
    }
  }

  final int? maxRuntime = _extractRuntimeMinutes(lower, max: true);
  final int? minRuntime = _extractRuntimeMinutes(lower, max: false);
  final (int?, int?) years = _extractYearRange(lower);
  final List<String> similarTo = _extractSimilarTitles(prompt);
  final List<String> intentPhrases = _extractIntentPhrases(prompt);
  final List<String> keywords = _extractKeywords(prompt, similarTo: similarTo);

  return _PromptCriteriaPreview(
    intentPhrases: intentPhrases,
    includeGenres: includeGenres.toList(growable: false),
    excludeGenres: excludeGenres.toList(growable: false),
    language: language,
    maxRuntimeMinutes: maxRuntime,
    minRuntimeMinutes: minRuntime,
    yearFrom: years.$1,
    yearTo: years.$2,
    keywords: keywords,
    similarTo: similarTo,
  );
}

bool _isNegated(String text, String term) {
  final String escapedTerm = RegExp.escape(term);
  final RegExp negation = RegExp(
    '(?:not|no|without|except|avoid)\\s+(?:\\w+\\s+){0,2}$escapedTerm',
    caseSensitive: false,
  );
  return negation.hasMatch(text);
}

int? _extractRuntimeMinutes(String lower, {required bool max}) {
  final RegExp hourPattern = RegExp(
    max
        ? '(?:under|less than|max(?:imum)?|up to|upto)\\s*(\\d{1,2})\\s*(?:hours?|hrs?|hr|h)\\b'
        : '(?:over|more than|min(?:imum)?|at least)\\s*(\\d{1,2})\\s*(?:hours?|hrs?|hr|h)\\b',
  );
  final Match? hourMatch = hourPattern.firstMatch(lower);
  if (hourMatch != null) {
    final int? parsed = int.tryParse(hourMatch.group(1) ?? '');
    if (parsed != null) {
      return parsed * 60;
    }
  }

  final RegExp minutePattern = RegExp(
    max
        ? '(?:under|less than|max(?:imum)?|up to|upto)\\s*(\\d{2,3})\\s*(?:min|mins|minutes?)\\b'
        : '(?:over|more than|min(?:imum)?|at least)\\s*(\\d{2,3})\\s*(?:min|mins|minutes?)\\b',
  );
  final Match? minuteMatch = minutePattern.firstMatch(lower);
  return int.tryParse(minuteMatch?.group(1) ?? '');
}

(int?, int?) _extractYearRange(String lower) {
  final RegExp yearFromPattern = RegExp(
    '(?:after|since|from)\\s*(19\\d{2}|20\\d{2})',
  );
  final RegExp yearToPattern = RegExp(
    '(?:before|till|until)\\s*(19\\d{2}|20\\d{2})',
  );
  final Match? fromMatch = yearFromPattern.firstMatch(lower);
  final Match? toMatch = yearToPattern.firstMatch(lower);
  final int? yearFrom = int.tryParse(fromMatch?.group(1) ?? '');
  final int? yearTo = int.tryParse(toMatch?.group(1) ?? '');
  return (yearFrom, yearTo);
}

List<String> _extractSimilarTitles(String prompt) {
  final Set<String> matches = <String>{};
  final Iterable<RegExpMatch> likeMatches = RegExp(
    '(?:like|similar to)\\s+([^,.!?;\\n]+)',
    caseSensitive: false,
  ).allMatches(prompt);
  for (final RegExpMatch match in likeMatches) {
    String value = (match.group(1) ?? '').trim();
    value = value
        .replaceAll(
          RegExp(
            '\\b(?:but|except|without|and not|not)\\b.*\$',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    if (value.length >= 2) {
      matches.add(value);
    }
  }
  return matches.take(3).toList(growable: false);
}

List<String> _extractIntentPhrases(String prompt) {
  final List<String> phrases = <String>[];
  final List<String> parts = prompt
      .split(RegExp(r'[,.!?;\n]'))
      .map((String p) => p.trim())
      .where((String p) => p.isNotEmpty)
      .toList(growable: false);

  for (final String part in parts) {
    final String normalized = part
        .replaceAll(
          RegExp(
            r'^(i want|i need|give me|show me|recommend|find me)\s+',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    final int wordCount = normalized.split(RegExp(r'\s+')).length;
    if (wordCount >= 3 && normalized.length >= 12) {
      phrases.add(normalized);
    }
    if (phrases.length >= 3) {
      break;
    }
  }
  return phrases;
}

List<String> _extractKeywords(
  String prompt, {
  List<String> similarTo = const <String>[],
}) {
  const Set<String> stopWords = <String>{
    'want',
    'watch',
    'something',
    'show',
    'movie',
    'tonight',
    'with',
    'without',
    'like',
    'similar',
    'please',
    'give',
    'about',
    'that',
    'this',
    'from',
    'into',
    'need',
    'make',
    'more',
    'less',
    'than',
    'under',
    'over',
    'preferably',
    'prefer',
    'feel',
    'good',
  };

  final Set<String> blocked = <String>{};
  for (final String title in similarTo) {
    blocked.addAll(
      title
          .toLowerCase()
          .split(RegExp('[^a-z0-9]+'))
          .where((String token) => token.length >= 3),
    );
  }

  final Set<String> keywords = <String>{};
  final Iterable<String> tokens = prompt
      .toLowerCase()
      .split(RegExp('[^a-z0-9]+'))
      .where((String token) => token.length >= 4);
  for (final String token in tokens) {
    if (!stopWords.contains(token) && !blocked.contains(token)) {
      keywords.add(token);
    }
    if (keywords.length >= 6) {
      break;
    }
  }
  return keywords.toList(growable: false);
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0x55B4233C),
        border: Border.all(color: const Color(0x44FF8AA1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
