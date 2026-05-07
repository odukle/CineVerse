import 'package:cineverse/domain/entities/movie_details.dart';
import 'package:cineverse/domain/repositories/media_repository.dart';
import 'package:cineverse/domain/usecases/use_case.dart';

class GetMovieDetailsParams {
  const GetMovieDetailsParams({required this.movieId, this.isTv = false});

  final int movieId;
  final bool isTv;

  @override
  bool operator ==(Object other) {
    return other is GetMovieDetailsParams &&
        other.movieId == movieId &&
        other.isTv == isTv;
  }

  @override
  int get hashCode => Object.hash(movieId, isTv);
}

class GetMovieDetailsUseCase
    implements UseCase<MovieDetails, GetMovieDetailsParams> {
  const GetMovieDetailsUseCase(this.repository);

  final MediaRepository repository;

  @override
  Future<MovieDetails> call(GetMovieDetailsParams params) async {
    return repository.fetchMovieDetails(params.movieId, isTv: params.isTv);
  }
}
