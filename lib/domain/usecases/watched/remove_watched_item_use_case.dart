import 'package:cineverse/domain/repositories/watched_repository.dart';

class RemoveWatchedItemUseCase {
  RemoveWatchedItemUseCase(this._repository);
  final WatchedRepository _repository;

  Future<void> call(int id) => _repository.removeFromWatched(id);
}
