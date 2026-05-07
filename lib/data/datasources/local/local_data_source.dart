import 'package:cineverse/core/storage/drift_connection_factory.dart';

abstract interface class LocalDataSource {}

class DriftLocalDataSource implements LocalDataSource {
  const DriftLocalDataSource(this.connectionFactory);

  final DriftConnectionFactory connectionFactory;
}
