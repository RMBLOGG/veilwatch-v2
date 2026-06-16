import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/anime_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Library (saved anime) ---

  List<AnimeItem> getLibrary() {
    final raw = _prefs.getStringList(AppConstants.libraryKey) ?? [];
    return raw.map((e) => AnimeItem.fromJson(jsonDecode(e))).toList();
  }

  Future<void> addToLibrary(AnimeItem anime) async {
    final library = getLibrary();
    if (!library.any((a) => a.slug == anime.slug)) {
      library.add(anime);
      await _save(AppConstants.libraryKey, library.map((e) => jsonEncode(e.toJson())).toList());
    }
  }

  Future<void> removeFromLibrary(String slug) async {
    final library = getLibrary();
    library.removeWhere((a) => a.slug == slug);
    await _save(AppConstants.libraryKey, library.map((e) => jsonEncode(e.toJson())).toList());
  }

  bool isInLibrary(String slug) => getLibrary().any((a) => a.slug == slug);

  // --- Watch History ---

  List<WatchHistory> getWatchHistory() {
    final raw = _prefs.getStringList(AppConstants.watchHistoryKey) ?? [];
    return raw
        .map((e) => WatchHistory.fromJson(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
  }

  Future<void> saveWatchProgress(WatchHistory history) async {
    final list = getWatchHistory();
    list.removeWhere((h) => h.animeSlug == history.animeSlug && h.episodeSlug == history.episodeSlug);
    list.insert(0, history);
    if (list.length > 100) list.removeLast();
    await _save(AppConstants.watchHistoryKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  WatchHistory? getEpisodeProgress(String animeSlug, String episodeSlug) {
    return getWatchHistory()
        .where((h) => h.animeSlug == animeSlug && h.episodeSlug == episodeSlug)
        .firstOrNull;
  }

  Future<void> clearHistory() async => await _prefs.remove(AppConstants.watchHistoryKey);

  Future<void> _save(String key, List<String> data) async {
    await _prefs.setStringList(key, data);
  }
}
