import 'dart:convert';
import 'package:dio/dio.dart';
import 'local_db.dart';
import 'models/anime_detail.dart';

class AniListService {
  final Dio _dio;
  static const String graphqlEndpoint = 'https://graphql.anilist.co';

  AniListService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _batchQuery = r'''
    query ($ids: [Int]) {
      Page(perPage: 50) {
        media(id_in: $ids, type: ANIME) {
          id
          title { romaji english native }
          description(asHtml: false)
          coverImage { large extraLarge color }
          bannerImage
          genres
          averageScore
          status
          season
          seasonYear
          episodes
          studios(isMain: true) { nodes { name } }
          characters(sort: ROLE, perPage: 10) {
            nodes { name { full } image { medium } }
          }
          staff(sort: RELEVANCE, perPage: 6) {
            nodes { name { full } primaryOccupations }
          }
        }
      }
    }
  ''';

  Future<Map<int, AniListAnime>> fetchAnimeBatch(List<int> anilistIds) async {
    if (anilistIds.isEmpty) return {};

    final result = <int, AniListAnime>{};
    final missingIds = <int>[];

    // Check DB cache first
    for (final id in anilistIds) {
      final cachedJson = await LocalDb.instance.getCachedAniListMedia(id);
      if (cachedJson != null) {
        try {
          final anime = AniListAnime.fromJson(jsonDecode(cachedJson));
          result[id] = anime;
        } catch (_) {
          missingIds.add(id);
        }
      } else {
        missingIds.add(id);
      }
    }

    if (missingIds.isEmpty) {
      return result;
    }

    try {
      final response = await _dio.post(
        graphqlEndpoint,
        data: {
          'query': _batchQuery,
          'variables': {'ids': missingIds},
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final mediaList = response.data['data']?['Page']?['media'] as List<dynamic>?;
        if (mediaList != null) {
          for (final item in mediaList) {
            final anime = AniListAnime.fromJson(item as Map<String, dynamic>);
            result[anime.id] = anime;
            // Save to DB cache
            await LocalDb.instance.cacheAniListMedia(
              anime.id,
              jsonEncode(item),
            );
          }
        }
      }
    } catch (_) {
      // If network fails, return cached ones available
    }

    return result;
  }
}
