import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/pages/game_library_page.dart';
import 'package:checkpoint/pages/library_page.dart';
import 'package:checkpoint/pages/profile_page.dart';
import 'package:checkpoint/pages/quest_page.dart';
import 'package:flutter/material.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  static const _pages = <Widget>[
    GameLibraryPage(),
    LibraryPage(),
    QuestPage(),
    ProfilePage(),
  ];

  int _selectedIndex = 0;

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scale = (media.size.width / 360.0).clamp(0.85, 1.15);
    final effectiveHeight =
        media.size.height - media.padding.top - media.padding.bottom;
    final navHeight = (effectiveHeight < 700 ? 62.0 : 68.0) * scale;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _BottomNavigationSection(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectDestination,
          scale: scale,
          navHeight: navHeight,
        ),
      ),
    );
  }
}

class _BottomNavigationSection extends StatelessWidget {
  const _BottomNavigationSection({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.scale,
    required this.navHeight,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final double scale;
  final double navHeight;

  double s(double value) => value * scale;

  static const _destinations = [
    _NavigationDestinationData(
      label: 'Games',
      icon: Icons.sports_esports_outlined,
      selectedIcon: Icons.sports_esports,
    ),
    _NavigationDestinationData(
      label: 'Library',
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books,
    ),
    _NavigationDestinationData(
      label: 'Quest',
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt,
    ),
    _NavigationDestinationData(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unselectedColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: AppColors.white,
      child: SizedBox(
        height: navHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: s(32),
              child: Row(
                children: List.generate(_destinations.length, (index) {
                  final destination = _destinations[index];
                  final isSelected = index == selectedIndex;

                  return Expanded(
                    child: InkWell(
                      onTap: () => onDestinationSelected(index),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: s(64),
                          height: s(32),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.14)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(s(16)),
                          ),
                          child: Icon(
                            isSelected
                                ? destination.selectedIcon
                                : destination.icon,
                            color: isSelected
                                ? AppColors.primary
                                : unselectedColor,
                            size: s(24),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: s(4)),
            SizedBox(
              height: s(16),
              child: Row(
                children: List.generate(_destinations.length, (index) {
                  final isSelected = index == selectedIndex;

                  return Expanded(
                    child: InkWell(
                      onTap: () => onDestinationSelected(index),
                      child: Center(
                        child: Text(
                          _destinations[index].label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : unselectedColor,
                            fontSize: s(12),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationDestinationData {
  const _NavigationDestinationData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
