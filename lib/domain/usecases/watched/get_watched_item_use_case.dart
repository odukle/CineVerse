import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';

class GetWatchedItemUseCase {
  GetWatchedItemUseCase(this._repository);
  final WatchedRepository _repository;

  Future<WatchedItem?> call(int id) => _repository.getWatchedItem(id);
}
