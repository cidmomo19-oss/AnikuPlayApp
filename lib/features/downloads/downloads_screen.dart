import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/models/catalog_entry.dart';
import '../player/player_screen.dart';
import '../providers/app_providers.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadManagerProvider);
    final combinedAsync = ref.watch(animeListCombinedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Unduhan'),
      ),
      body: downloadsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Belum ada episode yang diunduh.\nHanya episode mode "DIRECT" yang dapat diunduh untuk ditonton offline.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            );
          }

          final combinedList = combinedAsync.value ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.space16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final file = File(item.filePath);
              String fileSizeStr = 'Unknown size';
              if (file.existsSync()) {
                final bytes = file.lengthSync();
                final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
                fileSizeStr = '$mb MB';
              }

              final match = combinedList.firstWhere(
                (element) => element.catalogEntry.id == item.animeId,
                orElse: () => AnimeCombinedInfo(
                  catalogEntry: CatalogAnimeEntry(
                    id: item.animeId,
                    anilistId: 0,
                    episodes: [],
                  ),
                ),
              );

              final episode = match.catalogEntry.episodes.firstWhere(
                (e) => e.episodeNumber == item.episodeNumber,
                orElse: () => CatalogEpisode(
                  episodeNumber: item.episodeNumber,
                  videoType: 'direct',
                  videoUrl: null,
                  sourceChannel: 'Unduhan Lokal',
                ),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.space12),
                decoration: BoxDecoration(
                  color: AppTheme.surface1,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppTheme.space12),
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.surface2,
                    child: Icon(Icons.offline_pin_rounded, color: AppTheme.infoCyan),
                  ),
                  title: Text(
                    item.animeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Episode ${item.episodeNumber} • $fileSizeStr',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.accentStart),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlayerScreen(
                                animeId: item.animeId,
                                animeTitle: item.animeTitle,
                                episode: episode,
                                episodes: match.catalogEntry.episodes.isNotEmpty
                                    ? match.catalogEntry.episodes
                                    : [episode],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Unduhan?'),
                              content: Text(
                                'Hapus unduhan ${item.animeTitle} Ep ${item.episodeNumber} dari penyimpanan?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(downloadManagerProvider.notifier)
                                        .deleteDownload(item);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentStart),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
