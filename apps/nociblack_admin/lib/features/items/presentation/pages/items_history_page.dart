import 'package:flutter/material.dart';

import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/repositories/item_image_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/services/item_image_creation_service.dart';
import '../../domain/services/item_image_display_service.dart';
import '../../domain/services/item_image_update_service.dart';
import '../controllers/items_list_controller.dart';
import 'items_collection_page.dart';

/// Historique fonctionnel V1 constitué des articles archivés.
final class ItemsHistoryPage extends StatelessWidget {
  const ItemsHistoryPage({
    required this.itemRepository,
    required this.categoryRepository,
    required this.itemImageRepository,
    required this.itemImageCreationService,
    required this.itemImageUpdateService,
    required this.itemImageDisplayService,
    super.key,
  });

  final ItemRepository itemRepository;
  final CategoryRepository categoryRepository;
  final ItemImageRepository itemImageRepository;
  final ItemImageCreationService itemImageCreationService;
  final ItemImageUpdateService itemImageUpdateService;
  final ItemImageDisplayService itemImageDisplayService;

  @override
  Widget build(BuildContext context) {
    return ItemsCollectionPage(
      title: 'Historique',
      collection: ItemsCollection.archived,
      itemRepository: itemRepository,
      categoryRepository: categoryRepository,
      itemImageRepository: itemImageRepository,
      itemImageCreationService: itemImageCreationService,
      itemImageUpdateService: itemImageUpdateService,
      itemImageDisplayService: itemImageDisplayService,
    );
  }
}
