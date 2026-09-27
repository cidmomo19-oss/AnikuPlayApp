import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/models/catalog_entry.dart';
import '../providers/app_providers.dart';
import 'direct_player_widget.dart';
import 'youtube_player_widget.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final int animeId;
  final String animeTitle;
  final CatalogEpisode episode;
  final List<CatalogEpisode> episodes;

  const PlayerScreen({
    super.key,
    required this.animeId,
    required this.animeTitle,
    required this.episode,
    required this.episodes,
  });

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late CatalogEpisode _currentEpisode;

  @override
  void initState() {
    super.initState();
    _currentEpisode = widget.episode;
  }

  @override
  Widget build(BuildContext context) {
    final downloadsAsync = ref.watch(downloadManagerProvider);
    final downloadedList = downloadsAsync.value ?? [];
    final downloadedItem = downloadedList.cast<dynamic>().firstWhere(
      (d) => d.animeId == widget.animeId && d.episodeNumber == _currentEpisode.episodeNumber,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animeTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Engine Selector based on video_type
            if (_currentEpisode.videoType == 'youtube')
              YouTubePlayerWidget(
                episode: _currentEpisode,
                episodes: widget.episodes,
                onEpisodeChanged: (ep) => setState(() => _currentEpisode = ep),
              )
            else
              DirectPlayerWidget(
                animeId: widget.animeId,
                animeTitle: widget.animeTitle,
                episode: _currentEpisode,
                episodes: widget.episodes,
                localFilePath: downloadedItem?.filePath,
                onEpisodeChanged: (ep) => setState(() => _currentEpisode = ep),
              ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Episode ${_currentEpisode.episodeNumber}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 14, color: AppTheme.accentStart),
                      const SizedBox(width: AppTheme.space4),
                      Text(
                        _currentEpisode.sourceChannel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _currentEpisode.videoType == 'youtube'
                              ? Colors.red.withValues(alpha: 0.2)
                              : AppTheme.infoCyan.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _currentEpisode.videoType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _currentEpisode.videoType == 'youtube'
                                ? Colors.redAccent
                                : AppTheme.infoCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppTheme.space32, color: AppTheme.surface2),

                  // Daftar Episode Selection
                  Text(
                    'Daftar Episode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.space12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.episodes.length,
                    itemBuilder: (context, index) {
                      final ep = widget.episodes[index];
                      final isSelected = ep.episodeNumber == _currentEpisode.episodeNumber;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.space8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.surface2 : AppTheme.surface1,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          border: isSelected
                              ? Border.all(color: AppTheme.accentStart, width: 1.5)
                              : null,
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _currentEpisode = ep;
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? AppTheme.accentStart : AppTheme.surface2,
                            child: Text(
                              '${ep.episodeNumber}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            'Episode ${ep.episodeNumber}',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            ep.sourceChannel,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          trailing: ep.videoType == 'direct'
                              ? const Icon(Icons.download_rounded, color: AppTheme.textSecondary)
                              : const Icon(Icons.play_circle_fill_rounded,
                                  color: AppTheme.accentStart),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
