import 'dart:async';
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
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  int? _selectedListId;

  @override
  Widget build(BuildContext context) {
    return BackgroundGradient(
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(84),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: LinearGradient(
                      colors: AppColors.cinemaPanelGradient,
                    ),
                    border: Border.all(
                      color: AppColors.cinemaBorder.withValues(alpha: 0.28),
                    ),
                  ),
                  child: const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.symmetric(vertical: 2),
                    labelPadding: EdgeInsets.symmetric(horizontal: 14),
                    tabs: [
                      Tab(text: 'Watchlist'),
                      Tab(text: 'Favourites'),
                      Tab(text: 'Lists'),
                      Tab(text: 'Notes'),
                      Tab(text: 'Watched'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              const _WatchlistTab(),
              const _FavouritesTab(),
              _ListsTab(
                selectedListId: _selectedListId,
                onListSelected: (id) => setState(() => _selectedListId = id),
              ),
              const _NotesTab(),
              const _WatchedTab(),
            ],
          ),
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
      data: (items) => _MediaGrid(
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
        emptyLabel: 'Your watched list is empty',
        emptyIcon: Icons.check_circle_outline_rounded,
      ),
      loading: () => const _LoadingGrid(),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          const SizedBox(width: 16),
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

  void _showRenameDialog(BuildContext context, WidgetRef ref, NamedList list) {
    final controller = TextEditingController(text: list.name);
    showAnimatedDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        title: const Text('Rename List', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new name...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
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
            ),
            child: const Text('Rename', style: TextStyle(color: Colors.black)),
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
        title: const Text(
          'Delete List?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${list.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
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
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
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
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          itemCount: notes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _NoteListTile(note: notes[index]),
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
}

class _NoteListTile extends ConsumerWidget {
  const _NoteListTile({required this.note});

  final MovieNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetailsAsync = ref.watch(
      movieDetailsProvider(
        GetMovieDetailsParams(
          movieId: note.movieId,
          isTv: note.mediaType == GlobalMediaType.tv,
        ),
      ),
    );
    final dateFormat = DateFormat('MMM d, yyyy');

    return movieDetailsAsync.when(
      data: (details) => Stack(
        children: [
          InkWell(
            onTap: () => context.pushNamed(
              AppRoute.noteDetails.name,
              pathParameters: {'noteId': note.id.toString()},
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
                        tag: 'note-poster-${note.id}',
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
                          dateFormat.format(note.createdAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.text,
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
                  const SizedBox(width: 32), // Space for delete icon
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white24,
                size: 20,
              ),
              onPressed: () => _handleDelete(context, ref),
              tooltip: 'Delete Note',
            ),
          ),
        ],
      ),
      loading: () => const ShimmerEffect(
        width: double.infinity,
        height: 114,
        borderRadius: 12,
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(movieNotesActionsProvider);

    final deletedNoteText = note.text;
    final deletedNoteMediaId = note.movieId;
    final deletedNoteMediaType = note.mediaType;

    await actions.deleteNote(note.movieId, note.mediaType, note.id);

    if (!context.mounted) return;
    ToastUtils.showToast(
      context,
      'Note deleted',
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'UNDO',
        textColor: AppColors.cinemaAccent,
        onPressed: () async {
          await actions.addNote(
            deletedNoteMediaId,
            deletedNoteMediaType,
            deletedNoteText,
          );
        },
      ),
    );
  }
}

class _UndoSnackBarContent extends StatefulWidget {
  const _UndoSnackBarContent({required this.onUndo});
  final VoidCallback onUndo;

  @override
  State<_UndoSnackBarContent> createState() => _UndoSnackBarContentState();
}

class _UndoSnackBarContentState extends State<_UndoSnackBarContent> {
  int _remaining = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining > 1) {
        setState(() => _remaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Note deleted (${_remaining}s)',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onUndo();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: Text(
            'UNDO',
            style: TextStyle(
              color: AppColors.cinemaAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
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
