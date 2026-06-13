import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/presentation/features/movies/models/tonight_watch_models.dart';
import 'package:cineverse/presentation/features/movies/providers/tonight_ai_consent_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/tonight_query_history_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/tonight_feedback_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/tonight_watch_provider.dart';
import 'package:cineverse/presentation/features/movies/providers/hidden_titles_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
import 'package:cineverse/presentation/widgets/media_actions_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
    extends ConsumerState<WhatShouldIWatchTonightScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  final SpeechToText _speech = SpeechToText();
  final math.Random _random = math.Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  TonightPromptRequest? _submittedRequest;
  int _requestNonce = 0;
  bool _hasPendingFeedbackRefresh = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  String? _speechError;
  List<String> _rotatingExamples = <String>[];
  int _suggestionRevision = 0;
  bool _isShufflingSuggestions = false;
  late final AnimationController _diceController;
  late final Animation<double> _diceRotation;
  late final Animation<double> _diceScale;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _diceRotation = Tween<double>(
      begin: 0,
      end: 1.45,
    ).animate(CurvedAnimation(parent: _diceController, curve: Curves.easeOut));
    _diceScale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.12,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_diceController);
    _rotatingExamples = _buildRotatingExamples();
  }

  @override
  void dispose() {
    _diceController.dispose();
    _audioPlayer.dispose();
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
    final List<String> historyQueries =
        ref.watch(tonightQueryHistoryProvider).asData?.value ??
        const <String>[];
    final bool hasClearablePreferences = ref.watch(
      tonightHasClearablePreferencesProvider(widget.isTv),
    );
    final bool isFetching = recommendations?.isLoading ?? false;

    return _AmbientGlowingBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: _buildFeedbackRefreshButton(isFetching),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  examplePrompts: _rotatingExamples,
                  suggestionRevision: _suggestionRevision,
                  isShufflingSuggestions: _isShufflingSuggestions,
                  diceRotation: _diceRotation,
                  diceScale: _diceScale,
                  onSubmit: _runSearch,
                  onExampleTap: _useExamplePrompt,
                  onDiceTap: () => unawaited(_useRandomSuggestion()),
                  isListening: _isListening,
                  speechAvailable: _speechAvailable,
                  speechError: _speechError,
                  onMicTap: _toggleVoiceInput,
                  isFetching: isFetching,
                  historyQueries: historyQueries,
                  onHistoryTap: _useHistoryPrompt,
                  hasClearablePreferences: hasClearablePreferences,
                  onClearHistory: () => unawaited(
                    ref.read(tonightQueryHistoryProvider.notifier).clear(),
                  ),
                  onClearPreferences: () =>
                      unawaited(_clearTonightPreferences()),
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
      data: (TonightPromptResult result) => _ResultList(
        isTv: widget.isTv,
        result: result,
        prompt: _submittedRequest!.prompt,
        onFeedbackRefreshStateChanged: _setFeedbackRefreshPending,
      ),
    );
  }

  Future<void> _runSearch() async {
    final TonightPromptRequest? activeRequest = _submittedRequest;
    if (activeRequest != null) {
      final AsyncValue<TonightPromptResult> activeState = ref.read(
        tonightPromptRecommendationsProvider(activeRequest),
      );
      if (activeState.isLoading) {
        return;
      }
    }

    final String prompt = _promptController.text.trim();
    if (prompt.length < 4) {
      _promptFocusNode.requestFocus();
      return;
    }
    final bool canProceed = await _ensureAiConsent();
    if (!canProceed || !mounted) {
      return;
    }

    final TonightPromptRequest request = TonightPromptRequest(
      isTv: widget.isTv,
      prompt: prompt,
      requestNonce: ++_requestNonce,
      useTmdbSeedRefreshOnly: false,
    );
    unawaited(ref.read(tonightQueryHistoryProvider.notifier).addEntry(prompt));
    ref.invalidate(tonightPromptRecommendationsProvider(request));
    setState(() {
      _submittedRequest = request;
      _hasPendingFeedbackRefresh = false;
    });
  }

  void _rerunSubmittedQuery() {
    final TonightPromptRequest? activeRequest = _submittedRequest;
    if (activeRequest == null) {
      return;
    }
    final TonightPromptRequest request = TonightPromptRequest(
      isTv: activeRequest.isTv,
      prompt: activeRequest.prompt,
      requestNonce: ++_requestNonce,
      useTmdbSeedRefreshOnly: true,
    );
    ref.invalidate(tonightPromptRecommendationsProvider(request));
    setState(() {
      _submittedRequest = request;
      _hasPendingFeedbackRefresh = false;
    });
  }

  void _setFeedbackRefreshPending(bool pending) {
    if (_submittedRequest == null || _hasPendingFeedbackRefresh == pending) {
      return;
    }
    setState(() {
      _hasPendingFeedbackRefresh = pending;
    });
  }

  Widget? _buildFeedbackRefreshButton(bool isFetching) {
    final bool visible =
        _hasPendingFeedbackRefresh && !isFetching && _submittedRequest != null;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      child: !visible
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              key: const ValueKey<String>('feedback-refresh-fab'),
              onPressed: _rerunSubmittedQuery,
              backgroundColor: const Color(0xFF6E6BFF),
              foregroundColor: Colors.white,
              elevation: 10,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Refresh picks'),
            ),
    );
  }

  Future<void> _clearTonightPreferences() async {
    await ref
        .read(tonightFeedbackProvider.notifier)
        .clearPreferenceSignalsForMediaType(widget.isTv);
    _setFeedbackRefreshPending(_submittedRequest != null);
  }

  void _useExamplePrompt(String prompt) {
    _promptController.text = prompt;
    unawaited(_runSearch());
  }

  void _useHistoryPrompt(String prompt) {
    _promptController.text = prompt;
    _promptController.selection = TextSelection.fromPosition(
      TextPosition(offset: _promptController.text.length),
    );
    unawaited(_runSearch());
  }

  List<String> _buildRotatingExamples() {
    final List<String> pool = List<String>.from(
      widget.isTv ? tonightTvPromptExamples : tonightMoviePromptExamples,
    )..shuffle(_random);
    return pool.take(2).toList(growable: false);
  }

  Future<void> _useRandomSuggestion() async {
    if (_rotatingExamples.length <= 1) {
      return;
    }
    setState(() {
      _isShufflingSuggestions = true;
    });
    _diceController.forward(from: 0);
    unawaited(_audioPlayer.play(AssetSource('sounds/dice_shuffle.wav')));

    List<String> next = _buildRotatingExamples();
    int attempts = 0;
    while (_sameOrder(next, _rotatingExamples) && attempts < 4) {
      next = _buildRotatingExamples();
      attempts += 1;
    }
    setState(() {
      _rotatingExamples = next;
      _suggestionRevision += 1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!mounted) {
      return;
    }
    setState(() {
      _isShufflingSuggestions = false;
    });
  }

  bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
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

  Future<bool> _ensureAiConsent() async {
    final TonightAiConsentStatus status =
        ref.read(tonightAiConsentProvider).asData?.value ??
        TonightAiConsentStatus.unknown;
    if (status == TonightAiConsentStatus.granted) {
      return true;
    }
    final bool? allow = await _showAiConsentDialog(context);
    if (allow == true) {
      await ref.read(tonightAiConsentProvider.notifier).grant();
      return true;
    }
    await ref.read(tonightAiConsentProvider.notifier).decline();
    return false;
  }

  Future<bool?> _showAiConsentDialog(BuildContext context) {
    return showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: Text(
          'Allow AI data sharing?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Recommend Tonight sends the text you type for a movie recommendation request and temporary query-refinement context to Google Gemini and OpenRouter. Your full library and your sign-in credentials are not sent to those AI providers. Allow this data sharing for AI recommendations?',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: const Text(
              'Not now',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.cinemaSelected,
            ),
            child: const Text(
              'Allow',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptPanel extends StatelessWidget {
  const _PromptPanel({
    required this.isTv,
    required this.controller,
    required this.focusNode,
    required this.examplePrompts,
    required this.suggestionRevision,
    required this.isShufflingSuggestions,
    required this.diceRotation,
    required this.diceScale,
    required this.onSubmit,
    required this.onExampleTap,
    required this.onDiceTap,
    required this.isListening,
    required this.speechAvailable,
    required this.speechError,
    required this.onMicTap,
    required this.isFetching,
    required this.historyQueries,
    required this.onHistoryTap,
    required this.hasClearablePreferences,
    required this.onClearHistory,
    required this.onClearPreferences,
  });

  final bool isTv;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> examplePrompts;
  final int suggestionRevision;
  final bool isShufflingSuggestions;
  final Animation<double> diceRotation;
  final Animation<double> diceScale;
  final VoidCallback onSubmit;
  final ValueChanged<String> onExampleTap;
  final VoidCallback onDiceTap;
  final bool isListening;
  final bool speechAvailable;
  final String? speechError;
  final VoidCallback onMicTap;
  final bool isFetching;
  final List<String> historyQueries;
  final ValueChanged<String> onHistoryTap;
  final bool hasClearablePreferences;
  final VoidCallback onClearHistory;
  final VoidCallback onClearPreferences;

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
                  onTapOutside: (_) => focusNode.unfocus(),
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
              _AudioWavePulse(isListening: isListening, onTap: onMicTap),
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.85,
                    end: 1.0,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Wrap(
              key: ValueKey<int>(suggestionRevision),
              spacing: 8,
              runSpacing: 8,
              children: examplePrompts
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
          ),
          if (historyQueries.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Recent queries',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onClearHistory,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.74),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: historyQueries.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final String query = historyQueries[index];
                  return InkWell(
                    onTap: () => onHistoryTap(query),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.06),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.history_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              query,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (hasClearablePreferences) ...<Widget>[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onClearPreferences,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Clear preferences'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.9),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isFetching ? null : onSubmit,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    isFetching
                        ? (isTv ? 'Finding Shows...' : 'Finding Movies...')
                        : (isTv ? 'Find Shows' : 'Find Movies'),
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
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isFetching ? null : onDiceTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.cinemaSelected.withValues(
                        alpha: isShufflingSuggestions ? 0.24 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.cinemaSelected.withValues(
                          alpha: isShufflingSuggestions ? 0.55 : 0.24,
                        ),
                      ),
                    ),
                    child: ScaleTransition(
                      scale: diceScale,
                      child: RotationTransition(
                        turns: diceRotation,
                        child: Icon(
                          Icons.casino_outlined,
                          color: AppColors.cinemaSelected,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: isShufflingSuggestions ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Shuffling ideas...',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF9FE7FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _FeedbackSelectionType {
  watched,
  notInterested,
  moreLikeThis,
  tooMainstream,
}

String _selectionKey(int mediaId, _FeedbackSelectionType type) =>
    '$mediaId:${type.name}';

class _ResultList extends ConsumerStatefulWidget {
  const _ResultList({
    required this.isTv,
    required this.result,
    required this.prompt,
    required this.onFeedbackRefreshStateChanged,
  });

  final bool isTv;
  final TonightPromptResult result;
  final String prompt;
  final ValueChanged<bool> onFeedbackRefreshStateChanged;

  @override
  ConsumerState<_ResultList> createState() => _ResultListState();
}

class _ResultListState extends ConsumerState<_ResultList> {
  final GlobalKey _shareBoardKey = GlobalKey();
  String? _baselineSignatureKey;
  Map<String, bool> _baselineSelections = <String, bool>{};
  Map<String, bool> _currentSelections = <String, bool>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _captureBaselineIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _ResultList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _captureBaselineIfNeeded();
  }

  void _captureBaselineIfNeeded() {
    final String nextKey =
        '${normalizeTonightPromptScope(widget.prompt)}::${widget.result.recommendations.map((item) => item.title.id).join(',')}';
    if (_baselineSignatureKey == nextKey) {
      return;
    }
    final Map<String, bool> snapshot = <String, bool>{};
    for (final TonightRecommendationItem item
        in widget.result.recommendations) {
      final int mediaId = item.title.id;
      final Set<TonightFeedbackSignal> activeSignals = ref.read(
        tonightFeedbackSignalsProvider((
          mediaId: mediaId,
          isTv: widget.isTv,
          promptContext: widget.prompt,
        )),
      );
      final bool isWatched =
          ref
              .read(
                watchedItemProvider((
                  id: mediaId,
                  type: widget.isTv
                      ? GlobalMediaType.tv
                      : GlobalMediaType.movie,
                )),
              )
              .value !=
          null;
      snapshot[_selectionKey(mediaId, _FeedbackSelectionType.watched)] =
          isWatched;
      snapshot[_selectionKey(mediaId, _FeedbackSelectionType.notInterested)] =
          activeSignals.contains(TonightFeedbackSignal.notInterested);
      snapshot[_selectionKey(mediaId, _FeedbackSelectionType.moreLikeThis)] =
          activeSignals.contains(TonightFeedbackSignal.moreLikeThis);
      snapshot[_selectionKey(mediaId, _FeedbackSelectionType.tooMainstream)] =
          activeSignals.contains(TonightFeedbackSignal.tooMainstream);
    }
    _baselineSignatureKey = nextKey;
    _baselineSelections = snapshot;
    _currentSelections = Map<String, bool>.from(snapshot);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onFeedbackRefreshStateChanged(false);
    });
  }

  void _handleSelectionChanged({
    required int mediaId,
    required _FeedbackSelectionType type,
    required bool selected,
  }) {
    final String key = _selectionKey(mediaId, type);
    _currentSelections[key] = selected;
    final bool hasDiff = _currentSelections.entries.any(
      (entry) => _baselineSelections[entry.key] != entry.value,
    );
    widget.onFeedbackRefreshStateChanged(hasDiff);
  }

  Future<void> _shareBoard() async {
    try {
      final RenderObject? renderObject = _shareBoardKey.currentContext
          ?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        return;
      }
      final ui.Image image = await renderObject.toImage(pixelRatio: 3);
      final ByteData? bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (bytes == null) {
        return;
      }
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File(
        '${tempDir.path}/lumi_tonight_board_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await Share.shareXFiles(<XFile>[
        XFile(file.path),
      ], text: 'Tonight\'s Lumi picks for: ${widget.prompt}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share recommendation board.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> queryPlanChips =
        widget.result.queryPlanChips ?? <String>[];
    final List<TonightRecommendationItem> visibleRecommendations =
        widget.result.recommendations;
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
            widget.result.interpretedIntent,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 10),
        RepaintBoundary(
          key: _shareBoardKey,
          child: _RecommendationBoardCard(
            prompt: widget.prompt,
            isTv: widget.isTv,
            recommendations: visibleRecommendations.take(4).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: visibleRecommendations.isEmpty ? null : _shareBoard,
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: const Text('Share board'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9FE7FF),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            ),
          ),
        ),
        if (queryPlanChips.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
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
        ...visibleRecommendations.asMap().entries.map((
          MapEntry<int, TonightRecommendationItem> entry,
        ) {
          final int index = entry.key;
          final TonightRecommendationItem item = entry.value;
          return _StaggeredEntrance(
            index: index,
            child: _RecommendationCard(
              isTv: widget.isTv,
              item: item,
              prompt: widget.prompt,
              onFeedbackSelectionChanged: _handleSelectionChanged,
            ),
          );
        }),
      ],
    );
  }
}

class _RecommendationBoardCard extends StatelessWidget {
  const _RecommendationBoardCard({
    required this.prompt,
    required this.isTv,
    required this.recommendations,
  });

  final String prompt;
  final bool isTv;
  final List<TonightRecommendationItem> recommendations;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF101824), Color(0xFF091019)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tonight\'s Picks',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            prompt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: recommendations
                .take(4)
                .map((TonightRecommendationItem item) {
                  final String? poster =
                      item.details.posterPath ?? item.title.posterPath;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 2 / 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: poster == null
                                  ? Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      child: Icon(
                                        isTv
                                            ? Icons.live_tv_rounded
                                            : Icons.movie_creation_outlined,
                                        color: Colors.white54,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: poster,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
          const SizedBox(height: 10),
          Text(
            'Shared from Lumi',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  const _RecommendationCard({
    required this.isTv,
    required this.item,
    required this.prompt,
    required this.onFeedbackSelectionChanged,
  });

  final bool isTv;
  final TonightRecommendationItem item;
  final String prompt;
  final void Function({
    required int mediaId,
    required _FeedbackSelectionType type,
    required bool selected,
  })
  onFeedbackSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String heroTag =
        'tonight-llm-${isTv ? 'tv' : 'movie'}-${item.title.id}';
    final String? poster = item.details.posterPath ?? item.title.posterPath;

    final AsyncValue<bool> isInWatchlistAsync = ref.watch(
      isInWatchlistProvider(item.title.id),
    );
    final bool isInWatchlist = isInWatchlistAsync.value ?? false;
    final AsyncValue<WatchedItem?> watchedItemAsync = ref.watch(
      watchedItemProvider((
        id: item.title.id,
        type: isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
      )),
    );
    final bool isWatched = watchedItemAsync.value != null;
    final Set<TonightFeedbackSignal> activeSignals = ref.watch(
      tonightFeedbackSignalsProvider((
        mediaId: item.title.id,
        isTv: isTv,
        promptContext: prompt,
      )),
    );

    final int matchPct = (item.score <= 1.0 ? item.score * 100 : item.score)
        .round()
        .clamp(1, 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Hero(
                      tag: heroTag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 84,
                          height: 124,
                          child: poster == null
                              ? Container(
                                  color: AppColors.cinemaPlaceholder,
                                  child: const Icon(
                                    Icons.movie_creation_outlined,
                                    color: Colors.white54,
                                    size: 28,
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: poster,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.cinemaPlaceholder,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -8,
                      left: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFF00E5FF),
                              Color(0xFF6E6BFF),
                            ],
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(
                                0xFF00E5FF,
                              ).withValues(alpha: 0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          '$matchPct% Match',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Text(
                          item.title.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          _IconMetadataBadge(
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFFFD54F),
                            label:
                                (item.details.catalogScore ??
                                        item.title.voteAverage ??
                                        0)
                                    .toStringAsFixed(1),
                          ),
                          if (item.details.runtimeMinutes != null)
                            _IconMetadataBadge(
                              icon: Icons.schedule_rounded,
                              iconColor: const Color(0xFF78DDFF),
                              label: '${item.details.runtimeMinutes} min',
                            ),
                          if (item.details.originalLanguage != null)
                            _IconMetadataBadge(
                              icon: Icons.translate_rounded,
                              iconColor: const Color(0xFFB39DDB),
                              label: item.details.originalLanguage!
                                  .toUpperCase(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.matchReason,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.76),
                          height: 1.4,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _FeedbackChip(
                            label: 'Watched',
                            icon: Icons.visibility_rounded,
                            selected: isWatched,
                            onTap: () async {
                              final ({int id, GlobalMediaType type})
                              watchedParams = (
                                id: item.title.id,
                                type: isTv
                                    ? GlobalMediaType.tv
                                    : GlobalMediaType.movie,
                              );
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext context) =>
                                    WatchedDialog(
                                      details: item.details,
                                      isTv: isTv,
                                      existingItem: watchedItemAsync.value,
                                    ),
                              );
                              ref.invalidate(watchedItemsProvider);
                              ref.invalidate(
                                watchedItemProvider(watchedParams),
                              );
                              final WatchedItem? refreshed = await ref.read(
                                watchedItemProvider(watchedParams).future,
                              );
                              final TonightFeedbackStore notifier = ref.read(
                                tonightFeedbackProvider.notifier,
                              );
                              await notifier.setSignal(
                                mediaId: item.title.id,
                                isTv: isTv,
                                signal: TonightFeedbackSignal.watchedAlready,
                                enabled: refreshed != null,
                                title: item.title.title,
                                posterPath: poster,
                                genres: _feedbackGenresFromDetails(
                                  item.details,
                                ),
                                originalLanguage: item.details.originalLanguage,
                                popularity: item.title.popularity,
                              );
                              onFeedbackSelectionChanged(
                                mediaId: item.title.id,
                                type: _FeedbackSelectionType.watched,
                                selected: refreshed != null,
                              );
                            },
                          ),
                          _FeedbackChip(
                            label: 'Not for me',
                            icon: Icons.block_rounded,
                            selected: activeSignals.contains(
                              TonightFeedbackSignal.notInterested,
                            ),
                            onTap: () async {
                              final bool enabled = activeSignals.contains(
                                TonightFeedbackSignal.notInterested,
                              );
                              await ref
                                  .read(tonightFeedbackProvider.notifier)
                                  .setSignal(
                                    mediaId: item.title.id,
                                    isTv: isTv,
                                    signal: TonightFeedbackSignal.notInterested,
                                    enabled: !enabled,
                                    title: item.title.title,
                                    posterPath: poster,
                                    genres: _feedbackGenresFromDetails(
                                      item.details,
                                    ),
                                    originalLanguage:
                                        item.details.originalLanguage,
                                    popularity: item.title.popularity,
                                  );
                              onFeedbackSelectionChanged(
                                mediaId: item.title.id,
                                type: _FeedbackSelectionType.notInterested,
                                selected: !enabled,
                              );
                              final HiddenTitlesNotifier hiddenTitlesNotifier =
                                  ref.read(hiddenTitlesProvider.notifier);
                              if (enabled) {
                                unawaited(
                                  hiddenTitlesNotifier.unhideTitle(
                                    item.title.id,
                                    isTv,
                                  ),
                                );
                              } else {
                                unawaited(
                                  hiddenTitlesNotifier.hideHiddenTitle(
                                    HiddenTitle(
                                      id: item.title.id,
                                      title: item.title.title,
                                      posterPath: poster,
                                      releaseDate: item.title.releaseDate,
                                      isTv: isTv,
                                      voteAverage:
                                          item.title.voteAverage ??
                                          item.details.catalogScore,
                                      hiddenAt: DateTime.now(),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          _FeedbackChip(
                            label: 'More like this',
                            icon: Icons.auto_awesome_rounded,
                            selected: activeSignals.contains(
                              TonightFeedbackSignal.moreLikeThis,
                            ),
                            onTap: () => ref
                                .read(tonightFeedbackProvider.notifier)
                                .toggleSignal(
                                  mediaId: item.title.id,
                                  isTv: isTv,
                                  signal: TonightFeedbackSignal.moreLikeThis,
                                  promptContext: prompt,
                                  title: item.title.title,
                                  posterPath: poster,
                                  genres: _feedbackGenresFromDetails(
                                    item.details,
                                  ),
                                  originalLanguage:
                                      item.details.originalLanguage,
                                  popularity: item.title.popularity,
                                )
                                .then(
                                  (_) => onFeedbackSelectionChanged(
                                    mediaId: item.title.id,
                                    type: _FeedbackSelectionType.moreLikeThis,
                                    selected: !activeSignals.contains(
                                      TonightFeedbackSignal.moreLikeThis,
                                    ),
                                  ),
                                ),
                          ),
                          _FeedbackChip(
                            label: 'Too mainstream',
                            icon: Icons.trending_up_rounded,
                            selected: activeSignals.contains(
                              TonightFeedbackSignal.tooMainstream,
                            ),
                            onTap: () => ref
                                .read(tonightFeedbackProvider.notifier)
                                .toggleSignal(
                                  mediaId: item.title.id,
                                  isTv: isTv,
                                  signal: TonightFeedbackSignal.tooMainstream,
                                  title: item.title.title,
                                  posterPath: poster,
                                  genres: _feedbackGenresFromDetails(
                                    item.details,
                                  ),
                                  originalLanguage:
                                      item.details.originalLanguage,
                                  popularity: item.title.popularity,
                                )
                                .then(
                                  (_) => onFeedbackSelectionChanged(
                                    mediaId: item.title.id,
                                    type: _FeedbackSelectionType.tooMainstream,
                                    selected: !activeSignals.contains(
                                      TonightFeedbackSignal.tooMainstream,
                                    ),
                                  ),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
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
                        borderRadius: BorderRadius.circular(10),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.open_in_new_rounded,
                                size: 14,
                                color: Color(0xFF78DDFF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Explore details',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFF78DDFF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: InkWell(
                  key: ValueKey<bool>(isInWatchlist),
                  onTap: () {
                    final watchlistItem = WatchlistItem(
                      id: item.title.id,
                      title: item.title.title,
                      posterPath: poster,
                      releaseDate: item.title.releaseDate,
                      mediaType: isTv
                          ? GlobalMediaType.tv
                          : GlobalMediaType.movie,
                      addedDate: DateTime.now(),
                      voteAverage:
                          item.title.voteAverage ?? item.details.catalogScore,
                    );
                    ref
                        .read(watchlistProvider.notifier)
                        .toggleItem(watchlistItem);
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Ink(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isInWatchlist
                          ? const Color(0xFF6E6BFF).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: isInWatchlist
                            ? const Color(0xFF6E6BFF).withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.12),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isInWatchlist
                          ? Icons.bookmark_added_rounded
                          : Icons.bookmark_add_outlined,
                      color: isInWatchlist
                          ? const Color(0xFF78DDFF)
                          : Colors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  const _FeedbackChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: selected
              ? const LinearGradient(
                  colors: <Color>[Color(0xFF1FA2FF), Color(0xFF7B61FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: selected
                ? const Color(0xFFB7F0FF).withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF6CB9FF).withValues(alpha: 0.28),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 13,
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.72),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: selected ? 1 : 0.82),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: selected ? 0.15 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _feedbackGenresFromDetails(MovieDetails details) {
  return details.genres
      .map(
        (String genre) => genre
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\\s]'), ' ')
            .replaceAll(RegExp(r'\\s+'), ' ')
            .trim(),
      )
      .where((String genre) => genre.isNotEmpty)
      .toList(growable: false);
}

class _IconMetadataBadge extends StatelessWidget {
  const _IconMetadataBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _GeneratingQueryHeader(),
          const SizedBox(height: 24),
          const Center(child: _AiScanScanner()),
          const SizedBox(height: 24),
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF82F7FF),
                                ),
                              ),
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

// ==========================================
// Premium Overhaul Helper Widgets
// ==========================================

class _AmbientGlowingBackdrop extends StatefulWidget {
  const _AmbientGlowingBackdrop({required this.child});

  final Widget child;

  @override
  State<_AmbientGlowingBackdrop> createState() =>
      _AmbientGlowingBackdropState();
}

class _AmbientGlowingBackdropState extends State<_AmbientGlowingBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _GlowingBlobsPainter(
                  animationValue: _controller.value,
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
            child: Container(color: Colors.black.withValues(alpha: 0.55)),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GlowingBlobsPainter extends CustomPainter {
  _GlowingBlobsPainter({required this.animationValue});

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final double angle = animationValue * 2 * math.pi;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Blob 1: Cyan-Blueish
    final double x1 = size.width * (0.25 + 0.15 * math.sin(angle));
    final double y1 = size.height * (0.3 + 0.1 * math.cos(angle));
    final double r1 = math.min(size.width, size.height) * 0.45;
    paint.shader = RadialGradient(
      colors: <Color>[
        const Color(0xFF00E5FF).withValues(alpha: 0.18),
        const Color(0xFF00E5FF).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(x1, y1), radius: r1));
    canvas.drawCircle(Offset(x1, y1), r1, paint);

    // Blob 2: Magenta/Pinkish
    final double x2 = size.width * (0.75 + 0.12 * math.cos(angle + 1.0));
    final double y2 = size.height * (0.45 + 0.15 * math.sin(angle + 1.0));
    final double r2 = math.min(size.width, size.height) * 0.5;
    paint.shader = RadialGradient(
      colors: <Color>[
        const Color(0xFFE040FB).withValues(alpha: 0.15),
        const Color(0xFFE040FB).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(x2, y2), radius: r2));
    canvas.drawCircle(Offset(x2, y2), r2, paint);

    // Blob 3: Deep Indigo/Purple
    final double x3 = size.width * (0.45 + 0.2 * math.sin(angle + 2.5));
    final double y3 = size.height * (0.8 + 0.12 * math.cos(angle + 2.5));
    final double r3 = math.min(size.width, size.height) * 0.55;
    paint.shader = RadialGradient(
      colors: <Color>[
        const Color(0xFF651FFF).withValues(alpha: 0.18),
        const Color(0xFF651FFF).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(x3, y3), radius: r3));
    canvas.drawCircle(Offset(x3, y3), r3, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowingBlobsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _AudioWavePulse extends StatefulWidget {
  const _AudioWavePulse({required this.isListening, required this.onTap});

  final bool isListening;
  final VoidCallback onTap;

  @override
  State<_AudioWavePulse> createState() => _AudioWavePulseState();
}

class _AudioWavePulseState extends State<_AudioWavePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isListening) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AudioWavePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (widget.isListening)
            ...List<Widget>.generate(3, (int index) {
              final double delay = index * 0.33;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  double progress = _controller.value + delay;
                  if (progress > 1.0) {
                    progress -= 1.0;
                  }
                  final double scale = 1.0 + (progress * 1.2);
                  final double opacity = (1.0 - progress).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFFEF5350,
                        ).withValues(alpha: opacity * 0.45),
                        border: Border.all(
                          color: const Color(
                            0xFFEF5350,
                          ).withValues(alpha: opacity * 0.6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: widget.isListening
                  ? const Color(0xFFEF5350)
                  : const Color(0xFF3A425A),
              boxShadow: widget.isListening
                  ? <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFFEF5350).withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredEntrance extends StatefulWidget {
  const _StaggeredEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _timer = Timer(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, childWidget) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: childWidget,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _AiScanScanner extends StatefulWidget {
  const _AiScanScanner();

  @override
  State<_AiScanScanner> createState() => _AiScanScannerState();
}

class _AiScanScannerState extends State<_AiScanScanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: CustomPaint(
                    size: const Size(110, 110),
                    painter: _DashedCirclePainter(
                      color: const Color(0xFF6E6BFF).withValues(alpha: 0.6),
                      dashCount: 16,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_controller.value * 4 * math.pi,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return SweepGradient(
                        colors: <Color>[
                          const Color(0xFF82F7FF),
                          const Color(0xFF44E59A),
                          const Color(0xFF82F7FF).withValues(alpha: 0),
                        ],
                        stops: const <double>[0.0, 0.5, 1.0],
                      ).createShader(rect);
                    },
                    child: Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                );
              },
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.9, end: 1.1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutSine,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF6E6BFF), Color(0xFF28D7A1)],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFF6E6BFF).withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({
    required this.color,
    required this.dashCount,
    required this.strokeWidth,
  });

  final Color color;
  final int dashCount;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double dashAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = i * dashAngle;
      final double sweepAngle = dashAngle * 0.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
