import 'package:flutter/material.dart';

import '../../../../core/formatters/price_formatter.dart';
import '../../domain/entities/catalog_item.dart';

/// Résumé d'un article dans une liste administrative.
final class CatalogItemCard extends StatelessWidget {
  const CatalogItemCard({required this.item, super.key});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(item.title, style: theme.textTheme.titleMedium),
                ),
                const SizedBox(width: 12),
                _ItemStatusChip(status: item.status),
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
    );
  }
}

final class _ItemStatusChip extends StatelessWidget {
  const _ItemStatusChip({required this.status});

  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ItemStatus.draft => 'Brouillon',
      ItemStatus.published => 'Publié',
      ItemStatus.archived => 'Archivé',
    };

    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label),
    );
  }
}
