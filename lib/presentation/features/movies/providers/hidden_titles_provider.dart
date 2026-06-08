import 'dart:convert';
import 'package:cineverse/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/global_media_filter.dart';

const String _hiddenTitlesStorageKey = 'cineverse_hidden_spotlight_titles_v1';
const String _dontAskAgainStorageKey = 'cineverse_hide_dont_ask_again';

class HiddenTitle {
  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final bool isTv;
  final double? voteAverage;
  final DateTime hiddenAt;

  HiddenTitle({
    required this.id,
    required this.title,
    this.posterPath,
    this.releaseDate,
    required this.isTv,
    this.voteAverage,
    required this.hiddenAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'posterPath': posterPath,
    'releaseDate': releaseDate,
    'isTv': isTv,
    'voteAverage': voteAverage,
    'hiddenAt': hiddenAt.toIso8601String(),
  };

  factory HiddenTitle.fromJson(Map<String, dynamic> json) => HiddenTitle(
    id: json['id'] as int,
    title: json['title'] as String,
    posterPath: json['posterPath'] as String?,
    releaseDate: json['releaseDate'] as String?,
    isTv: json['isTv'] as bool,
    voteAverage: (json['voteAverage'] as num?)?.toDouble(),
    hiddenAt: DateTime.parse(json['hiddenAt'] as String),
  );

  MediaTitle toMediaTitle() => MediaTitle(
    id: id,
    title: title,
    posterPath: posterPath,
    releaseDate: releaseDate,
    voteAverage: voteAverage,
    mediaType: isTv ? GlobalMediaType.tv : GlobalMediaType.movie,
  );
}

class HiddenTitlesNotifier extends AsyncNotifier<List<HiddenTitle>> {
  @override
  Future<List<HiddenTitle>> build() async {
    final String? userId = ref.watch(authStateProvider).value?.id;
    final List<HiddenTitle> local = await _loadLocal();
    if (userId == null) {
      return local;
    }
    final List<HiddenTitle> remote = await _loadRemote(userId);
    final List<HiddenTitle> merged = _mergeHiddenTitles(local, remote);
    await _persistLocal(merged);
    await _syncRemote(userId, merged);
    return merged;
  }

  Future<void> hideTitle(MediaTitle media, bool isTv) async {
    await hideHiddenTitle(
      HiddenTitle(
        id: media.id,
        title: media.title,
        posterPath: media.posterPath,
        releaseDate: media.releaseDate,
        isTv: isTv,
        voteAverage: media.voteAverage,
        hiddenAt: DateTime.now(),
      ),
    );
  }

  Future<void> hideHiddenTitle(HiddenTitle hiddenTitle) async {
    final List<HiddenTitle> currentList = state.value ?? [];
    if (currentList.any(
      (item) => item.id == hiddenTitle.id && item.isTv == hiddenTitle.isTv,
    )) {
      return;
    }
    final List<HiddenTitle> updatedList = [...currentList, hiddenTitle];
    state = AsyncData(updatedList);
    await _persistLocal(updatedList);
    final String? userId = ref.read(authStateProvider).value?.id;
    if (userId != null) {
      await _syncRemote(userId, updatedList);
    }
  }

  Future<void> unhideTitle(int id, bool isTv) async {
    final List<HiddenTitle> currentList = state.value ?? [];
    final List<HiddenTitle> updatedList = currentList
        .where((item) => !(item.id == id && item.isTv == isTv))
        .toList();
    state = AsyncData(updatedList);
    await _persistLocal(updatedList);
    final String? userId = ref.read(authStateProvider).value?.id;
    if (userId != null) {
      await _syncRemote(userId, updatedList);
    }
  }

  Future<bool> getDontAskAgain() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dontAskAgainStorageKey) ?? false;
  }

  Future<void> setDontAskAgain(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dontAskAgainStorageKey, value);
  }

  Future<List<HiddenTitle>> _loadLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_hiddenTitlesStorageKey);
    if (jsonString == null) {
      return <HiddenTitle>[];
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => HiddenTitle.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return <HiddenTitle>[];
    }
  }

  Future<List<HiddenTitle>> _loadRemote(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(userId)
        .collection('appState')
        .doc('hiddenTitles')
        .get();
    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) {
      return <HiddenTitle>[];
    }
    final List<dynamic> entries =
        data['entries'] as List<dynamic>? ?? <dynamic>[];
    return entries
        .map(
          (dynamic item) =>
              HiddenTitle.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  List<HiddenTitle> _mergeHiddenTitles(
    List<HiddenTitle> local,
    List<HiddenTitle> remote,
  ) {
    final Map<String, HiddenTitle> merged = <String, HiddenTitle>{};
    for (final HiddenTitle item in <HiddenTitle>[...remote, ...local]) {
      final String key = '${item.isTv}:${item.id}';
      final HiddenTitle? existing = merged[key];
      if (existing == null || item.hiddenAt.isAfter(existing.hiddenAt)) {
        merged[key] = item;
      }
    }
    final List<HiddenTitle> values = merged.values.toList(growable: false);
    values.sort(
      (HiddenTitle a, HiddenTitle b) => b.hiddenAt.compareTo(a.hiddenAt),
    );
    return values;
  }

  Future<void> _persistLocal(List<HiddenTitle> titles) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      titles.map((HiddenTitle item) => item.toJson()).toList(growable: false),
    );
    await prefs.setString(_hiddenTitlesStorageKey, encoded);
  }

  Future<void> _syncRemote(String userId, List<HiddenTitle> titles) async {
    await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(userId)
        .collection('appState')
        .doc('hiddenTitles')
        .set(<String, dynamic>{
          'entries': titles
              .map((HiddenTitle item) => item.toJson())
              .toList(growable: false),
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}

final hiddenTitlesProvider =
    AsyncNotifierProvider<HiddenTitlesNotifier, List<HiddenTitle>>(
      HiddenTitlesNotifier.new,
    );
