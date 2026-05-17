import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/color_manager.dart';
import 'build_text.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  bool _showTitle = false;
  bool _showDescription = false;
  bool _showFeatures = false;

  @override
  void initState() {
    super.initState();
    // Show title after 300ms
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showTitle = true);
    });
    // Show description after 500ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showDescription = true);
    });
    // Show features after 700ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showFeatures = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.whiteColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon Container
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.5 + (value * 0.5),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          ColorManager.skyColor,
                          ColorManager.mainColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.skyColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: ColorManager.mainColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      size: 80.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                40.verticalSpace,
                
                // Title
                AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Transform.translate(
                    offset: Offset(0, _showTitle ? 0 : 30),
                    child: BuildText(
                      txt: "Coming Soon",
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: ColorManager.mainColor,
                    ),
                  ),
                ),
                
                20.verticalSpace,
                
                // Description
                AnimatedOpacity(
                  opacity: _showDescription ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Transform.translate(
                    offset: Offset(0, _showDescription ? 0 : 30),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        "Working on feature",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: ColorManager.grayTextColor,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                
                50.verticalSpace,
                
                // Features List
                AnimatedOpacity(
                  opacity: _showFeatures ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: ColorManager.lightGreyColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: ColorManager.disableTextColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          icon: Icons.speed_rounded,
                          text: "High Performance",
                        ),
                        16.verticalSpace,
                        _buildFeatureItem(
                          icon: Icons.security_rounded,
                          text: "Security Updates",
                        ),
                        16.verticalSpace,
                        _buildFeatureItem(
                          icon: Icons.auto_awesome_rounded,
                          text: "User Experience",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: ColorManager.skyColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: ColorManager.mainColor,
            size: 24.sp,
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorManager.mainColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}