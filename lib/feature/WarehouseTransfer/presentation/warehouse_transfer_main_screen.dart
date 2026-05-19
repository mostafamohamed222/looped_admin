import 'dart:async' show unawaited;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_gradient_action_button.dart';
import 'package:looped_admin/feature/WarehouseTransfer/data/warehouse_transfer_repository_impl.dart';
import 'package:looped_admin/feature/WarehouseTransfer/domain/stock_request_summary.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/cubit/warehouse_transfer_list_cubit.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/cubit/warehouse_transfer_list_state.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/warehouse_transfer_create_screen.dart';
import 'package:looped_admin/feature/WarehouseTransfer/presentation/warehouse_transfer_detail_screen.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/stock_request_card.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_app_bar.dart';

/// Lists warehouse transfer / stock requests from `get_all_requests`.
class WarehouseTransferMainScreen extends StatelessWidget {
  const WarehouseTransferMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseTransferListCubit(
        repository: WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>()),
      )..load(),
      child: const _WarehouseTransferMainShell(),
    );
  }
}

List<String> _distinctTransferStates(List<StockRequestSummary> items) {
  final seen = <String>{};
  final states = <String>[];
  for (final item in items) {
    final label = item.state.trim();
    if (label.isEmpty) continue;
    final key = label.toLowerCase();
    if (seen.add(key)) states.add(label);
  }
  states.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return states;
}

List<StockRequestSummary> _filterTransferItems(
  List<StockRequestSummary> items,
  String? selectedStateKey,
) {
  if (selectedStateKey == null) return items;
  return items
      .where((item) => item.state.toLowerCase().trim() == selectedStateKey)
      .toList();
}

List<StockRequestSummary> _searchTransferItems(
  List<StockRequestSummary> items,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return items;
  return items.where((item) {
    if (item.name.toLowerCase().contains(q)) return true;
    if (item.id.toString().contains(q)) return true;
    return false;
  }).toList();
}

class _WarehouseTransferMainShell extends StatefulWidget {
  const _WarehouseTransferMainShell();

  @override
  State<_WarehouseTransferMainShell> createState() =>
      _WarehouseTransferMainShellState();
}

class _WarehouseTransferMainShellState extends State<_WarehouseTransferMainShell> {
  String? _selectedStateKey;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearListFilters() {
    setState(() {
      _selectedStateKey = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  String _emptyResultsMessage({required bool hasSearch, required bool hasState}) {
    if (hasSearch && hasState) {
      return 'transfer_requests_search_filter_empty'.tr();
    }
    if (hasSearch) return 'transfer_requests_search_empty'.tr();
    return 'transfer_requests_filter_empty'.tr();
  }

  String _listError(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 'transfer_requests_list_generic_error'.tr();
    }
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('transfer_')) return trimmed.tr();
    return trimmed;
  }

  String _detailsErrorMessage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 'transfer_detail_load_error'.tr();
    }
    final trimmed = raw.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    if (trimmed.startsWith('transfer_')) return trimmed.tr();
    return trimmed;
  }

  Future<void> _openCreate(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const WarehouseTransferCreateScreen(),
      ),
    );
    if (!context.mounted || created != true) return;
    context.read<WarehouseTransferListCubit>().load();
  }

  Future<void> _openRequestDetail(
    BuildContext context,
    StockRequestSummary item,
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
                          'transfer_detail_loading'.tr(),
                          style: Theme.of(dialogContext)
                              .textTheme
                              .bodyMedium
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
      final repo = WarehouseTransferRepositoryImpl(dio: getIt<DioConsumer>());
      final detail = await repo.fetchRequestDetails(requestOrderId: item.id);
      if (!context.mounted) return;
      rootNav.pop();
      final result = await rootNav.push<WarehouseTransferDetailResult>(
        MaterialPageRoute<WarehouseTransferDetailResult>(
          builder: (_) => WarehouseTransferDetailScreen(detail: detail),
        ),
      );
      if (result != null && context.mounted) {
        await context.read<WarehouseTransferListCubit>().load();
        if (!context.mounted) return;
        final messageKey = switch (result) {
          WarehouseTransferDetailResult.submitted => 'transfer_submit_success',
          WarehouseTransferDetailResult.routeSaved =>
            'transfer_route_save_success',
          WarehouseTransferDetailResult.confirmed =>
            'transfer_confirm_success',
          WarehouseTransferDetailResult.linesAdded =>
            'transfer_detail_add_lines_success',
        };
        messenger.showSnackBar(
          SnackBar(
            content: Text(messageKey.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                    'transfer_home_title'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: InventoryColors.primaryNavy,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'transfer_home_subtitle'.tr(),
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
              child: BlocConsumer<WarehouseTransferListCubit,
                  WarehouseTransferListState>(
                listenWhen: (previous, current) =>
                    previous.items != current.items,
                listener: (context, state) {
                  if (_selectedStateKey == null) return;
                  final base =
                      _searchTransferItems(state.items, _searchQuery);
                  final available = _distinctTransferStates(base)
                      .map((s) => s.toLowerCase().trim())
                      .toSet();
                  if (!available.contains(_selectedStateKey)) {
                    setState(() => _selectedStateKey = null);
                  }
                },
                builder: (context, state) {
                  if (state.status == WarehouseTransferListStatus.loading &&
                      state.items.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.8),
                    );
                  }
                  if (state.status == WarehouseTransferListStatus.failure &&
                      state.items.isEmpty) {
                    return _ListErrorState(
                      message: _listError(state.errorMessage),
                      onRetry: () =>
                          context.read<WarehouseTransferListCubit>().load(),
                    );
                  }
                  if (state.items.isEmpty) {
                    return RefreshIndicator(
                      color: InventoryColors.primaryNavy,
                      onRefresh: () =>
                          context.read<WarehouseTransferListCubit>().load(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 56,
                            color: InventoryColors.subtitleGrey
                                .withValues(alpha: 0.75),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'transfer_requests_empty'.tr(),
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

                  final searchFiltered =
                      _searchTransferItems(state.items, _searchQuery);
                  final filterStates = _distinctTransferStates(searchFiltered);
                  final filteredItems = _filterTransferItems(
                    searchFiltered,
                    _selectedStateKey,
                  );
                  final hasSearch = _searchQuery.trim().isNotEmpty;
                  final hasStateFilter = _selectedStateKey != null;
                  final hasActiveFilters = hasSearch || hasStateFilter;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TransferListToolbar(
                        searchController: _searchController,
                        searchQuery: _searchQuery,
                        onSearchChanged: (value) {
                          setState(() => _searchQuery = value);
                          if (_selectedStateKey == null) return;
                          final available = _distinctTransferStates(
                            _searchTransferItems(state.items, value),
                          )
                              .map((s) => s.toLowerCase().trim())
                              .toSet();
                          if (!available.contains(_selectedStateKey)) {
                            _selectedStateKey = null;
                          }
                        },
                        items: searchFiltered,
                        states: filterStates,
                        selectedStateKey: _selectedStateKey,
                        onStateSelected: (key) =>
                            setState(() => _selectedStateKey = key),
                      ),
                      Expanded(
                        child: filteredItems.isEmpty
                            ? RefreshIndicator(
                                color: InventoryColors.primaryNavy,
                                onRefresh: () => context
                                    .read<WarehouseTransferListCubit>()
                                    .load(),
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 48, 24, 24),
                                  children: [
                                    Icon(
                                      hasSearch
                                          ? Icons.search_off_rounded
                                          : Icons.filter_list_off_rounded,
                                      size: 52,
                                      color: InventoryColors.subtitleGrey
                                          .withValues(alpha: 0.75),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _emptyResultsMessage(
                                        hasSearch: hasSearch,
                                        hasState: hasStateFilter,
                                      ),
                                      textAlign: TextAlign.center,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: InventoryColors.primaryNavy,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (hasActiveFilters) ...[
                                      const SizedBox(height: 16),
                                      Center(
                                        child: TextButton(
                                          onPressed: _clearListFilters,
                                          child: Text(
                                            'transfer_filter_clear_all'.tr(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                color: InventoryColors.primaryNavy,
                                onRefresh: () => context
                                    .read<WarehouseTransferListCubit>()
                                    .load(),
                                child: ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 6, 16, 20),
                                  itemCount: filteredItems.length +
                                      (state.status ==
                                              WarehouseTransferListStatus
                                                  .failure
                                          ? 1
                                          : 0),
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    if (index == filteredItems.length) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          _listError(state.errorMessage),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: InventoryColors.dangerText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }
                                    final item = filteredItems[index];
                                    return StockRequestCard(
                                      item: item,
                                      onTap: () =>
                                          _openRequestDetail(context, item),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
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
                    color: InventoryColors.primaryNavy.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                child: InventoryGradientActionButton(
                  label: 'transfer_new_request'.tr(),
                  icon: Icons.add_rounded,
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

class _TransferListToolbar extends StatelessWidget {
  const _TransferListToolbar({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.items,
    required this.states,
    required this.selectedStateKey,
    required this.onStateSelected,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<StockRequestSummary> items;
  final List<String> states;
  final String? selectedStateKey;
  final ValueChanged<String?> onStateSelected;

  int _countFor(String? stateKey) {
    if (stateKey == null) return items.length;
    return items
        .where((item) => item.state.toLowerCase().trim() == stateKey)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showStateFilters = states.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: InventoryColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: InventoryColors.borderSubtle.withValues(alpha: 0.75),
          ),
          boxShadow: [
            BoxShadow(
              color: InventoryColors.primaryNavy.withValues(alpha: 0.035),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, showStateFilters ? 0 : 10),
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  textInputAction: TextInputAction.search,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: InventoryColors.primaryNavy,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'transfer_requests_search_hint'.tr(),
                    hintStyle: theme.textTheme.bodySmall?.copyWith(
                      color: InventoryColors.subtitleGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: InventoryColors.subtitleGrey,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    suffixIcon: searchQuery.trim().isEmpty
                        ? null
                        : IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            tooltip: 'transfer_filter_clear'.tr(),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: InventoryColors.subtitleGrey,
                            ),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          ),
                    filled: true,
                    fillColor: InventoryColors.pageBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(
                        color:
                            InventoryColors.borderSubtle.withValues(alpha: 0.6),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(
                        color:
                            InventoryColors.accentBlue.withValues(alpha: 0.55),
                        width: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (showStateFilters) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: InventoryColors.borderSubtle.withValues(alpha: 0.65),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 13,
                      color: InventoryColors.subtitleGrey.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'transfer_filter_by_status'.tr(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: InventoryColors.subtitleGrey,
                        fontSize: 10.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                  itemCount: states.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _TransferStateFilterChip(
                        label: 'transfer_filter_all'.tr(),
                        count: _countFor(null),
                        selected: selectedStateKey == null,
                        isAll: true,
                        onTap: () => onStateSelected(null),
                      );
                    }
                    final state = states[index - 1];
                    final key = state.toLowerCase().trim();
                    final style = TransferStateStyle.forState(state);
                    return _TransferStateFilterChip(
                      label: state,
                      count: _countFor(key),
                      selected: selectedStateKey == key,
                      accent: style.accent,
                      background: style.background,
                      foreground: style.foreground,
                      onTap: () => onStateSelected(key),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransferStateFilterChip extends StatelessWidget {
  const _TransferStateFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.isAll = false,
    this.accent,
    this.background,
    this.foreground,
  });

  final String label;
  final int count;
  final bool selected;
  final bool isAll;
  final VoidCallback onTap;
  final Color? accent;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipAccent = accent ?? InventoryColors.primaryNavy;
    final chipBackground =
        background ?? InventoryColors.primaryNavy.withValues(alpha: 0.1);
    final chipForeground = foreground ?? InventoryColors.primaryNavy;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: chipAccent.withValues(alpha: 0.1),
        highlightColor: chipAccent.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
          decoration: BoxDecoration(
            color: selected
                ? chipBackground
                : InventoryColors.pageBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? chipAccent.withValues(alpha: 0.3)
                  : InventoryColors.borderSubtle.withValues(alpha: 0.7),
              width: selected ? 1.1 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAll)
                Icon(
                  selected ? Icons.grid_view_rounded : Icons.grid_view_outlined,
                  size: 12,
                  color: selected
                      ? chipForeground
                      : InventoryColors.subtitleGrey,
                )
              else
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: chipAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 5),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? chipForeground
                      : InventoryColors.subtitleGrey,
                  fontSize: 11,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                constraints: const BoxConstraints(minWidth: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? chipAccent.withValues(alpha: 0.12)
                      : InventoryColors.cardSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? chipForeground : InventoryColors.subtitleGrey,
                    fontSize: 9.5,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
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
