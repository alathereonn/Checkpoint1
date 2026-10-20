class GameModel {
  const GameModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.released,
    required this.genres,
  });

  final int id;
  final String name;
  final double rating;
  final String? released;
  final List<String> genres;
}
