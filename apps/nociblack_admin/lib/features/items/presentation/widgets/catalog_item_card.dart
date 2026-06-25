import 'package:flutter/material.dart';
import '../../../../core/formatters/price_formatter.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/services/item_image_display_service.dart';
import 'item_primary_image.dart';

/// Résumé d'un article dans une liste administrative.
final class CatalogItemCard extends StatelessWidget {
  const CatalogItemCard({
    required this.item,
    required this.imageDisplayService,
    this.onTap,
    this.onPublishPressed,
    super.key,
  });

  final CatalogItem item;
  final ItemImageDisplayService imageDisplayService;
  final VoidCallback? onTap;
  final VoidCallback? onPublishPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemPrimaryImage(
                imagePath: item.primaryImagePath,
                displayService: imageDisplayService,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _ItemStatusChip(
                          status: item.status,
                          onPublishPressed: onPublishPressed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${item.categoryName} • REF ${item.sku}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          PriceFormatter.inEuros(item.priceCents),
                          style: theme.textTheme.titleSmall,
                        ),
                        const Spacer(),
                        Text('Stock : ${item.stockQuantity}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ItemStatusChip extends StatelessWidget {
  const _ItemStatusChip({required this.status, required this.onPublishPressed});

  final ItemStatus status;
  final VoidCallback? onPublishPressed;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ItemStatus.draft => ActionChip(
        visualDensity: VisualDensity.compact,
        avatar: const Icon(
          Icons.publish_outlined,
          size: 18,
          color: Colors.orange,
        ),
        label: const Text(
          'Publier',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
        ),
        onPressed: onPublishPressed,
      ),
      ItemStatus.published => const Chip(
        visualDensity: VisualDensity.compact,
        avatar: Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
        label: Text(
          'Publié',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
        ),
      ),
      ItemStatus.archived => const Chip(
        visualDensity: VisualDensity.compact,
        avatar: Icon(Icons.archive_outlined, size: 18),
        label: Text('Archivé'),
      ),
    };
  }
}
