import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/item_image.dart';
import '../../domain/errors/item_failure.dart';
import '../../domain/repositories/item_image_repository.dart';

final class SupabaseItemImageRepository implements ItemImageRepository {
  SupabaseItemImageRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<ItemImage> createItemImage({
    required String itemId,
    required String imageUrl,
    required int displayOrder,
    required bool isPrimary,
  }) async {
    try {
      final row = await _supabase
          .from('item_images')
          .insert({
            'item_id': itemId,
            'image_url': imageUrl,
            'display_order': displayOrder,
            'is_primary': isPrimary,
          })
          .select()
          .single();

      return _mapRowToItemImage(row);
    } catch (_) {
      throw const ItemImageSaveFailure();
    }
  }

  @override
  Future<List<ItemImage>> getImagesByItemId(String itemId) async {
    try {
      final rows = await _supabase
          .from('item_images')
          .select()
          .eq('item_id', itemId)
          .order('display_order');

      return List.unmodifiable(rows.map(_mapRowToItemImage));
    } catch (_) {
      throw const ItemImagesLoadFailure();
    }
  }

  @override
  Future<void> updateItemImagePosition({
    required String imageId,
    required int displayOrder,
    required bool isPrimary,
  }) async {
    try {
      await _supabase
          .from('item_images')
          .update({'display_order': displayOrder, 'is_primary': isPrimary})
          .eq('id', imageId)
          .select('id')
          .single();
    } catch (_) {
      throw const ItemImageSaveFailure();
    }
  }

  @override
  Future<void> deleteItemImagesByIds(List<String> imageIds) async {
    if (imageIds.isEmpty) {
      return;
    }

    try {
      await _supabase.from('item_images').delete().inFilter('id', imageIds);
    } catch (_) {
      throw const ItemImageSaveFailure();
    }
  }

  ItemImage _mapRowToItemImage(Map<String, dynamic> row) {
    return ItemImage(
      id: row['id'] as String,
      itemId: row['item_id'] as String,
      imageUrl: row['image_url'] as String,
      displayOrder: row['display_order'] as int,
      isPrimary: row['is_primary'] as bool,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
