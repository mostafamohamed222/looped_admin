import 'package:flutter/material.dart';

import 'cached_network_image.dart';

class CardImage extends StatelessWidget {
  const CardImage({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: CachedNetWokImageWidget(
        url:   '',
          width: 35,
          height: 35,
          boxFit: BoxFit.cover,
          errorWidget: Image.asset(
            "",
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
