import '../entities/catalog_item.dart';
import '../entities/item_draft.dart';

/// Contrat de lecture du catalogue administratif.
abstract interface class ItemRepository {
  /// Articles exploitables dans le catalogue : brouillons et publiés.
  Future<List<CatalogItem>> getCurrentItems();

  /// Articles archivés, du plus récemment modifié au plus ancien.
  Future<List<CatalogItem>> getArchivedItems();

  Future<CatalogItem> createItem(ItemDraft draft);

  Future<CatalogItem> updateItem({
    required String itemId,
    required ItemDraft draft,
  });

  Future<void> archiveItem(String itemId);

  /// Restaure un article archivé en brouillon, conformément à la règle métier.
  Future<void> restoreItem(String itemId);
}
