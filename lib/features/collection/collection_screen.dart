import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../widgets/anime_card.dart';
import '../detail/detail_screen.dart';
import '../providers/app_providers.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkIds = ref.watch(bookmarkProvider);
    final combinedAsync = ref.watch(animeListCombinedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi Saya'),
      ),
      body: bookmarkIds.isEmpty
          ? const Center(
              child: Text(
                'Belum ada anime yang disimpan.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : combinedAsync.when(
              data: (list) {
                final bookmarkedList = list
                    .where((item) => bookmarkIds.contains(item.catalogEntry.id))
                    .toList();

                if (bookmarkedList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada anime yang disimpan.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: AppTheme.space12,
                    mainAxisSpacing: AppTheme.space12,
                  ),
                  itemCount: bookmarkedList.length,
                  itemBuilder: (context, index) {
                    final item = bookmarkedList[index];
                    final title =
                        item.aniListAnime?.displayTitle ?? 'Anime #${item.catalogEntry.id}';
                    final imgUrl = item.aniListAnime?.coverLarge;
                    final rating = item.aniListAnime?.averageScore;
                    final studio = item.aniListAnime?.mainStudio;

                    return AnimeCard(
                      title: title,
                      imageUrl: imgUrl,
                      rating: rating,
                      subtitle: studio,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(catalogEntry: item.catalogEntry),
                          ),
                        );
                      },
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
