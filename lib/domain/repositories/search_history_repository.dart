import 'package:cineverse/domain/entities/search_history.dart';

abstract class SearchHistoryRepository {
  Future<List<SearchHistory>> getHistory();
  Future<void> addToHistory(String query);
  Future<void> removeFromHistory(int id);
  Future<void> clearHistory();
}
