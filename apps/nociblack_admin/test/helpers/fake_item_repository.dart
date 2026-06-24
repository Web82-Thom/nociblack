import 'package:nociblack/features/items/domain/entities/catalog_item.dart';
import 'package:nociblack/features/items/domain/entities/item_deletion_result.dart';
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
    this.archiveFailure,
    this.restoreFailure,
    this.deleteFailure,
    this.deletionResult = const ItemDeletionResult(
      pendingStorageObjectCount: 0,
    ),
  });

  List<CatalogItem> currentItems;
  List<CatalogItem> archivedItems;
  ItemFailure? currentFailure;
  ItemFailure? archivedFailure;
  ItemFailure? saveFailure;
  ItemFailure? archiveFailure;
  ItemFailure? restoreFailure;
  ItemFailure? deleteFailure;
  ItemDeletionResult deletionResult;
  ItemDraft? lastCreatedDraft;
  int currentCalls = 0;
  int archivedCalls = 0;
  ItemDraft? lastUpdatedDraft;
  String? lastUpdatedItemId;
  String? lastArchivedItemId;
  int archiveCalls = 0;
  String? lastRestoredItemId;
  int restoreCalls = 0;
  String? lastDeletedItemId;
  int deleteCalls = 0;
  int retryCleanupCalls = 0;

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

  @override
  Future<CatalogItem> updateItem({
    required String itemId,
    required ItemDraft draft,
  }) async {
    if (saveFailure case final failure?) throw failure;

    lastUpdatedItemId = itemId;
    lastUpdatedDraft = draft;

    final now = DateTime.utc(2026, 6, 24, 12);

    final updatedItem = CatalogItem(
      id: itemId,
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

    currentItems = [
      for (final currentItem in currentItems)
        if (currentItem.id == itemId) updatedItem else currentItem,
    ];

    return updatedItem;
  }

  @override
  Future<void> archiveItem(String itemId) async {
    archiveCalls++;
    if (archiveFailure case final failure?) throw failure;

    lastArchivedItemId = itemId;
    currentItems = [
      for (final item in currentItems)
        if (item.id != itemId) item,
    ];
  }

  @override
  Future<void> restoreItem(String itemId) async {
    restoreCalls++;
    if (restoreFailure case final failure?) throw failure;

    final archivedItem = archivedItems.firstWhere((item) => item.id == itemId);
    lastRestoredItemId = itemId;
    archivedItems = [
      for (final item in archivedItems)
        if (item.id != itemId) item,
    ];
    currentItems = [
      ...currentItems,
      CatalogItem(
        id: archivedItem.id,
        categoryId: archivedItem.categoryId,
        categoryName: archivedItem.categoryName,
        title: archivedItem.title,
        description: archivedItem.description,
        priceCents: archivedItem.priceCents,
        stockQuantity: archivedItem.stockQuantity,
        sku: archivedItem.sku,
        status: ItemStatus.draft,
        displayOrder: archivedItem.displayOrder,
        createdAt: archivedItem.createdAt,
        updatedAt: DateTime.utc(2026, 6, 24, 12),
        primaryImagePath: archivedItem.primaryImagePath,
      ),
    ];
  }

  @override
  Future<ItemDeletionResult> deleteItem(String itemId) async {
    deleteCalls++;
    if (deleteFailure case final failure?) throw failure;

    lastDeletedItemId = itemId;
    currentItems = [
      for (final item in currentItems)
        if (item.id != itemId) item,
    ];
    archivedItems = [
      for (final item in archivedItems)
        if (item.id != itemId) item,
    ];
    return deletionResult;
  }

  @override
  Future<void> retryPendingStorageCleanup() async {
    retryCleanupCalls++;
  }
}
