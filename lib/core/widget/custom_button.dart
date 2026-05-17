// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/core/widgets/build_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final CustomButtonStyle style;
  final Widget? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isOutlined;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style = CustomButtonStyle.primary,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.isOutlined = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();

    Widget button = isOutlined
        ? OutlinedButton(
            onPressed: (isEnabled && !isLoading) ? onPressed : null,
            style: OutlinedButton.styleFrom(
              backgroundColor: buttonStyle.backgroundColor,
              foregroundColor: buttonStyle.textColor,
              side: BorderSide(color: borderColor ?? buttonStyle.borderColor, width: 1.5),
              padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 12.r)),
            ),
            child: _buildButtonContent(),
          )
        : ElevatedButton(
            onPressed: (isEnabled && !isLoading) ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonStyle.backgroundColor,
              foregroundColor: buttonStyle.textColor,
              disabledBackgroundColor: ColorManager.disableTextColor,
              disabledForegroundColor: ColorManager.disableTextColor,
              padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 12.r)),
              elevation: buttonStyle.elevation,
              shadowColor: buttonStyle.shadowColor,
            ),
            child: _buildButtonContent(),
          );

    // Handle width constraints properly
    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: height ?? 48.h, child: button);
    } else if (width != null) {
      return SizedBox(width: width, height: height ?? 48.h, child: button);
    } else {
      return SizedBox(height: height ?? 48.h, child: button);
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.h,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(style == CustomButtonStyle.primary ? Colors.white : ColorManager.mainColor)),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: 8.w),
          BuildText(txt: text, fontSize: fontSize ?? 16, color: textColor ?? _getButtonStyle().textColor, fontWeight: fontWeight ?? FontWeight.w600),
        ],
      );
    }

    return BuildText(txt: text, fontSize: fontSize ?? 16, color: textColor ?? _getButtonStyle().textColor, fontWeight: fontWeight ?? FontWeight.w600);
  }

  _ButtonStyleData _getButtonStyle() {
    switch (style) {
      case CustomButtonStyle.primary:
        return _ButtonStyleData(backgroundColor: backgroundColor ?? ColorManager.mainColor, textColor: textColor ?? Colors.white, borderColor: borderColor ?? ColorManager.mainColor, elevation: 2, shadowColor: ColorManager.mainColor.withValues(alpha: 0.3));
      case CustomButtonStyle.secondary:
        return _ButtonStyleData(backgroundColor: backgroundColor ?? ColorManager.disableTextColor, textColor: textColor ?? ColorManager.mainColor, borderColor: borderColor ?? ColorManager.disableTextColor, elevation: 0, shadowColor: Colors.transparent);
      case CustomButtonStyle.success:
        return _ButtonStyleData(backgroundColor: backgroundColor ?? ColorManager.mainColor, textColor: textColor ?? Colors.white, borderColor: borderColor ?? ColorManager.mainColor, elevation: 2, shadowColor: ColorManager.mainColor.withValues(alpha: 0.3));
      case CustomButtonStyle.danger:
        return _ButtonStyleData(backgroundColor: backgroundColor ?? ColorManager.mainColor, textColor: textColor ?? Colors.white, borderColor: borderColor ?? ColorManager.mainColor, elevation: 2, shadowColor: ColorManager.mainColor.withValues(alpha: 0.3));
      case CustomButtonStyle.warning:
        return _ButtonStyleData(backgroundColor: backgroundColor ?? ColorManager.warningColor, textColor: textColor ?? Colors.white, borderColor: borderColor ?? ColorManager.warningColor, elevation: 2, shadowColor: ColorManager.warningColor.withValues(alpha: 0.3));
    }
  }
}

class _ButtonStyleData {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double elevation;
  final Color shadowColor;

  _ButtonStyleData({required this.backgroundColor, required this.textColor, required this.borderColor, required this.elevation, required this.shadowColor});
}

enum CustomButtonStyle { primary, secondary, success, danger, warning }

// Predefined button styles
class CustomButtonStyles {
  static CustomButton primary({required String text, VoidCallback? onPressed, bool isLoading = false, Widget? icon, bool isFullWidth = false}) {
    return CustomButton(text: text, onPressed: onPressed, isLoading: isLoading, style: CustomButtonStyle.primary, icon: icon, isFullWidth: isFullWidth);
  }

  static CustomButton secondary({required String text, VoidCallback? onPressed, bool isLoading = false, Widget? icon, bool isFullWidth = false}) {
    return CustomButton(text: text, onPressed: onPressed, isLoading: isLoading, style: CustomButtonStyle.secondary, icon: icon, isFullWidth: isFullWidth);
  }

  static CustomButton success({required String text, VoidCallback? onPressed, bool isLoading = false, Widget? icon, bool isFullWidth = false}) {
    return CustomButton(text: text, onPressed: onPressed, isLoading: isLoading, style: CustomButtonStyle.success, icon: icon, isFullWidth: isFullWidth);
  }

  static CustomButton danger({required String text, VoidCallback? onPressed, bool isLoading = false, Widget? icon, bool isFullWidth = false}) {
    return CustomButton(text: text, onPressed: onPressed, isLoading: isLoading, style: CustomButtonStyle.danger, icon: icon, isFullWidth: isFullWidth);
  }

  static CustomButton outlined({required String text, VoidCallback? onPressed, bool isLoading = false, Widget? icon, bool isFullWidth = false, Color? borderColor, Color? textColor}) {
    return CustomButton(text: text, onPressed: onPressed, isLoading: isLoading, icon: icon, isOutlined: true, isFullWidth: isFullWidth, borderColor: borderColor, textColor: textColor);
  }
}
