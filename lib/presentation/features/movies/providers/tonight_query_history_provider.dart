import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _tonightQueryHistoryKey = 'tonight_query_history_v1';
const int _tonightQueryHistoryLimit = 12;

class TonightQueryHistoryNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_tonightQueryHistoryKey) ?? <String>[];
  }

  Future<void> addEntry(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> next = <String>[
      trimmed,
      ...state.asData?.value.where((entry) => entry != trimmed) ??
          const <String>[],
    ].take(_tonightQueryHistoryLimit).toList(growable: false);
    await preferences.setStringList(_tonightQueryHistoryKey, next);
    state = AsyncData(next);
  }

  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tonightQueryHistoryKey);
    state = const AsyncData(<String>[]);
  }
}

final tonightQueryHistoryProvider =
    AsyncNotifierProvider<TonightQueryHistoryNotifier, List<String>>(
      TonightQueryHistoryNotifier.new,
    );
