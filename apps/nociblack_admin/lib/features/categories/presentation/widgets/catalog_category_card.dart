import 'package:flutter/material.dart';

import '../../domain/entities/catalog_category.dart';

final class CatalogCategoryCard extends StatelessWidget {
  const CatalogCategoryCard({required this.category, super.key});

  final CatalogCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          category.isActive
              ? Icons.check_circle_outline
              : Icons.archive_outlined,
          color: category.isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        title: Text(category.name),
        subtitle: Text(
          category.isActive ? category.slug : '${category.slug} • Archivée',
        ),
        trailing: Text('Ordre ${category.displayOrder}'),
      ),
    );
  }
}
