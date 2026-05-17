import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/core/widgets/build_text.dart';

class ReusableAlertDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const ReusableAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.width,
    this.height,
    this.contentPadding,
    this.showCloseButton = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BuildText(
                        txt: title!,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.mainColor,
                      ),
                    ),
                    if (showCloseButton)
                      IconButton(
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: ColorManager.mainColor,
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Divider(
                  color: ColorManager.disableTextColor,
                  height: 1,
                ),
              ],
            )
          : null,
      content: content != null
          ? Container(
              width: width,
              height: height,
              padding: contentPadding ?? EdgeInsets.all(16.w),
              child: content!,
            )
          : null,
      actions: actions != null
          ? [
              ...actions!,
            ]
          : null,
    );
  }
}

// Extension for easy usage
extension ReusableAlertDialogExtensions on ReusableAlertDialog {
  static ReusableAlertDialog simple({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
    bool showCloseButton = false,
  }) {
    return ReusableAlertDialog(
      title: title,
      content: BuildText(
        txt: message,
        fontSize: 14,
        color: ColorManager.mainColor,
      ),
      actions: actionText != null
          ? [
              TextButton(
                onPressed: onAction,
                child: BuildText(
                  txt: actionText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.mainColor,
                ),
              ),
            ]
          : null,
      showCloseButton: showCloseButton,
    );
  }

  static ReusableAlertDialog confirmation({
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
  }) {
    return ReusableAlertDialog(
      title: title,
      content: BuildText(
        txt: message,
        fontSize: 14,
        color: ColorManager.mainColor,
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: BuildText(
            txt: cancelText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorManager.mainColor,
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: BuildText(
            txt: confirmText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: confirmColor ?? ColorManager.mainColor,
          ),
        ),
      ],
    );
  }

  static ReusableAlertDialog custom({
    String? title,
    required Widget content,
    List<Widget>? actions,
    double? width,
    double? height,
    EdgeInsetsGeometry? contentPadding,
    bool showCloseButton = false,
    VoidCallback? onClose,
  }) {
    return ReusableAlertDialog(
      title: title,
      content: content,
      actions: actions,
      width: width,
      height: height,
      contentPadding: contentPadding,
      showCloseButton: showCloseButton,
      onClose: onClose,
    );
  }
}

// Helper function to show the dialog
Future<T?> showReusableAlertDialog<T>({
  required BuildContext context,
  required ReusableAlertDialog dialog,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => dialog,
  );
}
