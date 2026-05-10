import 'package:cineverse/domain/entities/search_history.dart';
import 'package:cineverse/domain/repositories/search_history_repository.dart';

class GetSearchHistoryUseCase {
  GetSearchHistoryUseCase(this._repository);
  final SearchHistoryRepository _repository;

  Future<List<SearchHistory>> call() => _repository.getHistory();
}

class AddSearchHistoryUseCase {
  AddSearchHistoryUseCase(this._repository);
  final SearchHistoryRepository _repository;

  Future<void> call(String query) => _repository.addToHistory(query);
}

class RemoveSearchHistoryUseCase {
  RemoveSearchHistoryUseCase(this._repository);
  final SearchHistoryRepository _repository;

  Future<void> call(int id) => _repository.removeFromHistory(id);
}

class ClearSearchHistoryUseCase {
  ClearSearchHistoryUseCase(this._repository);
  final SearchHistoryRepository _repository;

  Future<void> call() => _repository.clearHistory();
}
