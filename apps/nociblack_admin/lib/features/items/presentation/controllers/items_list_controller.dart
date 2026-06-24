import 'package:flutter/foundation.dart';

import '../../domain/entities/catalog_item.dart';
import '../../domain/errors/item_failure.dart';
import '../../domain/repositories/item_repository.dart';

enum ItemsCollection { current, archived }

enum ItemsListStatus { initial, loading, success, failure }

/// Pilote une collection d'articles sans dépendre de Supabase.
final class ItemsListController extends ChangeNotifier {
  ItemsListController({
    required ItemRepository repository,
    required ItemsCollection collection,
  }) : _repository = repository,
       _collection = collection;

  final ItemRepository _repository;
  final ItemsCollection _collection;

  ItemsListStatus _status = ItemsListStatus.initial;
  List<CatalogItem> _items = const [];
  String? _errorMessage;

  ItemsListStatus get status => _status;
  List<CatalogItem> get items => _items;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _status = ItemsListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = switch (_collection) {
        ItemsCollection.current => await _repository.getCurrentItems(),
        ItemsCollection.archived => await _repository.getArchivedItems(),
      };
      _status = ItemsListStatus.success;
    } on ItemFailure catch (failure) {
      _items = const [];
      _status = ItemsListStatus.failure;
      _errorMessage = failure.message;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> archiveItem(String itemId) async {
    return _executeMutation(() => _repository.archiveItem(itemId));
  }

  Future<bool> restoreItem(String itemId) async {
    return _executeMutation(() => _repository.restoreItem(itemId));
  }

  Future<bool> _executeMutation(Future<void> Function() mutation) async {
    _errorMessage = null;

    try {
      await mutation();
      await load();
      return _status == ItemsListStatus.success;
    } on ItemFailure catch (failure) {
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    }
  }
}
