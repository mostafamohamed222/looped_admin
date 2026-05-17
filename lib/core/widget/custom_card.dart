// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/core/widget/reusable_material_button.dart';
import 'package:looped_admin/core/widgets/build_text.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final bool showBorder;
  final VoidCallback? onTap;
  final bool isLoading;
  final CustomCardStyle style;

  const CustomCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.elevation,
    this.showBorder = true,
    this.onTap,
    this.isLoading = false,
    this.style = CustomCardStyle.defaultStyle,
  });

  @override
  Widget build(BuildContext context) {
    final cardStyle = _getCardStyle();
    
    Widget cardContent = Container(
      margin: margin ?? EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? cardStyle.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? cardStyle.borderRadius),
        border: showBorder ? Border.all(
          color: borderColor ?? cardStyle.borderColor,
          width: 1,
        ) : null,
        boxShadow: (elevation != null || cardStyle.elevation > 0) ? [
          BoxShadow(
            color: ColorManager.mainColor.withValues(alpha: 0.1),
            blurRadius: elevation ?? cardStyle.elevation,
            offset: Offset(0, (elevation ?? cardStyle.elevation) / 2),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (title != null || leading != null || actions != null)
            _buildHeader(),
          
          // Content
          Padding(
            padding: padding ?? EdgeInsets.all(16.w),
            child: isLoading ? _buildLoadingContent() : child,
          ),
        ],
      ),
    );

    if (onTap != null) {
      cardContent = ReusableMaterialButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(borderRadius ?? cardStyle.borderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorManager.disableTextColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: 12.w),
          ],
          
          if (title != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuildText(
                    txt: title!,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.mainColor,
                    textAlign: TextAlign.left,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    BuildText(
                      txt: subtitle!,
                      fontSize: 14,
                      color: ColorManager.mainColor,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ],
              ),
            )
          else
            const Spacer(),
          
          if (actions != null) ...[
            ...actions!,
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        Container(
          height: 16.h,
          decoration: BoxDecoration(
            color: ColorManager.disableTextColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 12.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorManager.disableTextColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 12.h,
          width: 200.w,
          decoration: BoxDecoration(
            color: ColorManager.disableTextColor,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
      ],
    );
  }

  _CardStyleData _getCardStyle() {
    switch (style) {
      case CustomCardStyle.defaultStyle:
        return _CardStyleData(
          backgroundColor: ColorManager.whiteColor,
          borderColor: ColorManager.disableTextColor,
          borderRadius: 12,
          elevation: 2,
        );
      case CustomCardStyle.elevated:
        return _CardStyleData(
          backgroundColor: ColorManager.whiteColor,
          borderColor: Colors.transparent,
          borderRadius: 16,
          elevation: 8,
        );
      case CustomCardStyle.outlined:
        return _CardStyleData(
          backgroundColor: Colors.transparent,
          borderColor: ColorManager.disableTextColor,
          borderRadius: 12,
          elevation: 0,
        );
      case CustomCardStyle.flat:
        return _CardStyleData(
          backgroundColor: ColorManager.whiteColor,
          borderColor: ColorManager.disableTextColor,
          borderRadius: 8,
          elevation: 0,
        );
    }
  }
}

class _CardStyleData {
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double elevation;

  _CardStyleData({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.elevation,
  });
}

enum CustomCardStyle {
  defaultStyle,
  elevated,
  outlined,
  flat,
}

// Predefined card styles
class CustomCardStyles {
  static CustomCard info({
    required Widget child,
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return CustomCard(
      title: title,
      subtitle: subtitle,
      leading: leading ?? Icon(Icons.info_outline, color: ColorManager.mainColor),
      actions: actions,
      onTap: onTap,
      isLoading: isLoading,
      style: CustomCardStyle.defaultStyle,
      borderColor: ColorManager.mainColor.withValues(alpha: 0.3),
      child: child,
    );
  }

  static CustomCard success({
    required Widget child,
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return CustomCard(
      title: title,
      subtitle: subtitle,
      leading: leading ?? Icon(Icons.check_circle_outline, color: ColorManager.mainColor),
      actions: actions,
      onTap: onTap,
      isLoading: isLoading,
      style: CustomCardStyle.defaultStyle,
      borderColor: ColorManager.mainColor.withValues(alpha: 0.3),
      child: child,
    );
  }

  static CustomCard warning({
    required Widget child,
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return CustomCard(
      title: title,
      subtitle: subtitle,
      leading: leading ?? Icon(Icons.warning_amber_outlined, color: ColorManager.mainColor),
      actions: actions,
      onTap: onTap,
      isLoading: isLoading,
      style: CustomCardStyle.defaultStyle,
      borderColor: ColorManager.mainColor.withValues(alpha: 0.3),
      child: child,
    );
  }

  static CustomCard error({
    required Widget child,
    String? title,
    String? subtitle,
    Widget? leading,
    List<Widget>? actions,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return CustomCard(
      title: title,
      subtitle: subtitle,
      leading: leading ?? Icon(Icons.error_outline, color: ColorManager.mainColor),
      actions: actions,
      onTap: onTap,
      isLoading: isLoading,
      style: CustomCardStyle.defaultStyle,
      borderColor: ColorManager.mainColor.withValues(alpha: 0.3),
      child: child,
    );
  }

  static CustomCard stat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      style: CustomCardStyle.elevated,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuildText(
                  txt: title,
                  fontSize: 14,
                  color: ColorManager.mainColor,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 4.h),
                BuildText(
                  txt: value,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.mainColor,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
