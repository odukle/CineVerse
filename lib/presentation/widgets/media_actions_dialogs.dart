import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/library_item.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/presentation/features/watchlist/providers/library_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watched_provider.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/notes_provider.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'dart:ui';

class AddToListDialog extends StatefulWidget {
  const AddToListDialog({super.key, required this.details, required this.isTv});
  final MovieDetails details;
  final bool isTv;

  @override
  State<AddToListDialog> createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<AddToListDialog> {
  bool _addToWatchlist = false;
  final _newListNameController = TextEditingController();

  @override
  void dispose() {
    _newListNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final listsAsync = ref.watch(namedListsProvider);

        return AlertDialog(
          backgroundColor: AppColors.detailsCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          title: Text(
            context.l10n.lists,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                listsAsync.when(
                  data: (lists) {
                    if (lists.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          context.l10n.noItemsFound,
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    return Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: lists.length,
                        itemBuilder: (context, index) {
                          final list = lists[index];
                          final isInList = list.items.any(
                            (item) =>
                                item.mediaId == widget.details.id &&
                                item.mediaType ==
                                    (widget.isTv
                                        ? GlobalMediaType.tv
                                        : GlobalMediaType.movie),
                          );

                          return ListTile(
                            title: Text(
                              list.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Icon(
                              isInList ? Icons.remove : Icons.add,
                              color: isInList
                                  ? Colors.redAccent
                                  : AppColors.cinemaAccent,
                            ),
                            onTap: () {
                              if (isInList) {
                                ref
                                    .read(namedListsProvider.notifier)
                                    .removeItemFromList(
                                      list.id,
                                      widget.details.id,
                                      widget.isTv
                                          ? GlobalMediaType.tv
                                          : GlobalMediaType.movie,
                                    );
                                if (context.mounted) {
                                  ToastUtils.showToast(
                                    context,
                                    context.l10n.removedFromList(list.name),
                                  );
                                  Navigator.pop(context);
                                }
                              } else {
                                _addItemToList(ref, list.id);
                                if (context.mounted) {
                                  ToastUtils.showToast(
                                    context,
                                    _addToWatchlist
                                        ? context.l10n.addedToListAndWatchlist(
                                            list.name,
                                          )
                                        : context.l10n.addedToList(list.name),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Text(context.l10n.errorLoadingLists),
                ),
                const Divider(color: Colors.white10),
                TextField(
                  controller: _newListNameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: context.l10n.importSharedList,
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.03),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.cinemaAccent,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(
                    context.l10n.watchlist,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  value: _addToWatchlist,
                  onChanged: (val) =>
                      setState(() => _addToWatchlist = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.cinemaAccent,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white60),
              child: Text(
                context.l10n.cancel,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _newListNameController.text.trim();
                if (name.isNotEmpty) {
                  FocusScope.of(context).unfocus();
                  final newListId = await ref
                      .read(namedListsProvider.notifier)
                      .createList(name);

                  _addItemToList(ref, newListId);

                  if (context.mounted) {
                    ToastUtils.showToast(
                      context,
                      _addToWatchlist
                          ? context.l10n.addedToListAndWatchlist(name)
                          : context.l10n.addedToList(name),
                    );
                    Navigator.pop(context);
                  }
                  _newListNameController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinemaAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                context.l10n.save,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addItemToList(WidgetRef ref, int listId) {
    final item = NamedListItem(
      listId: listId,
      mediaId: widget.details.id,
      title: widget.details.title,
      posterPath: widget.details.posterPath,
      releaseDate: widget.details.releaseDate,
      mediaType: widget.isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
      addedDate: DateTime.now(),
      voteAverage: widget.details.catalogScore,
    );
    ref
        .read(namedListsProvider.notifier)
        .addItemToList(item: item, addToWatchlist: _addToWatchlist);
  }
}

class WatchedDialog extends StatefulWidget {
  const WatchedDialog({
    super.key,
    required this.details,
    required this.isTv,
    this.existingItem,
  });

  final MovieDetails details;
  final bool isTv;
  final WatchedItem? existingItem;

  @override
  State<WatchedDialog> createState() => _WatchedDialogState();
}

class _WatchedDialogState extends State<WatchedDialog> {
  late int _rating;
  late DateTime _watchDate;
  late int _rewatchCount;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingItem?.rating ?? 0;
    _watchDate = widget.existingItem?.watchDate ?? DateTime.now();
    _rewatchCount = widget.existingItem?.rewatchCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return AlertDialog(
      backgroundColor: AppColors.detailsCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      title: Text(
        isEditing ? context.l10n.editWatchedInfo : context.l10n.watched,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.rating,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.cinemaAccent,
                      size: 30,
                    ),
                  );
                }),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _rating == 0
                      ? null
                      : () => setState(() => _rating = 0),
                  style: TextButton.styleFrom(
                    foregroundColor: _rating == 0
                        ? Colors.white38
                        : Colors.white70,
                  ),
                  child: Text(
                    context.l10n.reset,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          if (_rating == 0)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                context.l10n.savedAsWatchedWithoutRating,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          SizedBox(height: 16),
          Text(
            context.l10n.watchDate,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _watchDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _watchDate = picked);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_watchDate.year}-${_watchDate.month.toString().padLeft(2, '0')}-${_watchDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.cinemaAccent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            context.l10n.rewatchCount,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _rewatchCount > 0
                    ? () => setState(() => _rewatchCount--)
                    : null,
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Colors.white70,
                ),
              ),
              Text(
                '$_rewatchCount',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              IconButton(
                onPressed: () => setState(() => _rewatchCount++),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (isEditing)
          Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () {
                Navigator.pop(context);
                _removeWatched(context, ref);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(
                context.l10n.delete,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.white60),
          child: Text(
            context.l10n.cancel,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Consumer(
          builder: (context, ref, _) => ElevatedButton(
            onPressed: () => _saveWatched(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cinemaAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              isEditing ? context.l10n.save : context.l10n.save,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _saveWatched(BuildContext context, WidgetRef ref) {
    final item = WatchedItem(
      id: widget.details.id,
      title: widget.details.title,
      posterPath: widget.details.posterPath,
      mediaType: widget.isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
      watchDate: _watchDate,
      rating: _rating,
      rewatchCount: _rewatchCount,
      voteAverage: widget.details.catalogScore,
    );

    final isUpdate = widget.existingItem != null;
    if (isUpdate) {
      ref.read(watchedItemsProvider.notifier).updateItem(item);
    } else {
      ref.read(watchedItemsProvider.notifier).addItem(item);
    }
    if (context.mounted) {
      ToastUtils.showToast(
        context,
        isUpdate ? context.l10n.watchedInfoUpdated : context.l10n.watched,
      );
      Navigator.pop(context);
    }
  }

  void _removeWatched(BuildContext context, WidgetRef ref) {
    showAnimatedDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) => AlertDialog(
          backgroundColor: AppColors.detailsCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          title: Text(
            context.l10n.delete,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            context.l10n.removeFromWatchedConfirmation,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.white60),
              child: Text(
                context.l10n.cancel,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(watchedItemsProvider.notifier)
                    .removeItem(
                      widget.details.id,
                      widget.isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
                    );
                if (context.mounted) {
                  ToastUtils.showToast(context, context.l10n.delete);
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(
                context.l10n.delete,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({
    super.key,
    required this.mediaId,
    required this.mediaType,
    this.initialNote,
  });
  final int mediaId;
  final GlobalMediaType mediaType;
  final MovieNote? initialNote;

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late final TextEditingController _controller;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote?.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialNote != null;

    return Consumer(
      builder: (context, ref, _) => AlertDialog(
        backgroundColor: AppColors.detailsCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        title: Text(
          isEditing ? context.l10n.notes : context.l10n.notes,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _controller,
          maxLines: 3,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: context.l10n.addNoteHint,
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
            child: Text(
              context.l10n.cancel,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    setState(() => _isSubmitting = true);
                    try {
                      if (isEditing) {
                        await ref
                            .read(movieNotesActionsProvider)
                            .updateNote(
                              widget.mediaId,
                              widget.mediaType,
                              widget.initialNote!.id,
                              text,
                            );
                        if (context.mounted) {
                          ToastUtils.showToast(context, context.l10n.save);
                          Navigator.pop(context);
                        }
                      } else {
                        await ref
                            .read(movieNotesActionsProvider)
                            .addNote(widget.mediaId, widget.mediaType, text);
                        if (context.mounted) {
                          ToastUtils.showToast(context, context.l10n.save);
                          Navigator.pop(context);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ToastUtils.showToast(
                          context,
                          isEditing
                              ? context.l10n.errorGeneric(e.toString())
                              : context.l10n.errorGeneric(e.toString()),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isSubmitting = false);
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
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    isEditing ? context.l10n.save : context.l10n.save,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}

class MediaActionsBottomSheet extends ConsumerWidget {
  const MediaActionsBottomSheet({
    super.key,
    required this.movie,
    required this.isTv,
  });

  final MediaTitle movie;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = isTv ? GlobalMediaType.tv : GlobalMediaType.movie;

    // Providers for current state
    final isFav = ref.watch(
      isFavouriteProvider((id: movie.id, type: mediaType)),
    );
    final isInWatchlist =
        ref.watch(isInWatchlistProvider(movie.id)).value ?? false;
    final isWatched =
        ref.watch(isWatchedProvider((id: movie.id, type: mediaType))).value ??
        false;
    final watchedItem = ref
        .watch(watchedItemProvider((id: movie.id, type: mediaType)))
        .value;

    final details = MovieDetails(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      releaseDate: movie.releaseDate,
      catalogScore: movie.voteAverage,
    );

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.detailsCard.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Movie Title & Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (movie.posterPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.posterPath!,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (movie.releaseDate != null)
                          Text(
                            movie.releaseDate!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10, height: 1),

            // Action items
            _ActionTile(
              icon: Icons.list_rounded,
              title: context.l10n.lists,
              onTap: () {
                Navigator.pop(context);
                showAnimatedDialog(
                  context: context,
                  builder: (context) =>
                      AddToListDialog(details: details, isTv: isTv),
                );
              },
            ),
            _ActionTile(
              icon: isFav
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
              iconColor: isFav ? Colors.redAccent : Colors.white,
              title: isFav ? context.l10n.favourites : context.l10n.favourites,
              onTap: () async {
                Navigator.pop(context);
                final item = FavouriteItem(
                  id: movie.id,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  releaseDate: movie.releaseDate,
                  mediaType: mediaType,
                  addedDate: DateTime.now(),
                  voteAverage: movie.voteAverage,
                );
                await ref
                    .read(favouritesProvider.notifier)
                    .toggleFavourite(item);
                if (context.mounted) {
                  ToastUtils.showToast(
                    context,
                    isFav ? context.l10n.favourites : context.l10n.favourites,
                  );
                }
              },
            ),
            _ActionTile(
              icon: isInWatchlist
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_add_outlined,
              iconColor: isInWatchlist ? AppColors.cinemaAccent : Colors.white,
              title: isInWatchlist
                  ? context.l10n.watchlist
                  : context.l10n.watchlist,
              onTap: () async {
                Navigator.pop(context);
                final item = WatchlistItem(
                  id: movie.id,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  releaseDate: movie.releaseDate,
                  mediaType: mediaType,
                  addedDate: DateTime.now(),
                  voteAverage: movie.voteAverage,
                );
                await ref.read(watchlistProvider.notifier).toggleItem(item);
                if (context.mounted) {
                  ToastUtils.showToast(
                    context,
                    isInWatchlist
                        ? context.l10n.watchlist
                        : context.l10n.watchlist,
                  );
                }
              },
            ),
            _ActionTile(
              icon: isWatched
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              iconColor: isWatched ? AppColors.cinemaAccent : Colors.white,
              title: isWatched ? context.l10n.watched : context.l10n.watched,
              onTap: () {
                Navigator.pop(context);
                showAnimatedDialog(
                  context: context,
                  builder: (context) => WatchedDialog(
                    details: details,
                    isTv: isTv,
                    existingItem: watchedItem,
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.note_add_rounded,
              title: context.l10n.notes,
              onTap: () {
                Navigator.pop(context);
                showAnimatedDialog(
                  context: context,
                  builder: (context) =>
                      AddNoteDialog(mediaId: movie.id, mediaType: mediaType),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      hoverColor: Colors.white10,
    );
  }
}
