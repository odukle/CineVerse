class SearchCompany {
  const SearchCompany({
    required this.id,
    required this.name,
    this.logoPath,
  });

  final int id;
  final String name;
  final String? logoPath;
}
