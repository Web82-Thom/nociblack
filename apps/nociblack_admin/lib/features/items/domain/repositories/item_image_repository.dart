import '../entities/item_image.dart';

abstract interface class ItemImageRepository {
  Future<List<ItemImage>> getImagesByItemId(String itemId);
}