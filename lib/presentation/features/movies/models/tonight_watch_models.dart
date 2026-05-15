import 'package:cineverse/domain/entities/media_title.dart';
import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/entities/movie_mood.dart';

class TonightTimeOption {
  const TonightTimeOption({
    required this.id,
    required this.movieLabel,
    required this.movieDescription,
    required this.tvLabel,
    required this.tvDescription,
    required this.minMinutes,
    required this.maxMinutes,
  });

  final String id;
  final String movieLabel;
  final String movieDescription;
  final String tvLabel;
  final String tvDescription;
  final int minMinutes;
  final int maxMinutes;

  String label(bool isTv) => isTv ? tvLabel : movieLabel;

  String description(bool isTv) => isTv ? tvDescription : movieDescription;

  String get durationLabel {
    if (minMinutes <= 0) {
      return '$maxMinutes min';
    }
    return '$minMinutes-$maxMinutes min';
  }
}

class TonightLanguageOption {
  const TonightLanguageOption({
    required this.code,
    required this.label,
    required this.accentHex,
  });

  final String code;
  final String label;
  final int accentHex;
}

class TonightWatchRequest {
  const TonightWatchRequest({
    required this.isTv,
    required this.timeOption,
    required this.mood,
    required this.language,
  });

  final bool isTv;
  final TonightTimeOption timeOption;
  final MovieMood mood;
  final TonightLanguageOption language;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TonightWatchRequest &&
            runtimeType == other.runtimeType &&
            isTv == other.isTv &&
            timeOption.id == other.timeOption.id &&
            mood == other.mood &&
            language.code == other.language.code;
  }

  @override
  int get hashCode => Object.hash(isTv, timeOption.id, mood, language.code);
}

class TonightWatchResult {
  const TonightWatchResult({
    required this.title,
    required this.details,
    required this.explanation,
  });

  final MediaTitle title;
  final MovieDetails details;
  final String explanation;
}

const List<TonightTimeOption> tonightMovieTimeOptions = <TonightTimeOption>[
  TonightTimeOption(
    id: 'snack',
    movieLabel: 'Snackable',
    movieDescription: 'A tight watch for a lighter night in.',
    tvLabel: 'Quick Escape',
    tvDescription: 'Short episodes you can finish before midnight.',
    minMinutes: 0,
    maxMinutes: 95,
  ),
  TonightTimeOption(
    id: 'prime',
    movieLabel: 'Prime Time',
    movieDescription: 'A full, satisfying feature-length pick.',
    tvLabel: 'One Big Episode',
    tvDescription: 'An episode with enough room to breathe.',
    minMinutes: 96,
    maxMinutes: 130,
  ),
  TonightTimeOption(
    id: 'luxury',
    movieLabel: 'Luxury Runtime',
    movieDescription: 'You are in the mood to sink into something bigger.',
    tvLabel: 'Epic Episode',
    tvDescription: 'Long-form episodes for a richer late-night watch.',
    minMinutes: 131,
    maxMinutes: 210,
  ),
];

const List<TonightLanguageOption>
tonightLanguageOptions = <TonightLanguageOption>[
  TonightLanguageOption(code: 'en', label: 'English', accentHex: 0xFF7AE7FF),
  TonightLanguageOption(code: 'hi', label: 'Hindi', accentHex: 0xFFFFA94D),
  TonightLanguageOption(code: 'ta', label: 'Tamil', accentHex: 0xFFFF6B6B),
  TonightLanguageOption(code: 'te', label: 'Telugu', accentHex: 0xFFFFD93D),
  TonightLanguageOption(code: 'ko', label: 'Korean', accentHex: 0xFF9B8CFF),
  TonightLanguageOption(code: 'ja', label: 'Japanese', accentHex: 0xFFFF8AAE),
  TonightLanguageOption(code: 'es', label: 'Spanish', accentHex: 0xFF67E8A5),
  TonightLanguageOption(code: 'fr', label: 'French', accentHex: 0xFF8AD8FF),
  TonightLanguageOption(code: 'de', label: 'German', accentHex: 0xFFCFA8FF),
];
