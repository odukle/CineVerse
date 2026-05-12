import 'package:cineverse/domain/entities/library_item.dart';

abstract class LibraryRepository {
  // Favourites
  Stream<List<FavouriteItem>> watchFavourites();
  Future<void> addFavourite(FavouriteItem item);
  Future<void> removeFavourite(int id, int mediaType);
  Future<bool> isFavourite(int id, int mediaType);

  // Named Lists
  Stream<List<NamedList>> watchNamedLists();
  Future<int> createNamedList(String name);
  Future<void> deleteNamedList(int id);
  Future<void> addItemToNamedList(NamedListItem item);
  Future<void> removeItemFromNamedList(int listId, int mediaId, int mediaType);
  Future<List<NamedListItem>> getItemsForList(int listId);
  Future<bool> isItemInList(int listId, int mediaId, int mediaType);
  Future<void> renameNamedList(int id, String newName);
}
