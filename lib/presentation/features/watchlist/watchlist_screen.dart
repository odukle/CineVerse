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

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  int? _selectedListId;

  @override
  Widget build(BuildContext context) {
    return TabContentReveal(
      child: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: AppColors.cinemaPanelGradient,
                  ),
                  border: Border.all(
                    color: AppColors.cinemaBorder.withValues(alpha: 0.28),
                  ),
                ),
                child: TabBar(
                  onTap: (_) => HapticFeedback.selectionClick(),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(
                    color: AppColors.cinemaAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.cinemaAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 0,
                  ),
                  splashBorderRadius: BorderRadius.circular(999),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                  tabs: const <Tab>[
                    Tab(
                      child: SizedBox(
                        height: 28,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Watchlist',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: SizedBox(
                        height: 28,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Favourites',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: SizedBox(
                        height: 28,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Lists',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: SizedBox(
                        height: 28,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Notes',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: SizedBox(
                        height: 28,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Watched',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const _WatchlistTab(),
                  const _FavouritesTab(),
                  _ListsTab(
                    selectedListId: _selectedListId,
                    onListSelected: (id) =>
                        setState(() => _selectedListId = id),
                  ),
                  const _NotesTab(),
                  const _WatchedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistTab extends ConsumerWidget {
  const _WatchlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);
    return watchlistAsync.when(
      data: (items) => _MediaGrid(
        items: items
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
        emptyLabel: 'Your watchlist is empty',
        emptyIcon: Icons.bookmark_border_rounded,
      ),
      loading: () => const _LoadingGrid(),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _FavouritesTab extends ConsumerWidget {
  const _FavouritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouritesAsync = ref.watch(favouritesProvider);
    return favouritesAsync.when(
      data: (items) => _MediaGrid(
        items: items
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
        emptyLabel: 'No favourites yet',
        emptyIcon: Icons.favorite_border_rounded,
      ),
      loading: () => const _LoadingGrid(),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _WatchedTab extends ConsumerWidget {
  const _WatchedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedAsync = ref.watch(watchedItemsProvider);
    return watchedAsync.when(
      data: (items) => _WatchedScrollableContent(
        items: items
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
  const _WatchedScrollableContent({required this.items});

  final List<MediaTitle> items;

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
                    'Your watched list is empty',
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
  const _ListsTab({required this.selectedListId, required this.onListSelected});
  final int? selectedListId;
  final ValueChanged<int?> onListSelected;

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

        final currentId = selectedListId ?? lists.first.id;
        final selectedList = lists.firstWhere(
          (l) => l.id == currentId,
          orElse: () => lists.first,
        );

        return Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: lists.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final list = lists[index];
                  final isSelected = list.id == currentId;
                  return ChoiceChip(
                    label: Text(list.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) onListSelected(list.id);
                    },
                    selectedColor: AppColors.cinemaAccent.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.cinemaAccent
                          : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.cinemaGlow
                          : AppColors.cinemaBorder.withValues(alpha: 0.18),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<NamedListItem>>(
                future: ref
                    .read(namedListsProvider.notifier)
                    .getItemsForList(selectedList.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingGrid();
                  }
                  final items = snapshot.data ?? [];
                  final mediaTitles = items
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
                      .toList();

                  if (mediaTitles.isEmpty) {
                    return Column(
                      children: [
                        Expanded(
                          child: _buildEmptyState(
                            'This list is empty',
                            Icons.list_rounded,
                          ),
                        ),
                        if (lists.any((l) => l.id == currentId))
                          _buildListActions(context, ref, selectedList),
                      ],
                    );
                  }

                  const double crossAxisSpacing = 12;
                  const int crossAxisCount = 3;
                  final double cardWidth =
                      (MediaQuery.sizeOf(context).width -
                          (16 * 2) -
                          (crossAxisSpacing * 2)) /
                      crossAxisCount;

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: crossAxisSpacing,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.55,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final media = mediaTitles[index];
                            return MediaPosterGridCard(
                              movie: media,
                              sectionTitle: 'library',
                              width: cardWidth,
                              isTvTitle: media.mediaType == GlobalMediaType.tv,
                              enableWatchlistUndoOnRemove: true,
                            );
                          }, childCount: mediaTitles.length),
                        ),
                      ),
                      if (lists.any((l) => l.id == currentId))
                        SliverToBoxAdapter(
                          child: _buildListActions(context, ref, selectedList),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  );
                },
              ),
            ),
          ],
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
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          TextButton.icon(
            onPressed: canShare
                ? () => _shareList(context, ref, selectedList)
                : null,
            icon: Icon(
              Icons.share_rounded,
              color: canShare ? Colors.white : Colors.white38,
              size: 18,
            ),
            label: Text(
              'Share List',
              style: TextStyle(
                color: canShare ? Colors.white : Colors.white38,
                fontSize: 13,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: canShare
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => _showRenameDialog(context, ref, selectedList),
            icon: Icon(
              Icons.edit_rounded,
              color: AppColors.cinemaAccent,
              size: 18,
            ),
            label: Text(
              'Rename List',
              style: TextStyle(color: AppColors.cinemaAccent, fontSize: 13),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: AppColors.cinemaAccent.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => _confirmDeleteList(context, ref, selectedList),
            icon: const Icon(
              Icons.delete_sweep_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
            label: const Text(
              'Delete List',
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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

class _NotesTab extends ConsumerWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(allNotesProvider);

    return notesAsync.when(
      skipLoadingOnReload: !notesAsync.hasError,
      data: (notes) {
        if (notes.isEmpty) {
          return const Center(
            child: Text(
              'No notes found.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        final List<_GroupedNotesEntry> groupedNotes = _groupNotesByTitle(notes);

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
