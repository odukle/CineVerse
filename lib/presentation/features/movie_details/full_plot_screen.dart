import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/data/models/omdb_title_details_dto.dart';
import 'package:cineverse/presentation/features/movie_details/providers/omdb_title_details_provider.dart';
import 'package:cineverse/presentation/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FullPlotScreen extends ConsumerWidget {
  const FullPlotScreen({
    super.key,
    required this.imdbId,
    required this.fallbackTitle,
    this.posterPath,
    this.releaseDate,
  });

  final String imdbId;
  final String fallbackTitle;
  final String? posterPath;
  final String? releaseDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = OmdbTitleDetailsRequest(
      imdbId: imdbId,
      fallbackTitle: fallbackTitle,
    );
    final detailsAsync = ref.watch(omdbTitleDetailsProvider(request));

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cinemaGradientTop,
        leading: const AppBackButton(),
        title: Text(context.l10n.fullPlot),
      ),
      body: detailsAsync.when(
        loading: () => _FullPlotLoadingState(title: fallbackTitle),
        error: (error, _) => _FullPlotErrorState(
          title: fallbackTitle,
          message: error is StateError
              ? error.message
              : context.l10n.errorLoadingGenres(error.toString()),
          onRetry: () => ref.invalidate(omdbTitleDetailsProvider(request)),
        ),
        data: (details) => _FullPlotContent(
          details: details,
          fallbackTitle: fallbackTitle,
          fallbackPosterPath: posterPath,
          fallbackReleaseDate: releaseDate,
        ),
      ),
    );
  }
}

class _FullPlotContent extends StatelessWidget {
  const _FullPlotContent({
    required this.details,
    required this.fallbackTitle,
    this.fallbackPosterPath,
    this.fallbackReleaseDate,
  });

  final OmdbTitleDetailsDto details;
  final String fallbackTitle;
  final String? fallbackPosterPath;
  final String? fallbackReleaseDate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = details.title ?? fallbackTitle;
    final String? poster = details.poster ?? fallbackPosterPath;
    final String? year = details.year ?? _yearFromDate(fallbackReleaseDate);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: poster != null
                  ? CachedNetworkImage(
                      imageUrl: poster,
                      width: 96,
                      height: 142,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 96,
                      height: 142,
                      color: Colors.white10,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.movie_creation_outlined,
                        color: Colors.white38,
                        size: 30,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
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
                  if (year != null && year.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      year,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (details.rated != null)
                        _MetaChip(
                          icon: Icons.verified_outlined,
                          text: details.rated!,
                        ),
                      if (details.runtime != null)
                        _MetaChip(
                          icon: Icons.schedule_outlined,
                          text: details.runtime!,
                        ),
                      if (details.imdbRating != null)
                        _MetaChip(
                          icon: Icons.star_rounded,
                          text: 'IMDb ${details.imdbRating}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _CardSection(
          title: context.l10n.fullPlot,
          child: Text(
            details.plot ?? context.l10n.noReviewsYet,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _InfoGrid(
          entries: [
            ('Genre', details.genre),
            ('Language', details.language),
            ('Country', details.country),
            ('Released', details.released),
            ('Type', details.type),
            ('IMDb Votes', details.imdbVotes),
            ('Metascore', details.metascore),
            ('Box Office', details.boxOffice),
          ],
        ),
        if (details.director != null ||
            details.writer != null ||
            details.actors != null) ...[
          const SizedBox(height: 14),
          _CardSection(
            title: context.l10n.userReviews,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details.director != null)
                  _InlineInfo(label: context.l10n.director, value: details.director!),
                if (details.writer != null)
                  _InlineInfo(label: context.l10n.writer, value: details.writer!),
                if (details.actors != null)
                  _InlineInfo(label: context.l10n.actors, value: details.actors!),
              ],
            ),
          ),
        ],
        if (details.awards != null) ...[
          const SizedBox(height: 14),
          _CardSection(
            title: context.l10n.filtered,
            child: Text(
              details.awards!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String? _yearFromDate(String? date) {
    if (date == null || date.length < 4) return null;
    return date.substring(0, 4);
  }
}

class _FullPlotLoadingState extends StatelessWidget {
  const _FullPlotLoadingState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.errorLoadingGenres(title),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullPlotErrorState extends StatelessWidget {
  const _FullPlotErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white54,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.detailsCard.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.cinemaAccent),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.detailsCard.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.entries});

  final List<(String, String?)> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<(String, String)> filtered = entries
        .where((entry) => entry.$2 != null && entry.$2!.trim().isNotEmpty)
        .map((entry) => (entry.$1, entry.$2!.trim()))
        .toList(growable: false);
    if (filtered.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.detailsCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: filtered
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        entry.$1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.$2,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.94),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
