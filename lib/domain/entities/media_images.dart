class MediaImages {
  const MediaImages({
    required this.posters,
    required this.backdrops,
    required this.logos,
    this.profiles = const [],
    this.taggedImages,
  });

  final List<String> posters;
  final List<String> backdrops;
  final List<String> logos;
  final List<String> profiles;
  final List<String>? taggedImages;

  List<String> get taggedImagesOrEmpty => taggedImages ?? const <String>[];

  static const MediaImages empty = MediaImages(
    posters: [],
    backdrops: [],
    logos: [],
    profiles: [],
    taggedImages: <String>[],
  );
}
