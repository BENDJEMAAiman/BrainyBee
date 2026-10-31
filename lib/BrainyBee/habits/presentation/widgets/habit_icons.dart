import 'package:flutter/material.dart';

import 'package:mobile_app_project/core/theme/app_colors.dart';

/// How one habit icon looks: the icon itself and its tinted background.
class HabitIconStyle {
  const HabitIconStyle({required this.icon, required this.background});

  final IconData icon;
  final Color background;
}

/// Maps the short text key stored in a Habit (e.g. "water") to an icon.
///
/// Keeping this in the presentation layer means the Habit model stays free of
/// Flutter code, and Firestore only ever stores plain text.
class HabitIcons {
  HabitIcons._();

  static const HabitIconStyle _fallback = HabitIconStyle(
    icon: Icons.check_circle_outline_rounded,
    background: AppColors.buttercreamSoft,
  );

  static const Map<String, HabitIconStyle> _styles = {
    'water': HabitIconStyle(
      icon: Icons.water_drop_outlined,
      background: AppColors.morningSkySoft,
    ),
    'sleep': HabitIconStyle(
      icon: Icons.bedtime_outlined,
      background: AppColors.morningSkySoft,
    ),
    'exercise': HabitIconStyle(
      icon: Icons.fitness_center_rounded,
      background: AppColors.canyonSoft,
    ),
    'read': HabitIconStyle(
      icon: Icons.menu_book_outlined,
      background: AppColors.buttercreamSoft,
    ),
    'teeth': HabitIconStyle(
      icon: Icons.clean_hands_outlined,
      background: AppColors.oliveGroveSoft,
    ),
    'meditate': HabitIconStyle(
      icon: Icons.self_improvement_rounded,
      background: AppColors.oliveGroveSoft,
    ),
  };

  /// All available keys (the "add habit" form will use this for its picker).
  static List<String> get keys => _styles.keys.toList();

  /// The style for [key], or a neutral check icon if the key is unknown.
  static HabitIconStyle styleFor(String key) => _styles[key] ?? _fallback;
}