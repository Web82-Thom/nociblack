import 'package:flutter/material.dart';

import '../../domain/repositories/item_repository.dart';
import '../controllers/items_list_controller.dart';
import '../widgets/catalog_item_card.dart';

/// Vue réutilisable pour les articles courants et les archives.
final class ItemsCollectionPage extends StatefulWidget {
  const ItemsCollectionPage({
    required this.title,
    required this.repository,
    required this.collection,
    super.key,
  });

  final String title;
  final ItemRepository repository;
  final ItemsCollection collection;

  @override
  State<ItemsCollectionPage> createState() => _ItemsCollectionPageState();
}

final class _ItemsCollectionPageState extends State<ItemsCollectionPage> {
  late final ItemsListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ItemsListController(
      repository: widget.repository,
      collection: widget.collection,
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return switch (_controller.status) {
            ItemsListStatus.initial || ItemsListStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            ItemsListStatus.failure => _ItemsFailureView(
              message: _controller.errorMessage!,
              onRetry: _controller.load,
            ),
            ItemsListStatus.success when _controller.items.isEmpty =>
              _ItemsEmptyView(onRefresh: _controller.load),
            ItemsListStatus.success => RefreshIndicator(
              onRefresh: _controller.load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _controller.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return CatalogItemCard(item: _controller.items[index]);
                },
              ),
            ),
          };
        },
      ),
    );
  }
}

final class _ItemsFailureView extends StatelessWidget {
  const _ItemsFailureView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ItemsEmptyView extends StatelessWidget {
  const _ItemsEmptyView({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Icon(Icons.inventory_2_outlined, size: 48),
          SizedBox(height: 16),
          Text('Aucun article à afficher.', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
