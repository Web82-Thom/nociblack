import 'package:flutter/material.dart';

import '../../domain/entities/item_image.dart';
import '../../domain/services/item_image_display_service.dart';

class ExistingItemImagePreview extends StatefulWidget {
  const ExistingItemImagePreview({
    required this.image,
    required this.imageDisplayService,
    required this.isMarkedForRemoval,
    required this.onRemovePressed,
    required this.onRestorePressed,
    super.key,
  });

  final ItemImage image;
  final ItemImageDisplayService imageDisplayService;
  final bool isMarkedForRemoval;
  final VoidCallback? onRemovePressed;
  final VoidCallback? onRestorePressed;

  @override
  State<ExistingItemImagePreview> createState() =>
      _ExistingItemImagePreviewState();
}

final class _ExistingItemImagePreviewState
    extends State<ExistingItemImagePreview> {
  late Future<String> _displayUrlFuture;

  @override
  void initState() {
    super.initState();
    _displayUrlFuture = widget.imageDisplayService.createDisplayUrl(
      widget.image.imageUrl,
    );
  }

  @override
  void didUpdateWidget(covariant ExistingItemImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.imageUrl != widget.image.imageUrl) {
      _displayUrlFuture = widget.imageDisplayService.createDisplayUrl(
        widget.image.imageUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: widget.isMarkedForRemoval ? 0.35 : 1,
          duration: const Duration(milliseconds: 150),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FutureBuilder<String>(
              future: _displayUrlFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const _ImagePlaceholder();
                }

                return Image.network(
                  snapshot.data!,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            onPressed: widget.isMarkedForRemoval
                ? widget.onRestorePressed
                : widget.onRemovePressed,
            icon: Icon(widget.isMarkedForRemoval ? Icons.undo : Icons.close),
            tooltip: widget.isMarkedForRemoval ? 'Restaurer' : 'Supprimer',
          ),
        ),
      ],
    );
  }
}

final class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
