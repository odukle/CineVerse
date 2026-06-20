import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/presentation/features/movie_details/providers/notes_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart'
    show movieDetailsProvider;
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart'
    show GetMovieDetailsParams;
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(allNotesProvider);

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.l10n.allNotes,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: notesAsync.when(
        skipLoadingOnReload: !notesAsync.hasError,
        data: (notes) {
          if (notes.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noNotesFound,
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
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
                context.l10n.errorGeneric(err.toString()),
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allNotesProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cinemaAccent,
                  foregroundColor: Colors.black,
                ),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
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
                color: AppColors.detailsCard.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                            : ColoredBox(
                                color: AppColors.detailsPosterSurface,
                              ),
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
              tooltip: context.l10n.deleteNote,
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

    // Save data for undo
    final deletedNoteText = note.text;
    final deletedNoteMediaId = note.movieId;
    final deletedNoteMediaType = note.mediaType;

    // Actually delete
    await actions.deleteNote(note.movieId, note.mediaType, note.id);

    if (!context.mounted) return;
    ToastUtils.showToast(
      context,
      context.l10n.noteDeleted,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: context.l10n.undo,
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
            context.l10n.noteDeletedWithCount(_remaining),
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
            context.l10n.undo,
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
