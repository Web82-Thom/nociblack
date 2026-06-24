import 'package:flutter/material.dart';

import '../../domain/repositories/item_repository.dart';
import '../controllers/items_list_controller.dart';
import 'items_collection_page.dart';

/// Historique fonctionnel V1 constitué des articles archivés.
final class ItemsHistoryPage extends StatelessWidget {
  const ItemsHistoryPage({required this.repository, super.key});

  final ItemRepository repository;

  @override
  Widget build(BuildContext context) {
    return ItemsCollectionPage(
      title: 'Historique',
      repository: repository,
      collection: ItemsCollection.archived,
    );
  }
}
