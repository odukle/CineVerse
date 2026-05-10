import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/domain/repositories/watchlist_repository.dart';

class GetWatchlistUseCase {
  GetWatchlistUseCase(this._repository);
  final WatchlistRepository _repository;

  Future<List<WatchlistItem>> call() => _repository.getWatchlist();
}
