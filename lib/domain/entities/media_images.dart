class MediaImages {
  const MediaImages({
    required this.posters,
    required this.backdrops,
    required this.logos,
  });

  final List<String> posters;
  final List<String> backdrops;
  final List<String> logos;

  static const MediaImages empty = MediaImages(
    posters: [],
    backdrops: [],
    logos: [],
  );
}
