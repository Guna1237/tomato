import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand palette
  static const spaceIndigo  = Color(0xFF2B2D42);
  static const lavenderGrey = Color(0xFF8D99AE);
  static const platinum     = Color(0xFFEDF2F4);
  static const punchRed     = Color(0xFFEF233C);
  static const flagRed      = Color(0xFFD90429);

  // Tomato ramp
  static const tomato50  = Color(0xFFFFF1F3);
  static const tomato100 = Color(0xFFFFDDE2);
  static const tomato200 = Color(0xFFFFB5BF);
  static const tomato300 = Color(0xFFFF8A97);
  static const tomato400 = Color(0xFFFF5A6D);
  static const tomato500 = Color(0xFFEF233C);
  static const tomato600 = Color(0xFFD90429);
  static const tomato700 = Color(0xFFB3001F);
  static const tomato800 = Color(0xFF8C0018);
  static const tomato900 = Color(0xFF660012);

  // Ember accent
  static const ember200 = Color(0xFFFFDDD6);
  static const ember300 = Color(0xFFFFC4B0);
  static const ember400 = Color(0xFFFF8E78);
  static const ember500 = Color(0xFFFF6A55);
  static const ember600 = Color(0xFFE54E38);

  // Leaf green
  static const leaf100 = Color(0xFFD4F0DC);
  static const leaf300 = Color(0xFFA6D9B0);
  static const leaf400 = Color(0xFF74BE89);
  static const leaf500 = Color(0xFF3FA85B);
  static const leaf600 = Color(0xFF2E8E48);

  // Indigo ramp
  static const indigo50  = Color(0xFFEDF2F4);
  static const indigo100 = Color(0xFFD6DDE5);
  static const indigo200 = Color(0xFF9BACC0);
  static const indigo300 = Color(0xFF8D99AE);
  static const indigo400 = Color(0xFF5E6781);
  static const indigo500 = Color(0xFF3F4359);
  static const indigo600 = Color(0xFF2B2D42);
  static const indigo700 = Color(0xFF1E2035);
  static const indigo800 = Color(0xFF151624);
  static const indigo900 = Color(0xFF0C0D17);

  // Semantic — light
  static const bgCanvas  = Color(0xFFF8FAFB);
  static const bgSurface = Color(0xFFFFFFFF);
  static const bgSunken  = Color(0xFFEDF2F4);

  // Semantic — dark
  static const darkCanvas   = Color(0xFF0C0D17);
  static const darkSurface  = Color(0xFF1A1B2C);
  static const darkSunken   = Color(0xFF131423);
  static const darkElevated = Color(0xFF20223A);
}

extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bgCanvas  => isDark ? AppColors.darkCanvas  : AppColors.bgCanvas;
  Color get bgSurface => isDark ? AppColors.darkSurface : AppColors.bgSurface;
  Color get bgSunken  => isDark ? AppColors.darkSunken  : AppColors.bgSunken;
  Color get bgElevated => isDark ? AppColors.darkElevated : AppColors.bgSurface;

  Color get fg1 => isDark ? AppColors.platinum     : AppColors.spaceIndigo;
  Color get fg2 => isDark ? const Color(0xFFC5CCD9) : const Color(0xFF3F4359);
  Color get fg3 => isDark ? AppColors.lavenderGrey  : const Color(0xFF5E6781);
  Color get fg4 => isDark ? const Color(0xFF5E6781)  : AppColors.lavenderGrey;

  Color get brand      => isDark ? const Color(0xFFFF3D52) : AppColors.punchRed;
  Color get brandSoft  => isDark ? const Color(0x33FF3D52) : const Color(0x14EF233C);
  Color get brandMid   => isDark ? const Color(0x66FF3D52) : const Color(0x33EF233C);

  Color get leaf  => AppColors.leaf500;
  Color get ember => AppColors.ember500;

  Color get hairline => isDark
      ? const Color(0x12EDF2F4)
      : const Color(0x122B2D42);

  Color get shadow => isDark
      ? const Color(0x66000000)
      : const Color(0x0A2B2D42);
}
