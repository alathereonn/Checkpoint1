enum QuestStatus { pending, completed }

extension QuestStatusX on QuestStatus {
  String get label {
    switch (this) {
      case QuestStatus.pending:
        return 'Pending';
      case QuestStatus.completed:
        return 'Completed';
    }
  }

  String get emptyMessage {
    switch (this) {
      case QuestStatus.pending:
        return 'No pending quests for today.';
      case QuestStatus.completed:
        return 'No completed quests yet.';
    }
  }
}
