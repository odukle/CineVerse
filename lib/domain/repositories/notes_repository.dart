import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_note.dart';

abstract class NotesRepository {
  Future<List<MovieNote>> getNotesForMedia(int mediaId, GlobalMediaType mediaType);
  Future<List<MovieNote>> getAllNotes();
  Future<void> addNote(int mediaId, GlobalMediaType mediaType, String text);
  Future<void> deleteNote(int id);
}
