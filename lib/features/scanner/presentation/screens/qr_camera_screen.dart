import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';

/// Screen that displays the camera for QR code scanning
class QRCameraScreen extends StatefulWidget {
  final Function(String) onQRCodeScanned;

  const QRCameraScreen({
    super.key,
    required this.onQRCodeScanned,
  });

  @override
  State<QRCameraScreen> createState() => _QRCameraScreenState();
}

class _QRCameraScreenState extends State<QRCameraScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;
  bool _hasScanned = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _hasScanned = true;
        });
        widget.onQRCodeScanned(barcode.rawValue!);
        Navigator.of(context).pop();
        break;
      }
    }
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    _scannerController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isArabic = !(l?.isEnLocale ?? true);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Overlay with scan area
          _buildOverlay(context, isArabic),
          // Top bar with close and torch buttons
          _buildTopBar(context, isArabic),
          // Bottom instruction text
          _buildBottomInstruction(context, isArabic),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isArabic) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // Title
            Text(
              isArabic ? 'مسح QR' : 'Scan QR',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
              ),
            ),
            // Torch button
            GestureDetector(
              onTap: _toggleTorch,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isTorchOn
                      ? AppColors.primaryColor
                      : Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, bool isArabic) {
    final scanAreaSize = context.dynamicWidth(0.7);

    return Stack(
      children: [
        // Dark overlay with transparent center
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scan frame corners
        Center(
          child: SizedBox(
            width: scanAreaSize,
            height: scanAreaSize,
            child: Stack(
              children: [
                // Corner decorations
                _buildCorner(
                  alignment: Alignment.topLeft,
                  rotation: 0,
                ),
                _buildCorner(
                  alignment: Alignment.topRight,
                  rotation: 90,
                ),
                _buildCorner(
                  alignment: Alignment.bottomRight,
                  rotation: 180,
                ),
                _buildCorner(
                  alignment: Alignment.bottomLeft,
                  rotation: 270,
                ),
                // Scanning line animation
                AnimatedBuilder(
                  animation: _scanLineAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanLineAnimation.value * (scanAreaSize - 4),
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.primaryColor,
                              AppColors.tertiaryColor,
                              AppColors.primaryColor,
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({
    required Alignment alignment,
    required double rotation,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.rotate(
        angle: rotation * 3.14159 / 180,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.primaryColor,
                width: 4,
              ),
              left: BorderSide(
                color: AppColors.primaryColor,
                width: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInstruction(BuildContext context, bool isArabic) {
    return Positioned(
      bottom: context.dynamicHeight(0.12),
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.06),
              vertical: context.dynamicHeight(0.015),
            ),
            margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.1)),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: context.dynamicWidth(0.05),
                ),
                SizedBox(width: context.dynamicWidth(0.02)),
                Text(
                  isArabic
                      ? 'ضع رمز QR داخل الإطار'
                      : 'Place QR code inside the frame',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: context.dynamicWidth(0.035),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
