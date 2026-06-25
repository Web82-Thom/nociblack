import '../entities/item_image.dart';

/// Synchronise les images d'un article existant depuis l'état du formulaire.
///
/// Le formulaire ne manipule pas directement Supabase Storage ni `item_images` :
/// ce service garde l'orchestration au niveau applicatif et centralise les
/// compensations nécessaires entre Storage et PostgreSQL.
abstract interface class ItemImageUpdateService {
  Future<void> updateImages({
    required String itemId,
    required List<ItemImage> existingImages,
    required List<ItemImage> removedExistingImages,
    required List<String> newSourcePaths,
  });
}
