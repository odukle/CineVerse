import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/library_item.dart';
import 'package:cineverse/domain/entities/shared_named_list.dart';
import 'package:cineverse/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _sharedNamedListsCollection = 'sharedNamedLists';

class SharedNamedListService {
  const SharedNamedListService(this._firestore, this._appConfig, this._ref);

  final FirebaseFirestore _firestore;
  final AppConfig _appConfig;
  final Ref _ref;

  Future<Uri> createShareLink(NamedList list) async {
    final currentUser = _ref.read(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      throw Exception('Sign in to share lists.');
    }

    if (list.items.isEmpty) {
      throw Exception('Add at least one title before sharing this list.');
    }

    final docRef = _firestore.collection(_sharedNamedListsCollection).doc();
    await docRef.set(<String, dynamic>{
      'name': list.name,
      'itemCount': list.items.length,
      'items': list.items
          .map(
            (item) => <String, dynamic>{
              'mediaId': item.mediaId,
              'title': item.title,
              'posterPath': item.posterPath,
              'releaseDate': item.releaseDate,
              'mediaType': item.mediaType.index,
              'voteAverage': item.voteAverage,
            },
          )
          .toList(growable: false),
      'ownerId': currentUser.uid,
      'ownerDisplayName': currentUser.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final Uri baseUri = Uri.parse(_appConfig.effectiveMovieApiBaseUrl);
    return baseUri.replace(
      path: '/lists/${docRef.id}',
      queryParameters: <String, String>{'name': list.name},
    );
  }

  Future<SharedNamedList?> fetchSharedList(String shareId) async {
    final snapshot = await _firestore
        .collection(_sharedNamedListsCollection)
        .doc(shareId)
        .get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    final rawItems = data['items'];
    if (rawItems is! List) {
      return null;
    }

    final items = rawItems
        .whereType<Map<dynamic, dynamic>>()
        .map((rawItem) {
          final mediaTypeIndex = rawItem['mediaType'];
          return SharedNamedListItem(
            mediaId: (rawItem['mediaId'] as num?)?.toInt() ?? 0,
            title: (rawItem['title'] as String?)?.trim() ?? 'Untitled',
            posterPath: rawItem['posterPath'] as String?,
            releaseDate: rawItem['releaseDate'] as String?,
            mediaType:
                GlobalMediaType.values[(mediaTypeIndex is int
                        ? mediaTypeIndex
                        : 0)
                    .clamp(0, GlobalMediaType.values.length - 1)],
            voteAverage: (rawItem['voteAverage'] as num?)?.toDouble(),
          );
        })
        .where((item) => item.mediaId > 0 && item.title.isNotEmpty)
        .toList(growable: false);

    final Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;

    return SharedNamedList(
      id: snapshot.id,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? (data['name'] as String).trim()
          : 'Shared List',
      items: items,
      createdAt: createdAtTimestamp?.toDate(),
      ownerDisplayName: (data['ownerDisplayName'] as String?)?.trim(),
    );
  }
}

final sharedNamedListServiceProvider = Provider<SharedNamedListService>((ref) {
  return SharedNamedListService(
    ref.watch(firestoreProvider),
    ref.watch(appConfigProvider),
    ref,
  );
});

final sharedNamedListProvider = FutureProvider.family<SharedNamedList?, String>(
  (ref, shareId) {
    return ref.watch(sharedNamedListServiceProvider).fetchSharedList(shareId);
  },
);
