import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/core/widgets/build_text.dart';
import 'package:looped_admin/core/widget/custom_button.dart';

class CustomDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final CustomDialogType type;

  const CustomDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.actions,
    this.barrierDismissible = true,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.icon,
    this.type = CustomDialogType.info,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor ?? ColorManager.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              icon!,
              SizedBox(height: 16.h),
            ] else if (type != CustomDialogType.info) ...[
              _buildTypeIcon(),
              SizedBox(height: 16.h),
            ],
            
            // Title
            if (title != null) ...[
                             BuildText(
                 txt: title!,
                 fontSize: 20,
                 fontWeight: FontWeight.w700,
                 color: ColorManager.mainColor,
                 textAlign: TextAlign.center,
               ),
              SizedBox(height: 8.h),
            ],
            
            // Message
            if (message != null) ...[
                             BuildText(
                 txt: message!,
                 fontSize: 16,
                 color: ColorManager.mainColor,
                 textAlign: TextAlign.center,
                 maxLines: 10,
               ),
              SizedBox(height: 16.h),
            ],
            
            // Custom content
            if (content != null) ...[
              content!,
              SizedBox(height: 16.h),
            ],
            
            // Actions
            if (actions != null) ...[
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (type) {
      case CustomDialogType.success:
        iconData = Icons.check_circle_outline;
        iconColor = ColorManager.successColor;
        break;
      case CustomDialogType.error:
        iconData = Icons.error_outline;
        iconColor = ColorManager.mainColor;
        break;
      case CustomDialogType.warning:
        iconData = Icons.warning_amber_outlined;
        iconColor = ColorManager.warningColor;
        break;
      case CustomDialogType.info:
        iconData = Icons.info_outline;
        iconColor = ColorManager.mainColor;
        break;
    }
    
    return Icon(
      iconData,
      size: 48.w,
      color: iconColor,
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    Widget? icon,
    CustomDialogType type = CustomDialogType.info,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        padding: padding,
        icon: icon,
        type: type,
      ),
    );
  }
}

enum CustomDialogType {
  info,
  success,
  error,
  warning,
}

// Predefined dialog styles
class CustomDialogStyles {
  static Future<T?> alert<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
    CustomDialogType type = CustomDialogType.info,
  }) {
    return CustomDialog.show(
      context: context,
      title: title,
      message: message,
      type: type,
      actions: [
        CustomButton(
          text: confirmText ?? 'OK',
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
          style: CustomButtonStyle.primary,
          isFullWidth: true,
        ),
      ],
    );
  }

  static Future<T?> confirmation<T>({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    CustomDialogType type = CustomDialogType.info,
  }) {
    return CustomDialog.show(
      context: context,
      title: title,
      message: message,
      type: type,
      actions: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: cancelText,
                onPressed: () {
                  Navigator.pop(context);
                  onCancel?.call();
                },
                style: CustomButtonStyle.secondary,
              ),
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
    );
  }

  static Future<T?> success<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return alert(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      onConfirm: onConfirm,
      type: CustomDialogType.success,
    );
  }

  static Future<T?> error<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return alert(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      onConfirm: onConfirm,
      type: CustomDialogType.error,
    );
  }

  static Future<T?> warning<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return alert(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      onConfirm: onConfirm,
      type: CustomDialogType.warning,
    );
  }

  static Future<T?> form<T>({
    required BuildContext context,
    required String title,
    required Widget form,
    required String submitText,
    required VoidCallback onSubmit,
    String? cancelText,
    bool isLoading = false,
  }) {
    return CustomDialog.show(
      context: context,
      title: title,
      content: form,
      actions: [
        if (cancelText != null) ...[
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: cancelText,
                  onPressed: () => Navigator.pop(context),
                  style: CustomButtonStyle.secondary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  text: submitText,
                  onPressed: isLoading ? null : () {
                    Navigator.pop(context);
                    onSubmit();
                  },
                  isLoading: isLoading,
                  style: CustomButtonStyle.primary,
                ),
              ),
            ],
          ),
        ] else ...[
          CustomButton(
            text: submitText,
            onPressed: isLoading ? null : () {
              Navigator.pop(context);
              onSubmit();
            },
            isLoading: isLoading,
            style: CustomButtonStyle.primary,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }
}
