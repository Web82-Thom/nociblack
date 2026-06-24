import 'package:nociblack/features/items/domain/entities/catalog_item.dart';
import 'package:nociblack/features/items/domain/entities/item_draft.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/domain/repositories/item_repository.dart';

final class FakeItemRepository implements ItemRepository {
  FakeItemRepository({
    this.currentItems = const [],
    this.archivedItems = const [],
    this.currentFailure,
    this.archivedFailure,
    this.saveFailure,
  });

  List<CatalogItem> currentItems;
  List<CatalogItem> archivedItems;
  ItemFailure? currentFailure;
  ItemFailure? archivedFailure;
  ItemFailure? saveFailure;
  ItemDraft? lastCreatedDraft;
  int currentCalls = 0;
  int archivedCalls = 0;

  @override
  Future<List<CatalogItem>> getCurrentItems() async {
    currentCalls++;
    if (currentFailure case final failure?) throw failure;
    return currentItems;
  }

  @override
  Future<List<CatalogItem>> getArchivedItems() async {
    archivedCalls++;
    if (archivedFailure case final failure?) throw failure;
    return archivedItems;
  }

  @override
  Future<CatalogItem> createItem(ItemDraft draft) async {
    if (saveFailure case final failure?) throw failure;
    lastCreatedDraft = draft;
    final now = DateTime.utc(2026, 6, 24, 12);
    final item = CatalogItem(
      id: 'created-item-id',
      categoryId: draft.categoryId,
      categoryName: 'Catégorie test',
      title: draft.title,
      description: draft.description,
      priceCents: draft.priceCents,
      stockQuantity: draft.stockQuantity,
      sku: draft.sku,
      status: ItemStatus.draft,
      displayOrder: draft.displayOrder,
      createdAt: now,
      updatedAt: now,
    );
    currentItems = [...currentItems, item];
    return item;
  }
}
