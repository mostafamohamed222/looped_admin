import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:looped_admin/core/widget/reusable_material_button.dart';

class SVGButton extends StatelessWidget {
  final String svgPath;
  final Color? color;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SVGButton(
    this.svgPath, {
    super.key,
    this.color,
    this.onTap,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableMaterialButton(
      onPressed: onTap,
      width: width,
      height: height,
      padding: EdgeInsets.zero,
      child: SvgPicture.asset(
        svgPath,
        colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
        fit: fit,
        width: width,
        height: height,
      ),
    );
  }
}
