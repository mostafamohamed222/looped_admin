import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_colors.dart';
import 'package:looped_admin/feature/dashboard/widget/dashboard_logo_mark.dart';

/// Header: شعار · Looped · القائمة (في RTL: قائمة يمين، شعار يسار كما في التصميم).
class DashboardAppBar extends StatelessWidget {
  const DashboardAppBar({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DashboardColors.appBarBackground,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 14),
        child: Row(
          children: [
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded),
              color: DashboardColors.titleText,
              iconSize: 26,
              tooltip: 'common_menu_tooltip'.tr(),
            ),
            Expanded(
              child: Text(
                'brand_looped'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: DashboardColors.titleText,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(end: 8),
              child: DashboardLogoMark(size: 44),
            ),
          ],
        ),
      ),
    );
  }
}
