import 'dart:convert';

import 'package:cineverse/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _tonightFeedbackStorageKey = 'tonight_recommendation_feedback_v2';

enum TonightFeedbackSignal {
  watchedAlready,
  notInterested,
  tooMainstream,
  moreLikeThis,
}

class TonightFeedbackEntry {
  const TonightFeedbackEntry({
    required this.mediaId,
    required this.isTv,
    required this.signals,
    this.title,
    this.posterPath,
    this.genres = const <String>[],
    this.originalLanguage,
    this.popularity,
    this.updatedAt,
  });

  final int mediaId;
  final bool isTv;
  final Set<TonightFeedbackSignal> signals;
  final String? title;
  final String? posterPath;
  final List<String> genres;
  final String? originalLanguage;
  final double? popularity;
  final DateTime? updatedAt;

  TonightFeedbackEntry copyWith({
    Set<TonightFeedbackSignal>? signals,
    String? title,
    String? posterPath,
    List<String>? genres,
    String? originalLanguage,
    double? popularity,
    DateTime? updatedAt,
  }) {
    return TonightFeedbackEntry(
      mediaId: mediaId,
      isTv: isTv,
      signals: signals ?? this.signals,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      genres: genres ?? this.genres,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      popularity: popularity ?? this.popularity,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mediaId': mediaId,
      'isTv': isTv,
      'signals': signals
          .map((TonightFeedbackSignal signal) => signal.name)
          .toList(growable: false),
      'title': title,
      'posterPath': posterPath,
      'genres': genres,
      'originalLanguage': originalLanguage,
      'popularity': popularity,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory TonightFeedbackEntry.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSignals =
        (json['signals'] as List<dynamic>?) ?? <dynamic>[];
    final Set<TonightFeedbackSignal> parsedSignals = rawSignals
        .whereType<String>()
        .map(
          (String raw) => TonightFeedbackSignal.values.firstWhere(
            (TonightFeedbackSignal signal) => signal.name == raw,
            orElse: () => TonightFeedbackSignal.moreLikeThis,
          ),
        )
        .toSet();
    return TonightFeedbackEntry(
      mediaId: json['mediaId'] as int,
      isTv: json['isTv'] as bool? ?? false,
      signals: parsedSignals,
      title: json['title'] as String?,
      posterPath: json['posterPath'] as String?,
      genres: ((json['genres'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<String>()
          .toList(growable: false),
      originalLanguage: json['originalLanguage'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'] as String),
    );
  }

  factory TonightFeedbackEntry.fromLegacy({
    required int mediaId,
    required bool isTv,
    required List<String> signals,
  }) {
    return TonightFeedbackEntry(
      mediaId: mediaId,
      isTv: isTv,
      signals: signals
          .map(
            (String raw) => TonightFeedbackSignal.values.firstWhere(
              (TonightFeedbackSignal signal) => signal.name == raw,
              orElse: () => TonightFeedbackSignal.moreLikeThis,
            ),
          )
          .toSet(),
    );
  }
}

class TonightPreferenceProfile {
  const TonightPreferenceProfile({
    required this.preferredGenres,
    required this.preferredLanguages,
    required this.mainstreamPenaltyStrength,
  });

  final Map<String, int> preferredGenres;
  final Map<String, int> preferredLanguages;
  final double mainstreamPenaltyStrength;
}

class TonightFeedbackStore
    extends AsyncNotifier<Map<String, TonightFeedbackEntry>> {
  @override
  Future<Map<String, TonightFeedbackEntry>> build() async {
    final String? userId = ref.watch(authStateProvider).value?.id;
    final Map<String, TonightFeedbackEntry> local = await _loadLocal();
    if (userId == null) {
      return local;
    }
    final Map<String, TonightFeedbackEntry> remote = await _loadRemote(userId);
    final Map<String, TonightFeedbackEntry> merged = _mergeEntries(
      local,
      remote,
    );
    await _persistLocal(merged);
    await _syncRemote(userId, merged);
    return merged;
  }

  Future<void> toggleSignal({
    required int mediaId,
    required bool isTv,
    required TonightFeedbackSignal signal,
    String? title,
    String? posterPath,
    List<String>? genres,
    String? originalLanguage,
    double? popularity,
  }) async {
    final TonightFeedbackEntry? currentEntry =
        state.value?[_feedbackKey(mediaId, isTv)];
    final bool nextValue = !(currentEntry?.signals.contains(signal) ?? false);
    await setSignal(
      mediaId: mediaId,
      isTv: isTv,
      signal: signal,
      enabled: nextValue,
      title: title,
      posterPath: posterPath,
      genres: genres,
      originalLanguage: originalLanguage,
      popularity: popularity,
    );
  }

  Future<void> setSignal({
    required int mediaId,
    required bool isTv,
    required TonightFeedbackSignal signal,
    required bool enabled,
    String? title,
    String? posterPath,
    List<String>? genres,
    String? originalLanguage,
    double? popularity,
  }) async {
    final String key = _feedbackKey(mediaId, isTv);
    final Map<String, TonightFeedbackEntry> current = {...?state.value};
    final TonightFeedbackEntry base =
        current[key] ??
        TonightFeedbackEntry(
          mediaId: mediaId,
          isTv: isTv,
          signals: const <TonightFeedbackSignal>{},
        );
    final Set<TonightFeedbackSignal> nextSignals = <TonightFeedbackSignal>{
      ...base.signals,
    };
    if (!enabled) {
      nextSignals.remove(signal);
    } else {
      nextSignals.add(signal);
      if (signal == TonightFeedbackSignal.notInterested ||
          signal == TonightFeedbackSignal.watchedAlready) {
        nextSignals.remove(TonightFeedbackSignal.moreLikeThis);
      }
    }
    if (nextSignals.isEmpty) {
      current.remove(key);
    } else {
      current[key] = base.copyWith(
        signals: nextSignals,
        title: title ?? base.title,
        posterPath: posterPath ?? base.posterPath,
        genres: genres == null || genres.isEmpty ? base.genres : genres,
        originalLanguage: originalLanguage ?? base.originalLanguage,
        popularity: popularity ?? base.popularity,
        updatedAt: DateTime.now(),
      );
    }
    state = AsyncData(current);
    await _persistLocal(current);
    final String? userId = ref.read(authStateProvider).value?.id;
    if (userId != null) {
      await _syncRemote(userId, current);
    }
  }

  Future<Map<String, TonightFeedbackEntry>> _loadLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_tonightFeedbackStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return <String, TonightFeedbackEntry>{};
    }
    final Object decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return <String, TonightFeedbackEntry>{};
    }
    return decoded.map((String key, dynamic value) {
      if (value is Map<String, dynamic>) {
        return MapEntry<String, TonightFeedbackEntry>(
          key,
          TonightFeedbackEntry.fromJson(value),
        );
      }
      if (value is List<dynamic>) {
        final List<String> signals = value.whereType<String>().toList();
        final bool isTv = key.startsWith('tv:');
        final int mediaId = int.tryParse(key.split(':').last) ?? 0;
        return MapEntry<String, TonightFeedbackEntry>(
          key,
          TonightFeedbackEntry.fromLegacy(
            mediaId: mediaId,
            isTv: isTv,
            signals: signals,
          ),
        );
      }
      return MapEntry<String, TonightFeedbackEntry>(
        key,
        TonightFeedbackEntry(
          mediaId: 0,
          isTv: key.startsWith('tv:'),
          signals: const <TonightFeedbackSignal>{},
        ),
      );
    });
  }

  Future<Map<String, TonightFeedbackEntry>> _loadRemote(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(userId)
        .collection('appState')
        .doc('tonightFeedback')
        .get();
    final Map<String, dynamic>? data = snapshot.data();
    if (data == null) {
      return <String, TonightFeedbackEntry>{};
    }
    final Map<String, dynamic> entries =
        data['entries'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return entries.map((String key, dynamic value) {
      return MapEntry<String, TonightFeedbackEntry>(
        key,
        TonightFeedbackEntry.fromJson(
          Map<String, dynamic>.from(value as Map<dynamic, dynamic>),
        ),
      );
    });
  }

  Map<String, TonightFeedbackEntry> _mergeEntries(
    Map<String, TonightFeedbackEntry> local,
    Map<String, TonightFeedbackEntry> remote,
  ) {
    final Map<String, TonightFeedbackEntry> merged = {...remote, ...local};
    for (final MapEntry<String, TonightFeedbackEntry> entry in remote.entries) {
      final TonightFeedbackEntry? localEntry = local[entry.key];
      if (localEntry == null) {
        merged[entry.key] = entry.value;
        continue;
      }
      final DateTime localTime =
          localEntry.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime remoteTime =
          entry.value.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      merged[entry.key] = remoteTime.isAfter(localTime)
          ? entry.value
          : localEntry;
    }
    return merged;
  }

  Future<void> _persistLocal(Map<String, TonightFeedbackEntry> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, dynamic>> payload = value.map(
      (String key, TonightFeedbackEntry entry) =>
          MapEntry<String, Map<String, dynamic>>(key, entry.toJson()),
    );
    await prefs.setString(_tonightFeedbackStorageKey, jsonEncode(payload));
  }

  Future<void> _syncRemote(
    String userId,
    Map<String, TonightFeedbackEntry> value,
  ) async {
    final Map<String, Map<String, dynamic>> payload = value.map(
      (String key, TonightFeedbackEntry entry) =>
          MapEntry<String, Map<String, dynamic>>(key, entry.toJson()),
    );
    await ref
        .read(firestoreProvider)
        .collection('users')
        .doc(userId)
        .collection('appState')
        .doc('tonightFeedback')
        .set(<String, dynamic>{
          'entries': payload,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}

final tonightFeedbackProvider =
    AsyncNotifierProvider<
      TonightFeedbackStore,
      Map<String, TonightFeedbackEntry>
    >(TonightFeedbackStore.new);

final tonightFeedbackEntryProvider =
    Provider.family<TonightFeedbackEntry?, ({int mediaId, bool isTv})>((
      ref,
      args,
    ) {
      final Map<String, TonightFeedbackEntry> state =
          ref.watch(tonightFeedbackProvider).value ??
          const <String, TonightFeedbackEntry>{};
      return state[_feedbackKey(args.mediaId, args.isTv)];
    });

final tonightFeedbackSignalsProvider =
    Provider.family<Set<TonightFeedbackSignal>, ({int mediaId, bool isTv})>((
      ref,
      args,
    ) {
      return ref.watch(tonightFeedbackEntryProvider(args))?.signals ??
          const <TonightFeedbackSignal>{};
    });

final tonightPreferenceProfileProvider =
    Provider.family<TonightPreferenceProfile, bool>((ref, isTv) {
      final Map<String, TonightFeedbackEntry> state =
          ref.watch(tonightFeedbackProvider).value ??
          const <String, TonightFeedbackEntry>{};
      final Map<String, int> preferredGenres = <String, int>{};
      final Map<String, int> preferredLanguages = <String, int>{};
      double mainstreamPenaltyStrength = 0;

      for (final TonightFeedbackEntry entry in state.values) {
        if (entry.isTv != isTv) {
          continue;
        }
        if (entry.signals.contains(TonightFeedbackSignal.moreLikeThis)) {
          for (final String genre in entry.genres) {
            preferredGenres[genre] = (preferredGenres[genre] ?? 0) + 1;
          }
          final String? language = entry.originalLanguage?.trim().toLowerCase();
          if (language != null && language.isNotEmpty) {
            preferredLanguages[language] =
                (preferredLanguages[language] ?? 0) + 1;
          }
        }
        if (entry.signals.contains(TonightFeedbackSignal.tooMainstream)) {
          mainstreamPenaltyStrength += 1;
        }
      }

      return TonightPreferenceProfile(
        preferredGenres: preferredGenres,
        preferredLanguages: preferredLanguages,
        mainstreamPenaltyStrength: mainstreamPenaltyStrength,
      );
    });

String _feedbackKey(int mediaId, bool isTv) =>
    '${isTv ? 'tv' : 'movie'}:$mediaId';
