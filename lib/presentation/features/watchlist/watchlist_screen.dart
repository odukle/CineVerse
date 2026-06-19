import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/domain/entities/library_item.dart';
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/notes_provider.dart';
import 'package:cineverse/presentation/features/movies/widgets/media_poster_grid_card.dart';
import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
import 'package:cineverse/presentation/widgets/tab_content_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cineverse/presentation/features/watchlist/providers/shared_named_list_provider.dart';

enum LibrarySection {
  watchlist('watchlist', 'Watchlist'),
  favourites('favourites', 'Favourites'),
  lists('lists', 'Lists'),
  notes('notes', 'Notes'),
  watched('watched', 'Watched');

  const LibrarySection(this.slug, this.label);

  final String slug;
  final String label;

  static LibrarySection fromSlug(String slug) {
    return LibrarySection.values.firstWhere(
      (section) => section.slug == slug,
      orElse: () => LibrarySection.watchlist,
    );
  }
}

enum LibraryMediaFilter {
  all('All'),
  movies('Movies'),
  tv('TV');

  const LibraryMediaFilter(this.label);

  final String label;
}

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key, this.openSectionSlug});

  final String? openSectionSlug;

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  bool _openedInitialSection = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_openedInitialSection) {
      return;
    }
    final String? openSectionSlug = widget.openSectionSlug;
    if (openSectionSlug == null || openSectionSlug.isEmpty) {
      return;
    }
    _openedInitialSection = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.pushNamed(
        AppRoute.librarySection.name,
        pathParameters: {'section': openSectionSlug},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchlistCount = ref.watch(watchlistProvider).value?.length;
    final favouritesCount = ref.watch(favouritesProvider).value?.length;
    final watchedCount = ref.watch(watchedItemsProvider).value?.length;
    final namedLists = ref.watch(namedListsProvider).value;
    final notesCount = ref.watch(allNotesProvider).value?.length;

    final cards = <_LibraryHubCardData>[
      _LibraryHubCardData(
        section: LibrarySection.watchlist,
        icon: Icons.bookmark_rounded,
        accent: const Color(0xFF63D3FF),
        countLabel: _countLabel(watchlistCount, 'title'),
        subtitle: 'Everything you plan to watch next.',
      ),
      _LibraryHubCardData(
        section: LibrarySection.favourites,
        icon: Icons.favorite_rounded,
        accent: const Color(0xFFFF6B7A),
        countLabel: _countLabel(favouritesCount, 'favourite'),
        subtitle: 'The titles you never want to lose.',
      ),
      _LibraryHubCardData(
        section: LibrarySection.lists,
        icon: Icons.list_alt_rounded,
        accent: const Color(0xFFFFB84D),
        countLabel: namedLists == null
            ? '...'
            : '${namedLists.length} ${namedLists.length == 1 ? "list" : "lists"}',
        subtitle: namedLists == null
            ? 'Curated collections you can organize and share.'
            : '${namedLists.fold<int>(0, (sum, list) => sum + list.items.length)} saved titles across your lists.',
      ),
      _LibraryHubCardData(
        section: LibrarySection.notes,
        icon: Icons.sticky_note_2_rounded,
        accent: const Color(0xFF8FBC8F),
        countLabel: _countLabel(notesCount, 'note'),
        subtitle: 'Your thoughts, reactions, and reminders.',
      ),
      _LibraryHubCardData(
        section: LibrarySection.watched,
        icon: Icons.check_circle_rounded,
        accent: const Color(0xFF9C88FF),
        countLabel: _countLabel(watchedCount, 'watched'),
        subtitle: 'Finished titles plus your history and stats.',
      ),
    ];

    return TabContentReveal(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.detailsCard.withValues(alpha: 0.96),
                      AppColors.detailsCard.withValues(alpha: 0.78),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.cinemaBorder.withValues(alpha: 0.22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cinemaGlow.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: -12,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Library',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep everything organized by collection, favourites, notes, and watch history.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final card = cards[index];
                return _LibraryHubCard(card: card);
              }, childCount: cards.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _countLabel(int? count, String noun) {
    if (count == null) return '...';
    return '$count ${count == 1 ? noun : '${noun}s'}';
  }
}

class LibrarySectionScreen extends ConsumerStatefulWidget {
  const LibrarySectionScreen({super.key, required this.section});

  final LibrarySection section;

  @override
  ConsumerState<LibrarySectionScreen> createState() =>
      _LibrarySectionScreenState();
}

class _LibrarySectionScreenState extends ConsumerState<LibrarySectionScreen> {
  LibraryMediaFilter _mediaFilter = LibraryMediaFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: TabContentReveal(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _LibraryMediaFilterBar(
                selected: _mediaFilter,
                onSelected: (filter) => setState(() => _mediaFilter = filter),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildSectionBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionBody() {
    return switch (widget.section) {
      LibrarySection.watchlist => _WatchlistTab(filter: _mediaFilter),
      LibrarySection.favourites => _FavouritesTab(filter: _mediaFilter),
      LibrarySection.lists => _ListsTab(filter: _mediaFilter),
      LibrarySection.notes => _NotesTab(filter: _mediaFilter),
      LibrarySection.watched => _WatchedTab(filter: _mediaFilter),
    };
  }
}

class _LibraryMediaFilterBar extends StatelessWidget {
  const _LibraryMediaFilterBar({
    required this.selected,
    required this.onSelected,
  });

  final LibraryMediaFilter selected;
  final ValueChanged<LibraryMediaFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: LibraryMediaFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = LibraryMediaFilter.values[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
            selectedColor: AppColors.cinemaAccent.withValues(alpha: 0.2),
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            side: BorderSide(
              color: isSelected
                  ? AppColors.cinemaGlow
                  : AppColors.cinemaBorder.withValues(alpha: 0.18),
            ),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.cinemaAccent : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}

bool _matchesLibraryMediaFilter(
  GlobalMediaType mediaType,
  LibraryMediaFilter filter,
) {
  return switch (filter) {
    LibraryMediaFilter.all =>
      mediaType == GlobalMediaType.movie || mediaType == GlobalMediaType.tv,
    LibraryMediaFilter.movies => mediaType == GlobalMediaType.movie,
    LibraryMediaFilter.tv => mediaType == GlobalMediaType.tv,
  };
}

class _LibraryHubCardData {
  const _LibraryHubCardData({
    required this.section,
    required this.icon,
    required this.accent,
    required this.countLabel,
    required this.subtitle,
  });

  final LibrarySection section;
  final IconData icon;
  final Color accent;
  final String countLabel;
  final String subtitle;
}

class _LibraryHubCard extends StatelessWidget {
  const _LibraryHubCard({required this.card});

  final _LibraryHubCardData card;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.selectionClick();
          context.pushNamed(
            AppRoute.librarySection.name,
            pathParameters: {'section': card.section.slug},
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                card.accent.withValues(alpha: 0.16),
                AppColors.detailsCard.withValues(alpha: 0.96),
              ],
            ),
            border: Border.all(color: card.accent.withValues(alpha: 0.24)),
            boxShadow: [
              BoxShadow(
                color: card.accent.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: -14,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: card.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: card.accent.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(card.icon, color: card.accent, size: 20),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.white.withValues(alpha: 0.42),
                      size: 18,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  card.section.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card.countLabel,
                  style: TextStyle(
                    color: card.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 12,
                    height: 1.4,
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

class _WatchlistTab extends ConsumerWidget {
  const _WatchlistTab({required this.filter});

  final LibraryMediaFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);
    return watchlistAsync.when(
      data: (items) {
        final filteredItems = items
            .where((e) => _matchesLibraryMediaFilter(e.mediaType, filter))
            .toList(growable: false);
        return _MediaGrid(
          items: filteredItems
              .map(
                (e) => MediaTitle(
                  id: e.id,
                  title: e.title,
                  posterPath: e.posterPath,
                  releaseDate: e.releaseDate,
                  mediaType: e.mediaType,
                  voteAverage: e.voteAverage,
                ),
              )
              .toList(),
          emptyLabel: 'No ${filter.label.toLowerCase()} in your watchlist',
          emptyIcon: Icons.bookmark_border_rounded,
        );
      },
      loading: () => const _LoadingGrid(),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _FavouritesTab extends ConsumerWidget {
  const _FavouritesTab({required this.filter});

  final LibraryMediaFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouritesAsync = ref.watch(favouritesProvider);
    return favouritesAsync.when(
      data: (items) {
        final filteredItems = items
            .where((e) => _matchesLibraryMediaFilter(e.mediaType, filter))
            .toList(growable: false);
        return _MediaGrid(
          items: filteredItems
              .map(
                (e) => MediaTitle(
                  id: e.id,
                  title: e.title,
                  posterPath: e.posterPath,
                  releaseDate: e.releaseDate,
                  mediaType: e.mediaType,
                  voteAverage: e.voteAverage,
                ),
              )
              .toList(),
          emptyLabel: 'No ${filter.label.toLowerCase()} in favourites',
          emptyIcon: Icons.favorite_border_rounded,
        );
      },
      loading: () => const _LoadingGrid(),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _WatchedTab extends ConsumerWidget {
  const _WatchedTab({required this.filter});

  final LibraryMediaFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedAsync = ref.watch(watchedItemsProvider);
    return watchedAsync.when(
      data: (items) => _WatchedScrollableContent(
        filter: filter,
        items: items
            .where((e) => _matchesLibraryMediaFilter(e.mediaType, filter))
            .map(
              (e) => MediaTitle(
                id: e.id,
                title: e.title,
                posterPath: e.posterPath,
                releaseDate: e.watchDate.year.toString(),
                mediaType: e.mediaType,
                voteAverage: e.voteAverage,
              ),
            )
            .toList(),
      ),
      loading: () => const _LoadingGrid(),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _WatchedScrollableContent extends StatelessWidget {
  const _WatchedScrollableContent({required this.items, required this.filter});

  final List<MediaTitle> items;
  final LibraryMediaFilter filter;

  @override
  Widget build(BuildContext context) {
    const double crossAxisSpacing = 12;
    const int crossAxisCount = 3;
    final double cardWidth =
        (MediaQuery.sizeOf(context).width - (16 * 2) - (crossAxisSpacing * 2)) /
        crossAxisCount;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _WatchHistoryAnalyticsCard(),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 64,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No ${filter.label.toLowerCase()} in watched',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final media = items[index];
                return MediaPosterGridCard(
                  movie: media,
                  sectionTitle: 'library',
                  width: cardWidth,
                  isTvTitle: media.mediaType == GlobalMediaType.tv,
                  enableWatchlistUndoOnRemove: true,
                );
              }, childCount: items.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: 16,
                childAspectRatio: 0.55,
              ),
            ),
          ),
      ],
    );
  }
}

class _WatchHistoryAnalyticsCard extends StatelessWidget {
  const _WatchHistoryAnalyticsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: AppColors.cinemaPanelGradient),
        border: Border.all(
          color: AppColors.cinemaBorder.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cinemaGlow.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.selectionClick();
            context.pushNamed(AppRoute.watchAnalytics.name);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cinemaAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cinemaAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: AppColors.cinemaAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Watch History Analytics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'View personalized insights, charts, and trends.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListsTab extends ConsumerWidget {
  const _ListsTab({required this.filter});
  final LibraryMediaFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(namedListsProvider);

    return listsAsync.when(
      data: (lists) {
        if (lists.isEmpty) {
          return const Center(
            child: Text(
              'No lists created yet.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        final filteredLists = lists
            .where(
              (list) =>
                  filter == LibraryMediaFilter.all ||
                  list.items.any(
                    (item) =>
                        _matchesLibraryMediaFilter(item.mediaType, filter),
                  ),
            )
            .toList(growable: false);

        if (filteredLists.isEmpty) {
          return _buildEmptyState(
            'No lists with ${filter.label.toLowerCase()}',
            Icons.list_rounded,
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.92,
          ),
          itemCount: filteredLists.length,
          itemBuilder: (context, index) {
            final list = filteredLists[index];
            final matchingItems = list.items
                .where(
                  (item) => _matchesLibraryMediaFilter(item.mediaType, filter),
                )
                .toList(growable: false);
            final previewItem = matchingItems.isEmpty
                ? null
                : matchingItems.first;
            return _NamedListCard(
              list: list,
              matchingCount: matchingItems.length,
              previewItem: previewItem,
              onTap: () {
                HapticFeedback.selectionClick();
                context.pushNamed(
                  AppRoute.libraryList.name,
                  pathParameters: {'listId': list.id.toString()},
                  queryParameters: {'filter': filter.name},
                );
              },
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppColors.cinemaAccent),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEmptyState(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListActions(
    BuildContext context,
    WidgetRef ref,
    NamedList selectedList,
  ) {
    final canShare = selectedList.items.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: canShare
                  ? () => _shareList(context, ref, selectedList)
                  : null,
              icon: Icon(
                Icons.share_rounded,
                color: canShare ? Colors.white : Colors.white38,
                size: 18,
              ),
              label: Text(
                'Share',
                style: TextStyle(
                  color: canShare ? Colors.white : Colors.white38,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                backgroundColor: canShare
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.03),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextButton.icon(
              onPressed: () => _showRenameDialog(context, ref, selectedList),
              icon: Icon(
                Icons.edit_rounded,
                color: AppColors.cinemaAccent,
                size: 18,
              ),
              label: Text(
                'Rename',
                style: TextStyle(color: AppColors.cinemaAccent, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                backgroundColor: AppColors.cinemaAccent.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextButton.icon(
              onPressed: () => _confirmDeleteList(context, ref, selectedList),
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              label: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareList(
    BuildContext context,
    WidgetRef ref,
    NamedList list,
  ) async {
    try {
      final shareLink = await ref
          .read(sharedNamedListServiceProvider)
          .createShareLink(list);
      final itemLabel = list.items.length == 1 ? 'title' : 'titles';
      await Share.share(
        'Import "${list.name}" into Lumi (${list.items.length} $itemLabel): $shareLink',
        subject: list.name,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ToastUtils.showToast(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, NamedList list) {
    final controller = TextEditingController(text: list.name);
    showAnimatedDialog(
      context: context,
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
          'Rename List',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new name...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cinemaAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != list.name) {
                await ref
                    .read(namedListsProvider.notifier)
                    .renameList(list.id, newName);
                if (context.mounted) {
                  Navigator.pop(context);
                  ToastUtils.showToast(context, 'List renamed to "$newName"');
                }
              } else {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cinemaAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Rename',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteList(BuildContext context, WidgetRef ref, NamedList list) {
    showAnimatedDialog(
      context: context,
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
          'Delete List?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${list.name}"?',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white60),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(namedListsProvider.notifier).deleteList(list.id);
              if (context.mounted) {
                Navigator.pop(context);
                ToastUtils.showToast(context, 'List "${list.name}" deleted');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class NamedListDetailsScreen extends ConsumerWidget {
  const NamedListDetailsScreen({
    super.key,
    required this.listId,
    required this.filter,
  });

  final int listId;
  final LibraryMediaFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(namedListsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: listsAsync.when(
        data: (lists) {
          NamedList? selectedList;
          for (final list in lists) {
            if (list.id == listId) {
              selectedList = list;
              break;
            }
          }

          if (selectedList == null) {
            return _buildEmptyState(
              'This list no longer exists',
              Icons.list_alt,
            );
          }

          final mediaTitles = selectedList.items
              .where((e) => _matchesLibraryMediaFilter(e.mediaType, filter))
              .map(
                (e) => MediaTitle(
                  id: e.mediaId,
                  title: e.title,
                  posterPath: e.posterPath,
                  releaseDate: e.releaseDate,
                  mediaType: e.mediaType,
                  voteAverage: e.voteAverage,
                ),
              )
              .toList(growable: false);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedList.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${mediaTitles.length} ${mediaTitles.length == 1 ? "title" : "titles"} shown',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.64),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: mediaTitles.isEmpty
                    ? _buildEmptyState(
                        'No ${filter.label.toLowerCase()} in this list',
                        Icons.list_rounded,
                      )
                    : _NamedListMediaGrid(items: mediaTitles),
              ),
              _ListsTab(
                filter: filter,
              )._buildListActions(context, ref, selectedList),
            ],
          );
        },
        loading: () => const _LoadingGrid(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NamedListCard extends StatelessWidget {
  const _NamedListCard({
    required this.list,
    required this.matchingCount,
    required this.previewItem,
    required this.onTap,
  });

  final NamedList list;
  final int matchingCount;
  final NamedListItem? previewItem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cinemaAccent.withValues(alpha: 0.14),
                AppColors.detailsCard.withValues(alpha: 0.96),
              ],
            ),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.22),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.cinemaAccent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.list_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.white.withValues(alpha: 0.42),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Text(
                    list.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$matchingCount ${matchingCount == 1 ? "title" : "titles"}',
                  style: TextStyle(
                    color: AppColors.cinemaAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  previewItem?.title ?? 'Open list',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 12,
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

class _NamedListMediaGrid extends StatelessWidget {
  const _NamedListMediaGrid({required this.items});

  final List<MediaTitle> items;

  @override
  Widget build(BuildContext context) {
    const double crossAxisSpacing = 12;
    const int crossAxisCount = 3;
    final double cardWidth =
        (MediaQuery.sizeOf(context).width - (16 * 2) - (crossAxisSpacing * 2)) /
        crossAxisCount;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final media = items[index];
        return MediaPosterGridCard(
          movie: media,
          sectionTitle: 'library',
          width: cardWidth,
          isTvTitle: media.mediaType == GlobalMediaType.tv,
          enableWatchlistUndoOnRemove: true,
        );
      },
    );
  }
}

class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.filter});

  final LibraryMediaFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(allNotesProvider);

    return notesAsync.when(
      skipLoadingOnReload: !notesAsync.hasError,
      data: (notes) {
        final List<MovieNote> filteredNotes = notes
            .where((note) => _matchesLibraryMediaFilter(note.mediaType, filter))
            .toList(growable: false);
        if (filteredNotes.isEmpty) {
          return const Center(
            child: Text(
              'No notes found.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        final List<_GroupedNotesEntry> groupedNotes = _groupNotesByTitle(
          filteredNotes,
        );

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          itemCount: groupedNotes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              _NoteListTile(entry: groupedNotes[index]),
        );
      },
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const ShimmerEffect(
          width: double.infinity,
          height: 114,
          borderRadius: 12,
        ),
      ),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Error: $err',
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(allNotesProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinemaAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<_GroupedNotesEntry> _groupNotesByTitle(List<MovieNote> notes) {
    final Map<String, List<MovieNote>> grouped = <String, List<MovieNote>>{};
    for (final MovieNote note in notes) {
      final String key = '${note.mediaType.index}-${note.movieId}';
      grouped.putIfAbsent(key, () => <MovieNote>[]).add(note);
    }

    final List<_GroupedNotesEntry> entries = grouped.values
        .map((List<MovieNote> group) {
          group.sort(
            (MovieNote a, MovieNote b) => b.createdAt.compareTo(a.createdAt),
          );
          return _GroupedNotesEntry(
            movieId: group.first.movieId,
            mediaType: group.first.mediaType,
            representativeNote: group.first,
            noteCount: group.length,
            latestCreatedAt: group.first.createdAt,
          );
        })
        .toList(growable: false);

    entries.sort(
      (_GroupedNotesEntry a, _GroupedNotesEntry b) =>
          b.latestCreatedAt.compareTo(a.latestCreatedAt),
    );
    return entries;
  }
}

class _NoteListTile extends ConsumerWidget {
  const _NoteListTile({required this.entry});

  final _GroupedNotesEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetailsAsync = ref.watch(
      movieDetailsProvider(
        GetMovieDetailsParams(
          movieId: entry.movieId,
          isTv: entry.mediaType == GlobalMediaType.tv,
        ),
      ),
    );
    final dateFormat = DateFormat('MMM d, yyyy');

    return movieDetailsAsync.when(
      data: (details) => InkWell(
        onTap: () => context.pushNamed(
          AppRoute.noteDetails.name,
          pathParameters: {'noteId': entry.representativeNote.id.toString()},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.cinemaPanelGradient
                  .map((color) => color.withValues(alpha: 0.72))
                  .toList(growable: false),
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.cinemaBorder.withValues(alpha: 0.24),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 90,
                  child: Hero(
                    tag:
                        'note-poster-${entry.movieId}-${entry.mediaType.index}',
                    child: details.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl: details.posterPath!,
                            fit: BoxFit.cover,
                          )
                        : ColoredBox(color: AppColors.detailsPosterSurface),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.noteCount} note${entry.noteCount == 1 ? '' : 's'} • ${dateFormat.format(entry.latestCreatedAt)}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.representativeNote.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const ShimmerEffect(
        width: double.infinity,
        height: 114,
        borderRadius: 12,
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _GroupedNotesEntry {
  const _GroupedNotesEntry({
    required this.movieId,
    required this.mediaType,
    required this.representativeNote,
    required this.noteCount,
    required this.latestCreatedAt,
  });

  final int movieId;
  final GlobalMediaType mediaType;
  final MovieNote representativeNote;
  final int noteCount;
  final DateTime latestCreatedAt;
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({
    required this.items,
    required this.emptyLabel,
    required this.emptyIcon,
  });

  final List<MediaTitle> items;
  final String emptyLabel;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),
            Text(
              emptyLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.52),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    const double crossAxisSpacing = 12;
    const int crossAxisCount = 3;
    final double cardWidth =
        (MediaQuery.sizeOf(context).width - (16 * 2) - (crossAxisSpacing * 2)) /
        crossAxisCount;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final media = items[index];
        return MediaPosterGridCard(
          movie: media,
          sectionTitle: 'library',
          width: cardWidth,
          isTvTitle: media.mediaType == GlobalMediaType.tv,
          enableWatchlistUndoOnRemove: true,
        );
      },
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: 9,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerEffect.poster(width: double.infinity, height: 153),
          const SizedBox(height: 12),
          ShimmerEffect.textLine(width: 80, height: 12),
        ],
      ),
    );
  }
}
