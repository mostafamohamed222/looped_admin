import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/core/widgets/build_text.dart';

/// A reusable loading indicator widget with optional text display
class AppLoadingIndicator extends StatelessWidget {
  /// The text to display below the loading indicator (optional)
  final String? text;
  
  /// The size of the loading indicator
  final double size;
  
  /// The stroke width of the loading indicator
  final double strokeWidth;
  
  /// The color of the loading indicator
  final Color? color;
  
  /// The text style for the loading text
  final TextStyle? textStyle;
  
  /// The spacing between the indicator and text
  final double spacing;
  
  /// Whether to show the text
  final bool showText;

  const AppLoadingIndicator({
    super.key,
    this.text,
    this.size = 24.0,
    this.strokeWidth = 3.0,
    this.color,
    this.textStyle,
    this.spacing = 16.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size.w,
          height: size.w,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? ColorManager.mainColor,
            ),
            strokeWidth: strokeWidth,
          ),
        ),
        if (showText && text != null && text!.isNotEmpty) ...[
          SizedBox(height: spacing.h),
          BuildText(
            txt: text!,
            fontSize: textStyle?.fontSize ?? 16,
            fontWeight: textStyle?.fontWeight ?? FontWeight.w500,
            color: textStyle?.color ?? ColorManager.mainColor,
          ),
        ],
      ],
    );
  }
}

/// A loading indicator with a container wrapper
class AppLoadingIndicatorWithContainer extends StatelessWidget {
  /// The text to display below the loading indicator (optional)
  final String? text;
  
  /// The size of the loading indicator
  final double size;
  
  /// The stroke width of the loading indicator
  final double strokeWidth;
  
  /// The color of the loading indicator
  final Color? color;
  
  /// The text style for the loading text
  final TextStyle? textStyle;
  
  /// The spacing between the indicator and text
  final double spacing;
  
  /// Whether to show the text
  final bool showText;
  
  /// The container decoration
  final BoxDecoration? decoration;
  
  /// The container padding
  final EdgeInsetsGeometry? padding;
  
  /// The container margin
  final EdgeInsetsGeometry? margin;

  const AppLoadingIndicatorWithContainer({
    super.key,
    this.text,
    this.size = 24.0,
    this.strokeWidth = 3.0,
    this.color,
    this.textStyle,
    this.spacing = 16.0,
    this.showText = true,
    this.decoration,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: Center(
        child: AppLoadingIndicator(
          text: text,
          size: size,
          strokeWidth: strokeWidth,
          color: color,
          textStyle: textStyle,
          spacing: spacing,
          showText: showText,
        ),
      ),
    );
  }
}
