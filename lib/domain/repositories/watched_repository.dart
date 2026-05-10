import 'package:cineverse/domain/entities/watched_item.dart';

abstract class WatchedRepository {
  Future<List<WatchedItem>> getWatchedItems();
  Future<void> addToWatched(WatchedItem item);
  Future<void> removeFromWatched(int id);
  Future<bool> isWatched(int id);
  Future<void> updateWatchedItem(WatchedItem item);
  Future<WatchedItem?> getWatchedItem(int id);
}
