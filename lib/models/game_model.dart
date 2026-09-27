class GameModel {
  const GameModel({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.rating,
    required this.released,
    required this.genres,
  });

  final int id;
  final String name;
  final String? backgroundImage;
  final double rating;
  final String? released;
  final List<String> genres;

  factory GameModel.fromJson(Map<String, dynamic> json) {
    final genresJson = json['genres'];

    return GameModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Untitled game',
      backgroundImage: json['background_image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      released: json['released'] as String?,
      genres: genresJson is List
          ? genresJson
                .whereType<Map<String, dynamic>>()
                .map((genre) => genre['name'] as String?)
                .whereType<String>()
                .toList()
          : const [],
    );
  }
}
