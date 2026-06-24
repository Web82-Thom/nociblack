import 'package:flutter/material.dart';
import 'package:nociblack/features/categories/domain/repositories/category_repository.dart';
import 'package:nociblack/features/items/presentation/pages/item_form_page.dart';

import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/item_repository.dart';
import '../controllers/items_list_controller.dart';
import '../widgets/catalog_item_card.dart';
import '../widgets/permanent_item_deletion_dialog.dart';

/// Vue réutilisable pour les articles courants et les archives.
final class ItemsCollectionPage extends StatefulWidget {
  const ItemsCollectionPage({
    required this.title,
    required this.itemRepository,
    required this.categoryRepository,
    required this.collection,
    super.key,
  });

  final String title;
  final ItemRepository itemRepository;
  final CategoryRepository categoryRepository;
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
      repository: widget.itemRepository,
      collection: widget.collection,
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmArchive(String itemId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archivage'),
          content: const Text(
            'Êtes-vous sûr de vouloir archiver cet article ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final wasArchived = await _controller.archiveItem(itemId);
    if (!mounted) return;

    final message = wasArchived
        ? 'Article archivé.'
        : _controller.errorMessage ?? 'Impossible d’archiver l’article.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmRestore(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restauration'),
          content: const Text(
            'Restaurer cet article ? Il redeviendra un brouillon.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Restaurer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final wasRestored = await _controller.restoreItem(itemId);
    if (!mounted) return;

    final message = wasRestored
        ? 'Article restauré en brouillon.'
        : _controller.errorMessage ?? 'Impossible de restaurer l’article.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(CatalogItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => PermanentItemDeletionDialog(itemTitle: item.title),
    );

    if (confirmed != true || !mounted) return;

    final result = await _controller.deleteItem(item.id);
    if (!mounted) return;

    final message = switch (result) {
      null => _controller.errorMessage ?? 'Impossible de supprimer l’article.',
      final result when result.hasPendingStorageCleanup =>
        'Article supprimé. Le nettoyage des images sera repris automatiquement.',
      _ => 'Article supprimé définitivement.',
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openItemForm(CatalogItem item) async {
    final wasSaved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ItemFormPage(
          categoryRepository: widget.categoryRepository,
          itemRepository: widget.itemRepository,
          itemToEdit: item,
        ),
      ),
    );

    if (wasSaved == true) {
      await _controller.load();
    }
  }

  Widget _buildItemCard(CatalogItem item) {
    final isArchivedCollection =
        widget.collection == ItemsCollection.archived;
    final card = CatalogItemCard(
      item: item,
      onTap: !isArchivedCollection
          ? () => _openItemForm(item)
          : null,
    );

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: isArchivedCollection ? Colors.green : Colors.orange,
        child: Icon(
          isArchivedCollection ? Icons.restore : Icons.archive,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (isArchivedCollection &&
            direction == DismissDirection.startToEnd) {
          await _confirmRestore(item.id);
          return false;
        }

        if (direction == DismissDirection.startToEnd) {
          await _confirmArchive(item.id);
          return false;
        }

        if (direction == DismissDirection.endToStart) {
          await _confirmDelete(item);
          return false;
        }

        return false;
      },
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return switch (_controller.status) {
            ItemsListStatus.initial || ItemsListStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
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
                itemBuilder: (_, index) =>
                    _buildItemCard(_controller.items[index]),
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
