enum MovieMood {
  mindBending(
    'Mind-Bending',
    'Mind-bending psychological thrillers and sci-fi',
    ['surreal', 'mind-blowing', 'time loop', 'simulation'],
    [10854, 9887, 362567, 12565],
    [27205, 157336, 77, 11324, 1124, 141, 577922, 38, 220289, 435],
    [135728, 67198, 95396, 63247],
  ),
  feelGood(
    'Feel-good',
    'Happy, uplifting, and family-friendly',
    ['feel-good', 'heartwarming', 'cheerful', 'joy'],
    [329716, 319357],
    [77338, 369557, 773, 346648, 122906, 212778, 194, 120467, 153158, 70160],
    [97546, 66573, 61662, 117376],
  ),
  dark(
    'Dark',
    'Gritty, intense, and atmospheric',
    ['dark fiction', 'gritty', 'noir', 'atmospheric'],
    [348204, 12565, 2351],
    [807, 274, 475557, 496243, 641, 146233, 503919, 1381, 1426, 670],
    [67744, 46648, 43929, 82922],
  ),
  fastPaced(
    'Fast-paced',
    'Action-packed and adrenaline-filled',
    ['fast-paced', 'action packed', 'high speed'],
    [9730],
    [76341, 245891, 94329, 353081, 339403, 2501, 168259, 218, 1637, 345940],
    [76479, 108978, 1911, 240], // Replaced Fargo with 24 (ID: 240)
  ),
  edgeOfYourSeat(
    'Edge-of-your-seat',
    'Suspenseful and thrilling',
    ['edge-of-your-seat', 'intense', 'thriller'],
    [10349, 12565],
    [273481, 313922, 333339, 300669, 447332, 49047, 37724, 419430, 17473, 1091], // Get Out, 10 Cloverfield Lane, The Thing
    [66732, 115036, 71446, 4057],
  ),
  cinematic(
    'Cinematic',
    'Visual masterpieces and epic scales',
    ['cinematography', 'visuals', 'masterpiece', 'epic'],
    [9663],
    [335984, 426426, 530915, 947, 62, 281957, 438631, 129, 425, 27205], // Dune, Spirited Away, Birdman
    [1399, 65494, 94605, 124364],
  ),
  indie(
    'Indie',
    'Independent films with unique perspectives',
    ['independent film', 'art-house', 'low budget'],
    [281237, 11130, 171993],
    [376867, 391713, 244786, 350312, 310307, 588228, 152603, 391067, 601666, 913290],
    [136315, 154385, 67070, 65495, 95215], // Updated Reservation Dogs ID
  );

  const MovieMood(
    this.label,
    this.description,
    this.keywords,
    this.keywordIds,
    this.movieSeeds,
    this.tvSeeds,
  );

  final String label;
  final String description;
  final List<String> keywords;
  final List<int> keywordIds;
  final List<int> movieSeeds;
  final List<int> tvSeeds;
}

