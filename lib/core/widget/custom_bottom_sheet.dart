import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/core/widget/custom_button.dart';
import 'package:looped_admin/core/widgets/build_text.dart';

class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? height;
  final double? maxHeight;
  final bool isScrollControlled;
  final bool isDismissible;
  final bool enableDrag;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? header;
  final List<Widget>? actions;
  final VoidCallback? onClose;

  const CustomBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.height,
    this.maxHeight,
    this.isScrollControlled = false,
    this.isDismissible = true,
    this.enableDrag = true,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.header,
    this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: height,
        constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
        decoration: BoxDecoration(
          color: backgroundColor ?? ColorManager.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius ?? 20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
            ),

            // Header
            if (header != null || title != null || actions != null) _buildHeader(),

            // Content
            Flexible(
              child: Padding(padding: padding ?? EdgeInsets.all(20.w), child: child),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          if (header != null)
            Expanded(child: header!)
          else if (title != null)
            Expanded(
              child: BuildText(txt: title!, fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[800], textAlign: TextAlign.left),
            )
          else
            const Spacer(),

          if (actions != null) ...[...actions!, SizedBox(width: 8.w)],

          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(Icons.close, color: Colors.grey[600]),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
            ),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double? height,
    double? maxHeight,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    Widget? header,
    List<Widget>? actions,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(title: title, height: height, maxHeight: maxHeight, backgroundColor: backgroundColor, borderRadius: borderRadius, padding: padding, header: header, actions: actions, onClose: onClose ?? () => Navigator.pop(context), child: child),
    );
  }
}

// Predefined bottom sheet styles
class CustomBottomSheetStyles {
  static Future<T?> confirmation<T>({required BuildContext context, required String title, required String message, required String confirmText, required String cancelText, required VoidCallback onConfirm, VoidCallback? onCancel, bool isDestructive = false}) {
    return CustomBottomSheet.show(
      context: context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BuildText(txt: message, fontSize: 16, color: Colors.grey[700], textAlign: TextAlign.center),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(text: cancelText, onPressed: onCancel ?? () => Navigator.pop(context), style: CustomButtonStyle.secondary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  text: confirmText,
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: isDestructive ? CustomButtonStyle.danger : CustomButtonStyle.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<T?> actionSheet<T>({required BuildContext context, required String title, required List<ActionSheetItem> items, String? cancelText}) {
    return CustomBottomSheet.show(
      context: context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...items.map((item) => _buildActionItem(context, item)),
          if (cancelText != null) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: CustomButton(text: cancelText, onPressed: () => Navigator.pop(context), style: CustomButtonStyle.secondary),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildActionItem(BuildContext context, ActionSheetItem item) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      child: CustomButton(
        text: item.title,
        onPressed: () {
          Navigator.pop(context);
          item.onTap();
        },
        icon: item.icon,
        style: item.isDestructive ? CustomButtonStyle.danger : CustomButtonStyle.secondary,
        textColor: item.isDestructive ? Colors.red : null,
      ),
    );
  }

  static Future<T?> form<T>({required BuildContext context, required String title, required Widget form, required String submitText, required VoidCallback onSubmit, bool isLoading = false, String? cancelText}) {
    return CustomBottomSheet.show(
      context: context,
      title: title,
      isScrollControlled: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          form,
          SizedBox(height: 24.h),
          Row(
            children: [
              if (cancelText != null) ...[
                Expanded(
                  child: CustomButton(text: cancelText, onPressed: () => Navigator.pop(context), style: CustomButtonStyle.secondary),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: CustomButton(text: submitText, onPressed: isLoading ? null : onSubmit, isLoading: isLoading, style: CustomButtonStyle.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionSheetItem {
  final String title;
  final Widget? icon;
  final VoidCallback onTap;
  final bool isDestructive;

  ActionSheetItem({required this.title, this.icon, required this.onTap, this.isDestructive = false});
}
