import 'dart:convert';
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_hiddenTitlesStorageKey);
    if (jsonString == null) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => HiddenTitle.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> hideTitle(MediaTitle media, bool isTv) async {
    final List<HiddenTitle> currentList = state.value ?? [];
    if (currentList.any((item) => item.id == media.id && item.isTv == isTv)) {
      return;
    }
    final HiddenTitle newHidden = HiddenTitle(
      id: media.id,
      title: media.title,
      posterPath: media.posterPath,
      releaseDate: media.releaseDate,
      isTv: isTv,
      voteAverage: media.voteAverage,
      hiddenAt: DateTime.now(),
    );
    final List<HiddenTitle> updatedList = [...currentList, newHidden];
    state = AsyncData(updatedList);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      updatedList.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_hiddenTitlesStorageKey, encoded);
  }

  Future<void> unhideTitle(int id, bool isTv) async {
    final List<HiddenTitle> currentList = state.value ?? [];
    final List<HiddenTitle> updatedList = currentList
        .where((item) => !(item.id == id && item.isTv == isTv))
        .toList();
    state = AsyncData(updatedList);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      updatedList.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_hiddenTitlesStorageKey, encoded);
  }

  Future<bool> getDontAskAgain() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dontAskAgainStorageKey) ?? false;
  }

  Future<void> setDontAskAgain(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dontAskAgainStorageKey, value);
  }
}

final hiddenTitlesProvider =
    AsyncNotifierProvider<HiddenTitlesNotifier, List<HiddenTitle>>(
  HiddenTitlesNotifier.new,
);
