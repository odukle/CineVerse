import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/domain/repositories/watchlist_repository.dart';

class ToggleWatchlistUseCase {
  ToggleWatchlistUseCase(this._repository);
  final WatchlistRepository _repository;

  Future<void> call(WatchlistItem item) async {
    final isAdded = await _repository.isInWatchlist(item.id);
    if (isAdded) {
      await _repository.removeFromWatchlist(item.id);
    } else {
      await _repository.addToWatchlist(item);
    }
  }
}
