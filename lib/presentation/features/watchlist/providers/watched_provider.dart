import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/watched_item.dart';
import 'package:cineverse/domain/usecases/watched/add_watched_item_use_case.dart';
import 'package:cineverse/domain/usecases/watched/get_watched_item_use_case.dart';
import 'package:cineverse/domain/usecases/watched/get_watched_items_use_case.dart';
import 'package:cineverse/domain/usecases/watched/is_watched_use_case.dart';
import 'package:cineverse/domain/usecases/watched/remove_watched_item_use_case.dart';
import 'package:cineverse/domain/usecases/watched/update_watched_item_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addWatchedItemUseCaseProvider = Provider<AddWatchedItemUseCase>((ref) {
  return AddWatchedItemUseCase(ref.watch(watchedRepositoryProvider));
});

final getWatchedItemsUseCaseProvider = Provider<GetWatchedItemsUseCase>((ref) {
  return GetWatchedItemsUseCase(ref.watch(watchedRepositoryProvider));
});

final isWatchedUseCaseProvider = Provider<IsWatchedUseCase>((ref) {
  return IsWatchedUseCase(ref.watch(watchedRepositoryProvider));
});

final removeWatchedItemUseCaseProvider =
    Provider<RemoveWatchedItemUseCase>((ref) {
  return RemoveWatchedItemUseCase(ref.watch(watchedRepositoryProvider));
});

final updateWatchedItemUseCaseProvider =
    Provider<UpdateWatchedItemUseCase>((ref) {
  return UpdateWatchedItemUseCase(ref.watch(watchedRepositoryProvider));
});

final getWatchedItemUseCaseProvider = Provider<GetWatchedItemUseCase>((ref) {
  return GetWatchedItemUseCase(ref.watch(watchedRepositoryProvider));
});

class WatchedItemsNotifier extends AsyncNotifier<List<WatchedItem>> {
  @override
  Future<List<WatchedItem>> build() async {
    return ref.watch(getWatchedItemsUseCaseProvider).call();
  }

  Future<void> addItem(WatchedItem item) async {
    await ref.read(addWatchedItemUseCaseProvider).call(item);
    ref.invalidateSelf();
    ref.invalidate(isWatchedProvider((id: item.id, type: item.mediaType)));
    ref.invalidate(watchedItemProvider((id: item.id, type: item.mediaType)));
  }

  Future<void> removeItem(int id, GlobalMediaType mediaType) async {
    await ref.read(removeWatchedItemUseCaseProvider).call(id, mediaType);
    ref.invalidateSelf();
    ref.invalidate(isWatchedProvider((id: id, type: mediaType)));
    ref.invalidate(watchedItemProvider((id: id, type: mediaType)));
  }

  Future<void> updateItem(WatchedItem item) async {
    await ref.read(updateWatchedItemUseCaseProvider).call(item);
    ref.invalidateSelf();
    ref.invalidate(watchedItemProvider((id: item.id, type: item.mediaType)));
  }
}

final watchedItemsProvider =
    AsyncNotifierProvider<WatchedItemsNotifier, List<WatchedItem>>(() {
  return WatchedItemsNotifier();
});

final isWatchedProvider =
    FutureProvider.family<bool, ({int id, GlobalMediaType type})>((
  ref,
  params,
) async {
  ref.watch(watchedItemsProvider);
  return ref.watch(isWatchedUseCaseProvider).call(params.id, params.type);
});

final watchedItemProvider =
    FutureProvider.family<WatchedItem?, ({int id, GlobalMediaType type})>((
  ref,
  params,
) async {
  ref.watch(watchedItemsProvider);
  return ref.watch(getWatchedItemUseCaseProvider).call(params.id, params.type);
});
