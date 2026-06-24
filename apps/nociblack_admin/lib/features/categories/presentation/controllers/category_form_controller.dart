import 'package:flutter/foundation.dart';

import '../../domain/entities/category_draft.dart';
import '../../domain/errors/category_failure.dart';
import '../../domain/repositories/category_repository.dart';

final class CategoryFormController extends ChangeNotifier {
  CategoryFormController(this._repository);

  final CategoryRepository _repository;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> create(CategoryDraft draft) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createCategory(draft);
      return true;
    } on CategoryFailure catch (failure) {
      _errorMessage = failure.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
