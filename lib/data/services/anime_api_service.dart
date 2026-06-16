import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/anime_model.dart';

class AnimeApiService {
  static final AnimeApiService _instance = AnimeApiService._internal();
  factory AnimeApiService() => _instance;

  late final Dio _dio;

  AnimeApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    _dio.interceptors.add(LogInterceptor(error: true, responseBody: false));
  }

  // Home: ongoing + recent
  Future<HomeResponse> getHome({int page = 1}) async {
    try {
      final res = await _dio.get('/animasu/home', queryParameters: {'page': page});
      return HomeResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Popular
  Future<AnimeListResponse> getPopular({int page = 1}) async {
    try {
      final res = await _dio.get('/animasu/popular', queryParameters: {'page': page});
      return AnimeListResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Ongoing
  Future<AnimeListResponse> getOngoing({int page = 1}) async {
    try {
      final res = await _dio.get('/animasu/ongoing', queryParameters: {'page': page});
      return AnimeListResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Completed
  Future<AnimeListResponse> getCompleted({int page = 1}) async {
    try {
      final res = await _dio.get('/animasu/completed', queryParameters: {'page': page});
      return AnimeListResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Latest
  Future<AnimeListResponse> getLatest({int page = 1}) async {
    try {
      final res = await _dio.get('/animasu/latest', queryParameters: {'page': page});
      return AnimeListResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Movies
  Future<AnimeListResponse> getMovies({int page = 1}) async {
    try {
      final res = await _dio.get('/animasu/movies', queryParameters: {'page': page});
      return AnimeListResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Search by keyword
  Future<AnimeListResponse> search(String keyword, {int page = 1}) async {
    try {
      final encoded = Uri.encodeComponent(keyword);
      final res = await _dio.get('/animasu/search/$encoded', queryParameters: {'page': page});
      return AnimeListResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Detail anime
  Future<AnimeDetail> getAnimeDetail(String slug) async {
    try {
      final res = await _dio.get('/animasu/anime/$slug');
      return AnimeDetail.fromJson(res.data['anime'] ?? res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Detail episode (stream sources)
  Future<EpisodeDetail> getEpisodeDetail(String slug) async {
    try {
      final res = await _dio.get('/animasu/episode/$slug');
      return EpisodeDetail.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Genres list
  Future<List<GenreItem>> getGenres() async {
    try {
      final res = await _dio.get('/animasu/genres');
      final List data = res.data['genres'] ?? [];
      return data.map((e) => GenreItem.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Anime by genre
  Future<AnimeListResponse> getByGenre(String slug, {int page = 1}) async {
    try {
      final res = await _dio.get('/animasu/genre/$slug', queryParameters: {'page': page});
      return AnimeListResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Schedule
  Future<ScheduleResponse> getSchedule() async {
    try {
      final res = await _dio.get('/animasu/schedule');
      return ScheduleResponse.fromJson(res.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Koneksi timeout. Cek internet kamu.');
        case DioExceptionType.connectionError:
          return Exception('Tidak ada koneksi internet.');
        default:
          final msg = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
          return Exception(msg);
      }
    }
    return Exception(e.toString());
  }
}
