import 'package:cineverse/domain/entities/search_keyword.dart';

class TmdbSearchKeywordDto {
  const TmdbSearchKeywordDto({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory TmdbSearchKeywordDto.fromJson(Map<String, dynamic> json) {
    return TmdbSearchKeywordDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  SearchKeyword toDomain() {
    return SearchKeyword(
      id: id,
      name: name,
    );
  }
}
