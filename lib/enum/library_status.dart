enum LibraryStatus {
  backlog,
  playing,
  completed
}

extension LibraryStatusLabel on LibraryStatus {
  String get label {
    switch (this) {
      case LibraryStatus.backlog:
        return 'Backlog';
      case LibraryStatus.playing:
        return 'Playing';
      case LibraryStatus.completed:
        return 'Completed';
    }
  }

  String get description {
    switch (this) {
      case LibraryStatus.backlog:
        return 'Want to play later';
      case LibraryStatus.playing:
        return 'Currently playing';
      case LibraryStatus.completed:
        return 'Already finished';
    }
  }
}
