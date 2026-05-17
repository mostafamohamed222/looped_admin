import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:looped_admin/feature/Inventory/widget/inventory_colors.dart';

/// Full-screen barcode / QR scanner; pops with the first decoded string value.
class InventoryBarcodeScannerScreen extends StatefulWidget {
  const InventoryBarcodeScannerScreen({super.key});

  @override
  State<InventoryBarcodeScannerScreen> createState() =>
      _InventoryBarcodeScannerScreenState();
}

class _InventoryBarcodeScannerScreenState
    extends State<InventoryBarcodeScannerScreen> {
  late final MobileScannerController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue ?? b.displayValue;
      if (raw != null && raw.trim().isNotEmpty) {
        _handled = true;
        _controller.stop();
        Navigator.of(context).pop<String>(raw.trim());
        return;
      }
    }
  }

  Future<void> _openManualEntry() async {
    final manual = TextEditingController();
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: InventoryColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: mq.viewInsets.bottom + 20,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'inventory_scan_manual_entry'.tr(),
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: InventoryColors.primaryNavy,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: manual,
                autofocus: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'inventory_barcode_field_hint'.tr(),
                  prefixIcon: const Icon(Icons.qr_code_2_rounded),
                  filled: true,
                  fillColor: InventoryColors.pageBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, manual.text),
                child: Text(
                  'inventory_barcode_apply'.tr(),
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
    manual.dispose();
    if (code != null && code.trim().isNotEmpty && mounted) {
      _handled = true;
      await _controller.stop();
      if (mounted) Navigator.of(context).pop<String>(code.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop<String>(),
        ),
        title: Text(
          'inventory_product_scan'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'inventory_scan_torch'.tr(),
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final on = state.torchState == TorchState.on;
                return Icon(
                  on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () {
              if (_controller.value.torchState == TorchState.unavailable) {
                return;
              }
              _controller.toggleTorch();
            },
          ),
          TextButton(
            onPressed: _handled ? null : _openManualEntry,
            child: Text(
              'inventory_scan_manual_entry'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              final denied =
                  error.errorCode == MobileScannerErrorCode.permissionDenied;
              return ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      denied
                          ? 'inventory_scan_permission_denied'.tr()
                          : error.errorDetails?.message ??
                              'inventory_scan_error_generic'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Text(
                  'inventory_scan_align_hint'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    shadows: const [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black54,
                        offset: Offset(0, 1),
                      ),
                    ],
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
