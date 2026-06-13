import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TonightAiConsentStatus { unknown, granted, declined }

const String _tonightAiConsentKey = 'tonight_ai_consent_status_v1';

class TonightAiConsentNotifier extends AsyncNotifier<TonightAiConsentStatus> {
  @override
  Future<TonightAiConsentStatus> build() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_tonightAiConsentKey);
    return _statusFromRaw(raw);
  }

  Future<void> grant() async {
    await _persist(TonightAiConsentStatus.granted);
  }

  Future<void> decline() async {
    await _persist(TonightAiConsentStatus.declined);
  }

  Future<void> reset() async {
    await _persist(TonightAiConsentStatus.unknown);
  }

  Future<void> _persist(TonightAiConsentStatus status) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    if (status == TonightAiConsentStatus.unknown) {
      await preferences.remove(_tonightAiConsentKey);
    } else {
      await preferences.setString(_tonightAiConsentKey, status.name);
    }
    state = AsyncData(status);
  }

  TonightAiConsentStatus _statusFromRaw(String? raw) {
    return switch (raw) {
      'granted' => TonightAiConsentStatus.granted,
      'declined' => TonightAiConsentStatus.declined,
      _ => TonightAiConsentStatus.unknown,
    };
  }
}

final tonightAiConsentProvider =
    AsyncNotifierProvider<TonightAiConsentNotifier, TonightAiConsentStatus>(
      TonightAiConsentNotifier.new,
    );
