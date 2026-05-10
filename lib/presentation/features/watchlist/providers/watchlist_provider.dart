import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:cineverse/domain/usecases/watchlist/get_watchlist_use_case.dart';
import 'package:cineverse/domain/usecases/watchlist/is_in_watchlist_use_case.dart';
import 'package:cineverse/domain/usecases/watchlist/toggle_watchlist_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getWatchlistUseCaseProvider = Provider<GetWatchlistUseCase>((ref) {
  return GetWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
});

final toggleWatchlistUseCaseProvider = Provider<ToggleWatchlistUseCase>((ref) {
  return ToggleWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
});

final isInWatchlistUseCaseProvider = Provider<IsInWatchlistUseCase>((ref) {
  return IsInWatchlistUseCase(ref.watch(watchlistRepositoryProvider));
});

class WatchlistNotifier extends AsyncNotifier<List<WatchlistItem>> {
  @override
  Future<List<WatchlistItem>> build() async {
    return ref.watch(getWatchlistUseCaseProvider).call();
  }

  Future<void> toggleItem(WatchlistItem item) async {
    try {
      await ref.read(toggleWatchlistUseCaseProvider).call(item);
      ref.invalidateSelf();
      // Also invalidate the isInWatchlistProvider for this ID
      ref.invalidate(isInWatchlistProvider(item.id));
    } catch (e) {
      // We don't want to set the whole list to error if a toggle fails
      // Maybe show a snackbar in the UI
    }
  }
}

final watchlistProvider =
    AsyncNotifierProvider<WatchlistNotifier, List<WatchlistItem>>(() {
      return WatchlistNotifier();
    });

final isInWatchlistProvider = FutureProvider.family<bool, int>((ref, id) async {
  // Listen to watchlist changes to re-evaluate
  ref.watch(watchlistProvider);
  return ref.watch(isInWatchlistUseCaseProvider).call(id);
});
