class AwardDetailEntry {
  const AwardDetailEntry({
    required this.text,
    this.logoUrl,
    this.awardName,
  });

  final String text;
  final String? logoUrl;
  final String? awardName;
}

class MovieAwards {
  const MovieAwards({
    required this.rawAwards,
    required this.oscarWins,
    required this.oscarNominations,
    required this.globeWins,
    required this.globeNominations,
    required this.baftaWins,
    required this.baftaNominations,
    required this.otherWins,
    required this.otherNominations,
    this.detailEntries = const <AwardDetailEntry>[],
  });

  factory MovieAwards.parse(String? raw) {
    final String clean = (raw ?? '').trim();
    if (clean.isEmpty || clean.toLowerCase() == 'n/a') {
      return const MovieAwards(
        rawAwards: '',
        oscarWins: 0,
        oscarNominations: 0,
        globeWins: 0,
        globeNominations: 0,
        baftaWins: 0,
        baftaNominations: 0,
        otherWins: 0,
        otherNominations: 0,
        detailEntries: const <AwardDetailEntry>[],
      );
    }

    int oscarWins = 0;
    int oscarNominations = 0;
    int globeWins = 0;
    int globeNominations = 0;
    int baftaWins = 0;
    int baftaNominations = 0;
    int otherWins = 0;
    int otherNominations = 0;

    // Split by periods to analyze sentence by sentence
    final List<String> sentences = clean.split('.');
    for (final String sentence in sentences) {
      final String trimmed = sentence.trim();
      if (trimmed.isEmpty) continue;

      final String lower = trimmed.toLowerCase();
      final bool isNominated = lower.contains('nominated') || lower.contains('nomination');

      if (lower.contains('oscar')) {
        final int count = _extractNumber(trimmed);
        if (isNominated) {
          oscarNominations += count;
        } else {
          // Default to win if 'won' is found or no nomination keyword
          oscarWins += count;
        }
      } else if (lower.contains('golden globe')) {
        final int count = _extractNumber(trimmed);
        if (isNominated) {
          globeNominations += count;
        } else {
          globeWins += count;
        }
      } else if (lower.contains('bafta')) {
        final int count = _extractNumber(trimmed);
        if (isNominated) {
          baftaNominations += count;
        } else {
          baftaWins += count;
        }
      } else {
        // General wins/nominations sentence, e.g. "Another 50 wins & 28 nominations" or "1 win & 2 nominations"
        final int winCount = _extractWins(trimmed);
        final int nomCount = _extractNominations(trimmed);
        otherWins += winCount;
        otherNominations += nomCount;
      }
    }

    return MovieAwards(
      rawAwards: clean,
      oscarWins: oscarWins,
      oscarNominations: oscarNominations,
      globeWins: globeWins,
      globeNominations: globeNominations,
      baftaWins: baftaWins,
      baftaNominations: baftaNominations,
      otherWins: otherWins,
      otherNominations: otherNominations,
      detailEntries: const <AwardDetailEntry>[],
    );
  }

  factory MovieAwards.fromResolverPayload(Map<String, dynamic>? payload) {
    final String awardsText = (payload?['awardsText'] as String? ?? '').trim();
    final MovieAwards parsed = MovieAwards.parse(awardsText);

    final List<AwardDetailEntry> detailEntries = <AwardDetailEntry>[];
    final dynamic rawItems = payload?['detailItems'];
    if (rawItems is List) {
      for (final dynamic item in rawItems) {
        if (item is! Map) continue;
        final String text = (item['text'] as String? ?? '').trim();
        if (text.isEmpty) continue;
        final String? logoUrl = (item['logoUrl'] as String?)?.trim();
        final String? awardName = (item['awardName'] as String?)?.trim();
        detailEntries.add(
          AwardDetailEntry(
            text: text,
            logoUrl: (logoUrl == null || logoUrl.isEmpty) ? null : logoUrl,
            awardName: (awardName == null || awardName.isEmpty)
                ? null
                : awardName,
          ),
        );
      }
    }

    return MovieAwards(
      rawAwards: parsed.rawAwards,
      oscarWins: parsed.oscarWins,
      oscarNominations: parsed.oscarNominations,
      globeWins: parsed.globeWins,
      globeNominations: parsed.globeNominations,
      baftaWins: parsed.baftaWins,
      baftaNominations: parsed.baftaNominations,
      otherWins: parsed.otherWins,
      otherNominations: parsed.otherNominations,
      detailEntries: detailEntries,
    );
  }

  final String rawAwards;
  final int oscarWins;
  final int oscarNominations;
  final int globeWins;
  final int globeNominations;
  final int baftaWins;
  final int baftaNominations;
  final int otherWins;
  final int otherNominations;
  final List<AwardDetailEntry> detailEntries;

  int get totalWins => oscarWins + globeWins + baftaWins + otherWins;
  int get totalNominations => oscarNominations + globeNominations + baftaNominations + otherNominations;

  bool get hasAwards => totalWins > 0 || totalNominations > 0;

  String get displaySummary {
    if (!hasAwards) return 'No awards info available';

    final List<String> parts = <String>[];
    if (totalWins > 0) {
      parts.add(totalWins == 1 ? '1 win' : '$totalWins wins');
    }
    if (totalNominations > 0) {
      parts.add(totalNominations == 1 ? '1 nomination' : '$totalNominations nominations');
    }
    return parts.join(' & ');
  }

  List<String> get detailLines {
    if (detailEntries.isNotEmpty) {
      return detailEntries.map((entry) => entry.text).toList(growable: false);
    }
    if (rawAwards.isEmpty || rawAwards.toLowerCase() == 'n/a') {
      return const <String>[];
    }
    return rawAwards
        .split('.')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty && s.toLowerCase() != 'n/a')
        .toList();
  }

  static int _extractNumber(String text) {
    final RegExp regExp = RegExp(r'(\d+)');
    final Match? match = regExp.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    return 0;
  }

  static int _extractWins(String text) {
    // Looks for number followed by "win" or "wins"
    final RegExp regExp = RegExp(r'(\d+)\s+win');
    final Match? match = regExp.firstMatch(text.toLowerCase());
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    return 0;
  }

  static int _extractNominations(String text) {
    // Looks for number followed by "nomination" or "nominations"
    final RegExp regExp = RegExp(r'(\d+)\s+nom');
    final Match? match = regExp.firstMatch(text.toLowerCase());
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    return 0;
  }
}
