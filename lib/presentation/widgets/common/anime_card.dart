import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/anime_model.dart';

class AnimeCard extends StatelessWidget {
  final AnimeItem anime;
  final VoidCallback onTap;
  final double? width;

  const AnimeCard({super.key, required this.anime, required this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width ?? 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: anime.poster,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _Shimmer(),
                      errorWidget: (_, __, ___) => Container(
                        color: VeilwatchColors.surfaceElevated,
                        child: const Icon(Icons.broken_image_outlined, color: VeilwatchColors.textMuted),
                      ),
                    ),
                    // Status badge (ongoing = fire, completed = check)
                    if (anime.isOngoing)
                      Positioned(
                        top: 6, right: 6,
                        child: _Badge(label: 'ON', color: VeilwatchColors.accent),
                      ),
                    if (anime.isCompleted)
                      Positioned(
                        top: 6, right: 6,
                        child: _Badge(label: 'END', color: VeilwatchColors.textMuted),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: VeilwatchColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            if (anime.episode != null) ...[
              const SizedBox(height: 2),
              Text(
                anime.episode!,
                style: const TextStyle(color: VeilwatchColors.textMuted, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}

class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: VeilwatchColors.surfaceElevated,
      highlightColor: VeilwatchColors.border,
      child: Container(color: VeilwatchColors.surfaceElevated),
    );
  }
}
