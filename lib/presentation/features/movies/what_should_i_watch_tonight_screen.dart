import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/domain/entities/movie_mood.dart';
import 'package:cineverse/presentation/features/movies/models/tonight_watch_models.dart';
import 'package:cineverse/presentation/features/movies/providers/tonight_watch_provider.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WhatShouldIWatchTonightScreen extends ConsumerStatefulWidget {
  const WhatShouldIWatchTonightScreen({super.key, required this.isTv});

  final bool isTv;

  @override
  ConsumerState<WhatShouldIWatchTonightScreen> createState() =>
      _WhatShouldIWatchTonightScreenState();
}

class _WhatShouldIWatchTonightScreenState
    extends ConsumerState<WhatShouldIWatchTonightScreen> {
  late TonightTimeOption _selectedTime;
  late MovieMood _selectedMood;
  late TonightLanguageOption _selectedLanguage;
  TonightWatchRequest? _submittedRequest;

  @override
  void initState() {
    super.initState();
    _selectedTime = tonightMovieTimeOptions[1];
    _selectedMood = MovieMood.cinematic;
    _selectedLanguage = tonightLanguageOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<TonightWatchResult>? recommendation =
        _submittedRequest == null
        ? null
        : ref.watch(tonightWatchRecommendationProvider(_submittedRequest!));

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                _IntroPanel(isTv: widget.isTv),
                const SizedBox(height: 20),
                _InputSection(
                  title: 'Time Available',
                  subtitle: widget.isTv
                      ? 'We will match the pacing to the episode length you want tonight.'
                      : 'Pick a runtime lane so the recommendation fits your evening.',
                  child: Column(
                    children: tonightMovieTimeOptions
                        .map((TonightTimeOption option) {
                          final bool isSelected = option.id == _selectedTime.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TimeOptionTile(
                              option: option,
                              isTv: widget.isTv,
                              isSelected: isSelected,
                              onTap: () =>
                                  setState(() => _selectedTime = option),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 16),
                _InputSection(
                  title: 'Mood',
                  subtitle:
                      'Set the emotional flavor first, then let the app find the strongest fit.',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: MovieMood.values
                        .map((MovieMood mood) {
                          final bool isSelected = mood == _selectedMood;
                          return _ChoiceChipCard(
                            label: mood.label,
                            subtitle: mood.description,
                            isSelected: isSelected,
                            accent: _moodColor(mood),
                            onTap: () => setState(() => _selectedMood = mood),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 16),
                _InputSection(
                  title: 'Language',
                  subtitle:
                      'Choose the original language you want the pick to come from.',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: tonightLanguageOptions
                        .map((TonightLanguageOption language) {
                          final bool isSelected =
                              language.code == _selectedLanguage.code;
                          return _LanguageChip(
                            language: language,
                            isSelected: isSelected,
                            onTap: () =>
                                setState(() => _selectedLanguage = language),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 20),
                _GenerateButton(
                  isTv: widget.isTv,
                  onTap: _generateRecommendation,
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _buildRecommendationState(
                    context: context,
                    recommendation: recommendation,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationState({
    required BuildContext context,
    required AsyncValue<TonightWatchResult>? recommendation,
  }) {
    if (recommendation == null) {
      return _EmptyRecommendationState(isTv: widget.isTv);
    }

    return recommendation.when(
      loading: () => const _LoadingRecommendationCard(),
      error: (Object error, StackTrace stackTrace) => _RecommendationErrorCard(
        message: '$error',
        onRetry: _generateRecommendation,
      ),
      data: (TonightWatchResult result) =>
          _TonightResultCard(result: result, isTv: widget.isTv),
    );
  }

  void _generateRecommendation() {
    setState(() {
      _submittedRequest = TonightWatchRequest(
        isTv: widget.isTv,
        timeOption: _selectedTime,
        mood: _selectedMood,
        language: _selectedLanguage,
      );
    });
  }
}

class _IntroPanel extends StatelessWidget {
  const _IntroPanel({required this.isTv});

  final bool isTv;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            const Color(0xFF13203F),
            AppColors.cinemaSurface.withValues(alpha: 0.92),
            const Color(0xFF281347),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x6619E6FF),
            blurRadius: 36,
            spreadRadius: -6,
            offset: Offset(0, 22),
          ),
          BoxShadow(
            color: Color(0x4CFD4DFF),
            blurRadius: 50,
            spreadRadius: -16,
            offset: Offset(-12, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isTv ? 'Tonight Mode: TV' : 'Tonight Mode: Movies',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFF8FEAFF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'One answer. No doom scrolling.',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isTv
                ? 'Choose your vibe, episode length, and language. We will surface one TV pick worth starting right now.'
                : 'Choose your vibe, runtime, and language. We will surface one movie that actually fits tonight.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputSection extends StatelessWidget {
  const _InputSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.64),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TimeOptionTile extends StatelessWidget {
  const _TimeOptionTile({
    required this.option,
    required this.isTv,
    required this.isSelected,
    required this.onTap,
  });

  final TonightTimeOption option;
  final bool isTv;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Color> gradient = isSelected
        ? const <Color>[Color(0xFF26D0FF), Color(0xFF7950F2)]
        : <Color>[
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.03),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: isSelected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x5526D0FF),
                      blurRadius: 28,
                      spreadRadius: -8,
                      offset: Offset(0, 16),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: isSelected ? 0.18 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.schedule_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label(isTv),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description(isTv),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                option.durationLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceChipCard extends StatelessWidget {
  const _ChoiceChipCard({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected
                  ? accent.withValues(alpha: 0.24)
                  : Colors.white.withValues(alpha: 0.03),
              border: Border.all(
                color: isSelected
                    ? accent.withValues(alpha: 0.82)
                    : Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: isSelected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.22),
                        blurRadius: 24,
                        spreadRadius: -10,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.68),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final TonightLanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = Color(language.accentHex);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isSelected
                ? accent.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: isSelected
                  ? accent.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            language.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.isTv, required this.onTap});

  final bool isTv;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFFFF7A18),
                Color(0xFFFF4D8D),
                Color(0xFF7A5CFF),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x55FF4D8D),
                blurRadius: 30,
                spreadRadius: -8,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTv ? 'Find my tonight show' : 'Find my tonight movie',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Return one best match and tell me why it is worth pressing play.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRecommendationState extends StatelessWidget {
  const _EmptyRecommendationState({required this.isTv});

  final bool isTv;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      key: const ValueKey<String>('empty-state'),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready when you are',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTv
                ? 'Dial in tonight’s episode vibe above and we will pick one show worth starting.'
                : 'Dial in tonight’s movie vibe above and we will pick one title worth your time.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.66),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingRecommendationCard extends StatefulWidget {
  const _LoadingRecommendationCard();

  @override
  State<_LoadingRecommendationCard> createState() =>
      _LoadingRecommendationCardState();
}

class _LoadingRecommendationCardState extends State<_LoadingRecommendationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      key: const ValueKey<String>('loading-state'),
      animation: _controller,
      builder: (context, child) {
        final double glow = 0.35 + (_controller.value * 0.4);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: <Color>[
                const Color(0xFF102040),
                const Color(0xFF2E1065).withValues(alpha: 0.92),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.14 + (_controller.value * 0.12),
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF35D7FF).withValues(alpha: glow),
                blurRadius: 34,
                spreadRadius: -12,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 18,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecommendationErrorCard extends StatelessWidget {
  const _RecommendationErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      key: const ValueKey<String>('error-state'),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0x66A11D33),
        border: Border.all(
          color: const Color(0xFFFF7B91).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No clean pick yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message.replaceFirst('Bad state: ', ''),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _TonightResultCard extends StatelessWidget {
  const _TonightResultCard({required this.result, required this.isTv});

  final TonightWatchResult result;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String heroTag =
        'tonight-watch-${isTv ? 'tv' : 'movie'}-${result.title.id}';
    final String? heroImage =
        result.details.posterPath ?? result.title.posterPath;

    return Container(
      key: ValueKey<int>(result.title.id),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF09192F),
            Color(0xFF1F1144),
            Color(0xFF31154E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x4D19E6FF),
            blurRadius: 38,
            spreadRadius: -8,
            offset: Offset(0, 24),
          ),
          BoxShadow(
            color: Color(0x40FF7A18),
            blurRadius: 54,
            spreadRadius: -22,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (result.details.backdropPath != null)
                    CachedNetworkImage(
                      imageUrl: result.details.backdropPath!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: const Color(0xFF101B33)),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.68),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              width: 88,
                              height: 124,
                              child: heroImage == null
                                  ? Container(
                                      color: AppColors.cinemaPlaceholder,
                                      child: const Icon(
                                        Icons.movie_creation_outlined,
                                        color: Colors.white,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: heroImage,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isTv ? 'Tonight\'s Show' : 'Tonight\'s Movie',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFF90EAFF),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                result.title.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _ResultBadge(
                                    label:
                                        result.details.originalLanguage
                                            ?.toUpperCase() ??
                                        'LANG',
                                  ),
                                  if (result.details.runtimeMinutes != null)
                                    _ResultBadge(
                                      label:
                                          '${result.details.runtimeMinutes} min',
                                    ),
                                  if ((result.details.catalogScore ??
                                          result.title.voteAverage) !=
                                      null)
                                    _ResultBadge(
                                      label:
                                          '${(result.details.catalogScore ?? result.title.voteAverage)!.toStringAsFixed(1)}/10',
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Why you should watch this',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            result.explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.55,
            ),
          ),
          if (result.details.overview != null &&
              result.details.overview!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                result.details.overview!,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.pushNamed(
                  AppRoute.movieDetails.name,
                  pathParameters: <String, String>{
                    'movieId': result.title.id.toString(),
                  },
                  queryParameters: <String, String>{
                    'isTv': isTv.toString(),
                    'heroTag': heroTag,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: const Text('Open details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
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
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

Color _moodColor(MovieMood mood) {
  return switch (mood) {
    MovieMood.mindBending => const Color(0xFF61B8FF),
    MovieMood.feelGood => const Color(0xFFFFC74D),
    MovieMood.dark => const Color(0xFFFF6B8A),
    MovieMood.fastPaced => const Color(0xFF42E695),
    MovieMood.edgeOfYourSeat => const Color(0xFFFF8A3D),
    MovieMood.cinematic => const Color(0xFF8B5CFF),
    MovieMood.indie => const Color(0xFF7AE7C7),
  };
}
