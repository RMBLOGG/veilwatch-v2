import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';

class AnimeDetailScreen extends ConsumerWidget {
  final String slug;
  const AnimeDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeAsync = ref.watch(animeDetailProvider(slug));
    final inLibrary = ref.watch(libraryProvider.select((lib) => lib.any((a) => a.slug == slug)));

    return Scaffold(
      backgroundColor: VeilwatchColors.bg,
      body: animeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: VeilwatchColors.accent)),
        error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: VeilwatchColors.textSecondary))),
        data: (anime) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: VeilwatchColors.bg,
              leading: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => ref.read(libraryProvider.notifier).toggle(anime.toAnimeItem()),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                    child: Icon(
                      inLibrary ? Iconsax.bookmark_25 : Iconsax.bookmark,
                      color: inLibrary ? VeilwatchColors.accent : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: anime.banner ?? anime.poster, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, VeilwatchColors.bg],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(anime.title, style: const TextStyle(color: VeilwatchColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),

                    const SizedBox(height: 12),

                    // Meta
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        if (anime.type != null) _MetaBadge(label: anime.type!),
                        if (anime.status != null) _MetaBadge(label: anime.status!),
                        if (anime.release != null) _MetaBadge(label: anime.release!),
                        if (anime.episodeCount != null) _MetaBadge(label: anime.episodeCount!),
                        if (anime.rating != null)
                          _MetaBadge(label: '★ ${anime.rating!.toStringAsFixed(2)}', icon: Icons.star_rounded, color: VeilwatchColors.warning),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Genres
                    if (anime.genres.isNotEmpty)
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: anime.genres.map((g) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(border: Border.all(color: VeilwatchColors.border), borderRadius: BorderRadius.circular(20)),
                          child: Text(g, style: const TextStyle(color: VeilwatchColors.textSecondary, fontSize: 12)),
                        )).toList(),
                      ),

                    const SizedBox(height: 16),

                    // Synopsis
                    if (anime.synopsis != null) ...[
                      const Text('Sinopsis', style: TextStyle(color: VeilwatchColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _ExpandableSynopsis(text: anime.synopsis!),
                      const SizedBox(height: 20),
                    ],

                    // Batches
                    if (anime.batches.isNotEmpty) ...[
                      const Text('Batch', style: TextStyle(color: VeilwatchColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ...anime.batches.map((b) => GestureDetector(
                        onTap: () => context.push(
                          '/watch/${b.slug}?animeSlug=$slug&epName=${Uri.encodeComponent(b.name)}&title=${Uri.encodeComponent(anime.title)}&poster=${Uri.encodeComponent(anime.poster)}',
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: VeilwatchColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [
                            const Icon(Iconsax.folder_open, color: VeilwatchColors.accent, size: 18),
                            const SizedBox(width: 10),
                            Text(b.name, style: const TextStyle(color: VeilwatchColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      )),
                      const SizedBox(height: 12),
                    ],

                    // Episodes header
                    if (anime.episodes.isNotEmpty)
                      Row(
                        children: [
                          const Text('Episode', style: TextStyle(color: VeilwatchColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Text('(${anime.episodes.length})', style: const TextStyle(color: VeilwatchColors.textMuted, fontSize: 14)),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Episodes grid
            if (anime.episodes.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ep = anime.episodes[index];
                      return GestureDetector(
                        onTap: () => context.push(
                          '/watch/${ep.slug}?animeSlug=$slug&epName=${Uri.encodeComponent(ep.name)}&title=${Uri.encodeComponent(anime.title)}&poster=${Uri.encodeComponent(anime.poster)}',
                        ),
                        child: Container(
                          decoration: BoxDecoration(color: VeilwatchColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: Text(
                            ep.number.toString(),
                            style: const TextStyle(color: VeilwatchColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                    childCount: anime.episodes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  const _MetaBadge({required this.label, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: VeilwatchColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, color: color ?? VeilwatchColors.textSecondary, size: 13), const SizedBox(width: 4)],
        Text(label, style: TextStyle(color: color ?? VeilwatchColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _ExpandableSynopsis extends StatefulWidget {
  final String text;
  const _ExpandableSynopsis({required this.text});

  @override
  State<_ExpandableSynopsis> createState() => _ExpandableSynopsisState();
}

class _ExpandableSynopsisState extends State<_ExpandableSynopsis> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.text, maxLines: _expanded ? null : 3, overflow: _expanded ? null : TextOverflow.ellipsis,
          style: const TextStyle(color: VeilwatchColors.textSecondary, fontSize: 13, height: 1.6)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(_expanded ? 'Tutup' : 'Selengkapnya', style: const TextStyle(color: VeilwatchColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
