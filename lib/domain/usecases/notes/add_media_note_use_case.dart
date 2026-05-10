import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/repositories/notes_repository.dart';

class AddMediaNoteUseCase {
  AddMediaNoteUseCase(this._repository);
  final NotesRepository _repository;

  Future<void> call(int mediaId, GlobalMediaType mediaType, String text) =>
      _repository.addNote(mediaId, mediaType, text);
}
