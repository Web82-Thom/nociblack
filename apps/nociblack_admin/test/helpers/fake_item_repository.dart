import 'package:nociblack/features/items/domain/entities/catalog_item.dart';
import 'package:nociblack/features/items/domain/errors/item_failure.dart';
import 'package:nociblack/features/items/domain/repositories/item_repository.dart';

final class FakeItemRepository implements ItemRepository {
  FakeItemRepository({
    this.currentItems = const [],
    this.archivedItems = const [],
    this.currentFailure,
    this.archivedFailure,
  });

  List<CatalogItem> currentItems;
  List<CatalogItem> archivedItems;
  ItemFailure? currentFailure;
  ItemFailure? archivedFailure;
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
}
