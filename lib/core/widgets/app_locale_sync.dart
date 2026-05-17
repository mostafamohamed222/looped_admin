import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:looped_admin/core/di/injection.dart' as di;
import 'package:looped_admin/feature/settings/cubit/app_locale_cubit.dart';

/// يطابق [AppLocaleCubit] مع اللغة التي استعادها EasyLocalization من التخزين.
class AppLocaleSync extends StatefulWidget {
  const AppLocaleSync({super.key, required this.child});

  final Widget child;

  @override
  State<AppLocaleSync> createState() => _AppLocaleSyncState();
}

class _AppLocaleSyncState extends State<AppLocaleSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      di.getIt<AppLocaleCubit>().hydrate(context.locale);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
