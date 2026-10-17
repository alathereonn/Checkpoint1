import 'package:checkpoint/enum/library_status.dart';
import 'package:flutter/material.dart';

Future<LibraryStatus?> showLibraryStatusSheet(BuildContext context) {
  return showModalBottomSheet<LibraryStatus>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Save to Library'),
              subtitle: Text('Choose the current game status'),
            ),
            _LibraryStatusOption(
              status: LibraryStatus.backlog,
              icon: Icons.bookmark_outline_rounded,
              onSelected: () =>
                  Navigator.pop(sheetContext, LibraryStatus.backlog),
            ),
            _LibraryStatusOption(
              status: LibraryStatus.playing,
              icon: Icons.play_circle_outline_rounded,
              onSelected: () =>
                  Navigator.pop(sheetContext, LibraryStatus.playing),
            ),
            _LibraryStatusOption(
              status: LibraryStatus.completed,
              icon: Icons.check_circle_outline_rounded,
              onSelected: () =>
                  Navigator.pop(sheetContext, LibraryStatus.completed),
            ),
          ],
        ),
      );
    },
  );
}

class _LibraryStatusOption extends StatelessWidget {
  const _LibraryStatusOption({
    required this.status,
    required this.icon,
    required this.onSelected,
  });

  final LibraryStatus status;
  final IconData icon;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(status.label),
      subtitle: Text(status.description),
      onTap: onSelected,
    );
  }
}
