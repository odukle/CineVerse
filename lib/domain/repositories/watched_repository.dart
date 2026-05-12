import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/watched_item.dart';

abstract class WatchedRepository {
  Future<List<WatchedItem>> getWatchedItems();
  Future<void> addToWatched(WatchedItem item);
  Future<void> removeFromWatched(int id, GlobalMediaType mediaType);
  Future<bool> isWatched(int id, GlobalMediaType mediaType);
  Future<void> updateWatchedItem(WatchedItem item);
  Future<WatchedItem?> getWatchedItem(int id, GlobalMediaType mediaType);
}
