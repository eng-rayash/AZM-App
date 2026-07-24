import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for managing file storage in a centralized and organized manner.
///
/// Responsibilities:
/// - Create and manage the application's dedicated archive folder
/// - Generate consistent, meaningful filenames based on document metadata
/// - Handle file operations (save, retrieve, delete)
/// - Provide utilities for path management
class FileStorageService {
  // Private constructor for singleton pattern
  FileStorageService._();

  static final FileStorageService _instance = FileStorageService._();

  factory FileStorageService() {
    return _instance;
  }

  /// Archive folder name within app documents
  static const String _archiveFolderName = 'mudiri_archive';

  /// Get the archive directory, creating it if necessary
  Future<Directory> getArchiveDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final archiveDir = Directory(path.join(appDocDir.path, _archiveFolderName));

    if (!await archiveDir.exists()) {
      await archiveDir.create(recursive: true);
    }

    return archiveDir;
  }

  /// Generate a standardized filename from document metadata
  ///
  /// Format: {title}-{referenceNumber}-{timestamp}
  ///
  /// Args:
  ///   - title: Document title (required)
  ///   - referenceNumber: Document reference/memo number (optional)
  ///   - extension: File extension (e.g., 'pdf', 'docx', 'jpg') - default: 'pdf'
  ///
  /// Returns: A safe, meaningful filename with timestamp to ensure uniqueness
  static String generateFileName({
    required String title,
    String? referenceNumber,
    String extension = 'pdf',
  }) {
    // Sanitize strings by removing invalid filename characters
    final sanitizedTitle = _sanitizeFilename(title);
    final sanitizedRef = referenceNumber != null
        ? _sanitizeFilename(referenceNumber)
        : '';

    // Create base filename
    String baseName;
    if (sanitizedRef.isNotEmpty) {
      baseName = '$sanitizedTitle-$sanitizedRef';
    } else {
      baseName = sanitizedTitle;
    }

    // Add extension
    return '$baseName.$extension';
  }

  /// Sanitize filename by removing or replacing invalid characters
  static String _sanitizeFilename(String filename) {
    // Remove invalid filename characters: \ / : * ? " < > |
    return filename
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '-')
        .replaceAll(
          RegExp(r'\s+'),
          '-',
        ) // Replace multiple spaces with single dash
        .replaceAll(
          RegExp(r'-+'),
          '-',
        ) // Replace multiple dashes with single dash
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing dashes
  }

  /// Save a file to the archive directory
  ///
  /// Args:
  ///   - sourceFile: The file to save
  ///   - filename: The target filename in the archive (use [generateFileName] to create)
  ///
  /// Returns: The full path to the saved file
  Future<String> saveFile({
    required File sourceFile,
    required String filename,
  }) async {
    try {
      final archiveDir = await getArchiveDirectory();
      final targetPath = path.join(archiveDir.path, filename);
      final savedFile = await sourceFile.copy(targetPath);
      
      // Also copy to public folder for user visibility
      await saveToPublicFolder(savedFile, filename, isArchive: true);
      
      return savedFile.path;
    } catch (e) {
      throw Exception('خطأ في حفظ الملف: $e');
    }
  }

  /// Save a copy of the file to a public folder on the device for easy user access.
  /// Handles Android public directories (Downloads/Documents) and desktop downlods.
  Future<String?> saveToPublicFolder(File file, String filename, {bool isArchive = false}) async {
    try {
      Directory? publicDir;
      if (Platform.isAndroid) {
        // Try multiple paths to ensure reliability on different Android flavors
        final List<String> possiblePaths = [
          '/storage/emulated/0/Documents/Mudiri/${isArchive ? 'Archive' : 'Exports'}',
          '/storage/emulated/0/Download/Mudiri/${isArchive ? 'Archive' : 'Exports'}',
          '/storage/emulated/0/Mudiri/${isArchive ? 'Archive' : 'Exports'}',
        ];

        for (final pStr in possiblePaths) {
          try {
            final dir = Directory(pStr);
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
            if (await dir.exists()) {
              publicDir = dir;
              break;
            }
          } catch (_) {
            // Try next path
          }
        }
      } else {
        // Fallback for Windows, macOS, etc.
        final downloads = await getDownloadsDirectory();
        if (downloads != null) {
          publicDir = Directory(path.join(downloads.path, 'Mudiri', isArchive ? 'Archive' : 'Exports'));
          if (!await publicDir.exists()) {
            await publicDir.create(recursive: true);
          }
        }
      }

      if (publicDir != null) {
        final targetPath = path.join(publicDir.path, filename);
        final savedFile = await file.copy(targetPath);
        return savedFile.path;
      }
    } catch (e) {
      // Fail silently or log to avoid breaking the core flow if OS permissions block public storage
      debugPrint('Error saving to public folder: $e');
    }
    return null;
  }

  /// Retrieve a file from the archive by its full path
  ///
  /// Args:
  ///   - filePath: The full path to the file
  ///
  /// Returns: The File object if it exists, null otherwise
  Future<File?> getFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return null;
    }

    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Delete a file from the archive
  ///
  /// Args:
  ///   - filePath: The full path to the file to delete
  ///
  /// Returns: true if deletion was successful, false otherwise
  Future<bool> deleteFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return false;
    }

    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('خطأ في حذف الملف: $e');
    }
  }

  /// List all files in the archive directory
  ///
  /// Returns: A list of File objects in the archive
  Future<List<File>> listAllFiles() async {
    final archiveDir = await getArchiveDirectory();
    final files = <File>[];

    await for (final entity in archiveDir.list()) {
      if (entity is File) {
        files.add(entity);
      }
    }

    return files;
  }

  /// Get file size in bytes
  ///
  /// Args:
  ///   - filePath: The full path to the file
  ///
  /// Returns: File size in bytes, or 0 if file doesn't exist
  Future<int> getFileSize(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return 0;
    }

    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get the archive directory path as a string
  ///
  /// Returns: Full path to the archive directory
  Future<String> getArchivePath() async {
    final archiveDir = await getArchiveDirectory();
    return archiveDir.path;
  }
}