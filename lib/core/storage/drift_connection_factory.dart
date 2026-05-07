import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

class DriftConnectionFactory {
  const DriftConnectionFactory();

  QueryExecutor create() {
    return driftDatabase(name: 'cineverse.sqlite');
  }
}
