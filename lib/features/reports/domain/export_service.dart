// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:excel/excel.dart' as exc;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils/arabic_reshaper.dart';

import '../../../core/security/security_logger.dart';
import '../../../core/database/providers/database_providers.dart';
import '../providers/reports_provider.dart';
import '../../../core/services/file_storage_service.dart';
import '../../../core/theme/neu_colors.dart';

/// Export format options centrally defined
enum ExportFormat {
  text,
  excel,
  pdf,
}

class ExportService {
  final SecurityLogger _logger;

  ExportService(this._logger);

  /// Decodes and formats a JSON array of strings or attendee maps into a single readable string
  String decodeJsonArray(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty || jsonStr == '[]') return '';
    try {
      final dynamic decoded = json.decode(jsonStr);
      if (decoded is List) {
        return decoded.map((e) {
          if (e is Map) {
            final name = e['name']?.toString() ?? '';
            final role = e['role']?.toString() ?? '';
            return role.isNotEmpty ? '$name ($role)' : name;
          }
          return e.toString();
        }).where((s) => s.isNotEmpty).join('، ');
      }
      return decoded.toString();
    } catch (_) {
      return jsonStr;
    }
  }

  Future<void> exportDailyReport(ReportsAnalytics analytics) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final StringBuffer sb = StringBuffer();
      sb.writeln('تقرير عزم اليومي - $dateStr');
      sb.writeln('-----------------------------------');
      sb.writeln('الاجتماعات: ${analytics.totalMeetings}');
      sb.writeln('المهام الإجمالية: ${analytics.totalTasks}');
      sb.writeln('المهام المكتملة: ${analytics.completedTasks}');
      sb.writeln('التوجيهات العاجلة: ${analytics.criticalDirectives}');
      sb.writeln('مواعيد اليوم: ${analytics.upcomingAppointments}');
      sb.writeln('نسبة إنجاز المهام: ${(analytics.taskCompletionRate * 100).toStringAsFixed(1)}%');
      sb.writeln('-----------------------------------');
      sb.writeln('تم إنشاؤه عبر تطبيق عزم لإدارة الأعمال.');

      // Write to temp file
      final tempDir = await getTemporaryDirectory();
      final filename = 'mudiri_report_$dateStr.txt';
      final tempFile = File('${tempDir.path}/$filename');
      await tempFile.writeAsString(sb.toString());

      // Save a copy to public folder on device
      await FileStorageService().saveToPublicFolder(tempFile, filename, isArchive: false);

      await _logger.logDataExport('تقرير يومي (نص)');

      await Share.shareXFiles([XFile(tempFile.path)], text: 'تقرير عزم اليومي');
    } catch (e) {
      // Handle error
    }
  }

  /// Core flexible method to export any list of items to CSV (Excel), Text, or Image
  Future<void> exportDataList<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required List<String> headers,
    required List<List<String>> Function(List<T>) itemMapper,
    required ExportFormat format,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final mappedRows = itemMapper(items);

      if (format == ExportFormat.text) {
        // 1. Export as Text
        final StringBuffer sb = StringBuffer();
        sb.writeln('تقرير عزم رسمي - $title');
        sb.writeln('تاريخ التصدير: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
        sb.writeln('--------------------------------------------------');
        for (var i = 0; i < mappedRows.length; i++) {
          sb.writeln('سجل رقم [${i + 1}]:');
          for (var j = 0; j < headers.length; j++) {
            sb.writeln('  - ${headers[j]}: ${mappedRows[i][j]}');
          }
          sb.writeln('--------------------------------------------------');
        }
        sb.writeln('تم التصدير عبر نظام عزم لإدارة الأعمال.');

        final tempDir = await getTemporaryDirectory();
        final filename = 'mudiri_export_$dateStr.txt';
        final file = File('${tempDir.path}/$filename');
        await file.writeAsString(sb.toString());

        final savedPath = await FileStorageService().saveToPublicFolder(file, filename, isArchive: false);
        if (savedPath != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ التصدير في مجلد التطبيق: $filename', textDirection: TextDirection.rtl),
              backgroundColor: NeuColors.primary,
            ),
          );
        }

        await _logger.logDataExport('$title (تقرير نصي)');
        await Share.shareXFiles([XFile(file.path)], text: 'تقرير $title');

      } else if (format == ExportFormat.excel) {
        // 2. Export as Native styled XLSX spreadsheet
        final excel = exc.Excel.createExcel();
        final sheetName = 'التقرير';
        final sheet = excel[sheetName];
        excel.setDefaultSheet(sheetName);
        if (excel.sheets.containsKey('Sheet1')) {
          excel.delete('Sheet1');
        }
        
        // Enable Right-to-Left (RTL) natively in Excel
        sheet.isRTL = true;

        // Border styles for header and cells
        final cellSideBorder = exc.Border(
          borderStyle: exc.BorderStyle.Thin,
          borderColorHex: exc.ExcelColor.fromHexString('#DCDCDC'),
        );

        final headerSideBorder = exc.Border(
          borderStyle: exc.BorderStyle.Thin,
          borderColorHex: exc.ExcelColor.fromHexString('#c5a880'),
        );

        final titleStyle = exc.CellStyle(
          backgroundColorHex: exc.ExcelColor.fromHexString('#F0F4F8'),
          fontColorHex: exc.ExcelColor.fromHexString('#1B2A4A'),
          fontSize: 13,
          bold: true,
          horizontalAlign: exc.HorizontalAlign.Center,
          verticalAlign: exc.VerticalAlign.Center,
          textWrapping: exc.TextWrapping.WrapText,
          leftBorder: headerSideBorder,
          rightBorder: headerSideBorder,
          topBorder: headerSideBorder,
          bottomBorder: headerSideBorder,
        );

        final headerStyle = exc.CellStyle(
          backgroundColorHex: exc.ExcelColor.fromHexString('#1B2A4A'),
          fontColorHex: exc.ExcelColor.fromHexString('#D4AF37'),
          fontSize: 11,
          bold: true,
          horizontalAlign: exc.HorizontalAlign.Center,
          verticalAlign: exc.VerticalAlign.Center,
          textWrapping: exc.TextWrapping.WrapText,
          leftBorder: headerSideBorder,
          rightBorder: headerSideBorder,
          topBorder: headerSideBorder,
          bottomBorder: headerSideBorder,
        );

        final evenRowStyleCenter = exc.CellStyle(
          backgroundColorHex: exc.ExcelColor.fromHexString('#F7F9FC'), // Zebra striping
          fontColorHex: exc.ExcelColor.fromHexString('#333333'),
          fontSize: 10,
          horizontalAlign: exc.HorizontalAlign.Center,
          verticalAlign: exc.VerticalAlign.Center,
          textWrapping: exc.TextWrapping.WrapText,
          leftBorder: cellSideBorder,
          rightBorder: cellSideBorder,
          topBorder: cellSideBorder,
          bottomBorder: cellSideBorder,
        );

        final evenRowStyleRight = exc.CellStyle(
          backgroundColorHex: exc.ExcelColor.fromHexString('#F7F9FC'), // Zebra striping
          fontColorHex: exc.ExcelColor.fromHexString('#333333'),
          fontSize: 10,
          horizontalAlign: exc.HorizontalAlign.Right,
          verticalAlign: exc.VerticalAlign.Center,
          textWrapping: exc.TextWrapping.WrapText,
          leftBorder: cellSideBorder,
          rightBorder: cellSideBorder,
          topBorder: cellSideBorder,
          bottomBorder: cellSideBorder,
        );

        final oddRowStyleCenter = exc.CellStyle(
          backgroundColorHex: exc.ExcelColor.fromHexString('#FFFFFF'),
          fontColorHex: exc.ExcelColor.fromHexString('#333333'),
          fontSize: 10,
          horizontalAlign: exc.HorizontalAlign.Center,
          verticalAlign: exc.VerticalAlign.Center,
          textWrapping: exc.TextWrapping.WrapText,
          leftBorder: cellSideBorder,
          rightBorder: cellSideBorder,
          topBorder: cellSideBorder,
          bottomBorder: cellSideBorder,
        );

        final oddRowStyleRight = exc.CellStyle(
          backgroundColorHex: exc.ExcelColor.fromHexString('#FFFFFF'),
          fontColorHex: exc.ExcelColor.fromHexString('#333333'),
          fontSize: 10,
          horizontalAlign: exc.HorizontalAlign.Right,
          verticalAlign: exc.VerticalAlign.Center,
          textWrapping: exc.TextWrapping.WrapText,
          leftBorder: cellSideBorder,
          rightBorder: cellSideBorder,
          topBorder: cellSideBorder,
          bottomBorder: cellSideBorder,
        );

        // 1. Report Title Row (merged across all columns)
        sheet.merge(
          exc.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
          exc.CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 0),
          customValue: exc.TextCellValue('$title - تم التصدير من تطبيق عزم لإدارة الأعمال'),
        );
        
        // Apply title style to all cells in the title row range to display borders/colors correctly
        for (int i = 0; i < headers.length; i++) {
          final cell = sheet.cell(exc.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.cellStyle = titleStyle;
        }

        // 2. Headers Row
        for (int col = 0; col < headers.length; col++) {
          final cell = sheet.cell(exc.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1));
          cell.value = exc.TextCellValue(headers[col]);
          cell.cellStyle = headerStyle;
        }

        // 3. Data Rows
        for (int rowIdx = 0; rowIdx < mappedRows.length; rowIdx++) {
          final row = mappedRows[rowIdx];
          for (int colIdx = 0; colIdx < row.length; colIdx++) {
            final cell = sheet.cell(exc.CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx + 2));
            cell.value = exc.TextCellValue(row[colIdx]);
            
            // Choose right alignment for long textual fields, center for short ones
            final header = headers[colIdx].trim();
            final isLongText = const [
              'العنوان', 'التفاصيل', 'المخرجات', 'القرارات', 'الاعمال', 
              'الملاحظات', 'الحضور', 'الغرض / السبب', 'التوجيه / العنوان', 
              'الملخص', 'الغرض', 'المكلف بالمهام'
            ].contains(header);
            
            if (rowIdx % 2 == 0) {
              cell.cellStyle = isLongText ? evenRowStyleRight : evenRowStyleCenter;
            } else {
              cell.cellStyle = isLongText ? oddRowStyleRight : oddRowStyleCenter;
            }
          }
        }

        // 4. Set professional column widths for Excel
        for (int colIdx = 0; colIdx < headers.length; colIdx++) {
          final header = headers[colIdx].trim();
          double width = 15.0; // Default width
          if (header == 'م') {
            width = 6.0;
          } else if (const ['التفاصيل', 'المخرجات', 'القرارات', 'الاعمال', 'الملاحظات', 'الحضور', 'الغرض / السبب', 'التوجيه / العنوان', 'الملخص', 'الغرض'].contains(header)) {
            width = 35.0;
          } else if (const ['الوقت', 'التاريخ', 'نوع المكالمة', 'وقت الدخول', 'وقت الخروج', 'المدة (دقائق)', 'تاريخ الاستحقاق', 'رقم الهاتف'].contains(header)) {
            width = 14.0;
          } else if (const ['هام', 'النوع', 'الحالة', 'الأهمية'].contains(header)) {
            width = 10.0;
          }
          sheet.setColumnWidth(colIdx, width);
        }

        // Save and write native XLSX file
        final fileBytes = excel.save();
        if (fileBytes == null) {
          throw Exception('فشل توليد ملف إكسل');
        }

        final tempDir = await getTemporaryDirectory();
        final filename = 'mudiri_excel_$dateStr.xlsx';
        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(fileBytes);

        final savedPath = await FileStorageService().saveToPublicFolder(file, filename, isArchive: false);
        if (savedPath != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ التصدير في مجلد التطبيق: $filename', textDirection: TextDirection.rtl),
              backgroundColor: NeuColors.primary,
            ),
          );
        }

        await _logger.logDataExport('$title (جدول إكسل XLSX)');
        await Share.shareXFiles([XFile(file.path)], text: 'جدول إكسل - $title');

      } else if (format == ExportFormat.pdf) {
        // 3. Export as Native styled PDF document
        final pdf = pw.Document();

        // Load custom Arabic font IBMPlexSansArabic from assets as requested by the user
        final fontData = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf');
        final arabicFont = pw.Font.ttf(fontData);

        final boldFontData = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf');
        final arabicFontBold = pw.Font.ttf(boldFontData);

        // Determine orientation and layout settings dynamically
        final isWide = headers.length > 6;
        final double cellFontSize = headers.length > 8 
            ? 7.5
            : (headers.length > 5 ? 8.5 : 10.0);
        final double headerFontSize = cellFontSize + 0.5;

        final cellPadding = headers.length > 8
            ? const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4)
            : const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6);

        final headerPadding = headers.length > 8
            ? const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 5)
            : const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8);

        // Executive Navy deep and gold color theme
        final primaryColor = PdfColor.fromHex('#1B2A4A');
        final accentColor = PdfColor.fromHex('#D4AF37');
        final borderColor = PdfColor.fromHex('#DCDCDC');
        final evenRowColor = PdfColor.fromHex('#F7F9FC');
        final oddRowColor = PdfColor.fromHex('#FFFFFF');

        // Text Styles
        final headerTextStyle = pw.TextStyle(
          font: arabicFontBold,
          fontSize: headerFontSize,
          color: accentColor,
        );

        final cellTextStyle = pw.TextStyle(
          font: arabicFont,
          fontSize: cellFontSize,
          color: PdfColor.fromHex('#333333'),
        );

        // Reshape headers and rows for Arabic compatibility in PDF
        final shapedHeaders = headers.map((h) => adjustArabicTextForPdf(h)).toList();

        final shapedRows = mappedRows.map((row) {
          return row.map((cell) => adjustArabicTextForPdf(cell)).toList();
        }).toList();

        // Generate pages
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginTop: 1.0 * PdfPageFormat.cm,
              marginBottom: 1.0 * PdfPageFormat.cm,
              marginLeft: 1.0 * PdfPageFormat.cm,
              marginRight: 1.0 * PdfPageFormat.cm,
            ),
            orientation: isWide ? pw.PageOrientation.landscape : pw.PageOrientation.portrait,
            textDirection: pw.TextDirection.rtl,
            // Removed header callback as requested: "ازل الراس والنصوص التي فيه ليظهر الجدول بشكل متناسق"
            footer: (pw.Context context) {
              return pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 1,
                      color: PdfColor.fromHex('#E0E0E0'),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          adjustArabicTextForPdf('تم التصدير عبر نظام عزم لإدارة الأعمال'),
                          style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColor.fromHex('#999999')),
                        ),
                        pw.Text(
                          adjustArabicTextForPdf('صفحة ${context.pageNumber} من ${context.pagesCount}'),
                          style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColor.fromHex('#999999')),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            build: (pw.Context context) {
              return [
                pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Table(
                    border: pw.TableBorder.all(
                      color: borderColor,
                      width: 0.5,
                    ),
                    columnWidths: {
                      for (int i = 0; i < shapedHeaders.length; i++)
                        i: _getColumnWidth(headers[shapedHeaders.length - 1 - i]),
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                        ),
                        children: List.generate(shapedHeaders.length, (colIdx) {
                          final header = headers[colIdx].trim();
                          final isLongText = const [
                            'العنوان', 'التفاصيل', 'المخرجات', 'القرارات', 'الاعمال', 
                            'الملاحظات', 'الحضور', 'الغرض / السبب', 'التوجيه / العنوان', 
                            'الملخص', 'الغرض', 'المكلف بالمهام'
                          ].contains(header);
                          
                          return pw.Padding(
                            padding: headerPadding,
                            child: pw.Container(
                              alignment: isLongText ? pw.Alignment.centerRight : pw.Alignment.center,
                              child: pw.Directionality(
                                textDirection: pw.TextDirection.ltr,
                                child: pw.Text(
                                  shapedHeaders[colIdx],
                                  style: headerTextStyle,
                                ),
                              ),
                            ),
                          );
                        }).reversed.toList(),
                      ),
                      // Data Rows
                      ...List.generate(shapedRows.length, (rowIdx) {
                        final row = shapedRows[rowIdx];
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: rowIdx % 2 == 0 ? evenRowColor : oddRowColor,
                          ),
                          children: List.generate(row.length, (colIdx) {
                            final header = headers[colIdx].trim();
                            final isLongText = const [
                              'العنوان', 'التفاصيل', 'المخرجات', 'القرارات', 'الاعمال', 
                              'الملاحظات', 'الحضور', 'الغرض / السبب', 'التوجيه / العنوان', 
                              'الملخص', 'الغرض', 'المكلف بالمهام'
                            ].contains(header);
                            
                            return pw.Padding(
                              padding: cellPadding,
                              child: pw.Container(
                                alignment: isLongText ? pw.Alignment.centerRight : pw.Alignment.center,
                                child: pw.Directionality(
                                  textDirection: pw.TextDirection.ltr,
                                  child: pw.Text(
                                    row[colIdx],
                                    style: cellTextStyle,
                                  ),
                                ),
                              ),
                            );
                          }).reversed.toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ];
            },
          ),
        );

        // Save PDF and share
        final fileBytes = await pdf.save();
        final tempDir = await getTemporaryDirectory();
        final filename = 'mudiri_report_$dateStr.pdf';
        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(fileBytes);

        final savedPath = await FileStorageService().saveToPublicFolder(file, filename, isArchive: false);
        if (savedPath != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حفظ التصدير في مجلد التطبيق: $filename', textDirection: TextDirection.rtl),
              backgroundColor: NeuColors.primary,
            ),
          );
        }

        await _logger.logDataExport('$title (تقرير PDF)');
        await Share.shareXFiles([XFile(file.path)], text: 'تقرير PDF - $title');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تصدير البيانات، الرجا، المحاولة لاحقاً')),
        );
      }
    }
  }

  /// Calculates dynamic column flex/fixed widths based on Arabic header text to ensure perfect layout spacing.
  pw.TableColumnWidth _getColumnWidth(String header) {
    final cleanHeader = header.trim();
    if (cleanHeader == 'م') {
      return const pw.FixedColumnWidth(20);
    }
    
    // Widen 'التفاصيل' column slightly as requested by the user
    if (cleanHeader == 'التفاصيل') {
      return const pw.FlexColumnWidth(2.4);
    }
    
    // Very short width items
    if (const [
      'هام',
      'النوع',
      'الحالة',
      'الأهمية'
    ].contains(cleanHeader)) {
      return const pw.FlexColumnWidth(0.6);
    }
    
    // Short width items (dates, times, status, phone number)
    if (const [
      'الوقت',
      'التاريخ',
      'نوع المكالمة',
      'وقت الدخول',
      'وقت الخروج',
      'المدة (دقائق)',
      'تاريخ الاستحقاق',
      'رقم الهاتف'
    ].contains(cleanHeader)) {
      return const pw.FlexColumnWidth(0.85);
    }
    
    // Long text items (descriptions, outcomes, decisions, agenda, notes, attendees, lists)
    if (const [
      'المخرجات',
      'القرارات',
      'الاعمال',
      'الملاحظات',
      'الحضور',
      'الغرض / السبب',
      'التوجيه / العنوان',
      'الملخص',
      'الغرض',
      'المكلف بالمهام'
    ].contains(cleanHeader)) {
      return const pw.FlexColumnWidth(1.8);
    }
    
    // Default / Medium text items (e.g. العنوان, الجهة / الشركة, اسم الزائر, اسم المتصل, المكان, إلخ)
    return const pw.FlexColumnWidth(1.2);
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return ExportService(logger);
});