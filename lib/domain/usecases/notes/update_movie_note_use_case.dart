import 'package:cineverse/domain/repositories/notes_repository.dart';

class UpdateMovieNoteUseCase {
  UpdateMovieNoteUseCase(this._repository);

  final NotesRepository _repository;

  Future<void> call(int id, String text) {
    return _repository.updateNote(id, text);
  }
}
