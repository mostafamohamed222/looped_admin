import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/color_manager.dart';

class BuildText extends StatelessWidget {
  const BuildText(
      {super.key,
      required this.txt,
      required this.fontSize,
      this.color = ColorManager.blackColor,
      this.fontWeight,
      this.textDirection,
      this.textAlign = TextAlign.center,
      this.maxLines = 4,
      this.decoration = false});
  final String txt;
  final double fontSize;
  final Color? color;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final bool decoration;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: "tajawal",
        fontSize: (fontSize).sp,
        color: color,
        decorationColor: color,
        fontWeight: fontWeight,
        letterSpacing: 0.0,
        decoration: decoration ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }
}
