import 'package:cineverse/domain/repositories/notes_repository.dart';

class DeleteMovieNoteUseCase {
  DeleteMovieNoteUseCase(this._repository);
  final NotesRepository _repository;

  Future<void> call(int id) => _repository.deleteNote(id);
}
