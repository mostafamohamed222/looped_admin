import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:looped_admin/core/res/app_routes.dart';

/// يتحكم في لغة الواجهة (عربي / إنجليزي) مع [EasyLocalization].
class AppLocaleCubit extends Cubit<Locale> {
  AppLocaleCubit(this._navigator) : super(const Locale('ar'));

  final NavigatorManager _navigator;

  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  /// مزامنة مع اللغة المحفوظة بعد تهيئة [EasyLocalization].
  void hydrate(Locale resolved) {
    final next = _normalize(resolved);
    if (next == state) return;
    emit(next);
  }

  Locale _normalize(Locale locale) =>
      locale.languageCode == english.languageCode ? english : arabic;

  Future<void> setLocale(Locale locale) async {
    final next = _normalize(locale);
    if (next == state) return;

    final ctx = _resolveLocaleContext();
    if (ctx != null && ctx.mounted) {
      await ctx.setLocale(next);
    }

    // بعد تحديث EasyLocalization نحدّث الـ Cubit في الإطار التالي حتى تبقى الترجمات و MaterialApp متزامنتين.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) emit(next);
    });
  }

  /// يفضّل سياق الـ Overlay تحت [MaterialApp] حتى يجد [EasyLocalization] بشكل موثوق.
  BuildContext? _resolveLocaleContext() {
    final navState = _navigator.navigatorKey.currentState;
    final overlayCtx = navState?.overlay?.context;
    if (overlayCtx != null && overlayCtx.mounted) return overlayCtx;
    final root = _navigator.navigatorKey.currentContext;
    if (root != null && root.mounted) return root;
    return null;
  }

  Future<void> setArabic() => setLocale(arabic);

  Future<void> setEnglish() => setLocale(english);
}
