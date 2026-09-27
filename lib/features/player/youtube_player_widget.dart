import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../app/theme.dart';
import '../../data/models/catalog_entry.dart';

class YouTubePlayerWidget extends StatefulWidget {
  final CatalogEpisode episode;
  final List<CatalogEpisode> episodes;
  final Function(CatalogEpisode) onEpisodeChanged;

  const YouTubePlayerWidget({
    super.key,
    required this.episode,
    required this.episodes,
    required this.onEpisodeChanged,
  });

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final videoId = widget.episode.youtubeId ?? 'L_LUpnjgPso';
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant YouTubePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.episode.youtubeId != widget.episode.youtubeId) {
      if (widget.episode.youtubeId != null) {
        _controller.loadVideoById(videoId: widget.episode.youtubeId!);
      }
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        widget.episodes.indexWhere((e) => e.episodeNumber == widget.episode.episodeNumber);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex != -1 && currentIndex < widget.episodes.length - 1;

    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Column(
          children: [
            player,
            Container(
              color: AppTheme.surface1,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: hasPrev
                        ? () => widget.onEpisodeChanged(widget.episodes[currentIndex - 1])
                        : null,
                    icon: const Icon(Icons.skip_previous_rounded),
                    label: const Text('Episode Seb.'),
                  ),
                  TextButton.icon(
                    onPressed: hasNext
                        ? () => widget.onEpisodeChanged(widget.episodes[currentIndex + 1])
                        : null,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Episode Sel.'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
