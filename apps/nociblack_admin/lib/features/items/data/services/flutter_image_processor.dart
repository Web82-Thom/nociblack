import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

import '../../domain/errors/item_failure.dart';
import '../../domain/services/image_processor.dart';

final class FlutterImageProcessor implements ImageProcessor {
  static const int _maxWidth = 1200;
  static const int _quality = 80;
  static const int _maxSizeBytes = 5 * 1024 * 1024;

  static const Set<String> _supportedExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.heic',
    '.heif',
  };

  @override
  bool isSupportedFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    return _supportedExtensions.contains(extension);
  }

  @override
  Future<ProcessedImage> processImage(String filePath) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: _maxWidth,
        quality: _quality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        throw const ItemImageProcessingFailure();
      }

      final bytes = Uint8List.fromList(compressedBytes);

      if (bytes.lengthInBytes > _maxSizeBytes) {
        throw const ItemImageTooLargeFailure();
      }

      return ProcessedImage(
        bytes: bytes,
        mimeType: 'image/jpeg',
        sizeBytes: bytes.lengthInBytes,
      );
    } on ItemFailure {
      rethrow;
    } catch (_) {
      throw const ItemImageProcessingFailure();
    }
  }
}
