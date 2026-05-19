import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';
import 'package:looped_admin/feature/WarehouseTransfer/widget/stock_request_card.dart';

/// Compact search + horizontal state filter bar (shared by list screens).
class FilterableListToolbar extends StatelessWidget {
  const FilterableListToolbar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.states,
    required this.selectedStateKey,
    required this.onStateSelected,
    required this.countFor,
    required this.searchHintKey,
    required this.filterByStatusKey,
    required this.filterAllKey,
    required this.clearSearchTooltipKey,
    required this.stateStyleFor,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<String> states;
  final String? selectedStateKey;
  final ValueChanged<String?> onStateSelected;
  final int Function(String? stateKey) countFor;
  final String searchHintKey;
  final String filterByStatusKey;
  final String filterAllKey;
  final String clearSearchTooltipKey;
  final TransferStateStyle Function(String state) stateStyleFor;

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
                    hintText: searchHintKey.tr(),
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
                            tooltip: clearSearchTooltipKey.tr(),
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
                      filterByStatusKey.tr(),
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
                      return FilterableListStateChip(
                        label: filterAllKey.tr(),
                        count: countFor(null),
                        selected: selectedStateKey == null,
                        isAll: true,
                        onTap: () => onStateSelected(null),
                      );
                    }
                    final state = states[index - 1];
                    final key = state.toLowerCase().trim();
                    final style = stateStyleFor(state);
                    return FilterableListStateChip(
                      label: state,
                      count: countFor(key),
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

class FilterableListStateChip extends StatelessWidget {
  const FilterableListStateChip({
    super.key,
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

/// Distinct non-empty state labels from [stateLabels], sorted alphabetically.
List<String> distinctStateLabels(Iterable<String> stateLabels) {
  final seen = <String>{};
  final states = <String>[];
  for (final raw in stateLabels) {
    final label = raw.trim();
    if (label.isEmpty) continue;
    final key = label.toLowerCase();
    if (seen.add(key)) states.add(label);
  }
  states.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return states;
}
