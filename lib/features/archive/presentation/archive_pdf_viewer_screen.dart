import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';

/// Screen for displaying/previewing a compiled memo PDF.
/// Offers offline viewing, sharing, and physical printing.
class ArchivePdfViewerScreen extends StatelessWidget {
  const ArchivePdfViewerScreen({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  final String pdfPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final file = File(pdfPath);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: file.existsSync()
            ? Theme(
                // Overriding printing library theme to match our application style
                data: Theme.of(context).copyWith(
                  primaryColor: NeuColors.navyDeep,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: NeuColors.navyDeep,
                    brightness: Theme.of(context).brightness,
                  ),
                ),
                child: PdfPreview(
                  build: (format) => file.readAsBytesSync(),
                  allowPrinting: true,
                  allowSharing: true,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  initialPageFormat: PdfPageFormat.a4,
                  pdfFileName: '${title.replaceAll(" ", "_")}.pdf',
                  loadingWidget: const Center(child: CircularProgressIndicator()),
                  // Custom theme styling for PdfPreview widgets
                  pdfPreviewPageDecoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: isDark ? NeuColors.priorityCritical : Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'الملف غير موجود أو تم حذفه.',
                        style: isDark ? AppTypography.bodyDark : AppTypography.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}