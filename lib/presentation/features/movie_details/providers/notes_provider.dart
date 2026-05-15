import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/domain/usecases/notes/add_media_note_use_case.dart';
import 'package:cineverse/domain/usecases/notes/delete_movie_note_use_case.dart';
import 'package:cineverse/domain/usecases/notes/get_all_notes_use_case.dart';
import 'package:cineverse/domain/usecases/notes/get_media_notes_use_case.dart';
import 'package:cineverse/domain/usecases/notes/update_movie_note_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getMediaNotesUseCaseProvider = Provider<GetMediaNotesUseCase>((ref) {
  return GetMediaNotesUseCase(ref.watch(notesRepositoryProvider));
});

final getAllNotesUseCaseProvider = Provider<GetAllNotesUseCase>((ref) {
  return GetAllNotesUseCase(ref.watch(notesRepositoryProvider));
});

final addMediaNoteUseCaseProvider = Provider<AddMediaNoteUseCase>((ref) {
  return AddMediaNoteUseCase(ref.watch(notesRepositoryProvider));
});

final deleteMovieNoteUseCaseProvider = Provider<DeleteMovieNoteUseCase>((ref) {
  return DeleteMovieNoteUseCase(ref.watch(notesRepositoryProvider));
});

final updateMovieNoteUseCaseProvider = Provider<UpdateMovieNoteUseCase>((ref) {
  return UpdateMovieNoteUseCase(ref.watch(notesRepositoryProvider));
});

typedef MediaNoteParams = ({int id, GlobalMediaType type});

final mediaNotesProvider = FutureProvider.family<List<MovieNote>, MediaNoteParams>((ref, params) async {
  return ref.watch(getMediaNotesUseCaseProvider).call(params.id, params.type);
});

final allNotesProvider = FutureProvider<List<MovieNote>>((ref) async {
  return ref.watch(getAllNotesUseCaseProvider).call();
});

class MovieNotesActions {
  MovieNotesActions(this._ref);
  final Ref _ref;

  Future<void> addNote(int mediaId, GlobalMediaType type, String text) async {
    await _ref.read(addMediaNoteUseCaseProvider).call(mediaId, type, text);
    _ref.invalidate(mediaNotesProvider((id: mediaId, type: type)));
    _ref.invalidate(allNotesProvider);
  }

  Future<void> updateNote(int mediaId, GlobalMediaType type, int noteId, String text) async {
    await _ref.read(updateMovieNoteUseCaseProvider).call(noteId, text);
    _ref.invalidate(mediaNotesProvider((id: mediaId, type: type)));
    _ref.invalidate(allNotesProvider);
  }

  Future<void> deleteNote(int mediaId, GlobalMediaType type, int noteId) async {
    await _ref.read(deleteMovieNoteUseCaseProvider).call(noteId);
    _ref.invalidate(mediaNotesProvider((id: mediaId, type: type)));
    _ref.invalidate(allNotesProvider);
  }
}

final movieNotesActionsProvider = Provider<MovieNotesActions>((ref) {
  return MovieNotesActions(ref);
});
