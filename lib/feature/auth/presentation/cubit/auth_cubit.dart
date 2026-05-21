import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/data_scource/local/objectbox_database/objectbox_helper.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/core/data_scource/remote/end_points.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/res/app_routes.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static final AuthCubit _instance =
      BlocProvider.of(getIt<NavigatorManager>().navigatorKey.currentContext!);

  static AuthCubit get instance => _instance;
  final DioConsumer dioConsumer = getIt<DioConsumer>();

  bool isPasswordVisible = true;

  void changePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(AuthChangePasswordVisibilityState());
  }

  bool isRememberMe = false;

  void changeRememberMe() {
    isRememberMe = !isRememberMe;
    emit(AuthChangeRememberMeState());
  }

  void setRememberMe(bool value) {
    if (isRememberMe == value) return;
    isRememberMe = value;
    emit(AuthChangeRememberMeState());
  }

  /// يبني `https://{slug}.saas.loopedsol.com` — يقبل الـ slug فقط أو رابط/Host كامل.
  static String normalizeTenantDomain(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return '';
    if (s.contains('://')) {
      final uri = Uri.tryParse(s);
      if (uri != null && uri.host.isNotEmpty) {
        s = uri.host;
      }
    } else {
      s = s.split('/').first.split('?').first.trim();
    }
    const suffix = '.saas.loopedsol.com';
    if (s.toLowerCase().endsWith(suffix)) {
      s = s.substring(0, s.length - suffix.length).trim();
      if (s.endsWith('.')) {
        s = s.substring(0, s.length - 1).trim();
      }
    }
    return s;
  }

  Future<String> _fetchRequiredAppVersion() async {
    final response = await dioConsumer.post(
      body: {},
      "https://saas.loopedsol.com${EndPoints.getMobileApplicationVersionPath}",
    );
    if(response['statusCode'] == 200) {
      return response['result']['version'];
    }
    return "1.0.0";
    // throw Exception("Invalid version response");
  }

  Future<void> checkAppVersion() async {
    try {
      emit(CheckAppVersionLoading());

      final requiredVersion = await _fetchRequiredAppVersion();
 
      final localVersion = "1.0.0";
      if (localVersion.trim() != requiredVersion.trim()) {
        emit(CheckAppVersionForceUpdateRequired(requiredVersion));
      } else {
        emit(CheckAppVersionUpToDate());
      }
    } catch (e) {
      emit(CheckAppVersionError(e.toString()));
    }
  }

Future<String> _fetchDeviceIdentifier() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Unique identifier for Android
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId =
            iosInfo.identifierForVendor ?? ""; // Unique identifier for iOS
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId; // Unique identifier for Windows
      } else {
        deviceId = 'Unsupported platform';
      }
    } catch (e) {
      deviceId = 'Error: $e';
    }
    return deviceId;
  }

  Future<void> login(String domainInput, String password, String userName) async {
    final domain = normalizeTenantDomain(domainInput);
    if (domain.isEmpty) {
      emit(AuthError(message: 'login_validation_domain_invalid'.tr()));
      return;
    }

    emit(AuthLoading());
    dioConsumer.addBaseUrl(
      '${EndPoints.firstBaseUrlDev}$domain${EndPoints.secondBaseUrlDev}',
    );
    try {
      // await addDeviceIdToHeaders();
      final response = await dioConsumer.post(
        EndPoints.login,
        body: {
          'domain': domain,
          'password': password,
          'login': userName,
        },
      );
      final statusCode = response['statusCode'];
      if (statusCode == 200) {
        final cookie = response['cookie']?.toString();
        final sessionInfo = response['session_info'];
        final uid = sessionInfo is Map<String, dynamic> ? sessionInfo['uid'] : null;
        if (cookie == null || cookie.isEmpty || uid == null) {
          emit(AuthError(message: 'errorOccurredTryAgain'.tr()));
          return;
        }
        dioConsumer.addSession(cookie);
        await getIt<ObjectBoxHelper>().put('userId', uid);
        if (isRememberMe) {
          await saveUserToken(cookie, domain, uid);
        }
        emit(AuthSuccess());
      } else {
        if (statusCode == 503) {
          emit(AuthError(message: 'linkNotAvailable'.tr()));
        } else {
          final desc = response['description'];
          final message = desc == null || '$desc'.trim().isEmpty
              ? 'errorOccurredTryAgain'.tr()
              : desc.toString();
          emit(AuthError(message: message));
        }
      }
    } catch (e) {
      emit(AuthError(message: 'errorOccurredTryAgain'.tr()));
    }
  }

  Future<void> saveUserToken(String token, String domain, dynamic uId) async {
    await getIt<ObjectBoxHelper>().put('userSessionId', token);
    await getIt<ObjectBoxHelper>().put('userDomain', domain);
    await getIt<ObjectBoxHelper>().put('userId', uId);
  }

  Future<void> logout() async {
    final box = getIt<ObjectBoxHelper>();
    await box.clear('userSessionId');
    await box.clear('userDomain');
    await box.clear('userId');
    dioConsumer.clearSession();
    isRememberMe = false;
    emit(AuthInitial());
  }


  /// يستعيد الجلسة من التخزين المحلي (تذكرني) ويطبّق [baseUrl] والـ cookie ثم [AuthSuccess].
  Future<void> checkIfUserLogin() async {
    try {
      final tokenRaw = await getIt<ObjectBoxHelper>().get('userSessionId');
      final domainRaw = await getIt<ObjectBoxHelper>().get('userDomain');
      if (tokenRaw == null || domainRaw == null) return;

      final token = '$tokenRaw'.trim();
      final domain = normalizeTenantDomain('$domainRaw');
      if (token.isEmpty || domain.isEmpty) return;

      dioConsumer.addBaseUrl(
        '${EndPoints.firstBaseUrlDev}$domain${EndPoints.secondBaseUrlDev}',
      );
      dioConsumer.addSession(token);
      emit(AuthSuccess());
    } catch (_) {
      // تجاهل — نعرض شاشة الدخول
    }
  }

Future<void> addDeviceIdToHeaders()async
{
  final deviceId = await _fetchDeviceIdentifier();
  dioConsumer.client.options.headers.addAll({'device-id': deviceId });
}

}
