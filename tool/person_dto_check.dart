import 'package:cineverse/data/models/tmdb_person_details_dto.dart';
import 'package:flutter/foundation.dart';

void main() {
  final payloads = [
    {'id': 1, 'name': 'A', 'also_known_as': null, 'external_ids': {}},
    {'id': 1, 'name': 'A', 'external_ids': {}},
    {
      'id': 1,
      'name': 'A',
      'also_known_as': ['x', null, 2],
      'external_ids': {},
    },
  ];
  for (final p in payloads) {
    final dto = TmdbPersonDetailsDto.fromJson(Map<String, dynamic>.from(p));
    debugPrint('${dto.alsoKnownAs}');
  }
}
