import 'package:cineverse/data/models/tmdb_movie_dto.dart';
import 'package:cineverse/domain/entities/person_details.dart';

class TmdbPersonDetailsDto {
  const TmdbPersonDetailsDto({
    required this.id,
    required this.name,
    this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.profilePath,
    this.knownForDepartment,
    this.alsoKnownAs,
    this.gender,
    this.homepage,
    this.popularity,
    this.isAdult,
    this.imdbId,
    this.facebookId,
    this.instagramId,
    this.twitterId,
    this.tiktokId,
    this.youtubeId,
    this.wikidataId,
    this.freebaseId,
    this.freebaseMid,
    this.tvrageId,
  });

  factory TmdbPersonDetailsDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> externalIds =
        (json['external_ids'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    String? externalValue(String key) {
      return ((externalIds[key] ?? json[key]) as String?)?.trim();
    }

    return TmdbPersonDetailsDto(
      id: json['id'] as int,
      name: json['name'] as String,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      alsoKnownAs: _readAliases(json['also_known_as']),
      gender: (json['gender'] as num?)?.toInt(),
      homepage: (json['homepage'] as String?)?.trim(),
      popularity: (json['popularity'] as num?)?.toDouble(),
      isAdult: json['adult'] as bool?,
      imdbId: externalValue('imdb_id'),
      facebookId: externalValue('facebook_id'),
      instagramId: externalValue('instagram_id'),
      twitterId: externalValue('twitter_id'),
      tiktokId: externalValue('tiktok_id'),
      youtubeId: externalValue('youtube_id'),
      wikidataId: externalValue('wikidata_id'),
      freebaseId: externalValue('freebase_id'),
      freebaseMid: externalValue('freebase_mid'),
      tvrageId: (externalIds['tvrage_id'] ?? json['tvrage_id']) is num
          ? ((externalIds['tvrage_id'] ?? json['tvrage_id']) as num).toInt()
          : null,
    );
  }

  final int id;
  final String name;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String? profilePath;
  final String? knownForDepartment;
  final List<String>? alsoKnownAs;
  final int? gender;
  final String? homepage;
  final double? popularity;
  final bool? isAdult;
  final String? imdbId;
  final String? facebookId;
  final String? instagramId;
  final String? twitterId;
  final String? tiktokId;
  final String? youtubeId;
  final String? wikidataId;
  final String? freebaseId;
  final String? freebaseMid;
  final int? tvrageId;

  PersonDetails toDomain({Map<String, List<PersonCredit>> creditsByDepartment = const {}}) {
    return PersonDetails(
      id: id,
      name: name,
      biography: biography,
      birthday: birthday,
      deathday: deathday,
      placeOfBirth: placeOfBirth,
      profilePath: profilePath != null ? 'https://image.tmdb.org/t/p/w500$profilePath' : null,
      knownForDepartment: knownForDepartment,
      alsoKnownAs: alsoKnownAs ?? const <String>[],
      gender: gender,
      homepage: homepage,
      popularity: popularity,
      isAdult: isAdult,
      imdbId: imdbId,
      facebookId: facebookId,
      instagramId: instagramId,
      twitterId: twitterId,
      tiktokId: tiktokId,
      youtubeId: youtubeId,
      wikidataId: wikidataId,
      freebaseId: freebaseId,
      freebaseMid: freebaseMid,
      tvrageId: tvrageId,
      creditsByDepartment: creditsByDepartment,
    );
  }

  static List<String>? _readAliases(dynamic raw) {
    if (raw is! List) return const <String>[];
    return raw
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }
}

class TmdbPersonCastCreditDto {
  const TmdbPersonCastCreditDto({
    required this.media,
    this.character,
    this.creditId,
    this.order,
    this.episodeCount,
  });

  factory TmdbPersonCastCreditDto.fromJson(Map<String, dynamic> json) {
    return TmdbPersonCastCreditDto(
      media: TmdbMovieDto.fromJson(json),
      character: json['character'] as String?,
      creditId: (json['credit_id'] as String?)?.trim(),
      order: (json['order'] as num?)?.toInt(),
      episodeCount: (json['episode_count'] as num?)?.toInt(),
    );
  }

  final TmdbMovieDto media;
  final String? character;
  final String? creditId;
  final int? order;
  final int? episodeCount;
}

class TmdbPersonCrewCreditDto {
  const TmdbPersonCrewCreditDto({
    required this.media,
    this.job,
    this.department,
    this.creditId,
    this.episodeCount,
  });

  factory TmdbPersonCrewCreditDto.fromJson(Map<String, dynamic> json) {
    return TmdbPersonCrewCreditDto(
      media: TmdbMovieDto.fromJson(json),
      job: json['job'] as String?,
      department: json['department'] as String?,
      creditId: (json['credit_id'] as String?)?.trim(),
      episodeCount: (json['episode_count'] as num?)?.toInt(),
    );
  }

  final TmdbMovieDto media;
  final String? job;
  final String? department;
  final String? creditId;
  final int? episodeCount;
}

class TmdbPersonCombinedCreditsDto {
  const TmdbPersonCombinedCreditsDto({required this.cast, required this.crew});

  factory TmdbPersonCombinedCreditsDto.fromJson(Map<String, dynamic> json) {
    return TmdbPersonCombinedCreditsDto(
      cast: (json['cast'] as List<dynamic>?)
              ?.map((e) => TmdbPersonCastCreditDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      crew: (json['crew'] as List<dynamic>?)
              ?.map((e) => TmdbPersonCrewCreditDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  final List<TmdbPersonCastCreditDto> cast;
  final List<TmdbPersonCrewCreditDto> crew;
}
