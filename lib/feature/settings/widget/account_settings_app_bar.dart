import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';

class AccountSettingsAppBar extends StatelessWidget {
  const AccountSettingsAppBar({
    super.key,
    required this.onMenuTap,
    required this.onHelpTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onHelpTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu_rounded),
            color: ColorManager.blackColor,
            tooltip: 'common_menu_tooltip'.tr(),
          ),
          Expanded(
            child: Text(
              'brand_looped'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ColorManager.blackColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Tooltip(
            message: 'common_help_tooltip'.tr(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onHelpTap,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorManager.lightGreyColor,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    size: 22,
                    color: ColorManager.blackColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
