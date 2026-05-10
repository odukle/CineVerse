import 'package:cineverse/domain/entities/media_filter.dart';
import 'package:flutter/material.dart';

enum GlobalMediaType {
  movie('Movie'),
  tv('TV Show'),
  person('Person'),
  both('Movie & TV Show');

  const GlobalMediaType(this.label);
  final String label;
}

class GlobalMediaFilter {
  const GlobalMediaFilter({
    this.mediaType = GlobalMediaType.both,
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
  });

  final GlobalMediaType mediaType;
  final SortField sortField;
  final SortOrder sortOrder;
  final Set<String> availabilities;
  final RangeValues userScore;
  final bool includeNotRated;
  final DateTime? releaseDateFrom;
  final DateTime? releaseDateTo;
  final Set<int> releaseTypes;
  final int minUserVotes;
  final Set<int> genres;
  final RangeValues runtime;
  final Set<int> personIds;
  final Set<String> personNames;

  String get sortByValue => '${sortField.value}.${sortOrder.value}';

  bool get isDefault =>
      mediaType == GlobalMediaType.both &&
      sortField == SortField.popularity &&
      sortOrder == SortOrder.descending &&
      availabilities.isEmpty &&
      userScore.start == 0 &&
      userScore.end == 10 &&
      includeNotRated == true &&
      releaseDateFrom == null &&
      releaseDateTo == null &&
      releaseTypes.isEmpty &&
      minUserVotes == 0 &&
      genres.isEmpty &&
      runtime.start == 0 &&
      runtime.end == 390 &&
      personIds.isEmpty &&
      personNames.isEmpty;

  MediaFilter toMediaFilter() {
    return MediaFilter(
      sortField: sortField,
      sortOrder: sortOrder,
      availabilities: availabilities,
      userScore: userScore,
      includeNotRated: includeNotRated,
      releaseDateFrom: releaseDateFrom,
      releaseDateTo: releaseDateTo,
      releaseTypes: releaseTypes,
      minUserVotes: minUserVotes,
      genres: genres,
      runtime: runtime,
      personIds: personIds,
      personNames: personNames,
    );
  }

  GlobalMediaFilter copyWith({
    GlobalMediaType? mediaType,
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
  }) {
    return GlobalMediaFilter(
      mediaType: mediaType ?? this.mediaType,
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
    );
  }
}
