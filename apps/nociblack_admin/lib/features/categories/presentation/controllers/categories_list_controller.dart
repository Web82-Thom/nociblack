import 'package:flutter/foundation.dart';

import '../../domain/entities/catalog_category.dart';
import '../../domain/errors/category_failure.dart';
import '../../domain/repositories/category_repository.dart';

enum CategoriesListStatus { initial, loading, success, failure }

final class CategoriesListController extends ChangeNotifier {
  CategoriesListController(this._repository);

  final CategoryRepository _repository;

  CategoriesListStatus _status = CategoriesListStatus.initial;
  List<CatalogCategory> _categories = const [];
  String? _errorMessage;

  CategoriesListStatus get status => _status;
  List<CatalogCategory> get categories => _categories;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _status = CategoriesListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
      _status = CategoriesListStatus.success;
    } on CategoryFailure catch (failure) {
      _categories = const [];
      _status = CategoriesListStatus.failure;
      _errorMessage = failure.message;
    } finally {
      notifyListeners();
    }
  }
}
