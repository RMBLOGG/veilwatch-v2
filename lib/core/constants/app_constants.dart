class AppConstants {
  // Base URL
  static const baseUrl = 'https://www.sankavollerei.com/anime';

  // Endpoints
  static const home = '/animasu/home';
  static const popular = '/animasu/popular';
  static const ongoing = '/animasu/ongoing';
  static const completed = '/animasu/completed';
  static const latest = '/animasu/latest';
  static const movies = '/animasu/movies';
  static const animelist = '/animasu/animelist';
  static const schedule = '/animasu/schedule';
  static const genres = '/animasu/genres';
  static const characters = '/animasu/characters';

  // Dynamic endpoints (replace :slug)
  static const searchByKeyword = '/animasu/search/:keyword';
  static const animeDetail = '/animasu/anime/:slug';
  static const episodeDetail = '/animasu/episode/:slug';
  static const genreAnime = '/animasu/genre/:slug';
  static const characterAnime = '/animasu/character/:slug';
  static const advancedSearch = '/animasu/advanced-search';

  // Storage Keys
  static const watchHistoryKey = 'watch_history';
  static const libraryKey = 'library';

  // UI
  static const cardAspectRatio = 2 / 3;
  static const bannerAspectRatio = 16 / 9;
}
