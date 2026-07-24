import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../../features/reports/domain/export_service.dart';


/// Export Button — shows export format options in a popup.
///
/// Displays the count of items to export and opens
/// a menu with format choices.
class ExportButton extends StatelessWidget {
  const ExportButton({
    super.key,
    required this.itemCount,
    required this.onExport,
  });

  final int itemCount;
  final void Function(ExportFormat format) onExport;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<ExportFormat>(
      onSelected: onExport,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.ios_share_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            size: 20,
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$itemCount',
              style: const TextStyle(
                color: NeuColors.textOnDark,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => [
        _buildItem(
          ExportFormat.text,
          Icons.text_snippet_rounded,
          'تصدير كنص',
          isDark,
        ),
        _buildItem(
          ExportFormat.excel,
          Icons.table_chart_rounded,
          'تصدير Excel',
          isDark,
        ),
        _buildItem(
          ExportFormat.pdf,
          Icons.picture_as_pdf_rounded,
          'تصدير PDF',
          isDark,
        ),
      ],
    );
  }

  PopupMenuItem<ExportFormat> _buildItem(
    ExportFormat format,
    IconData icon,
    String label,
    bool isDark,
  ) {
    return PopupMenuItem<ExportFormat>(
      value: format,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Icon(icon, size: 20,
              color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(label,
              style: isDark ? AppTypography.bodyDark : AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}