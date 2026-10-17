import 'package:checkpoint/enum/library_status.dart';

enum LibraryFilter { all, backlog, playing, completed }

extension LibraryFilterX on LibraryFilter {
  String get label {
    switch (this) {
      case LibraryFilter.all:
        return 'All';
      case LibraryFilter.backlog:
        return 'Backlog';
      case LibraryFilter.playing:
        return 'Playing';
      case LibraryFilter.completed:
        return 'Completed';
    }
  }

  LibraryStatus? get status {
    switch (this) {
      case LibraryFilter.all:
        return null;
      case LibraryFilter.backlog:
        return LibraryStatus.backlog;
      case LibraryFilter.playing:
        return LibraryStatus.playing;
      case LibraryFilter.completed:
        return LibraryStatus.completed;
    }
  }
}
