import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/anilist_service.dart';
import '../../data/catalog_service.dart';
import '../../data/download_service.dart';
import '../../data/local_db.dart';
import '../../data/models/anime_detail.dart';
import '../../data/models/catalog_entry.dart';
import '../../data/models/download_item.dart';
import '../../data/models/watch_history.dart';

// Services
final catalogServiceProvider = Provider((ref) => CatalogService());
final aniListServiceProvider = Provider((ref) => AniListService());
final downloadServiceProvider = Provider((ref) => DownloadService());

// Catalog State
final catalogProvider = FutureProvider<CatalogData>((ref) async {
  final service = ref.watch(catalogServiceProvider);
  return await service.fetchCatalog();
});

// AniList Batch Data State
final aniListBatchProvider = FutureProvider<Map<int, AniListAnime>>((ref) async {
  final catalogAsync = await ref.watch(catalogProvider.future);
  final ids = catalogAsync.anime.map((e) => e.anilistId).toList();
  final service = ref.watch(aniListServiceProvider);
  return await service.fetchAnimeBatch(ids);
});

// Single Anime Combined Info
class AnimeCombinedInfo {
  final CatalogAnimeEntry catalogEntry;
  final AniListAnime? aniListAnime;

  AnimeCombinedInfo({required this.catalogEntry, this.aniListAnime});
}

final animeListCombinedProvider = Provider<AsyncValue<List<AnimeCombinedInfo>>>((ref) {
  final catalogAsync = ref.watch(catalogProvider);
  final aniListAsync = ref.watch(aniListBatchProvider);

  if (catalogAsync.isLoading || aniListAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (catalogAsync.hasError) {
    return AsyncValue.error(catalogAsync.error!, catalogAsync.stackTrace!);
  }

  final catalogData = catalogAsync.value!;
  final aniListMap = aniListAsync.value ?? {};

  final list = catalogData.anime.map((entry) {
    return AnimeCombinedInfo(
      catalogEntry: entry,
      aniListAnime: aniListMap[entry.anilistId],
    );
  }).toList();

  return AsyncValue.data(list);
});

// Watch History Notifier
class WatchHistoryNotifier extends StateNotifier<AsyncValue<List<WatchHistory>>> {
  WatchHistoryNotifier() : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final list = await LocalDb.instance.getAllWatchHistory();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveProgress({
    required int animeId,
    required int episodeNumber,
    required int positionMs,
    required int durationMs,
  }) async {
    final history = WatchHistory(
      animeId: animeId,
      episodeNumber: episodeNumber,
      positionMs: positionMs,
      durationMs: durationMs,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await LocalDb.instance.saveWatchHistory(history);
    await loadHistory();
  }

  Future<void> deleteHistory(int animeId) async {
    await LocalDb.instance.deleteWatchHistory(animeId);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await LocalDb.instance.clearAllWatchHistory();
    await loadHistory();
  }
}

final watchHistoryProvider =
    StateNotifierProvider<WatchHistoryNotifier, AsyncValue<List<WatchHistory>>>((ref) {
  return WatchHistoryNotifier();
});

// Bookmarks Notifier
class BookmarkNotifier extends StateNotifier<Set<int>> {
  BookmarkNotifier() : super({}) {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final items = await LocalDb.instance.getBookmarks();
    final ids = items.map((m) => m['anime_id'] as int).toSet();
    state = ids;
  }

  Future<void> toggleBookmark(int animeId, String jsonStr) async {
    await LocalDb.instance.toggleBookmark(animeId, jsonStr);
    await loadBookmarks();
  }
}

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, Set<int>>((ref) {
  return BookmarkNotifier();
});

// Downloads Notifier
class DownloadManagerNotifier extends StateNotifier<AsyncValue<List<DownloadItem>>> {
  final DownloadService _service;
  final Map<String, double> _downloadingProgress = {};

  DownloadManagerNotifier(this._service) : super(const AsyncValue.loading()) {
    loadDownloads();
  }

  Map<String, double> get downloadingProgress => _downloadingProgress;

  Future<void> loadDownloads() async {
    try {
      final items = await LocalDb.instance.getAllDownloads();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startDownload({
    required int animeId,
    required String animeTitle,
    required int episodeNumber,
    required String videoUrl,
  }) async {
    final key = '$animeId-$episodeNumber';
    _downloadingProgress[key] = 0.0;
    // Notify listeners of progress change
    state = state;

    try {
      await _service.downloadEpisode(
        animeId: animeId,
        animeTitle: animeTitle,
        episodeNumber: episodeNumber,
        videoUrl: videoUrl,
        onProgress: (progress) {
          _downloadingProgress[key] = progress;
          state = state;
        },
      );
    } finally {
      _downloadingProgress.remove(key);
      await loadDownloads();
    }
  }

  Future<void> deleteDownload(DownloadItem item) async {
    await _service.deleteDownload(item);
    await loadDownloads();
  }
}

final downloadManagerProvider =
    StateNotifierProvider<DownloadManagerNotifier, AsyncValue<List<DownloadItem>>>((ref) {
  final service = ref.watch(downloadServiceProvider);
  return DownloadManagerNotifier(service);
});
