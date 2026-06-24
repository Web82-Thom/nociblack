import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nociblack/features/items/data/services/default_item_image_creation_service.dart';
import 'package:nociblack/features/items/domain/entities/item_image.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/domain/repositories/item_image_repository.dart';
import 'package:nociblack/features/items/domain/services/image_processor.dart';
import 'package:nociblack/features/items/domain/services/item_image_storage_service.dart';

void main() {
  test('processes, uploads and persists images in display order', () async {
    final processor = _FakeImageProcessor();
    final storage = _FakeItemImageStorageService();
    final repository = _FakeItemImageRepository();
    final generatedIds = ['image-id-1', 'image-id-2'].iterator;
    final service = DefaultItemImageCreationService(
      imageProcessor: processor,
      storageService: storage,
      imageRepository: repository,
      generateImageId: () {
        generatedIds.moveNext();
        return generatedIds.current;
      },
    );

    await service.createImages(
      itemId: 'item-id',
      sourcePaths: const ['first.png', 'second.heic'],
    );

    expect(processor.processedPaths, const ['first.png', 'second.heic']);
    expect(storage.uploadedImageIds, const ['image-id-1', 'image-id-2']);
    expect(repository.createdImages, [
      const _CreatedImageCall(
        imageUrl: 'item-images/items/item-id/image-id-1.jpg',
        displayOrder: 1,
        isPrimary: true,
      ),
      const _CreatedImageCall(
        imageUrl: 'item-images/items/item-id/image-id-2.jpg',
        displayOrder: 2,
        isPrimary: false,
      ),
    ]);
  });

  test('rejects an unsupported source before processing or upload', () async {
    final processor = _FakeImageProcessor(supported: false);
    final storage = _FakeItemImageStorageService();
    final service = DefaultItemImageCreationService(
      imageProcessor: processor,
      storageService: storage,
      imageRepository: _FakeItemImageRepository(),
      generateImageId: () => 'unused',
    );

    await expectLater(
      service.createImages(
        itemId: 'item-id',
        sourcePaths: const ['document.pdf'],
      ),
      throwsA(isA<ItemImageUnsupportedFormatFailure>()),
    );

    expect(processor.processedPaths, isEmpty);
    expect(storage.uploadedImageIds, isEmpty);
  });

  test('removes the uploaded object when database persistence fails', () async {
    final storage = _FakeItemImageStorageService();
    final service = DefaultItemImageCreationService(
      imageProcessor: _FakeImageProcessor(),
      storageService: storage,
      imageRepository: _FakeItemImageRepository(
        failure: const ItemImageSaveFailure(),
      ),
      generateImageId: () => 'image-id',
    );

    await expectLater(
      service.createImages(itemId: 'item-id', sourcePaths: const ['first.png']),
      throwsA(isA<ItemImageSaveFailure>()),
    );

    expect(storage.deletedPaths, const [
      'item-images/items/item-id/image-id.jpg',
    ]);
  });
}

final class _FakeImageProcessor implements ImageProcessor {
  _FakeImageProcessor({this.supported = true});

  final bool supported;
  final List<String> processedPaths = [];

  @override
  bool isSupportedFormat(String filePath) => supported;

  @override
  Future<ProcessedImage> processImage(String filePath) async {
    processedPaths.add(filePath);
    return ProcessedImage(
      bytes: Uint8List.fromList([1, 2, 3]),
      mimeType: 'image/jpeg',
      sizeBytes: 3,
    );
  }
}

final class _FakeItemImageStorageService implements ItemImageStorageService {
  final List<String> uploadedImageIds = [];
  final List<String> deletedPaths = [];

  @override
  Future<String> uploadItemImage({
    required String itemId,
    required String imageId,
    required Uint8List imageBytes,
  }) async {
    uploadedImageIds.add(imageId);
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
  final List<_CreatedImageCall> createdImages = [];

  @override
  Future<ItemImage> createItemImage({
    required String itemId,
    required String imageUrl,
    required int displayOrder,
    required bool isPrimary,
  }) async {
    if (failure case final failure?) throw failure;
    createdImages.add(
      _CreatedImageCall(
        imageUrl: imageUrl,
        displayOrder: displayOrder,
        isPrimary: isPrimary,
      ),
    );
    return ItemImage(
      id: 'image-$displayOrder',
      itemId: itemId,
      imageUrl: imageUrl,
      displayOrder: displayOrder,
      isPrimary: isPrimary,
      createdAt: DateTime.utc(2026, 6, 25),
    );
  }

  @override
  Future<List<ItemImage>> getImagesByItemId(String itemId) async => const [];
}

final class _CreatedImageCall {
  const _CreatedImageCall({
    required this.imageUrl,
    required this.displayOrder,
    required this.isPrimary,
  });

  final String imageUrl;
  final int displayOrder;
  final bool isPrimary;

  @override
  bool operator ==(Object other) {
    return other is _CreatedImageCall &&
        other.imageUrl == imageUrl &&
        other.displayOrder == displayOrder &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode => Object.hash(imageUrl, displayOrder, isPrimary);
}
