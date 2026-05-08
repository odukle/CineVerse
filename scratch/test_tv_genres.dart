// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.themoviedb.org/3'));
  const apiKey = 'YOUR_API_KEY'; // I need to get this or use a mock

  try {
    final response = await dio.get(
      '/genre/tv/list',
      queryParameters: {'api_key': apiKey, 'language': 'en-US'},
    );
    print('TV Genres: ${response.data}');
  } catch (e) {
    print('Error: $e');
  }
}
