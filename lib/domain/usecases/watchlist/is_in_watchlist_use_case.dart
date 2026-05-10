import 'package:cineverse/domain/repositories/watchlist_repository.dart';

class IsInWatchlistUseCase {
  IsInWatchlistUseCase(this._repository);
  final WatchlistRepository _repository;

  Future<bool> call(int id) => _repository.isInWatchlist(id);
}
