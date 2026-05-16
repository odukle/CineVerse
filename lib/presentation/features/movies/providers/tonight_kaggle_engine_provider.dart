import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/presentation/features/movies/models/tonight_watch_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _kaggleManifestCollection = 'tonight_index_manifest';
const String _kaggleManifestDoc = 'current';
const String _defaultKaggleEntriesCollection = 'tonight_index_entries_v1';

final tonightKaggleEngineProvider = FutureProvider<TonightKaggleEngine>((
  ref,
) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String collectionName = _defaultKaggleEntriesCollection;

  try {
    final DocumentSnapshot<Map<String, dynamic>> manifestSnapshot =
        await firestore
            .collection(_kaggleManifestCollection)
            .doc(_kaggleManifestDoc)
            .get();
    final Map<String, dynamic>? manifestData = manifestSnapshot.data();
    if (manifestData != null) {
      final String maybeCollection =
          (manifestData['collection'] as String? ?? '').trim();
      if (maybeCollection.isNotEmpty) {
        collectionName = maybeCollection;
      }
    }
  } catch (_) {
    // Fall back to the default collection when the manifest is unavailable.
  }

  return TonightKaggleEngine(
    firestore: firestore,
    entriesCollection: collectionName,
  );
});

class TonightKaggleEngine {
  const TonightKaggleEngine({
    required this.firestore,
    required this.entriesCollection,
  });

  final FirebaseFirestore firestore;
  final String entriesCollection;

  bool get hasData => true;

  Future<List<MediaTitle>> findCandidates({
    required TonightWatchRequest request,
    int limit = 80,
  }) async {
    final int minRuntime = math.max(0, request.timeOption.minMinutes - 36);
    final int maxRuntime = request.timeOption.maxMinutes + 36;
    final String mediaType = request.isTv ? 'tv' : 'movie';

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection(entriesCollection)
          .where('mediaType', isEqualTo: mediaType)
          .where('originalLanguage', isEqualTo: request.language.code)
          .where('moods', arrayContains: request.mood.name)
          .where('runtimeMinutes', isGreaterThanOrEqualTo: minRuntime)
          .where('runtimeMinutes', isLessThanOrEqualTo: maxRuntime)
          .orderBy('runtimeMinutes')
          .limit(limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return _convertSnapshots(snapshot.docs, request: request);
      }
    } catch (_) {
      // Fall through to a broader runtime/language query if index rules vary.
    }

    try {
      final QuerySnapshot<Map<String, dynamic>> fallbackSnapshot =
          await firestore
              .collection(entriesCollection)
              .where('mediaType', isEqualTo: mediaType)
              .where('originalLanguage', isEqualTo: request.language.code)
              .where('runtimeMinutes', isGreaterThanOrEqualTo: minRuntime)
              .where('runtimeMinutes', isLessThanOrEqualTo: maxRuntime)
              .orderBy('runtimeMinutes')
              .limit(limit * 2)
              .get();

      return _convertSnapshots(
        fallbackSnapshot.docs,
        request: request,
      ).take(limit).toList(growable: false);
    } catch (_) {
      return const <MediaTitle>[];
    }
  }

  List<MediaTitle> _convertSnapshots(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    required TonightWatchRequest request,
  }) {
    final Set<int> seenIds = <int>{};
    final List<MediaTitle> results = <MediaTitle>[];

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      final Map<String, dynamic> data = doc.data();
      final int? id = _readInt(data['id']);
      final String title = _readString(data['title']);
      final String originalLanguage = _readString(
        data['originalLanguage'],
      ).toLowerCase();
      final int runtimeMinutes = _readInt(data['runtimeMinutes']) ?? 0;

      if (id == null || id <= 0 || title.isEmpty) {
        continue;
      }
      if (originalLanguage != request.language.code) {
        continue;
      }
      if (!seenIds.add(id)) {
        continue;
      }

      results.add(
        MediaTitle(
          id: id,
          title: title,
          voteAverage: _readDouble(data['voteAverage']),
          voteCount: _readInt(data['voteCount']) ?? 0,
          popularity: _readDouble(data['popularity']) ?? 0,
          releaseDate: _readOptionalString(data['releaseDate']),
          mediaType: request.isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
          subtitle: runtimeMinutes > 0 ? '$runtimeMinutes min' : null,
        ),
      );
    }

    return results;
  }
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

double? _readDouble(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

String _readString(Object? value) {
  if (value is String) {
    return value.trim();
  }
  return '';
}

String? _readOptionalString(Object? value) {
  final String normalized = _readString(value);
  return normalized.isEmpty ? null : normalized;
}
