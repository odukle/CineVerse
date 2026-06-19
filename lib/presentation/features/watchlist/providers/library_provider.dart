import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/library_item.dart';
import 'package:cineverse/domain/entities/shared_named_list.dart';
import 'package:cineverse/presentation/features/watchlist/providers/watchlist_provider.dart';
import 'package:cineverse/domain/entities/watchlist_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Favourites Provider
class FavouritesNotifier extends StreamNotifier<List<FavouriteItem>> {
  @override
  Stream<List<FavouriteItem>> build() {
    return ref.watch(libraryRepositoryProvider).watchFavourites();
  }

  Future<void> toggleFavourite(FavouriteItem item) async {
    final repo = ref.read(libraryRepositoryProvider);
    final isFav = await repo.isFavourite(item.id, item.mediaType.index);
    if (isFav) {
      await repo.removeFavourite(item.id, item.mediaType.index);
    } else {
      await repo.addFavourite(item);
    }
  }
}

final favouritesProvider =
    StreamNotifierProvider<FavouritesNotifier, List<FavouriteItem>>(
      FavouritesNotifier.new,
    );

final isFavouriteProvider =
    Provider.family<bool, ({int id, GlobalMediaType type})>((ref, arg) {
      final favourites = ref.watch(favouritesProvider).value ?? [];
      return favourites.any((f) => f.id == arg.id && f.mediaType == arg.type);
    });

// Named Lists Provider
class NamedListsNotifier extends StreamNotifier<List<NamedList>> {
  @override
  Stream<List<NamedList>> build() {
    return ref.watch(libraryRepositoryProvider).watchNamedLists();
  }

  Future<int> createList(String name) async {
    return await ref.read(libraryRepositoryProvider).createNamedList(name);
  }

  Future<void> deleteList(int id) async {
    await ref.read(libraryRepositoryProvider).deleteNamedList(id);
  }

  Future<void> addItemToList({
    required NamedListItem item,
    bool addToWatchlist = false,
  }) async {
    await ref.read(libraryRepositoryProvider).addItemToNamedList(item);
    if (addToWatchlist) {
      final watchlistItem = WatchlistItem(
        id: item.mediaId,
        title: item.title,
        posterPath: item.posterPath,
        releaseDate: item.releaseDate,
        mediaType: item.mediaType,
        addedDate: DateTime.now(),
        voteAverage: item.voteAverage,
      );
      await ref.read(watchlistProvider.notifier).toggleItem(watchlistItem);
    }
  }

  Future<void> removeItemFromList(
    int listId,
    int mediaId,
    GlobalMediaType mediaType,
  ) async {
    await ref
        .read(libraryRepositoryProvider)
        .removeItemFromNamedList(listId, mediaId, mediaType.index);
  }

  Future<List<NamedListItem>> getItemsForList(int listId) {
    return ref.read(libraryRepositoryProvider).getItemsForList(listId);
  }

  Future<void> renameList(int id, String newName) async {
    await ref.read(libraryRepositoryProvider).renameNamedList(id, newName);
  }

  Future<String> importSharedList(SharedNamedList sharedList) async {
    final repo = ref.read(libraryRepositoryProvider);
    final existingLists = state.value ?? const <NamedList>[];
    final importedName = _dedupeListName(sharedList.name, existingLists);
    final listId = await repo.createNamedList(importedName);

    for (final item in sharedList.items) {
      await repo.addItemToNamedList(
        NamedListItem(
          listId: listId,
          mediaId: item.mediaId,
          title: item.title,
          posterPath: item.posterPath,
          releaseDate: item.releaseDate,
          mediaType: item.mediaType,
          addedDate: DateTime.now(),
          voteAverage: item.voteAverage,
        ),
      );
    }

    return importedName;
  }

  String _dedupeListName(String preferredName, List<NamedList> existingLists) {
    final trimmedName = preferredName.trim().isEmpty
        ? 'Shared List'
        : preferredName.trim();
    final existingNames = existingLists
        .map((list) => list.name.trim().toLowerCase())
        .toSet();
    if (!existingNames.contains(trimmedName.toLowerCase())) {
      return trimmedName;
    }

    int suffix = 2;
    while (existingNames.contains('$trimmedName ($suffix)'.toLowerCase())) {
      suffix++;
    }
    return '$trimmedName ($suffix)';
  }
}

final namedListsProvider =
    StreamNotifierProvider<NamedListsNotifier, List<NamedList>>(
      NamedListsNotifier.new,
    );

final isItemInListProvider =
    FutureProvider.family<
      bool,
      ({int listId, int mediaId, GlobalMediaType type})
    >((ref, arg) async {
      return ref
          .watch(libraryRepositoryProvider)
          .isItemInList(arg.listId, arg.mediaId, arg.type.index);
    });
