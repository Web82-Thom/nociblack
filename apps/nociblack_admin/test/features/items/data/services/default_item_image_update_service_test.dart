import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/items/data/services/default_item_image_update_service.dart';
import 'package:nociblack/features/items/domain/entities/item_image.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/domain/repositories/item_image_repository.dart';
import 'package:nociblack/features/items/domain/services/image_processor.dart';
import 'package:nociblack/features/items/domain/services/item_image_storage_service.dart';

void main() {
  test(
    'removes, renumbers and appends images in final display order',
    () async {
      final repository = _FakeItemImageRepository();
      final storage = _FakeItemImageStorageService();
      final generatedIds = ['new-image-id'].iterator;
      final service = DefaultItemImageUpdateService(
        imageProcessor: _FakeImageProcessor(),
        storageService: storage,
        imageRepository: repository,
        generateImageId: () {
          generatedIds.moveNext();
          return generatedIds.current;
        },
      );
      final firstImage = _buildImage(id: 'image-1', displayOrder: 1);
      final secondImage = _buildImage(id: 'image-2', displayOrder: 2);

      await service.updateImages(
        itemId: 'item-id',
        existingImages: [firstImage, secondImage],
        removedExistingImages: [firstImage],
        newSourcePaths: const ['new.png'],
      );

      expect(repository.deletedImageIds, const ['image-1']);
      expect(repository.updatedPositions, const [
        _UpdatedPosition(imageId: 'image-2', displayOrder: 1, isPrimary: true),
      ]);
      expect(repository.createdImages, const [
        _CreatedImage(
          imageUrl: 'item-images/items/item-id/new-image-id.jpg',
          displayOrder: 2,
          isPrimary: false,
        ),
      ]);
      expect(storage.deletedPaths, const [
        'item-images/items/item-id/image-1.jpg',
      ]);
    },
  );

  test(
    'cleans newly uploaded objects when database persistence fails',
    () async {
      final storage = _FakeItemImageStorageService();
      final service = DefaultItemImageUpdateService(
        imageProcessor: _FakeImageProcessor(),
        storageService: storage,
        imageRepository: _FakeItemImageRepository(
          failure: const ItemImageSaveFailure(),
        ),
        generateImageId: () => 'new-image-id',
      );

      await expectLater(
        service.updateImages(
          itemId: 'item-id',
          existingImages: const [],
          removedExistingImages: const [],
          newSourcePaths: const ['new.png'],
        ),
        throwsA(isA<ItemImageSaveFailure>()),
      );

      expect(storage.deletedPaths, const [
        'item-images/items/item-id/new-image-id.jpg',
      ]);
    },
  );
}

ItemImage _buildImage({required String id, required int displayOrder}) {
  return ItemImage(
    id: id,
    itemId: 'item-id',
    imageUrl: 'item-images/items/item-id/$id.jpg',
    displayOrder: displayOrder,
    isPrimary: displayOrder == 1,
    createdAt: DateTime.utc(2026, 6, 25),
  );
}

final class _FakeImageProcessor implements ImageProcessor {
  @override
  bool isSupportedFormat(String filePath) => true;

  @override
  Future<ProcessedImage> processImage(String filePath) async {
    return ProcessedImage(
      bytes: Uint8List.fromList([1, 2, 3]),
      mimeType: 'image/jpeg',
      sizeBytes: 3,
    );
  }
}

final class _FakeItemImageStorageService implements ItemImageStorageService {
  final List<String> deletedPaths = [];

  @override
  Future<String> uploadItemImage({
    required String itemId,
    required String imageId,
    required Uint8List imageBytes,
  }) async {
    return 'item-images/items/$itemId/$imageId.jpg';
  }

  @override
  Future<void> deleteItemImage(String imagePath) async {
    deletedPaths.add(imagePath);
  }

  @override
  Future<void> deleteItemImages(List<String> imagePaths) async {
    deletedPaths.addAll(imagePaths);
  }
}

final class _FakeItemImageRepository implements ItemImageRepository {
  _FakeItemImageRepository({this.failure});

  final ItemFailure? failure;
  final List<String> deletedImageIds = [];
  final List<_UpdatedPosition> updatedPositions = [];
  final List<_CreatedImage> createdImages = [];

  @override
  Future<ItemImage> createItemImage({
    required String itemId,
    required String imageUrl,
    required int displayOrder,
    required bool isPrimary,
  }) async {
    if (failure case final failure?) throw failure;
    createdImages.add(
      _CreatedImage(
        imageUrl: imageUrl,
        displayOrder: displayOrder,
        isPrimary: isPrimary,
      ),
    );
    return _buildImage(id: 'created-image', displayOrder: displayOrder);
  }

  @override
  Future<void> deleteItemImagesByIds(List<String> imageIds) async {
    if (failure case final failure?) throw failure;
    deletedImageIds.addAll(imageIds);
  }

  @override
  Future<List<ItemImage>> getImagesByItemId(String itemId) async => const [];

  @override
  Future<void> updateItemImagePosition({
    required String imageId,
    required int displayOrder,
    required bool isPrimary,
  }) async {
    if (failure case final failure?) throw failure;
    updatedPositions.add(
      _UpdatedPosition(
        imageId: imageId,
        displayOrder: displayOrder,
        isPrimary: isPrimary,
      ),
    );
  }
}

final class _UpdatedPosition {
  const _UpdatedPosition({
    required this.imageId,
    required this.displayOrder,
    required this.isPrimary,
  });

  final String imageId;
  final int displayOrder;
  final bool isPrimary;

  @override
  bool operator ==(Object other) {
    return other is _UpdatedPosition &&
        other.imageId == imageId &&
        other.displayOrder == displayOrder &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode => Object.hash(imageId, displayOrder, isPrimary);
}

final class _CreatedImage {
  const _CreatedImage({
    required this.imageUrl,
    required this.displayOrder,
    required this.isPrimary,
  });

  final String imageUrl;
  final int displayOrder;
  final bool isPrimary;

  @override
  bool operator ==(Object other) {
    return other is _CreatedImage &&
        other.imageUrl == imageUrl &&
        other.displayOrder == displayOrder &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode => Object.hash(imageUrl, displayOrder, isPrimary);
}
