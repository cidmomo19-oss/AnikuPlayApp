import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../app/theme.dart';
import '../../data/models/catalog_entry.dart';
import '../../data/models/watch_history.dart';
import '../providers/app_providers.dart';

class DirectPlayerWidget extends ConsumerStatefulWidget {
  final int animeId;
  final String animeTitle;
  final CatalogEpisode episode;
  final List<CatalogEpisode> episodes;
  final String? localFilePath;
  final Function(CatalogEpisode) onEpisodeChanged;

  const DirectPlayerWidget({
    super.key,
    required this.animeId,
    required this.animeTitle,
    required this.episode,
    required this.episodes,
    this.localFilePath,
    required this.onEpisodeChanged,
  });

  @override
  ConsumerState<DirectPlayerWidget> createState() => _DirectPlayerWidgetState();
}

class _DirectPlayerWidgetState extends ConsumerState<DirectPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isLocked = false;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  Timer? _hideControlsTimer;
  int _lastSavedSecond = -1;

  // Pulse animation states for double tap skip
  bool _showLeftPulse = false;
  bool _showRightPulse = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  @override
  void didUpdateWidget(covariant DirectPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.episode.episodeNumber != widget.episode.episodeNumber ||
        oldWidget.localFilePath != widget.localFilePath) {
      _controller?.dispose();
      _isInitialized = false;
      _initVideoPlayer();
    }
  }

  Future<void> _initVideoPlayer() async {
    WakelockPlus.enable();

    if (widget.localFilePath != null) {
      _controller = VideoPlayerController.file(
        File(widget.localFilePath!),
      );
    } else if (widget.episode.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.episode.videoUrl!),
      );
    }

    if (_controller == null) return;

    try {
      await _controller!.initialize();
      _controller!.setPlaybackSpeed(_playbackSpeed);
      _controller!.play();

      // Check watch history to restore position
      final historyList = ref.read(watchHistoryProvider).value;
      if (historyList != null) {
        final history = historyList.cast<WatchHistory?>().firstWhere(
          (h) => h?.animeId == widget.animeId && h?.episodeNumber == widget.episode.episodeNumber,
          orElse: () => null,
        );
        if (history != null) {
          _controller!.seekTo(Duration(milliseconds: history.positionMs));
        }
      }

      _controller!.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startHideControlsTimer();
      }
    } catch (_) {}
  }

  void _videoListener() {
    if (_controller != null && _controller!.value.isInitialized) {
      final pos = _controller!.value.position.inMilliseconds;
      final dur = _controller!.value.duration.inMilliseconds;
      final currentSecond = pos ~/ 3000;

      if (dur > 0 && currentSecond != _lastSavedSecond) {
        _lastSavedSecond = currentSecond;
        ref.read(watchHistoryProvider.notifier).saveProgress(
              animeId: widget.animeId,
              episodeNumber: widget.episode.episodeNumber,
              positionMs: pos,
              durationMs: dur,
            );
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_isLocked) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _doubleTapSeek(bool isForward) {
    if (_controller == null || !_controller!.value.isInitialized || _isLocked) return;

    final current = _controller!.value.position;
    final delta = Duration(seconds: isForward ? 10 : -10);
    _controller!.seekTo(current + delta);

    setState(() {
      if (isForward) {
        _showRightPulse = true;
      } else {
        _showLeftPulse = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showLeftPulse = false;
          _showRightPulse = false;
        });
      }
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _showSpeedSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface2,
      builder: (context) {
        final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppTheme.space16),
              child: Text(
                'Kecepatan Putar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...speeds.map((s) => ListTile(
                  title: Text('${s}x'),
                  trailing: _playbackSpeed == s
                      ? const Icon(Icons.check_rounded, color: AppTheme.accentStart)
                      : null,
                  onTap: () {
                    setState(() {
                      _playbackSpeed = s;
                    });
                    _controller?.setPlaybackSpeed(s);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: AppTheme.space16),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.accentStart),
        ),
      );
    }

    final currentIndex =
        widget.episodes.indexWhere((e) => e.episodeNumber == widget.episode.episodeNumber);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex != -1 && currentIndex < widget.episodes.length - 1;

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio > 0 ? _controller!.value.aspectRatio : 16 / 9,
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),

            // Double tap overlay zones
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onDoubleTap: () => _doubleTapSeek(false),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onDoubleTap: () => _doubleTapSeek(true),
                    ),
                  ),
                ],
              ),
            ),

            // Left Skip Pulse Animation
            if (_showLeftPulse)
              Positioned(
                left: 40,
                child: AnimatedOpacity(
                  opacity: _showLeftPulse ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay_10_rounded, color: Colors.white, size: 36),
                        Text('-10s', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),

            // Right Skip Pulse Animation
            if (_showRightPulse)
              Positioned(
                right: 40,
                child: AnimatedOpacity(
                  opacity: _showRightPulse ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.forward_10_rounded, color: Colors.white, size: 36),
                        Text('+10s', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),

            // Controls Overlay
            if (_showControls)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isLocked = !_isLocked;
                            });
                          },
                        ),
                        if (!_isLocked)
                          Row(
                            children: [
                              TextButton(
                                onPressed: _showSpeedSheet,
                                child: Text(
                                  '${_playbackSpeed}x',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _isFullscreen
                                      ? Icons.fullscreen_exit_rounded
                                      : Icons.fullscreen_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleFullscreen,
                              ),
                            ],
                          ),
                      ],
                    ),

                    // Center Media Controls (if unlocked)
                    if (!_isLocked)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 32,
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: hasPrev ? Colors.white : Colors.white38,
                            ),
                            onPressed: hasPrev
                                ? () => widget.onEpisodeChanged(
                                      widget.episodes[currentIndex - 1],
                                    )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            iconSize: 48,
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              color: AppTheme.accentStart,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_controller!.value.isPlaying) {
                                  _controller!.pause();
                                } else {
                                  _controller!.play();
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            iconSize: 32,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: hasNext ? Colors.white : Colors.white38,
                            ),
                            onPressed: hasNext
                                ? () => widget.onEpisodeChanged(
                                      widget.episodes[currentIndex + 1],
                                    )
                                : null,
                          ),
                        ],
                      ),

                    // Bottom Bar / Seek Bar
                    if (!_isLocked)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _controller!,
                            builder: (context, VideoPlayerValue value, child) {
                              final pos = value.position;
                              final dur = value.duration;

                              return Column(
                                children: [
                                  VideoProgressIndicator(
                                    _controller!,
                                    allowScrubbing: true,
                                    colors: const VideoProgressColors(
                                      playedColor: AppTheme.accentStart,
                                      bufferedColor: AppTheme.surface2,
                                      backgroundColor: Colors.white24,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(pos),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(dur),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return hours > 0
        ? '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
