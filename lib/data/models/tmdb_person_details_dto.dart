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
  });

  factory TmdbPersonDetailsDto.fromJson(Map<String, dynamic> json) {
    return TmdbPersonDetailsDto(
      id: json['id'] as int,
      name: json['name'] as String,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
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
      creditsByDepartment: creditsByDepartment,
    );
  }
}

class TmdbPersonCastCreditDto {
  const TmdbPersonCastCreditDto({required this.media, this.character});

  factory TmdbPersonCastCreditDto.fromJson(Map<String, dynamic> json) {
    return TmdbPersonCastCreditDto(
      media: TmdbMovieDto.fromJson(json),
      character: json['character'] as String?,
    );
  }

  final TmdbMovieDto media;
  final String? character;
}

class TmdbPersonCrewCreditDto {
  const TmdbPersonCrewCreditDto({
    required this.media,
    this.job,
    this.department,
  });

  factory TmdbPersonCrewCreditDto.fromJson(Map<String, dynamic> json) {
    return TmdbPersonCrewCreditDto(
      media: TmdbMovieDto.fromJson(json),
      job: json['job'] as String?,
      department: json['department'] as String?,
    );
  }

  final TmdbMovieDto media;
  final String? job;
  final String? department;
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
