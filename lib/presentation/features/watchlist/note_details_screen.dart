import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cineverse/app/router/app_router.dart';
import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/utils/toast_utils.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/presentation/features/movie_details/providers/notes_provider.dart';
import 'package:cineverse/presentation/features/movie_details/providers/movie_details_provider.dart'
    show movieDetailsProvider;
import 'package:cineverse/domain/usecases/get_movie_details_use_case.dart'
    show GetMovieDetailsParams;
import 'package:cineverse/presentation/widgets/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cineverse/presentation/widgets/animated_dialog.dart';
import 'package:cineverse/presentation/widgets/media_actions_dialogs.dart';

class NoteDetailsScreen extends ConsumerWidget {
  const NoteDetailsScreen({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(allNotesProvider);

    return Scaffold(
      backgroundColor: AppColors.cinemaBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cinemaBackground,
        elevation: 0,
        title: const Text(
          'Notes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: notesAsync.when(
        skipLoadingOnReload: !notesAsync.hasError,
        data: (notes) {
          final MovieNote? note = notes.cast<MovieNote?>().firstWhere(
            (n) => n?.id == noteId,
            orElse: () => null,
          );

          if (note == null) {
            return const Center(
              child: Text(
                'Note not found.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final List<MovieNote> relatedNotes =
              notes
                  .where(
                    (MovieNote n) =>
                        n.movieId == note.movieId &&
                        n.mediaType == note.mediaType,
                  )
                  .toList(growable: false)
                ..sort(
                  (MovieNote a, MovieNote b) =>
                      b.createdAt.compareTo(a.createdAt),
                );

          final movieDetailsAsync = ref.watch(
            movieDetailsProvider(
              GetMovieDetailsParams(
                movieId: note.movieId,
                isTv: note.mediaType == GlobalMediaType.tv,
              ),
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                movieDetailsAsync.when(
                  data: (details) => GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        AppRoute.movieDetails.name,
                        pathParameters: {'movieId': details.id.toString()},
                        queryParameters: {
                          'isTv': (note.mediaType == GlobalMediaType.tv)
                              .toString(),
                        },
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 100,
                            height: 150,
                            child: Hero(
                              tag: 'note-poster-${note.id}',
                              child: details.posterPath != null
                                  ? CachedNetworkImage(
                                      imageUrl: details.posterPath!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const ShimmerEffect(
                                            width: 100,
                                            height: 150,
                                            borderRadius: 12,
                                          ),
                                    )
                                  : ColoredBox(
                                      color: AppColors.detailsPosterSurface,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              if (details.releaseDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    details.releaseDate!,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              if (details.genres.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    details.genres.join(', '),
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => Row(
                    children: [
                      const ShimmerEffect(
                        width: 100,
                        height: 150,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerEffect.textLine(width: 150, height: 20),
                            const SizedBox(height: 8),
                            ShimmerEffect.textLine(width: 80, height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),
                Text(
                  'Your Notes (${relatedNotes.length})',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: relatedNotes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final MovieNote item = relatedNotes[index];
                    return InkWell(
                      onTap: () {
                        showAnimatedDialog(
                          context: context,
                          builder: (context) => AddNoteDialog(
                            mediaId: item.movieId,
                            mediaType: item.mediaType,
                            initialNote: item,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.detailsCard.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'MMMM d, yyyy • HH:mm',
                                    ).format(item.createdAt),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () => _handleDelete(
                                    context,
                                    ref,
                                    item,
                                    popAfterDelete: relatedNotes.length == 1,
                                  ),
                                  tooltip: 'Delete Note',
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
      ),
    );
  }

  void _handleDelete(
    BuildContext context,
    WidgetRef ref,
    MovieNote note, {
    required bool popAfterDelete,
  }) async {
    final actions = ref.read(movieNotesActionsProvider);

    // Save data for undo
    final deletedNoteText = note.text;
    final deletedNoteMediaId = note.movieId;
    final deletedNoteMediaType = note.mediaType;

    // Actually delete
    await actions.deleteNote(note.movieId, note.mediaType, note.id);

    if (popAfterDelete && context.mounted) {
      context.pop();
    }

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
            'Note deleted ($_remaining s)',
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
