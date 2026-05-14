enum MovieMood {
  mindBending('Mind-bending', 'Mind-bending psychological thrillers and sci-fi', [310, 2321, 9862, 14544, 1564, 2095], []),
  feelGood('Feel-good', 'Happy, uplifting, and family-friendly', [], [35, 10751]),
  dark('Dark', 'Gritty, intense, and atmospheric', [10349, 9826, 14611], [27]),
  fastPaced('Fast-paced', 'Action-packed and adrenaline-filled', [9715, 9717], [28]),
  heartwarming('Heartwarming', 'Touching stories that pull at your heartstrings', [180342, 171400], [10749, 18]),
  edgeOfYourSeat('Edge-of-your-seat', 'Suspenseful and thrilling', [10349, 33633], [53, 9648]),
  cinematic('Cinematic', 'Visual masterpieces and epic scales', [1476, 267323], []),
  indie('Indie', 'Independent films with unique perspectives', [10183], []);

  const MovieMood(this.label, this.description, this.keywordIds, this.genreIds);

  final String label;
  final String description;
  final List<int> keywordIds;
  final List<int> genreIds;
}
