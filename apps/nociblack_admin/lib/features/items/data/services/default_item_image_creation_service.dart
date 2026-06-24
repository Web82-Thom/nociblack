import '../../domain/errors/item_failure.dart';
import '../../domain/repositories/item_image_repository.dart';
import '../../domain/services/image_processor.dart';
import '../../domain/services/item_image_creation_service.dart';
import '../../domain/services/item_image_storage_service.dart';

typedef ImageIdGenerator = String Function();

/// Workflow applicatif d'ajout d'images.
///
/// Storage et PostgreSQL ne partagent pas de transaction. Si la création de la
/// ligne échoue après l'upload, l'objet courant est donc supprimé immédiatement.
/// Le contrôleur reste responsable de la compensation globale de l'article si
/// une étape de la série échoue.
final class DefaultItemImageCreationService
    implements ItemImageCreationService {
  const DefaultItemImageCreationService({
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
  Future<void> createImages({
    required String itemId,
    required List<String> sourcePaths,
  }) async {
    for (var index = 0; index < sourcePaths.length; index++) {
      final sourcePath = sourcePaths[index];
      if (!_imageProcessor.isSupportedFormat(sourcePath)) {
        throw const ItemImageUnsupportedFormatFailure();
      }

      final processedImage = await _imageProcessor.processImage(sourcePath);
      final imageUrl = await _storageService.uploadItemImage(
        itemId: itemId,
        imageId: _generateImageId(),
        imageBytes: processedImage.bytes,
      );

      try {
        await _imageRepository.createItemImage(
          itemId: itemId,
          imageUrl: imageUrl,
          displayOrder: index + 1,
          isPrimary: index == 0,
        );
      } on ItemFailure {
        await _cleanupUploadedImage(imageUrl);
        rethrow;
      } catch (_) {
        await _cleanupUploadedImage(imageUrl);
        throw const ItemImageSaveFailure();
      }
    }
  }

  Future<void> _cleanupUploadedImage(String imageUrl) async {
    try {
      await _storageService.deleteItemImage(imageUrl);
    } on ItemFailure {
      throw const ItemImageCleanupFailure();
    }
  }
}
