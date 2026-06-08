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
    this.moreLikeThisPromptKeys = const <String>[],
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
  final List<String> moreLikeThisPromptKeys;
  final DateTime? updatedAt;

  TonightFeedbackEntry copyWith({
    Set<TonightFeedbackSignal>? signals,
    String? title,
    String? posterPath,
    List<String>? genres,
    String? originalLanguage,
    double? popularity,
    List<String>? moreLikeThisPromptKeys,
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
      moreLikeThisPromptKeys:
          moreLikeThisPromptKeys ?? this.moreLikeThisPromptKeys,
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
      'moreLikeThisPromptKeys': moreLikeThisPromptKeys,
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
      moreLikeThisPromptKeys:
          ((json['moreLikeThisPromptKeys'] as List<dynamic>?) ??
                  const <dynamic>[])
              .whereType<String>()
              .toList(growable: false),
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
    required this.moreLikeThisSeedIds,
    required this.tooMainstreamTitleIds,
    required this.rejectedMainstreamPopularities,
  });

  final Map<String, int> preferredGenres;
  final Map<String, int> preferredLanguages;
  final double mainstreamPenaltyStrength;
  final List<int> moreLikeThisSeedIds;
  final List<int> tooMainstreamTitleIds;
  final List<double> rejectedMainstreamPopularities;
}

class TonightFeedbackStore
    extends AsyncNotifier<Map<String, TonightFeedbackEntry>> {
  @override
  Future<Map<String, TonightFeedbackEntry>> build() async {
    final String? userId = ref.watch(authStateProvider).value?.id;
    final Map<String, TonightFeedbackEntry> local = _sanitizePersistedEntries(
      await _loadLocal(),
    );
    if (userId == null) {
      return local;
    }
    final Map<String, TonightFeedbackEntry> remote = _sanitizePersistedEntries(
      await _loadRemote(userId),
    );
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
    String? promptContext,
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
      promptContext: promptContext,
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
    String? promptContext,
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
    final Set<String> nextMoreLikeThisPromptKeys = <String>{
      ...base.moreLikeThisPromptKeys,
    };
    final String? normalizedPromptKey = promptContext == null
        ? null
        : normalizeTonightPromptScope(promptContext);
    final Set<TonightFeedbackSignal> nextSignals = <TonightFeedbackSignal>{
      ...base.signals,
    };
    if (!enabled) {
      if (signal == TonightFeedbackSignal.moreLikeThis &&
          normalizedPromptKey != null) {
        nextMoreLikeThisPromptKeys.remove(normalizedPromptKey);
        if (nextMoreLikeThisPromptKeys.isEmpty) {
          nextSignals.remove(signal);
        }
      } else {
        nextSignals.remove(signal);
        if (signal == TonightFeedbackSignal.moreLikeThis) {
          nextMoreLikeThisPromptKeys.clear();
        }
      }
    } else {
      nextSignals.add(signal);
      if (signal == TonightFeedbackSignal.moreLikeThis &&
          normalizedPromptKey != null &&
          normalizedPromptKey.isNotEmpty) {
        nextMoreLikeThisPromptKeys.add(normalizedPromptKey);
      }
      if (signal == TonightFeedbackSignal.notInterested ||
          signal == TonightFeedbackSignal.watchedAlready) {
        nextSignals.remove(TonightFeedbackSignal.moreLikeThis);
        nextMoreLikeThisPromptKeys.clear();
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
        moreLikeThisPromptKeys: nextMoreLikeThisPromptKeys.toList(
          growable: false,
        ),
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

  Future<void> clearPreferenceSignalsForMediaType(bool isTv) async {
    final Map<String, TonightFeedbackEntry> current = {...?state.value};

    for (final MapEntry<String, TonightFeedbackEntry> entry
        in current.entries.toList()) {
      final TonightFeedbackEntry value = entry.value;
      if (value.isTv != isTv) {
        continue;
      }
      final Set<TonightFeedbackSignal> nextSignals =
          <TonightFeedbackSignal>{...value.signals}
            ..remove(TonightFeedbackSignal.moreLikeThis)
            ..remove(TonightFeedbackSignal.tooMainstream);
      if (nextSignals.isEmpty) {
        current.remove(entry.key);
      } else {
        current[entry.key] = value.copyWith(
          signals: nextSignals,
          moreLikeThisPromptKeys: const <String>[],
          updatedAt: DateTime.now(),
        );
      }
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
    final Map<String, TonightFeedbackEntry> persisted =
        _sanitizePersistedEntries(value);
    final Map<String, Map<String, dynamic>> payload = persisted.map(
      (String key, TonightFeedbackEntry entry) =>
          MapEntry<String, Map<String, dynamic>>(key, entry.toJson()),
    );
    await prefs.setString(_tonightFeedbackStorageKey, jsonEncode(payload));
  }

  Future<void> _syncRemote(
    String userId,
    Map<String, TonightFeedbackEntry> value,
  ) async {
    final Map<String, TonightFeedbackEntry> persisted =
        _sanitizePersistedEntries(value);
    final Map<String, Map<String, dynamic>> payload = persisted.map(
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

  Map<String, TonightFeedbackEntry> _sanitizePersistedEntries(
    Map<String, TonightFeedbackEntry> entries,
  ) {
    final Map<String, TonightFeedbackEntry> sanitized =
        <String, TonightFeedbackEntry>{};
    for (final MapEntry<String, TonightFeedbackEntry> entry
        in entries.entries) {
      final Set<TonightFeedbackSignal> persistedSignals = entry.value.signals
          .where((TonightFeedbackSignal signal) {
            return signal != TonightFeedbackSignal.moreLikeThis;
          })
          .toSet();
      if (persistedSignals.isEmpty) {
        continue;
      }
      sanitized[entry.key] = entry.value.copyWith(
        signals: persistedSignals,
        moreLikeThisPromptKeys: const <String>[],
      );
    }
    return sanitized;
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
    Provider.family<
      Set<TonightFeedbackSignal>,
      ({int mediaId, bool isTv, String? promptContext})
    >((ref, args) {
      final TonightFeedbackEntry? entry = ref.watch(
        tonightFeedbackEntryProvider((mediaId: args.mediaId, isTv: args.isTv)),
      );
      if (entry == null) {
        return const <TonightFeedbackSignal>{};
      }
      final Set<TonightFeedbackSignal> signals = <TonightFeedbackSignal>{
        ...entry.signals,
      };
      if (signals.contains(TonightFeedbackSignal.moreLikeThis)) {
        final String promptKey = args.promptContext == null
            ? ''
            : normalizeTonightPromptScope(args.promptContext!);
        if (promptKey.isEmpty ||
            !entry.moreLikeThisPromptKeys.contains(promptKey)) {
          signals.remove(TonightFeedbackSignal.moreLikeThis);
        }
      }
      return signals;
    });

final tonightPreferenceProfileProvider =
    Provider.family<
      TonightPreferenceProfile,
      ({bool isTv, String promptContext})
    >((ref, args) {
      final Map<String, TonightFeedbackEntry> state =
          ref.watch(tonightFeedbackProvider).value ??
          const <String, TonightFeedbackEntry>{};
      final Map<String, int> preferredGenres = <String, int>{};
      final Map<String, int> preferredLanguages = <String, int>{};
      double mainstreamPenaltyStrength = 0;
      final Set<int> moreLikeThisSeedIds = <int>{};
      final Set<int> tooMainstreamTitleIds = <int>{};
      final List<double> rejectedMainstreamPopularities = <double>[];
      final String promptKey = normalizeTonightPromptScope(args.promptContext);

      for (final TonightFeedbackEntry entry in state.values) {
        if (entry.isTv != args.isTv) {
          continue;
        }
        if (entry.signals.contains(TonightFeedbackSignal.moreLikeThis) &&
            promptKey.isNotEmpty &&
            entry.moreLikeThisPromptKeys.contains(promptKey)) {
          moreLikeThisSeedIds.add(entry.mediaId);
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
          tooMainstreamTitleIds.add(entry.mediaId);
          if (entry.popularity != null && entry.popularity! > 0) {
            rejectedMainstreamPopularities.add(entry.popularity!);
          }
        }
      }

      return TonightPreferenceProfile(
        preferredGenres: preferredGenres,
        preferredLanguages: preferredLanguages,
        mainstreamPenaltyStrength: mainstreamPenaltyStrength,
        moreLikeThisSeedIds: moreLikeThisSeedIds.toList(growable: false),
        tooMainstreamTitleIds: tooMainstreamTitleIds.toList(growable: false),
        rejectedMainstreamPopularities: rejectedMainstreamPopularities,
      );
    });

final tonightHasClearablePreferencesProvider = Provider.family<bool, bool>((
  ref,
  isTv,
) {
  final Map<String, TonightFeedbackEntry> state =
      ref.watch(tonightFeedbackProvider).value ??
      const <String, TonightFeedbackEntry>{};
  for (final TonightFeedbackEntry entry in state.values) {
    if (entry.isTv != isTv) {
      continue;
    }
    if (entry.signals.contains(TonightFeedbackSignal.moreLikeThis) ||
        entry.signals.contains(TonightFeedbackSignal.tooMainstream)) {
      return true;
    }
  }
  return false;
});

String _feedbackKey(int mediaId, bool isTv) =>
    '${isTv ? 'tv' : 'movie'}:$mediaId';

String normalizeTonightPromptScope(String prompt) =>
    prompt.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
