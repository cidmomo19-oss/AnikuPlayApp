import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/shimmer_card.dart';
import '../detail/detail_screen.dart';
import '../providers/app_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final combinedAsync = ref.watch(animeListCombinedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Anime'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.space16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _query = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan judul atau genre...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surface1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space16,
                  vertical: AppTheme.space12,
                ),
              ),
            ),
          ),
          Expanded(
            child: combinedAsync.when(
              data: (list) {
                final filtered = list.where((item) {
                  if (_query.isEmpty) return true;
                  final title = item.aniListAnime?.displayTitle.toLowerCase() ?? '';
                  final romaji = item.aniListAnime?.titleRomaji.toLowerCase() ?? '';
                  final genres = item.aniListAnime?.genres.map((g) => g.toLowerCase()).toList() ?? [];
                  return title.contains(_query) ||
                      romaji.contains(_query) ||
                      genres.any((g) => g.contains(_query));
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'Anime tidak ditemukan.',
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
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
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
                padding: const EdgeInsets.all(AppTheme.space16),
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
                child: Text('Error: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
