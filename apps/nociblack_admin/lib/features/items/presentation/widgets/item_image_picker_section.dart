import 'dart:io';

import 'package:flutter/material.dart';
import '../../domain/entities/item_image.dart';
import '../../domain/services/item_image_display_service.dart';
import 'existing_item_image_preview.dart';
import 'selected_item_image_preview.dart';

class ItemImagePickerSection extends StatelessWidget {
  const ItemImagePickerSection({
    super.key,
    required this.imageCount,
    required this.onAddImagePressed,
    required this.existingImages,
    required this.removedExistingImages,
    required this.imageDisplayService,
    required this.selectedImages,
    required this.onRemoveExistingImage,
    required this.onRestoreExistingImage,
    required this.onRemoveSelectedImage,
  });

  final int imageCount;
  final VoidCallback? onAddImagePressed;
  final List<ItemImage> existingImages;
  final List<ItemImage> removedExistingImages;
  final ItemImageDisplayService imageDisplayService;
  final List<File> selectedImages;
  final ValueChanged<ItemImage>? onRemoveExistingImage;
  final ValueChanged<ItemImage>? onRestoreExistingImage;
  final ValueChanged<File>? onRemoveSelectedImage;

  @override
  Widget build(BuildContext context) {
    final canAddImage = imageCount < 3;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Images ($imageCount/3)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: canAddImage ? onAddImagePressed : null,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Ajouter une image'),
            ),
            if (existingImages.isNotEmpty || selectedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...existingImages.map((image) {
                    final isMarkedForRemoval = removedExistingImages.any(
                      (removedImage) => removedImage.id == image.id,
                    );

                    return ExistingItemImagePreview(
                      image: image,
                      imageDisplayService: imageDisplayService,
                      isMarkedForRemoval: isMarkedForRemoval,
                      onRemovePressed: onRemoveExistingImage == null
                          ? null
                          : () => onRemoveExistingImage!(image),
                      onRestorePressed: onRestoreExistingImage == null
                          ? null
                          : () => onRestoreExistingImage!(image),
                    );
                  }),
                  ...selectedImages.map((imageFile) {
                    return SelectedItemImagePreview(
                      imageFile: imageFile,
                      onRemovePressed: onRemoveSelectedImage == null
                          ? null
                          : () => onRemoveSelectedImage!(imageFile),
                    );
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
