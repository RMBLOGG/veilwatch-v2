import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/anime_model.dart';
import '../../widgets/common/anime_card.dart';
import '../../widgets/common/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    final popularAsync = ref.watch(popularProvider);
    final history = ref.watch(watchHistoryProvider);

    return Scaffold(
      backgroundColor: VeilwatchColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: VeilwatchColors.bg,
            title: RichText(
              text: const TextSpan(children: [
                TextSpan(text: 'Veil', style: TextStyle(fontFamily: 'Urbanist', fontSize: 24, fontWeight: FontWeight.w800, color: VeilwatchColors.textPrimary)),
                TextSpan(text: 'watch', style: TextStyle(fontFamily: 'Urbanist', fontSize: 24, fontWeight: FontWeight.w800, color: VeilwatchColors.accent)),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero carousel - ongoing dari home
                homeAsync.when(
                  loading: () => _HeroShimmer(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (home) => _HeroCarousel(items: home.ongoing.take(5).toList()),
                ),
                const SizedBox(height: 24),

                // Continue watching
                if (history.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(title: 'Lanjut Nonton'),
                  ),
                  const SizedBox(height: 12),
                  _ContinueWatching(history: history),
                  const SizedBox(height: 24),
                ],

                // Ongoing terbaru
                homeAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (home) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SectionHeader(title: 'Update Terbaru'),
                      ),
                      const SizedBox(height: 12),
                      _HorizontalList(items: home.recent),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Popular
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(title: 'Populer'),
                ),
                const SizedBox(height: 12),
                popularAsync.when(
                  loading: () => _ListShimmer(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (res) => _HorizontalList(items: res.animes),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  final List<AnimeItem> items;
  const _HeroCarousel({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return CarouselSlider.builder(
      itemCount: items.length,
      itemBuilder: (context, index, _) => _HeroItem(anime: items[index]),
      options: CarouselOptions(
        height: 220,
        viewportFraction: 0.88,
        enlargeCenterPage: true,
        enlargeFactor: 0.12,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
      ),
    );
  }
}

class _HeroItem extends StatelessWidget {
  final AnimeItem anime;
  const _HeroItem({required this.anime});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/anime/${anime.slug}'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: VeilwatchColors.accent.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: anime.poster, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16, left: 16, right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    if (anime.episode != null) ...[
                      const SizedBox(height: 4),
                      Text(anime.episode!, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final List<AnimeItem> items;
  const _HorizontalList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => AnimeCard(
          anime: items[index],
          onTap: () => context.push('/anime/${items[index].slug}'),
          width: 120,
        ),
      ),
    );
  }
}

class _ContinueWatching extends StatelessWidget {
  final List<WatchHistory> history;
  const _ContinueWatching({required this.history});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: history.take(10).length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final h = history[index];
          return GestureDetector(
            onTap: () => context.push(
              '/watch/${h.episodeSlug}?animeSlug=${h.animeSlug}&epName=${Uri.encodeComponent(h.episodeName)}&title=${Uri.encodeComponent(h.animeTitle)}&poster=${Uri.encodeComponent(h.animePoster)}',
            ),
            child: Container(
              width: 160,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: VeilwatchColors.surfaceElevated),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: h.animePoster, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6, left: 8, right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.episodeName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(value: h.progress, backgroundColor: Colors.white24, color: VeilwatchColors.accent, minHeight: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: VeilwatchColors.surfaceElevated,
      highlightColor: VeilwatchColors.border,
      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: VeilwatchColors.surfaceElevated, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _ListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: VeilwatchColors.surfaceElevated,
          highlightColor: VeilwatchColors.border,
          child: Container(width: 120, decoration: BoxDecoration(color: VeilwatchColors.surfaceElevated, borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }
}
