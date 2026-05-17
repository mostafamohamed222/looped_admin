import 'dart:async' show unawaited;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/Inventory/data/inventory_count_repository_impl.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_adjustment_summary.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_adjustments_list_cubit.dart';
import 'package:looped_admin/feature/Inventory/presentation/cubit/inventory_adjustments_list_state.dart';
import 'package:looped_admin/feature/Inventory/presentation/inventory_adjustment_detail_screen.dart';
import 'package:looped_admin/feature/Inventory/presentation/inventory_create_adjustment_screen.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_adjustment_card.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_gradient_action_button.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_app_bar.dart';

/// Lists past inventory adjustments; opens the existing create flow from the primary action.
class InventoryMainScreen extends StatelessWidget {
  const InventoryMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryAdjustmentsListCubit(
        repository: InventoryCountRepositoryImpl(dio: getIt<DioConsumer>()),
      )..load(),
      child: const _InventoryMainShell(),
    );
  }
}

class _InventoryMainShell extends StatelessWidget {
  const _InventoryMainShell();

  String _listError(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 'inventory_adjustments_list_generic_error'.tr();
    }
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('inventory_')) return trimmed.tr();
    return trimmed;
  }

  Future<void> _openCreate(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const InventoryCreateAdjustmentScreen(),
      ),
    );
    if (!context.mounted) return;
    context.read<InventoryAdjustmentsListCubit>().load();
  }

  String _detailsErrorMessage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 'inventory_adjustment_details_load_error'.tr();
    }
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('inventory_')) return trimmed.tr();
    return trimmed;
  }

  Future<void> _openAdjustmentDetail(
    BuildContext context,
    InventoryAdjustmentSummary item,
  ) async {
    final rootNav = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            child: Material(
              color: Colors.black26,
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2.8),
                        const SizedBox(height: 16),
                        Text(
                          'inventory_adjustment_details_loading'.tr(),
                          style: Theme.of(dialogContext).textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: InventoryColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    try {
      final repo = InventoryCountRepositoryImpl(dio: getIt<DioConsumer>());
      final result =
          await repo.fetchAdjustmentDetails(inventoryId: item.inventoryId);
      if (!context.mounted) return;
      rootNav.pop();
      await rootNav.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => InventoryAdjustmentDetailScreen(
            result: result,
            repository: repo,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      if (rootNav.canPop()) rootNav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(_detailsErrorMessage(e.toString())),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: InventoryColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccountSettingsAppBar(
              onMenuTap: () => Navigator.of(context).maybePop(),
              onHelpTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'inventory_home_title'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: InventoryColors.primaryNavy,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'inventory_home_subtitle'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: InventoryColors.subtitleGrey,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<InventoryAdjustmentsListCubit,
                  InventoryAdjustmentsListState>(
                builder: (context, state) {
                  if (state.status == InventoryAdjustmentsListStatus.loading &&
                      state.items.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.8),
                    );
                  }
                  if (state.status == InventoryAdjustmentsListStatus.failure &&
                      state.items.isEmpty) {
                    return _ListErrorState(
                      message: _listError(state.errorMessage),
                      onRetry: () =>
                          context.read<InventoryAdjustmentsListCubit>().load(),
                    );
                  }
                  if (state.items.isEmpty) {
                    return RefreshIndicator(
                      color: InventoryColors.primaryNavy,
                      onRefresh: () =>
                          context.read<InventoryAdjustmentsListCubit>().load(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 56,
                            color: InventoryColors.subtitleGrey
                                .withValues(alpha: 0.75),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'inventory_adjustments_empty'.tr(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: InventoryColors.primaryNavy,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: InventoryColors.primaryNavy,
                    onRefresh: () =>
                        context.read<InventoryAdjustmentsListCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: state.items.length +
                          (state.status ==
                                  InventoryAdjustmentsListStatus.failure
                              ? 1
                              : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index == state.items.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _listError(state.errorMessage),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: InventoryColors.dangerText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        final item = state.items[index];
                        return InventoryAdjustmentCard(
                          item: item,
                          onTap: () => _openAdjustmentDetail(context, item),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: InventoryColors.cardSurface,
                border: Border(
                  top: BorderSide(
                    color: InventoryColors.borderSubtle.withValues(alpha: 0.9),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: InventoryColors.primaryNavy.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  14 + MediaQuery.of(context).padding.bottom,
                ),
                child: InventoryGradientActionButton(
                  label: 'inventory_new_request'.tr(),
                  onPressed: () => _openCreate(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListErrorState extends StatelessWidget {
  const _ListErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: InventoryColors.subtitleGrey.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: InventoryColors.primaryNavy,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('inventory_retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
