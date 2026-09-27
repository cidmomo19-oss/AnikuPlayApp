import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/models/catalog_entry.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/shimmer_card.dart';
import '../detail/detail_screen.dart';
import '../player/player_screen.dart';
import '../providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combinedAsync = ref.watch(animeListCombinedProvider);
    final historyAsync = ref.watch(watchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'AnikuPlay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(catalogProvider);
          ref.invalidate(aniListBatchProvider);
        },
        color: AppTheme.accentStart,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spotlight / Featured Banner
              combinedAsync.when(
                data: (list) {
                  if (list.isEmpty) return const SizedBox.shrink();
                  final featured = list.first;
                  final bannerUrl = featured.aniListAnime?.bannerImage ??
                      featured.aniListAnime?.coverLarge;
                  final title = featured.aniListAnime?.displayTitle ?? 'Anime Utama';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(catalogEntry: featured.catalogEntry),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(AppTheme.space16),
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        image: bannerUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(bannerUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: AppTheme.surface1,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(AppTheme.space16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.infoCyan,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BARU!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppTheme.space16),
                  child: ShimmerBox(height: 180),
                ),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              // "Lanjutkan Menonton" section
              historyAsync.when(
                data: (historyList) {
                  if (historyList.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                        child: Text(
                          'Lanjutkan Menonton',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space12),
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                          itemCount: historyList.length,
                          itemBuilder: (context, index) {
                            final item = historyList[index];
                            final combinedList = combinedAsync.value ?? [];
                            final match = combinedList.firstWhere(
                              (element) => element.catalogEntry.id == item.animeId,
                              orElse: () => combinedList.isNotEmpty
                                  ? combinedList.first
                                  : AnimeCombinedInfo(
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

                            return GestureDetector(
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
                              child: Container(
                                width: 220,
                                margin: const EdgeInsets.only(right: AppTheme.space12),
                                padding: const EdgeInsets.all(AppTheme.space12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface1,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                                  border: Border.all(
                                    color: AppTheme.accentStart.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Episode ${item.episodeNumber}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 11,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: item.progressRatio,
                                      backgroundColor: AppTheme.surface2,
                                      color: AppTheme.accentStart,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppTheme.space24),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              // Katalog Utama Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                child: Text(
                  'Katalog Anime',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppTheme.space12),

              combinedAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Belum ada anime di katalog.'),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: AppTheme.space12,
                      mainAxisSpacing: AppTheme.space12,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final title = item.aniListAnime?.displayTitle ?? 'Anime #${item.catalogEntry.id}';
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
                loading: () => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: AppTheme.space12,
                    mainAxisSpacing: AppTheme.space12,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => const ShimmerBox(),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Gagal memuat katalog: $err'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
