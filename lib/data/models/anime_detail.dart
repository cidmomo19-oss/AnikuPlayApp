class AnimeCharacterNode {
  final String name;
  final String? imageUrl;

  AnimeCharacterNode({required this.name, this.imageUrl});

  factory AnimeCharacterNode.fromJson(Map<String, dynamic> json) {
    final nameObj = json['name'] as Map<String, dynamic>?;
    final imgObj = json['image'] as Map<String, dynamic>?;
    return AnimeCharacterNode(
      name: nameObj?['full'] as String? ?? 'Unknown',
      imageUrl: imgObj?['medium'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'imageUrl': imageUrl};
}

class AnimeStaffNode {
  final String name;
  final List<String> occupations;

  AnimeStaffNode({required this.name, required this.occupations});

  factory AnimeStaffNode.fromJson(Map<String, dynamic> json) {
    final nameObj = json['name'] as Map<String, dynamic>?;
    final occList = (json['primaryOccupations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return AnimeStaffNode(
      name: nameObj?['full'] as String? ?? 'Unknown',
      occupations: occList,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'occupations': occupations};
}

class AniListAnime {
  final int id;
  final String titleRomaji;
  final String? titleEnglish;
  final String? titleNative;
  final String? description;
  final String? coverLarge;
  final String? bannerImage;
  final List<String> genres;
  final double? averageScore;
  final String? status;
  final String? season;
  final int? seasonYear;
  final int? totalEpisodes;
  final String? mainStudio;
  final List<AnimeCharacterNode> characters;
  final List<AnimeStaffNode> staff;

  AniListAnime({
    required this.id,
    required this.titleRomaji,
    this.titleEnglish,
    this.titleNative,
    this.description,
    this.coverLarge,
    this.bannerImage,
    required this.genres,
    this.averageScore,
    this.status,
    this.season,
    this.seasonYear,
    this.totalEpisodes,
    this.mainStudio,
    required this.characters,
    required this.staff,
  });

  String get displayTitle =>
      (titleEnglish != null && titleEnglish!.isNotEmpty) ? titleEnglish! : titleRomaji;

  factory AniListAnime.fromJson(Map<String, dynamic> json) {
    final titleMap = json['title'] as Map<String, dynamic>?;
    final coverMap = json['coverImage'] as Map<String, dynamic>?;
    final studioNodes = (json['studios'] as Map<String, dynamic>?)?['nodes'] as List<dynamic>?;
    final mainStudioName = studioNodes != null && studioNodes.isNotEmpty
        ? studioNodes.first['name'] as String?
        : null;

    final charNodes = (json['characters'] as Map<String, dynamic>?)?['nodes'] as List<dynamic>?;
    final staffNodes = (json['staff'] as Map<String, dynamic>?)?['nodes'] as List<dynamic>?;

    return AniListAnime(
      id: json['id'] as int,
      titleRomaji: titleMap?['romaji'] as String? ?? 'Untitled',
      titleEnglish: titleMap?['english'] as String?,
      titleNative: titleMap?['native'] as String?,
      description: json['description'] as String?,
      coverLarge: coverMap?['extraLarge'] as String? ?? coverMap?['large'] as String?,
      bannerImage: json['bannerImage'] as String?,
      genres: (json['genres'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      averageScore: (json['averageScore'] as num?)?.toDouble(),
      status: json['status'] as String?,
      season: json['season'] as String?,
      seasonYear: json['seasonYear'] as int?,
      totalEpisodes: json['episodes'] as int?,
      mainStudio: mainStudioName,
      characters: charNodes
              ?.map((c) => AnimeCharacterNode.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      staff: staffNodes
              ?.map((s) => AnimeStaffNode.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': {
        'romaji': titleRomaji,
        'english': titleEnglish,
        'native': titleNative,
      },
      'description': description,
      'coverImage': {'extraLarge': coverLarge, 'large': coverLarge},
      'bannerImage': bannerImage,
      'genres': genres,
      'averageScore': averageScore,
      'status': status,
      'season': season,
      'seasonYear': seasonYear,
      'episodes': totalEpisodes,
      'studios': {
        'nodes': mainStudio != null ? [{'name': mainStudio}] : []
      },
      'characters': {
        'nodes': characters.map((c) => {'name': {'full': c.name}, 'image': {'medium': c.imageUrl}}).toList()
      },
      'staff': {
        'nodes': staff.map((s) => {'name': {'full': s.name}, 'primaryOccupations': s.occupations}).toList()
      },
    };
  }
}
