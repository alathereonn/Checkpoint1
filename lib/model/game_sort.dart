enum GameSort { popular, topRated, newest, alphabetical }

extension GameSortX on GameSort {
  String get label => switch (this) {
    GameSort.popular => 'Popular',
    GameSort.topRated => 'Top Rated',
    GameSort.newest => 'Newest',
    GameSort.alphabetical => 'A-Z',
  };

  String get rawgOrdering => switch (this) {
    GameSort.popular => '-added',
    GameSort.topRated => '-rating',
    GameSort.newest => '-released',
    GameSort.alphabetical => 'name',
  };
}
