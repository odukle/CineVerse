import 'package:cineverse/data/providers/data_providers.dart';
import 'package:cineverse/domain/entities/person_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final personDetailsProvider = FutureProvider.family<PersonDetails, int>((ref, personId) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return repository.fetchPersonDetails(personId);
});
