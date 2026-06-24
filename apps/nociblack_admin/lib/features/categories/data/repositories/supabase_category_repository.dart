import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/catalog_category.dart';
import '../../domain/errors/category_failure.dart';
import '../../domain/repositories/category_repository.dart';
import '../mappers/catalog_category_mapper.dart';

/// Lecture des catégories actives depuis Supabase.
final class SupabaseCategoryRepository implements CategoryRepository {
  const SupabaseCategoryRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<CatalogCategory>> getActiveCategories() async {
    try {
      final rows = await _client
          .from('categories')
          .select(
            'id, name, slug, description, display_order, is_active, '
            'created_at, updated_at',
          )
          .eq('is_active', true)
          .order('display_order')
          .order('created_at')
          .order('id');

      return List.unmodifiable(rows.map(CatalogCategoryMapper.fromJson));
    } catch (_) {
      throw const CategoriesLoadFailure();
    }
  }
}
