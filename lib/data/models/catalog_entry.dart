class CatalogEpisode {
  final int episodeNumber;
  final String videoType; // 'youtube' or 'direct'
  final String? youtubeId;
  final String? videoUrl;
  final String sourceChannel;

  CatalogEpisode({
    required this.episodeNumber,
    required this.videoType,
    this.youtubeId,
    this.videoUrl,
    required this.sourceChannel,
  });

  factory CatalogEpisode.fromJson(Map<String, dynamic> json) {
    return CatalogEpisode(
      episodeNumber: json['episode_number'] as int,
      videoType: json['video_type'] as String,
      youtubeId: json['youtube_id'] as String?,
      videoUrl: json['video_url'] as String?,
      sourceChannel: json['source_channel'] as String? ?? 'Sumber Resmi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episode_number': episodeNumber,
      'video_type': videoType,
      'youtube_id': youtubeId,
      'video_url': videoUrl,
      'source_channel': sourceChannel,
    };
  }
}

class CatalogAnimeEntry {
  final int id;
  final int anilistId;
  final String? addedDate;
  final List<CatalogEpisode> episodes;

  CatalogAnimeEntry({
    required this.id,
    required this.anilistId,
    this.addedDate,
    required this.episodes,
  });

  factory CatalogAnimeEntry.fromJson(Map<String, dynamic> json) {
    return CatalogAnimeEntry(
      id: json['id'] as int,
      anilistId: json['anilist_id'] as int,
      addedDate: json['added_date'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => CatalogEpisode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anilist_id': anilistId,
      'added_date': addedDate,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}

class CatalogData {
  final String updatedAt;
  final List<CatalogAnimeEntry> anime;

  CatalogData({
    required this.updatedAt,
    required this.anime,
  });

  factory CatalogData.fromJson(Map<String, dynamic> json) {
    return CatalogData(
      updatedAt: json['updated_at'] as String? ?? '',
      anime: (json['anime'] as List<dynamic>?)
              ?.map((e) => CatalogAnimeEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'updated_at': updatedAt,
      'anime': anime.map((e) => e.toJson()).toList(),
    };
  }
}
