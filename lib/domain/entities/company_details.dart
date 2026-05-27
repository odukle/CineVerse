class CompanyDetails {
  const CompanyDetails({
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
}
