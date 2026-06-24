import 'dart:io';

import 'package:flutter/material.dart';

class SelectedItemImagePreview extends StatelessWidget {
  const SelectedItemImagePreview({
    super.key,
    required this.imageFile,
    required this.onRemovePressed,
  });

  final File imageFile;
  final VoidCallback? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            imageFile,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            onPressed: onRemovePressed,
            icon: const Icon(Icons.close),
            tooltip: 'Supprimer',
          ),
        ),
      ],
    );
  }
}
