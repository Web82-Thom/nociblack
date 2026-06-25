import 'package:nociblack/features/items/domain/entities/item_image.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/domain/services/item_image_update_service.dart';

final class FakeItemImageUpdateService implements ItemImageUpdateService {
  FakeItemImageUpdateService({this.failure});

  ItemFailure? failure;
  int calls = 0;
  String? lastItemId;
  List<ItemImage>? lastExistingImages;
  List<ItemImage>? lastRemovedExistingImages;
  List<String>? lastNewSourcePaths;

  @override
  Future<void> updateImages({
    required String itemId,
    required List<ItemImage> existingImages,
    required List<ItemImage> removedExistingImages,
    required List<String> newSourcePaths,
  }) async {
    calls++;
    lastItemId = itemId;
    lastExistingImages = List.unmodifiable(existingImages);
    lastRemovedExistingImages = List.unmodifiable(removedExistingImages);
    lastNewSourcePaths = List.unmodifiable(newSourcePaths);
    if (failure case final failure?) throw failure;
  }
}
