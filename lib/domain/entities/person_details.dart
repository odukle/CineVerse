import 'package:cineverse/domain/entities/media_title.dart';

class PersonCredit {
  const PersonCredit({
    required this.media,
    this.role,
    this.department,
  });

  final MediaTitle media;
  final String? role;
  final String? department;
}

class PersonDetails {
  const PersonDetails({
    required this.id,
    required this.name,
    this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.profilePath,
    this.knownForDepartment,
    this.creditsByDepartment = const {},
  });

  final int id;
  final String name;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String? profilePath;
  final String? knownForDepartment;
  final Map<String, List<PersonCredit>> creditsByDepartment;
}
