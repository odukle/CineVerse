import 'package:cineverse/data/datasources/local/app_database.dart';
import 'package:cineverse/domain/entities/search_history.dart';
import 'package:cineverse/domain/repositories/search_history_repository.dart';
import 'package:drift/drift.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  SearchHistoryRepositoryImpl(this._database);
  final AppDatabase _database;

  @override
  Future<List<SearchHistory>> getHistory() async {
    final query = _database.select(_database.searchHistoryTable)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(10);

    final results = await query.get();
    return results
        .map(
          (row) => SearchHistory(
            id: row.id,
            query: row.query,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> addToHistory(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    // Remove existing identical query to move it to top
    await (_database.delete(_database.searchHistoryTable)
          ..where((t) => t.query.equals(trimmedQuery)))
        .go();

    // Insert new entry
    await _database.into(_database.searchHistoryTable).insert(
      SearchHistoryTableCompanion.insert(
        query: trimmedQuery,
        createdAt: DateTime.now(),
      ),
    );

    // Keep only the 10 most recent
    final allHistory = await (_database.select(_database.searchHistoryTable)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();

    if (allHistory.length > 10) {
      final idsToDelete = allHistory.skip(10).map((e) => e.id).toList();
      await (_database.delete(_database.searchHistoryTable)
            ..where((t) => t.id.isIn(idsToDelete)))
          .go();
    }
  }

  @override
  Future<void> removeFromHistory(int id) async {
    await (_database.delete(_database.searchHistoryTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> clearHistory() async {
    await _database.delete(_database.searchHistoryTable).go();
  }
}
