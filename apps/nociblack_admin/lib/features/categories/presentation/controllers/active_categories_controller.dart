import 'package:flutter/foundation.dart';

import '../../domain/entities/catalog_category.dart';
import '../../domain/errors/category_failure.dart';
import '../../domain/repositories/category_repository.dart';

enum ActiveCategoriesStatus { initial, loading, success, failure }

/// Charge les catégories sélectionnables sans exposer le SDK aux widgets.
final class ActiveCategoriesController extends ChangeNotifier {
  ActiveCategoriesController(this._repository);

  final CategoryRepository _repository;

  ActiveCategoriesStatus _status = ActiveCategoriesStatus.initial;
  List<CatalogCategory> _categories = const [];
  String? _errorMessage;

  ActiveCategoriesStatus get status => _status;
  List<CatalogCategory> get categories => _categories;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _status = ActiveCategoriesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getActiveCategories();
      _status = ActiveCategoriesStatus.success;
    } on CategoryFailure catch (failure) {
      _categories = const [];
      _status = ActiveCategoriesStatus.failure;
      _errorMessage = failure.message;
    } finally {
      notifyListeners();
    }
  }
}
