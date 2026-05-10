import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/domain/repositories/notes_repository.dart';

class GetAllNotesUseCase {
  GetAllNotesUseCase(this._repository);
  final NotesRepository _repository;

  Future<List<MovieNote>> call() => _repository.getAllNotes();
}
