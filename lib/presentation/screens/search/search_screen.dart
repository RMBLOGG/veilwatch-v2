import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/anime_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: VeilwatchColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search', style: TextStyle(color: VeilwatchColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: VeilwatchColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari judul anime...',
                      prefixIcon: const Icon(Iconsax.search_normal, color: VeilwatchColors.textMuted, size: 20),
                      suffixIcon: query.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _controller.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                              },
                              child: const Icon(Icons.close_rounded, color: VeilwatchColors.textMuted, size: 20),
                            )
                          : null,
                    ),
                    onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val.trim(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: query.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Iconsax.search_normal, color: VeilwatchColors.textMuted.withOpacity(0.4), size: 56),
                        const SizedBox(height: 12),
                        const Text('Ketik judul anime', style: TextStyle(color: VeilwatchColors.textMuted)),
                      ]),
                    )
                  : results.when(
                      loading: () => GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, mainAxisSpacing: 16, crossAxisSpacing: 10),
                        itemCount: 9,
                        itemBuilder: (_, __) => Shimmer.fromColors(
                          baseColor: VeilwatchColors.surfaceElevated,
                          highlightColor: VeilwatchColors.border,
                          child: Container(decoration: BoxDecoration(color: VeilwatchColors.surfaceElevated, borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      error: (e, _) => Center(child: Text(e.toString(), style: const TextStyle(color: VeilwatchColors.textSecondary))),
                      data: (res) => res.animes.isEmpty
                          ? Center(
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Iconsax.search_status, color: VeilwatchColors.textMuted, size: 48),
                                const SizedBox(height: 12),
                                Text('Tidak ada hasil untuk "$query"', style: const TextStyle(color: VeilwatchColors.textSecondary)),
                              ]),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, mainAxisSpacing: 16, crossAxisSpacing: 10),
                              itemCount: res.animes.length,
                              itemBuilder: (context, index) => AnimeCard(
                                anime: res.animes[index],
                                onTap: () => context.push('/anime/${res.animes[index].slug}'),
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
