import 'package:flutter/material.dart';
import 'package:looped_admin/feature/auth/widget/login_colors.dart';

class LoginSessionLoading extends StatelessWidget {
  const LoginSessionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: LoginColors.navy,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
