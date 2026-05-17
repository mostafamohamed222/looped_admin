
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_cubit.dart';

import '../data_scource/local/objectbox_database/objectbox_helper.dart';
import '../data_scource/remote/dio_consumer.dart';
import '../res/app_routes.dart';
import 'package:looped_admin/feature/nav_bar/cubit/app_shell_nav_cubit.dart';
import 'package:looped_admin/feature/settings/cubit/app_locale_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDi() async {
  getIt.registerLazySingleton(
    () => NavigatorManager(),
  );

  getIt.registerLazySingleton(() => AppShellNavCubit());

  // Local storage
  final objectBox = await ObjectBoxHelper.create();
  getIt.registerSingleton(objectBox);
  

 // dio network
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton<DioConsumer>(() => DioConsumer(client: getIt()));

  getIt.registerLazySingleton(() => AppLocaleCubit(getIt<NavigatorManager>()));
  getIt.registerLazySingleton(() => AuthCubit());
}
