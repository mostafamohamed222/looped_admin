import 'package:flutter/material.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

/// Calm, modern primary / secondary CTA for inventory and transfer flows.
enum InventoryActionButtonVariant { primary, primaryBlue, secondary }

class InventoryGradientActionButton extends StatelessWidget {
  const InventoryGradientActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.enabled = true,
    this.compact = false,
    this.variant = InventoryActionButtonVariant.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final bool enabled;
  final bool compact;
  final InventoryActionButtonVariant variant;
  final bool isLoading;

  bool get _isInteractive => enabled && !isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = compact ? 48.0 : 52.0;
    final radius = compact ? 12.0 : 14.0;
    final hPad = compact ? 12.0 : 18.0;
    final iconSize = compact ? 18.0 : 20.0;
    final gap = compact ? 8.0 : 10.0;

    final colors = _resolveColors();
    final labelStyle = (compact
            ? theme.textTheme.labelLarge
            : theme.textTheme.titleSmall)
        ?.copyWith(
      fontWeight: FontWeight.w600,
      color: colors.foreground,
      letterSpacing: 0,
      height: 1.15,
      fontSize: compact ? 13.5 : 15,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isInteractive ? onPressed : null,
        borderRadius: BorderRadius.circular(radius),
        splashColor: colors.splash,
        highlightColor: colors.highlight,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(radius),
            border: colors.border,
            boxShadow: colors.shadows,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: colors.foreground,
                    ),
                  )
                else
                  Icon(icon, color: colors.foreground, size: iconSize),
                SizedBox(width: gap),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: labelStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _resolveColors() {
    if (!enabled) {
      return const _ButtonColors(
        background: InventoryColors.tonalIconBg,
        foreground: InventoryColors.subtitleGrey,
        border: Border.fromBorderSide(
          BorderSide(color: InventoryColors.borderSubtle),
        ),
        splash: Colors.transparent,
        highlight: Colors.transparent,
        shadows: [],
      );
    }

    if (variant == InventoryActionButtonVariant.secondary) {
      return _ButtonColors(
        background: InventoryColors.cardSurface,
        foreground: InventoryColors.primaryNavy,
        border: Border.all(color: InventoryColors.borderSubtle),
        splash: InventoryColors.accentBlue.withValues(alpha: 0.06),
        highlight: InventoryColors.accentBlueSoft.withValues(alpha: 0.5),
        shadows: [
          BoxShadow(
            color: InventoryColors.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    if (variant == InventoryActionButtonVariant.primaryBlue) {
      return _ButtonColors(
        background: InventoryColors.accentBlue,
        foreground: Colors.white,
        border: null,
        splash: Colors.white.withValues(alpha: 0.1),
        highlight: Colors.white.withValues(alpha: 0.06),
        shadows: [
          BoxShadow(
            color: InventoryColors.accentBlue.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );
    }

    return _ButtonColors(
      background: InventoryColors.primaryNavy,
      foreground: Colors.white,
      border: null,
      splash: Colors.white.withValues(alpha: 0.08),
      highlight: Colors.white.withValues(alpha: 0.05),
      shadows: [
        BoxShadow(
          color: InventoryColors.primaryNavy.withValues(alpha: 0.12),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.splash,
    required this.highlight,
    required this.shadows,
  });

  final Color background;
  final Color foreground;
  final Border? border;
  final Color splash;
  final Color highlight;
  final List<BoxShadow> shadows;
}
