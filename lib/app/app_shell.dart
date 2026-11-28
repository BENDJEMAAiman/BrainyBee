import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app_project/core/theme/app_colors.dart';

/// The main page: the current tab and the bottom navigation bar.
///
/// [navigationShell] is provided by go_router. It shows the page of the
/// selected tab and remembers each tab's state when you switch between them.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.canyonSoft,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            // Tapping the tab you are already on goes back to its first page.
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_rounded),
              label: 'Habits',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Studies',
            ),
          ],
        ),
      ),
    );
  }
}