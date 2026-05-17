import 'package:flutter/material.dart';
import 'package:looped_admin/core/widget/animation_manager.dart';

/// Animated container with fade and scale effect
class AnimatedFadeScale extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  final bool show;

  const AnimatedFadeScale({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.show = true,
  });

  @override
  State<AnimatedFadeScale> createState() => _AnimatedFadeScaleState();
}

class _AnimatedFadeScaleState extends State<AnimatedFadeScale>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationManager.createController(
      this,
      duration: widget.duration ?? AnimationManager.normal,
    );

    
    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedFadeScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    AnimationManager.disposeController(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeScaleUp(
      controller: _controller,
      child: widget.child,
    );
  }
}

/// Animated container with slide effect
class AnimatedSlide extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final SlideDirection direction;
  final bool show;

  const AnimatedSlide({
    super.key,
    required this.child,
    this.duration,
    this.direction = SlideDirection.fromRight,
    this.show = true,
  });

  @override
  State<AnimatedSlide> createState() => _AnimatedSlideState();
}

class _AnimatedSlideState extends State<AnimatedSlide>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationManager.createController(
      this,
      duration: widget.duration ?? AnimationManager.normal,
    );

    
    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    AnimationManager.disposeController(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slideAnimation = widget.direction == SlideDirection.fromRight
        ? AnimationManager.slideFromRightAnimation(_controller)
        : AnimationManager.slideFromLeftAnimation(_controller);
    
    return SlideTransition(
      position: slideAnimation,
      child: widget.child,
    );
  }
}

/// Animated container with bounce effect
class AnimatedBounce extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final bool show;

  const AnimatedBounce({
    super.key,
    required this.child,
    this.duration,
    this.show = true,
  });

  @override
  State<AnimatedBounce> createState() => _AnimatedBounceState();
}

class _AnimatedBounceState extends State<AnimatedBounce>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationManager.createController(
      this,
      duration: widget.duration ?? AnimationManager.slow,
    );

    
    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    AnimationManager.disposeController(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimations.bounceIn(
      controller: _controller,
      child: widget.child,
    );
  }
}

/// Animated container with fade effect
class AnimatedFade extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final bool show;

  const AnimatedFade({
    super.key,
    required this.child,
    this.duration,
    this.show = true,
  });

  @override
  State<AnimatedFade> createState() => _AnimatedFadeState();
}

class _AnimatedFadeState extends State<AnimatedFade>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationManager.createController(
      this,
      duration: widget.duration ?? AnimationManager.normal,
    );

    
    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    AnimationManager.disposeController(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeInOut(
      controller: _controller,
      child: widget.child,
    );
  }
}

/// Slide direction enum
enum SlideDirection {
  fromRight,
  fromLeft,
}
