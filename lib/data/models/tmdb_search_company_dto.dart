import 'package:cineverse/domain/entities/search_company.dart';

class TmdbSearchCompanyDto {
  const TmdbSearchCompanyDto({
    required this.id,
    required this.name,
    this.logoPath,
  });

  final int id;
  final String name;
  final String? logoPath;

  factory TmdbSearchCompanyDto.fromJson(Map<String, dynamic> json) {
    return TmdbSearchCompanyDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      logoPath: _normalizeImagePath(json['logo_path'] as String?, size: 'w185'),
    );
  }

  SearchCompany toDomain() {
    return SearchCompany(
      id: id,
      name: name,
      logoPath: logoPath,
    );
  }

  static String? _normalizeImagePath(String? path, {required String size}) {
    if (path == null || path.trim().isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size${path.trim()}';
  }
}
