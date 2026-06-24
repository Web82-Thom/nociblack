import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/domain/services/item_image_creation_service.dart';

final class FakeItemImageCreationService implements ItemImageCreationService {
  FakeItemImageCreationService({this.failure});

  ItemFailure? failure;
  int calls = 0;
  String? lastItemId;
  List<String>? lastSourcePaths;

  @override
  Future<void> createImages({
    required String itemId,
    required List<String> sourcePaths,
  }) async {
    calls++;
    lastItemId = itemId;
    lastSourcePaths = List.unmodifiable(sourcePaths);
    if (failure case final failure?) throw failure;
  }
}
