import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project/BrainyBee/presentation/widgets/brainybee_bottom_navigation.dart';
import 'package:mobile_app_project/core/routing/routes.dart';

class BrainyShellScreen extends StatelessWidget {
  const BrainyShellScreen({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  int _getSelectedIndex() {
    if (location.startsWith(Routes.routines)) {
      return 1;
    }

    if (location.startsWith(Routes.quiz)) {
      return 2;
    }

    if (location.startsWith(Routes.game)) {
      return 3;
    }

    if (location.startsWith(Routes.profile)) {
      return 4;
    }

    return 0;
  }

  Future<void> _onItemTapped(BuildContext context, int index) async {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;

      case 1:
        context.go(Routes.routines);
        break;

      case 2:
        context.go(Routes.quiz);
        break;

      case 3:
        context.go(Routes.game);
        break;

      case 4:
        context.go(Routes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex();

    return Scaffold(
      body: child,

      bottomNavigationBar: BrainyBottomNavigation(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          _onItemTapped(context, index);
        },
      ),
    );
  }
}
