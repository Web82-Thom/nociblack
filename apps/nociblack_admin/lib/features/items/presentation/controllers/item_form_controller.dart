import 'package:flutter/foundation.dart';

import '../../domain/entities/item_draft.dart';
import '../../domain/errors/item_failure.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/services/item_image_creation_service.dart';

final class ItemFormController extends ChangeNotifier {
  ItemFormController({
    required ItemRepository repository,
    required ItemImageCreationService imageCreationService,
  }) : _repository = repository,
       _imageCreationService = imageCreationService;

  final ItemRepository _repository;
  final ItemImageCreationService _imageCreationService;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> create(
    ItemDraft draft, {
    List<String> imageSourcePaths = const [],
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdItem = await _repository.createItem(draft);

      try {
        await _imageCreationService.createImages(
          itemId: createdItem.id,
          sourcePaths: imageSourcePaths,
        );
      } on ItemFailure catch (failure) {
        // La soumission du formulaire représente un seul agrégat pour
        // l'utilisateur. Le brouillon est donc supprimé si ses images ne
        // peuvent pas être enregistrées, ce qui rend le retry idempotent.
        try {
          await _repository.deleteItem(createdItem.id);
        } on ItemFailure {
          _errorMessage = const ItemCreationRollbackFailure().message;
          return false;
        }

        _errorMessage = failure.message;
        return false;
      }

      return true;
    } on ItemFailure catch (failure) {
      _errorMessage = failure.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> update({
    required String itemId,
    required ItemDraft draft,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateItem(itemId: itemId, draft: draft);
      return true;
    } on ItemFailure catch (failure) {
      _errorMessage = failure.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> archive(String itemId) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.archiveItem(itemId);
      return true;
    } on ItemFailure catch (failure) {
      _errorMessage = failure.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> delete(String itemId) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteItem(itemId);
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
