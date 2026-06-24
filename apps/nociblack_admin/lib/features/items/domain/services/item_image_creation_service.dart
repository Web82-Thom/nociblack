/// Orchestre la préparation et la persistance des nouvelles images d'un article.
abstract interface class ItemImageCreationService {
  Future<void> createImages({
    required String itemId,
    required List<String> sourcePaths,
  });
}
