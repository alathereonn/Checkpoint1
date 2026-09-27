import 'package:checkpoint/widgets/tab_placeholder.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(
      icon: Icons.person_outline,
      title: 'Profile',
      message: 'Your profile and statistics will appear here.',
    );
  }
}
