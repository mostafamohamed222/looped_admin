import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/domain/inventory_count_type.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

class InventoryTypeSelector extends StatelessWidget {
  const InventoryTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final InventoryCountType? selected;
  final ValueChanged<InventoryCountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TypeCard(
          title: 'inventory_type_full_title'.tr(),
          description: 'inventory_type_full_desc'.tr(),
          icon: Icons.fact_check_rounded,
          selected: selected == InventoryCountType.full,
          onTap: () => onChanged(InventoryCountType.full),
        ),
        const SizedBox(height: 12),
        _TypeCard(
          title: 'inventory_type_single_title'.tr(),
          description: 'inventory_type_single_desc'.tr(),
          icon: Icons.qr_code_2_rounded,
          selected: selected == InventoryCountType.singleProduct,
          onTap: () => onChanged(InventoryCountType.singleProduct),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
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
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? InventoryColors.accentBlueSoft : InventoryColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? InventoryColors.accentBlue : InventoryColors.borderSubtle,
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: InventoryColors.accentBlue.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? InventoryColors.accentBlue
                        : InventoryColors.tonalIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? Colors.white : InventoryColors.primaryNavy,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: InventoryColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: InventoryColors.subtitleGrey,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected
                      ? InventoryColors.accentBlue
                      : InventoryColors.subtitleGrey,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
