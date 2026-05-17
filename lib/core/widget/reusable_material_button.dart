import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/core/widgets/build_text.dart';

class ReusableMaterialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final bool isLoading;
  final bool isEnabled;
  final ReusableButtonStyle style;
  final ReusableButtonShape shape;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ReusableMaterialButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.isLoading = false,
    this.isEnabled = true,
    this.style = ReusableButtonStyle.primary,
    this.shape = ReusableButtonShape.rounded,
    this.fontSize,
    this.fontWeight,
  }) : assert(child != null || text != null, 'Either child or text must be provided');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: MaterialButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        padding: padding ?? _getDefaultPadding(),
        minWidth: 0,
        height: 0,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: elevation ?? _getDefaultElevation(),
        color: backgroundColor ?? _getDefaultBackgroundColor(),
        disabledColor: ColorManager.disableTextColor,
        shape: _getButtonShape(),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            style == ReusableButtonStyle.primary ? Colors.white : ColorManager.mainColor,
          ),
        ),
      );
    }

    if (child != null) {
      return child!;
    }

    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor ?? textColor ?? _getDefaultTextColor(),
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          BuildText(
            txt: text!,
            fontSize: fontSize ?? 14,
            fontWeight: fontWeight ?? FontWeight.w500,
            color: textColor ?? _getDefaultTextColor(),
          ),
        ],
      );
    }

    if (icon != null) {
      return Icon(
        icon,
        color: iconColor ?? textColor ?? _getDefaultTextColor(),
        size: 20.sp,
      );
    }

    return BuildText(
      txt: text!,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: textColor ?? _getDefaultTextColor(),
    );
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (style) {
      case ReusableButtonStyle.primary:
      case ReusableButtonStyle.secondary:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
      case ReusableButtonStyle.text:
      case ReusableButtonStyle.icon:
        return EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h);
    }
  }

  double _getDefaultElevation() {
    switch (style) {
      case ReusableButtonStyle.primary:
        return 2;
      case ReusableButtonStyle.secondary:
      case ReusableButtonStyle.text:
      case ReusableButtonStyle.icon:
        return 0;
    }
  }

  Color _getDefaultBackgroundColor() {
    switch (style) {
      case ReusableButtonStyle.primary:
        return ColorManager.mainColor;
      case ReusableButtonStyle.secondary:
      case ReusableButtonStyle.text:
      case ReusableButtonStyle.icon:
        return Colors.transparent;
    }
  }

  Color _getDefaultTextColor() {
    switch (style) {
      case ReusableButtonStyle.primary:
        return Colors.white;
      case ReusableButtonStyle.secondary:
      case ReusableButtonStyle.text:
        return ColorManager.mainColor;
      case ReusableButtonStyle.icon:
        return ColorManager.mainColor;
    }
  }

  OutlinedBorder _getButtonShape() {
    final radius = borderRadius ?? _getDefaultBorderRadius();
    
    switch (shape) {
      case ReusableButtonShape.rounded:
        return RoundedRectangleBorder(borderRadius: radius);
      case ReusableButtonShape.circular:
        return const CircleBorder();
      case ReusableButtonShape.rectangular:
        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r));
      case ReusableButtonShape.pill:
        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r));
    }
  }

  BorderRadius _getDefaultBorderRadius() {
    switch (shape) {
      case ReusableButtonShape.rounded:
        return BorderRadius.circular(12.r);
      case ReusableButtonShape.circular:
        return BorderRadius.circular(100.r);
      case ReusableButtonShape.rectangular:
        return BorderRadius.circular(4.r);
      case ReusableButtonShape.pill:
        return BorderRadius.circular(100.r);
    }
  }
}

enum ReusableButtonStyle {
  primary,
  secondary,
  text,
  icon,
}

enum ReusableButtonShape {
  rounded,
  circular,
  rectangular,
  pill,
}

// Convenience constructors for common use cases
extension ReusableMaterialButtonExtensions on ReusableMaterialButton {
  // Primary button with text
  static ReusableMaterialButton primary({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    double? width,
    double? height,
    bool isLoading = false,
    bool isEnabled = true,
    Key? key,
  }) {
    return ReusableMaterialButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      width: width,
      height: height,
      isLoading: isLoading,
      isEnabled: isEnabled,
      style: ReusableButtonStyle.primary,
    );
  }

  // Secondary button with text
  static ReusableMaterialButton secondary({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    double? width,
    double? height,
    bool isLoading = false,
    bool isEnabled = true,
    Key? key,
  }) {
    return ReusableMaterialButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      width: width,
      height: height,
      isLoading: isLoading,
      isEnabled: isEnabled,
      style: ReusableButtonStyle.secondary,
    );
  }

  // Text button
  static ReusableMaterialButton text({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    Color? textColor,
    bool isLoading = false,
    bool isEnabled = true,
    Key? key,
  }) {
    return ReusableMaterialButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      textColor: textColor,
      isLoading: isLoading,
      isEnabled: isEnabled,
      style: ReusableButtonStyle.text,
    );
  }

  // Icon button
  static ReusableMaterialButton icon({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    bool isLoading = false,
    bool isEnabled = true,
    Key? key,
  }) {
    return ReusableMaterialButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      width: size,
      height: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      style: ReusableButtonStyle.icon,
      shape: ReusableButtonShape.circular,
    );
  }

  // Card button (for card-like interactions)
  static ReusableMaterialButton card({
    required Widget child,
    required VoidCallback? onPressed,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    double? elevation,
    bool isLoading = false,
    bool isEnabled = true,
    Key? key,
  }) {
    return ReusableMaterialButton(
      key: key,
      onPressed: onPressed,
      padding: padding ?? EdgeInsets.all(16.w),
      borderRadius: borderRadius ?? BorderRadius.circular(12.r),
      elevation: elevation ?? 0,
      backgroundColor: Colors.white,
      isLoading: isLoading,
      isEnabled: isEnabled,
      style: ReusableButtonStyle.secondary,
      child: child,
    );
  }
}
