import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/catalog_item.dart';
import '../../domain/entities/item_deletion_result.dart';
import '../../domain/entities/item_draft.dart';
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

  @override
  Future<CatalogItem> createItem(ItemDraft draft) async {
    try {
      final row = await _client
          .from('items')
          .insert({
            'category_id': draft.categoryId,
            'title': draft.title,
            'slug': draft.slug,
            'description': draft.description,
            'price_cents': draft.priceCents,
            'stock_quantity': draft.stockQuantity,
            'sku': draft.sku,
            'display_order': draft.displayOrder,
          })
          .select(_selection)
          .single();

      return CatalogItemMapper.fromJson(row);
    } on PostgrestException catch (error) {
      if (error.code == '23505') throw const ItemConflictFailure();
      throw const ItemSaveFailure();
    } catch (_) {
      throw const ItemSaveFailure();
    }
  }

  @override
  Future<CatalogItem> updateItem({
    required String itemId,
    required ItemDraft draft,
  }) async {
    try {
      final row = await _client
          .from('items')
          .update({
            'category_id': draft.categoryId,
            'title': draft.title,
            'slug': draft.slug,
            'description': draft.description,
            'price_cents': draft.priceCents,
            'stock_quantity': draft.stockQuantity,
            'sku': draft.sku,
            'display_order': draft.displayOrder,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', itemId)
          .select(_selection)
          .single();

      return CatalogItemMapper.fromJson(row);
    } on PostgrestException catch (error) {
      if (error.code == '23505') throw const ItemConflictFailure();
      throw const ItemSaveFailure();
    } catch (_) {
      throw const ItemSaveFailure();
    }
  }

  List<CatalogItem> _mapRows(List<Map<String, dynamic>> rows) {
    return List.unmodifiable(rows.map(CatalogItemMapper.fromJson));
  }

  @override
  Future<void> archiveItem(String itemId) async {
    try {
      await _client
          .from('items')
          .update({
            'status': 'ARCHIVED',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', itemId)
          .select('id')
          .single();
    } catch (_) {
      throw const ItemSaveFailure();
    }
  }

  @override
  Future<void> publishItem(String itemId) async {
    try {
      await _client
          .from('items')
          .update({
            'status': 'PUBLISHED',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', itemId)
          .eq('status', 'DRAFT')
          .select('id')
          .single();
    } catch (_) {
      throw const ItemSaveFailure();
    }
  }

  @override
  Future<void> restoreItem(String itemId) async {
    try {
      await _client
          .from('items')
          .update({
            'status': 'DRAFT',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', itemId)
          .eq('status', 'ARCHIVED')
          .select('id')
          .single();
    } catch (_) {
      throw const ItemRestoreFailure();
    }
  }

  @override
  Future<ItemDeletionResult> deleteItem(String itemId) async {
    late final List<_StorageDeletionJob> jobs;

    try {
      final rows = await _client.rpc(
        'delete_item_permanently',
        params: {'target_item_id': itemId},
      );
      jobs = _mapDeletionJobs(rows);
    } catch (_) {
      throw const ItemDeleteFailure();
    }

    final cleanupCompleted = await _cleanupStorageJobs(jobs);

    return ItemDeletionResult(
      pendingStorageObjectCount: cleanupCompleted ? 0 : jobs.length,
    );
  }

  @override
  Future<void> retryPendingStorageCleanup() async {
    try {
      final rows = await _client.rpc(
        'get_pending_item_storage_deletions',
        params: {'requested_limit': 100},
      );
      await _cleanupStorageJobs(_mapDeletionJobs(rows));
    } catch (_) {
      // Le catalogue reste utilisable : les jobs durables seront repris lors
      // de la prochaine ouverture d'une collection d'articles.
    }
  }

  List<_StorageDeletionJob> _mapDeletionJobs(dynamic rows) {
    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_StorageDeletionJob.fromJson)
        .toList(growable: false);
  }

  Future<bool> _cleanupStorageJobs(List<_StorageDeletionJob> jobs) async {
    if (jobs.isEmpty) return true;

    try {
      final jobsByBucket = <String, List<_StorageDeletionJob>>{};
      for (final job in jobs) {
        jobsByBucket.putIfAbsent(job.bucketId, () => []).add(job);
      }

      for (final entry in jobsByBucket.entries) {
        await _client.storage
            .from(entry.key)
            .remove(entry.value.map((job) => job.objectName).toList());
      }

      await _client.rpc(
        'complete_item_storage_deletions',
        params: {'completed_job_ids': jobs.map((job) => job.id).toList()},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final class _StorageDeletionJob {
  const _StorageDeletionJob({
    required this.id,
    required this.bucketId,
    required this.objectName,
  });

  factory _StorageDeletionJob.fromJson(Map<String, dynamic> json) {
    return _StorageDeletionJob(
      id: json['job_id'] as String,
      bucketId: json['bucket_id'] as String,
      objectName: json['object_name'] as String,
    );
  }

  final String id;
  final String bucketId;
  final String objectName;
}
