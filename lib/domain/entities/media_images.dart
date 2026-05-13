class MediaImages {
  const MediaImages({
    required this.posters,
    required this.backdrops,
    required this.logos,
    this.profiles = const [],
  });

  final List<String> posters;
  final List<String> backdrops;
  final List<String> logos;
  final List<String> profiles;

  static const MediaImages empty = MediaImages(
    posters: [],
    backdrops: [],
    logos: [],
    profiles: [],
  );
}
