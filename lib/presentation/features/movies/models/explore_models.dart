import 'package:cineverse/domain/entities/movie_section.dart';

class ExploreShelfData {
  const ExploreShelfData({
    required this.title,
    required this.filters,
    this.variant = 'normal',
  });

  final String title;
  final List<ExploreFilterOption> filters;
  final String variant;
}

enum RecSource { all, watchlist, favourites, lists, watched }

class ExploreFilterOption {
  const ExploreFilterOption({
    required this.label,
    this.section,
    this.genreId,
    this.isLibraryRecommendations = false,
    this.recSource = RecSource.all,
  });

  final String label;
  final MovieSection? section;
  final int? genreId;
  final bool isLibraryRecommendations;
  final RecSource recSource;

  bool matches(ExploreFilterOption other) {
    if (isLibraryRecommendations) {
      return other.isLibraryRecommendations && recSource == other.recSource;
    }
    if (section != null) return section == other.section;
    if (genreId != null) return genreId == other.genreId;
    return false;
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'section': section?.name,
    'genreId': genreId,
    'isLibraryRecommendations': isLibraryRecommendations,
    'recSource': recSource.name,
  };

  factory ExploreFilterOption.fromJson(Map<String, dynamic> json) => ExploreFilterOption(
    label: json['label'] as String,
    section: json['section'] != null ? MovieSection.values.firstWhere((e) => e.name == json['section']) : null,
    genreId: json['genreId'] as int?,
    isLibraryRecommendations: (json['isLibraryRecommendations'] as bool?) ?? false,
    recSource: json['recSource'] != null 
        ? RecSource.values.firstWhere((e) => e.name == json['recSource']) 
        : RecSource.all,
  );
}
