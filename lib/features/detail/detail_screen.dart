import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/models/catalog_entry.dart';
import '../../widgets/episode_tile.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/gradient_button.dart';
import '../player/player_screen.dart';
import '../providers/app_providers.dart';

class DetailScreen extends ConsumerWidget {
  final CatalogAnimeEntry catalogEntry;

  const DetailScreen({super.key, required this.catalogEntry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchMapAsync = ref.watch(aniListBatchProvider);
    final historyList = ref.watch(watchHistoryProvider).value ?? [];
    final bookmarkSet = ref.watch(bookmarkProvider);
    final downloadsAsync = ref.watch(downloadManagerProvider);
    final downloadedList = downloadsAsync.value ?? [];

    final isBookmarked = bookmarkSet.contains(catalogEntry.id);

    return Scaffold(
      body: batchMapAsync.when(
        data: (aniListMap) {
          final anime = aniListMap[catalogEntry.anilistId];
          final title = anime?.displayTitle ?? 'Anime #${catalogEntry.id}';
          final bannerUrl = anime?.bannerImage ?? anime?.coverLarge;
          final posterUrl = anime?.coverLarge;

          return CustomScrollView(
            slivers: [
              // Header SliverAppBar with Banner
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isBookmarked ? AppTheme.accentStart : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(bookmarkProvider.notifier).toggleBookmark(
                            catalogEntry.id,
                            catalogEntry.toJson().toString(),
                          );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (bannerUrl != null)
                        CachedNetworkImage(
                          imageUrl: bannerUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(color: AppTheme.surface1),
                        )
                      else
                        Container(color: AppTheme.surface1),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.bgBase.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster & Title Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (posterUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                              child: CachedNetworkImage(
                                imageUrl: posterUrl,
                                width: 100,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(width: AppTheme.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.space8),
                                if (anime?.averageScore != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: AppTheme.gold, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(anime!.averageScore! / 10).toStringAsFixed(1)} / 10',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: AppTheme.space4),
                                if (anime?.mainStudio != null)
                                  Text(
                                    'Studio: ${anime!.mainStudio}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                if (anime?.status != null)
                                  Text(
                                    'Status: ${anime!.status}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space16),

                      // "Tonton Sekarang" CTA Button
                      if (catalogEntry.episodes.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            text: 'Tonton Sekarang',
                            icon: Icons.play_arrow_rounded,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerScreen(
                                    animeId: catalogEntry.id,
                                    animeTitle: title,
                                    episode: catalogEntry.episodes.first,
                                    episodes: catalogEntry.episodes,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: AppTheme.space24),

                      // Genre Chips Carousel
                      if (anime?.genres != null && anime!.genres.isNotEmpty) ...[
                        Wrap(
                          spacing: AppTheme.space8,
                          runSpacing: AppTheme.space8,
                          children: anime.genres.map((g) => GenreChip(label: g)).toList(),
                        ),
                        const SizedBox(height: AppTheme.space24),
                      ],

                      // Sinopsis
                      Text('Sinopsis', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppTheme.space8),
                      Text(
                        anime?.description?.replaceAll(RegExp(r'<[^>]*>'), '') ??
                            'Sinopsis belum tersedia.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: AppTheme.space24),

                      // Karakter (Carousel Horizontal)
                      if (anime?.characters != null && anime!.characters.isNotEmpty) ...[
                        Text('Karakter', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppTheme.space12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: anime.characters.length,
                            itemBuilder: (context, index) {
                              final char = anime.characters[index];
                              return Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: AppTheme.space12),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 32,
                                      backgroundImage: char.imageUrl != null
                                          ? CachedNetworkImageProvider(char.imageUrl!)
                                          : null,
                                      backgroundColor: AppTheme.surface2,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      char.name,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppTheme.space24),
                      ],

                      // Staff (Carousel Horizontal)
                      if (anime?.staff != null && anime!.staff.isNotEmpty) ...[
                        Text('Staf Produksi', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppTheme.space12),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: anime.staff.length,
                            itemBuilder: (context, index) {
                              final st = anime.staff[index];
                              return Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: AppTheme.space12),
                                padding: const EdgeInsets.all(AppTheme.space8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface1,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      st.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      st.occupations.join(', '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppTheme.space24),
                      ],

                      // Daftar Episode
                      Text('Daftar Episode', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppTheme.space12),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: catalogEntry.episodes.length,
                        itemBuilder: (context, index) {
                          final ep = catalogEntry.episodes[index];
                          final isWatched = historyList.any(
                            (h) => h.animeId == catalogEntry.id && h.episodeNumber == ep.episodeNumber,
                          );
                          final isDownloaded = downloadedList.any(
                            (d) => d.animeId == catalogEntry.id && d.episodeNumber == ep.episodeNumber,
                          );

                          return EpisodeTile(
                            episodeNumber: ep.episodeNumber,
                            videoType: ep.videoType,
                            sourceChannel: ep.sourceChannel,
                            isWatched: isWatched,
                            isDownloaded: isDownloaded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerScreen(
                                    animeId: catalogEntry.id,
                                    animeTitle: title,
                                    episode: ep,
                                    episodes: catalogEntry.episodes,
                                  ),
                                ),
                              );
                            },
                            onDownloadTap: () {
                              if (ep.videoUrl != null) {
                                ref.read(downloadManagerProvider.notifier).startDownload(
                                      animeId: catalogEntry.id,
                                      animeTitle: title,
                                      episodeNumber: ep.episodeNumber,
                                      videoUrl: ep.videoUrl!,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Mulai mengunduh episode ${ep.episodeNumber}...'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentStart),
        ),
        error: (err, stack) => Center(child: Text('Gagal memuat detail: $err')),
      ),
    );
  }
}
