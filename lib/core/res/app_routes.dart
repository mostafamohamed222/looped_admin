import 'dart:developer';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/presentation/Inventory_main_screen.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/warehouse_transfer_main_screen.dart';
import 'package:looped_admin/feature/nav_bar/presentation/nav_bar.dart';
import 'package:looped_admin/login_page.dart';

import '../di/injection.dart';

class Routes {
  static const String initialRoute = "/";
  static const String loginCompanyScreen = "/login";
  static const String navBarScreen = "/app-shell";
  static const String inventoryMainScreen = "/inventory-main-screen";
  static const String warehouseTransferMainScreen =
      "/warehouse-transfer-main-screen";
}

class AppRoutes {
  static const initialRouteName = Routes.loginCompanyScreen;
  static final _routeNameNotifier = ValueNotifier<String>(initialRouteName);

  /// Reactive version for [currentRouteName].
  static ValueNotifier<String> get routeNameNotifier => _routeNameNotifier;

  /// The current route id. If the current route
  /// is reached in a way other than [Navigator.toNamed],
  /// this id is stale.
  static String get routeName => _routeNameNotifier.value;

  static void onRouteChanged(String? routeName) {
    _routeNameNotifier.value = routeName ?? 'Error';

    log(
      _routeNameNotifier.value,
      name: 'Route',
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.loginCompanyScreen:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case Routes.navBarScreen:
        return MaterialPageRoute(builder: (context) => const AppShellPage());
      case Routes.inventoryMainScreen:
        return MaterialPageRoute(builder: (context) => const InventoryMainScreen());
      case Routes.warehouseTransferMainScreen:
        return MaterialPageRoute(
          builder: (context) => const WarehouseTransferMainScreen(),
        );
      default:
        return undefinedRoute();
    }
  }

  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('common_route_not_found'.tr()),
        ),
      ),
    );
  }
}

class NavigatorManager {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<T?> pushReplacementNamed<T extends Object?>(String routeName) {
    AppRoutes.onRouteChanged(routeName);
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  Future<T?> pushNamed<T extends Object?>(String routeName) {
    AppRoutes.onRouteChanged(routeName);
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  void popUntilFirstRoute() {
    return navigatorKey.currentState!.popUntil((route) {
      if (!route.isFirst) return false;
      AppRoutes.onRouteChanged(route.settings.name);
      return route.isFirst;
    });
  }

  //! this method not passing result back
  void pop<T extends Object?>([T? result]) {
    var predicate = false;
    return navigatorKey.currentState!.popUntil((route) {
      AppRoutes.onRouteChanged(route.settings.name);
      final value = predicate;
      predicate = true;
      return value;
    });
  }

  /// If no drawer is open, it will pop the current route.
  void closeDrawer<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  Future<dynamic> navigateAndFinish(String routeName) {
    AppRoutes.onRouteChanged(routeName);
    return navigatorKey.currentState!
        .pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  }
}

NavigatorManager get navigatorManager => getIt<NavigatorManager>();
BuildContext get currentContext =>
    navigatorManager.navigatorKey.currentState!.context;

class CoolTransitionPage<T> extends PageRouteBuilder<T> {
  final Widget child;
  CoolTransitionPage({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: animation, curve: Curves.fastOutSlowIn));
            var rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.ease));
            var opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeIn));
            return ScaleTransition(
              scale: scaleAnimation,
              child: RotationTransition(
                turns: rotationAnimation,
                child: FadeTransition(
                  opacity: opacityAnimation,
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}

class SlideTransitionPage<T> extends PageRouteBuilder<T> {
  final Widget child;
  SlideTransitionPage({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
