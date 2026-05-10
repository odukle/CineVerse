import 'package:cineverse/data/datasources/local/app_database.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';
import 'package:drift/drift.dart';

class WatchedRepositoryImpl implements WatchedRepository {
  WatchedRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<WatchedItem>> getWatchedItems() async {
    final results = await _database.select(_database.watchedItemsTable).get();
    return results
        .map(
          (row) => WatchedItem(
            id: row.id,
            title: row.title,
            posterPath: row.posterPath,
            mediaType: row.mediaType,
            watchDate: row.watchDate,
            rating: row.rating,
            rewatchCount: row.rewatchCount,
            voteAverage: row.voteAverage,
          ),
        )
        .toList();
  }

  @override
  Future<void> addToWatched(WatchedItem item) async {
    await _database.into(_database.watchedItemsTable).insert(
      WatchedItemsTableCompanion.insert(
        id: Value(item.id),
        title: item.title,
        posterPath: Value(item.posterPath),
        mediaType: item.mediaType,
        watchDate: item.watchDate,
        rating: item.rating,
        rewatchCount: Value(item.rewatchCount),
        voteAverage: Value(item.voteAverage),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> removeFromWatched(int id) async {
    await (_database.delete(_database.watchedItemsTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<bool> isWatched(int id) async {
    final query =
        _database.select(_database.watchedItemsTable)
          ..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  @override
  Future<void> updateWatchedItem(WatchedItem item) async {
    await (_database.update(_database.watchedItemsTable)
          ..where((t) => t.id.equals(item.id)))
        .write(
      WatchedItemsTableCompanion(
        rating: Value(item.rating),
        watchDate: Value(item.watchDate),
        rewatchCount: Value(item.rewatchCount),
      ),
    );
  }

  @override
  Future<WatchedItem?> getWatchedItem(int id) async {
    final query =
        _database.select(_database.watchedItemsTable)
          ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return WatchedItem(
      id: row.id,
      title: row.title,
      posterPath: row.posterPath,
      mediaType: row.mediaType,
      watchDate: row.watchDate,
      rating: row.rating,
      rewatchCount: row.rewatchCount,
      voteAverage: row.voteAverage,
    );
  }
}
