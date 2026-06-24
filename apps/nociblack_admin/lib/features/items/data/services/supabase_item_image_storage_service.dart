import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/errors/item_failure.dart';
import '../../domain/services/item_image_storage_service.dart';

final class SupabaseItemImageStorageService implements ItemImageStorageService {
  SupabaseItemImageStorageService(this._supabase);

  static const String _bucketName = 'item-images';

  final SupabaseClient _supabase;

  @override
  Future<String> uploadItemImage({
    required String itemId,
    required String imageId,
    required Uint8List imageBytes,
  }) async {
    final imagePath = 'items/$itemId/$imageId.jpg';

    try {
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            imagePath,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
    } catch (_) {
      throw const ItemImageUploadFailure();
    }

    return '$_bucketName/$imagePath';
  }

  @override
  Future<void> deleteItemImage(String imagePath) async {
    final storagePath = imagePath.replaceFirst('$_bucketName/', '');

    try {
      await _supabase.storage.from(_bucketName).remove([storagePath]);
    } catch (_) {
      throw const ItemImageCleanupFailure();
    }
  }

  @override
  Future<void> deleteItemImages(List<String> imagePaths) async {
    if (imagePaths.isEmpty) {
      return;
    }

    final storagePaths = imagePaths
        .map((imagePath) => imagePath.replaceFirst('$_bucketName/', ''))
        .toList();

    try {
      await _supabase.storage.from(_bucketName).remove(storagePaths);
    } catch (_) {
      throw const ItemImageCleanupFailure();
    }
  }
}
