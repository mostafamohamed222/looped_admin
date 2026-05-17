import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

/// When full warehouse count is selected: include or exclude zero-quantity lines.
class FullCountZeroStockOptions extends StatelessWidget {
  const FullCountZeroStockOptions({
    super.key,
    required this.includeZeroQuantityProducts,
    required this.onChanged,
  });

  /// `true` = count lines with zero on-hand qty; `false` = skip them.
  final bool includeZeroQuantityProducts;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'inventory_full_zero_section_title'.tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: InventoryColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'inventory_full_zero_section_subtitle'.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: InventoryColors.subtitleGrey,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _ZeroPolicyCard(
          title: 'inventory_full_zero_exclude_title'.tr(),
          description: 'inventory_full_zero_exclude_desc'.tr(),
          icon: Icons.filter_alt_outlined,
          selected: !includeZeroQuantityProducts,
          onTap: () => onChanged(false),
        ),
        const SizedBox(height: 10),
        _ZeroPolicyCard(
          title: 'inventory_full_zero_include_title'.tr(),
          description: 'inventory_full_zero_include_desc'.tr(),
          icon: Icons.all_inclusive_rounded,
          selected: includeZeroQuantityProducts,
          onTap: () => onChanged(true),
        ),
      ],
    );
  }
}

class _ZeroPolicyCard extends StatelessWidget {
  const _ZeroPolicyCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? InventoryColors.accentBlueSoft : InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? InventoryColors.accentBlue : InventoryColors.borderSubtle,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected ? InventoryColors.accentBlue : InventoryColors.subtitleGrey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: InventoryColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? InventoryColors.accentBlue : InventoryColors.subtitleGrey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
