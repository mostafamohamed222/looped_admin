import 'package:flutter/material.dart';

/// Palette for the categorized orders (طلبات مصنفة) screen.
abstract final class CategorizedOrdersColors {
  static const Color pageBackground = Color(0xFFF5F6F8);
  static const Color primaryNavy = Color(0xFF0D1B3E);
  static const Color subtitleGrey = Color(0xFF64748B);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color accentTeal = Color(0xFF0F766E);
  static const Color accentTealSoft = Color(0xFFCCFBF1);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentBlueSoft = Color(0xFFEFF6FF);
  static const Color accentAmber = Color(0xFFD97706);
  static const Color accentAmberSoft = Color(0xFFFFFBEB);
  static const Color statusBannerBg = Color(0xFFE8F4FC);
  static const Color statusBannerBorder = Color(0xFFC8E0F4);
  static const Color statusBannerIconBg = Color(0xFF2563EB);
  static const Color sectionHeaderBg = Color(0xFF0D1B3E);
  static const Color divider = Color(0xFFF1F5F9);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
}
