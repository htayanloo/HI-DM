import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/constants/app_constants.dart';

/// Handles temp file management and final file assembly.
class FileAssembler {
  final String tempDirectory;
  final int downloadId;

  FileAssembler({
    required this.tempDirectory,
    required this.downloadId,
  });

  /// Get the temp file path for a given segment index.
  String getTempFilePath(int segmentIndex) {
    return p.join(
      tempDirectory,
      '${AppConstants.tempFilePrefix}${downloadId}_$segmentIndex.tmp',
    );
  }

  /// Ensure the temp directory exists.
  Future<void> ensureTempDirectory() async {
    final dir = Directory(tempDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Check which segments already have temp files and their sizes.
  /// Returns a map of segment index -> bytes already downloaded.
  Future<Map<int, int>> detectExistingSegments(int segmentCount) async {
    final existing = <int, int>{};
    for (var i = 0; i < segmentCount; i++) {
      final file = File(getTempFilePath(i));
      if (await file.exists()) {
        existing[i] = await file.length();
      }
    }
    return existing;
  }

  /// Assemble all segment temp files into the final output file.
  /// Segments must be assembled in order (0, 1, 2, ...).
  Future<void> assemble({
    required String outputPath,
    required int segmentCount,
    required int expectedTotalSize,
    void Function(int assembledBytes)? onProgress,
  }) async {
    // Ensure output directory exists
    final outputDir = Directory(p.dirname(outputPath));
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final outputFile = File(outputPath);
    final sink = outputFile.openWrite();

    try {
      var totalAssembled = 0;

      for (var i = 0; i < segmentCount; i++) {
        final tempFile = File(getTempFilePath(i));
        if (!await tempFile.exists()) {
          throw FileAssemblyException(
            'Segment $i temp file not found: ${tempFile.path}',
          );
        }

        // Stream the temp file into the output
        await for (final chunk in tempFile.openRead()) {
          sink.add(chunk);
          totalAssembled += chunk.length;
          onProgress?.call(totalAssembled);
        }
      }

      await sink.flush();
    } finally {
      await sink.close();
    }

    // Verify file size
    if (expectedTotalSize > 0) {
      final actualSize = await outputFile.length();
      if (actualSize != expectedTotalSize) {
        throw FileAssemblyException(
          'Size mismatch: expected $expectedTotalSize bytes, got $actualSize bytes',
        );
      }
    }
  }

  /// Delete all temp files for this download.
  Future<void> cleanupTempFiles(int segmentCount) async {
    for (var i = 0; i < segmentCount; i++) {
      final file = File(getTempFilePath(i));
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Delete a specific segment's temp file.
  Future<void> deleteSegmentFile(int segmentIndex) async {
    final file = File(getTempFilePath(segmentIndex));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get total bytes downloaded across all temp files.
  Future<int> getTotalDownloadedBytes(int segmentCount) async {
    var total = 0;
    for (var i = 0; i < segmentCount; i++) {
      final file = File(getTempFilePath(i));
      if (await file.exists()) {
        total += await file.length();
      }
    }
    return total;
  }
}

class FileAssemblyException implements Exception {
  final String message;
  const FileAssemblyException(this.message);

  @override
  String toString() => 'FileAssemblyException: $message';
}
