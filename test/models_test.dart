import 'dart:convert';
import 'package:anikuplay/data/models/anime_detail.dart';
import 'package:anikuplay/data/models/catalog_entry.dart';
import 'package:anikuplay/data/models/download_item.dart';
import 'package:anikuplay/data/models/watch_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Catalog Models Test', () {
    test('CatalogData json parsing', () {
      final jsonMap = {
        'updated_at': '2026-09-27',
        'anime': [
          {
            'id': 1,
            'anilist_id': 21519,
            'added_date': '2026-09-20',
            'episodes': [
              {
                'episode_number': 1,
                'video_type': 'youtube',
                'youtube_id': 'L_LUpnjgPso',
                'source_channel': 'Muse Indonesia'
              },
              {
                'episode_number': 2,
                'video_type': 'direct',
                'video_url': 'https://example.com/sample.mp4',
                'source_channel': 'Video Uji'
              }
            ]
          }
        ]
      };

      final catalog = CatalogData.fromJson(jsonMap);
      expect(catalog.updatedAt, '2026-09-27');
      expect(catalog.anime.length, 1);
      expect(catalog.anime.first.anilistId, 21519);
      expect(catalog.anime.first.episodes.length, 2);
      expect(catalog.anime.first.episodes[0].videoType, 'youtube');
      expect(catalog.anime.first.episodes[1].videoType, 'direct');
    });
  });

  group('AniListAnime Model Test', () {
    test('AniListAnime GraphQL response parsing', () {
      final jsonMap = {
        'id': 21519,
        'title': {
          'romaji': 'Kimi no Na wa.',
          'english': 'Your Name.',
          'native': '君の名は。'
        },
        'description': 'Two strangers find themselves connected...',
        'coverImage': {
          'large': 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/medium/nx21519.jpg',
          'extraLarge': 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/nx21519.jpg'
        },
        'bannerImage': 'https://s4.anilist.co/file/anilistcdn/media/anime/banner/21519.jpg',
        'genres': ['Romance', 'Supernatural', 'Drama'],
        'averageScore': 88,
        'status': 'FINISHED',
        'season': 'SUMMER',
        'seasonYear': 2016,
        'episodes': 1,
        'studios': {
          'nodes': [
            {'name': 'CoMix Wave Films'}
          ]
        },
        'characters': {
          'nodes': [
            {
              'name': {'full': 'Mitsuha Miyamizu'},
              'image': {'medium': 'https://s4.anilist.co/char.jpg'}
            }
          ]
        },
        'staff': {
          'nodes': [
            {
              'name': {'full': 'Makoto Shinkai'},
              'primaryOccupations': ['Director', 'Writer']
            }
          ]
        }
      };

      final anime = AniListAnime.fromJson(jsonMap);
      expect(anime.id, 21519);
      expect(anime.displayTitle, 'Your Name.');
      expect(anime.mainStudio, 'CoMix Wave Films');
      expect(anime.averageScore, 88.0);
      expect(anime.characters.first.name, 'Mitsuha Miyamizu');
      expect(anime.staff.first.name, 'Makoto Shinkai');
    });
  });

  group('WatchHistory & DownloadItem Tests', () {
    test('WatchHistory calculations', () {
      final history = WatchHistory(
        animeId: 1,
        episodeNumber: 1,
        positionMs: 60000,
        durationMs: 120000,
        updatedAt: 1000000,
      );

      expect(history.progressRatio, 0.5);
    });

    test('DownloadItem mapping', () {
      final item = DownloadItem(
        id: 1,
        animeId: 10,
        animeTitle: 'Test Anime',
        episodeNumber: 2,
        filePath: '/storage/downloads/10/ep_2.mp4',
        downloadedAt: 1234567,
      );

      final map = item.toMap();
      final restored = DownloadItem.fromMap(map);

      expect(restored.animeTitle, 'Test Anime');
      expect(restored.filePath, '/storage/downloads/10/ep_2.mp4');
    });
  });
}
