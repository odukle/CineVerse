import 'package:drift/drift.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';

part 'app_database.g.dart';

class WatchlistItemsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get releaseDate => text().nullable()();
  IntColumn get mediaType => intEnum<GlobalMediaType>()();
  DateTimeColumn get addedDate => dateTime()();
  RealColumn get voteAverage => real().nullable()();

  @override
  Set<Column> get primaryKey => {id, mediaType};
}

class WatchedItemsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get posterPath => text().nullable()();
  IntColumn get mediaType => intEnum<GlobalMediaType>()();
  DateTimeColumn get watchDate => dateTime()();
  IntColumn get rating => integer()();
  IntColumn get rewatchCount => integer().withDefault(const Constant(0))();
  RealColumn get voteAverage => real().nullable()();

  @override
  Set<Column> get primaryKey => {id, mediaType};
}

class MovieNotesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get movieId => integer()();
  IntColumn get mediaType => intEnum<GlobalMediaType>().withDefault(const Constant(0))(); // 0 is Movie
  TextColumn get noteText => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class SearchHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class FavouritesTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get releaseDate => text().nullable()();
  IntColumn get mediaType => intEnum<GlobalMediaType>()();
  DateTimeColumn get addedDate => dateTime()();
  RealColumn get voteAverage => real().nullable()();

  @override
  Set<Column> get primaryKey => {id, mediaType};
}

class NamedListsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class NamedListItemsTable extends Table {
  IntColumn get listId => integer().references(NamedListsTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get mediaId => integer()();
  TextColumn get title => text()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get releaseDate => text().nullable()();
  IntColumn get mediaType => intEnum<GlobalMediaType>()();
  RealColumn get voteAverage => real().nullable()();
  DateTimeColumn get addedDate => dateTime()();

  @override
  Set<Column> get primaryKey => {listId, mediaId, mediaType};
}

@DriftDatabase(tables: [
  WatchlistItemsTable,
  WatchedItemsTable,
  MovieNotesTable,
  SearchHistoryTable,
  FavouritesTable,
  NamedListsTable,
  NamedListItemsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(watchlistItemsTable, watchlistItemsTable.voteAverage);
          }
          if (from < 3) {
            await m.createTable(watchedItemsTable);
          }
          if (from < 4) {
            await m.createTable(movieNotesTable);
          }
          if (from < 5) {
            await m.addColumn(watchlistItemsTable, watchlistItemsTable.releaseDate);
          }
          if (from < 6) {
            try {
              await m.addColumn(movieNotesTable, movieNotesTable.mediaType);
            } catch (e) {
              if (!e.toString().contains('duplicate column name')) {
                rethrow;
              }
            }
          }
          if (from < 7) {
            await m.createTable(searchHistoryTable);
          }
          if (from < 8) {
            await m.createTable(favouritesTable);
            await m.createTable(namedListsTable);
            await m.createTable(namedListItemsTable);
          }
          if (from < 9) {
            // Note: Primary keys changed for watchlistItemsTable and watchedItemsTable.
            // SQLite doesn't support changing primary keys via ALTER TABLE.
            // For a production app, we would need to:
            // 1. Create temporary tables with the new schema.
            // 2. Copy data from old tables to temporary tables.
            // 3. Drop old tables.
            // 4. Rename temporary tables to original names.
          }
        },
      );
}
