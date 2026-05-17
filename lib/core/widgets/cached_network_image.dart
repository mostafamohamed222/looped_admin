import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/color_manager.dart';


class CachedNetWokImageWidget extends StatelessWidget {
  const CachedNetWokImageWidget
      ({super.key, required this.url, required this.height,
    required this.width, this.boxFit, this.errorWidget,});
  final String url;
  final double height;
  final double width;
  final Widget? errorWidget;
  final BoxFit? boxFit;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width.w,
      height: height.h,
      cacheKey: url,
      // progressIndicatorBuilder: (context, url, downloadProgress) => ShimmerLoadingItemBuilder(width: width, height: height),
      fit: boxFit ?? BoxFit.cover,
      alignment: Alignment.topCenter,
      errorWidget: (context, url, error) => errorWidget??Icon(Icons.image_not_supported_outlined, color: ColorManager.redColor),
    );
  }
}
