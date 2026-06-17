import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';
import 'package:looped_admin/feature/auth/widget/looped_o_ring.dart';

class LoopedWordmark extends StatelessWidget {
  const LoopedWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: LoginColors.navy,
      letterSpacing: 0.2,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('L', style: style.copyWith(height: 1)),
        const SizedBox(width: 2),
        const LoopedORing(size: 28),
        Text('OPED', style: style.copyWith(height: 1)),
      ],
    );
  }
}
