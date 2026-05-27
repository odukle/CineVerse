import 'package:cineverse/domain/entities/company_details.dart';

class TmdbCompanyDetailsDto {
  const TmdbCompanyDetailsDto({
    required this.id,
    required this.name,
    this.description,
    this.headquarters,
    this.homepage,
    this.logoPath,
    this.originCountry,
    this.parentCompany,
  });

  final int id;
  final String name;
  final String? description;
  final String? headquarters;
  final String? homepage;
  final String? logoPath;
  final String? originCountry;
  final String? parentCompany;

  factory TmdbCompanyDetailsDto.fromJson(Map<String, dynamic> json) {
    String? parentName;
    final parent = json['parent_company'];
    if (parent is Map<String, dynamic>) {
      parentName = parent['name'] as String?;
    } else if (parent is String) {
      parentName = parent;
    }

    return TmdbCompanyDetailsDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      headquarters: json['headquarters'] as String?,
      homepage: json['homepage'] as String?,
      logoPath: _normalizeImagePath(json['logo_path'] as String?, size: 'w300'),
      originCountry: json['origin_country'] as String?,
      parentCompany: parentName,
    );
  }

  CompanyDetails toDomain() {
    return CompanyDetails(
      id: id,
      name: name,
      description: description,
      headquarters: headquarters,
      homepage: homepage,
      logoPath: logoPath,
      originCountry: originCountry,
      parentCompany: parentCompany,
    );
  }

  static String? _normalizeImagePath(String? path, {required String size}) {
    if (path == null || path.trim().isEmpty) return null;
    return 'https://image.tmdb.org/t/p/$size${path.trim()}';
  }
}
