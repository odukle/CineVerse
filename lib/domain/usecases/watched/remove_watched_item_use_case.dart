import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';

class RemoveWatchedItemUseCase {
  RemoveWatchedItemUseCase(this._repository);
  final WatchedRepository _repository;

  Future<void> call(int id, GlobalMediaType mediaType) =>
      _repository.removeFromWatched(id, mediaType);
}
