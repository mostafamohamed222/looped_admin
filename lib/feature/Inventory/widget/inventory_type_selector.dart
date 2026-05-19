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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _CompactTypeCard(
              title: 'inventory_type_full_title'.tr(),
              description: 'inventory_type_full_desc'.tr(),
              icon: Icons.fact_check_rounded,
              selected: selected == InventoryCountType.full,
              onTap: () => onChanged(InventoryCountType.full),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _CompactTypeCard(
              title: 'inventory_type_single_title'.tr(),
              description: 'inventory_type_single_desc'.tr(),
              icon: Icons.playlist_add_check_rounded,
              selected: selected == InventoryCountType.singleProduct,
              onTap: () => onChanged(InventoryCountType.singleProduct),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTypeCard extends StatelessWidget {
  const _CompactTypeCard({
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
        color: selected
            ? InventoryColors.accentBlueSoft.withValues(alpha: 0.55)
            : InventoryColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? InventoryColors.accentBlue.withValues(alpha: 0.38)
              : InventoryColors.borderSubtle.withValues(alpha: 0.85),
          width: selected ? 1.2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: InventoryColors.accentBlue.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: selected
                            ? InventoryColors.accentBlue
                            : InventoryColors.tonalIconBg,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        icon,
                        size: 17,
                        color: selected
                            ? Colors.white
                            : InventoryColors.primaryNavy.withValues(alpha: 0.75),
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? InventoryColors.accentBlue
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? InventoryColors.accentBlue
                              : InventoryColors.borderSubtle,
                          width: 1.2,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: InventoryColors.primaryNavy,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: InventoryColors.subtitleGrey,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
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
