import 'dart:typed_data';

class ProcessedImage {
  const ProcessedImage({
    required this.bytes,
    required this.mimeType,
    required this.sizeBytes,
  });

  final Uint8List bytes;
  final String mimeType;
  final int sizeBytes;
}

abstract interface class ImageProcessor {
  bool isSupportedFormat(String filePath);

  Future<ProcessedImage> processImage(String filePath);
}
