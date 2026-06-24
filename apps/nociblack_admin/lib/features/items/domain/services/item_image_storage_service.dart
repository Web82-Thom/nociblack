import 'dart:typed_data';

abstract interface class ItemImageStorageService {
  Future<String> uploadItemImage({
    required String itemId,
    required String imageId,
    required Uint8List imageBytes,
  });

  Future<void> deleteItemImage(String imagePath);

  Future<void> deleteItemImages(List<String> imagePaths);
}