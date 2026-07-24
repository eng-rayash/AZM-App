import 'dart:io';
import 'dart:math' as math;
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../features/archive/presentation/document_crop_screen.dart';

/// Document filter types available for scanned documents.
enum DocumentFilter {
  /// Original image — no processing applied
  original,

  /// Grayscale — converts to black & white tones
  grayscale,

  /// Fidelity Color — optimized contrast color balance
  fidelityColor,

  /// Magic Vivid — enhanced white balance, high vibrancy
  magicVivid,

  /// Crisp B&W — pure white background, pure black text
  crispBW,
}

/// Extension to provide Arabic labels and icons for each filter.
extension DocumentFilterExtension on DocumentFilter {
  String get arabicLabel {
    switch (this) {
      case DocumentFilter.original:
        return 'الأصلي';
      case DocumentFilter.grayscale:
        return 'رمادي';
      case DocumentFilter.fidelityColor:
        return 'مستند ملون واضح (Fidelity Color)';
      case DocumentFilter.magicVivid:
        return 'ألوان سحرية فائقة الوضوح (Magic Vivid)';
      case DocumentFilter.crispBW:
        return 'مستند نصي ناصع (Crisp B&W)';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentFilter.original:
        return Icons.image_rounded;
      case DocumentFilter.grayscale:
        return Icons.filter_b_and_w_rounded;
      case DocumentFilter.fidelityColor:
        return Icons.auto_fix_high_rounded;
      case DocumentFilter.magicVivid:
        return Icons.auto_awesome_rounded;
      case DocumentFilter.crispBW:
        return Icons.contrast_rounded;
    }
  }
}

/// Input data for Edge Detection Isolate
class EdgeDetectionInput {
  final String imagePath;
  EdgeDetectionInput(this.imagePath);
}

/// Output coordinates for Edge Detection Isolate (normalized)
class EdgeDetectionOutput {
  final double tlX; final double tlY;
  final double trX; final double trY;
  final double brX; final double brY;
  final double blX; final double blY;

  EdgeDetectionOutput(this.tlX, this.tlY, this.trX, this.trY, this.brX, this.brY, this.blX, this.blY);
}

/// Input data for Perspective Transform Isolate
class PerspectiveInput {
  final String imagePath;
  final double tlX; final double tlY;
  final double trX; final double trY;
  final double brX; final double brY;
  final double blX; final double blY;
  final String outputPath;

  PerspectiveInput({
    required this.imagePath,
    required this.tlX, required this.tlY,
    required this.trX, required this.trY,
    required this.brX, required this.brY,
    required this.blX, required this.blY,
    required this.outputPath,
  });
}

/// Professional document scanner service.
///
/// Provides camera/gallery capture → interactive crop → document filters.
/// Designed to produce CamScanner-quality scanned documents.
class DocumentScannerService {
  DocumentScannerService._();
  static final DocumentScannerService _instance = DocumentScannerService._();
  factory DocumentScannerService() => _instance;


  /// Detect edges of a document in an image file. Runs inside an Isolate.
  Future<EdgeDetectionOutput> detectEdges(File imageFile) async {
    try {
      final input = EdgeDetectionInput(imageFile.path);
      return await Isolate.run(() => _detectEdgesInternal(input));
    } catch (e) {
      debugPrint('DocumentScannerService.detectEdges error: $e');
      return EdgeDetectionOutput(0.15, 0.15, 0.85, 0.15, 0.85, 0.85, 0.15, 0.85);
    }
  }

  /// Apply perspective transform to crop and warp document. Runs inside an Isolate.
  Future<File?> perspectiveTransform(File imageFile, EdgeDetectionOutput corners) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/cropped_$timestamp.jpg';

      final input = PerspectiveInput(
        imagePath: imageFile.path,
        tlX: corners.tlX, tlY: corners.tlY,
        trX: corners.trX, trY: corners.trY,
        brX: corners.brX, brY: corners.brY,
        blX: corners.blX, blY: corners.blY,
        outputPath: outputPath,
      );

      final success = await Isolate.run(() => _perspectiveTransformInternal(input));
      if (success) {
        return File(outputPath);
      }
      return imageFile;
    } catch (e) {
      debugPrint('DocumentScannerService.perspectiveTransform error: $e');
      return imageFile;
    }
  }

  /// Crop an image interactively using the custom DocumentCropScreen.
  Future<File?> cropImage(BuildContext context, File imageFile) async {
    try {
      final croppedFile = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentCropScreen(imageFile: imageFile),
        ),
      );
      return croppedFile;
    } catch (e) {
      debugPrint('DocumentScannerService.cropImage error: $e');
      return imageFile;
    }
  }

  /// Apply a document enhancement filter to an image file. Runs inside an Isolate.
  Future<File?> applyFilter(File imageFile, DocumentFilter filter, [double intensity = 1.0]) async {
    if (filter == DocumentFilter.original) return imageFile;

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/scanned_$timestamp.jpg';

      final success = await Isolate.run(() async {
        final bytes = File(imageFile.path).readAsBytesSync();
        final original = img.decodeImage(bytes);
        if (original == null) return false;

        img.Image processed;
        switch (filter) {
          case DocumentFilter.grayscale:
            processed = _applyGrayscale(original);
            break;
          case DocumentFilter.fidelityColor:
            processed = _applyFidelityColor(original);
            break;
          case DocumentFilter.magicVivid:
            processed = _applyMagicVivid(original);
            break;
          case DocumentFilter.crispBW:
            processed = _applyCrispBW(original);
            break;
          default:
            processed = original;
        }

        if (intensity < 1.0 && filter != DocumentFilter.original) {
          processed = _blendImages(original, processed, intensity);
        }

        final encoded = img.encodeJpg(processed, quality: 90);
        File(outputPath).writeAsBytesSync(encoded);
        return true;
      });

      if (success) {
        return File(outputPath);
      }
      return imageFile;
    } catch (e) {
      debugPrint('DocumentScannerService.applyFilter error: $e');
      return imageFile;
    }
  }

  // ─────────────────────────────────────────────
  // Internal Image Processing Algorithms
  // ─────────────────────────────────────────────

  static EdgeDetectionOutput _detectEdgesInternal(EdgeDetectionInput input) {
    try {
      final bytes = File(input.imagePath).readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return EdgeDetectionOutput(0.15, 0.15, 0.85, 0.15, 0.85, 0.85, 0.15, 0.85);
      }

      final width = image.width;
      final height = image.height;
      
      // Downscale to 300px width for fast calculations
      final targetW = 300;
      final targetH = (height * targetW / width).round();
      final smallImg = img.copyResize(image, width: targetW, height: targetH);

      final grayscale = img.grayscale(smallImg);
      final gradients = List.filled(targetW * targetH, 0.0);

      for (int y = 1; y < targetH - 1; y++) {
        for (int x = 1; x < targetW - 1; x++) {
          double val(int px, int py) {
            return grayscale.getPixel(px, py).r.toDouble();
          }

          double gx = -val(x - 1, y - 1) + val(x + 1, y - 1) -
                      2 * val(x - 1, y) + 2 * val(x + 1, y) -
                      val(x - 1, y + 1) + val(x + 1, y + 1);

          double gy = -val(x - 1, y - 1) - 2 * val(x, y - 1) - val(x + 1, y - 1) +
                      val(x - 1, y + 1) + 2 * val(x, y + 1) + val(x + 1, y + 1);

          gradients[y * targetW + x] = gx * gx + gy * gy;
        }
      }

      final double cx = targetW / 2;
      final double cy = targetH / 2;

      Offset? searchDiag(double startX, double startY) {
        final dx = cx - startX;
        final dy = cy - startY;
        final steps = 80;
        double maxGrad = 0.0;
        int maxIdx = 0;

        for (int i = 6; i < steps - 15; i++) {
          final t = i / steps;
          final x = (startX + dx * t).round().clamp(0, targetW - 1);
          final y = (startY + dy * t).round().clamp(0, targetH - 1);

          final g = gradients[y * targetW + x];
          if (g > maxGrad) {
            maxGrad = g;
            maxIdx = i;
          }
        }

        // If gradient is above noise threshold, accept it as corner
        if (maxGrad > 20.0) {
          final t = maxIdx / steps;
          return Offset(
            (startX + dx * t) / targetW,
            (startY + dy * t) / targetH,
          );
        }
        return null;
      }

      final tl = searchDiag(0, 0) ?? const Offset(0.15, 0.15);
      final tr = searchDiag(targetW - 1.0, 0) ?? const Offset(0.85, 0.15);
      final br = searchDiag(targetW - 1.0, targetH - 1.0) ?? const Offset(0.85, 0.85);
      final bl = searchDiag(0, targetH - 1.0) ?? const Offset(0.15, 0.85);

      return EdgeDetectionOutput(
        tl.dx, tl.dy,
        tr.dx, tr.dy,
        br.dx, br.dy,
        bl.dx, bl.dy,
      );
    } catch (e) {
      return EdgeDetectionOutput(0.15, 0.15, 0.85, 0.15, 0.85, 0.85, 0.15, 0.85);
    }
  }

  static bool _perspectiveTransformInternal(PerspectiveInput input) {
    try {
      final bytes = File(input.imagePath).readAsBytesSync();
      final src = img.decodeImage(bytes);
      if (src == null) return false;

      final w = src.width.toDouble();
      final h = src.height.toDouble();

      final x0 = input.tlX * w; final y0 = input.tlY * h;
      final x1 = input.trX * w; final y1 = input.trY * h;
      final x2 = input.brX * w; final y2 = input.brY * h;
      final x3 = input.blX * w; final y3 = input.blY * h;

      double dist(double ax, double ay, double bx, double by) {
        final dx = bx - ax;
        final dy = by - ay;
        return math.sqrt(dx * dx + dy * dy);
      }

      final widthTop = dist(x0, y0, x1, y1);
      final widthBottom = dist(x3, y3, x2, y2);
      final dstWidth = ((widthTop + widthBottom) / 2).round().clamp(200, 3600);

      final heightLeft = dist(x0, y0, x3, y3);
      final heightRight = dist(x1, y1, x2, y2);
      final dstHeight = ((heightLeft + heightRight) / 2).round().clamp(200, 3600);

      final dst = img.Image(width: dstWidth, height: dstHeight);

      // Solve Homography that maps Destination (u, v) back to Source (x, y)
      final coeff = solveHomography(
        0.0, 0.0,
        dstWidth - 1.0, 0.0,
        dstWidth - 1.0, dstHeight - 1.0,
        0.0, dstHeight - 1.0,
        x0, y0,
        x1, y1,
        x2, y2,
        x3, y3,
      );

      if (coeff == null) {
        // Fallback: simple bilinear mapping
        for (int v = 0; v < dstHeight; v++) {
          final double dy = v / (dstHeight - 1);
          for (int u = 0; u < dstWidth; u++) {
            final double dx = u / (dstWidth - 1);
            final double sx = (1 - dx) * (1 - dy) * x0 +
                              dx * (1 - dy) * x1 +
                              (1 - dx) * dy * x3 +
                              dx * dy * x2;
            final double sy = (1 - dx) * (1 - dy) * y0 +
                              dx * (1 - dy) * y1 +
                              (1 - dx) * dy * y3 +
                              dx * dy * y2;
            _bilinearPixel(src, dst, u, v, sx, sy);
          }
        }
      } else {
        final a = coeff[0]; final b = coeff[1]; final c = coeff[2];
        final d = coeff[3]; final e = coeff[4]; final f = coeff[5];
        final g = coeff[6]; final h = coeff[7];

        for (int v = 0; v < dstHeight; v++) {
          for (int u = 0; u < dstWidth; u++) {
            final den = g * u + h * v + 1.0;
            final sx = (a * u + b * v + c) / den;
            final sy = (d * u + e * v + f) / den;
            _bilinearPixel(src, dst, u, v, sx, sy);
          }
        }
      }

      final encoded = img.encodeJpg(dst, quality: 92);
      File(input.outputPath).writeAsBytesSync(encoded);
      return true;
    } catch (e) {
      return false;
    }
  }

  static List<double>? solveHomography(
    double x0, double y0,
    double x1, double y1,
    double x2, double y2,
    double x3, double y3,
    double u0, double v0,
    double u1, double v1,
    double u2, double v2,
    double u3, double v3,
  ) {
    List<List<double>> A = List.generate(8, (_) => List.filled(8, 0.0));
    List<double> B = List.filled(8, 0.0);

    void setRow(int i, double x, double y, double u, double v) {
      A[i * 2] = [x, y, 1.0, 0.0, 0.0, 0.0, -u * x, -u * y];
      B[i * 2] = u;

      A[i * 2 + 1] = [0.0, 0.0, 0.0, x, y, 1.0, -v * x, -v * y];
      B[i * 2 + 1] = v;
    }

    setRow(0, x0, y0, u0, v0);
    setRow(1, x1, y1, u1, v1);
    setRow(2, x2, y2, u2, v2);
    setRow(3, x3, y3, u3, v3);

    // Solve using Gauss-Jordan elimination
    int n = 8;
    for (int i = 0; i < n; i++) {
      double maxEl = A[i][i].abs();
      int maxRow = i;
      for (int k = i + 1; k < n; k++) {
        if (A[k][i].abs() > maxEl) {
          maxEl = A[k][i].abs();
          maxRow = k;
        }
      }

      if (maxRow != i) {
        final tempA = A[i];
        A[i] = A[maxRow];
        A[maxRow] = tempA;

        final tempB = B[i];
        B[i] = B[maxRow];
        B[maxRow] = tempB;
      }

      if (A[i][i].abs() < 1e-10) {
        return null; // Singular matrix
      }

      for (int k = i + 1; k < n; k++) {
        double c = -A[k][i] / A[i][i];
        for (int j = i; j < n; j++) {
          if (i == j) {
            A[k][j] = 0.0;
          } else {
            A[k][j] += c * A[i][j];
          }
        }
        B[k] += c * B[i];
      }
    }

    List<double> x = List.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = B[i] / A[i][i];
      for (int k = i - 1; k >= 0; k--) {
        B[k] -= A[k][i] * x[i];
      }
    }
    return x;
  }

  static void _bilinearPixel(img.Image src, img.Image dst, int dstX, int dstY, double sx, double sy) {
    final w = src.width;
    final h = src.height;

    if (sx < 0 || sx >= w - 1 || sy < 0 || sy >= h - 1) {
      final cx = sx.clamp(0.0, w - 1.0).round();
      final cy = sy.clamp(0.0, h - 1.0).round();
      dst.setPixel(dstX, dstY, src.getPixel(cx, cy));
      return;
    }

    final xf = sx.floor();
    final yf = sy.floor();
    final xc = xf + 1;
    final yc = yf + 1;

    final dx = sx - xf;
    final dy = sy - yf;

    final p00 = src.getPixel(xf, yf);
    final p10 = src.getPixel(xc, yf);
    final p01 = src.getPixel(xf, yc);
    final p11 = src.getPixel(xc, yc);

    double interpolate(double v00, double v10, double v01, double v11) {
      return v00 * (1 - dx) * (1 - dy) +
             v10 * dx * (1 - dy) +
             v01 * (1 - dx) * dy +
             v11 * dx * dy;
    }

    final r = interpolate(p00.r.toDouble(), p10.r.toDouble(), p01.r.toDouble(), p11.r.toDouble());
    final g = interpolate(p00.g.toDouble(), p10.g.toDouble(), p01.g.toDouble(), p11.g.toDouble());
    final b = interpolate(p00.b.toDouble(), p10.b.toDouble(), p01.b.toDouble(), p11.b.toDouble());
    final a = interpolate(p00.a.toDouble(), p10.a.toDouble(), p01.a.toDouble(), p11.a.toDouble());

    dst.setPixelRgba(dstX, dstY, r.round(), g.round(), b.round(), a.round());
  }

  static img.Image _applyGrayscale(img.Image source) {
    try {
      return img.grayscale(source);
    } catch (_) {
      return source;
    }
  }

  static img.Image _applyFidelityColor(img.Image source) {
    try {
      var result = img.adjustColor(
        source,
        contrast: 1.25,
        brightness: 1.05,
        saturation: 1.05,
      );
      result = img.convolution(result, filter: [
        0, -0.2, 0,
        -0.2, 1.8, -0.2,
        0, -0.2, 0,
      ]);
      return result;
    } catch (_) {
      return source;
    }
  }

  static img.Image _applyMagicVivid(img.Image source) {
    try {
      var result = img.normalize(source, min: 5, max: 250);
      result = img.adjustColor(
        result,
        contrast: 1.45,
        brightness: 1.12,
        saturation: 1.35,
      );
      result = img.convolution(result, filter: [
        -0.1, -0.2, -0.1,
        -0.2, 2.2, -0.2,
        -0.1, -0.2, -0.1,
      ]);
      return result;
    } catch (_) {
      return source;
    }
  }

  static img.Image _applyCrispBW(img.Image source) {
    try {
      var result = img.grayscale(source);
      result = img.normalize(result, min: 0, max: 255);
      result = img.adjustColor(result, contrast: 2.2, brightness: 1.2);
      
      final w = result.width;
      final height = result.height;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < w; x++) {
          final p = result.getPixel(x, y);
          final luma = p.r; 
          final binaryVal = luma > 140 ? 255 : 0;
          result.setPixelRgba(x, y, binaryVal, binaryVal, binaryVal, p.a.round());
        }
      }
      return result;
    } catch (_) {
      try {
        return img.grayscale(source);
      } catch (_) {
        return source;
      }
    }
  }

  static img.Image _blendImages(img.Image original, img.Image processed, double intensity) {
    final blended = img.Image.from(processed);
    final w = processed.width;
    final h = processed.height;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pOrig = original.getPixel(x, y);
        final pProc = processed.getPixel(x, y);

        final r = (pOrig.r + (pProc.r - pOrig.r) * intensity).round().clamp(0, 255);
        final g = (pOrig.g + (pProc.g - pOrig.g) * intensity).round().clamp(0, 255);
        final b = (pOrig.b + (pProc.b - pOrig.b) * intensity).round().clamp(0, 255);
        final a = (pOrig.a + (pProc.a - pOrig.a) * intensity).round().clamp(0, 255);

        blended.setPixelRgba(x, y, r, g, b, a);
      }
    }
    return blended;
  }
}