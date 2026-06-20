import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:cineverse/core/constants/app_constants.dart';
import 'package:cineverse/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _selectedTmdbRegionKey = 'selected_tmdb_region';
const String _detectedTmdbRegionKey = 'detected_tmdb_region';
const String _detectedTmdbRegionUpdatedAtKey =
    'detected_tmdb_region_updated_at';
const Duration _detectedRegionCacheTtl = Duration(hours: 24);

class RegionOption {
  const RegionOption({required this.code, required this.label});

  final String code;
  final String label;
}

const List<RegionOption> commonRegionOptions = <RegionOption>[
  RegionOption(code: 'US', label: 'United States'),
  RegionOption(code: 'IN', label: 'India'),
  RegionOption(code: 'GB', label: 'United Kingdom'),
  RegionOption(code: 'CA', label: 'Canada'),
  RegionOption(code: 'AU', label: 'Australia'),
  RegionOption(code: 'NZ', label: 'New Zealand'),
  RegionOption(code: 'DE', label: 'Germany'),
  RegionOption(code: 'FR', label: 'France'),
  RegionOption(code: 'ES', label: 'Spain'),
  RegionOption(code: 'IT', label: 'Italy'),
  RegionOption(code: 'JP', label: 'Japan'),
  RegionOption(code: 'KR', label: 'South Korea'),
  RegionOption(code: 'BR', label: 'Brazil'),
  RegionOption(code: 'MX', label: 'Mexico'),
  RegionOption(code: 'SG', label: 'Singapore'),
  RegionOption(code: 'PH', label: 'Philippines'),
  RegionOption(code: 'ID', label: 'Indonesia'),
  RegionOption(code: 'AE', label: 'United Arab Emirates'),
  RegionOption(code: 'SA', label: 'Saudi Arabia'),
  RegionOption(code: 'TR', label: 'Turkey'),
];

RegionOption? regionOptionForCode(String code) {
  for (final RegionOption option in commonRegionOptions) {
    if (option.code == code) {
      return option;
    }
  }

  return null;
}

String regionLabelForCode(String code) {
  return regionOptionForCode(code)?.label ?? code;
}

String localizedRegionLabel(AppLocalizations l10n, String code) {
  return switch (code) {
    'US' => l10n.regionUnitedStates,
    'IN' => l10n.regionIndia,
    'GB' => l10n.regionUnitedKingdom,
    'CA' => l10n.regionCanada,
    'AU' => l10n.regionAustralia,
    'NZ' => l10n.regionNewZealand,
    'DE' => l10n.regionGermany,
    'FR' => l10n.regionFrance,
    'ES' => l10n.regionSpain,
    'IT' => l10n.regionItaly,
    'JP' => l10n.regionJapan,
    'KR' => l10n.regionSouthKorea,
    'BR' => l10n.regionBrazil,
    'MX' => l10n.regionMexico,
    'SG' => l10n.regionSingapore,
    'PH' => l10n.regionPhilippines,
    'ID' => l10n.regionIndonesia,
    'AE' => l10n.regionUnitedArabEmirates,
    'SA' => l10n.regionSaudiArabia,
    'TR' => l10n.regionTurkey,
    _ => regionLabelForCode(code),
  };
}

class SelectedRegionController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return normalizeRegionCode(preferences.getString(_selectedTmdbRegionKey));
  }

  Future<void> setSelectedRegion(String? regionCode) async {
    final String? normalizedRegionCode = normalizeRegionCode(regionCode);
    final String? previousRegionCode = state.asData?.value;
    state = AsyncData(normalizedRegionCode);

    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      if (normalizedRegionCode == null) {
        await preferences.remove(_selectedTmdbRegionKey);
      } else {
        await preferences.setString(
          _selectedTmdbRegionKey,
          normalizedRegionCode,
        );
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previousRegionCode);
      rethrow;
    }
  }
}

class AutoDetectedRegionController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final String? localeRegionCode = _detectRegionCodeFromDeviceLocale();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final String? cachedRegionCode = normalizeRegionCode(
      preferences.getString(_detectedTmdbRegionKey),
    );
    final int cachedUpdatedAtMs =
        preferences.getInt(_detectedTmdbRegionUpdatedAtKey) ?? 0;
    final bool hasFreshCache =
        cachedRegionCode != null &&
        nowMs - cachedUpdatedAtMs <= _detectedRegionCacheTtl.inMilliseconds;

    final String? initialRegionCode = hasFreshCache
        ? cachedRegionCode
        : localeRegionCode;

    unawaited(
      _refreshRegionFromIp(
        preferences: preferences,
        localeRegionCode: localeRegionCode,
      ),
    );
    return initialRegionCode;
  }

  Future<void> _refreshRegionFromIp({
    required SharedPreferences preferences,
    required String? localeRegionCode,
  }) async {
    final String? ipRegionCode = await _lookupRegionCodeFromIp();
    final String? normalizedIpRegionCode = normalizeRegionCode(ipRegionCode);
    final String? resolvedRegionCode =
        normalizedIpRegionCode ?? localeRegionCode;
    if (resolvedRegionCode == null) {
      return;
    }

    if (state.asData?.value != resolvedRegionCode) {
      state = AsyncData(resolvedRegionCode);
    }

    try {
      await preferences.setString(_detectedTmdbRegionKey, resolvedRegionCode);
      await preferences.setInt(
        _detectedTmdbRegionUpdatedAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // best effort cache only
    }
  }

  Future<String?> _lookupRegionCodeFromIp() async {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        sendTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );
    try {
      final Response<dynamic> response = await dio.get<dynamic>(
        'https://ipapi.co/json/',
        options: Options(
          headers: const <String, String>{
            'Accept': 'application/json',
            'User-Agent': 'Lumi/1.0',
          },
        ),
      );
      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) {
        return null;
      }
      if (data['error'] == true) {
        return null;
      }
      return data['country_code'] as String?;
    } catch (_) {
      return null;
    } finally {
      dio.close(force: true);
    }
  }
}

String? normalizeRegionCode(String? regionCode) {
  if (regionCode == null) {
    return null;
  }

  final String trimmedRegionCode = regionCode.trim().toUpperCase();
  if (trimmedRegionCode.isEmpty) {
    return null;
  }

  return RegExp(r'^[A-Z]{2}$').hasMatch(trimmedRegionCode)
      ? trimmedRegionCode
      : null;
}

String? _detectRegionCodeFromDeviceLocale() {
  for (final locale in PlatformDispatcher.instance.locales) {
    final String? code = normalizeRegionCode(locale.countryCode);
    if (code != null) {
      return code;
    }
  }
  return normalizeRegionCode(PlatformDispatcher.instance.locale.countryCode);
}

final selectedRegionCodeProvider =
    AsyncNotifierProvider<SelectedRegionController, String?>(
      SelectedRegionController.new,
    );

final autoDetectedRegionCodeProvider =
    AsyncNotifierProvider<AutoDetectedRegionController, String?>(
      AutoDetectedRegionController.new,
    );

final detectedRegionCodeProvider = Provider<String?>((ref) {
  return ref.watch(autoDetectedRegionCodeProvider).asData?.value ??
      _detectRegionCodeFromDeviceLocale();
});

final preferredRegionCodeProvider = Provider<String>((ref) {
  return ref.watch(selectedRegionCodeProvider).asData?.value ??
      ref.watch(detectedRegionCodeProvider) ??
      AppConstants.tmdbDefaultRegion;
});
