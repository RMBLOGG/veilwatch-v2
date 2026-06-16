import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/detail/anime_detail_screen.dart';
import '../presentation/screens/player/player_screen.dart';
import '../presentation/screens/library/library_screen.dart';
import '../presentation/widgets/common/main_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/', pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen())),
        GoRoute(path: '/search', pageBuilder: (_, __) => const NoTransitionPage(child: SearchScreen())),
        GoRoute(path: '/library', pageBuilder: (_, __) => const NoTransitionPage(child: LibraryScreen())),
      ],
    ),
    GoRoute(
      path: '/anime/:slug',
      builder: (context, state) => AnimeDetailScreen(slug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/watch/:episodeSlug',
      builder: (context, state) => PlayerScreen(
        episodeSlug: state.pathParameters['episodeSlug']!,
        animeSlug: state.uri.queryParameters['animeSlug'] ?? '',
        episodeName: state.uri.queryParameters['epName'] ?? '',
        animeTitle: state.uri.queryParameters['title'] ?? '',
        animePoster: state.uri.queryParameters['poster'] ?? '',
      ),
    ),
  ],
);
