import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/models/catalog_entry.dart';
import '../player/player_screen.dart';
import '../providers/app_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchHistoryProvider);
    final combinedAsync = ref.watch(animeListCombinedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Nonton'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Hapus Semua',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Semua Riwayat?'),
                  content: const Text(
                    'Apakah Anda yakin ingin menghapus seluruh riwayat menonton?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(watchHistoryProvider.notifier).clearAll();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: historyAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat menonton.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          final combinedList = combinedAsync.value ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.space16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
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

              final title = match.aniListAnime?.displayTitle ?? 'Anime #${item.animeId}';
              final episode = match.catalogEntry.episodes.firstWhere(
                (e) => e.episodeNumber == item.episodeNumber,
                orElse: () => CatalogEpisode(
                  episodeNumber: item.episodeNumber,
                  videoType: 'youtube',
                  sourceChannel: 'Resmi',
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
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Episode ${item.episodeNumber} • ${episode.sourceChannel}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: item.progressRatio,
                        backgroundColor: AppTheme.surface2,
                        color: AppTheme.accentStart,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                    onPressed: () {
                      ref.read(watchHistoryProvider.notifier).deleteHistory(item.animeId);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          animeId: item.animeId,
                          animeTitle: title,
                          episode: episode,
                          episodes: match.catalogEntry.episodes,
                        ),
                      ),
                    );
                  },
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
