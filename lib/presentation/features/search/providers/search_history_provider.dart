import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/search_history.dart';
import 'package:cineverse/domain/usecases/search/search_history_use_cases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getSearchHistoryUseCaseProvider = Provider<GetSearchHistoryUseCase>((ref) {
  return GetSearchHistoryUseCase(ref.watch(searchHistoryRepositoryProvider));
});

final addSearchHistoryUseCaseProvider = Provider<AddSearchHistoryUseCase>((ref) {
  return AddSearchHistoryUseCase(ref.watch(searchHistoryRepositoryProvider));
});

final removeSearchHistoryUseCaseProvider =
    Provider<RemoveSearchHistoryUseCase>((ref) {
  return RemoveSearchHistoryUseCase(ref.watch(searchHistoryRepositoryProvider));
});

final clearSearchHistoryUseCaseProvider =
    Provider<ClearSearchHistoryUseCase>((ref) {
  return ClearSearchHistoryUseCase(ref.watch(searchHistoryRepositoryProvider));
});

class SearchHistoryNotifier extends AsyncNotifier<List<SearchHistory>> {
  @override
  Future<List<SearchHistory>> build() async {
    return ref.watch(getSearchHistoryHistoryUseCaseProvider).call();
  }

  Future<void> addEntry(String query) async {
    if (query.trim().isEmpty) return;
    await ref.read(addSearchHistoryUseCaseProvider).call(query);
    ref.invalidateSelf();
  }

  Future<void> removeEntry(int id) async {
    await ref.read(removeSearchHistoryUseCaseProvider).call(id);
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    await ref.read(clearSearchHistoryUseCaseProvider).call();
    ref.invalidateSelf();
  }
}

final searchHistoryProvider =
    AsyncNotifierProvider<SearchHistoryNotifier, List<SearchHistory>>(() {
  return SearchHistoryNotifier();
});

// Alias for GetSearchHistoryUseCase to avoid naming conflict in build method
final getSearchHistoryHistoryUseCaseProvider =
    Provider<GetSearchHistoryUseCase>((ref) {
  return GetSearchHistoryUseCase(ref.watch(searchHistoryRepositoryProvider));
});
