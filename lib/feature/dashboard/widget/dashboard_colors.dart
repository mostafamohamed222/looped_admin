import 'package:flutter/material.dart';

/// Palette for the dashboard (لوحة التحكم) screen — aligned with Stitch mock.
abstract final class DashboardColors {
  static const Color pageBackground = Color(0xFFF5F6F8);
  static const Color appBarBackground = Color(0xFFF8F9FB);
  static const Color titleText = Color(0xFF231F20);
  static const Color subtitleGrey = Color(0xFF64748B);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color statusBannerBg = Color(0xFFE8F4FC);
  static const Color statusBannerBorder = Color(0xFFC8E0F4);
  static const Color statusBannerIconBg = Color(0xFF3B82F6);
  static const Color accentBlue = Color(0xFF2563EB);

  /// Feature card icon tiles (Orders / Reports / Statistics).
  static const Color ordersIconBg = Color(0xFF0D1B3E);
  static const Color reportsIconBg = Color(0xFF93C5FD);
  static const Color statisticsIconBg = Color(0xFFE4E8F5);

  static const Color statisticsChartIcon = Color(0xFF1E3A8A);
  static const Color linkText = Color(0xFF2563EB);

  /// AI Assistant card (المساعد الذكي).
  static const Color aiCardBackground = Color(0xFFEEF4FF);
  static const Color aiCardBorder = Color(0xFFC9D8F8);
  static const Color aiIconBackground = Color(0xFF001133);
  static const Color aiTitleColor = Color(0xFF0D1B3E);
  static const Color aiBodyText = Color(0xFF1E293B);
  static const Color aiButtonBorder = Color(0xFFE2E8F0);
  static const Color aiWatermark = Color(0xFF94A3B8);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
