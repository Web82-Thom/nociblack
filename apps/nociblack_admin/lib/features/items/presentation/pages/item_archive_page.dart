import 'package:flutter/material.dart';

import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/services/item_image_creation_service.dart';
import '../controllers/items_list_controller.dart';
import 'items_collection_page.dart';

/// Liste en lecture seule des articles archivés.
final class ItemArchivePage extends StatelessWidget {
  const ItemArchivePage({
    required this.itemRepository,
    required this.categoryRepository,
    required this.itemImageCreationService,
    super.key,
  });

  final ItemRepository itemRepository;
  final CategoryRepository categoryRepository;
  final ItemImageCreationService itemImageCreationService;

  @override
  Widget build(BuildContext context) {
    return ItemsCollectionPage(
      title: 'Archives',
      itemRepository: itemRepository,
      categoryRepository: categoryRepository,
      itemImageCreationService: itemImageCreationService,
      collection: ItemsCollection.archived,
    );
  }
}
