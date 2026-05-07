import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/core/config/region_preferences.dart';
import 'package:cineverse/core/network/dio_provider.dart';
import 'package:cineverse/core/storage/storage_providers.dart';
import 'package:cineverse/data/datasources/local/local_data_source.dart';
import 'package:cineverse/data/datasources/remote/omdb_api_client.dart';
import 'package:cineverse/data/datasources/remote/remote_data_source.dart';
import 'package:cineverse/data/datasources/remote/tmdb_api_client.dart';
import 'package:cineverse/data/repositories/media_repository_impl.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tmdbApiClientProvider = Provider<TmdbApiClient>((ref) {
  return TmdbApiClient(
    client: ref.watch(dioProvider),
    appConfig: ref.watch(appConfigProvider),
    preferredRegionCode: ref.watch(preferredRegionCodeProvider),
  );
});

final omdbApiClientProvider = Provider<OmdbApiClient>((ref) {
  return OmdbApiClient(
    client: ref.watch(dioProvider),
    appConfig: ref.watch(appConfigProvider),
  );
});

final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return TmdbRemoteDataSource(ref.watch(tmdbApiClientProvider));
});

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return DriftLocalDataSource(ref.watch(driftConnectionFactoryProvider));
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepositoryImpl(
    remoteDataSource: ref.watch(remoteDataSourceProvider),
    localDataSource: ref.watch(localDataSourceProvider),
    omdbApiClient: ref.watch(omdbApiClientProvider),
  );
});
