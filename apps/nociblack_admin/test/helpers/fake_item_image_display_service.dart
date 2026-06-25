import 'package:nociblack/features/items/domain/services/item_image_display_service.dart';

final class FakeItemImageDisplayService implements ItemImageDisplayService {
  FakeItemImageDisplayService({this.failure});

  Object? failure;
  final List<String> requestedPaths = [];

  @override
  Future<String> createDisplayUrl(String imagePath) async {
    requestedPaths.add(imagePath);

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }

    return 'https://images.test/$imagePath';
  }
}
