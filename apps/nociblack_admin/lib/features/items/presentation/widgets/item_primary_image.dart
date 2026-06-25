import 'package:flutter/material.dart';

import '../../domain/services/item_image_display_service.dart';

/// Miniature d'une image Storage privée avec un fallback stable.
final class ItemPrimaryImage extends StatefulWidget {
  const ItemPrimaryImage({
    required this.imagePath,
    required this.displayService,
    this.size = 96,
    super.key,
  });

  final String? imagePath;
  final ItemImageDisplayService displayService;
  final double size;

  @override
  State<ItemPrimaryImage> createState() => _ItemPrimaryImageState();
}

final class _ItemPrimaryImageState extends State<ItemPrimaryImage> {
  Future<String>? _displayUrl;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant ItemPrimaryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.displayService != widget.displayService) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    final imagePath = widget.imagePath;
    _displayUrl = imagePath == null
        ? null
        : widget.displayService.createDisplayUrl(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final displayUrl = _displayUrl;

    if (displayUrl == null) {
      return _ItemImageFallback(size: widget.size);
    }

    return SizedBox.square(
      dimension: widget.size,
      child: FutureBuilder<String>(
        future: displayUrl,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ItemImageFallback(size: widget.size);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              snapshot.requireData,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _ItemImageFallback(size: widget.size),
            ),
          );
        },
      ),
    );
  }
}

final class _ItemImageFallback extends StatelessWidget {
  const _ItemImageFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }
}
