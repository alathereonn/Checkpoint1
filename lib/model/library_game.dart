import 'package:checkpoint/enum/library_status.dart';
import 'package:checkpoint/model/game_model.dart';

class LibraryGame {
  const LibraryGame({
    required this.game,
    required this.status,
    required this.addedAt,
  });

  final GameModel game;
  final LibraryStatus status;
  final DateTime addedAt;

  LibraryGame copyWith({GameModel? game, LibraryStatus? status}) {
    return LibraryGame(
      game: game ?? this.game,
      status: status ?? this.status,
      addedAt: addedAt,
    );
  }
}
