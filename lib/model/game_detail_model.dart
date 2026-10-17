class GameDetailModel {
  const GameDetailModel({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.description,
    required this.rating,
    required this.metacritic,
    required this.released,
    required this.genres,
    required this.platforms,
    required this.developers,
    required this.publishers,
    required this.playtime,
    required this.esrbRating,
    required this.website,
  });

  final int id;
  final String name;
  final String? backgroundImage;
  final String description;
  final double rating;
  final int? metacritic;
  final String? released;
  final List<String> genres;
  final List<String> platforms;
  final List<String> developers;
  final List<String> publishers;
  final int? playtime;
  final String? esrbRating;
  final String? website;

  factory GameDetailModel.fromJson(Map<String, dynamic> json) {
    return GameDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Untitled game',
      backgroundImage: json['background_image'] as String?,
      description:
          (json['description_raw'] as String?)?.trim().isNotEmpty == true
          ? json['description_raw'] as String
          : json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      metacritic: (json['metacritic'] as num?)?.toInt(),
      released: json['released'] as String?,
      genres: _readNames(json['genres']),
      platforms: _readPlatformNames(json['platforms']),
      developers: _readNames(json['developers']),
      publishers: _readNames(json['publishers']),
      playtime: (json['playtime'] as num?)?.toInt(),
      esrbRating:
          (json['esrb_rating'] as Map<String, dynamic>?)?['name'] as String?,
      website: json['website'] as String?,
    );
  }

  static List<String> _readNames(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name'] as String?)
        .whereType<String>()
        .toList();
  }

  static List<String> _readPlatformNames(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map<String, dynamic>>()
        .map((item) => item['platform'] as Map<String, dynamic>?)
        .whereType<Map<String, dynamic>>()
        .map((platform) => platform['name'] as String?)
        .whereType<String>()
        .toList();
  }
}
