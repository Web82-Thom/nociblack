import '../entities/item_image.dart';

abstract interface class ItemImageRepository {
  Future<List<ItemImage>> getImagesByItemId(String itemId);

  Future<ItemImage> createItemImage({
    required String itemId,
    required String imageUrl,
    required int displayOrder,
    required bool isPrimary,
  });
}
