import 'package:cineverse/core/storage/drift_connection_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final driftConnectionFactoryProvider = Provider<DriftConnectionFactory>((ref) {
  return const DriftConnectionFactory();
});
