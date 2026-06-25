import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/errors/item_failure.dart';
import '../../domain/services/item_image_display_service.dart';

/// Résout les chemins persistés en URL signées sans rendre le bucket public.
final class SupabaseItemImageDisplayService implements ItemImageDisplayService {
  SupabaseItemImageDisplayService(this._supabase);

  static const _bucketName = 'item-images';
  static const _signedUrlLifetimeInSeconds = 3600;
  static const _cacheLifetime = Duration(minutes: 50);

  final SupabaseClient _supabase;
  final Map<String, _CachedDisplayUrl> _cache = {};

  @override
  Future<String> createDisplayUrl(String imagePath) async {
    final now = DateTime.now();
    final cachedUrl = _cache[imagePath];

    if (cachedUrl != null && cachedUrl.expiresAt.isAfter(now)) {
      return cachedUrl.url;
    }

    final storagePath = imagePath.replaceFirst('$_bucketName/', '');

    try {
      final signedUrl = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(storagePath, _signedUrlLifetimeInSeconds);

      _cache[imagePath] = _CachedDisplayUrl(
        url: signedUrl,
        expiresAt: now.add(_cacheLifetime),
      );

      return signedUrl;
    } catch (_) {
      throw const ItemImageDisplayFailure();
    }
  }
}

final class _CachedDisplayUrl {
  const _CachedDisplayUrl({required this.url, required this.expiresAt});

  final String url;
  final DateTime expiresAt;
}
