import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/color_manager.dart';
import 'build_text.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.textWord,
    required this.buttonColor,
    required this.textColor,
    required this.onTap,
    this.fontSize,
    this.buttonWidth = 0,
    this.disable = false,
    this.marginNumber = 0,
    this.isLoading = false,
    this.buttonHeight = 0,
    this.isBoarder = false,
    this.isIcon = false,
  });

  final bool isBoarder;
  final String textWord;
  final Color textColor;
  final Color buttonColor;
  final VoidCallback onTap;
  final bool disable;
  final double? fontSize;
  final double buttonWidth;
  final double buttonHeight;
  final int marginNumber;
  final bool isLoading;
  final bool isIcon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disable || isLoading ? null : onTap,
      child: Container(
        // margin: const EdgeInsets.symmetric(horizontal: 16),
        width: buttonWidth == 0 ? double.infinity : buttonWidth,
        height: buttonHeight == 0 ? 50 : buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: disable || isLoading ? Colors.grey : buttonColor,
          border: isBoarder
              ? Border.all(color: ColorManager.mainColor, width: 2)
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isIcon)
                const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              if (isIcon)
              8.horizontalSpace,
              BuildText(
                txt: "$textWord ${isLoading ? "..." : ""}",
                fontSize: fontSize ?? 16,
                color: disable ? Colors.green : textColor,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
