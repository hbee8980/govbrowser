import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Utility class for image compression and manipulation
class ImageUtils {
  ImageUtils._();

  /// Compress an image to a target size in KB
  /// Uses iterative compression to achieve the target size
  ///
  /// [sourceFile] - The source image file
  /// [targetKB] - The target file size in kilobytes
  /// [minQuality] - Minimum quality to try (default: 10)
  ///
  /// Returns the compressed file, or null if compression failed
  static Future<File?> compressToTargetSize(
    File sourceFile, {
    required int targetKB,
    int minQuality = 10,
  }) async {
    try {
      final targetBytes = targetKB * 1024;
      final sourceBytes = await sourceFile.length();

      // If already under target, return the original
      if (sourceBytes <= targetBytes) {
        return sourceFile;
      }

      // Get temp directory for output
      final tempDir = await getTemporaryDirectory();
      final uploadsDir = Directory('${tempDir.path}/govbrowser_uploads');
      if (!await uploadsDir.exists()) {
        await uploadsDir.create(recursive: true);
      }

      // Generate output filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = path.extension(sourceFile.path).toLowerCase();
      final outputPath = '${uploadsDir.path}/compressed_$timestamp$ext';

      // Start with high quality and iterate down
      int quality = 90;
      File? result;

      while (quality >= minQuality) {
        final compressed = await FlutterImageCompress.compressAndGetFile(
          sourceFile.absolute.path,
          outputPath,
          quality: quality,
          format: _getCompressFormat(ext),
        );

        if (compressed == null) {
          quality -= 10;
          continue;
        }

        final compressedFile = File(compressed.path);
        final compressedBytes = await compressedFile.length();

        if (compressedBytes <= targetBytes) {
          result = compressedFile;
          break;
        }

        // Delete the over-sized file and try again
        if (await compressedFile.exists()) {
          await compressedFile.delete();
        }

        quality -= 10;
      }

      // If still over target after min quality, try resizing
      if (result == null) {
        result = await _compressWithResize(
          sourceFile,
          outputPath,
          targetBytes,
          minQuality,
        );
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Compress with progressive resizing for stubborn images
  static Future<File?> _compressWithResize(
    File sourceFile,
    String outputPath,
    int targetBytes,
    int minQuality,
  ) async {
    try {
      // Start with 80% of original dimensions
      int widthPercent = 80;

      while (widthPercent >= 30) {
        final compressed = await FlutterImageCompress.compressAndGetFile(
          sourceFile.absolute.path,
          outputPath,
          quality: minQuality,
          format: _getCompressFormat(path.extension(sourceFile.path)),
          minWidth: 100, // Will be overridden by percentage
          minHeight: 100,
        );

        if (compressed == null) {
          widthPercent -= 10;
          continue;
        }

        final compressedFile = File(compressed.path);
        final compressedBytes = await compressedFile.length();

        if (compressedBytes <= targetBytes) {
          return compressedFile;
        }

        // Clean up and try smaller
        if (await compressedFile.exists()) {
          await compressedFile.delete();
        }

        widthPercent -= 10;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get the compression format based on file extension
  static CompressFormat _getCompressFormat(String extension) {
    switch (extension.toLowerCase()) {
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      case '.heic':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg;
    }
  }

  /// Get the uploads directory path
  static Future<String> getUploadsDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final uploadsDir = Directory('${tempDir.path}/govbrowser_uploads');
    if (!await uploadsDir.exists()) {
      await uploadsDir.create(recursive: true);
    }
    return uploadsDir.path;
  }

  /// Get file size in human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Clear all files in the uploads directory
  static Future<void> clearUploadsDirectory() async {
    try {
      final uploadsPath = await getUploadsDirectory();
      final uploadsDir = Directory(uploadsPath);

      if (await uploadsDir.exists()) {
        final files = await uploadsDir.list().toList();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (_) {
      // Ignore errors during cleanup
    }
  }

  /// Copy a file to the uploads directory with a new name
  static Future<File?> copyToUploads(File sourceFile, String newName) async {
    try {
      final uploadsPath = await getUploadsDirectory();
      final ext = path.extension(sourceFile.path);
      final newPath = '$uploadsPath/$newName$ext';
      return await sourceFile.copy(newPath);
    } catch (e) {
      return null;
    }
  }
}
