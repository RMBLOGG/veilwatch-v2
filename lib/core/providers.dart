import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/anime_model.dart';
import '../data/services/anime_api_service.dart';
import '../data/services/local_storage_service.dart';

// Services
final apiServiceProvider = Provider<AnimeApiService>((ref) => AnimeApiService());
final storageServiceProvider = Provider<LocalStorageService>((ref) => LocalStorageService());

// Home
final homeProvider = FutureProvider.autoDispose<HomeResponse>((ref) async {
  return ref.read(apiServiceProvider).getHome();
});

// Popular
final popularProvider = FutureProvider.autoDispose<AnimeListResponse>((ref) async {
  return ref.read(apiServiceProvider).getPopular();
});

// Ongoing
final ongoingProvider = FutureProvider.autoDispose<AnimeListResponse>((ref) async {
  return ref.read(apiServiceProvider).getOngoing();
});

// Latest
final latestProvider = FutureProvider.autoDispose<AnimeListResponse>((ref) async {
  return ref.read(apiServiceProvider).getLatest();
});

// Anime Detail
final animeDetailProvider = FutureProvider.autoDispose.family<AnimeDetail, String>((ref, slug) async {
  return ref.read(apiServiceProvider).getAnimeDetail(slug);
});

// Episode Detail (streams)
final episodeDetailProvider = FutureProvider.autoDispose.family<EpisodeDetail, String>((ref, slug) async {
  return ref.read(apiServiceProvider).getEpisodeDetail(slug);
});

// Genres
final genresProvider = FutureProvider.autoDispose<List<GenreItem>>((ref) async {
  return ref.read(apiServiceProvider).getGenres();
});

// Schedule
final scheduleProvider = FutureProvider.autoDispose<ScheduleResponse>((ref) async {
  return ref.read(apiServiceProvider).getSchedule();
});

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<AnimeListResponse>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return AnimeListResponse(animes: [], pagination: const Pagination());
  return ref.read(apiServiceProvider).search(query);
});

// Library
final libraryProvider = StateNotifierProvider<LibraryNotifier, List<AnimeItem>>((ref) {
  return LibraryNotifier(ref.read(storageServiceProvider));
});

class LibraryNotifier extends StateNotifier<List<AnimeItem>> {
  final LocalStorageService _storage;
  LibraryNotifier(this._storage) : super([]) { _load(); }

  void _load() => state = _storage.getLibrary();

  Future<void> toggle(AnimeItem anime) async {
    if (_storage.isInLibrary(anime.slug)) {
      await _storage.removeFromLibrary(anime.slug);
    } else {
      await _storage.addToLibrary(anime);
    }
    _load();
  }

  bool isInLibrary(String slug) => state.any((a) => a.slug == slug);
}

// Watch History
final watchHistoryProvider = StateNotifierProvider<WatchHistoryNotifier, List<WatchHistory>>((ref) {
  return WatchHistoryNotifier(ref.read(storageServiceProvider));
});

class WatchHistoryNotifier extends StateNotifier<List<WatchHistory>> {
  final LocalStorageService _storage;
  WatchHistoryNotifier(this._storage) : super([]) { _load(); }

  void _load() => state = _storage.getWatchHistory();

  Future<void> saveProgress(WatchHistory history) async {
    await _storage.saveWatchProgress(history);
    _load();
  }

  Future<void> clearAll() async {
    await _storage.clearHistory();
    _load();
  }
}

// Bottom Nav
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
