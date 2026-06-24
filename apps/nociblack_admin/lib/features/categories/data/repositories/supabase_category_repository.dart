import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/catalog_category.dart';
import '../../domain/entities/category_draft.dart';
import '../../domain/errors/category_failure.dart';
import '../../domain/repositories/category_repository.dart';
import '../mappers/catalog_category_mapper.dart';

/// Lecture des catégories actives depuis Supabase.
final class SupabaseCategoryRepository implements CategoryRepository {
  const SupabaseCategoryRepository(this._client);

  final SupabaseClient _client;

  static const _selection =
      'id, name, slug, description, display_order, is_active, '
      'created_at, updated_at';

  @override
  Future<List<CatalogCategory>> getActiveCategories() async {
    try {
      final rows = await _client
          .from('categories')
          .select(_selection)
          .eq('is_active', true)
          .order('display_order')
          .order('created_at')
          .order('id');

      return List.unmodifiable(rows.map(CatalogCategoryMapper.fromJson));
    } catch (_) {
      throw const CategoriesLoadFailure();
    }
  }

  @override
  Future<List<CatalogCategory>> getAllCategories() async {
    try {
      final rows = await _client
          .from('categories')
          .select(_selection)
          .order('display_order')
          .order('created_at')
          .order('id');

      return List.unmodifiable(rows.map(CatalogCategoryMapper.fromJson));
    } catch (_) {
      throw const CategoriesLoadFailure();
    }
  }

  @override
  Future<CatalogCategory> createCategory(CategoryDraft draft) async {
    try {
      final row = await _client
          .from('categories')
          .insert({
            'name': draft.name,
            'slug': draft.slug,
            'description': draft.description,
            'display_order': draft.displayOrder,
          })
          .select(_selection)
          .single();

      return CatalogCategoryMapper.fromJson(row);
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const CategoryConflictFailure();
      }
      throw const CategorySaveFailure();
    } catch (_) {
      throw const CategorySaveFailure();
    }
  }

  @override
  Future<CatalogCategory> updateCategory({
    required String id,
    required CategoryDraft draft,
  }) async {
    return _updateCategory(
      id: id,
      values: {
        'name': draft.name,
        'slug': draft.slug,
        'description': draft.description,
        'display_order': draft.displayOrder,
      },
    );
  }

  @override
  Future<CatalogCategory> setCategoryActive({
    required String id,
    required bool isActive,
  }) async {
    return _updateCategory(id: id, values: {'is_active': isActive});
  }

  Future<CatalogCategory> _updateCategory({
    required String id,
    required Map<String, Object?> values,
  }) async {
    try {
      final row = await _client
          .from('categories')
          .update(values)
          .eq('id', id)
          .select(_selection)
          .single();

      return CatalogCategoryMapper.fromJson(row);
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const CategoryConflictFailure();
      }
      throw const CategorySaveFailure();
    } catch (_) {
      throw const CategorySaveFailure();
    }
  }
}
