import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';

/// Shared palette for account / settings UI blocks.
abstract final class AccountSettingsColors {
  static const Color navy = ColorManager.mainColor;
  static const Color fieldFill = Color(0xFFF1F5F9);
  static const Color fieldBorder = Color(0xFFCBD5E1);
  static const Color subtitleGrey = Color(0xFF64748B);
  static const Color verificationBg = Color(0xFFE0F2FE);
  static const Color verificationFg = Color(0xFF0369A1);
  static const Color memberBg = Color(0xFFF1F5F9);
  static const Color memberFg = Color(0xFF64748B);
  static const Color avatarRing = Color(0xFFBFDBFE);

  static const Color langSectionBg = Color(0xFFEEF4FB);
  static const Color langTeal = Color(0xFF0D9488);
  static const Color langTealDark = Color(0xFF0F766E);
  static const Color langRadioEmpty = Color(0xFFCBD5E1);

  static const Color notifyCardBorder = Color(0xFFE2E8F0);
  static const Color notifySwitchTrackOff = Color(0xFFE5E7EB);
  static const Color notifySwitchThumbOff = Color(0xFFFFFFFF);

  static const Color assistantCardBg = Color(0xFF0C1828);
  static const Color assistantBadgeBg = Color(0xFF115E59);
  static const Color assistantBodyText = Color(0xFF94A3B8);
  static const Color assistantPrimaryCyan = Color(0xFF7DD3FC);

  static const Color pageBackground = ColorManager.backgroundColor;
}
