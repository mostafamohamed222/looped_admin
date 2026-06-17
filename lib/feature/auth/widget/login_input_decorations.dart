import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';

abstract final class LoginInputDecorations {
  static InputBorder underlineBorder(Color color, {double width = 1}) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputDecoration base({
    required ThemeData theme,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: true,
      border: underlineBorder(Colors.grey.shade300),
      enabledBorder: underlineBorder(Colors.grey.shade300),
      focusedBorder: underlineBorder(LoginColors.navy, width: 2),
      errorBorder: underlineBorder(theme.colorScheme.error),
      focusedErrorBorder: underlineBorder(theme.colorScheme.error, width: 2),
      contentPadding: const EdgeInsets.only(bottom: 6, top: 4),
    );
  }
}
