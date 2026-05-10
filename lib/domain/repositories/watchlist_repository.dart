import 'package:cineverse/domain/entities/watchlist_item.dart';

abstract class WatchlistRepository {
  Future<List<WatchlistItem>> getWatchlist();
  Future<void> addToWatchlist(WatchlistItem item);
  Future<void> removeFromWatchlist(int id);
  Future<bool> isInWatchlist(int id);
}
