import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../core/services/document_scanner_service.dart';

/// Custom Document Cropping Screen (CamScanner style)
///
/// Features:
/// 1. 4 independent draggable corners.
/// 2. Bounding guidelines and semi-transparent overlay shroud.
/// 3. Zoomed-in Magnifying Glass overlay during dragging.
/// 4. Edge-detection integration.
/// 5. Image rotation and reset functionality.
class DocumentCropScreen extends StatefulWidget {
  final File imageFile;

  const DocumentCropScreen({super.key, required this.imageFile});

  @override
  State<DocumentCropScreen> createState() => _DocumentCropScreenState();
}

class _DocumentCropScreenState extends State<DocumentCropScreen> {
  late File _currentImageFile;
  bool _isLoading = true;
  int _imageWidth = 0;
  int _imageHeight = 0;

  // Normalized corner coordinates (0.0 to 1.0)
  Offset _topLeft = const Offset(0.15, 0.15);
  Offset _topRight = const Offset(0.85, 0.15);
  Offset _bottomRight = const Offset(0.85, 0.85);
  Offset _bottomLeft = const Offset(0.15, 0.85);

  int _activeCornerIndex = -1; // -1: none, 0: TL, 1: TR, 2: BR, 3: BL
  Offset? _lastTouchPosition;

  @override
  void initState() {
    super.initState();
    _currentImageFile = widget.imageFile;
    _loadImageData();
  }

  Future<void> _loadImageData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await _currentImageFile.readAsBytes();
      final ui.Image decodedImage = await decodeImageFromList(bytes);
      
      _imageWidth = decodedImage.width;
      _imageHeight = decodedImage.height;

      // Run edge detection
      final scanner = DocumentScannerService();
      final corners = await scanner.detectEdges(_currentImageFile);

      setState(() {
        _topLeft = Offset(corners.tlX, corners.tlY);
        _topRight = Offset(corners.trX, corners.trY);
        _bottomRight = Offset(corners.brX, corners.brY);
        _bottomLeft = Offset(corners.blX, corners.blY);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading image details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetCorners() {
    setState(() {
      _topLeft = const Offset(0.15, 0.15);
      _topRight = const Offset(0.85, 0.15);
      _bottomRight = const Offset(0.85, 0.85);
      _bottomLeft = const Offset(0.15, 0.85);
    });
  }

  Future<void> _rotateImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Rotate image using the service helper
      final rotatedFile = await _rotateImageFile(_currentImageFile);
      
      setState(() {
        _currentImageFile = rotatedFile;
      });
      
      await _loadImageData();
    } catch (e) {
      debugPrint('Error rotating image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<File> _rotateImageFile(File file) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/rotated_$timestamp.jpg';

    await Isolate.run(() {
      try {
        final bytes = File(file.path).readAsBytesSync();
        final original = img.decodeImage(bytes);
        if (original != null) {
          final rotated = img.copyRotate(original, angle: 90);
          final encoded = img.encodeJpg(rotated, quality: 92);
          File(outputPath).writeAsBytesSync(encoded);
        }
      } catch (e) {
        debugPrint('Error inside rotation isolate: $e');
      }
    });

    return File(outputPath);
  }

  Future<void> _confirmCrop() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scanner = DocumentScannerService();
      final corners = EdgeDetectionOutput(
        _topLeft.dx, _topLeft.dy,
        _topRight.dx, _topRight.dy,
        _bottomRight.dx, _bottomRight.dy,
        _bottomLeft.dx, _bottomLeft.dy,
      );

      final croppedFile = await scanner.perspectiveTransform(_currentImageFile, corners);
      
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      debugPrint('Error cropping document: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء قص المستند')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        title: Text(
          'تعديل وقص المستند',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: NeuColors.navyDeep,
                ),
              )
            : Column(
                children: [
                  // Top Info Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'اسحب الزوايا الأربع لتحديد حدود الورقة بدقة وسيقوم النظام بتصحيح المنظور تلقائياً.',
                      style: isDark ? AppTypography.bodySmallDark : AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Image Crop Area
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boxW = constraints.maxWidth;
                        final boxH = constraints.maxHeight;

                        // Calculate display aspect ratio fit (BoxFit.contain)
                        final imageRatio = _imageWidth / _imageHeight;
                        final containerRatio = boxW / boxH;

                        double displayW, displayH;
                        double offsetX = 0.0;
                        double offsetY = 0.0;

                        if (imageRatio > containerRatio) {
                          displayW = boxW;
                          displayH = boxW / imageRatio;
                          offsetY = (boxH - displayH) / 2;
                        } else {
                          displayH = boxH;
                          displayW = boxH * imageRatio;
                          offsetX = (boxW - displayW) / 2;
                        }

                        // Convert coordinates for magnifier glass
                        Offset getScreenPos(Offset norm) {
                          return Offset(
                            offsetX + norm.dx * displayW,
                            offsetY + norm.dy * displayH,
                          );
                        }

                        // Close corner finder
                        int findClosestCorner(Offset touch) {
                          final screenTL = getScreenPos(_topLeft);
                          final screenTR = getScreenPos(_topRight);
                          final screenBR = getScreenPos(_bottomRight);
                          final screenBL = getScreenPos(_bottomLeft);

                          final dists = [
                            (touch - screenTL).distance,
                            (touch - screenTR).distance,
                            (touch - screenBR).distance,
                            (touch - screenBL).distance,
                          ];

                          double minDist = double.infinity;
                          int idx = -1;
                          for (int i = 0; i < 4; i++) {
                            if (dists[i] < minDist) {
                              minDist = dists[i];
                              idx = i;
                            }
                          }
                          
                          // Maximum grab radius of 44 logical pixels
                          if (minDist < 44.0) {
                            return idx;
                          }
                          return -1;
                        }

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Main Image Container
                            Positioned.fill(
                              child: GestureDetector(
                                onPanStart: (details) {
                                  final idx = findClosestCorner(details.localPosition);
                                  if (idx != -1) {
                                    setState(() {
                                      _activeCornerIndex = idx;
                                      _lastTouchPosition = details.localPosition;
                                    });
                                  }
                                },
                                onPanUpdate: (details) {
                                  if (_activeCornerIndex != -1) {
                                    final localPos = details.localPosition;
                                    
                                    // Convert back to normalized coordinates
                                    double g = (localPos.dx - offsetX) / displayW;
                                    double h = (localPos.dy - offsetY) / displayH;

                                    g = g.clamp(0.0, 1.0);
                                    h = h.clamp(0.0, 1.0);

                                    setState(() {
                                      switch (_activeCornerIndex) {
                                        case 0: _topLeft = Offset(g, h); break;
                                        case 1: _topRight = Offset(g, h); break;
                                        case 2: _bottomRight = Offset(g, h); break;
                                        case 3: _bottomLeft = Offset(g, h); break;
                                      }
                                      _lastTouchPosition = localPos;
                                    });
                                  }
                                },
                                onPanEnd: (_) {
                                  setState(() {
                                    _activeCornerIndex = -1;
                                    _lastTouchPosition = null;
                                  });
                                },
                                child: Container(
                                  color: isDark ? const Color(0xFF0A0F18) : const Color(0xFFE2E7F0),
                                  child: Center(
                                    child: Image.file(
                                      _currentImageFile,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Overlay crop guidelines and shroud
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _DocumentCropPainter(
                                    topLeft: getScreenPos(_topLeft),
                                    topRight: getScreenPos(_topRight),
                                    bottomRight: getScreenPos(_bottomRight),
                                    bottomLeft: getScreenPos(_bottomLeft),
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            ),

                            // Magnifying Glass Overlay
                            if (_activeCornerIndex != -1 && _lastTouchPosition != null)
                              _buildMagnifier(
                                touchPos: _lastTouchPosition!,
                                offsetX: offsetX,
                                offsetY: offsetY,
                                displayW: displayW,
                                displayH: displayH,
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Bottom toolbar panel
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildToolbarButton(
                                icon: Icons.rotate_right_rounded,
                                label: 'تدوير 90آ°',
                                onTap: _rotateImage,
                                isDark: isDark,
                              ),
                              _buildToolbarButton(
                                icon: Icons.refresh_rounded,
                                label: 'إعادة تعيين',
                                onTap: _resetCorners,
                                isDark: isDark,
                              ),
                              _buildToolbarButton(
                                icon: Icons.auto_awesome_motion_rounded,
                                label: 'كشف تلقائي',
                                onTap: _loadImageData,
                                isDark: isDark,
                              ),
                            ],
                          ),
                          AppSpacing.gapLg,
                          ElevatedButton.icon(
                            onPressed: _confirmCrop,
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                            label: const Text('قص وتصحيح المنظور'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                              foregroundColor: isDark ? NeuColors.bgColorDark : Colors.white,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: AppTypography.button,
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        radius: 12,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Panorama',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagnifier({
    required Offset touchPos,
    required double offsetX,
    required double offsetY,
    required double displayW,
    required double displayH,
  }) {
    const double magnifierSize = 120.0;
    const double zoomFactor = 2.0;

    // Magnifier position: display 80 pixels above touch point
    final double left = touchPos.dx - (magnifierSize / 2);
    final double top = touchPos.dy - magnifierSize - 40;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: magnifierSize,
        height: magnifierSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: ClipOval(
          child: Stack(
            children: [
              Positioned(
                // Position the image zoomed in and translated
                left: -(touchPos.dx - offsetX) * zoomFactor + (magnifierSize / 2),
                top: -(touchPos.dy - offsetY) * zoomFactor + (magnifierSize / 2),
                child: Image.file(
                  _currentImageFile,
                  width: displayW * zoomFactor,
                  height: displayH * zoomFactor,
                  fit: BoxFit.fill,
                ),
              ),
              // Center crosshair
              Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
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

class _DocumentCropPainter extends CustomPainter {
  final Offset topLeft;
  final Offset topRight;
  final Offset bottomRight;
  final Offset bottomLeft;
  final bool isDark;

  _DocumentCropPainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw outer dark shroud (semi-transparent overlay)
    final shroudPaint = Paint()
      ..color = Colors.black.withAlpha(140)
      ..style = PaintingStyle.fill;

    final shroudPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cropPath = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    shroudPath.addPath(cropPath, Offset.zero);
    canvas.drawPath(shroudPath, shroudPaint);

    // 2. Draw guidelines
    final linePaint = Paint()
      ..color = isDark ? NeuColors.goldAccent : NeuColors.navyDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(cropPath, linePaint);

    // 3. Draw corner handles (44px grab area visualizer)
    final handlePaint = Paint()
      ..color = isDark ? NeuColors.goldAccent : NeuColors.navyDeep
      ..style = PaintingStyle.fill;

    final innerHandlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final handleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final p in [topLeft, topRight, bottomRight, bottomLeft]) {
      // Draw outer circle
      canvas.drawCircle(p, 12, handlePaint);
      canvas.drawCircle(p, 12, handleBorderPaint);
      // Draw inner dot
      canvas.drawCircle(p, 4, innerHandlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DocumentCropPainter oldDelegate) {
    return oldDelegate.topLeft != topLeft ||
        oldDelegate.topRight != topRight ||
        oldDelegate.bottomRight != bottomRight ||
        oldDelegate.bottomLeft != bottomLeft ||
        oldDelegate.isDark != isDark;
  }
}