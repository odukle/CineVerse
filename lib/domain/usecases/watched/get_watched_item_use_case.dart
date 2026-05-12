import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';

class GetWatchedItemUseCase {
  GetWatchedItemUseCase(this._repository);
  final WatchedRepository _repository;

  Future<WatchedItem?> call(int id, GlobalMediaType mediaType) =>
      _repository.getWatchedItem(id, mediaType);
}
