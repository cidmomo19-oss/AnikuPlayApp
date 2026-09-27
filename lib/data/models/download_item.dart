class DownloadItem {
  final int? id;
  final int animeId;
  final String animeTitle;
  final int episodeNumber;
  final String filePath;
  final int downloadedAt;

  DownloadItem({
    this.id,
    required this.animeId,
    required this.animeTitle,
    required this.episodeNumber,
    required this.filePath,
    required this.downloadedAt,
  });

  factory DownloadItem.fromMap(Map<String, dynamic> map) {
    return DownloadItem(
      id: map['id'] as int?,
      animeId: map['anime_id'] as int,
      animeTitle: map['anime_title'] as String? ?? 'Anime',
      episodeNumber: map['episode_number'] as int,
      filePath: map['file_path'] as String,
      downloadedAt: map['downloaded_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'anime_id': animeId,
      'anime_title': animeTitle,
      'episode_number': episodeNumber,
      'file_path': filePath,
      'downloaded_at': downloadedAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
