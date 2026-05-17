import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:looped_admin/core/di/injection.dart' as di;
import 'package:looped_admin/core/widgets/app_locale_sync.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:looped_admin/feature/nav_bar/cubit/app_shell_nav_cubit.dart';
import 'package:looped_admin/feature/settings/cubit/app_locale_cubit.dart';
import 'package:looped_admin/core/res/app_routes.dart';
import 'package:looped_admin/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await di.initDi();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      saveLocale: true,
      useOnlyLangCode: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppShellNavCubit>.value(
            value: di.getIt<AppShellNavCubit>(),
          ),
          BlocProvider<AppLocaleCubit>.value(
            value: di.getIt<AppLocaleCubit>(),
          ),
          BlocProvider<AuthCubit>.value(
            value: di.getIt<AuthCubit>(),
          ),
        ],
        child: const AppLocaleSync(child: MyApp()),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLocaleCubit, Locale>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, _) {
        return Builder(
          builder: (context) {
            final locale = context.locale;
            final dir = locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorManager.navigatorKey,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              initialRoute: Routes.loginCompanyScreen,
              title: 'app_title'.tr(),
              locale: locale,
              localizationsDelegates: [
                ...context.localizationDelegates,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: context.supportedLocales,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF3B82F6),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              home: const LoginPage(),
              builder: (context, child) {
                return Directionality(
                  textDirection: dir,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
    );
  }
}
