import 'package:flutter/material.dart';

import 'package:mobile_app_project/core/theme/app_colors.dart';

/// Gives every subject a color from the palette, based only on its name.
///
/// The same name always gets the same color, in the timetable and (later) in
/// the homework list, with nothing to store. Capital letters and spaces at the
/// ends are ignored, so "Math" and " math" match.
class SubjectColors {
  SubjectColors._();

  static const List<Color> _palette = [
    AppColors.canyonSoft,
    AppColors.buttercreamSoft,
    AppColors.morningSkySoft,
    AppColors.oliveGroveSoft,
  ];

  static Color of(String subject) {
    final name = subject.trim().toLowerCase();
    if (name.isEmpty) return AppColors.buttercreamSoft;

    // A tiny hash written by hand. (Dart's own String.hashCode is not
    // guaranteed to be the same between app runs, which would make colors
    // change.) `& 0x7fffffff` keeps the number positive.
    var hash = 0;
    for (final unit in name.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }
}