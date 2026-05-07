import 'package:cineverse/core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _selectedTmdbRegionKey = 'selected_tmdb_region';

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

class SelectedRegionController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return _normalizeRegionCode(preferences.getString(_selectedTmdbRegionKey));
  }

  Future<void> setSelectedRegion(String? regionCode) async {
    final String? normalizedRegionCode = _normalizeRegionCode(regionCode);
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

  String? _normalizeRegionCode(String? regionCode) {
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
}

final selectedRegionCodeProvider =
    AsyncNotifierProvider<SelectedRegionController, String?>(
      SelectedRegionController.new,
    );

final preferredRegionCodeProvider = Provider<String>((ref) {
  return ref.watch(selectedRegionCodeProvider).asData?.value ??
      AppConstants.tmdbDefaultRegion;
});
