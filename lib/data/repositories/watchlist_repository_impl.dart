import 'package:cineverse/data/datasources/local/app_database.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/domain/repositories/watchlist_repository.dart';
import 'package:drift/drift.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<WatchlistItem>> getWatchlist() async {
    final results = await _database.select(_database.watchlistItemsTable).get();
    return results
        .map(
          (row) => WatchlistItem(
            id: row.id,
            title: row.title,
            posterPath: row.posterPath,
            releaseDate: row.releaseDate,
            mediaType: row.mediaType,
            addedDate: row.addedDate,
            voteAverage: row.voteAverage,
          ),
        )
        .toList();
  }

  @override
  Future<void> addToWatchlist(WatchlistItem item) async {
    await _database.transaction(() async {
      await (_database.delete(_database.watchlistRemovalTombstonesTable)
            ..where(
              (t) =>
                  t.id.equals(item.id) &
                  t.mediaType.equals(item.mediaType.index),
            ))
          .go();
      await _database.into(_database.watchlistItemsTable).insert(
        WatchlistItemsTableCompanion.insert(
          id: item.id,
          title: item.title,
          posterPath: Value(item.posterPath),
          releaseDate: Value(item.releaseDate),
          mediaType: item.mediaType,
          addedDate: item.addedDate,
          voteAverage: Value(item.voteAverage),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  @override
  Future<void> removeFromWatchlist(int id) async {
    await _database.transaction(() async {
      final rows =
          await (_database.select(_database.watchlistItemsTable)
                ..where((t) => t.id.equals(id)))
              .get();
      final removedAt = DateTime.now();
      for (final row in rows) {
        await _database.into(_database.watchlistRemovalTombstonesTable).insert(
          WatchlistRemovalTombstonesTableCompanion.insert(
            id: row.id,
            mediaType: row.mediaType,
            removedAt: removedAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
      await (_database.delete(_database.watchlistItemsTable)
            ..where((t) => t.id.equals(id)))
          .go();
    });
  }

  @override
  Future<bool> isInWatchlist(int id) async {
    final query =
        _database.select(_database.watchlistItemsTable)
          ..where((t) => t.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null;
  }
}
