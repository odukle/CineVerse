import 'package:cineverse/data/datasources/local/app_database.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/domain/repositories/notes_repository.dart';
import 'package:drift/drift.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<MovieNote>> getNotesForMedia(int mediaId, GlobalMediaType mediaType) async {
    final query = _database.select(_database.movieNotesTable)
      ..where((t) => t.movieId.equals(mediaId) & t.mediaType.equals(mediaType.index))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    
    final results = await query.get();
    return results
        .map(
          (row) => MovieNote(
            id: row.id,
            movieId: row.movieId,
            mediaType: row.mediaType,
            text: row.noteText,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<List<MovieNote>> getAllNotes() async {
    final query = _database.select(_database.movieNotesTable)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    
    final results = await query.get();
    return results
        .map(
          (row) => MovieNote(
            id: row.id,
            movieId: row.movieId,
            mediaType: row.mediaType,
            text: row.noteText,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> addNote(int mediaId, GlobalMediaType mediaType, String text) async {
    await _database.into(_database.movieNotesTable).insert(
      MovieNotesTableCompanion.insert(
        movieId: mediaId,
        mediaType: Value(mediaType),
        noteText: text,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateNote(int id, String text) async {
    await (_database.update(_database.movieNotesTable)
          ..where((t) => t.id.equals(id)))
        .write(MovieNotesTableCompanion(noteText: Value(text)));
  }

  @override
  Future<void> deleteNote(int id) async {
    await (_database.delete(_database.movieNotesTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}
