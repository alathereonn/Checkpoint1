# Checkpoint

Checkpoint is a Flutter game-backlog tracker. The current version uses six local sample games and does not contact external services.

## Features

- Browse and search the sample game list.
- View sample game details and add games to a local library.
- Organize library games by status.
- Create daily quests for games marked as Playing.
- Track play sessions and view session history.

Library entries, quests, and sessions are kept in memory for the current app run; they are not saved after the app closes.

## Run

```bash
flutter pub get
flutter run
```

## Verify

```bash
flutter analyze
flutter test
```
