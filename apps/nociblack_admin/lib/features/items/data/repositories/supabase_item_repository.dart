import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/catalog_item.dart';
import '../../domain/errors/item_failure.dart';
import '../../domain/repositories/item_repository.dart';
import '../mappers/catalog_item_mapper.dart';

/// Implémentation Supabase de la lecture du catalogue administratif.
final class SupabaseItemRepository implements ItemRepository {
  const SupabaseItemRepository(this._client);

  static const _selection = '''
    id,
    category_id,
    title,
    description,
    price_cents,
    stock_quantity,
    sku,
    status,
    display_order,
    created_at,
    updated_at,
    categories(name),
    item_images(image_url, is_primary, display_order)
  ''';

  final SupabaseClient _client;

  @override
  Future<List<CatalogItem>> getCurrentItems() async {
    try {
      final rows = await _client
          .from('items')
          .select(_selection)
          .neq('status', 'ARCHIVED')
          .order('display_order')
          .order('created_at')
          .order('id');

      return _mapRows(rows);
    } catch (_) {
      throw const ItemsLoadFailure();
    }
  }

  @override
  Future<List<CatalogItem>> getArchivedItems() async {
    try {
      final rows = await _client
          .from('items')
          .select(_selection)
          .eq('status', 'ARCHIVED')
          .order('updated_at', ascending: false)
          .order('id');

      return _mapRows(rows);
    } catch (_) {
      throw const ItemsLoadFailure();
    }
  }

  List<CatalogItem> _mapRows(List<Map<String, dynamic>> rows) {
    return List.unmodifiable(rows.map(CatalogItemMapper.fromJson));
  }
}
