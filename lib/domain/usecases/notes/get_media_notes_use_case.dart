import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/movie_note.dart';
import 'package:cineverse/domain/repositories/notes_repository.dart';

class GetMediaNotesUseCase {
  GetMediaNotesUseCase(this._repository);
  final NotesRepository _repository;

  Future<List<MovieNote>> call(int mediaId, GlobalMediaType mediaType) =>
      _repository.getNotesForMedia(mediaId, mediaType);
}
