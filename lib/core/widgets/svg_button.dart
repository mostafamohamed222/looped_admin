import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SVGButton extends StatelessWidget {
  final String svgPath;
  final Color? color;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SVGButton(
       this.svgPath,
      {super.key,
      this.color,
      this.onTap,
      this.width,
      this.height, this.fit=BoxFit.contain,});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        svgPath,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
        fit: fit,
        width: width,
        height: height,
      ),
    );
  }
}
