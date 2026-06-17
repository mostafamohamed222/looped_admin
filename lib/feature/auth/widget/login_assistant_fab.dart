import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';
import 'package:looped_admin/feature/auth/widget/looped_o_ring.dart';

class LoginAssistantFab extends StatelessWidget {
  const LoginAssistantFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Material(
        elevation: 6,
        shadowColor: LoginColors.fabBlue.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        color: LoginColors.fabBlue,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {},
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Center(child: LoopedORing(size: 26)),
          ),
        ),
      ),
    );
  }
}
