import 'package:flutter/material.dart';
import 'package:nociblack/features/categories/domain/repositories/category_repository.dart';

import '../../domain/repositories/item_repository.dart';
import '../controllers/items_list_controller.dart';
import 'items_collection_page.dart';

/// Liste opérationnelle des articles brouillons et publiés.
final class ItemsListPage extends StatelessWidget {
  const ItemsListPage({
    required this.itemRepository,
    required this.categoryRepository,
    super.key,
  });

  final ItemRepository itemRepository;
  final CategoryRepository categoryRepository;

  @override
  Widget build(BuildContext context) {
    return ItemsCollectionPage(
      title: 'Articles',
      itemRepository: itemRepository,
      categoryRepository: categoryRepository,
      collection: ItemsCollection.current,
    );
  }
}
