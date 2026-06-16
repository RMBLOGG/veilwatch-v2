import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/anime_model.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String episodeSlug;
  final String animeSlug;
  final String episodeName;
  final String animeTitle;
  final String animePoster;

  const PlayerScreen({
    super.key,
    required this.episodeSlug,
    required this.animeSlug,
    required this.episodeName,
    required this.animeTitle,
    required this.animePoster,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  BetterPlayerController? _controller;
  bool _initialized = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _initPlayer(String url) {
    if (_currentUrl == url) return;
    _currentUrl = url;
    _controller?.dispose();

    final isM3u8 = url.contains('.m3u8');
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      videoFormat: isM3u8 ? BetterPlayerVideoFormat.hls : null,
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black54,
          iconsColor: Colors.white,
          progressBarPlayedColor: VeilwatchColors.accent,
          progressBarHandleColor: VeilwatchColors.accent,
          progressBarBackgroundColor: Colors.white24,
          loadingColor: VeilwatchColors.accent,
          enableSkips: true,
          forwardSkipTimeInMilliseconds: 10000,
          backwardSkipTimeInMilliseconds: 10000,
        ),
        eventListener: (event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
            _saveProgress();
          }
        },
      ),
      betterPlayerDataSource: dataSource,
    );
    setState(() => _initialized = true);
  }

  void _saveProgress() {
    if (_controller == null) return;
    final pos = _controller!.videoPlayerController?.value.position.inSeconds ?? 0;
    final dur = _controller!.videoPlayerController?.value.duration?.inSeconds ?? 0;
    if (dur == 0) return;

    ref.read(watchHistoryProvider.notifier).saveProgress(WatchHistory(
      animeSlug: widget.animeSlug,
      animeTitle: widget.animeTitle,
      animePoster: widget.animePoster,
      episodeSlug: widget.episodeSlug,
      episodeName: widget.episodeName,
      positionSeconds: pos,
      durationSeconds: dur,
      watchedAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final episodeAsync = ref.watch(episodeDetailProvider(widget.episodeSlug));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: episodeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: VeilwatchColors.accent)),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, color: Colors.white54, size: 40),
                  const SizedBox(height: 8),
                  Text(e.toString(), style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                ]),
              ),
              data: (episode) {
                if (episode.streams.isEmpty) {
                  return const Center(child: Text('Tidak ada stream tersedia', style: TextStyle(color: Colors.white54)));
                }
                if (!_initialized) {
                  // Auto-pick best quality
                  final best = episode.streams.firstWhere(
                    (s) => s.quality == '720p',
                    orElse: () => episode.streams.first,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) => _initPlayer(best.url));
                  return const Center(child: CircularProgressIndicator(color: VeilwatchColors.accent));
                }
                return BetterPlayer(controller: _controller!);
              },
            ),
          ),

          // Info panel
          Expanded(
            child: Container(
              color: VeilwatchColors.bg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: VeilwatchColors.textPrimary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(widget.animeTitle, style: const TextStyle(color: VeilwatchColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(widget.episodeName, style: const TextStyle(color: VeilwatchColors.textSecondary, fontSize: 13)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  // Quality selector
                  episodeAsync.whenData((episode) {
                    if (episode.streams.length <= 1) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kualitas', style: TextStyle(color: VeilwatchColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: episode.streams.map((s) => GestureDetector(
                              onTap: () => _initPlayer(s.url),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: _currentUrl == s.url ? VeilwatchColors.accent : VeilwatchColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(s.name, style: TextStyle(
                                  color: _currentUrl == s.url ? Colors.white : VeilwatchColors.textPrimary,
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                )),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    );
                  }).value ?? const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
