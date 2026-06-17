import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _currentUrl;
  bool _initialized = false;
  String? _error;

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
    _chewieController?.dispose();
    _videoController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _initPlayer(String url) async {
    if (_currentUrl == url) return;
    _currentUrl = url;

    _chewieController?.dispose();
    _videoController?.dispose();

    setState(() {
      _initialized = false;
      _error = null;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: VeilwatchColors.accent,
          handleColor: VeilwatchColors.accent,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
      );

      if (mounted) setState(() => _initialized = true);

      _videoController!.addListener(() {
        if (_videoController!.value.isPlaying) _saveProgress();
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _saveProgress() {
    if (_videoController == null) return;
    final pos = _videoController!.value.position.inSeconds;
    final dur = _videoController!.value.duration.inSeconds;
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
          // Player area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: episodeAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: VeilwatchColors.accent)),
              error: (e, _) => _ErrorView(message: e.toString()),
              data: (episode) {
                if (episode.streams.isEmpty) {
                  return const _ErrorView(message: 'Tidak ada stream tersedia');
                }

                // Auto init dengan stream pertama
                if (!_initialized && _error == null && _currentUrl == null) {
                  final best = episode.streams.firstWhere(
                    (s) => s.quality == '720p',
                    orElse: () => episode.streams.first,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) => _initPlayer(best.url));
                  return const Center(child: CircularProgressIndicator(color: VeilwatchColors.accent));
                }

                if (_error != null) return _ErrorView(message: _error!);

                if (!_initialized) {
                  return const Center(child: CircularProgressIndicator(color: VeilwatchColors.accent));
                }

                return Chewie(controller: _chewieController!);
              },
            ),
          ),

          // Info panel
          Expanded(
            child: Container(
              color: VeilwatchColors.bg,
              child: SingleChildScrollView(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.animeTitle, style: const TextStyle(color: VeilwatchColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(widget.episodeName, style: const TextStyle(color: VeilwatchColors.textSecondary, fontSize: 13)),
                              ],
                            ),
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
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.white54, size: 40),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
      ]),
    );
  }
}
