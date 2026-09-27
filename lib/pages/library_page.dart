import 'package:checkpoint/widgets/tab_placeholder.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(
      icon: Icons.library_books_outlined,
      title: 'Library',
      message: 'Your saved games will appear here.',
    );
  }
}
