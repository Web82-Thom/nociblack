import 'package:flutter/foundation.dart';

import '../../domain/entities/item_draft.dart';
import '../../domain/errors/item_failure.dart';
import '../../domain/repositories/item_repository.dart';

final class ItemFormController extends ChangeNotifier {
  ItemFormController(this._repository);

  final ItemRepository _repository;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> create(ItemDraft draft) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createItem(draft);
      return true;
    } on ItemFailure catch (failure) {
      _errorMessage = failure.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
