import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/presentation/features/home/providers/library_retention_provider.dart';
import 'package:cineverse/presentation/features/home/providers/reminders_provider.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ReleaseCalendarScreen extends ConsumerWidget {
  const ReleaseCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<LibraryRetentionBundle> bundleAsync = ref.watch(
      libraryRetentionBundleProvider,
    );

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Release Calendar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        body: bundleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load release tracking.\n$error',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          data: (LibraryRetentionBundle bundle) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              children: <Widget>[
                _SummaryStrip(health: bundle.health),
                const SizedBox(height: 18),
                _SectionHeader(
                  title: 'Watch next from your library',
                  subtitle: 'Fast picks based on what you already saved.',
                ),
                const SizedBox(height: 12),
                if (bundle.health.watchNextSuggestions.isEmpty)
                  const _EmptyPanel(
                    title: 'No watch-next suggestions yet',
                    subtitle:
                        'Add more movies or shows to your watchlist, favourites, or lists.',
                  )
                else
                  ...bundle.health.watchNextSuggestions.map(
                    (WatchNextSuggestion item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _WatchNextCard(item: item),
                    ),
                  ),
                const SizedBox(height: 8),
                _SectionHeader(
                  title: 'Upcoming from your library',
                  subtitle:
                      'Movie releases and next TV episodes with one-tap reminders.',
                ),
                const SizedBox(height: 12),
                if (bundle.upcomingEntries.isEmpty)
                  const _EmptyPanel(
                    title: 'Nothing upcoming right now',
                    subtitle:
                        'When tracked movies get release dates or shows have new episodes scheduled, they will appear here.',
                  )
                else
                  ...bundle.upcomingEntries.map(
                    (ReleaseCalendarEntry item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReleaseCalendarCard(item: item),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.health});

  final LibraryHealthSnapshot health;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            label: 'Upcoming',
            value: '${health.upcomingCount}',
            icon: Icons.event_available_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Stale watchlist',
            value: '${health.staleWatchlistCount}',
            icon: Icons.timelapse_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Tracked',
            value: '${health.trackedTitlesCount}',
            icon: Icons.layers_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cinemaBorder.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.cinemaSelected, size: 18),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchNextCard extends StatelessWidget {
  const _WatchNextCard({required this.item});

  final WatchNextSuggestion item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        context.pushNamed(
          AppRoute.movieDetails.name,
          pathParameters: <String, String>{'movieId': item.mediaId.toString()},
          queryParameters: <String, String>{'isTv': item.isTv.toString()},
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.cinemaBorder.withValues(alpha: 0.24),
          ),
        ),
        child: Row(
          children: <Widget>[
            _PosterPill(posterPath: item.posterPath, isTv: item.isTv),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.reason,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.76),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _TinyBadge(label: item.isTv ? 'TV' : 'Movie'),
                      if (item.voteAverage != null)
                        _TinyBadge(
                          label: '${item.voteAverage!.toStringAsFixed(1)} ★',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseCalendarCard extends ConsumerWidget {
  const _ReleaseCalendarCard({required this.item});

  final ReleaseCalendarEntry item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String dateLabel = DateFormat(
      'EEE, d MMM • hh:mm a',
    ).format(item.date);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        context.pushNamed(
          AppRoute.movieDetails.name,
          pathParameters: <String, String>{'movieId': item.mediaId.toString()},
          queryParameters: <String, String>{'isTv': item.isTv.toString()},
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.cinemaBorder.withValues(alpha: 0.24),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _PosterPill(posterPath: item.posterPath, isTv: item.isTv),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _TinyBadge(
                        label:
                            item.kind == ReleaseCalendarEntryKind.movieRelease
                            ? 'Movie release'
                            : 'Next episode',
                      ),
                      ...item.sourceLabels.map(
                        (String source) => _TinyBadge(label: source),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.cinemaSelected,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              tooltip: 'Remind me',
              onPressed: () async {
                final DateTime notifyAt =
                    item.kind == ReleaseCalendarEntryKind.movieRelease
                    ? DateTime(
                        item.date.year,
                        item.date.month,
                        item.date.day,
                        9,
                      )
                    : item.date.subtract(const Duration(hours: 1));
                final AppReminder reminder = AppReminder(
                  id: buildReminderId(),
                  type: item.kind == ReleaseCalendarEntryKind.movieRelease
                      ? ReminderType.general
                      : ReminderType.episodeAiring,
                  title: item.title,
                  message: item.kind == ReleaseCalendarEntryKind.movieRelease
                      ? '${item.title} releases today.'
                      : '${item.title} ${item.subtitle.toLowerCase()} airs soon.',
                  notifyAt: notifyAt.isAfter(DateTime.now())
                      ? notifyAt
                      : DateTime.now().add(const Duration(minutes: 1)),
                  createdAt: DateTime.now(),
                  mediaId: item.mediaId,
                  isTv: item.isTv,
                  backdropPath: item.backdropPath,
                  seasonNumber: item.seasonNumber,
                  episodeNumber: item.episodeNumber,
                  airDate: item.date,
                );
                await ref
                    .read(remindersProvider.notifier)
                    .addReminder(reminder);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      item.kind == ReleaseCalendarEntryKind.movieRelease
                          ? 'Release reminder set for ${item.title}.'
                          : 'Episode reminder set for ${item.title}.',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications_active_outlined,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterPill extends StatelessWidget {
  const _PosterPill({required this.posterPath, required this.isTv});

  final String? posterPath;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 62,
        height: 92,
        color: Colors.white.withValues(alpha: 0.08),
        child: posterPath == null
            ? Icon(
                isTv ? Icons.live_tv_rounded : Icons.movie_creation_outlined,
                color: Colors.white54,
              )
            : Image.network(posterPath!, fit: BoxFit.cover),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
