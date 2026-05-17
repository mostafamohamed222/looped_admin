import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/feature/dashboard/presentation/dashboard_page.dart';
import 'package:looped_admin/feature/nav_bar/cubit/app_shell_nav_cubit.dart';
import 'package:looped_admin/feature/settings/cubit/app_locale_cubit.dart';
import 'package:looped_admin/feature/requests/presentation/categorized_orders_page.dart';
import 'package:looped_admin/feature/ai_chat/presentation/ai_chat_page.dart';
import 'package:looped_admin/feature/settings/presentation/account_settings_page.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShellScaffold();
  }
}

class _AppShellScaffold extends StatelessWidget {
  const _AppShellScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLocaleCubit, Locale>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, locale) {
        return BlocBuilder<AppShellNavCubit, int>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, index) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                tooltip: 'ai_chat_fab_tooltip'.tr(),
                backgroundColor: ColorManager.mainColor,
                foregroundColor: ColorManager.whiteColor,
                elevation: 4,
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const AiChatPage(),
                    ),
                  );
                },
                child: const Icon(Icons.smart_toy_outlined),
              ),
              body: KeyedSubtree(
                key: ValueKey<String>(locale.languageCode),
                child: IndexedStack(
                  index: index,
                  children: const [
                    AccountSettingsPage(),
                    CategorizedOrdersPage(),
                    DashboardPage(),
                  ],
                ),
              ),
              bottomNavigationBar: Material(
                color: ColorManager.navBarBackgroundColor,
                elevation: 0,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ColorManager.navBarAccentBorderColor,
                        width: 2,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                      child: Row(
                        children: [
                          _NavItem(
                            label: 'nav_settings'.tr(),
                            icon: Icons.person_outline_rounded,
                            selected:
                                index == AppShellNavCubit.settingsTab,
                            onTap: () => context
                                .read<AppShellNavCubit>()
                                .selectTab(AppShellNavCubit.settingsTab),
                            pillColor: ColorManager.navBarActivePillColor,
                            labelColor: ColorManager.navBarLabelColor,
                          ),
                          _NavItem(
                            label: 'nav_requests'.tr(),
                            icon: Icons.account_tree_outlined,
                            selected:
                                index == AppShellNavCubit.requestsTab,
                            onTap: () => context
                                .read<AppShellNavCubit>()
                                .selectTab(AppShellNavCubit.requestsTab),
                            pillColor: ColorManager.navBarActivePillColor,
                            labelColor: ColorManager.navBarLabelColor,
                          ),
                          _NavItem(
                            label: 'nav_dashboard'.tr(),
                            icon: Icons.grid_view_rounded,
                            selected:
                                index == AppShellNavCubit.dashboardTab,
                            onTap: () => context
                                .read<AppShellNavCubit>()
                                .selectTab(AppShellNavCubit.dashboardTab),
                            pillColor: ColorManager.navBarActivePillColor,
                            labelColor: ColorManager.navBarLabelColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.pillColor,
    required this.labelColor,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color pillColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? pillColor : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: labelColor.withValues(alpha: selected ? 1 : 0.72),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: labelColor.withValues(alpha: selected ? 1 : 0.78),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
