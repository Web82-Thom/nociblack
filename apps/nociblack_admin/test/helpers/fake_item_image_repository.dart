import 'package:nociblack/features/items/domain/entities/item_image.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/domain/repositories/item_image_repository.dart';

final class FakeItemImageRepository implements ItemImageRepository {
  FakeItemImageRepository({this.images = const [], this.failure});

  List<ItemImage> images;
  ItemFailure? failure;
  String? lastLoadedItemId;
  final List<ItemImage> createdImages = [];
  final List<String> deletedImageIds = [];
  final List<FakeItemImagePositionUpdate> updatedPositions = [];

  @override
  Future<List<ItemImage>> getImagesByItemId(String itemId) async {
    if (failure case final failure?) throw failure;
    lastLoadedItemId = itemId;
    return images.where((image) => image.itemId == itemId).toList();
  }

  @override
  Future<ItemImage> createItemImage({
    required String itemId,
    required String imageUrl,
    required int displayOrder,
    required bool isPrimary,
  }) async {
    if (failure case final failure?) throw failure;
    final image = ItemImage(
      id: 'created-image-${createdImages.length + 1}',
      itemId: itemId,
      imageUrl: imageUrl,
      displayOrder: displayOrder,
      isPrimary: isPrimary,
      createdAt: DateTime.utc(2026, 6, 25),
    );
    createdImages.add(image);
    return image;
  }

  @override
  Future<void> updateItemImagePosition({
    required String imageId,
    required int displayOrder,
    required bool isPrimary,
  }) async {
    if (failure case final failure?) throw failure;
    updatedPositions.add(
      FakeItemImagePositionUpdate(
        imageId: imageId,
        displayOrder: displayOrder,
        isPrimary: isPrimary,
      ),
    );
  }

  @override
  Future<void> deleteItemImagesByIds(List<String> imageIds) async {
    if (failure case final failure?) throw failure;
    deletedImageIds.addAll(imageIds);
  }
}

final class FakeItemImagePositionUpdate {
  const FakeItemImagePositionUpdate({
    required this.imageId,
    required this.displayOrder,
    required this.isPrimary,
  });

  final String imageId;
  final int displayOrder;
  final bool isPrimary;
}
