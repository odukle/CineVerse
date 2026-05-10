import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/core/config/region_preferences.dart';
import 'package:cineverse/core/network/dio_provider.dart';
import 'package:cineverse/core/storage/storage_providers.dart';
import 'package:cineverse/data/datasources/local/local_data_source.dart';
import 'package:cineverse/data/datasources/remote/omdb_api_client.dart';
import 'package:cineverse/data/datasources/remote/remote_data_source.dart';
import 'package:cineverse/data/datasources/remote/tmdb_api_client.dart';
import 'package:cineverse/data/datasources/local/app_database.dart';
import 'package:cineverse/data/repositories/media_repository_impl.dart';
import 'package:cineverse/data/repositories/watchlist_repository_impl.dart';
import 'package:cineverse/data/repositories/watched_repository_impl.dart';
import 'package:cineverse/data/repositories/library_repository_impl.dart';
import 'package:cineverse/data/repositories/notes_repository_impl.dart';
import 'package:cineverse/data/repositories/search_history_repository_impl.dart';
import 'package:cineverse/domain/repositories/library_repository.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/domain/repositories/watchlist_repository.dart';
import 'package:cineverse/domain/repositories/watched_repository.dart';
import 'package:cineverse/domain/repositories/notes_repository.dart';
import 'package:cineverse/domain/repositories/search_history_repository.dart';
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

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final factory = ref.watch(driftConnectionFactoryProvider);
  return AppDatabase(factory.create());
});

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepositoryImpl(ref.watch(appDatabaseProvider));
});

final watchedRepositoryProvider = Provider<WatchedRepository>((ref) {
  return WatchedRepositoryImpl(ref.watch(appDatabaseProvider));
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl(ref.watch(appDatabaseProvider));
});

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((ref) {
  return SearchHistoryRepositoryImpl(ref.watch(appDatabaseProvider));
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepositoryImpl(ref.watch(appDatabaseProvider));
});
