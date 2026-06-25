import 'package:flutter/foundation.dart';

import '../../domain/entities/item_draft.dart';
import '../../domain/errors/item_failure.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/services/item_image_creation_service.dart';
import '../../domain/services/item_image_update_service.dart';
import '../../domain/entities/item_image.dart';

final class ItemFormController extends ChangeNotifier {
  ItemFormController({
    required ItemRepository repository,
    required ItemImageCreationService imageCreationService,
    required ItemImageUpdateService imageUpdateService,
  }) : _repository = repository,
       _imageCreationService = imageCreationService,
       _imageUpdateService = imageUpdateService;

  final ItemRepository _repository;
  final ItemImageCreationService _imageCreationService;
  final ItemImageUpdateService _imageUpdateService;

  bool _isSubmitting = false;
  String? _errorMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<String?> create(
    ItemDraft draft, {
    List<String> imageSourcePaths = const [],
  }) async {
    if (_isSubmitting) return null;

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
        try {
          await _repository.deleteItem(createdItem.id);
        } on ItemFailure {
          _errorMessage = const ItemCreationRollbackFailure().message;
          return null;
        }

        _errorMessage = failure.message;
        return null;
      }

      return createdItem.id;
    } on ItemFailure catch (failure) {
      _errorMessage = failure.message;
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> update({
    required String itemId,
    required ItemDraft draft,
    List<ItemImage> existingImages = const [],
    List<ItemImage> removedExistingImages = const [],
    List<String> newImageSourcePaths = const [],
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateItem(itemId: itemId, draft: draft);
      await _imageUpdateService.updateImages(
        itemId: itemId,
        existingImages: existingImages,
        removedExistingImages: removedExistingImages,
        newSourcePaths: newImageSourcePaths,
      );
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

  Future<bool> publish(String itemId) async {
  if (_isSubmitting) return false;

  _isSubmitting = true;
  _errorMessage = null;
  notifyListeners();

  try {
    await _repository.publishItem(itemId);
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
