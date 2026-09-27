class WatchHistory {
  final int animeId;
  final int episodeNumber;
  final int positionMs;
  final int durationMs;
  final int updatedAt;

  WatchHistory({
    required this.animeId,
    required this.episodeNumber,
    required this.positionMs,
    required this.durationMs,
    required this.updatedAt,
  });

  double get progressRatio => durationMs > 0 ? (positionMs / durationMs).clamp(0.0, 1.0) : 0.0;

  factory WatchHistory.fromMap(Map<String, dynamic> map) {
    return WatchHistory(
      animeId: map['anime_id'] as int,
      episodeNumber: map['episode_number'] as int,
      positionMs: map['position_ms'] as int,
      durationMs: map['duration_ms'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'anime_id': animeId,
      'episode_number': episodeNumber,
      'position_ms': positionMs,
      'duration_ms': durationMs,
      'updated_at': updatedAt,
    };
  }
}
