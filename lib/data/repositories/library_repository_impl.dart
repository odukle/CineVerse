import 'package:cineverse/data/datasources/local/app_database.dart';
import 'package:cineverse/domain/entities/library_item.dart';
import 'package:cineverse/domain/repositories/library_repository.dart';
import 'package:drift/drift.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._database);
  final AppDatabase _database;

  // Favourites
  @override
  Stream<List<FavouriteItem>> watchFavourites() {
    return (_database.select(_database.favouritesTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.addedDate, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) => rows
            .map((row) => FavouriteItem(
                  id: row.id,
                  title: row.title,
                  posterPath: row.posterPath,
                  releaseDate: row.releaseDate,
                  mediaType: row.mediaType,
                  addedDate: row.addedDate,
                  voteAverage: row.voteAverage,
                ))
            .toList());
  }

  @override
  Future<void> addFavourite(FavouriteItem item) async {
    await _database.into(_database.favouritesTable).insertOnConflictUpdate(
          FavouritesTableCompanion.insert(
            id: item.id,
            title: item.title,
            posterPath: Value(item.posterPath),
            releaseDate: Value(item.releaseDate),
            mediaType: item.mediaType,
            addedDate: item.addedDate,
            voteAverage: Value(item.voteAverage),
          ),
        );
  }

  @override
  Future<void> removeFavourite(int id, int mediaType) async {
    await (_database.delete(_database.favouritesTable)
          ..where((t) => t.id.equals(id) & t.mediaType.equals(mediaType)))
        .go();
  }

  @override
  Future<bool> isFavourite(int id, int mediaType) async {
    final query = _database.select(_database.favouritesTable)
      ..where((t) => t.id.equals(id) & t.mediaType.equals(mediaType));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  // Named Lists
  @override
  Stream<List<NamedList>> watchNamedLists() {
    final query = _database.select(_database.namedListsTable).join([
      leftOuterJoin(
        _database.namedListItemsTable,
        _database.namedListItemsTable.listId.equalsExp(_database.namedListsTable.id),
      ),
    ]);

    return query.watch().map((rows) {
      final grouped = <int, NamedList>{};

      for (final row in rows) {
        final listRow = row.readTable(_database.namedListsTable);
        final itemRow = row.readTableOrNull(_database.namedListItemsTable);

        final list = grouped.putIfAbsent(
          listRow.id,
          () => NamedList(
            id: listRow.id,
            name: listRow.name,
            createdAt: listRow.createdAt,
            items: [],
          ),
        );

        if (itemRow != null) {
          list.items.add(NamedListItem(
            listId: itemRow.listId,
            mediaId: itemRow.mediaId,
            title: itemRow.title,
            posterPath: itemRow.posterPath,
            releaseDate: itemRow.releaseDate,
            mediaType: itemRow.mediaType,
            addedDate: itemRow.addedDate,
            voteAverage: itemRow.voteAverage,
          ));
        }
      }

      return grouped.values.toList();
    });
  }

  @override
  Future<int> createNamedList(String name) async {
    return await _database.into(_database.namedListsTable).insert(
          NamedListsTableCompanion.insert(
            name: name,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> deleteNamedList(int id) async {
    await (_database.delete(_database.namedListsTable)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> addItemToNamedList(NamedListItem item) async {
    await _database.into(_database.namedListItemsTable).insertOnConflictUpdate(
          NamedListItemsTableCompanion.insert(
            listId: item.listId,
            mediaId: item.mediaId,
            title: item.title,
            posterPath: Value(item.posterPath),
            releaseDate: Value(item.releaseDate),
            mediaType: item.mediaType,
            addedDate: item.addedDate,
            voteAverage: Value(item.voteAverage),
          ),
        );
  }

  @override
  Future<void> removeItemFromNamedList(int listId, int mediaId, int mediaType) async {
    await (_database.delete(_database.namedListItemsTable)
          ..where((t) =>
              t.listId.equals(listId) &
              t.mediaId.equals(mediaId) &
              t.mediaType.equals(mediaType)))
        .go();
  }

  @override
  Future<List<NamedListItem>> getItemsForList(int listId) async {
    final query = _database.select(_database.namedListItemsTable)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([(t) => OrderingTerm(expression: t.addedDate, mode: OrderingMode.desc)]);
    
    final results = await query.get();
    return results.map((row) => NamedListItem(
      listId: row.listId,
      mediaId: row.mediaId,
      title: row.title,
      posterPath: row.posterPath,
      releaseDate: row.releaseDate,
      mediaType: row.mediaType,
      addedDate: row.addedDate,
      voteAverage: row.voteAverage,
    )).toList();
  }

  @override
  Future<bool> isItemInList(int listId, int mediaId, int mediaType) async {
    final query = _database.select(_database.namedListItemsTable)
      ..where((t) =>
          t.listId.equals(listId) &
          t.mediaId.equals(mediaId) &
          t.mediaType.equals(mediaType));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  @override
  Future<void> renameNamedList(int id, String newName) async {
    await (_database.update(_database.namedListsTable)..where((t) => t.id.equals(id)))
        .write(NamedListsTableCompanion(name: Value(newName)));
  }
}
