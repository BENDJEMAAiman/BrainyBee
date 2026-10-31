import 'package:flutter/material.dart';

/// Every color used by BrainyBee lives here.
///
/// Widgets should never write a hex value directly. They should always use
/// one of these names, so the whole app can be re-themed from a single file.
class AppColors {
  AppColors._(); // Prevents creating instances; this class is only constants.

  // ---------------------------------------------------------------------------
  // Palette (from your color palette image)
  // ---------------------------------------------------------------------------
  static const Color canyon = Color(0xFFDF6D41);
  static const Color buttercream = Color(0xFFF7D89A);
  static const Color morningSky = Color(0xFF8DA6CC);
  static const Color oliveGrove = Color(0xFFAAA648);

  // ---------------------------------------------------------------------------
  // Soft tints: lighter versions used for card backgrounds, chips, highlights
  // ---------------------------------------------------------------------------
  static const Color canyonSoft = Color(0xFFFBE3D9);
  static const Color buttercreamSoft = Color(0xFFFDF1D6);
  static const Color morningSkySoft = Color(0xFFE5ECF6);
  static const Color oliveGroveSoft = Color(0xFFEDEED2);

  // ---------------------------------------------------------------------------
  // Neutrals
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFFFBF8F2); // warm off-white page
  static const Color surface = Color(0xFFFFFFFF); // cards
  static const Color border = Color(0xFFEDE6D9);
  static const Color textPrimary = Color(0xFF2E2A27); // warm near-black
  static const Color textSecondary = Color(0xFF7A726B);

  // ---------------------------------------------------------------------------
  // Roles: what each palette color MEANS in the app
  // ---------------------------------------------------------------------------
  /// Main buttons and active elements.
  static const Color primary = canyon;

  /// Text/icons placed on top of [primary]. Use only for large or bold text.
  static const Color onPrimary = Colors.white;

  /// A habit day / homework marked as done.
  static const Color done = oliveGrove;

  /// Text/icons placed on top of [done]. Dark, because white on olive is hard
  /// to read.
  static const Color onDone = textPrimary;

  /// Studies page: timetable, homework.
  static const Color studies = morningSky;

  /// Warm highlights (today, current class, streak badges).
  static const Color highlight = buttercream;
}