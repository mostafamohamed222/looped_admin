import 'package:flutter/material.dart';

/// Palette for the dashboard — aligned with inventory / orders screens.
abstract final class DashboardColors {
  static const Color pageBackground = Color(0xFFF5F6F8);
  static const Color primaryNavy = Color(0xFF0D1B3E);
  static const Color subtitleGrey = Color(0xFF64748B);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentBlueSoft = Color(0xFFEFF6FF);
  static const Color accentIndigoSoft = Color(0xFFE0E7FF);
  static const Color accentIndigo = Color(0xFF4338CA);
  static const Color accentTealSoft = Color(0xFFCCFBF1);
  static const Color accentTeal = Color(0xFF0F766E);
  static const Color accentVioletSoft = Color(0xFFEDE9FE);
  static const Color accentViolet = Color(0xFF7C3AED);
  static const Color statusBannerBg = Color(0xFFDCFCE7);
  static const Color statusBannerBorder = Color(0xFF86EFAC);
  static const Color statusBannerIconBg = Color(0xFF16A34A);
  static const Color sectionHeaderBg = Color(0xFF0D1B3E);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color linkText = Color(0xFF2563EB);

  /// AI Assistant card.
  static const Color aiCardBackground = Color(0xFFFFFFFF);
  static const Color aiIconBackground = Color(0xFF0D1B3E);
  static const Color aiAccentSoft = Color(0xFFEEF4FF);
  static const Color aiAccentBorder = Color(0xFFC9D8F8);

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
