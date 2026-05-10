import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';

class GetWatchedItemsUseCase {
  GetWatchedItemsUseCase(this._repository);
  final WatchedRepository _repository;

  Future<List<WatchedItem>> call() => _repository.getWatchedItems();
}
