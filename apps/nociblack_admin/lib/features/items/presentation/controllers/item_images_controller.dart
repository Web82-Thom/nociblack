import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/entities/item_image.dart';

class ItemImagesController extends ChangeNotifier {
  bool validateDraftImages() {
    return totalImageCount <= 3;
  }

  bool validatePublishImages() {
    return totalImageCount >= 1 && totalImageCount <= 3;
  }

  final List<ItemImage> _existingImages = [];

  final List<File> _newSelectedImages = [];

  final List<ItemImage> _removedExistingImages = [];

  List<ItemImage> get existingImages => List.unmodifiable(_existingImages);

  List<File> get newSelectedImages => List.unmodifiable(_newSelectedImages);

  List<ItemImage> get removedExistingImages =>
      List.unmodifiable(_removedExistingImages);

  int get totalImageCount =>
      _existingImages.length -
      _removedExistingImages.length +
      _newSelectedImages.length;

  bool get canAddImage => totalImageCount < 3;

  bool get hasAtLeastOneImage => totalImageCount > 0;

  void initialize(List<ItemImage> images) {
    _existingImages
      ..clear()
      ..addAll(images);

    _newSelectedImages.clear();
    _removedExistingImages.clear();

    notifyListeners();
  }

  void addSelectedImage(File imageFile) {
    if (!canAddImage) {
      return;
    }

    _newSelectedImages.add(imageFile);
    notifyListeners();
  }

  void removeSelectedImage(File imageFile) {
    _newSelectedImages.remove(imageFile);
    notifyListeners();
  }

  void markExistingImageForRemoval(ItemImage image) {
    if (_removedExistingImages.contains(image)) {
      return;
    }

    _removedExistingImages.add(image);
    notifyListeners();
  }

  void restoreExistingImage(ItemImage image) {
    _removedExistingImages.remove(image);
    notifyListeners();
  }
}
