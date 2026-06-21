import 'dart:async';
import 'package:cineverse/data/datasources/local/app_database.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import 'package:cineverse/presentation/providers/sync_provider.dart';

class SyncService {
  SyncService(this._firestore, this._db, {this.onStatusChanged}) {
    _initListener();
  }

  final FirebaseFirestore _firestore;
  final AppDatabase _db;
  final void Function(SyncStatus)? onStatusChanged;

  String? _userId;
  StreamSubscription? _dbSubscription;
  bool _isPulling = false;
  bool _suspendNextAutomaticPull = false;
  bool _hasCompletedRemotePull = false;

  void _setStatus(SyncStatus status) {
    onStatusChanged?.call(status);
  }

  void _initListener() {
    _dbSubscription = _db.tableUpdates().listen((updates) {
      if (_isPulling || _userId == null) return;

      bool shouldPush = false;
      for (final update in updates) {
        if (update.table == _db.watchlistItemsTable.actualTableName ||
            update.table == _db.watchedItemsTable.actualTableName ||
            update.table == _db.favouritesTable.actualTableName ||
            update.table == _db.movieNotesTable.actualTableName ||
            update.table == _db.namedListsTable.actualTableName ||
            update.table == _db.namedListItemsTable.actualTableName) {
          shouldPush = true;
          break;
        }
      }

      if (shouldPush) {
        syncAllToRemote();
      }
    });
  }

  void dispose() {
    _dbSubscription?.cancel();
  }

  void updateUserId(String? userId) {
    if (_userId != userId) {
      _hasCompletedRemotePull = false;
    }
    _userId = userId;
  }

  void suspendNextAutomaticPull() {
    _suspendNextAutomaticPull = true;
  }

  bool consumeSuspendedAutomaticPull() {
    final bool shouldSuspend = _suspendNextAutomaticPull;
    _suspendNextAutomaticPull = false;
    return shouldSuspend;
  }

  Future<bool> hasLocalLibraryContent() async {
    final results = await Future.wait<int>(<Future<int>>[
      _db.select(_db.watchlistItemsTable).get().then((rows) => rows.length),
      _db.select(_db.watchedItemsTable).get().then((rows) => rows.length),
      _db.select(_db.favouritesTable).get().then((rows) => rows.length),
      _db.select(_db.namedListItemsTable).get().then((rows) => rows.length),
    ]);
    return results.any((entryCount) => entryCount > 0);
  }

  Future<void> clearLocalLibrary() async {
    final bool wasPulling = _isPulling;
    _isPulling = true;
    try {
      await _db.transaction(() async {
        await _db.delete(_db.movieNotesTable).go();
        await _db.delete(_db.namedListItemsTable).go();
        await _db.delete(_db.namedListsTable).go();
        await _db.delete(_db.favouritesTable).go();
        await _db.delete(_db.watchedItemsTable).go();
        await _db.delete(_db.watchlistItemsTable).go();
        await _db.delete(_db.watchlistRemovalTombstonesTable).go();
      });
    } finally {
      _isPulling = wasPulling;
    }
  }

  Future<void> syncAllToRemote({bool allowEmptyLibraryOverwrite = true}) async {
    if (_userId == null) return;
    if (!allowEmptyLibraryOverwrite &&
        !_hasCompletedRemotePull &&
        !await hasLocalLibraryContent()) {
      return;
    }
    _setStatus(SyncStatus.syncing);
    try {
      await Future.wait([
        pushWatchlist(),
        pushWatched(),
        pushFavourites(),
        pushNotes(),
        pushNamedLists(),
      ]);
      _setStatus(SyncStatus.idle);
    } catch (e) {
      _setStatus(SyncStatus.error);
      rethrow;
    }
  }

  Future<void> syncAllFromRemote() async {
    if (_userId == null) return;
    _isPulling = true;
    _setStatus(SyncStatus.syncing);
    try {
      await Future.wait([
        _pullWatchlist(),
        _pullWatched(),
        _pullFavourites(),
        _pullNotes(),
        _pullNamedLists(),
      ]);
      _hasCompletedRemotePull = true;
      _setStatus(SyncStatus.idle);
    } catch (e) {
      _setStatus(SyncStatus.error);
      rethrow;
    } finally {
      _isPulling = false;
    }
  }

  Future<void> pushWatchlist() async {
    if (_userId == null) return;
    final items = await _db.select(_db.watchlistItemsTable).get();
    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('watchlist');

    final existingDocs = await collection.get();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    for (final item in items) {
      final docRef = collection.doc(_libraryDocId(item.id, item.mediaType));
      batch.set(docRef, {
        'id': item.id,
        'title': item.title,
        'posterPath': item.posterPath,
        'releaseDate': item.releaseDate,
        'mediaType': item.mediaType.index,
        'addedDate': item.addedDate.toIso8601String(),
        'voteAverage': item.voteAverage,
      });
    }

    await batch.commit();
  }

  Future<void> _pullWatchlist() async {
    if (_userId == null) return;
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('watchlist');
    final snapshot = await collection.get();

    if (snapshot.docs.isEmpty) return;

    final tombstoneRows = await _db
        .select(_db.watchlistRemovalTombstonesTable)
        .get();
    final tombstoneKeys = tombstoneRows
        .map((row) => _libraryDocId(row.id, row.mediaType))
        .toSet();
    final remoteDeleteBatch = _firestore.batch();
    var hasRemoteDeletes = false;

    await _db.transaction(() async {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final id = data['id'] as int;
        final mediaTypeIndex = data['mediaType'] as int;
        final mediaType = GlobalMediaType.values[mediaTypeIndex];
        final docId = _libraryDocId(id, mediaType);
        if (tombstoneKeys.contains(doc.id) || tombstoneKeys.contains(docId)) {
          remoteDeleteBatch.delete(doc.reference);
          hasRemoteDeletes = true;
          continue;
        }
        await _db
            .into(_db.watchlistItemsTable)
            .insert(
              WatchlistItemsTableCompanion(
                id: Value(id),
                title: Value(data['title'] as String),
                posterPath: Value(data['posterPath'] as String?),
                releaseDate: Value(data['releaseDate'] as String?),
                mediaType: Value(mediaType),
                addedDate: Value(DateTime.parse(data['addedDate'] as String)),
                voteAverage: Value(data['voteAverage'] as double?),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
    if (hasRemoteDeletes) {
      await remoteDeleteBatch.commit();
    }
  }

  Future<void> pushWatched() async {
    if (_userId == null) return;
    final items = await _db.select(_db.watchedItemsTable).get();
    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('watched');

    final existingDocs = await collection.get();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    for (final item in items) {
      final docRef = collection.doc('${item.id}_${item.mediaType.index}');
      batch.set(docRef, {
        'id': item.id,
        'title': item.title,
        'posterPath': item.posterPath,
        'mediaType': item.mediaType.index,
        'watchDate': item.watchDate.toIso8601String(),
        'rating': item.rating,
        'rewatchCount': item.rewatchCount,
        'voteAverage': item.voteAverage,
      });
    }

    await batch.commit();
  }

  Future<void> _pullWatched() async {
    if (_userId == null) return;
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('watched');
    final snapshot = await collection.get();

    if (snapshot.docs.isEmpty) return;

    await _db.transaction(() async {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        await _db
            .into(_db.watchedItemsTable)
            .insert(
              WatchedItemsTableCompanion(
                id: Value(data['id'] as int),
                title: Value(data['title'] as String),
                posterPath: Value(data['posterPath'] as String?),
                mediaType: Value(
                  GlobalMediaType.values[data['mediaType'] as int],
                ),
                watchDate: Value(DateTime.parse(data['watchDate'] as String)),
                rating: Value(data['rating'] as int),
                rewatchCount: Value(data['rewatchCount'] as int),
                voteAverage: Value(data['voteAverage'] as double?),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<void> pushFavourites() async {
    if (_userId == null) return;
    final items = await _db.select(_db.favouritesTable).get();
    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('favourites');

    final existingDocs = await collection.get();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    for (final item in items) {
      final docRef = collection.doc('${item.id}_${item.mediaType.index}');
      batch.set(docRef, {
        'id': item.id,
        'title': item.title,
        'posterPath': item.posterPath,
        'releaseDate': item.releaseDate,
        'mediaType': item.mediaType.index,
        'addedDate': item.addedDate.toIso8601String(),
        'voteAverage': item.voteAverage,
      });
    }

    await batch.commit();
  }

  Future<void> _pullFavourites() async {
    if (_userId == null) return;
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('favourites');
    final snapshot = await collection.get();

    if (snapshot.docs.isEmpty) return;

    await _db.transaction(() async {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        await _db
            .into(_db.favouritesTable)
            .insert(
              FavouritesTableCompanion(
                id: Value(data['id'] as int),
                title: Value(data['title'] as String),
                posterPath: Value(data['posterPath'] as String?),
                releaseDate: Value(data['releaseDate'] as String?),
                mediaType: Value(
                  GlobalMediaType.values[data['mediaType'] as int],
                ),
                addedDate: Value(DateTime.parse(data['addedDate'] as String)),
                voteAverage: Value(data['voteAverage'] as double?),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<void> pushNotes() async {
    if (_userId == null) return;
    final items = await _db.select(_db.movieNotesTable).get();
    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes');

    final existingDocs = await collection.get();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    for (final item in items) {
      final docRef = collection.doc(item.id.toString());
      batch.set(docRef, {
        'id': item.id,
        'movieId': item.movieId,
        'mediaType': item.mediaType.index,
        'noteText': item.noteText,
        'createdAt': item.createdAt.toIso8601String(),
      });
    }

    await batch.commit();
  }

  Future<void> _pullNotes() async {
    if (_userId == null) return;
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes');
    final snapshot = await collection.get();

    if (snapshot.docs.isEmpty) return;

    await _db.transaction(() async {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        await _db
            .into(_db.movieNotesTable)
            .insert(
              MovieNotesTableCompanion(
                id: Value(data['id'] as int),
                movieId: Value(data['movieId'] as int),
                mediaType: Value(
                  GlobalMediaType.values[data['mediaType'] as int],
                ),
                noteText: Value(data['noteText'] as String),
                createdAt: Value(DateTime.parse(data['createdAt'] as String)),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  Future<void> pushNamedLists() async {
    if (_userId == null) return;
    final lists = await _db.select(_db.namedListsTable).get();
    final items = await _db.select(_db.namedListItemsTable).get();

    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('namedLists');
    final itemsCollection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('namedListItems');

    final existingLists = await collection.get();
    for (final doc in existingLists.docs) {
      batch.delete(doc.reference);
    }
    final existingItems = await itemsCollection.get();
    for (final doc in existingItems.docs) {
      batch.delete(doc.reference);
    }

    for (final list in lists) {
      final docRef = collection.doc(list.id.toString());
      batch.set(docRef, {
        'id': list.id,
        'name': list.name,
        'createdAt': list.createdAt.toIso8601String(),
      });
    }

    for (final item in items) {
      final docRef = itemsCollection.doc(
        '${item.listId}_${item.mediaId}_${item.mediaType.index}',
      );
      batch.set(docRef, {
        'listId': item.listId,
        'mediaId': item.mediaId,
        'title': item.title,
        'posterPath': item.posterPath,
        'releaseDate': item.releaseDate,
        'mediaType': item.mediaType.index,
        'addedDate': item.addedDate.toIso8601String(),
        'voteAverage': item.voteAverage,
      });
    }

    await batch.commit();
  }

  Future<void> _pullNamedLists() async {
    if (_userId == null) return;
    final collection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('namedLists');
    final itemsCollection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('namedListItems');

    final snapshot = await collection.get();
    final itemsSnapshot = await itemsCollection.get();

    await _db.transaction(() async {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        await _db
            .into(_db.namedListsTable)
            .insert(
              NamedListsTableCompanion(
                id: Value(data['id'] as int),
                name: Value(data['name'] as String),
                createdAt: Value(DateTime.parse(data['createdAt'] as String)),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }

      for (final doc in itemsSnapshot.docs) {
        final data = doc.data();
        await _db
            .into(_db.namedListItemsTable)
            .insert(
              NamedListItemsTableCompanion(
                listId: Value(data['listId'] as int),
                mediaId: Value(data['mediaId'] as int),
                title: Value(data['title'] as String),
                posterPath: Value(data['posterPath'] as String?),
                releaseDate: Value(data['releaseDate'] as String?),
                mediaType: Value(
                  GlobalMediaType.values[data['mediaType'] as int],
                ),
                addedDate: Value(DateTime.parse(data['addedDate'] as String)),
                voteAverage: Value(data['voteAverage'] as double?),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  String _libraryDocId(int id, GlobalMediaType mediaType) {
    return '${id}_${mediaType.index}';
  }
}
