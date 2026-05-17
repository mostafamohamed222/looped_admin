import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/core/widgets/build_text.dart';

class ReusableScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool canPop;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? elevation;
  final Widget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior? drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;

  const ReusableScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.centerTitle = false,
    this.canPop = true,
    this.elevation = 0,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? ColorManager.backgroundColor,
      body: SafeArea(
        child: PopScope(
            canPop:canPop ,
            child: body),
      ),
      bottomNavigationBar: bottom,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior ?? DragStartBehavior.start,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
  }


}

// ==================== SCAFFOLD VARIANTS ====================

/// Scaffold with gradient background
class GradientScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Color> gradientColors;
  final bool centerTitle;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const GradientScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.gradientColors = const [ColorManager.mainColor, ColorManager.mainColor],
    this.centerTitle = false,
    this.elevation = 0,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ReusableScaffold(
        title: title,
        body: body,
        actions: actions,
        leading: leading,
        showBackButton: showBackButton,
        onBackPressed: onBackPressed,
        backgroundColor: Colors.transparent,
        centerTitle: centerTitle,
        elevation: elevation,
        bottom: bottom,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}

/// Scaffold with custom app bar styling
class CustomAppBarScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Color? titleColor;
  final bool centerTitle;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const CustomAppBarScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.appBarColor,
    this.titleColor,
    this.centerTitle = false,
    this.elevation = 0,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? ColorManager.backgroundColor,
      appBar: title != null ? AppBar(
        title: BuildText(
          txt: title!,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: titleColor ?? ColorManager.mainColor,
        ),
        backgroundColor: appBarColor ?? Colors.white,
        elevation: elevation,
        centerTitle: centerTitle,
        leading: _buildLeading(context),
        actions: actions,
        automaticallyImplyLeading: false,
      ) : null,
      body: body,
      bottomNavigationBar: bottom,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (!showBackButton) {
      return null;
    }

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: titleColor ?? ColorManager.mainColor,
      ),
      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
    );
  }
}

/// Scaffold with bottom navigation
class BottomNavScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? elevation;
  final PreferredSizeWidget bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const BottomNavScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.centerTitle = false,
    this.elevation = 0,
    required this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableScaffold(
      title: title,
      body: body,
      actions: actions,
      leading: leading,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      elevation: elevation,
      bottom: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// Scaffold with drawer
class DrawerScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? elevation;
  final Widget drawer;
  final Widget? endDrawer;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const DrawerScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.centerTitle = false,
    this.elevation = 0,
    required this.drawer,
    this.endDrawer,
    this.bottom,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableScaffold(
      title: title,
      body: body,
      actions: actions,
      leading: leading,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      elevation: elevation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottom: bottom,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
