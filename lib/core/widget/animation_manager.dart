import 'package:flutter/material.dart';

/// Centralized animation manager for consistent animations across the app
class AnimationManager {
  // Singleton pattern
  static final AnimationManager _instance = AnimationManager._internal();
  factory AnimationManager() => _instance;
  AnimationManager._internal();

  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Animation curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  /// 1. FADE IN/OUT Animation
  static Animation<double> fadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: easeInOut,
    ));
  }

  /// 2. SLIDE FROM RIGHT Animation
  static Animation<Offset> slideFromRightAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: easeOutCubic,
    ));
  }

  /// 3. SLIDE FROM LEFT Animation
  static Animation<Offset> slideFromLeftAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: easeOutCubic,
    ));
  }

  /// 4. SCALE UP Animation
  static Animation<double> scaleUpAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: easeOut,
    ));
  }

  /// 5. BOUNCE IN Animation
  static Animation<double> bounceInAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: bounceOut,
    ));
  }

  /// Helper method to create animation controller
  static AnimationController createController(TickerProvider vsync, {Duration? duration}) {
    return AnimationController(
      duration: duration ?? normal,
      vsync: vsync,
    );
  }

  /// Helper method to dispose animation controller
  static void disposeController(AnimationController? controller) {
    controller?.dispose();
  }

  /// Helper method to reset and start animation
  static void resetAndStart(AnimationController controller) {
    controller.reset();
    controller.forward();
  }

  /// Helper method to reverse animation
  static void reverse(AnimationController controller) {
    controller.reverse();
  }
}

/// Predefined animation widgets for common use cases
class AppAnimations {
  /// Fade in/out widget
  static Widget fadeInOut({
    required AnimationController controller,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: AnimationManager.fadeAnimation(controller),
      child: child,
    );
  }

  /// Slide from right widget
  static Widget slideFromRight({
    required AnimationController controller,
    required Widget child,
  }) {
    return SlideTransition(
      position: AnimationManager.slideFromRightAnimation(controller),
      child: child,
    );
  }

  /// Slide from left widget
  static Widget slideFromLeft({
    required AnimationController controller,
    required Widget child,
  }) {
    return SlideTransition(
      position: AnimationManager.slideFromLeftAnimation(controller),
      child: child,
    );
  }

  /// Scale up widget
  static Widget scaleUp({
    required AnimationController controller,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: AnimationManager.scaleUpAnimation(controller),
      child: child,
    );
  }

  /// Bounce in widget
  static Widget bounceIn({
    required AnimationController controller,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: AnimationManager.bounceInAnimation(controller),
      child: child,
    );
  }

  /// Combined fade and slide from right
  static Widget fadeSlideFromRight({
    required AnimationController controller,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: AnimationManager.fadeAnimation(controller),
      child: SlideTransition(
        position: AnimationManager.slideFromRightAnimation(controller),
        child: child,
      ),
    );
  }

  /// Combined fade and slide from left
  static Widget fadeSlideFromLeft({
    required AnimationController controller,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: AnimationManager.fadeAnimation(controller),
      child: SlideTransition(
        position: AnimationManager.slideFromLeftAnimation(controller),
        child: child,
      ),
    );
  }

  /// Combined fade and scale up
  static Widget fadeScaleUp({
    required AnimationController controller,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: AnimationManager.fadeAnimation(controller),
      child: ScaleTransition(
        scale: AnimationManager.scaleUpAnimation(controller),
        child: child,
      ),
    );
  }
}

/// Animation mixin for easy integration
mixin AnimationMixin<T extends StatefulWidget> on State<T> {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationManager.createController(this as TickerProvider);
    _fadeAnimation = AnimationManager.fadeAnimation(_animationController);
    _slideAnimation = AnimationManager.slideFromRightAnimation(_animationController);
    _scaleAnimation = AnimationManager.scaleUpAnimation(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    AnimationManager.disposeController(_animationController);
    super.dispose();
  }

  void resetAnimation() {
    AnimationManager.resetAndStart(_animationController);
  }

  void reverseAnimation() {
    AnimationManager.reverse(_animationController);
  }

  // Getter methods for animations
  AnimationController get controller => _animationController;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;
}
