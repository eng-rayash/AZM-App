import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import '../../../core/services/file_storage_service.dart';
import '../../../core/theme/neu_colors.dart';

/// Helper widget for displaying and opening archived files
class ArchiveFileHelper {
  /// Open a file from the archive
  ///
  /// Args:
  ///   - filePath: The full path to the file stored in archive
  ///   - onError: Callback for error handling
  static Future<void> openFile({
    required String? filePath,
    required Function(String error) onError,
  }) async {
    if (filePath == null || filePath.isEmpty) {
      onError('لا يوجد ملف مرفق بهذه المذكرة');
      return;
    }

    final file = await FileStorageService().getFile(filePath);

    if (file == null) {
      onError('الملف غير متاح - قد تم حذفه أو نقله');
      return;
    }

    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        onError('تعذر فتح الملف: ${result.message}');
      }
    } catch (e) {
      onError('خطأ في فتح الملف: $e');
    }
  }

  /// Display file info as a widget
  static Widget buildFileInfoWidget({
    required String? filePath,
    required BuildContext context,
  }) {
    if (filePath == null || filePath.isEmpty) {
      return const SizedBox.shrink();
    }

    final fileName = filePath.split(Platform.pathSeparator).last;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: NeuColors.info.withAlpha(100)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.description, color: NeuColors.info),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الملف المرفق:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: () => openFile(
                filePath: filePath,
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get file size display string
  static Future<String> getFileSizeDisplay(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return '';
    }

    try {
      final sizeBytes = await FileStorageService().getFileSize(filePath);
      if (sizeBytes == 0) return '';

      if (sizeBytes < 1024) {
        return '$sizeBytes B';
      } else if (sizeBytes < 1024 * 1024) {
        return '${(sizeBytes / 1024).toStringAsFixed(2)} KB';
      } else {
        return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      return '';
    }
  }
}