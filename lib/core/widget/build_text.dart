import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildText extends StatelessWidget {
  const BuildText(
      {super.key,
      required this.txt,
      required this.fontSize,
      this.color = Colors.black,
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
      textDirection: textDirection,
      style: TextStyle(
          // height: ConstantsManager.textHeight,
          fontSize: (fontSize).sp,
          color: color,
          decorationColor: color,
          fontWeight: fontWeight,
          letterSpacing: 0.0,
          // height: (1.6).h,

          decoration:
              decoration ? TextDecoration.underline : TextDecoration.none),
    );
  }
}
