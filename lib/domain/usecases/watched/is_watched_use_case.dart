import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';

class IsWatchedUseCase {
  IsWatchedUseCase(this._repository);
  final WatchedRepository _repository;

  Future<bool> call(int id, GlobalMediaType mediaType) =>
      _repository.isWatched(id, mediaType);
}
