import 'package:cineverse/domain/entities/movie_mood.dart';
import 'package:flutter/material.dart';

enum SortField {
  popularity('popularity', 'Popularity'),
  revenue('revenue', 'Revenue'),
  releaseDate('primary_release_date', 'Release Date'),
  voteAverage('vote_average', 'Rating'),
  voteCount('vote_count', 'Vote Count');

  const SortField(this.value, this.label);
  final String value;
  final String label;
}

enum SortOrder {
  ascending('asc', 'Ascending'),
  descending('desc', 'Descending');

  const SortOrder(this.value, this.label);
  final String value;
  final String label;
}

class MediaFilter {
  const MediaFilter({
    this.sortField = SortField.popularity,
    this.sortOrder = SortOrder.descending,
    this.availabilities = const {},
    this.userScore = const RangeValues(0, 10),
    this.includeNotRated = true,
    this.releaseDateFrom,
    this.releaseDateTo,
    this.releaseTypes = const {},
    this.minUserVotes = 0,
    this.genres = const {},
    this.runtime = const RangeValues(0, 390),
    this.personIds = const {},
    this.personNames = const {},
    this.mood,
  });

  final SortField sortField;
  final SortOrder sortOrder;
  final Set<String> availabilities; // flatrate, free, ads, rent, buy
  final RangeValues userScore; // 0.0 to 10.0
  final bool includeNotRated;
  final DateTime? releaseDateFrom;
  final DateTime? releaseDateTo;
  final Set<int> releaseTypes; // 1, 2, 3, 4, 5, 6
  final int minUserVotes;
  final Set<int> genres;
  final RangeValues runtime; // 0 to 390
  final Set<int> personIds;
  final Set<String> personNames;
  final MovieMood? mood;

  bool get isDefault =>
      sortField == SortField.popularity &&
      sortOrder == SortOrder.descending &&
      availabilities.isEmpty &&
      userScore == const RangeValues(0, 10) &&
      includeNotRated == true &&
      releaseDateFrom == null &&
      releaseDateTo == null &&
      releaseTypes.isEmpty &&
      minUserVotes == 0 &&
      genres.isEmpty &&
      runtime == const RangeValues(0, 390) &&
      personIds.isEmpty &&
      personNames.isEmpty &&
      mood == null;

  String get sortByValue => '${sortField.value}.${sortOrder.value}';

  MediaFilter copyWith({
    SortField? sortField,
    SortOrder? sortOrder,
    Set<String>? availabilities,
    RangeValues? userScore,
    bool? includeNotRated,
    DateTime? releaseDateFrom,
    DateTime? releaseDateTo,
    Set<int>? releaseTypes,
    int? minUserVotes,
    Set<int>? genres,
    RangeValues? runtime,
    Set<int>? personIds,
    Set<String>? personNames,
    MovieMood? mood,
    bool clearMood = false,
  }) {
    return MediaFilter(
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      availabilities: availabilities ?? this.availabilities,
      userScore: userScore ?? this.userScore,
      includeNotRated: includeNotRated ?? this.includeNotRated,
      releaseDateFrom: releaseDateFrom ?? this.releaseDateFrom,
      releaseDateTo: releaseDateTo ?? this.releaseDateTo,
      releaseTypes: releaseTypes ?? this.releaseTypes,
      minUserVotes: minUserVotes ?? this.minUserVotes,
      genres: genres ?? this.genres,
      runtime: runtime ?? this.runtime,
      personIds: personIds ?? this.personIds,
      personNames: personNames ?? this.personNames,
      mood: clearMood ? null : (mood ?? this.mood),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFilter &&
          runtimeType == other.runtimeType &&
          sortField == other.sortField &&
          sortOrder == other.sortOrder &&
          availabilities == other.availabilities &&
          userScore == other.userScore &&
          includeNotRated == other.includeNotRated &&
          releaseDateFrom == other.releaseDateFrom &&
          releaseDateTo == other.releaseDateTo &&
          releaseTypes == other.releaseTypes &&
          minUserVotes == other.minUserVotes &&
          genres == other.genres &&
          runtime == other.runtime &&
          personIds == other.personIds &&
          personNames == other.personNames &&
          mood == other.mood;

  @override
  int get hashCode =>
      sortField.hashCode ^
      sortOrder.hashCode ^
      availabilities.hashCode ^
      userScore.hashCode ^
      includeNotRated.hashCode ^
      releaseDateFrom.hashCode ^
      releaseDateTo.hashCode ^
      releaseTypes.hashCode ^
      minUserVotes.hashCode ^
      genres.hashCode ^
      runtime.hashCode ^
      personIds.hashCode ^
      personNames.hashCode ^
      mood.hashCode;
}
