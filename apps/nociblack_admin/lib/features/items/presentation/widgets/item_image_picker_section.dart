import 'dart:io';

import 'package:flutter/material.dart';
import 'selected_item_image_preview.dart';

class ItemImagePickerSection extends StatelessWidget {
  const ItemImagePickerSection({
    super.key,
    required this.imageCount,
    required this.onAddImagePressed,
    required this.selectedImages,
    required this.onRemoveSelectedImage,
  });

  final int imageCount;
  final VoidCallback onAddImagePressed;
  final List<File> selectedImages;
  final ValueChanged<File> onRemoveSelectedImage;

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
            if (selectedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: selectedImages
                    .map((imageFile) {
                      return SelectedItemImagePreview(
                        imageFile: imageFile,
                        onRemovePressed: () => onRemoveSelectedImage(imageFile),
                      );
                    })
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
