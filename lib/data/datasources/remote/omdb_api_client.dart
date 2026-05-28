import 'dart:io';

import 'package:cineverse/core/config/app_config.dart';
import 'package:cineverse/data/models/omdb_movie_ratings_dto.dart';
import 'package:cineverse/data/models/omdb_title_details_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OmdbApiException implements Exception {
  const OmdbApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OmdbApiClient {
  const OmdbApiClient({required this.client, required this.appConfig});

  final Dio client;
  final AppConfig appConfig;

  Future<OmdbMovieRatingsDto?> fetchMovieRatings(String imdbId) async {
    if (!appConfig.hasOmdbResolverApiUrl || imdbId.trim().isEmpty) {
      return null;
    }

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(
            appConfig.omdbResolverApiUrl.trim(),
            queryParameters: <String, dynamic>{
              'imdbId': imdbId,
              'mode': 'ratings',
            },
          );

      final Map<String, dynamic>? payload = response.data;
      if (payload == null) {
        throw const OmdbApiException('OMDb returned an empty payload.');
      }

      final Map<String, dynamic> omdbPayload =
          (payload['data'] as Map<String, dynamic>?) ?? payload;
      final String responseValue = (omdbPayload['Response'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (responseValue == 'false') {
        throw OmdbApiException(
          (omdbPayload['Error'] as String?)?.trim() ??
              'OMDb did not return ratings for this title.',
        );
      }

      return OmdbMovieRatingsDto.fromJson(omdbPayload);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchMovieRatings', error, stackTrace);
      throw OmdbApiException(_messageForDioException(error));
    }
  }

  Future<OmdbTitleDetailsDto?> fetchTitleDetails(
    String imdbId, {
    bool fullPlot = true,
  }) async {
    if (!appConfig.hasOmdbResolverApiUrl || imdbId.trim().isEmpty) {
      return null;
    }

    try {
      final Response<Map<String, dynamic>> response = await client
          .get<Map<String, dynamic>>(
            appConfig.omdbResolverApiUrl.trim(),
            queryParameters: <String, dynamic>{
              'imdbId': imdbId,
              'mode': 'details',
              'plot': fullPlot ? 'full' : 'short',
            },
          );

      final Map<String, dynamic>? payload = response.data;
      if (payload == null) {
        throw const OmdbApiException('OMDb returned an empty payload.');
      }

      final Map<String, dynamic> omdbPayload =
          (payload['data'] as Map<String, dynamic>?) ?? payload;
      final String responseValue = (omdbPayload['Response'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (responseValue == 'false') {
        throw OmdbApiException(
          (omdbPayload['Error'] as String?)?.trim() ??
              'OMDb did not return details for this title.',
        );
      }

      return OmdbTitleDetailsDto.fromJson(omdbPayload);
    } on DioException catch (error, stackTrace) {
      _logFailure('fetchTitleDetails', error, stackTrace);
      throw OmdbApiException(_messageForDioException(error));
    }
  }

  String _messageForDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'OMDb request timed out. Check your connection and try again.';
    }

    if (error.type == DioExceptionType.badResponse) {
      return 'OMDb returned an unexpected response (${error.response?.statusCode ?? 'unknown'}).';
    }

    if (error.type == DioExceptionType.connectionError) {
      final Object? rootError = error.error;
      if (rootError is SocketException) {
        return 'Could not connect to OMDb. Check internet or DNS access.';
      }
    }

    return 'Unexpected OMDb resolver error: ${error.message ?? 'unknown error'}';
  }

  void _logFailure(
    String operation,
    DioException error,
    StackTrace stackTrace,
  ) {
    debugPrint('[OMDb][$operation] ${error.type}: ${error.message}');
    if (error.response != null) {
      debugPrint(
        '[OMDb][$operation] status=${error.response?.statusCode} data=${error.response?.data}',
      );
    }
    if (error.error != null) {
      debugPrint('[OMDb][$operation] root=${error.error}');
    }
    debugPrintStack(stackTrace: stackTrace);
  }
}
