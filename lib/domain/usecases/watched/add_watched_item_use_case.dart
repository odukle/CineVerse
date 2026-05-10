import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';

class AddWatchedItemUseCase {
  AddWatchedItemUseCase(this._repository);
  final WatchedRepository _repository;

  Future<void> call(WatchedItem item) => _repository.addToWatched(item);
}
