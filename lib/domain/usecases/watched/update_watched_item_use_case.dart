import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';

class UpdateWatchedItemUseCase {
  UpdateWatchedItemUseCase(this._repository);
  final WatchedRepository _repository;

  Future<void> call(WatchedItem item) => _repository.updateWatchedItem(item);
}
