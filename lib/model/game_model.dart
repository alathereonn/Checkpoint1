class GameModel {
  const GameModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.esrbRating,
    required this.rating,
    required this.released,
    required this.genres,
    this.description,
    this.platforms = const [],
    this.developers = const [],
  });

  final int id;
  final String name;
  final String? imageUrl;
  final String? esrbRating;
  final double? rating;
  final String? released;
  final List<String> genres;
  final String? description;
  final List<String> platforms;
  final List<String> developers;
}
