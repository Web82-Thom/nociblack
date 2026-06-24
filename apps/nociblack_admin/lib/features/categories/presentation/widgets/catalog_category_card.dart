import 'package:flutter/material.dart';

import '../../domain/entities/catalog_category.dart';

final class CatalogCategoryCard extends StatelessWidget {
  const CatalogCategoryCard({
    required this.category,
    required this.onEdit,
    required this.onToggleActive,
    super.key,
  });

  final CatalogCategory category;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        onTap: onEdit,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ordre ${category.displayOrder}'),
            PopupMenuButton<_CategoryAction>(
              tooltip: 'Actions de la catégorie',
              onSelected: (action) {
                switch (action) {
                  case _CategoryAction.edit:
                    onEdit();
                  case _CategoryAction.toggleActive:
                    onToggleActive();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: _CategoryAction.edit,
                  child: Text('Modifier'),
                ),
                PopupMenuItem(
                  value: _CategoryAction.toggleActive,
                  child: Text(category.isActive ? 'Archiver' : 'Réactiver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _CategoryAction { edit, toggleActive }
