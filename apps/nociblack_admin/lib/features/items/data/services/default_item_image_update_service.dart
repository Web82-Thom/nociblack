import '../../domain/entities/item_image.dart';
import '../../domain/errors/item_failure.dart';
import '../../domain/repositories/item_image_repository.dart';
import '../../domain/services/image_processor.dart';
import '../../domain/services/item_image_storage_service.dart';
import '../../domain/services/item_image_update_service.dart';
import 'default_item_image_creation_service.dart';

/// Workflow applicatif de mise à jour des images d'un article existant.
///
/// Storage et PostgreSQL ne partagent pas de transaction. Les nouvelles images
/// sont donc uploadées avant la persistance, puis nettoyées si l'écriture DB
/// échoue. Les anciens objets Storage ne sont supprimés qu'après succès DB afin
/// de ne jamais perdre une image encore référencée.
final class DefaultItemImageUpdateService implements ItemImageUpdateService {
  const DefaultItemImageUpdateService({
    required ImageProcessor imageProcessor,
    required ItemImageStorageService storageService,
    required ItemImageRepository imageRepository,
    required ImageIdGenerator generateImageId,
  }) : _imageProcessor = imageProcessor,
       _storageService = storageService,
       _imageRepository = imageRepository,
       _generateImageId = generateImageId;

  final ImageProcessor _imageProcessor;
  final ItemImageStorageService _storageService;
  final ItemImageRepository _imageRepository;
  final ImageIdGenerator _generateImageId;

  @override
  Future<void> updateImages({
    required String itemId,
    required List<ItemImage> existingImages,
    required List<ItemImage> removedExistingImages,
    required List<String> newSourcePaths,
  }) async {
    final removedIds = removedExistingImages.map((image) => image.id).toSet();
    final keptImages =
        existingImages
            .where((image) => !removedIds.contains(image.id))
            .toList(growable: false)
          ..sort(
            (left, right) => left.displayOrder.compareTo(right.displayOrder),
          );

    final uploadedImageUrls = <String>[];

    try {
      for (final sourcePath in newSourcePaths) {
        if (!_imageProcessor.isSupportedFormat(sourcePath)) {
          throw const ItemImageUnsupportedFormatFailure();
        }

        final processedImage = await _imageProcessor.processImage(sourcePath);
        final imageUrl = await _storageService.uploadItemImage(
          itemId: itemId,
          imageId: _generateImageId(),
          imageBytes: processedImage.bytes,
        );
        uploadedImageUrls.add(imageUrl);
      }

      await _persistImageState(
        itemId: itemId,
        keptImages: keptImages,
        removedImages: removedExistingImages,
        uploadedImageUrls: uploadedImageUrls,
      );
    } on ItemFailure {
      await _cleanupUploadedImages(uploadedImageUrls);
      rethrow;
    } catch (_) {
      await _cleanupUploadedImages(uploadedImageUrls);
      throw const ItemImageSaveFailure();
    }

    await _deleteRemovedStorageObjects(removedExistingImages);
  }

  Future<void> _persistImageState({
    required String itemId,
    required List<ItemImage> keptImages,
    required List<ItemImage> removedImages,
    required List<String> uploadedImageUrls,
  }) async {
    await _imageRepository.deleteItemImagesByIds(
      removedImages.map((image) => image.id).toList(growable: false),
    );

    for (var index = 0; index < keptImages.length; index++) {
      await _imageRepository.updateItemImagePosition(
        imageId: keptImages[index].id,
        displayOrder: index + 1,
        isPrimary: index == 0,
      );
    }

    final firstNewImageOrder = keptImages.length + 1;
    for (var index = 0; index < uploadedImageUrls.length; index++) {
      final displayOrder = firstNewImageOrder + index;
      await _imageRepository.createItemImage(
        itemId: itemId,
        imageUrl: uploadedImageUrls[index],
        displayOrder: displayOrder,
        isPrimary: displayOrder == 1,
      );
    }
  }

  Future<void> _cleanupUploadedImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;

    try {
      await _storageService.deleteItemImages(imageUrls);
    } on ItemFailure {
      throw const ItemImageCleanupFailure();
    }
  }

  Future<void> _deleteRemovedStorageObjects(
    List<ItemImage> removedImages,
  ) async {
    if (removedImages.isEmpty) return;

    await _storageService.deleteItemImages(
      removedImages.map((image) => image.imageUrl).toList(growable: false),
    );
  }
}
