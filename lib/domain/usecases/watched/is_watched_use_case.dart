import 'package:cineverse/domain/repositories/watched_repository.dart';

class IsWatchedUseCase {
  IsWatchedUseCase(this._repository);
  final WatchedRepository _repository;

  Future<bool> call(int id) => _repository.isWatched(id);
}
