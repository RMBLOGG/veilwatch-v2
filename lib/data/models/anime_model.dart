// Model utama berdasarkan response API Animasu
class AnimeItem {
  final String title;
  final String slug;
  final String poster;
  final String? episode;       // e.g. "Episode 21", "12 Episode", "Movie"
  final String? statusOrDay;   // e.g. "🔥🔥🔥", "Selesai ✓", hari rilis
  final String? type;          // "TV", "Movie", "ONA", "Special"

  const AnimeItem({
    required this.title,
    required this.slug,
    required this.poster,
    this.episode,
    this.statusOrDay,
    this.type,
  });

  bool get isOngoing => statusOrDay?.contains('🔥') ?? false;
  bool get isCompleted => statusOrDay?.contains('Selesai') ?? false;

  factory AnimeItem.fromJson(Map<String, dynamic> json) {
    return AnimeItem(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      poster: json['poster'] ?? '',
      episode: json['episode'],
      statusOrDay: json['status_or_day'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'slug': slug,
        'poster': poster,
        'episode': episode,
        'status_or_day': statusOrDay,
        'type': type,
      };
}

// Response dari /animasu/home
class HomeResponse {
  final List<AnimeItem> ongoing;
  final List<AnimeItem> recent;
  final Pagination pagination;

  const HomeResponse({
    required this.ongoing,
    required this.recent,
    required this.pagination,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      ongoing: (json['ongoing'] as List? ?? [])
          .map((e) => AnimeItem.fromJson(e))
          .toList(),
      recent: (json['recent'] as List? ?? [])
          .map((e) => AnimeItem.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// Response dari list endpoints (popular, ongoing, completed, dll)
class AnimeListResponse {
  final List<AnimeItem> animes;
  final Pagination pagination;

  const AnimeListResponse({
    required this.animes,
    required this.pagination,
  });

  factory AnimeListResponse.fromJson(Map<String, dynamic> json) {
    return AnimeListResponse(
      animes: (json['animes'] as List? ?? [])
          .map((e) => AnimeItem.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// Pagination
class Pagination {
  final bool hasNext;
  final bool hasPrev;
  final int currentPage;

  const Pagination({
    this.hasNext = false,
    this.hasPrev = false,
    this.currentPage = 1,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}

// Detail anime dari /animasu/anime/:slug
class AnimeDetail {
  final String title;
  final String slug;
  final String poster;
  final String? banner;
  final String? synopsis;
  final String? status;
  final String? type;
  final String? release;
  final String? episodeCount;
  final double? rating;
  final List<String> genres;
  final List<EpisodeItem> episodes;
  final List<EpisodeItem> batches;
  final List<Map<String, String>> characters;

  const AnimeDetail({
    required this.title,
    required this.slug,
    required this.poster,
    this.banner,
    this.synopsis,
    this.status,
    this.type,
    this.release,
    this.episodeCount,
    this.rating,
    this.genres = const [],
    this.episodes = const [],
    this.batches = const [],
    this.characters = const [],
  });

  factory AnimeDetail.fromJson(Map<String, dynamic> json) {
    // Parse rating dari string seperti "★ 8.11"
    double? rating;
    final ratingRaw = json['rating']?.toString() ?? json['type']?.toString() ?? '';
    if (ratingRaw.contains('★')) {
      final ratingStr = ratingRaw.replaceAll('★', '').replaceAll('N/A', '').trim();
      rating = double.tryParse(ratingStr);
    }

    return AnimeDetail(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      poster: json['poster'] ?? json['thumbnail'] ?? '',
      banner: json['banner'] ?? json['cover'],
      synopsis: json['synopsis'] ?? json['description'] ?? json['sinopsis'],
      status: json['status'],
      type: json['type'],
      release: json['release'] ?? json['aired'],
      episodeCount: json['episode_count'] ?? json['total_episodes']?.toString(),
      rating: rating ?? (json['rating'] as num?)?.toDouble(),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => g is Map ? g['name'].toString() : g.toString())
              .toList() ??
          [],
      episodes: (json['episodes'] as List? ?? [])
          .map((e) => EpisodeItem.fromJson(e))
          .toList(),
      batches: (json['batches'] as List? ?? [])
          .map((e) => EpisodeItem.fromJson(e))
          .toList(),
      characters: (json['characters'] as List? ?? [])
          .map((e) => {'name': e['name']?.toString() ?? '', 'slug': e['slug']?.toString() ?? ''})
          .toList(),
    );
  }

  // Convert ke AnimeItem untuk library
  AnimeItem toAnimeItem() => AnimeItem(
        title: title,
        slug: slug,
        poster: poster,
        type: type,
        statusOrDay: status,
      );
}

// Episode dalam detail anime
class EpisodeItem {
  final String name;   // e.g. "Episode 1", "Episode 1148"
  final String slug;   // e.g. "nonton-one-piece-episode-1148-sub-indo"

  const EpisodeItem({required this.name, required this.slug});

  int get number {
    final match = RegExp(r'\d+').firstMatch(name);
    return int.tryParse(match?.group(0) ?? '0') ?? 0;
  }

  factory EpisodeItem.fromJson(Map<String, dynamic> json) {
    return EpisodeItem(
      name: json['name'] ?? json['title'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

// Stream source dari /animasu/episode/:slug
class EpisodeDetail {
  final String title;
  final List<StreamSource> streams;
  final List<StreamSource> downloads;

  const EpisodeDetail({
    required this.title,
    required this.streams,
    this.downloads = const [],
  });

  factory EpisodeDetail.fromJson(Map<String, dynamic> json) {
    return EpisodeDetail(
      title: json['title'] ?? '',
      streams: (json['streams'] as List? ?? [])
          .map((e) => StreamSource.fromJson(e))
          .toList(),
      downloads: (json['downloads'] as List? ?? [])
          .map((e) => StreamSource.fromJson(e))
          .toList(),
    );
  }
}

class StreamSource {
  final String name;   // e.g. "480p [1]", "720p [2]"
  final String url;    // direct embed URL

  const StreamSource({required this.name, required this.url});

  String get quality {
    if (name.contains('1080')) return '1080p';
    if (name.contains('720')) return '720p';
    if (name.contains('480')) return '480p';
    if (name.contains('360')) return '360p';
    return name;
  }

  factory StreamSource.fromJson(Map<String, dynamic> json) {
    return StreamSource(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

// Genre item
class GenreItem {
  final String name;
  final String slug;

  const GenreItem({required this.name, required this.slug});

  factory GenreItem.fromJson(Map<String, dynamic> json) =>
      GenreItem(name: json['name'] ?? '', slug: json['slug'] ?? '');
}

// Schedule response
class ScheduleResponse {
  final List<AnimeItem> minggu;
  final List<AnimeItem> senin;
  final List<AnimeItem> selasa;
  final List<AnimeItem> rabu;
  final List<AnimeItem> kamis;
  final List<AnimeItem> jumat;
  final List<AnimeItem> sabtu;

  const ScheduleResponse({
    this.minggu = const [],
    this.senin = const [],
    this.selasa = const [],
    this.rabu = const [],
    this.kamis = const [],
    this.jumat = const [],
    this.sabtu = const [],
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    final s = json['schedule'] ?? json;
    List<AnimeItem> parseDay(String key) =>
        (s[key] as List? ?? []).map((e) => AnimeItem.fromJson(e)).toList();

    return ScheduleResponse(
      minggu: parseDay('minggu'),
      senin: parseDay('senin'),
      selasa: parseDay('selasa'),
      rabu: parseDay('rabu'),
      kamis: parseDay('kamis'),
      jumat: parseDay('jumat'),
      sabtu: parseDay('sabtu'),
    );
  }
}

// Watch history (local)
class WatchHistory {
  final String animeSlug;
  final String animeTitle;
  final String animePoster;
  final String episodeSlug;
  final String episodeName;
  final int positionSeconds;
  final int durationSeconds;
  final DateTime watchedAt;

  const WatchHistory({
    required this.animeSlug,
    required this.animeTitle,
    required this.animePoster,
    required this.episodeSlug,
    required this.episodeName,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.watchedAt,
  });

  double get progress =>
      durationSeconds > 0 ? positionSeconds / durationSeconds : 0.0;

  Map<String, dynamic> toJson() => {
        'anime_slug': animeSlug,
        'anime_title': animeTitle,
        'anime_poster': animePoster,
        'episode_slug': episodeSlug,
        'episode_name': episodeName,
        'position_seconds': positionSeconds,
        'duration_seconds': durationSeconds,
        'watched_at': watchedAt.toIso8601String(),
      };

  factory WatchHistory.fromJson(Map<String, dynamic> json) => WatchHistory(
        animeSlug: json['anime_slug'],
        animeTitle: json['anime_title'],
        animePoster: json['anime_poster'],
        episodeSlug: json['episode_slug'],
        episodeName: json['episode_name'],
        positionSeconds: json['position_seconds'],
        durationSeconds: json['duration_seconds'],
        watchedAt: DateTime.parse(json['watched_at']),
      );
}
