import 'package:cineverse/domain/entities/media_title.dart';

class PersonCredit {
  const PersonCredit({
    required this.media,
    this.role,
    this.department,
    this.creditId,
    this.episodeCount,
    this.billingOrder,
    this.isCastCredit = false,
  });

  final MediaTitle media;
  final String? role;
  final String? department;
  final String? creditId;
  final int? episodeCount;
  final int? billingOrder;
  final bool isCastCredit;
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
  final Map<String, List<PersonCredit>> creditsByDepartment;

  bool get hasSocialHandles =>
      (facebookId?.isNotEmpty ?? false) ||
      (instagramId?.isNotEmpty ?? false) ||
      (twitterId?.isNotEmpty ?? false) ||
      (tiktokId?.isNotEmpty ?? false) ||
      (youtubeId?.isNotEmpty ?? false) ||
      (homepage?.isNotEmpty ?? false) ||
      (wikidataId?.isNotEmpty ?? false) ||
      (imdbId?.isNotEmpty ?? false);
}
